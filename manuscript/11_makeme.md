{:: encoding="utf-8" /}

# Make me

It's time to take a closer look at the process of building the application workspace and exporting the EXE. In this chapter we'll

* add the automated execution of test cases to the DYAPP.
* create a "Make" utility that allows us to create everything thats needed for what will finally be shipped to the customer.

At first glance you might think we can get away with splitting the DYAPP into two different versions, one for development and one for producing the final version of the EXE, but there will be tasks we cannot carry out with this approach. Examples are:

* Currently we depend on whatever version of Dyalog is associated with DYAPPs. We need an explicit way to define that version, 
  even if for the time being there is just one version installed on our machine.
* We might want to convert any Markdown documents -- like README.MD -- into HTML documents. While the MD is the source, 
  the HTML will become part of the final product.
* We need to make sure that the help system -- which we will introduce soon -- is properly compiled and configured.
* Soon we need an installer that produces an EXE we can send to the customer for installing the software.

We resume, as usual, by saving a copy of `Z:\code\v10` as `Z:\code\v11`. Now delete `MyApp.exe` from `Z:\code\v11`: from now on we will create the EXE somewhere else.


## The development environment

`MyApp.dyapp` does not need many changes, it comes with everything that's needed for development. The only thing we add is to execute the test cases automatically. Well, almost automatically. Ideally we should always make sure that all test cases pass when we call it a day, but sometimes that is just not possible due to the amount of work involved. In such cases it might or might not be sensible to execute the test cases before you start working: in case you _know_ they will fail and there are _many_ of them there is no point in wasting computer ressources and your time, so we better ask.

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

Now a developer who double-clicks the DYAPP in order to assemble the workspace will always be reminded of running all test cases before she starts working on the application. Experience tells us that this is a good thing.


## "Make" the application

I> In most programming languages the process of compiling the source code and putting together an application is done by a utility that's called "Make"; therefore we use the same term.

At first sight it might seem that we can get away with a reduced version of `Develop.dyapp`, but that is not quite true. Soon we will discuss how to add a help system to our application. We must then make sure that the help system is compiled properly when the application is assembled. Later even more tasks will come up. Conclusion: we cannot do this with a DYAPP; we need more flexibility.

A> ### More complex scenarios 
A> 
A> In a more complex application than ours you might prefer a different approach. Using an INI file for this is not a bad idea: it gives you way more freedom in defining all sorts of things while a DYAPP allows you to define just the modules to be loaded.
A> 
A> Also, if you have not one but quite a number of applications to deal with it is certainly not a bad idea to use a generalized user command like `]runmake`.

`Execute`, `Tester` and `Tests` have no place in the finished application, and we don't need to establish the test helpers either.

We are going to create a DYAPP file `Make.dyapp` that performs the "Make". However, if you want to make sure that you can specify explicitly the version of Dyalog that should run this DYAPP rather than relying on what happens to be associated with the file extensions DWS, DYALOG and DYAPP at the time you double-click it then you need a batch file that starts the correct version of Dyalog. Create such a batch file as `Make.bat`. This is the contents:

~~~
"C:\Program Files\Dyalog\Dyalog APL{yourPreferredVersion}\Dyalog.exe" DYAPP="%~dp0Make.dyapp"
~~~

Of course you need to make amendments so that it is using the version of Dyalog of your choice. If it is at the moment what happens to run  a DYAPP on a double-click then this will give you the correct path:

~~~
'"',(⊃#.GetCommandLineArgs),'"'
@echo off
if NOT ["%errorlevel%"]==["0"] (
    pause
    exit /b %errorlevel%
)
~~~

You might want to add other parameters like `MAXWS=128MB` to the BAT file.

Notes:

* The expression `%~dp0` in a batch file will give you the full path -- with a trailing `\` -- of the folder that hosts the batch file. In other words, `"%~dp0Make.dyapp"` would result in a full path pointing to `MyApp.dyapp`, no matter where that is. You _must_ specify a full path because when the interpreter tries to find the DYAPP, the current directory is where the EXE lives, _not_ where the bat file lives.
* Checking `errorlevel` makes sure that in case of an error the batch file pauses. That gets us around the nasty problem that when you double-click a BAT file, you see a black windows popping up for a split of a second and then it's gone, leaving you wondering whether it has worked alright or not. Now when an error occurs it will pause. In addition it will pass the value of `errorlevel` as return code of the batch script.

  However, this technique is suitable only for scripts that are supposed to be executed by a WCU [^WCU]; you don't want to have a pause in scripts that are called by other scripts.

I> _Warning:_ Note that at the time of writing (2017-05) you _must_ write "dyapp" in lowercase characters - DYAPP would _not_ work!

A> ### The current directory
A> 
A> For APLers, the current directory (sometimes called "working directory") is a strange animal. In general, the current directory is where "the application" lives. That means that if you start an application `C:\Program Files\Foo\Foo.exe` then for the application "Foo" the current directory will be `C:\Program Files\Foo`. 
A>
A> That's fine except that for APLers "the application" is _not_ the DYALOG.EXE, it's the workspace, whether it was loaded from disk or assembled by a DYAPP. When you double-click `MyApp.dyapp` then the interpreter changes the current directory for you: it's where the DYAPP lives, and that's fine from an APL application programmer's point of view.
A> 
A> The same holds true when you double-click a workspace but it is _not_ true when you _load_ a workspace: the current directory remains what it was before, and that's where the Dyalog EXE lives. Therefore it's probably not a bad idea to change the current directory yourself at the earliest possible stage after loading a workspace: call `#.FilesAndDirs.PolishCurrentDir` and your are done, no matter what the circumstances are. One of the authors is doing this for roughly 20 years now, and it has solved several problems without introducing new ones.

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
Run #.MyApp.SetLX #.MyApp.GetCommandLineArg ⍬

Load Make
Run #.Make.Run 1
~~~

The upper part (until the blank line) is identical with `MyApp.dyapp` except that we don't load the stuff that's only needed during development. We then load a script `Make` and finally we call `Make.Run`. That's how `Make` looks at this point:

~~~
:Class Make
⍝ Puts the application `MyApp` together:
⍝ * Remove folder `Source\` in the current directory
⍝ * Create folder `Source\` in the current directory
⍝ * Copy icon to `Source\`
⍝ * Copy the INI file template over to `DESTINATION`
⍝ * Creates `MyApp.exe` within `Source\`
    ⎕IO←1 ⋄ ⎕ML←1
    DESTINATION←'MyApp'
    ∇ {filename}←Run offFlag;rc;en;more;successFlag;F;msg
      :Access Public Shared
      F←##.FilesAndDirs
      (rc en more)←F.RmDir DESTINATION
      {⍵:.}0≠rc
      successFlag←'Create!'F.CheckPath DESTINATION
      {⍵:.}1≠successFlag
      (successFlag more)←2↑'images'F.CopyTree DESTINATION,'\images'
      {⍵:.}1≠successFlag
      (rc more)←'MyApp.ini.template'F.CopyTo DESTINATION,'\MyApp.ini'
      {⍵:.}0≠rc
      Export'MyApp.exe'
      filename←DESTINATION,'\MyApp.exe'
      :If offFlag
          ⎕OFF
      :EndIf
    ∇
:EndClass
~~~

Note that the function executes a full stop in a dfn in case the right argument is a `1`. This is an easy way to make the function stop when something goes wrong. There is no point in doing anything but stopping the code from continuing since it is called by a programmer, and when it fails she wants to investigate straight away. And things can go wrong quite easily; for example, if somebody is looking with the Windows Explorer into `DESTINATION` then the attempt to remove that folder will fail.

First we create the folder `DESTINATION` from scratch and then we copy everything that's needed to the folder `DESTINATION` is pointing to: the application icon and the INI file. Whether the function executes `⎕OFF` or not depends on the right argument `offFlag`. Why that is needed will become apparent soon.

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

However, that leaves us vulnerable to another problem: imagine we introduce a new section and/or a new key and forget to copy it over to the tmeplate. In order to avoid this we add a test case to `Tests`:

~~~
    ∇ R←Test_misc_01(stopFlag batchFlag);⎕TRAP;ini1;ini2
      ⍝ Check whether MyApp.ini and MyApp.ini.template have the same sections and keys
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

In the penultimate line `Run` calls `Export`, a private function in the `Make` class that does not yet exist:

~~~
...
    ∇
    ∇ {r}←{flags}Export exeName;type;flags;resource;icon;cmdline;try;max;success
    ⍝ Attempts to export the application
      r←⍬
      flags←##.Constants.BIND_FLAGS.RUNTIME{⍺←0 ⋄ 0<⎕NC ⍵:⍎⍵ ⋄ ⍺}'flags'
      max←50
      type←'StandaloneNativeExe'
      icon←F.NormalizePath DESTINATION,'\images\logo.ico'
      resource←cmdline←''
      success←try←0
      :Repeat
          :Trap 11
              2 ⎕NQ'.' 'Bind',(DESTINATION,'\',exeName)type flags resource icon cmdline
              success←1
          :Else
              ⎕DL 0.2
          :EndTrap
      :Until success∨max<try←try+1
      :If 0=success
          ⎕←'*** ERROR: Failed to export EXE to ',DESTINATION,'\',exeName,' after ',(⍕try),' tries.'
          . ⍝ Deliberate error; allows investigation
      :EndIf
    ∇
:EndClass
~~~

`Export` automates what we've done so far by calling the "Export" command from the "File" menu. In case the "Bind" method fails it tries up to 50 times before it gives up. This is because from experience we know that depending on the OS and the machine and God knows what else sometimes the command fails several times before it finally succeeds. 

We specified `##.Constants.BIND_FLAGS.RUNTIME` as a default for `flags`, but that does not exist yet, so we add it to the `Constants` namespace:

~~~
:Namespace Constants
...
    :EndNamespace
leanpub-start-insert
    :Namespace BIND_FLAGS
        BOUND_CONSOLE←2
        RUNTIME←8
    :EndNamespace
leanpub-end-insert    
:EndNamespace
~~~

Double-click `Make.dyapp`: a folder `MyApp` should appear in `Z:\code\v11` with, among other files, `MyApp.exe`.


## The tests

Now that we have a way to automatically assemble all the necessary files our application will finally consist of we need to amend our tests. Double-click `MyApp.dyapp`. You don't need to execute the test cases right now because we are going to change them.

We need to make a few changes:

~~~
:Namespace Tests
    ⎕IO←1 ⋄ ⎕ML←1
    ∇ Initial;list;rc
      ∆Path←##.FilesAndDirs.GetTempPath,'\MyApp_Tests'
leanpub-start-insert      
      ∆ExeFilename←'MyApp.exe'
leanpub-end-insert      
      #.FilesAndDirs.RmDir ∆Path
      'Create!'#.FilesAndDirs.CheckPath ∆Path
      list←⊃#.FilesAndDirs.Dir'..\..\texts\en\*.txt'
      rc←list #.FilesAndDirs.CopyTo ∆Path,'\'
      ⍎(0∨.≠⊃rc)/'.'
leanpub-start-insert      
      ⎕SE.UCMD'Load ',#.FilesAndDirs.PWD,'\Make.dyalog -target=#'
      #.Make.Run 0      
leanpub-end-insert      
    ∇
 ...
:EndNamespace      
~~~

Notes: `Initial` ...

* ... now creates a global variable `∆ExeFilename` which will be used by the test cases.
* ... loads the script `Make.dyalog` into `#`.
* ... runs the function `Make.Run`. The `0` provided as right argument tell `Make.Run` to _not_ execute `⎕OFF`, something we would not appreciate at this stage.

In the next step replace the string `'MyApp.exe '` (note the trailing blank!) by ` ∆ExeFilename,' '` (note the leading and the trailing blank!) in the `Make` class. That makes sure that the EXE is created within the `MyApp` folder rather than in the current directory.

Our last change: we add `⎕EX'∆ExeFilename'` to the `Cleanup` function in order to get rid of the global variable when the job is done.


## Workflow

With the two DYAPPs and the BAT file, your development cycle now looks like this:

1. Launch `MyApp.dyapp` and review test results. 
2. Fix any errors and rerun `#.Tests.Run`. If you edit the test themselves, either rerun 
   
   ~~~
   `#,Tester.EstablishHelpersIn #.Tests` 
   ~~~
   
   or simply close the session and relaunch Develop.dyapp.
   
[WCU]: Worst Case User, also known as Dumbest Assumable User (DAU).