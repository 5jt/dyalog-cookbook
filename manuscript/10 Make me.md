{:: encoding="utf-8" /}
[parm]:title='Make'

# Make me

It's time to take a closer look at the process of building the application workspace and exporting the EXE. In this chapter we'll

* add the automated execution of test cases to the DYAPP.

* create a "Make" utility that allows us to create everything thats needed for what will finally be shipped to the customer.

At first glance you might think we can get away with splitting the DYAPP into two different versions, one for development and one for producing the final version of the EXE, but there will be tasks we cannot carry out with this approach. Examples are:

* Currently we depend on whatever version of Dyalog is associated with DYAPPs. We need an explicit way to define that version, even if for the time being there is just one version installed on our machine.

* We might want to convert any Markdown documents -- like README.MD -- into HTML documents. While the MD is the source, only the HTML will become part of the final product.

* We need to make sure that the help system -- which we will introduce soon -- is properly compiled and configured by the "make" utility.

* Soon we need an installer that produces an EXE we can send to the customer for installing the software.

We resume, as usual, by saving a copy of `Z:\code\v09` as `Z:\code\v10`. Now delete `MyApp.exe` from `Z:\code\v10`: from now on we will create the EXE somewhere else.


## The development environment

`MyApp.dyapp` does not need many changes, it comes with everything that's needed for development. The only thing we add is to execute the test cases automatically. Well, almost automatically. 

Ideally we should always make sure that all test cases pass when we call it a day, but sometimes that is just not possible due to the amount of work involved. 

In such cases it might or might not be sensible to execute the test cases before you _start_ working: in case you _know_ they will fail and there are _many_ of them there is no point in wasting computer ressources and your time, so we better ask.

### Development helpers

For that we are going to have a function `YesOrNo` which is very simple and straightforward: the right argument (`question`) is printed to the session and then the user might answer that question.

If she does not enter one of: "YyNn" the question is repeated. If she enters one of "Yy" a 1 is returned, otherwise a 0. Since we use this to ask ourself (or other programmers) the function does not have to be bullet proof; that's why we allow `¯1↑⍞`.

But where exactly should this function go? Though it is helpful it has no part in our final application. Therefore we put it into a new script called `DevHelpers`. We also add a function `RunTests` to this new script:

~~~
:Namespace DevHelpers

∇ {r}←RunTests forceFlag
⍝ Runs the test cases in debug mode, either in case the user wants to 
⍝ or if `forceFlag` is 1.
  r←''
  :If forceFlag
  :OrIf YesOrNo'Would you like to execute all test cases in debug mode?'
      r←#.Tests.RunDebug 0
  :EndIf
∇

∇ flag←YesOrNo question;isOkay;answer
  isOkay←0
  ⎕←(⎕PW-1)⍴'-'
  :Repeat
      ⍞←question,' (y/n) '
      answer←¯1↑⍞
      :If answer∊'YyNn'
          isOkay←1
          flag←answer∊'Yy'
      :EndIf
  :Until isOkay
∇

:EndNamespace
~~~

### Running test cases first thing in the morning

We add a line to the bottom of `MyApp.dyapp`:

~~~
...
Run #.Tester.EstablishHelpersIn #.Tests
leanpub-start-insert
Run #.DevHelpers.RunTests 0
leanpub-end-insert
~~~

Now a developer who double-clicks the DYAPP in order to assemble the workspace will always be reminded of running all test cases before she starts working on the application. Experience tells us that this is a good thing.


## MyApp.dyalog

One minor thing needs our attention: because we create `MyApp.exe` now in a folder `MyApp` simply setting `⎕WSID` to `MyApp` does not do any more. Therefore we need to make a change to the `StartFromCmdLine` function in `MyApp.dyalog`:

~~~
...
∇ {r}←StartFromCmdLine arg;MyLogger;Config;rc;⎕TRAP
   ⍝ Needs command line parameters, runs the application.
      r←⍬
      ⎕TRAP←#.HandleError.SetTrap ⍬
      ⎕SIGNAL 0
leanpub-start-insert      
      ⎕WSID←⊃{⍵/⍨~'='∊¨⍵}{⍵/⍨'-'≠⊃¨⍵}1↓2⎕nq # 'GetCommandLineArgs'
leanpub-end-insert      
      #.FilesAndDirs.PolishCurrentDir
...      
~~~

This change makes sure that the `⎕WSID` will be correct. Under the current circumstances it will be `MyApp\MyApp.dws`.

Note that we access `GetCommandLineArgs` as a function call with `⎕NQ` rather than referring to `#.GetCommandLineArgs`; over the years that has proven to be more reliable.


## "Make" the application

I> In most programming languages the process of compiling the source code and putting together an application is done by a utility that's called "Make"; therefore we use the same term.

At first sight it might seem that we can get away with a reduced version of `MyApp.dyapp`, but that is not quite true. Soon we will discuss how to add a help system to our application. 

We must then make sure that the help system is compiled properly when the application is assembled. Later even more tasks will come up. Conclusion: we cannot do this with a DYAPP; we need more flexibility.

A> # More complex scenarios 
A> 
A> In a more complex application than ours you might prefer a different approach. Using an INI file for this is not a bad idea: it gives you way more freedom in defining all sorts of things while a DYAPP allows you to define just the modules to be loaded, and to execute some code.
A> 
A> Also, if you have not one but quite a number of applications to deal with it is certainly not a bad idea to implement your own generalized user command like `]runmake`.

`Execute`, `Tester` and `Tests` have no place in the finished application, and we don't need to establish the test helpers either.

### Batch file for starting Dyalog

We are going to create a DYAPP file `Make.dyapp` that performs the "Make".

However, if you want to make sure that you can specify explicitly the version of Dyalog that should run this DYAPP rather than relying on what happens to be associated with the file extensions DWS, DYALOG and DYAPP at the time you double-click it then you need a batch file that starts the correct version of Dyalog. 

Create such a batch file as `Make.bat`. This is the contents:

~~~
"C:\Program Files\Dyalog\Dyalog APL{yourPreferredVersion}\Dyalog.exe" DYAPP="%~dp0Make.dyapp"
@echo off
if NOT ["%errorlevel%"]==["0"] (
    echo Error %errorlevel%
    pause
    exit /b %errorlevel%
)
~~~

Of course you need to make amendments so that it is using the version of Dyalog of your choice. If it is at the moment what happens to run  a DYAPP on a double-click then this will give you the correct path:

~~~
'"',(⊃#.GetCommandLineArgs),'"'
~~~

You might want to add other parameters like `MAXWS=128M` (or `MAXWS=6G`) to the BAT file.

Notes:

* The expression `%~dp0` in a batch file will give you the full path -- with a trailing `\` -- of the folder that hosts the batch file. In other words, `"%~dp0Make.dyapp"` would result in a full path pointing to `MyApp.dyapp`, no matter where that is as long as it is a sibling of the BAT file. 

  You _must_ specify a full path because when the interpreter tries to find the DYAPP, the current directory is where the EXE lives, _not_ where the BAT file lives.

* Checking `errorlevel` makes sure that in case of an error the batch file shows the return code and then pauses. 

  That gets us around the nasty problem that when you double-click a BAT file, you see a black windows popping up for a split of a second and then it's gone, leaving you wondering whether it has worked alright or not.

  Now when an error occurs it will pause. In addition it will pass the value of `errorlevel` as return code of the batch script.

  However, this technique is suitable only for scripts that are supposed to be executed by a WCU [^WCU]; you don't want to have a pause in scripts that are called by other scripts.


A> # The current directory
A> 
A> For APLers, the current directory (sometimes called "working directory") is, when running under Windows, a strange animal. In general, the current directory is where "the application" lives. 
A> 
A> That means that if you start an application `C:\Program Files\Foo\Foo.exe` then for the application "Foo" the current directory will be `C:\Program Files\Foo`. 
A>
A> That's fine except that for APLers "the application" is _not_ the DYALOG.EXE, it's the workspace, whether it was loaded from disk or assembled by a DYAPP. When you double-click `MyApp.dyapp` then the interpreter changes the current directory for you: it's going to be where the DYAPP lives, and that's fine from an APL application programmer's point of view.
A> 
A> The same holds true when you double-click a workspace but it is _not_ true when you _load_ a workspace: the current directory remains what it was before, and that's where the Dyalog EXE lives.
A> 
A> Therefore it's probably not a bad idea to change the current directory yourself _at the earliest possible stage_ after loading a workspace: call `#.FilesAndDirs.PolishCurrentDir` and your are done, no matter what the circumstances are. One of the authors is doing this for roughly 20 years now, and it has solved several problems without introducing new ones.

### The DYAPP file

Now we need to establish the `Make.dyapp` file:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
Load ..\AplTree\HandleError
Load ..\AplTree\IniFiles
Load ..\AplTree\OS
Load ..\AplTree\Logger
Load Constants
Load Utilities
Load MyApp
Run #.MyApp.SetLX ⍬

Load Make
Run #.Make.Run 1
~~~

The upper part (until the blank line) is identical with `MyApp.dyapp` except that we don't load the stuff that's only needed during development. We then load a script `Make` and finally we call `Make.Run`. That's how `Make` looks at this point:

~~~
:Class Make
⍝ Puts the application `MyApp` together:
⍝ 1. Remove folder `DESTINATION\` in the current directory
⍝ 2. Create folder `DESTINATION\` in the current directory
⍝ 3. Copy icon to `DESTINATION\`
⍝ 4. Copy the INI file template over to `DESTINATION`
⍝ 5. Creates `MyApp.exe` within `DESTINATION\`
    ⎕IO←1 ⋄ ⎕ML←1
    
    DESTINATION←'MyApp'
    
    ∇ {filename}←Run offFlag;rc;en;more;successFlag;F;U;msg
      :Access Public Shared
      F←##.FilesAndDirs ⋄ U←##.Utilities
      (rc en more)←F.RmDir DESTINATION
      U.Assert 0=rc
      successFlag←'Create!'F.CheckPath DESTINATION
      U.Assert successFlag
      (successFlag more)←2↑'images'F.CopyTree DESTINATION,'\images'
      U.Assert successFlag
      (rc more)←'MyApp.ini.template'F.CopyTo DESTINATION,'\MyApp.ini'
      U.Assert 0=rc
      Export'MyApp.exe'
      filename←DESTINATION,'\MyApp.exe'
      :If offFlag
          ⎕OFF
      :EndIf
      ∇
:EndClass
~~~

### Assertions

It is common practice in any programming language to inject checks into the code to make sure that specific conditions are fulfilled because if not the program cannot succeed anyway. If a condition is not fulfilled an error is thrown.

The function `Assert` does not exist yet in `Utilities`:

~~~
:Namespace Utilities
      map←{
          (,2)≢⍴⍺:'Left argument is not a two-element vector'⎕SIGNAL 5
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }      
leanpub-start-insert      
       Assert←{⍺←'' ⋄ (success errorNo)←2↑⍵,11 ⋄ (,1)≡,success:r←1 ⋄ ⍺ ⎕SIGNAL errorNo}
leanpub-end-insert      
:EndNamespace
~~~

Notes:

* The right argument of `Assert` must be one of:

  * A scalar or a vector of length 1. This is the `success` flag.

  * A vector of length two. 

   The second item is supposed to be an `errorNo`. It defaults to `11` (DOMAIN ERROR).

* The optional left argument must be, when specified, a character vector. This is used as message in case `⎕SIGNAL` is issued. This defaults to "DOMAIN ERROR".

* In case the right argument is any flavour of `1` (scalar, vector, matrix, ...) `Assert` returns a shy (!) result: `1`.

* In all other cases `Assert` will signal `errorNo` with the message specified in the left argument, if any.

Because it's a one-liner you cannot trace into `Assert`, and that's a good thing.

This is an easy way to make the calling function stop when something goes wrong. There is no point in doing anything but stopping the code from continuing since it is called by a programmer, and when it fails she wants to investigate straight away. 

And things can go wrong quite easily; for example, the attempt to remove `DESTINATION` may fail simply because somebody is looking into `DESTINATION` with the Windows Explorer.

First we create the folder `DESTINATION` from scratch and then we copy everything that's needed to the folder `DESTINATION`: the application icon and the INI file. Whether the function executes `⎕OFF` or not depends on the right argument `offFlag`. Why that is needed will become apparent soon.

### INI files

We don't copy `MyApp.ini` into `DESTINATION` but `MyApp.ini.template`; therefore we must create this file: copy `MyApp.ini` to `MyApp.ini.template` and then check its settings: in particular these settings are important:

~~~
...
[Config]
Debug       = ¯1   ; 0=enfore error trapping; 1=prevent error trapping;
Trap        = 1    ; 0 disables any :Trap statements (local traps)
ForceError  = 0    ; 1=let TxtToCsv crash (for testing global trap handling)
...
[Ride]
Active      = 0
...
~~~

Those might well get changed in `MyApp.ini` while working on the project, so we make sure that we get them set correctly in `MyApp.ini.template`.

However, that leaves us vulnerable to another problem: imagine we introduce a new section and/or a new key and forget to copy it over to the template. In order to avoid this we add a test case to `Tests`:

~~~
    ∇ R←Test_misc_01(stopFlag batchFlag);⎕TRAP;ini1;ini2
      ⍝ Check if MyApp.ini & MyApp.ini.template have same sections & keys
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
      ini1←⎕NEW ##.IniFiles(,⊂'MyApp.ini')
      ini2←⎕NEW ##.IniFiles(,⊂'MyApp.ini.template')
      →PassesIf ini1.GetSections{(∧/⍺∊⍵)∧(∧/⍵∊⍺)}ini2.GetSections
      →PassesIf(ini1.Get ⍬ ⍬)[;2]{(∧/⍺∊⍵)∧(∧/⍵∊⍺)}(ini2.Get ⍬ ⍬)[;2]
      R←∆OK
    ∇
~~~

The test simply checks whether the two INI files have the same sections and the same keys; that's sufficient to notify us in case we forgot something.


### Prerequisites


#### Bind types

For the "Bind" method we can specify different types. We add those to the `Constants` namespace but in a separate sub namespace:

~~~
:Namespace Constants
...
    :EndNamespace
leanpub-start-insert
    :Namespace BIND_TYPES
        ActiveXControl←'ActiveXControl'
        InProcessServer←'InProcessServer'
        Library←'Library'
        NativeExe←'NativeExe'
        OutOfProcessServer←'OutOfProcessServer'
        StandaloneNativeExe←'StandaloneNativeExe'
    :EndNamespace
leanpub-end-insert    
:EndNamespace
~~~

Why do we do this? After all it does not increase readability. But it does offer all available options, so it makes the code self-explaining.

#### Flags

~~~
:Namespace Constants
...
    :EndNamespace
leanpub-start-insert
    :Namespace BIND_FLAGS
        BOUND_CONSOLE←2
        BOUND_USEDOTNET←4
        RUNTIME←8
        BOUND_XPLOOK←32
    :EndNamespace
leanpub-end-insert    
:EndNamespace
~~~

### Exporting

`Run` then calls `Export`, a private function in the `Make` class that does not yet exist:

~~~
...
    ∇ {r}←{flags}Export exeName;type;flags;resource;icon;cmdline;try;max;success;details;fn
    ⍝ Attempts to export the application
      r←⍬
      flags←##.Constants.BIND_FLAGS.RUNTIME{⍺←0 ⋄ 0<⎕NC ⍵:⍎⍵ ⋄ ⍺}'flags'
      max←50
      type←##.Constants.BIND_TYPES.StandaloneNativeExe
      icon←F.NormalizePath DESTINATION,'\images\logo.ico'
      resource←cmdline←''
      details←''
      details,←⊂'CompanyName' 'My company'
      details,←⊂'ProductVersion'(2⊃##.MyApp.Version)
      details,←⊂'LegalCopyright' 'Dyalog Ltd 2018'
      details,←⊂'ProductName' 'MyApp'
      details,←⊂'FileVersion' '1.2.3.4'
      details←↑details
      success←try←0
      fn←DESTINATION,'\',exeName     ⍝ filename
      :Repeat
          :Trap 11
              2 ⎕NQ'.' 'Bind' fn type flags resource icon cmdline details
              success←1
          :Else
              ⎕DL 0.2
          :EndTrap
      :Until success∨max<try←try+1
      :If 0=success
          ⎕←'*** ERROR: Failed to export EXE to ',fn,' after ',(⍕try),' tries.'
          . ⍝ Deliberate error; allows investigation
      :EndIf
    ∇
:EndClass
~~~

`Export` automates what we've done so far by calling the "Export" command from the "File" menu. In case the "Bind" method fails it tries up to 50 times before giving up. 

This is because from experience we know that depending on the OS and the machine and God knows what else sometimes the command fails several times before it finally succeeds. 

A> # The "Bind" method
A>
A> Not that for the `Bind` method to work as discussed in this chapter you must use at least version 16.0.31811.0 of Dyalog. Before that `Bind` was not an official method and did not support the "Details".

Double-click `Make.dyapp`: a folder `MyApp` should appear in `Z:\code\v10` with, among other files, `MyApp.exe`.


### Check the result

Open a Windows Explorer (Windows key + "E"), navigate to the folder hosting the EXE, right-click on the EXE and select "Properties" from the context menu. Then click on the "Details" tab.

![EXEs properties](./Images/Stand-alone-properties.png "APL Team's dots")

As you can see, the fields "File version", "Product name", "Product version" and "Copyright" hold the information we have specified.

W> Note that the names we have used are not the names used by Microsoft in the GUI. The MSDN [^9] provides details.


## The tests

Now that we have a way to automatically assemble all the necessary files required by our application we need to amend our tests. Double-click `MyApp.dyapp`. You don't need to execute the test cases right now because we are going to change them.

We need to make a few changes:

~~~
:Namespace Tests
    ⎕IO←1 ⋄ ⎕ML←1
    ∇ Initial;list;rc
      U←##.Utilities ⋄ F←##.FilesAndDirs ⋄ A←##.APLTreeUtils
      ∆Path←F.GetTempPath,'\MyApp_Tests'      
      F.RmDir ∆Path
      'Create!'F.CheckPath ∆Path     
      list←⊃F.Dir'..\..\texts\en\*.txt'
      rc←list F.CopyTo ∆Path,'\'
      :If ~R←0∧.=⊃rc
          ⎕←'Could not create ',∆Path
      :EndIf
leanpub-start-insert      
      ⎕SE.UCMD'Load ',F.PWD,'\Make.dyalog -target=#'
      #.Make.Run 0      
leanpub-end-insert      
    ∇   
 ...
:EndNamespace      
~~~

Notes: `Initial` ...

* ... loads the script `Make.dyalog` into `#`.
* ... runs the function `Make.Run`. The `0` provided as right argument tells `Make.Run` to _not_ execute `⎕OFF`, something we would not appreciate at this stage.


## Workflow

With the two DYAPPs and the BAT file, your development cycle now looks like this:

1. Launch `MyApp.dyapp` and check the test results. 
2. Fix any errors and rerun `#.Tests.Run` until it's fine. If you edit the test themselves, either rerun 
   
   ~~~
   `#.Tester.EstablishHelpersIn #.Tests` 
   ~~~
   
   or simply close the session and relaunch `MyApp.dyapp`.
   
[^WCU]: Worst Case User, also known as Dumbest Assumable User (DAU).
[^9]: The [MSDN](https://msdn.microsoft.com/en-us/library/windows/desktop/aa381058(v=vs.85).aspx) provides more information on what names are actually recognized.


*[HTML]: Hyper Text Mark-up language
*[DYALOG]: File with the extension 'dyalog' holding APL code
*[TXT]: File with the extension 'txt' containing text
*[INI]: File with the extension 'ini' containing configuration data
*[DYAPP]: File with the extension 'dyapp' that contains 'Load' and 'Run' commands in order to put together an APL application
*[EXE]: Executable file with the extension 'exe'
*[BAT]: Executeabe file that contains batch commands
*[CSS]: File that contains layout definitions (Cascading Style Sheet)
*[MD]: File with the extension 'md' that contains markdown
*[CHM]: Executable file with the extension 'chm' that contains Windows Help(Compiled Help) 
*[DWS]: Dyalog workspace
*[WS]: Short for Workspaces
*[PF-key]: Programmable function key