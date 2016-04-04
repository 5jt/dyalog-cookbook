Handling errors
===============

Our app now anticipates, tests for and reports certain foreseeable problems with the parameters. We'll now handle errors more comprehensively.


What are we missing? 
--------------------

1. Other problems are foreseeable. The file system is a rich source of ephemeral problems and displays. Many of these are caught and handled by the APLTree utilities. They might make several attempts to read or write a file before giving up and signalling an error. Hooray. We need to handle the events signalled when the utilities give up. 

2. The MyApp EXE terminates with an all-OK zero exit code even when it has caught and handled an error. Some custom exit codes would make it a better Windows citizen.

3. By definition, unforeseeable problems can't be foreseen. But we foresee there will be some! A mere typo in the code could break execution. We need a master trap to catch any events that would break execution, save them for analysis, and report them in an orderly way. 


Foreseen errors
------------------

We'll start with the first two. Quite a bit of restructuring here. We'll get `Compile` to return an exit code to be used by `⎕OFF`. So we'll begin by defining in the `MyApp` namespace a reference namespace of constants and their exit codes.  

~~~~~~~~
:Namespace MyApp
    ⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3
    (A L W)←#.(APLTreeUtils Logger WinFile) ⍝ aliases for all

leanpub-start-insert
   ⍝ define Exit Code constants
    EXIT←⎕NS''
    EXIT.OK←0
    EXIT.INVALID_SOURCE_FOLDER←101
    EXIT.INVALID_TARGET_FOLDER←102
    EXIT.UNABLE_TO_READ_MANIFEST←103
    EXIT.NO_FILES_FOUND←104
    EXIT.UNABLE_TO_READ_SOURCE←105
    EXIT.UNABLE_TO_WRITE_TO_TARGET←106
leanpub-end-insert
~~~~~~~~

Note that we define an `OK` value of zero for completeness. All the exit codes are defined here. The function code can refer to them by name, so the meaning is clear. And this is the only definition of the exit-code values. 
  
~~~~~~~~
    ∇ StartFromCmdLine
    ⍝ Initialise environment, read command parameters, and run the application
      W.PolishCurrentDir ⍝ set current dir to that of EXE
      ⎕OFF Compile 1↓3↑(⌷2 ⎕NQ'.' 'getcommandlineargs'),'' ''
    ∇
~~~~~~~~

No change here. 

`Compile` still starts and stops the logging, but it now calls `CheckAgenda` to examine the agenda (things to be done) and `CompileFiles` to do them. 

~~~~~~~~
    ∇ exit←Compile(srcfolder tgtfile);∆;Log;Error;files
     ⍝ Dyalog Cookbook compiler
     ⍝ Compile files from srcfolder to tgtfile
      'CREATE!'W.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←L.CreatePropertySpace
      ∆.path←'Logs\' ⍝ subfolder of current directory
      ∆.encoding←'UTF8'
      ∆.filenamePrefix←'MyApp'
      ∆.refToUtils←#
      Log←⎕NEW L(,⊂∆)
      Log.Log'Started MyApp in ',∆.path
      Log.Log'Source: ' 'Target: ',¨srcfolder tgtfile

leanpub-start-insert     
      Error←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
     
      :If 0=⊃(exit files)←CheckAgenda srcfolder tgtfile
          exit←CompileFiles files tgtfile
      :EndIf
leanpub-end-insert     
     
      Log.Log'All done'
      Log.Close
    ∇
~~~~~~~~

**Some comments**

* `Error`: this direct function aids clarity by avoiding some repetition in `CheckAgenda` and `CompileFiles`, where one would otherwise write perhaps:
~~~~~~~~
    exit←EXIT.INVALID_SOURCE_FOLDER
    Log.LogError exit 'INVALID_SOURCE_FOLDER'
~~~~~~~~

`Compile` now uses `CheckAgenda` to confirm it has work to do.

~~~~~~~~
    ∇ r←CheckAgenda(srcfolder tgtfile);∆;_srcfolder;orbust;manifest;files;srcfile;exit;n
      ⍝ Validate and set up agenda
      ⍝ r: errorcode filelist
      ⍝ errorcode: (int) see EXIT
      ⍝ filelist: (strs) full filepaths
      _srcfolder←{⍵,(~'\/'∊⍨⊃⌽⍵)/'\'}srcfolder
leanpub-start-insert
      orbust←{11::0 ⋄ ⍺⍺ ⍵} ⍝ return 0 if test breaks
leanpub-end-insert
      exit←EXIT.OK ⋄ files←'' ⍝ default values
     
      :If ~W.DoesExistDir orbust _srcfolder
          exit←Error'INVALID_SOURCE_FOLDER'
      :ElseIf ~W.DoesExistDir orbust W.Parent tgtfile
          exit←Error'INVALID_TARGET_FOLDER'
      :Else
          manifest←_srcfolder,'MANIFEST.DAT'
          :If W.DoesExistFile orbust manifest
              :Trap 0
                  files←A.ReadUtf8File manifest
                  Log.Log(⍕≢files),' files specified in manifest'
              :Else
                  exit←Error'UNABLE_TO_READ_MANIFEST'
              :EndTrap
          :Else
              files←W.Dir _srcfolder,'*.TXT'
          :EndIf
     
          :If exit=EXIT.OK ⍝ let's see what we got...
              files,⍨¨←⊂_srcfolder ⍝ full filepaths
              files/⍨←W.DoesExistFile files
              :If ×n←≢files
                  Log.Log(⍕n),' file',('s'/⍨n>1),' found in folder'
              :Else
                  exit←Error'NO_FILES_FOUND'
              :EndIf
          :EndIf
     
      :EndIf
     
      r←exit files
    ∇
~~~~~~~~

**Some comments**

* Testing and logging the parameters has swollen this part of the code to where we're pleased to have it in its own function. It also defines files and is the last code to read `srcfolder`, so this is a good functional encapsulation.
* `_srcfolder`: suffixing a folder path with `\` is so common we might define a `suffix` function to do it. But the definition is barely twice the length of the name we would give it!
* The `⍺⍺` in `orbust` marks it as an operator, modifying how a function works. `⍺⍺` refers to the function. The error guard `0::0` means in the event of any error return 0 (false). For example, `W.DoesExistDir` signals 11 (domain error) if its argument contains a wildcard. Moderated by `orbust`, it returns 0. 
* `files,⍨¨←⊂_srcfolder` combines the _commute_ and _each_ operators with assignment through a function to prefix each filename with `_srcfolder`. Assignment through a function elides the left argument of a dyadic function, so `file,←_srcfolder` is equivalent to `file←file,_srcfolder`. But we want to prefix `file` with `_srcfolder`, not suffix it. So we use _commute_ to switch the arguments of _catenate_: `file,⍨←_srcfolder`, equivalent to `file←_srcfolder,file`. Finally, we want to prefix every file in `files` so the assignment is done through `,⍨¨` and the right argument enclosed. Similarly `files/⍨←` compresses `files` with a Boolean vector.     
* Note the exit code is tested `exit=EXIT.OK`. Testing `~×exit` would work and read as well, but relies on EXIT.OK being 0. The point of defining the codes in `EXIT` was to make the functions relate to the exit codes only by their names.  
* In general, we like functions to start at the top and exit at the bottom. The best form is a cascade of tests:

~~~~~~~~
:If    ~ok←test1 ⋄ emsg←'Failed test 1'
:ElseIf~ok←test2 ⋄ emsg←'Failed test 2'
:ElseIf~ok←test3 ⋄ emsg←'Failed test 3'
:Else
	(ok emsg)←DoAllThe Work
:EndIf
r←ok emsg
~~~~~~~~~
	 
The handling of error codes and messages can easily obscure the rest of the logic. Clarity is not always easy to find, but is well worth working for. This is particularly true where there is no convenient test for an error, only a trap for when it is encountered. 

In such cases, it is tempting to use a `:Return` statement to abort the function. It can be confusing when a function 'aborts' in the middle. We have learned a great respect for our capacity to get confused. Aborting from the middle of a function may also skip essential tidying up at the end.  

We meet the same issue in `CompileFiles`, where we trap errors and abort within a loop. Note how the use of repeat/until allows -- unlike a for loop -- to test at the bottom of the loop both the counter and the exit code.

~~~~~~~~
    ∇ exit←CompileFiles(srcfiles tgtfile);srcfile;txt;i
    ⍝ Copy srcfiles to tgtfile
    ⍝ exit: (int) see EXIT
    ⍝ srcfiles: (strs) full filepaths
    ⍝ tgtfile: (str) full filepath of target file
      W.Delete tgtfile
      (exit i)←EXIT.OK ⎕IO
      :Repeat
          srcfile←i⊃srcfiles
          :Trap 0
              txt←'flat'A.ReadUtf8File srcfile
          :Else
              exit←Error'UNABLE_TO_READ_SOURCE'
          :EndTrap
          :If exit=EXIT.OK
              Log.Log'Read ',(⍕≢txt),' bytes from ',srcfile
              :Trap 0
                  'append'A.WriteUtf8File tgtfile txt
              :Else
                  exit←Error'UNABLE_TO_WRITE_TO_TARGETFILE'
              :EndTrap
          :EndIf
          i+←1
      :Until i>≢srcfiles
      :OrIf exit≠EXIT.OK
    ∇
~~~~~~~~
	 
**Some comments**

* `:Trap 0`: trap any error 


Unforeseen errors
-----------------

Our code so far covers the errors we foresee: errors in the parameters, and errors encountered in the file system. There remain the unforeseen errors, chief among them errors in our own code. If the code we have so far breaks, the EXE will try to report the problem to the session, find no session, and abort with an exit code of 4 to tell Windows "Sorry, it didn't work out."

If the error is easily replicable, we can easily track it down using the development interpreter. But the error might not be easily replicable. It could, for instance, have been produced by ephemeral congestion on a network interfering with file operations. Or the parameters for your app might be so complicated that it is hard to replicate the environment and data with confidence. What you really want for analysing the crash is a crash workspace, a picture of the ship before it went down. 

For this we need a high-level trap to catch any event not trapped by `Compile`. We want it to save the workspace for analysis. We might also want it to report the incident to the developer: users don't always do this. For this we'll use the `HandleError` class from the APLTree.

Place into `C:\dev\Myapp\src\` a copy of `HandleError.dyalog` from the APLTree. Edit `C:\dev\MyApp\MyApp.dyapp`:

~~~~~~~~ 
Target #
Load C:\dev\MyApp\src\APLTreeUtils
Load C:\dev\MyApp\src\WinFile
Load C:\dev\MyApp\src\HandleError
Load C:\dev\MyApp\src\Logger 
Load C:\dev\MyApp\src\MyApp 
~~~~~~~~ 

And set an alias `H` for it in the preamble of the `MyApp` namespace:

~~~~~~~~
:Namespace MyApp
    ⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3
leanpub-start-insert
    (A H L W)←#.(APLTreeUtils HandleError Logger WinFile)
leanpub-end-insert

   ⍝ define Exit Code constants
    EXIT←⎕NS''
    EXIT.OK←0
leanpub-start-insert
    EXIT.APPLICATION_CRASHED←100
leanpub-end-insert
    EXIT.INVALID_SOURCE_FOLDER←101
    EXIT.INVALID_TARGET_FOLDER←102
    EXIT.UNABLE_TO_READ_MANIFEST←103
    EXIT.NO_FILES_FOUND←104
    EXIT.UNABLE_TO_READ_SOURCE←105
    EXIT.UNABLE_TO_WRITE_TO_TARGET←106
~~~~~~~~ 

Note the new exit code to indicate the application crashed. 

We'll start as soon as `StartFromCmdLine` begins, setting `HandleError` to do whatever it can before we can give it more specific information derived from the calling environment. 

~~~~~~~~
    ∇ exit←StartFromCmdLine args
    ⍝ Initialise environment, and run the application
    ⍝ args: command line arguments
    ⍝ exit: Windows exit code -- see EXIT
      W.PolishCurrentDir ⍝ set current dir to that of EXE
leanpub-start-insert
      ⎕TRAP←0 'E' '#.HandleError.Process ''''' ⍝ trap unforeseen problems
leanpub-end-insert
      exit←Compile(args,'' '')[2 3]
    ∇
~~~~~~~~
	 
This trap will do to get things started and catch anything that falls over immediately. We need to get more specific in `Compile`.

~~~~~~~~
    ∇ exit←Compile(srcfolder tgtfile);∆;Log;Error;files
     ⍝ Dyalog Cookbook compiler
     ⍝ Compile files from srcfolder to tgtfile
     
      'CREATE!'W.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←L.CreatePropertySpace
      ∆.path←'Logs\' ⍝ subfolder of current directory
      ∆.encoding←'UTF8'
      ∆.filenamePrefix←'MyApp'
      ∆.refToUtils←#
      Log←⎕NEW L(,⊂∆)
      Log.Log'Started MyApp in ',∆.path
      Log.Log'Source: ' 'Target: ',¨srcfolder tgtfile
      Error←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}

leanpub-start-insert     
      ⍝ refine trap definition
      #.ErrorParms←H.CreateParms
      #.ErrorParms.errorFolder←W.PWD
      #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED
      #.ErrorParms.(logFunctionParent logFunction)←Log'Log'
      #.ErrorParms.trapInternalErrors←~isDev
      mayBreak←'Development'≡4⊃'.'⎕WG'APLVersion'
      means←{⊃⍺⌽⍵} ⋄ else←{⍵ ⍺}
      ⎕TRAP←mayBreak means(0⍴⎕TRAP)else 0 'E' '#.HandleError.Process ''#.ErrorParms'''
leanpub-end-insert
     
      :If 0=⊃(exit files)←CheckAgenda srcfolder tgtfile
          exit←CompileFiles files tgtfile
      :EndIf
     
      Log.Log'All done'
      Log.Close
    ∇
~~~~~~~~

`CheckAgenda` and `CompileFiles` are as before. 

**Some comments**

* `mayBreak` flags whether (true) the application is allowed to suspend, or (false) errors are to be caught and handled. Later we will set this flag in an INI file. For now we set it by testing whether the interpreter is development or runtime. 
* `means` … `else` are 'syntax sweeteners' for a simple conditional. A bit over the top to define them merely to use them on the next line. Later we shall look at how you can incorporate functions such as these into your development environment as your local extensions to the APL language. Watch Out: unlike with control structures, both expressions get evaluated, regardless of the value of `test`.    
* `⎕TRAP` -- if we're using a Development interpreter, any error will simply suspend -- including errors inside `HandleError` itself. Note the form `⊃test⌽expn1 expn2` as a simple conditional construct. 
* `#.ErrorParms.errorFolder` -- write crash files as siblings of the EXE. 
* `#.ErrorParms.(logFunctionParent logFunction)` -- we set a ref to the `Logger` instance, so `HandleError` can write on the log.

We can test this! Put a stop[^stop] in `CompileFiles` after copying the first file to the target. 

~~~~~~~~
          :EndIf
          i+←1
          . ⍝ DEBUG
      :Until i>≢srcfiles
      :OrIf exit≠EXIT.OK
    ∇
~~~~~~~~
	 
This will definitely break. It is not caught by any of the other traps. Export the workspace as before, run it from the DOS command shell… and what do we get?

Predictably we get a new TXT, with only the first file copied to it. In `C:\dev`, we find in the LOG a record of what happened. 

First, the log entry records the crash then breaks off:

~~~~~~~~
2014-12-21 15:42:43 *** Log File opened
2014-12-21 15:42:43 (0) Started C:\dev\myapp
2014-12-21 15:42:43 (0) Source: temp\source
2014-12-21 15:42:43 (0) Target: temp\test.txt
2014-12-21 15:42:43 (0) 2 files specified in manifest
2014-12-21 15:42:43 (0) 2 files found
2014-12-21 15:42:43 (0) Read 45 bytes from temp\source\foo.txt
2014-12-21 15:42:43 (0) *** Error
2014-12-21 15:42:43 (0) Error number=2
2014-12-21 15:42:43 (0) SYNTAX ERROR
2014-12-21 15:42:43 (0) CompileFiles[17] . ⍝ DEBUG
2014-12-21 15:42:43 (0)                 ∧
~~~~~~~~

We also have an HTM with a crash report, an eponymous DWS containing the workspace saved at the time it broke, and an eponymous DCF whose single component is a namespace of all the variables defined in the workspace. Some of this has got to help. 

Remove the deliberate error from `#.MyApp` and save your work. 


Discussion
----------

[SJT] What's a convenient way to show the exit codes returned to the Windows command shell?


Offcuts
-------



[^stop]: The poets among us love that the tersest way to bring a function to a full stop is to type one. 