{:: encoding="utf-8" /}

Handling errors
===============

MyApp now anticipates, tests for and reports certain foreseeable problems with the parameters. We'll now move on to handle errors more comprehensively.

Save a copy of `Z:\code\v02` as `Z:\code\v03`.


## What are we missing? 

1. Other problems are foreseeable. The file system is a rich source of ephemeral problems and displays. Many of these are caught and handled by the APLTree utilities. They might make several attempts to read or write a file before giving up and signalling an error. Hooray. We need to handle the events signalled when the utilities give up. 

2. The MyApp EXE terminates with an all-OK zero exit code even when it has caught and handled an error. It would be a better Windows citizen if it returned custom exit codes, letting a calling program know how it terminated..

3. By definition, unforeseen problems haven't been foreseen. But we foresee there will be some! A mere typo in the code could break execution. We need a master trap to catch any events that would break execution, save them for analysis, and report them in an orderly way. 


## Foreseen errors

We'll start with the second item from the list above. Now the result of `TxtToCsv` gets passed to `⎕OFF` to be returned to the operating system as an exit code. 

~~~~~~~~
    ∇ StartFromCmdLine
   ⍝ Read command parameters, run the application
    ⎕OFF TxtToCsv 2⊃2↑⌷2 ⎕NQ'.' 'GetCommandLineArgs'
    ∇
~~~~~~~~

And we'll define in `#.MyApp` a child namespace of exit codes.  

~~~~~~~~
    :Namespace EXIT
        OK←0
        INVALID_SOURCE←101
        UNABLE_TO_READ_SOURCE←102
        UNABLE_TO_WRITE_TARGET←103
    :EndNamespace
~~~~~~~~

We define an `OK` value of zero for completeness. (We really _are_ trying to eliminate from our functions numerical constants that the reader has to interpret.) In Windows, an exit code of zero is a normal exit. All the exit codes are defined in this namespace. The function code can refer to them by name, so the meaning is clear. And this is the _only_ definition of the exit-code values. 

A> We could have defined `EXIT` in `#.Constants`, but we reserve that script for Dyalog constants, keeping it as a component that could be used in other Dyalog applications. _These_ exit codes are specific to MyApp, so are better defined in `#.MyApp`. 

`TxtToCsv` still starts and stops the logging, but it now calls `CheckAgenda` to examine what's to be done, and `CountLettersIn` to do them. Both these functions use the function `Error`, local to `TxtToCsv`, to log errors.  

~~~~~~~~
    ∇ exit←TxtToCsv fullfilepath;∆;xxx;Log;Error;files;tgt
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text
      'CREATE!'W.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←L.CreatePropertySpace
      ∆.path←'Logs\' ⍝ subfolder of current directory
      ∆.encoding←'UTF8'
      ∆.filenamePrefix←'MyApp'
      ∆.refToUtils←#
      Log←⎕NEW L(,⊂∆)
      Log.Log'Started MyApp in ',W.PWD
      Log.Log'Source: ',fullfilepath

leanpub-start-insert     
      Error←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
      
      :If EXIT.OK=⊃(exit files)←CheckAgenda fullfilepath
          Log.Log'Target: ',tgt←(⊃,/2↑⎕NPARTS fullfilepath),'.CSV'
          exit←CountLettersIn files tgt
      :EndIf
leanpub-end-insert     
      Log.Log'All done'
    ∇
~~~~~~~~

Note the exit code is tested against `EXIT.OK`. Testing `~×exit` would work and read as well, but relies on `EXIT.OK` being 0. The point of defining the codes in `EXIT` is to make the functions relate to the exit codes only by their names.  

A> See _Delta, the Heracitlean variable_ in Part 2 for a discussion of how and why we use the `∆` variable. 

`CheckAgenda` looks for foreseeable errors. In general, we like functions to start at the top and exit at the bottom. `CheckAgenda` follows a common pattern of validation logic: a cascade of tests with corresponding actions to handle the error, terminating in an 'all clear'.

~~~
    ∇ (exit files)←CheckAgenda fullfilepath;type
      :If ~(type←1 ⎕NINFO fullfilepath)∊C.NINFO.TYPE.(DIRECTORY FILE)
          (files exit)←(Error 'INVALID_SOURCE')('')
      :ElseIf ~⎕NEXISTS fullfilepath
          (files exit)←(Error 'SOURCE_NOT_FOUND')('')
      :Else
          :Select type
          :Case C.NINFO.TYPE.DIRECTORY
              files←⊃(⎕NINFO⍠C.NINFO.WILDCARD)fullfilepath,'\*.txt'
          :Case C.NINFO.TYPE.FILE
              files←,⊂fullfilepath
          :EndSelect
          exit←EXIT.OK
      :EndIf
    ∇
~~~

`CountLettersIn` can get to work now knowing its arguments are valid. But it's working with the file system, and valid file operations can fail for all sorts of reasons, including unpredictable and ephemeral network conditions. So we set traps to catch and report failures. 

~~~
    ∇ exit←CountLettersIn (files tgt);i;txt;tbl;enc;nl;lines;bytes
     ⍝ Exit code from writing a letter-frequency count for a list of files
      tbl←0 2⍴'A' 0
      exit←EXIT.OK ⋄ i←1
      :While exit=EXIT.OK
          :Trap 0
              (txt enc nl)←⎕NGET i⊃files
              tbl⍪←CountLetters txt
          :Else
              exit←Error 'UNABLE_TO_READ_SOURCE'
          :EndTrap
      :Until (≢files)<i←i+1
      :If exit=EXIT.OK
          lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
          :Trap 0
              bytes←(lines ec nl)⎕NPUT tgt C.NPUT.OVERWRITE
          :Else
              exit←Error'UNABLE_TO_WRITE_TARGET'
              bytes←0
          :EndTrap
          Log.Log(⍕bytes),' bytes written to ',tgt
      :Endif
    ∇
~~~

In this context the `:Trap` structure has an advantage over `⎕TRAP`. When it fires, and control advances to its `:Else` fork, the trap is immediately cleared. So there is no need explicitly to reset the trap to avoid an open loop. 

The handling of error codes and messages can easily obscure the rest of the logic. Clarity is not always easy to find, but is well worth working for. This is particularly true where there is no convenient test for an error, only a trap for when it is encountered. 

In such cases, it is tempting to use a `:Return` statement to abort the function. But it can be confusing when a function 'aborts' in the middle, and we have learned a great respect for our capacity to get confused. Aborting from the middle of a function may also skip essential tidying up at the end.  

We meet this issue reading files, where we trap errors and abort within a loop. Note how the use of while/until allows -- unlike a for loop -- to test at the ends of the loop both the counter and the exit code.

Rather than simply reporting an error in the file operation, you might prefer to delay a fraction of a second, then retry, perhaps two or three times, in case the problem is ephemeral and clears quickly. 

This is in fact a deep topic. Many real-world problems can be treated by fix-and-resume when running under supervision, ie with a UI. Out of disk space? Offer the user a chance to delete some files and resume. But at this point we're working 'headless' -- without a UI -- and the simplest and lightest form of resilience will serve for now. 

We'll provide this in the form of a `retry` operator. This will catch errors in its operand (monadic or dyadic) and retry up to twice at 500-msec intervals. 

~~~
      retry←{
          ⍺←⊣
          0::⍺ ⍺⍺ ⍵⊣⎕DL .5
          0::⍺ ⍺⍺ ⍵⊣⎕DL .5
          ⍺ ⍺⍺ ⍵
      }
~~~

The `⍺⍺` in `retry` marks it as an operator, modifying how a function works. `⍺⍺` refers to the function. The error guard `0::` means _in the event of any error_. We use `retry` to modify the file reads and writes in `CountLettersIn`:

~~~
              (txt enc nl)←⎕NGET retry i⊃files
              ...
              bytes←(lines enc nl)⎕NPUT retry tgt C.NPUT.OVERWRITE
~~~

The `retry` operator goes into `#.MyApp`, not `#.Utilities`, because its strategy of two-more-tries is specific to this application. 



## Unforeseen errors

Our code so far covers the errors we foresee: errors in the parameters, and errors encountered in the file system. There remain the unforeseen errors, chief among them errors in our own code. If the code we have so far breaks, the EXE will try to report the problem to the session, find no session, and abort with an exit code of 4 to tell Windows "Sorry, it didn't work out."

If the error is easily replicable, we can easily track it down using the development interpreter. But the error might not be easily replicable. It could, for instance, have been produced by ephemeral congestion on a network interfering with file operations. Or the parameters for your app might be so complicated that it is hard to replicate the environment and data with confidence. What you really want for analysing the crash is a crash workspace, a snapshot of the ship before it went down. 

For this we need a high-level trap to catch any event not trapped by `CountLettersIn`. We want it to save the workspace for analysis. We might also want it to report the incident to the developer: users don't always do this. For this we'll use the `HandleError` class from the APLTree.

Edit `Z:\code\MyApp.dyapp`:

~~~~~~~~ 
Target #
Load ..\AplTree\APLTreeUtils
leanpub-start-insert
Load ..\AplTree\HandleError
leanpub-end-insert
Load ..\AplTree\Logger
Load ..\AplTree\WinFile
Load Constants
Load Utilities
Load MyApp
Run MyApp.SetLX
~~~~~~~~ 

And set an alias `H` for it in the preamble of the `MyApp` namespace:

~~~
    (A H L W)←#.(APLTreeUtils HandleError Logger WinFile) ⍝ from APLTree
~~~

Define a new exit code constant:

~~~
    OK←0
leanpub-start-insert
    APPLICATION_CRASHED←100
leanpub-end-insert
    INVALID_SOURCE←101
~~~~~~~~ 

We want the high-level trap only when we're running headless, so we'll start as soon as `StartFromCmdLine` begins, setting `HandleError` to do whatever it can before we can give it more specific information derived from the calling environment. 

~~~
    ∇ StartFromCmdLine
     ⍝ Read command parameters, run the application
leanpub-start-insert
      ⎕TRAP←0 'E' '#.HandleError.Process ''''' ⍝ trap unforeseen problems
leanpub-end-insert
      ⎕OFF TxtToCsv 2⊃2↑⌷2 ⎕NQ'.' 'GetCommandLineArgs'
    ∇
~~~
 
This trap will do to get things started and catch anything that falls over immediately. We need to get more specific now in `TxtToCsv`. Before getting to work with `CheckAgenda`, refine the global trap definition:

~~~
        ...
      Error←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
      
leanpub-start-insert     
      isDev←'Development'≡4⊃'.'⎕WG'APLVersion'
      ⍝ refine trap definition
      #.ErrorParms←H.CreateParms
      #.ErrorParms.errorFolder←W.PWD
      #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED
      #.ErrorParms.(logFunctionParent logFunction)←Log'Log'
      #.ErrorParms.trapInternalErrors←~isDev
      :If 'Development'≡4⊃'.'⎕WG'APLVersion'
          ⎕TRAP0⍴⎕TRAP
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

We can test this! Put a stop[^stop] in `CompileFiles` after reading the first file. 

~~~
          :EndTrap
leanpub-start-insert
          . ⍝ DEBUG
leanpub-end-insert
      :Until (≢files)<i←i+1
~~~

This will definitely break. It is not caught by any of the other traps. Export the workspace as before, run it from the DOS command shell… 

~~~
Z:>myapp.exe texts\en
~~~

and what do we get?

Predictably we get no new result CSV. In `Z:\code\v03\Logs`, we find in the LOG a record of what happened. 

First, the log entry records the crash then breaks off:

~~~~~~~~
FIXME
~~~~~~~~

We also have an HTM with a crash report, an eponymous DWS containing the workspace saved at the time it broke, and an eponymous DCF whose single component is a namespace of all the variables defined in the workspace. Some of this has got to help. 

Remove the deliberate error from `#.MyApp` and save your work. 


## Discussion

[SJT] What's a convenient way to show the exit codes returned to the Windows command shell?




[^stop]: The poets among us love that the tersest way to bring a function to a full stop is to type one. 