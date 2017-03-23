{:: encoding="utf-8" /}

# Handling errors

`MyApp` already anticipates, tests for and reports certain foreseeable problems with the parameters. We'll now move on to handle errors more comprehensively.


## What are we missing? 

1. Other problems are foreseeable. The file system is a rich source of ephemeral problems and displays. Many of these are caught and handled by the APLTree utilities. They might make several attempts to read or write a file before giving up and signalling an error. Hooray. We need to handle the events signalled when the utilities give up. 

2. The MyApp EXE terminates with an all-OK zero exit code even when it has caught and handled an error. It would be a better Windows citizen if it returned custom exit codes, letting a calling program know how it terminated..

3. By definition, unforeseen problems haven't been foreseen. But we foresee there will be some! A mere typo in the code could break execution. We need a master trap to catch any events that would break execution, save them for analysis, and report them in an orderly way. 

We'll start with the second item from the list above: quitting and passing an exit code.

### Inspecting Windows exit codes

How do you see the exit code returned to Windows? You can access it in the command shell like this:

~~~
Z:\code\v05\MyApp.exe Z:\texts\en
 
echo Exit Code is %errorlevel%
Exit Code is 0

MyApp.exe Z:\texts\does_not_exist
 
echo Exit Code is %errorlevel%
Exit Code is 101
~~~

but only if you ticked the check box "Console application" in the "Export" dialog box. We don't want to do this if we can help it because we cannot Ride into an application with this option active. Therefore we are going to execute our stand-alone EXE from now on with the help of the APLTree class `Execute`.

Copy `Z:\code\06` to `Z:\code\07`.

For the implementation of global error handling we need APLTree's `HandleError` class. For calling the exported EXE we need the `Execute` class.

Edit `Z:\code\v07\MyApp.dyapp`:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
leanpub-start-insert
Load ..\AplTree\HandleError
Load ..\AplTree\Execute
leanpub-end-insert
Load ..\AplTree\Logger
Load Constants
Load Utilities
Load MyApp
Run MyApp.SetLX
~~~


## Foreseen errors

For those we check in the code and quit when something is wrong but pass an error code to the calling environment.

First we define in `#.MyApp` a child namespace of exit codes: 

~~~
    :Namespace EXIT
        OK←0
        INVALID_SOURCE←111
        SOURCE_NOT_FOUND←112
        UNABLE_TO_READ_SOURCE←113
        UNABLE_TO_WRITE_TARGET←114
          GetName←{
              l←' '~¨⍨↓⎕NL 2
              ind←({⍎¨l}l)⍳⍵
              ind⊃l,⊂'Unknown error'
          }
    :EndNamespace
~~~

We define an `OK` value of zero for completeness; we really _are_ trying to eliminate from our functions numerical constants that the reader has to interpret. In Windows, an exit code of zero is a normal exit. All the exit codes are defined in this namespace. The function code can refer to them by name, so the meaning is clear. And this is the _only_ definition of the exit-code values. 

We can convert the numeric value back to the symbolic name with the function `GetName`:

~~~
      EXIT.GetName EXIT.INVALID_SOURCE
INVALID_SOURCE      
~~~

This is useful when we want to log an error code: the name is telling while the number is meaningless.

I> We could have defined `EXIT` in `#.Constants`, but we reserve that script for Dyalog constants, keeping it as a component that could be used in other Dyalog applications. The exit codes defined in `EXIT` are specific to `MyApp`, so are better defined there. 

Now the result of `TxtToCsv` gets passed to `⎕OFF` to be returned to the operating system as an exit code. 

~~~
∇ StartFromCmdLine;exit;args;rc
 ⍝ Read command parameters, run the application      
  args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'
leanpub-start-insert
  rc←TxtToCsv 2⊃2↑args
  Off rc
leanpub-end-insert           
∇
~~~

Note that in this particular case we invent a local variable `rc` although strictly speaking this is not necessary. We learned from experience that you should not call several functions on a single line with the left-most being `Off`. If you do this anyway you will regret it one day, it's just a matter of time.

Now we have to introduce a function `Off`:

~~~    
∇ Off exitCode
  :If 0<⎕NC'MyLogger'
      :If exitCode=EXIT.OK
          MyLogger.Log'MyApp is closing down gracefully'
      :Else
          MyLogger.LogError'MyApp is closing down, rc = ',EXIT.GetName exitCode
      :EndIf
  :EndIf
  :If A.IsDevelopment
      →
  :Else
      ⎕OFF exitCode
  :EndIf
∇
~~~

Note that `⎕OFF` is actually only executed when the program detects a runtime environment, otherwise it just quits. Although the workspace is much less important these days you still don't want to loose it by accident.

We modify `GetFiles` so that it checks its arguments and the intermediary results:

~~~
leanpub-start-insert
∇ (rc target files)←GetFiles fullfilepath;csv;target;path;stem;isDir
⍝ Checks argument and returns liast of files (or single file).
leanpub-end-insert
   fullfilepath~←'"'
leanpub-start-insert   
   files←target←''
   :If 0∊⍴fullfilepath
       rc←EXIT.INVALID_SOURCE
       :Return
   :EndIf
leanpub-end-insert   
   csv←'.csv'
leanpub-start-insert   
   :If 0=F.Exists fullfilepath
       rc←EXIT.SOURCE_NOT_FOUND
   :ElseIf ~isDir←F.IsDir fullfilepath
   :AndIf ~F.IsFile fullfilepath
       rc←EXIT.INVALID_SOURCE
   :Else
       :If isDir
leanpub-end-insert       
           target←F.NormalizePath fullfilepath,'\total',csv
leanpub-start-insert           
           files←⊃F.Dir fullfilepath,'/*.txt'
       :Else
leanpub-end-insert       
           (path stem)←2↑⎕NPARTS fullfilepath
           target←path,stem,csv
           files←,⊂fullfilepath
leanpub-start-insert           
       :EndIf
leanpub-end-insert       
       target←(~0∊⍴files)/target
leanpub-start-insert       
       rc←(1+0∊⍴files)⊃EXIT.(OK SOURCE_NOT_FOUND)
leanpub-end-insert       
   :EndIf
∇
~~~

Note that we have replaced some constants by calls to functions in `FilesAndDirs`. You might find this easier to read.

In general, we like functions to _start at the top and exit at the bottom_. Returning from the middle of a function can lead to confusion, and we have learned a great respect for our capacity to get confused. However, here we don't mind exiting the function with `:Return` on line 5. It's obvious why that is and it saves us one level of nesting regarding the control structures. Also, there is no  tidying up at the end of the function that we would miss with `:Return`.

`ProcessFile` now traps some errors:

~~~
∇ data←(fns ProcessFiles)files;txt;file
 Reads all files and executes `fns` on the contents.
  data←⍬
  :For file :In files
leanpub-start-insert           
      :Trap Config.Trap/FileRelatedErrorCodes
leanpub-end-insert               
          txt←'flat'A.ReadUtf8File file
leanpub-start-insert  
      :Case
          MyLogger.LogError'Unable to read source: ',file
          Off EXIT.UNABLE_TO_READ_SOURCE
      :EndTrap
leanpub-end-insert               
      data,←⊂fns txt
  :EndFor
∇
~~~

In the line with the `:Trap` we call a niladic function (exception to the rule!) which returns all error codes that are related to problems with files:

~~~
∇ r←FileRelatedErrorCodes
⍝ Useful to trap all file (and directory) related errors.
  r←12 18 20 21 22 23 24 25 26 28 30 31 32 34 35
∇    
~~~

A> ### Why don't we just :Trap all errors?
A> 
A> `:Trap 0` would trap all errors - easier to read and write than `:Trap 12 18 20 21 22 23 24 25 26 28 30 31 32 34 35`, so why don't we do this?
A> 
A> Well, for a very good reason: trapping everything includes such basic things like a VALUE ERROR, which is most likely introduced by a typo or by removing a function or an operator in the false believe that it is not called anywhere. We don't want to trap those, really. The sooner they come to light the better. For that reason we restrict the errors to be trapped to whatever might pop up when it comes to dealing with files and directories.
A> 
A> That being said, if you really have to trap _all_ errors (occasionally this makes sense) then make sure that you can switch it off with a global flag as in `:Trap trap/0`: if `trap` is 1 then the trap is active, otherwise it is not.

In this context the `:Trap` structure has an advantage over `⎕TRAP`. When it fires, and control advances to its `:Else` fork, the trap is immediately cleared. So there is no need explicitly to reset the trap to avoid an open loop.  But be careful when you call other functions: in case they crash the `:Trap` would catch the error!

The handling of error codes and messages can easily obscure the rest of the logic. Clarity is not always easy to find, but is well worth working for. This is particularly true where there is no convenient test for an error, only a trap for when it is encountered. 

Note that here for the first time we take advantage of the `[Config]Trap` flag defined in the INI file, which translates to `Config.Trap` at this stage. With this flag we can switch off all "local" error trapping, sometimes a measure we need to take to get to the bottom of a problem.

Finally we need to amend `TxtToCsv`:

~~~
    ∇ exit←TxtToCsv fullfilepath;∆;isDev;Log;LogError;files;target
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text
leanpub-start-insert          
     ⍝ Returns one of the values defined in `EXIT`.     
leanpub-end-insert          
      MyLogger.Log'Started MyApp in ',F.PWD
      MyLogger.Log'Source: ',fullfilepath
leanpub-start-insert           
      (rc target files)←GetFiles fullfilepath
      :If rc=EXIT.OK
leanpub-end-insert                 
          :If 0∊⍴files
              MyLogger.Log'No files found to process'
leanpub-start-insert                         
              rc←EXIT.SOURCE_NOT_FOUND
leanpub-end-insert                         
          :Else
              tbl←⊃⍪/(CountLetters ProcessFiles)files
              lines←{⍺,',',⍕⍵}/{⍵[⍒⍵[;2];]}⊃{⍺(+/⍵)}⌸/↓[1]tbl
              :Trap Config.Trap/FileRelatedErrorCodes
                  A.WriteUtf8File target lines
              :Case
                  MyLogger.LogError'Writing to <',target,'> failed, rc=',(⍕⎕EN),'; ',⊃⎕DM
                  rc←EXIT.UNABLE_TO_WRITE_TARGET
                  :Return
              :EndTrap
              MyLogger.Log(⍕⍴files),' file',((1<⍴files)/'s'),' processed:'
              MyLogger.Log' ',↑files
leanpub-start-insert                                       
          :EndIf
leanpub-end-insert                                   
      :EndIf
    ∇
~~~

Note that the exit code is tested against `EXIT.OK`. Testing `0=exit` would work and read as well, but relies on `EXIT.OK` being 0. The point of defining the codes in `EXIT` is to make the functions relate to the exit codes only by their names.  

## Unforeseen errors

Our code so far covers the errors we foresee: errors in the parameters, and errors encountered in the file system. There remain the unforeseen errors, chief among them errors in our own code. If the code we have so far breaks, the EXE will try to report the problem to the session, find no session, and abort with an exit code of 4 to tell Windows "Sorry, it didn't work out."

If the error is replicable, we can easily track it down using the development interpreter. But the error might not be replicable. It could, for instance, have been produced by ephemeral congestion on a network interfering with file operations. Or the parameters for your app might be so complicated that it is hard to replicate the environment and data with confidence. What you really want for analysing the crash is a crash workspace, a snapshot of the ship before it went down. 

For this we need a high-level trap to catch any event not trapped by any `:Trap` statements. We want it to save the workspace for analysis. We might also want it to report the incident to the developer -- users don't always do this! For this we'll use the `HandleError` class from the APLTree.

Define a new `EXIT` code constant:

~~~
    ....
    OK←0
leanpub-start-insert
    APPLICATION_CRASHED←104
leanpub-end-insert
    INVALID_SOURCE←111
    ...
~~~

A> 104? Why not 4, the standard Windows code for a crashed application? The distinction is useful. An exit code of 104 will tell us  MyApp's trap caught and reported the crash. An exit code of 4 tells you even the trap failed!

We want to establish general error trapping as soon as possible, but we also need to know where to save crash files etc. That means we start right after having instantiated the INI file, because that's where we get this kind of information from. For establishing error trapping we need to set `⎕TRAP`. Because we want to make sure that any function down the stack can pass a certain error up to the next definition of `⎕TRAP` (see the `⎕TRAP` help options "C" and "N") it is vitally important not only set to set but also to _localyze_ `⎕TRAP` in `StartFromCmdLine`

~~~
leanpub-start-insert  
∇ {r}←StartFromCmdLine arg;MyLogger;Config;rc;⎕TRAP
leanpub-end-insert  
⍝ Needs command line parameters, runs the application.
   r←⍬
   (Config MyLogger)←Initial ⍬
leanpub-start-insert     
   ⎕WSID←'MyApp'
   ⎕TRAP←(Config.Debug=0) SetTrap Config
leanpub-end-insert     
   rc←TxtToCsv arg~''''
   Off rc
∇
~~~

We need to set `⎕WSID` because the global trap will attempt to save a workspace in case of a crash.
We set `⎕TRAP` by assigning the result of `SetTrap`, so we we need to create that function now:

~~~
∇ trap←{force}SetTrap Config
⍝ Returns a nested array that can be assigned to `⎕TRAP`.
  force←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'force'
  #.ErrorParms←##.HandleError.CreateParms
  #.ErrorParms.errorFolder←⊃Config.Get'Folders:Errors'
  #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED
  #.ErrorParms.logFunction←MyLogger.Log
  #.ErrorParms.windowsEventSource←'MyApp'
  #.ErrorParms.addToMsg←' --- Something went terribly wrong'
  trap←force ##.HandleError.SetTrap '#.ErrorParms' 
∇
~~~

Notes:

* First we generate a parameter space with default values by calling `HandleError.CreateParms`.
* We then overwrite some of the defaults:
  * Where to save crash information.
  * The return code.
  * What function to use for logging information.
  * Name of the source to be used when reporting the problem to the Windows Event Log (empty=no reporting at all).
  * Additonal message to be added to the report send to the Windows Event Log.
* We specify `ErrorParms` as a global named namespace for two reasons:
  * Any function might crash, and we need to "see" the namespace with the parameters needed in case of a crash, so it has to be a global in `#`.
  * The `⎕TRAP` statement allows us to call a function and to pass parameters but no references, so it has to be a named namespace.
 
 Let's investigate how this will work; trace into `#.MyApp.StartFromCmdLine ''`. When you reach line 4 `Config` exists, so now you can call `MyApp.SetTrap` with different left arguments:

~~~
      SetTrap Config
 0 1000 S
      0 SetTrap Config
 0 1000 S
      1 SetTrap Config
 0 E #.HandleError.Process '#.ErrorParms'  
      #.ErrorParms.∆List
 addToMsg                                                               
 checkErrorFolder                                                      1 
 createHTML                                                            1 
 customFns                                                              
 customFnsParent                                                        
 enforceOff                                                            0 
 errorFolder                     C:\Users\kai\AppData\Local\MyApp\Errors 
 logFunction                                                         Log 
 logFunctionParent   [Logger:C:\Users\...\MyApp_20170305.log(¯70419218)] 
 off                                                                   1 
 returnCode                                                          104 
 saveCrash                                                             1 
 saveErrorWS                                                           1 
 saveVars                                                              1 
 signal                                                                0 
 trapInternalErrors                                                    1 
 trapSaveWSID                                                          1 
 windowsEventSource                                                                              
~~~

### Test the global trap

We can test this: we could insert a line with a full stop[^stop] into, say, `CountLettersIn`. But that is awkward: we don't really want to change our source code in order to test error trapping. Therefore we invent an additional setting in the INI file:

~~~
[Config]
Debug       = ¯1    ; 0=enfore error trapping; 1=prevent error trapping;
Trap        = 1     ; 0 disables any :Trap statements (local traps)
leanpub-start-insert  
ForceError  = 1     ; 1=let TxtToCsv crash (for testing global trap handling)
leanpub-end-insert  
...
~~~

That requires two minor changes in `CreateConfig`:

~~~
∇ Config←CreateConfig dummy;myIni;iniFilename
...
leanpub-start-insert           
Config.ForceError←0
leanpub-end-insert           
      iniFilename←'expand'F.NormalizePath'MyApp.ini'
      :If F.Exists iniFilename
          myIni←⎕NEW ##.IniFiles(,⊂iniFilename)
leanpub-start-insert                     
          Config.ForceError←myIni.Get'Config:ForceError'  
leanpub-end-insert                     
~~~

We change `TxtToCsv` so that is crashes in case `Config.ForceError` equals 1:

~~~
∇ rc←TxtToCsv fullfilepath;files;tbl;lines;target
⍝ Write a sibling CSV of the TXT located at fullfilepath,
⍝ containing a frequency count of the letters in the file text.
⍝ Returns one of the values defined in `EXIT`.
   MyLogger.Log'Source: ',fullfilepath
   (rc target files)←GetFiles fullfilepath
leanpub-start-insert     
   {⍵:⍎'. ⍝ Deliberate error (INI flag "ForceError")'}Config.ForceError
leanpub-end-insert  
...   
~~~

The dfns `{⍵:.}` uses a guard to execute a full stop if `⍵` is true and do nothing at all otherwise. In order to test error trapping we don't even need to create and execute a new EXE; instead we just set `ForceError←1` and then call `#.MyApp.StartFromCmdLine` from within the WS:

~~~
      #.MyApp.StartFromCmdLine 'Z:\texts\ulysses.txt'
⍎SYNTAX ERROR
TxtToCsv[6] . ⍝ Deliberate error (INI flag "ForceError")
           ∧      
~~~

That's exactly what we want: error trapping should not interfere when we are developing.

To actually test error trapping we need to set the `Debug` flag in the INI file to 0. That will `MyApp` tell that we want error trapping to be active, no matter what environment we are in. Change the INI file accordingly and execute it again.

~~~
      )reset
      #.MyApp.StartFromCmdLine 'Z:\texts\ulysses.txt'
HandleError.Process caught SYNTAX ERROR      
~~~

Note that `HandleError` has not executed `⎕OFF` because we executed this in a development environment.

That's all we see in the session, but when you check the folder `#.ErrorParms.errorFolder` you will find that indeed there were three new files created in that folder for this crash. (Note that in case you traced through the code there would be just two files: the workspace is missing. The reason is that with the Tracer active the current workspace cannot be saved; same when an edit window is open for some reason or more than one thread is used)

Because we've defined a source for the Windows Event Log `HandleError` has reported the error accordingly:

![Windows Event Log](images\MyAppEventViewer.jpg)

We also find evidence in the log file that something broke; see LogDog:

![The log file](images\LogDog2.jpg)

This is done automatically by the `HandleError` class for us because we provided the name of a logging function and a ref pointing to the instance where that log function lives.

We also have an HTML with a crash report, an eponymous DWS containing the workspace saved at the time it broke, and an eponymous DCF whose single component is a namespace of a4ll the variables visible at the moment of the crash. Some of this has got to help. 

Note that the crash files names are simply the WSID plus the timestamp prefixed by an underscore:

~~~
      ⍪{⊃,/1↓⎕NPARTS⍵}¨⊃#.FilesAndDirs.Dir #.ErrorParms.errorFolder,'\'
 MyApp_20170307111141.dcf  
 MyApp_20170307111141.dws  
 MyApp_20170307111141.html 
~~~

Save your work and re-export the EXE.

## Crash files

What's _in_ those crash files?

The HTML contains a report of the crash and some key system variables:

~~~
MyApp_20170307111141

Version:   Windows-64 16.0 W Development
⎕WSID:	   MyApp
⎕IO:	   1
⎕ML:	   1
⎕WA:	   62722168
⎕TNUMS:	   0
Category:	
EM:	       SYNTAX ERROR
HelpURL:	
EN:	       2
ENX:	   0
InternalLocation:	parse.c 1739
Message:	
OSError:   0 0
Current Dir:	...code\v07
Command line:	"...\Dyalog\Dyalog APL-64 16.0 Unicode\dyalog.exe" DYAPP="...code\v07\MyApp.dyapp"
Stack:

#.HandleError.Process[22]
#.MyApp.TxtToCsv[6]
#.MyApp.StartFromCmdLine[6]
Error Message:

⍎SYNTAX ERROR
TxtToCsv[6] . ⍝ Deliberate error (INI flag "ForceError")
           ∧
~~~

More information is saved in a single component -- a namespace -- on the DCF.

~~~
      (#.ErrorParms.errorFolder,'/MyApp_20160513112024.dcf') ⎕FTIE 1
      ⎕FSIZE 1
1 2 7300 1.844674407E19
      q←⎕FREAD 1 1
      q.⎕NL ⍳10
AN              
Category        
CurrentDir      
DM              
EM              
EN              
ENX             
HelpURL         
InternalLocation
LC              
Message         
OSError         
TID             
TNUMS           
Trap            
Vars            
WA              
WSID            
XSI             
~~~

~~~
      q.Vars.⎕NL 2
ACCENTS     
args        
exit        
files       
fullfilepath
i           
isDev       
tbl         
tgt         
~~~

The DWS is the crash workspace. Load it. The Latent Expression has been disabled, to ensure `MyApp` does not attempt to start up again. 

~~~
      ⎕LX
⎕TRAP←0 'S' ⍝#.MyApp.StartFromCmdLine
~~~

The State Indicator shows the workspace captured at the moment the HandleError object saved the workspace. Your real problem -- the full stop in `MyApp.TxtToCsv` -- is some levels down in the stack. 

~~~
      )SI
#.HandleError.SaveErrorWorkspace[7]*
#.HandleError.Process[28]
#.MyApp.TxtToCsv[6]*
#.MyApp.StartFromCmdLine[6]
~~~

You can clear `HandleError` off the stack with a naked branch arrow. When you do so, you'll find the original global trap restored. Disable it. Otherwise any error you produce while running code will trigger `HandleError` again! 

~~~
      →
      )SI
#.MyApp.TxtToCsv[6]*
#.MyApp.StartFromCmdLine[6]
      ⎕TRAP
  0 E #.HandleError.Process '#.ErrorParms'  
      ⎕TRAP←0/⎕TRAP

~~~

We also want to check whether the correct return code is returned. For that we have to call the EXE, but we don't do this in a console window for reasons we have discussed earlier. Instead we use the `Execute` class which provides two main methods:

* `Process` allows use to catch a program's standard output.
* `Application` allows us to catch a program's exit code.

~~~
      ⎕←2⊃#.Execute.Application 'Myapp.exe '"Z:\texts\ulysses.txt"'
104
~~~
 
In development you'll discover and fix most errors while working from the APL session. Unforeseen errors encountered by the EXE will be much rarer. Now you're all set to investigate them! 

## About #.ErrorParms

We've established `#.ErrorParms` as a namespace, and we have explained why: `HandleError.Process` needs to see `ErrorParms` not matter the circumstances, otherwise it cannot work. Since we construct the workspace from scratch when we start developing it cannot do any harm because we quit as soon as the work is done.

Or can it? Let's check. First change the INI file so that it reads:

~~~
...
leanpub-end-insert
Trap        = 1    ; 0 disables any :Trap statements (local traps)
leanpub-start-insert
ForceError  = 0    ; 1=let TxtToCsv crash (for testing global trap handling)
leanpub-end-insert
...
~~~

Now double-click the DYAPP, call `#.MyApp.StartFromCmdLine ''` and then execute:

~~~
      ⎕nnames
C:\Users\kai\AppData\Local\MyApp\Log\MyApp_20170309.log
~~~

The log file is still open! Now that's what we expect to see as long as `MyLogger` lives, but that is kept local in `#.MyApp.StartFromCmdLine`, so why is this? The culprit is `ErrorParms`! In order to allow `HandleError` to write to our log file we've provided not only the name of the log file but also a reference pointing to the instance the log function is living in:

~~~
      #.ErrorParms.logFunctionParent
[Logger:C:\Users\kai\AppData\Local\MyApp\Log/MyApp_20170309.log(¯76546889)]      
~~~

In short: we have indeed a good reason to get rid of `ErrorParms` once the program has finished. But how? `⎕SHADOW` to the rescue! With `⎕SHADOW` we can declare a variable to be local from within a function. Mainly useful for localyzing names that are constructed in one way or another we can use it to make `ErrorParms` local within `StartFromCmdLine`. For that we add a single line:

~~~
∇ {r}←StartFromCmdLine arg;MyLogger;Config;rc;⎕TRAP
⍝ Needs command line parameters, runs the application.
  r←⍬
leanpub-start-insert  
  #.⎕SHADOW'ErrorParms'
leanpub-end-insert  
  ⎕WSID←'MyApp'
....
~~~

Note that we've put `#.` in front of `⎕SHADOW`; that is effectlively the same as having a header `StartFromCmdLine;#.ErrorParms` only that this is syntactically impossible to do. With `#.⎕SHADOW` it works. When you now try again a double-click on the DYAPP and then call `#.MyApp.StartFromCmdLine` you will find that no file is tied any more, and that `#.ErrorParms` is not hanging around either.


## Very early errors

At the moment there is a possibility that `MyApp` will crash and the global trap is not catching it. This is because we establish the global trap only after having instantiated the INI file: only then do we know where to write the crash files, how to log the error etc. But an error may well occur before that!

Naturally there is no perfect solution available here but we can at least try to catch such errors. For this we establish a `⎕TRAP` with default settings very early, and we make sure that `⎕WSID` is set even earlier, otherwise any attempt to save the crash WS will fail.

~~~
∇ {r}←StartFromCmdLine arg;MyLogger;Config;rc;⎕TRAP
⍝ Needs command line parameters, runs the application.
  r←⍬
leanpub-start-insert    
  ⎕WSID←'MyApp'
  ⎕TRAP←1 #.HandleError.SetTrap ⍬
  .
leanpub-end-insert    
  #.⎕SHADOW'ErrorParms'
  ....
~~~

Note that we use the `SetTrap` function `HandleError` comes with. It accepts a parameter space as right argument, but it also accepts an empty vector. In the latter case it falls back to the defaults.

For testing purposes we have provided a `1` as left argument, which enforces error trapping even in a development environment. In the following line we break the program with a full stop.

When you now call `#.MyApp.StartFromCmdLine ''` then the error is caught. Of course no logging will take place but it will still try to save the crash files. Since no better place is known it will try to create a folder `MyApp\Errors` in `%LOCALAPPDATA%`.

You can try this now but make sure that when you are ready you remove the line with the full stop from `MyApp.StartFromCmdLine` and also remove the `1` provided as left argument to `HandleError.SetTrap`.


## HandleError in detail

`HandleError` can be configured in many ways by changing the defaults provided by the `CreateParms` method. There is a table with documentation available; execute `]ADOC_Browse #.HandleError` and then scroll to `CreateParms`. Most of the parameters are self-explaining but some need background information.

~~~
      #.HandleError.CreateParms.∆List
 addToMsg                    
 checkErrorFolder          1 
 createHTML                1 
 customFns                   
 customFnsParent             
 enforceOff                0 
 errorFolder         Errors/ 
 logFunction                 
 logFunctionParent           
 off                       1 
 returnCode                1 
 saveCrash                 1 
 saveErrorWS               1 
 saveVars                  1 
 signal                    0 
 trapInternalErrors        1 
 trapSaveWSID              1 
 windowsEventSource          
 ~~~

`signal`
: By default `HandleError` executes `⎕OFF` in a runtime environment. That's not always the best way to deal with an error. In a complex application it might be the case that just one command fails, but the rest of the application is doing fine. In that case we would be better off by setting `off` to 0 and signal an numeric code that can be caught by yet another `⎕TRAP` that simply allows the user to explore other commands in the application.
 
`trapInternalErrors`
: This flag allows you to switch off any error trapping _within_ `HandleError`. This can be useful in case something goes wrong. It's can be useful when working on or debugging `HandleError` itself.
 
`saveCrash`, `saveErrorWS` and `saveVars`
: While `saveCrash` and `saveVars` are probably always 1 setting `saveErrorWS` to 0 is perfectly reasonable in case you know upfront that any attempt to save the error WS will fail, for example because your application is multi-threaded.

`customFns` and `customFnsParent`
: This allows you to make sure that `HandleError` will call a function of your choice. For example, you can use this to send an email or a text to a certain address.

[^stop]: The English poets among us love that the tersest way to bring a function to a full stop is to type one. (American poets will of course have typed a period and will think of it as calling time out.)