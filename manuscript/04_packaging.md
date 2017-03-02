{:: encoding="utf-8" /}


# Package MyApp as an executable

Now we will make some adjustments in order to make `MyApp` ready for being packaged as an EXE. It will run from the command line and it will run 'headless' -- without a user interface (UI).

Copy all files in `z:\code\v02\` to `z:\code\v03\`. Alternatively you can dowload version 3 from the book's website of course.


## Output to the session log

What happens to values that would otherwise be written in the session log? They disappear. That’s not actually a problem for us, but it is tidy to catch anything that would otherwise be written to the UI, including empty arrays. Note that anything that is written to the session by accident can cause a major hiccup depending on the circumstances. Therefore you should _always_ use `⎕←` if you actually _intend_ to write to the session for the simple reason that you just have to search for `⎕←` in order to find any such statements.

But what if it happened by accident? You start an application with a double-click on a DYAPP, it works or a while and then all of a sudden the session appears, obviously because a function printed an empty vector to it. Because it's an empty vector you have nothing to search for. How to identify the culprit?

The easiest way is to associate a callback function with the `SessionPrint` event as in

~~~
      '⎕se'⎕WS'Event' 'SessionPrint' '#.CatchSessionPrint'
       #.⎕FX⊃'what CatchSessionPrint msg'  '⍎(0∊⍴what)/''. ⍝ Deliberate error''' '⎕←what'
       ⎕fx 'test arg'  '⎕←arg'
       test 1 2 3
1 2 3       
       test ''
⍎SYNTAX ERROR
CatchSessionPrint[1] .  ⍝ Deliberate error
                    ∧  
~~~

You can even use this to investigate what is about to be written to the session (the left argument of `CatchSessionPrint`) and make the function crash only if it's what you are after. In the example we check for anything that's empty.

I> Don't try the `⎕se.onSessionPrint←'#.CatchSessionPrint'` syntax with `⎕SE`; just stick with `⎕WS` etc.

I> Don't forget to clear the stack after `CatchSessionPrint` crashed because if you don't and instead call `test` again it would behave as if there was no handler associated with the `SessionPrint` event.

`TxtToCsv` however has a shy result, so it won't write its result to the session. That’s fine. 


## Reading arguments from the command line 

`TxtToCsv` needs an argument. The EXE must take it from the command line. We'll give `MyApp` a function `StartFromCmdLine`. We will also introduce `SetLX` in order to set `⎕LX`. The DYAPP will use it to start the program:

~~~
Target #
Load Constants
Load Utilities
Load MyApp
Run #.MyApp.SetLX ⍬
~~~

In `MyApp.dyalog` 

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
       {}TxtToCsv arg
    ∇
    
    ∇ r←GetCommandLineArgs dummy
       r←⊃¯1↑1↓2 ⎕NQ'.' 'GetCommandLineArgs' ⍝ Take the last one
    ∇  
    ...
~~~

This is how MyApp will run when called from the Windows command line. 

Notes:

* `Accents` is now a vector of text vectors (vtv). There is no point in making it a matrix when `CountLetters` (the only function that consumes `Accents`) requires a vtv anyway. We were able to simplify `CountLetters` as a consequence.

* Functions should return a result, even `StartFromCmdLine` and `SetLX`. Always. Otherwise, by definition, they are not functions. 

  If there is nothing reasonable to return as a result, return `⍬` as a shy result as in `StartFromCmdLine`. Make this a habit. It makes life easier in the long run. One example is that you cannot call a "function" from a dfn that does not return a result. Another one is that you cannot provide it as an operand to the `⍣` (power) operator.
  
* Make a function _always_ monadic rather than niladic even if it does not require an argument right now. 

  It is way easier to change a monadic function that has ignored its argument so far to one that actually requires an argument than to change a niladic function to a monadic one later on, especially when the function is called in many places, and this is something you _will_ run into; it's just a matter of time.
  
* `GetCommandLineArgs` ignores its right argument. It makes that very clear by using the name "dummy". "ignored" would be fine as well. When you change this at one stage or another then of course you have to change that name to something meaningful.
  
* Make sure that a `⎕LX` statement can be executed from anywhere. That requires the path to be fully qualified, therefore `#.MyApp` rather than `MyApp`. Make that a habit too. You won't regret it when later on you want to execute the statement.

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
6. Check the "Runtime application" and "Console application" boxes.
7. Click "Save". 

You should see an alert message: _File Z:\\code\\v03\\MyApp.exe successfully created._ This occasionally fails for no obvious reason. If it does fail just try again and you should be fine. If it keeps failing then the by far most common reason is that the EXE is running - you cannot replace an EXE while it is running. 

I> Although you cannot replace a running exe what you _can_ do is to rename it; that's possible. You can then create a new EXE with the original name.

In case you wonder what the check box "Console application" actually means: it _forces_ the resulting standalone EXE to have the Dyalog runtime EXE included and also sets the `IMAGE_SUBSYSTEM_WINDOWS_CUI` flag in the header of the EXE. The effect is that with the check box ticked when called on a command line (also known as the console) it waits for the program to return; it also catches the return code and assigns it to the environment variable "ERRORLEVEL". Also, when double-clicked a console window pops up. Finally you cannot really debug a console application with Ride; for details see the "Debugging a stand-alone EXE" chapter.

Without it being ticked the program is started and left alone; in particular you cannot catch the return code.

It is therefore recommended not to tick the "Console application" check box unless you have a good reason to do so.

T> Use the *Version* button to bind to the EXE information about the application, author, version, copyright and so on. These pieces of information will show in the "Properties/Details" tab of the resulting EXE. Note that in order to use the cursor keys or "Home" or "End" _within_ a cell the "Version" dialog box requires you to enter "in-cell" mode by pressing F2.

T> Specify an icon file to replace the Dyalog icon with one of your own. 

Let's run it. From a command line:

~~~
Z:\code\v03\MyApp.exe texts\en
~~~

Looking in Windows Explorer at `Z:\texts\en.csv`, we see its timestamp just changed. Our EXE works! 