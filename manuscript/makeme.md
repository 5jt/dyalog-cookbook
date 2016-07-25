{:: encoding="utf-8" /}

# Make me

It's time to take a closer look at the process of building the application workspace and exporting the EXE. In this chapter we'll

* split the DYAPP into separate versions -- one to create the development and testing environment, the other to assemble and export the application;
* automate the export process;
* write tests for the EXE.

We resume, as usual, by saving a copy of `Z:\code\v05` as `Z:\code\v06`.


## Make me whole, make me lean 

Our makefile, `MyApp.dyapp`, includes scripts we have no reason to include in the exported EXE:

	Target #
	Load ..\AplTree\APLTreeUtils
	Load ..\AplTree\ADOC
	Load ..\AplTree\HandleError
	Load ..\AplTree\IniFiles
	Load ..\AplTree\Logger
	Load ..\AplTree\WinFile
	Load ..\AplTree\Tester
	Load Constants
	Load Utilities
	Load Tests
	Load MyApp
	Run MyApp.Start 'Session'

`ADOC`, `Tester` and `Tests` have no place in the finished application. 

We could expunge them before exporting the active workspace as an EXE. Or -- have _two_ makefiles, one for the development environment, one for export. 

Duplicate `MyApp.dyapp` and name the files `Develop.dyapp` and `Export.dyapp`. Edit `Export.dyapp` as follows: 

    Target #
    Load ..\AplTree\APLTreeUtils
    Load ..\AplTree\HandleError
    Load ..\AplTree\IniFiles
    Load ..\AplTree\Logger
    Load ..\AplTree\WinFile
    Load Constants
    Load Utilities
    Load MyApp
    Run MyApp.Start 'Export'

Now, `#.MyApp.Start` doesn't yet have an Export mode, so we'd better give it one: 

      ...
      :Select mode
      :Case 'Export'
          #.⎕LX←'#.MyApp.Start ''Application''' ⍝ ready to export
      :Case 'Session'
          ⎕←'Alphabet is ',Params.alphabet
          ⎕←'Defined alphabets: ',⍕U.m2n Params.ALPHABETS.⎕NL 2
      :Case 'Application'
          exit←TxtToCsv Params.source
          Off exit
      :EndSelect

Notice that Session mode no longer needs to set the Latent Expression. 


## Refactoring

We also notice now that the contents of `#.MyApp` divide into two groups. One is concerned with setting up the environment and communicating with the operating system. The other does the work of MyApp. We'll now refactor them into separate namespaces: `MyApp` and `Environment`.

`MyApp` will continue to contain the code for counting frequency. But the code for interrogating the environment, setting error traps, and starting logging -- we'll move that into `Environment`. And we'll minimise the cross references between the two. 

First, all the default parameter values for `MyApp` -- the values it has to have in case they are set nowhere else -- can go into a simple, static namespace:

    :Namespace PARAMETERS
        :Namespace ALPHABETS
            English←⎕A
            French←'AÁÂÀBCÇDEÈÊÉFGHIÌÍÎJKLMNOÒÓÔPQRSTUÙÚÛVWXYZ'
            German←'AÄBCDEFGHIJKLMNOÖPQRSßTUÜVWXYZ'
            Greek←'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'
        :EndNamespace
        accented←0
        alphabet←'English'
        source←''
        output←''
    :EndNamespace

We'll leave to `Environment` the definition of `MyApp.Params` and `MyApp.Log` and just make a note of that in `MyApp`:

    ⍝ Objects Log and Params are defined by #.Environment.Start

That lets us cut `MyApp` down to size:

          )CS MyApp
    #.MyApp
          )FNS
    CheckAgenda     CountLetters    CountLettersIn  TxtToCsv
          )VARS
    ACCENTS ∆

`Environment` will get the `Start` function. For extra clarity we'll rename the start modes to `Develop`, `Export` and `Run`. 

    ∇ Start mode;∆
    ⍝ Initialise workspace for development, export or use
    ⍝ mode: ['Develop' | 'Export' | 'Run']
      :If mode≡'Run`'
          ⍝ trap problems in startup
          #.⎕TRAP←0 'E' '#.HandleError.Process '''''
      :EndIf
      ⎕WSID←'MyApp'

It must now create the `Log` object 'over there' -- within `#.MyApp`. 

      'CREATE!'#.WinFile.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←{
          ⍵.path←'Logs\' ⍝ subfolder of current directory
          ⍵.encoding←'UTF8'
          ⍵.filenamePrefix←'MyApp'
          ⍵.refToUtils←#
          ⍵
      }#.Logger.CreatePropertySpace
      #.MyApp.Log←⎕NEW #.Logger(,⊂∆)

Similarly it must set the `Params` namespace in `#.MyApp`:

      #.MyApp.Params←mode GetParameters #.MyApp.PARAMETERS 

While we're at this, we've switched the arguments in `GetParameters` to follow an ancient APL convention for functions, that the right argument represents data and any left argument, some modifier for the function.[^circle] 

What happens next depends upon the mode. If we're getting ready to develop, we want tools and tests. We'll ensure global error trapping is off, so we can investigate any errors. And we might as well start by running the tests:

      :Select mode
     
      :Case 'Develop'
          #.⎕TRAP←0⍴#.⎕TRAP
          ⎕←'Alphabet is ',#.MyApp.Params.alphabet
          ⎕←'Defined alphabets: ',⍕U.m2n #.MyApp.Params.ALPHABETS.⎕NL 2
          #.Tester.EstablishHelpersIn #.Tests
          #.Tests.Run

If we're starting in Export mode, everything is ready to export as an EXE. We'll just display the expression that does that.

      :Case 'Export'
          ⎕←U.ScriptFollowing
          ⍝ Exporting to an EXE can fail unpredictably.
          ⍝ Retry the following expression if it fails,
          ⍝ or use the File>Export dialogue from the menus.
          ⍝      #.Environment.Export '.\MyApp.exe'

We'll define that `Export` function in a moment. Right now, we'll set out what the EXE is to do when it runs:

      :Case 'Run'
          #.ErrorParms←{
              ⍵.errorFolder←#.WinFile.PWD
              ⍵.returnCode←#.MyApp.EXIT.APPLICATION_CRASHED
              ⍵.(logFunctionParent logFunction)←(#.MyApp.Log)('Log')
              ⍵.trapInternalErrors←~#.APLTreeUtils.IsDevelopment
          }#.HandleError.CreateParms
          #.⎕TRAP←0 'E' '#.HandleError.Process ''#.ErrorParms'''
          Off #.MyApp.TxtToCsv #.MyApp.Params.source

Now that `Export` function. You'll have noticed exporting an EXE can fail from time to time, and you've performed this from the _File_ menu enough times to have wearied of it. So we'll automate it. Automating it doesn't make it any more reliable, but it certainly makes retries easier. 

    ∇ msg←Export filename;type;flags;resource;icon;cmdline;nl
      #.⎕LX←'#.Environment.Start ''Run'''
     
      type←'StandaloneNativeExe'
      flags←2 ⍝ BOUND_CONSOLE
      resource←''
      icon←'.\images\gear.ico'
      cmdline←''
      :Trap 0
          2 ⎕NQ'.' 'Bind',filename type flags resource icon cmdline
          msg←'Exported ',filename
      :Else
          msg←'**ERROR: Failed to export EXE.'
      :EndTrap
    ∇

Basically, the choices you have been making from the _File > Export_ dialogue, now wrapped as a function. 

One last tweak to the setup for development. Let's have some handy tools defined in `#.MyApp` just for when we're working in there. 

    :Namespace DevTools
    ⍝ Developer tools 
    ⍝ Vern: sjt25jul16
          
        fc←{⍺(≢⍵)}⌸ ⍝ frequency count
        same←{⍵≡¨⊂⊃⍵}∘,
        type←{type←{'CN'[⎕IO+0=⊃0⍴⊃⍣≡⍵]}}
        wi←{(≡⍵)(type ⍵)(⍴⍵)} ⍝ what is this array?
           
    :EndNamespace

A few tweaks now to the makefiles. `Develop.dyapp`:

    Target #
    Load ..\AplTree\APLTreeUtils
    Load ..\AplTree\ADOC
    Load ..\AplTree\HandleError
    Load ..\AplTree\IniFiles
    Load ..\AplTree\Logger
    Load ..\AplTree\WinFile
    Load ..\AplTree\Tester
    Load Constants
    Load Tests
    Load Utilities
    Load MyApp
    Load Environment
    Target #.MyApp
    Load DevTools -disperse
    Run #.Environment.Start 'Develop'

Note the `Target #.MyApp` followed by `Load DevTools -disperse`. That disperses the contents of the `DevTools` namespace into `#.MyApp`. (Watch out for name conflicts if you do this.) Now when we're working in `MyApp` we'll have some tools to hand. 

Running the DYAPP creates our working environment and runs the tests:

    clear ws
    Booting Z:\code\v06\Develop.dyapp
    Loaded: #.APLTreeUtils
    Loaded: #.ADOC
    Loaded: #.HandleError
    Loaded: #.IniFiles
    Loaded: #.Logger
    Loaded: #.WinFile
    Loaded: #.Tester
    Loaded: #.Constants
    Loaded: #.Tests
    Loaded: #.Utilities
    Loaded: #.MyApp
    Loaded: #.Environment
    Loaded: * 4 objects dispersed in #.MyApp
    Alphabet is Russian
    Defined alphabets:  English  French  German  Greek  Russian 
    --- Tests started at 2016-07-25 15:18:17  on #.Tests ---------------------
      Test_CountLettersIn_001 (1 of 12) : across multiple files
      Test_CountLetters_001 (2 of 12) : base case
      Test_toLowercase_001 (3 of 12) : boundary case
      Test_toLowercase_002 (4 of 12) : no case
      Test_toLowercase_003 (5 of 12) : base case
      Test_toLowercase_004 (6 of 12) : accented Latin and Greek characters
      Test_toTitlecase_001 (7 of 12) : base case
      Test_toTitlecase_002 (8 of 12) : Greek script
      Test_toUppercase_001 (9 of 12) : boundary case
      Test_toUppercase_002 (10 of 12) : no case
      Test_toUppercase_003 (11 of 12) : base case
      Test_toUppercase_004 (12 of 12) : accented Latin and Greek characters
     --------------------------------------------------------------------------
       12 test cases executed
       0 test cases failed
       0 test cases broken

The foregoing is a good example of how having automated tests allows us to refactor code with confidence that we'll notice and fix anything we break. 

Slight tweaks to the export makefile and we can export an EXE. `Export.dyapp`: 

    Target #
    Load ..\AplTree\APLTreeUtils
    Load ..\AplTree\HandleError
    Load ..\AplTree\IniFiles
    Load ..\AplTree\Logger
    Load ..\AplTree\WinFile
    Load Constants
    Load Utilities
    Load MyApp
    Load Environment
    Run #.Environment.Start 'Export'

Run this new export makefile and we get a new session: 

    clear ws
    Booting Z:\code\v06\Export.dyapp
    Loaded: #.APLTreeUtils
    Loaded: #.HandleError
    Loaded: #.IniFiles
    Loaded: #.Logger
    Loaded: #.WinFile
    Loaded: #.Constants
    Loaded: #.Utilities
    Loaded: #.MyApp
    Loaded: #.Environment
     Exporting to an EXE can fail unpredictably.                        
     Retry the following expression if it fails,                        
     or use the File>Export dialogue from the menus.                    
          #.Environment.Export '.\MyApp.exe'                            

And if we execute the suggested expression...[^export]

          #.Environment.Export '.\MyApp.exe'                            
    Exported .\MyApp.exe


## Testing the EXE


[^circle]: the best example of this are the circle functions represented by `○`. 
[^export]: It would be great if `#.Environment.Export` could be run straight from the DYAPP. But the DYAPP has to finish before an EXE can be exported. 

