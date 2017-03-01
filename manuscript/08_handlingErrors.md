{:: encoding="utf-8" /}

Handling errors
===============

`MyApp` already anticipates, tests for and reports certain foreseeable problems with the parameters. We'll now move on to handle errors more comprehensively.

Copy `Z:\code\05` to `Z:\code\06`.


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

but only if you ticked the check box "Console application" in the "Export" dialog box.

## Foreseen errors

For those we check in the code and quit when something is wrong but pass an error code to the calling environment..

First we define in `#.MyApp` a child namespace of exit codes: 

~~~
    :Namespace EXIT
        OK←0
        INVALID_SOURCE←101
        SOURCE_NOT_FOUND←102
        UNABLE_TO_READ_SOURCE←103
        UNABLE_TO_WRITE_TARGET←104
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
∇ StartFromCmdLine;exit;args
 ⍝ Read command parameters, run the application      
  args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'
leanpub-start-insert
  ⎕WSID←'MyApp'
  Off TxtToCsv 2⊃2↑args
leanpub-end-insert           
∇
~~~

That means we have to introduce a function `Off`:

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

Note that `⎕OFF` is actually only executed when the program detects a runtime environment, otherwise it just quits. Also the WS is much less important these days you still don't want to loose it by accident.

We modify `GetFiles` so that it checks its arguments and the intermediary results:

~~~
∇ (rc target files)←GetFiles fullfilepath;csv;target;path;stem;isDir
⍝ Checks argument and returns liast of files (or single file).
   fullfilepath~←'"'
   :If 0∊⍴fullfilepath
       rc←EXIT.INVALID_SOURCE
       :Return
   :EndIf
   files←target←''
   csv←'.csv'
   :If 0=F.Exists fullfilepath
       rc←EXIT.SOURCE_NOT_FOUND
   :ElseIf ~isDir←F.IsDir fullfilepath
   :AndIf ~F.IsFile fullfilepath
       rc←EXIT.INVALID_SOURCE
   :Else
       :If isDir
           target←F.NormalizePath fullfilepath,'\total',csv
           files←⊃F.Dir fullfilepath,'/*.txt'
       :Else
           (path stem)←2↑⎕NPARTS fullfilepath
           target←path,stem,csv
           files←,⊂fullfilepath
       :EndIf
       target←(~0∊⍴files)/target
       rc←(1+0∊⍴files)⊃EXIT.(OK SOURCE_NOT_FOUND)
   :EndIf
∇
~~~

Note that we have replaced some constants by calls to functions in `FilesAndDirs`. You might find this easier to read.

In general, we like functions to _start at the top and exit at the bottom_. Returning from the middle of a function can lead to confusion, and we have learned a great respect for our capacity to get confused. However, here we don't mind exiting the function with `:Return` on line 5. It's obvious why that is and it saves us one level of nesting regarding the control structures. Also, there is no  tidying up at the end of the function that we would miss with `:Return`.

A> ### Restartable functions
A> 
A> Note only do we try to exit functions at the bottom, we also like them to be "restartable". What we mean by that is that we want a function -- and its variables -- to survive `→1`. This is not always possible, for example when a function starts a thread and must not start a second one for the same task, or a file was tied etc. but most of the time it is possible to achieve that. That means that something like this must be avoided:
A>
A>~~~
A> ∇r←MyFns arg
A> r←⍬
A> :Repeat
A>     r,← DoSomethingSensible ⊃arg
A> :Until 0∊⍴arg←1↓arg
A>~~~
A> 
A> This function does not make much sense but the point is that the right argument is mutilated; one cannot restart this function with `→1`. Don't do something like that!

`ProcessFile` now traps some errors:

~~~
∇ data←(fns ProcessFiles)files;txt;file
 Reads all files and executes `fns` on the contents.
  data←⍬
  :For file :In files
leanpub-start-insert           
      :Trap G.Trap/FileRelatedErrorCodes
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
    
∇ r←FileRelatedErrorCodes
⍝ Useful to trap all file (and directory) related errors.
  r←12 18 20 21 22 23 24 25 26 28 30 31 32 34 35
∇    
~~~

A> ### Why don't we just :Trap all errors?
A> 
A> `:Trap 0` would trap all errors - easier to read and write than `:Trap 12 18 20 21 22 23 24 25 26 28 30 31 32 34 35`, so why don't we do this?
A> 
A> Well, for a very good reason: trapping everything includes such basic things like a VALUE ERROR, which is most likely introduced by a typo or by removing a function or an operator in the false believe that it is not called anywhere. We don't want to trap those, really. The sooner they come to light the better. For that reason we restrict the errors to whatever might pop up when it comes to dealing with files and directories.
A> 
A> That being said, if you have to trap all errors (occasionally this makes sense) then make sure that you can switch it off with a global flag as in `:Trap ∆debug/0`: if `∆debug` is 1 then the trap is active, otherwise it is not.

In this context the `:Trap` structure has an advantage over `⎕TRAP`. When it fires, and control advances to its `:Else` fork, the trap is immediately cleared. So there is no need explicitly to reset the trap to avoid an open loop. 

The handling of error codes and messages can easily obscure the rest of the logic. Clarity is not always easy to find, but is well worth working for. This is particularly true where there is no convenient test for an error, only a trap for when it is encountered. 

Note that here we take advantage of the `[Config]Trap` flag -- which translates to `G.Trap` at this stage -- defined in the INI file for the first time. With this flag we can switch off all error trapping, sometimes a measure we need to take to get to the bottom of a problem.

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
              :Trap G.Trap/FileRelatedErrorCodes
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

It's time to create a stand-alone EXE and call that EXE...

* without any argument
* with a filename that does not exist
* with the name of an existing file
* witht the name of a directory that exists and contains some proper TXT files

to make sure that everything work fine and, if that's not the case, fix those problems before we carry on.


## Unforeseen errors

Our code so far covers the errors we foresee: errors in the parameters, and errors encountered in the file system. There remain the unforeseen errors, chief among them errors in our own code. If the code we have so far breaks, the EXE will try to report the problem to the session, find no session, and abort with an exit code of 4 to tell Windows "Sorry, it didn't work out."

If the error is replicable, we can easily track it down using the development interpreter. But the error might not be replicable. It could, for instance, have been produced by ephemeral congestion on a network interfering with file operations. Or the parameters for your app might be so complicated that it is hard to replicate the environment and data with confidence. What you really want for analysing the crash is a crash workspace, a snapshot of the ship before it went down. 

For this we need a high-level trap to catch any event not trapped by any `:Trap` statements. We want it to save the workspace for analysis. We might also want it to report the incident to the developer -- users don't always do this! For this we'll use the `HandleError` class from the APLTree.


Copy `Z:\code\06` to `Z:\code\07`.

Edit `Z:\code\v06\MyApp.dyapp`:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
leanpub-start-insert
Load ..\AplTree\HandleError
leanpub-end-insert
Load ..\AplTree\Logger
Load Constants
Load Utilities
Load MyApp
Run MyApp.SetLX
~~~

Define a new EXIT code constant:

~~~
    ....
    OK←0
leanpub-start-insert
    APPLICATION_CRASHED←104
leanpub-end-insert
    INVALID_SOURCE←101
    ...
~~~

A> 104? Why not 4, the standard Windows code for a crashed application? The distinction is useful. An exit code of 100 will tell us  MyApp's trap caught and reported the crash. An exit code of 4 tells you even the trap failed!

We want to establish general error trapping as soon as possible, but we also need to know where to save crash files etc. That means we start right after having instatiated the INI file, because that's where we define these pieces of information:






⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹

We want the high-level trap only when we're running headless, so we'll start as soon as `StartFromCmdLine` begins. For that we need a `⎕TRAP` statement. Because we want to make sure that any function down the stack can pass a certain error up to the next definition of `⎕TRAP` it is vitally important to _localyze_ `⎕TRAP` in `StartFromCmdLine`

~~~
    ∇ {r}←StartFromCmdLine arg;⎕TRAP
    ...
~~~

We will set `⎕TRAP` by assigning the result of `HandleError.SetTrap`. The most simple example:

~~~
      #.HandleError.SetTrap ⍬
0 1000 S      
~~~

But that's not trapping anything! Yes, and that's because we are currently in a development version of Dyalog APL. `SetTrap` assumes that you don't want error trapping to be active while developing, and that's a very reasonable assumption.

However, we can tell `SetTrap` that we want error trapping anyway by passing a `1` as left argument ("force" flag). Then `SetTrap` returns what it would return in a runtime environment, be it a runtime EXE, a runtime DLL or a stand-alone EXE:

~~~
      1 #.HandleError.SetTrap ⍬
 0 E #.HandleError.Process ⍬  
~~~
Note that the right argument of `HandleError.SetTrap` is passed as right argument to `HandleError.Process`. Instead we could provide a parameter space here defining all sorts of things, and we will soon do this. However, this reqieres that the application has collected a certain amount of information about itself by reading from the Windows Registry, a config or INI file, you name it. At the moment we don't have such information at our disposal, therefore we pass `⍬` as right argument. That just means that in case of an error `HandleError.Process` will take the defaults; that's the best we can do right now.

~~~
    ∇ StartFromCmdLine;exit;args;⎕TRAP
     ⍝ Read command parameters, run the application
      ⎕TRAP←#.HandleError.SetTrap ⍬
      args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'
      Off TxtToCsv 2⊃2↑args
    ∇
~~~

Note that `⎕TRAP` is kept local in `StartFromCmdLine`. This trap will do to get things started and catch anything that falls over immediately. We need to get more specific now in `TxtToCsv`. Before getting to work with `CheckAgenda`, refine the global trap definition:

~~~
        ...
      LogError←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
      
leanpub-start-insert     
      isDev←#.A.IsDevelopment
      ⍝ refine trap definition
      #.ErrorParms←H.CreateParms
      #.ErrorParms.errorFolder←F.PWD
      #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED
      #.ErrorParms.(logFunctionParent logFunction)←Log'Log'
      #.ErrorParms.trapInternalErrors←~isDev
      :If isDev
          ⎕TRAP←0⍴⎕TRAP
      :Else
          ⎕TRAP←0 'E' '#.HandleError.Process ''#.ErrorParms'''
      :EndIf
leanpub-end-insert

      :If EXIT.OK=⊃(exit files)←CheckAgenda fullfilepath
        ...
~~~

`CheckAgenda` and `CountLettersIn` are as before. 

The test for `isDev` determines whether (true) the application is allowed to suspend, or (false) errors are to be caught and handled. Later we will set this in an INI file. For now we set it by testing whether the interpreter is development or runtime. 

`#.ErrorParms.errorFolder` -- write crash files as siblings of the EXE. 

`#.ErrorParms.(logFunctionParent logFunction)` -- we set a ref to the `Logger` instance, so `HandleError` can write on the log.


### Test the global trap

We can test this! Put a full stop[^stop] in the first few lines of `CountLettersIn`. 

~~~
      tbl←0 2⍴'A' 0
      exit←EXIT.OK ⋄ i←1 
leanpub-start-insert
      . ⍝ DEBUG
leanpub-end-insert
~~~

This will definitely break. It is not caught by any of the other traps. 

Save the change. In the session, run 

~~~
`#.MyApp.TxtToCsv 'Z:\texts\en'`
~~~

See that `CountLettersIn` suspends on the new line. This is just as you want it. The global trap does not interfere with your development work. 

Now export the workspace to `Z:\code\v03\myapp.exe` and run it from the DOS command shell in `Z:\code\v03`:

~~~
Z:\code\v03>myapp.exe Z:\texts\en

Z:\code\v03>echo Exit Code was %errorcode%
Exit Code was 100
~~~

and what do we get?

Predictably we get no new result CSV. In `Z:\code\v03\Logs`, we find in the LOG a record of what happened. 

First, the log entry records the crash then breaks off:

~~~
2016-05-13 10:56:28 *** Log File opened
2016-05-13 10:56:28 (0) Started MyApp in Z:\code\v03
2016-05-13 10:56:28 (0) Source: Z:\texts\en
2016-05-13 10:56:28 (0) Target: Z:\texts\en.CSV
2016-05-13 10:56:28 (0) *** Error
2016-05-13 10:56:28 (0) Error number=2
2016-05-13 10:56:28 (0) SYNTAX ERROR
2016-05-13 10:56:28 (0) CountLettersIn[4] . ⍝ DEBUG
2016-05-13 10:56:28 (0)                  ∧
~~~

We also have an HTM with a crash report, an eponymous DWS containing the workspace saved at the time it broke, and an eponymous DCF whose single component is a namespace of all the variables defined in the workspace. Some of this has got to help. 

However, the crash files names are simply the timestamp prefixed by an underscore:

~~~
Z:/code/v03/_20160513105628.dcf 
Z:/code/v03/_20160513105628.dws 
Z:/code/v03/_20160513105628.html
~~~

We can improve this by setting the Workspace Identification at launch time. 

~~~
    ∇ StartFromCmdLine;exit;args
     ⍝ Read command parameters, run the application
      ⍝ trap unforeseen problems 
      ⎕TRAP←0 'E' '#.HandleError.Process '''''
leanpub-start-insert
      ⎕WSID←'MyApp'
leanpub-end-insert
      args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'
      exit←TxtToCsv 2⊃2↑args
      ⎕OFF exit
    ∇
~~~

Export the EXE again and run 

~~~
Z:\code\v03>MyApp.exe Z:\texts\en
~~~

Now your crash files will have better names:

~~~
Z:/code/v03/MyApp_20160513112024.dcf    
Z:/code/v03/MyApp_20160513112024.dws    
Z:/code/v03/MyApp_20160513112024.html   
~~~

Remove the deliberate error from `#.MyApp`, save your work and re-export the EXE.


## Crash files

What's _in_ those crash files?

The HTML contains a report of the crash and some key system variables:

~~~
MyApp_20160513112024

Version:            Windows 15.0.27377.0 W Runtime
⎕WSID:
⎕IO:                1
⎕ML:                1
⎕WA:                16408308
⎕TNUMS:             0
Category:
EM:                 SYNTAX ERROR
HelpURL:
EN:                 2
ENX:                0
InternalLocation:   parse.c 1722
Message:
OSError:            0 0
Current Dir:        Z:\code\v03
Stack:

#.HandleError.Process[17]
#.MyApp.CountLettersIn[4]
#.MyApp.TxtToCsv[30]
#.MyApp.StartFromCmdLine[5]
Error Message:

SYNTAX ERROR
CountLettersIn[4] . ⍝ DEBUG
                 ∧
~~~

More information is saved in a single component -- a namespace -- on the DCF.

~~~
      'Z:/code/v03/MyApp_20160513112024.dcf' ⎕FTIE 1
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

The DWS is the crash workspace. Load it. The Latent Expression has been disabled, to ensure MyApp does not attempt to start up again. 

~~~
      ⎕LX
⎕TRAP←0 'S' ⍝#.MyApp.StartFromCmdLine
~~~

The State Indicator shows the workspace captured at the moment the HandleError object saved the workspace. Your problem -- the full stop in `MyApp.CountLettersIn` -- is two levels down in the stack. 

~~~
      )SI
#.HandleError.SaveErrorWorkspace[6]*
#.HandleError.Process[23]
#.MyApp.CountLettersIn[4]*
#.MyApp.TxtToCsv[30]
#.MyApp.StartFromCmdLine[5]
~~~

You can clear `HandleError` off the stack with a naked branch arrow. When you do so, you'll find the original global trap restored. Disable it. Otherwise any error you produce while investigating will trigger `HandleError` again! 

~~~
      →
      )SI
#.MyApp.CountLettersIn[4]*
#.MyApp.TxtToCsv[30]
#.MyApp.StartFromCmdLine[5]
      ⎕TRAP
  0 E #.HandleError.Process '#.ErrorParms'  
      ⎕←⎕TRAP←0/⎕TRAP

~~~
 
In development you'll discover and fix most errors while working from the APL session. Unforeseen errors encountered by the EXE will be much rarer. Now you're all set to investigate them! 


[^stop]: The English poets among us love that the tersest way to bring a function to a full stop is to type one. (American poets will of course have typed a period and will think of it as calling time out.)