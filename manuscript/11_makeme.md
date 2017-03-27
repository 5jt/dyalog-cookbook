♠{:: encoding="utf-8" /}

# Make me

It's time to take a closer look at the process of building the application workspace and exporting the EXE. In this chapter we'll

* add the automated execution of test cases to the DYAPP.
* create a "Make" utility that allows us to create everything thats needed for will finally be shipped to the customer.

At first glance you might think we can get away with splitting the DYAPP into two different versions, one for development and one for producing the final version of the EXE, but there will be tasks we cannot carry out with this approach. Examples are:

* Currently we depend on whatever version of Dyalog is associated with DYAPPs. We need an explicit way to define that version, 
  even if for the time being their is just one version installed on your machine.
* We might want to convert any Markdown documents -- like README.MD -- into an HTML document. While the MD is for development, 
  the HTML will become part of the final product.
* We need to make sure that the help system -- which we will introduce soon -- is properly compiled and configured.
* Soon we need an installer that produces an EXE we can send to the customer for installing the software.

We resume, as usual, by saving a copy of `Z:\code\v10` as `Z:\code\v11`.


## The development environment

`MyApp.dyapp` does not need much changes, it comes with everything that's needed for development. The only thing we add is to execute the test cases automatically. Well, almost automatically. Ideally we should always make sure that all test cases pass when we call it a day, but sometimes that is just not possible due to the amount of work involved. In such cases it might or might not be sensible to execute the test cases before you start working: in case you _know_ they will fail and there are _many_ of them there is no point in wasting computer ressources and your time, so we better ask.

For that we are going to have a function `YesOrNo` which is very simple and straightforward: the right argument (`question`) is printed to the session and then the user might answer that question. If she does not enter one of: "YyNn" the question is repeated. If she enters one of "Yy" a 1 is returned, otherwise a 0. Since we use this to ask ourself (or any other programmer) the function does not have to be bullet proof; that's why we allow `¯1↑⍞`.

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

We add a line to the bottom of `MyApp.dyapp`:

~~~
...
Run #.Tester.EstablishHelpersIn #.Tests
leanpub-start-insert
Run #.DevHelpers.RunTests 0
leanpub-end-insert
~~~

Now a developer who double-clicks the DYAPP in order to assemble the workspace will always be reminded of running all test cases before she starts working on the application. Experience tells us that this is not a bad thing.

However, we are going to use `MyApp.dyalog` for the "Make" process as well. That means we need a way to tell the essentials from what's only needed for supporting the development process. Therefore we restructure `MyApp.dyapp` and insert a comment line:

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
Run #.MyApp.SetLX #.MyApp.GetCommandLineArg ⍬

⍝ Start Development only
Load ..\AplTree\Tester
Load ..\AplTree\Execute
Load Tests
Load DevHelpers
Run #.Tester.EstablishHelpersIn #.Tests
Run #.DevHelpers.RunTests 0
~~~

Everything above the line `⍝ Start Development only` is essential; that's easy enough to find out.


## "Make" the application

I> In most other programming languages the process of compiling the course code and putting together an application is done by a utility that's called "Make". Therefore we use the same term.

At first sight it might seem that we can get away with a reduced version of `Develop.dyapp`, but that is not quite true. Soon we will discuss how to add a help system to our application. We must then make sure that the help system is compiled properly when the application is assembled. We cannot do this with a DYAPP; we need more flexibility.

A> ### More complex scenarios 
A> 
A> In a more complex application than ours you might prefer a different approach. Using an INI file for this is not a bad idea: it gives yoy way more freedom in defining all sorts of things while a DYAPP allows you to define just the modules to be loaded.
A> 
A> Also, if you have not one but quite a number of applications to deal with it is certainly not a bad idea to use a generalized user command like `]runmake`.



`Execute`, `Tester` and `Tests` have no place in the finished application, and we don't need to establish the test helpers either.

We could expunge them before exporting the active workspace as an EXE. Or -- have _two_ makefiles, one for the development environment, one for export. We go for the second approach.

Duplicate `MyApp.dyapp` and name the files `Develop.dyapp` and `Export.dyapp`. Edit `Export.dyapp` as follows: 

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
Load ..\AplTree\HandleError
Load ..\AplTree\IniFiles
Load ..\AplTree\Logger
Load Constants
Load Utilities
Load MyApp
Run MyApp.Export
~~~    

Now, `#.MyApp.Export` doesn't exist yet, so we'd better create it. You'll have noticed exporting an EXE can fail from time to time, and you might have performed this from the _File_ menu enough times to have tired of it. So we'll automate it. Automating it doesn't make it any more reliable, but it certainly makes retries easier. 

~~~
∇ msg←{flags}Export filename;type;flags;resource;icon;cmdline;success;try;max
⍝ Attempts to export the application
  flags←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'flags'       ⍝ 2 = BOUND_CONSOLE
  max←50
  type←'StandaloneNativeExe'
  resource←''
  icon←F.NormalizePath'.\images\logo.ico'
  cmdline←''
  success←try←0
  :Repeat
      :Trap 11
          2 ⎕NQ'.' 'Bind',filename type flags resource icon cmdline
          success←1
      :Else
          ⎕DL 0.2
      :EndTrap
      try+←1
  :Until success∨max<try
  msg←⊃success⌽('*** ERROR: Failed to export EXE')('Exported: ',filename)
  msg,←(try>1)/' after ',(⍕try),' tries'    
~~~

Basically, the choices you have been making from the _File > Export_ dialogue, now wrapped as a function. It tries up to 50 times which according to our experience is always enough to get the job done unless something is really wrong, like the EXE being running.

Running the DYAPP creates our working environment:

~~~
clear ws
Booting Z:\code\v06\Develop.dyapp
Loaded: #.APLTreeUtils
Loaded: #.FilesAndDirs
Loaded: #.HandleError
Loaded: #.IniFiles
Loaded: #.Logger
Loaded: #.Tester
Loaded: #.Constants
Loaded: #.Tests
Loaded: #.Utilities
Loaded: #.MyApp    
~~~       

The foregoing is a good example of how having automated tests allows us to refactor code with confidence that we'll notice and fix anything we break. 

And if we execute the suggested expression...[^export]

~~~
          #.Environment.Export '.\MyApp.exe'                            
    Exported .\MyApp.exe
~~~



## Workflow

With the two DYAPPs, your development cycle now looks like this:

1. Launch Develop.dyapp and review test results. 
2. Fix any errors and rerun `#.Tests.Run`. (If you edit the test themselves, either rerun `#,Tester.EstablishHelpersIn #.Tests` or simply close the session and relaunch Develop.dyapp.) 
3. Launch Export.dyapp, which will export a new EXE. Close the session. 



[^circle]: the best example of this are the circle functions represented by `○`. 

[^export]: It would be great if `#.Environment.Export` could be run straight from the DYAPP. But the DYAPP has to finish before an EXE can be exported. 

