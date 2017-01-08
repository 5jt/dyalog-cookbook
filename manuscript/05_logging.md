{:: encoding="utf-8" /}

Logging what happens 
====================

MyApp 1.0 is now working, but handles errors poorly. See what happens when we try to work on a non-existent folder. In the command shell

~~~
Z:\code\v01>MyApp.exe Z:\texts\de
~~~

We see an alert message: _This Dyalog APL runtime application has attempted to use the APL session and will therefore be closed._ 

MyApp failed, because there is no folder `Z:\texts\de`. That triggered an error in the APL code. The interpreter tried to signal the error to the session. But a runtime task has no session, so at that point the interpreter popped the alert message and MyApp died.   

MyApp 2.0 could do better. In several ways.

* Have the program write a log file recording what happens.
* Set traps to catch and log foreseeable problems.
* Set a top-level trap to catch and report unforeseen errors and save a crash workspace for analysis.

Save a copy of `Z:\code\v01` as `Z:\code\v02`.

Start with the log file. We'll use the APLTree `Logger` class, which we'll now install in the workspace root. If you've not already done so, copy the APLTree library folder into `Z:\code`.[^apltree] Now edit `Z:\code\v02\MyApp.dyapp` to include some library code:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
Load ..\AplTree\Logger
Load Constants
Load Utilities
Load MyApp
Run MyApp.SetLX
~~~ 

and run the DYAPP to recreate the MyApp workspace. 

The `Logger` class is now part of MyApp. Let's get the program to log what it's doing. 

Within `MyApp`, some changes. Some aliases for the new code.

~~~
⍝ Aliases (referents must be defined previously)
    (A F L)←#.(APLTreeUtils FilesAndDirs Logger) ⍝ from APLTree
    (C U)←#.(Constants Utilities) 
~~~


Where to keep the logfiles? 
------------------------

Where is MyApp to write the logfile? We need a filepath we know exists. That rules out `fullfilepath`. We need a logfile even if that isn't a valid path.  

We'll write logfiles into a subfolder of the Current Directory. Where will that be?

When the EXE launches, the Current Directory is set by the command shell. Eg:

~~~
Z:\code\v02\MyApp.exe Z:\texts\en
~~~

Current Directory is `Z:\code\v02` and therefore the logfiles will appear in  `Z:\code\v02`.

If this version of MyApp were for shipping that would be a problem. An application installed in `C:\Program Files` cannot rely on being able to write logfiles there. That is a problem to be solved by an installer. We'll come to that later. But for this version of MyApp the logfiles are for your eyes only. It's fine that the logfiles appear wherever you launch the EXE. You just have know where they are. We will put them into a sub folder `Logs` within the current directory.

In developing and testing MyApp, we create the active workspace by running `MyApp.dyapp`. The interpreter sets the Current Directory of the active workspace as the DYAPP's parent folder. That too is sure to exist. 

~~~
      #.FilesAndDirs.PWD
Z:\code\v02
~~~

We need `TxtToCsv` to ensure the Current Directory contains a `Logs` folder. 

~~~
      'CREATE!' F.CheckPath 'Logs' ⍝ ensure subfolder of current dir
~~~

Now we set up the parameters for the Logger object. First we use the Logger class' sttaic `CreateParms` method to get a property space (object) with an initial a set of default parameters. We then modify those and use the object to create the Logger object. You can use the property space's `List` method to display its properties.) 

If `TxtToCsv` can log what it's doing, it makes sense to check its argument. We wrap the earlier version of the function in an if/else:

~~~
    ∇ {ok}←TxtToCsv fullfilepath;∆;csv;stem;path;files;txt;type;lines;nl;enc;tgt;src;tbl
   ⍝ Write a sibling CSV of the TXT located at fullfilepath,
   ⍝ containing a frequency count of the letters in the file text
      'CREATE!'F.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←L.CreateParms
      ∆.path←'Logs\' ⍝ subfolder of current directory
      ∆.encoding←'UTF8'
      ∆.filenamePrefix←'MyApp'
      Log←⎕NEW L(,⊂∆)
      Log.Log'Started MyApp in ',F.PWD
      Log.Log'Source: ',fullfilepath

      :If ~⎕NEXISTS fullfilepath
          Log.Log'Invalid source'
          ok←0
      :Else

          ⍝ as before...
      
      :EndIf
    ∇
~~~

Notice how defining the aliases `A`, `L`, and `W` in the namespace script -- the environment of `StartFromCmdLine` and `TxtToCsv` -- makes the function code more legible. 

The foreseeable error that aborted the runtime task -- on an invalid filepath -- has now been replaced by log messages to say no files were found.

As the logging starts and ends in `TxtToCsv`, we can run this in the workspace now to test it.

~~~~~~~~
      #.MyApp.TxtToCsv 'Z:\texts\en'
      ⊃(⎕NINFO⍠1) 'Logs\*.LOG'
 MyApp_20160406.log 
      ↑⎕NGET 'Logs\MyApp_20160406.log'
2016-04-06 13:42:43 *** Log File opened
2016-04-06 13:42:43 (0) Started MyApp in Z:\code\v02
2016-04-06 13:42:43 (0) Source: Z:\texts\en
2016-04-06 13:42:43 (0) Target: Z:\texts\en.csv
2016-04-06 13:42:43 (0) 244 bytes written to Z:\texts\en.csv
2016-04-06 13:42:43 (0) All done
~~~~~~~~

Let's see if this works also for the exported EXE. Run the DYAPP to rebuild the workspace. Export as before, but to `Z:\code\v02`, and in the Windows command line run the new `MyApp.exe`.

~~~
    Z:\code\v02>MyApp.exe Z:\texts\en
~~~

Yes! The output TXT gets produced as before, and the work gets logged in `Z:\code\v02\Logs`. 

Let's see what happens now when the filepath is invalid. 

~~~
    Z:\code\v02>MyApp.exe Z:\texts\de
~~~

No warning message -- the program made an orderly finish. And the log?

~~~
      ↑⎕NGET 'Logs\MyApp_20160406.log'
2016-04-06 13:42:43 *** Log File opened
2016-04-06 13:42:43 (0) Started MyApp in Z:\code\v02
2016-04-06 13:42:43 (0) Source: Z:\texts\en
2016-04-06 13:42:43 (0) Target: Z:\texts\en.csv
2016-04-06 13:42:43 (0) 244 bytes written to Z:\texts\en.csv
2016-04-06 13:42:43 (0) All done
2016-04-06 13:42:50 *** Log File opened
2016-04-06 13:42:50 (0) Started MyApp in Z:\code\v02
2016-04-06 13:42:50 (0) Source: Z:\texts\de
2016-04-06 13:42:50 (0) Invalid source
~~~

Yes! 

We now have MyApp logging its work in a subfolder of the application folder and reporting problems which it has anticipated.

Next we need to consider how to handle and report errors we have _not_ anticipated. We should also return some kind of error code to Windows. If MyApp encounters an error, any process calling it needs to know. 



[^apltree]: You can download the complete APLTree library from the [APL Wiki](http://aplwiki.com/CategoryAplTree).