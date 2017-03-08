{:: encoding="utf-8" /}


# Package MyApp as an executable

Now we will make some adjustments in order to make `MyApp` ready for being packaged as an EXE. It will run from the command line and it will run 'headless' -- without a user interface (UI).

Copy all files in `z:\code\v02\` to `z:\code\v03\`. Alternatively you can download version 3 from the book's website.


## Output to the session log

In a runtime interpreter or an EXE, there is no APL session, and output to the session which would have been visible in a development system will simply disappear. If we want the user to be able to view this output, we need to write it to a log file.

But how do we find out where we need to make changes? We recommended that you think about this from the start, and make sure that all _intentional_ output is output through a "Log" function, or at least use an explicit `⎕←` so that output can be located in the source.

A> ### Unwanted output to the session
A>
A> What can you do if you have output appearing in the session and you don't know where in your application it is being generated? The easiest way is to associate a callback function with the `SessionPrint` event as in:
A> 
A> ~~~
A>   '⎕se' ⎕WS 'Event' 'SessionPrint' '#.Catch'
A>   #.⎕FX ↑'what Catch m'  ':If 0∊⍴what' '. ⍝ !' ':Else' '⎕←what' ':Endif'
A>   ⎕FX 'test arg'  '⎕←arg'
A>   test 1 2 3
A>⍎SYNTAX ERROR
A>Catch[2] . ⍝ !
A>~~~
A>
A> You can even use this to investigate what is about to be written to the session (the left argument of `Catch`) and make the function stop when it reaches the output you are looking for. In the above example we check for anything that’s empty.

I> Don't try the `⎕se.onSessionPrint←'#.Catch'` syntax with `⎕SE`; just stick with `⎕WS` as in the above example.

I> Don't forget to clear the stack after `Catch` crashed because if you don't and instead call `test` again it would behave as if there was no handler associated with the `SessionPrint` event.

`TxtToCsv` however has a shy result, so it won't write its result to the session. That’s fine. 


## Reading arguments from the command line 

`TxtToCsv` needs an argument. The EXE must take it from the command line. We'll give `MyApp` a function `StartFromCmdLine`. We will also introduce `SetLX` in order to set `⎕LX`. The last line of the DYAPP will run it to set the workspace up to start corectly:

~~~
Target #
Load Constants
Load Utilities
Load MyApp
Run #.MyApp.SetLX ⍬
~~~

In `MyApp.dyalog`:

~~~
:Namespace MyApp

    ∇r←Version
    ⍝ * 1.0.0
    ⍝   * Runs as a stand-alone EXE and takes parameters from the command line.
      r←(⍕⎕THIS) '1.0.0' '2017-02-26'
    ∇
    ...
    ⍝ === VARIABLES ===

    Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}Accents map toUppercase ⍵
      }
    ...
    ∇ {r}←SetLX dummy
    :Access Public Shared
    ⍝ Set Latent Expression (needed in order to export workspace as EXE)
     r←⍬
     ⎕LX←'#.MyApp.StartFromCmdLine #.MyApp.GetCommandLineArgs ⍬'
    ∇

    ∇ {r}←StartFromCmdLine arg
    :Access Public Shared
    ⍝ Run the application; arg = usually command line parameters .
       r←⍬
       r←TxtToCsv arg~''''
    ∇
    
    ∇ r←GetCommandLineArgs dummy
       r←⊃¯1↑1↓2 ⎕NQ'.' 'GetCommandLineArgs' ⍝ Take the last one
    ∇  
    ...
~~~

Now MyApp is ready to be run from the Windows command line, with the name of the file to be processed following the command name. 

Notes:

* By introducing a function `Version` we start to keep track of changes.

* `Accents` is now a vector of text vectors (vtv). There is no point in making it a matrix when `CountLetters` (the only function that consumes `Accents`) requires a vtv anyway. We were able to simplify `CountLetters` as a consequence.

* Functions should return a result, even `StartFromCmdLine` and `SetLX`. Always. Otherwise, by definition, they are not functions. 

  If there is nothing reasonable to return as a result, return `⍬` as a shy result as in `StartFromCmdLine`. Make this a habit. It makes life easier in the long run. One example is that you cannot call a "function" from a dfn that does not return a result. Another one is that you cannot provide it as an operand to the `⍣` (power) operator.
  
* _Always_ make a function monadic rather than niladic even if it does not require an argument right now. 

  It is way easier to change a monadic function that has ignored its argument so far to one that actually requires an argument than to change a niladic function to a monadic one later on, especially when the function is called in many places, and this is something you _will_ run into; it's just a matter of time.
  
* `GetCommandLineArgs` ignores its right argument. It makes that very clear by using the name "dummy". "ignored" would be fine as well. When you change this at one stage or another then of course you have to change that name to something meaningful.
  
* Make sure that a `⎕LX` statement can be executed from anywhere. That requires the path to be fully qualified, therefore `#.MyApp` rather than `MyApp`. Make that a habit too. You won't regret it when later on you want to execute the statement:

* By introducing a function `Version` we start to keep track of changes.


  ~~~
  ⍎⎕LX
  ~~~
  
  while you are not in root.

* You may wonder whether `#.MyApp.(StartFromCmdLine GetCommandLineArgs ⍬)` is better than `#.MyApp.StartFromCmdLine #.MyApp.GetCommandLineArgs ⍬` because it is shorter. Good point, but there is a drawback: you cannot <Shift+Enter> on either of the two functions within the shorter expression but you can with the longer one.

* Currently we allow only one file (or folder) to be specified. That's supposed to be the last parameter specified on the command line. We'll improve on this later.

We're now nearly ready to export the first version of our EXE. 

1. Double-click the DYAPP in order to create the WS.
2. From the File menu pick "Export". 
3. Pick `Z:\code\v03` as the destination folder. 
4. From the list "Save as type" pick "Standalone Executable". 
5. Set the "File name" as `MyApp`.
6. Check the "Runtime application" check box 
7. Make sure that the "Console application" check box is not ticked.
8. Click "Save". 

You should see an alert message: _File Z:\\code\\v03\\MyApp.exe successfully created._ This occasionally fails for no obvious reason. If it does fail just try again and you should be fine. If it keeps failing then the by far most common reason is that the EXE is running - you cannot replace an EXE while it is running. 

I> Although you cannot replace a running exe what you _can_ do is to rename it; that's possible. You can then create a new EXE with the original name.

In case you wonder what a "Console application" actually is: apart from including the Dyalog runtime EXE included it also sets the `IMAGE_SUBSYSTEM_WINDOWS_CUI` flag in the header of the EXE. The effect is that, when called _on a command line_ (also known as the console), it will wait for the program to return; it also catches the return code and assigns it to the environment variable "ERRORLEVEL". Also, when double-clicked a console window pops up. When called in any other way you _can_ catch the return code

Note that you cannot really debug a console application with Ride; for details see the "Debugging a stand-alone EXE" chapter.

If you do not tick "Console application", the program is started as a separate process and you cannot catch the return code.

It is therefore recommended not to tick the "Console application" check box unless you have a good reason to do so.

T> Use the *Version* button to bind to the EXE information about the application, author, version, copyright and so on. These pieces of information will show in the "Properties/Details" tab of the resulting EXE. Note that in order to use the cursor keys or "Home" or "End" _within_ a cell the "Version" dialog box requires you to enter "in-cell" mode by pressing F2.

T> Specify an icon file to replace the Dyalog icon with one of your own. 

Let's run it. From a command line:

~~~
Z:\code\v03\MyApp.exe texts\en
~~~

Looking in Windows Explorer at `Z:\texts\en.csv`, we see its timestamp just changed. Our EXE works! 