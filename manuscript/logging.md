{:: encoding="utf-8" /}

Logging what happens 
====================

Our MyApp EXE is now working, but handles errors poorly. From the command line try:

    C:\>dev\myapp.exe temp\sauce temp\test.txt

We see an alert message: _This Dyalog APL runtime application has attempted to use the APL session and will therefore be closed._ 

MyApp failed, because there is no folder `C:\temp\sauce`. That triggered an error in the APL code. The interpreter tried to signal the error to the session. But a runtime task has no session, so at that point it popped the alert message and died.   

Could do better. In several ways.

* Have the app write a log file recording what it's done.
* Set traps to catch and log foreseeable problems.
* Set a top-level trap to catch and report unforeseen errors and save a crash workspace for analysis.

Start with the log file. We'll use the APLTree `Logger` class, which we'll now define in the workspace root. From the command line:

    C:>dev\MyApp\MyApp.dyapp

Whee. We just launched Dyalog and rebuilt the MyApp workspace. Now in the Dyalog session:

          ⎕SE.SALT.Load 'C:\temp\apltree\Logger'
          ⎕SE.SALT.Save #.Logger 'C:\dev\myapp\src\Logger'
    C:\dev\myapp\src\Logger.dyalog

And add a line to `C:\dev\MyApp\MyApp.dyapp`:

    Load C:\dev\MyApp\src\Logger

The `Logger` class is now part of MyApp. Lets get the app to log what it's doing. But first a short diversion. We'll add a small handy method to `WinFile`.

      )ED #.WinFile
    ∇ r←Parent path
    ⍝ Container of object eg
    ⍝ '\path\to\' ←→ Parent '\path\to\object'
    ⍝ Revn: sjt09aug15
      :Access Public Shared
      r←path↓⍨1-'\'⍳⍨⌽path
    ∇

When you leave the editor, SALT prompts you to confirm you want the change saved to the script file. (Click Yes.)

We now have a custom version of the `WinFile` class. (This introduces a maintenance issue we'll come back to and tackle later.) 

Let's add logging. Edit `MyApp`, as follows. (And have the new version saved to file when you leave the editor.) 

~~~~~~~~
:Namespace MyApp
    (⎕IO ⎕ML ⎕WX)←1 1 3
    (A L W)←#.(APLTreeUtils Logger WinFile) ⍝ aliases

    ∇ StartFromCmdLine
    ⍝ Initialise environment, read command parameters, and run the application
      W.PolishCurrentDir ⍝ set current dir to that of EXE
      Compile 1↓3↑(⌷2 ⎕NQ'.' 'getcommandlineargs'),'' ''
    ∇

    ∇ Compile(srcfolder tgtfile);files;_srcfolder;srcfile;∆;Log
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
     
      _srcfolder←srcfolder,(~'\/'∊⍨⊃⌽srcfolder)/'\'
     
      :If ~W.DoesExistDir _srcfolder
          Log.Log'Invalid source folder'
      :ElseIf ~W.DoesExistDir W.Parent tgtfile
          Log.Log'Invalid target folder'
      :Else
          :If W.DoesExistFile ∆←_srcfolder,'MANIFEST.DAT'
              files←A.ReadUtf8File ∆
              Log.Log(⍕≢files),' files specified in manifest'
          :Else
              files←W.Dir _srcfolder,'*.TXT'
              Log.Log(⍕≢files),' files found in folder'
          :EndIf
          files,⍨¨←⊂_srcfolder
          files/⍨←W.DoesExistFile files
     
          :If 0=≢files
              Log.Log'No files found to read'
          :Else
              W.Delete tgtfile
              :For srcfile :In files
                  ∆←'flat'A.ReadUtf8File srcfile
                  Log.Log'Read ',(⍕≢∆),' bytes from ',srcfile
                  'append'A.WriteUtf8File tgtfile ∆
              :EndFor
          :EndIf
     
      :EndIf
     
      Log.Log'All done'
    ∇

:EndNamespace
~~~~~~~~

A bit over the top for so simple an app, but definitely worth it for yours. 

Notice how defining the aliases `A`, `L`, and `W` in the namespace script -- the environment of `StartFromCmdLine` and `Compile` -- makes the function code more legible. 

The `⎕SIGNAL` that aborted the runtime task has now been replaced by log messages to say no files were found.


Where to keep the logfiles? 
---------------------------

Where is MyApp to write the logfile? We need a filepath we know exists. That rules out `srcfolder` or `tgtfile`. We need a logfile even if they aren't valid paths. But we do know the EXE exists, or MyApp would not be running. 

`StartFromCmdLine` uses `W.PolishCurrentDir` to set the current directory to that of the EXE. `Compile` uses `W.CheckPath` to ensure the current directory contains a folder `Logs`. That can then be safely specified as the `path` property for the Logger instance.   

Because the logging starts and ends in `Compile`, we can run this in the workspace now to test it.

~~~~~~~~
      )CS
#
      #.WinFile.Cd 'C:\dev\MyApp'
C:\Windows\system32
      #.WinFile.PWD ⍝ really?
C:\dev\MyApp
      ⍝ yes
      #.MyApp.Compile 'C:\temp\source' 'C:\temp\test.txt'
~~~~~~~~

Let's see what we got.

~~~~~~~~
      #.WinFile.PWD ⍝ still here?
C:\dev\MyApp
      WinFile.Dir 'Logs\*.LOG'
 MyApp_20150829.log 
      ↑APLTreeUtils.ReadUtf8File 'Logs\MyApp_20150829.log'
2015-08-29 12:43:15 *** Log File opened                          
2015-08-29 12:43:15 (0) Started MyApp in Logs\                   
2015-08-29 12:43:15 (0) Source: C:\temp\source                   
2015-08-29 12:43:15 (0) Target: C:\temp\test.txt                 
2015-08-29 12:43:15 (0) 2 files specified in manifest            
2015-08-29 12:43:15 (0) Read 45 bytes from C:\temp\source\foo.txt
2015-08-29 12:43:15 (0) Read 66 bytes from C:\temp\source\bar.txt
2015-08-29 12:43:15 (0) All done                                 
~~~~~~~~

Let's see if this works also for the exported EXE. Rebuild the workspace. 

          ⎕SE.SALT.Boot 'C:\dev\MyApp\MyApp'
    Loaded: #.APLTreeUtils
    Loaded: #.WinFile
    Loaded: #.Logger
    Loaded: #.MyApp
          ⎕LX←'#.MyApp.StartFromCmdLine'

Export as before, and in the Windows command line run the new `MyApp.exe`.

    C:\>dev\MyApp\MyApp.exe C:\temp\source C:\temp\test.txt

Yes! The output TXT gets produced as before, and the work gets logged in `C:\dev\MyApp\Logs`. 

We now have MyApp logging its work in a subfolder of the application folder and reporting problems which it has anticipated. Next we need to consider how to handle and report errors we have not anticipated. 

## Offcuts

But the only indication is that the task's Exit Code is 4 instead of 0, and the target file hasn't changed. 