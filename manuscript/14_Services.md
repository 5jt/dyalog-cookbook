{:: encoding="utf-8" /}

# Windows Services


## What is a Windows Service

While the Windows Task Manager just starts any ordinary application, any application that runs as a Windows Service must be specifically designed in order to meet a number of requirements. In particular services are expected to communicate by exchanging messages with the Windows Service Control Manager (SCM). Commands can be issued by the `SC.exe` (Service Controller) [^scm] application or interactively via the "Services" application. This allows the user to not only start but also to pause, continue (or resume) and stop a Windows Service. 


## The Window Event Log
  
Our application is already prepared to write log files and save information in case of a crash, but that's not sufficient: while applications started by the Windows Task Scheduler _might_ write to the Windows Event Log, applications running as a Windows Service are _expected_ to do that, and for good reasons: when running on a server one cannot expect anybody to be around for keeping an eye on log or crash files. In large organisations running server farms it is common to have a software in place that frequently checks the Windows Event Logs of all those servers, and raise an alarm in one way or another (TCP messages, text messages, emails, whatever) in case it finds any problems.

We won't add the ability to write to the Windows Event Log in this chapter but rather discuss how to do this in the next chapter.


## Restrictions

With Dyalog version 16.0 we cannot install a stand-alone EXE as a Windows Service. All we can do is to install a given interpreter and then ask it to load a workspace which implies running `⎕LX`. In a future version of Dyalog this restriction will most likely be lifted.

That means that in case you don't want to expose your code as a workspace you have a problem. There are some solutions:

* Lock all the functions and operators in the workspace.  
* You can create .NET assemblies from your APL code and call them from the workspace that is running as a Windows Service.
* You can start the stand-alone EXE from the workspace that is running as a Windows Service and communicate with it via Conga.
  
All three solutions share the disadvantage that they add a level of complexity without any gain but hiding the code, but at least there are several escape routes available.


## The ServiceState namespace

In order to simplify things we are going to make use of the `ServiceState` namespace, another member of the APLTree project. It requires you to do just two things:

1. Call `ServiceState.Init` as early as possible. This function will make sure that the Service is capable of communicating with the SCM. 

   To do it as early as possible is necessary so that any request will be answered in time. Windows is not exactly patient when it waits for a Service to respond to a "Pause", "Resume" or "Stop" request: after 5 seconds you are already in danger to see an error message that is basically saying that the Service refused to cooperate. However, note that the interpreter confirms the "start" request for us; no further action is required.
   
   Normally you need to create a parameter space by calling `CreateParmSpace` and to set at least the name of the log function and possibly the namespace (or class instance) that log function is living in; this log function is used to log any incoming requests from the SCM. The parameter space is then passed as right argument to `Init`.

1. In its main loop the Service is expected to call `ServiceState.CheckServiceMessages`.
   
   This is an operator, so it needs a function as operand: that is a function that is doing the logging, allowing `CheckServiceMessages` to log its actions to the log file. (If you don't have the need to write to a log file then simply passing `{⍵}` will do.)
      
   If no request of the SCM is pending when `CheckServiceMessages` is called then it will quit straight away and return a 0. If a "Pause" is pending then it goes into a loop, and it will continue to loop (with a `⎕DL` in between) until either "Continue" (sometimes referred to as "Resume") or "Stop" is requested by the SCM. If a "Stop" is requested the operator will subsequently quit and return a 1.

We will use this approach when making `MyApp` a Service.

## Installing and uninstalling a Service.

**Note:** for installing as well as un-installing a Service you need admin rights.

Let's assume you have loaded a WS `MyService` which you want to install as a Windows Service run by the same version of Dyalog you are currently in:

~~~
aplexe←'"',(2 ⎕NQ # 'GetEnvironment' 'dyalog'),'\dyalogrt.exe"'
wsid←'"whereEverTheWsLives\MyAppService.DWS"'
cmd←aplexe,' ',wsid,' APL_ServiceInstall=MyAppService DYALOG_NOPOPUPS=1'
~~~

That would do the trick.

Note `DYALOG_NOPOPUPS=1`: this prevents any dialogs from popping up (aplcore, WS FULL etc.). You don't want them when Dyalog is running in the background because there's nobody around to click the "OK" button. This also prevents the "Service MyAppService successfully installed" message from popping up which you don't want to see when executing tests that install, start, pause, resume, stop and uninstall a Service.

In order to uninstall the Service simply open a console window with "Run as administrator" and enter:

~~~
sc delete MyAppService
~~~

and you are done.

A> ### Pitfalls when installing / uninstalling Windows Services
A>
A> Be warned that when you have opened the "Services" GUI while installing or uninstalling a Windows Service then you must press F5 on the GUI in order to update it. The problem is not that the GUI does not update itself, though this can be quite annoying; it can get much worse: you might end up with a Service marked in the GUI as "disabled", and the only thing you can do by then it rebooting the machine. This will happen when you try to perform an action on the GUI when it is not in sync of the Service's current state.

A> ### SC: Service Control
A>
A> `SC` is a command line program that allows a user with admin rights to issue particular commands regarding Services. The general format is:
A>
A> ~~~
A> SC.exe {command} {serviceName}
A> ~~~
A>
A> Commonly used commands are:
A> * create
A> * start
A> * pause
A> * continue
A> * stop
A> * query
A> * delete

## Obstacles

From experience we can tell that there are quite a number of traps. In general there are three different types of problem you might encounter:

1. The Service pretends to start (read: show "running" in the Services GUI) but nothing happens at all.
2. The Service starts, the log file reads fine, but once you request the Service to "Pause" or "Stop" you get nothing but a Windows error message.
3. It all works well but the application does not do anything, or something unexpected.


### The Service seems to be doing nothing at all

If a Service does not seem to do anything when started:

* Check the name and path of the workspace the Service is expected to load: if that's wrong you won't see anything at all - the message "Workspace not found" goes straight into the ether.
* Make sure the workspace size is sufficent. Again too little memory would not produce any error message.
* The Service might create an aplcore when started. Look out for a file `aplcore` in the Service's current directory to exclude this possibility.
* The Service might have created a CONTINUE workspace for all sorts of reasons.


  Keep in mind that once a second thread is started, Dyalog is not able any more to save a CONTINUE workspace. On the other hand you should have established error trapping before a second thread is started; that would avoid this problem.
* Start the "Event Viewer" and check whether any useful piece of information is provided.  
  
### The Service starts but ignores "Pause" and "Stop" requests.

This requires the log file to contain all the information we expect: calling parameters etc. In such a case we _know_ that the Service has started and is running.

* Check whether you have really called `ServiceState.Init` at an early stage.
* Make sure that you have called `CheckServiceMessages` in the main loop of the application.

If these two conditions are met then it's hard to imagine what could the application prevent from reacting to any requests of the SCM, except when you have an endless loop somewhere in your application.


### The application does not do what's supposed to do.

First  and foremost it is worth mentioning that any application that is supposed to run as a Service should be developed as an ordinary application, including test cases. When it passes such test cases you have reasons to be confident that the application should run fine as a Service as well.

Having said this, there can be surprising differences between running as an ordinary application and a Service. For example, when a Service runs not with a user's account but with the system account (which is quite normal to do) any call to `#.FilesAndDirs.GetTempPath` results in `"C:\Windows\System32\config\systemprofile\AppData\Local\Apps"` while for a user's account it would be something like `'C:\Users\{username}\AppData\Local\Temp'`.

When the application behaves in an unexpected way you need to debug it, and for that Ride is invaluable.


## Potions and wands

### Ride

First of all we have to make sure that the application provides us a Ride if we wish to. Since passing any arguments for a Ride via the command line requires the Service to be uninstalled and installed at least twice we recommend preparing the Service from within the application instead.

If you have trouble to Ride into any kind of application: make sure that there is not an old instance of the Service running which might occupy the port you need for the Ride.
 
There are two very different scenarios when you might want to use Ride:

* The Service does not seem to start or does not react to "Pause" or "Stop" requests. 
* Although the Service starts fine and reacts properly to any "Pause" or "Stop" requests, the application is behaving unexpectedly.
 
In the former case make sure that you allow the programmer to Ride into the Service as soon as possible - literally. That means that the second line of the function noted on `⎕LX` should provide a Ride, assuming that the first line sets `⎕IO`, `⎕ML` etc.

At such an early stage we don't have an INI file instantiated, so we cannot switch Ride on and off via the INI file, we have to modify the code for that. You might feel tempted to overcome this by doing it a bit later (read: after having processed the INI file etc.) but we warn you: if a Service does not cooperate then "a bit later" might well be too late to get to the bottom of the problem, so don't.
  
In the latter case you should add the call to `HandleRide` to the main loop of the application.

I> Make sure that you have _never_ more than one of the two calls to `HandleRide` active: if both are active you would be able to make use of the first one but the second one would throw you out!  


### Logging


#### Local logging

We want to log as soon as possible any command-line parameters as well as any message exchange between the Service and the SCM. Again we advise you to not wait until the folder holding the log files is defined by instantiating the INI file. Instead we suggest making the assumption that a certain folder ("Logs") will (or might) exist in the current directory which will become where the workspace was loaded from.

If that's not suitable then consider passing the directory that will host the "Logs" folder as a command line parameter.


#### Windows event log

In the next chapter we will discuss how and why to use the Windows Event Log, in particular when it comes to Services.


## How to implement this


### Setting the latent expression

First of all we need to point out that `MyApp` as it stands is hardly a candidate for a Service. Therefore we have to make something up: the idea is to specify one to many folders to be watched by the `MyApp` Service. If any files are found then those are processed. Finally the app will store hashes for all files it has processed. That allows it to recognize any added, changed or removed files efficiently.

In the future we need to create a workspace that can be loaded by the Service. Therefore we need to set `⎕LX`, and for that we create a new function:

~~~
 ∇ {r}←SetLXForService(earlyRide ridePort)
   ⍝ Set Latent Expression (needed in order to export workspace as EXE)
   ⍝ `earlyRide` is a flag. 1 allows a Ride.
   ⍝ `ridePort`  is the port number to be used for a Ride.
      r←⍬
      ⎕LX←'#.MyApp.RunAsService ',(⍕earlyRide),' ',(⍕ridePort)
 ∇
~~~

The function takes a flag `earlyRide` and an integer `ridePort` as arguments. How and when this function will be called will be discussed in a moment.

Because we have now two functions that set `⎕LX` we shall rename the original one (`SetLX`) to `SetLXForApplication` to make clear what each of them is good for.


### Initialising the Service

Next we need the main function for the service:

~~~
 ∇ {r}←RunAsService(earlyRide ridePort);⎕TRAP;MyLogger;Config;∆FileHashes
    ⍝ Main function when app is running as a Windows Service.
    ⍝ `earlyRide`: flag that allows a very early Ride.
    ⍝ `ridePort`: Port number used by Ride.
      r←⍬
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
      1 CheckForRide earlyRide ridePort
      #.FilesAndDirs.PolishCurrentDir
      ⎕TRAP←#.HandleError.SetTrap ⍬
      (Config MyLogger)←Initial 1
      ⎕TRAP←(Config.Debug=0)SetTrap Config
      Config.ControlFileTieNo←CheckForOtherInstances ⍬
      ∆FileHashes←0 2⍴''
      :If #.ServiceState.IsRunningAsService
          {MainLoop ⍵}&ridePort
          ⎕DQ'.'
      :Else
          MainLoop ridePort
      :EndIf
      Cleanup ⍬
      Off EXIT.OK
    ∇
~~~

Notes:

* This function allows a Ride very early indeed.
* It calls the function `Initial` and passes a 1 as right argument. The 1 stands for "running as a service". We will discuss `Initial` next.
* We create a global variable `∆FileHashes` which we use to collect the hashes of all files that we have processed. This gives us an easy and fast way to check whether any of the files we've already processes got changed.
* We call `MainLoop` (a function that has not been established yet) in different ways depending on whether the function is running as part of a Windows Service or not for the simple reason that it is much easier to debug an application that runs in a single thread.


### The "business logic"

Time to change `MyApp.Initial` function:

~~~
leanpub-start-insert
 ∇ (Config MyLogger)←Initial isService;parms
leanpub-end-insert
    ⍝ Prepares the application.
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
leanpub-start-insert
      Config←CreateConfig isService
leanpub-end-insert
      Config.ControlFileTieNo←CheckForOtherInstances ⍬      
      CheckForRide (0≠Config.Ride) Config.Ride
      MyLogger←OpenLogFile Config.LogFolder
      MyLogger.Log'Started MyApp in ',F.PWD
      MyLogger.Log 2 ⎕NQ'#' 'GetCommandLine'
      MyLogger.Log↓⎕FMT Config.∆List
leanpub-start-insert
      :If isService
          parms←#.ServiceState.CreateParmSpace
          parms.logFunction←'Log'
          parms.logFunctionParent←MyLogger
          #.ServiceState.Init parms
      :EndIf
leanpub-end-insert
 ∇
~~~

Note that we pass `isService` as right argument to `CreateConfig`, so we must amend `CreateConfig` accordingly:

~~~
leanpub-start-insert
 ∇ Config←CreateConfig isService;myIni;iniFilename
leanpub-end-insert 
   Config←⎕NS''
   ...
leanpub-start-insert          
   Config.IsService←isService
leanpub-end-insert          
   ...         
       Config.Accents←⊃Config.Accents myIni.Get'Config:Accents'
leanpub-start-insert       
        :If isService
            Config.WatchFolders←⊃myIni.Get'Folders:Watch'
        :Else
            Config.LogFolder←'expand'F.NormalizePath⊃Config.LogFolder myIni.Get'Folders:Logs'
        :EndIf
leanpub-end-insert       
        Config.DumpFolder←'expand'F.NormalizePath⊃Config.DumpFolder myIni.Get'Folders:Errors'
   ...
 ∇
~~~

Note that `WatchFolder` is introduced only when the application is running as a Service.

Time to introduce the function `MainLoop`:

~~~
∇ {r}←MainLoop port;S
  r←⍬
  MyLogger.Log'"MyApp" server started'
  S←#.ServiceState
  :Repeat
      CheckForRide 0 port
      LoopOverFolder ⍬
      :If (MyLogger.Log S.CheckServiceMessages)S.IsRunningAsService
          MyLogger.Log'"MyApp" is about to shut down...'
          :Leave
      :EndIf
      ⎕DL 2
  :Until 0
 ⍝Done
∇
~~~

Notes:

* We put a call to the function `CheckForRide` into the code but pass a 0 as first item of the right argument, making it inactive for the time being.
* The call to `ServiceState.CheckServiceMessages` makes sure that the function reacts to any status change requests from the SCM.
* `LoopOverFolder` is doing the real work.

The function `LoopOverFolder`:

~~~
∇ {r}←LoopOverFolder dummy;folder;files;hashes;noOf;rc
  r←⍬
  :For folder :In Config.WatchFolders
      files←#.FilesAndDirs.ListFiles folder,'\*.txt'
      hashes←GetHash¨files
      (files hashes)←(~hashes∊∆FileHashes[;2])∘/¨files hashes
      :If 0<noOf←LoopOverFiles files hashes
          :If EXIT.OK=rc←TxtToCsv folder
              MyLogger.Log'Totals.csv updated'
          :Else
              LogError rc('Could not update Totals.csv, RC=',EXIT.GetName rc)
          :EndIf
      :EndIf
  :EndFor
∇
~~~

This function calls `GetHash` so we better introduce this:

~~~
 GetHash←{
 ⍝ Get hash for file ⍵
     ⊣2 ⎕NQ'#' 'GetBuildID'⍵
 }
~~~

The function `LoopOverFiles`:

~~~
 ∇ noOf←LoopOverFiles(files hashes);file;hash;rc
   noOf←0
   :For file hash :InEach files hashes
       :If EXIT.OK=rc←TxtToCsv file
           ∆FileHashes⍪←file hash
           noOf+←1
       :EndIf
   :EndFor
 ∇
 ~~~

This function finally calls `TxtToCsv`.

Because of the change we've made to the right argument of `Initial` we need  to change `StartFromCmdLine`; it needs a 0 as right argument now, indicating that it is _not_ running as a Service:

~~~
∇ {r}←StartFromCmdLine arg;MyLogger;Config;rc;⎕TRAP
...
   (Config MyLogger)←Initial 0
...    
~~~

Two more changes:

~~~
 ∇ {r}←Cleanup dummy
   r←⍬
   ⎕FUNTIE Config.ControlFileTieNo
   Config.ControlFileTieNo←⍬
leanpub-start-insert
   '#'⎕WS'Event' 'ServiceNotification' 0
leanpub-end-insert
 ∇

 ∇ r←PublicFns
leanpub-start-insert 
   r←'StartFromCmdLine' 'TxtToCsv' 'SetLXForApplication' 'SetLXForService' 
   r,←'GetCommandLineArg' 'RunAsService'
leanpub-end-insert   
 ∇
~~~


### Running the test cases

Now it's time to make sure that we did not break anything: double-click `MyApp.dyapp` and answer the question whether you would like to run all test cases with "y". If something does not work execute `#.Tests.RunDebug 0` and fix the problem(s).


### Installing and un-installing the Service

In order to install as well as un-install the Service we should have two BAT files: `InstallService.bat` and `Uninstall_Service.bat`. We will create these BAT files from Dyalog. For that we create a class `ServiceHelpers`:

~~~
:Class ServiceHelpers

    ∇ {r}←CreateBatFiles dummy;path;cmd;aplexe;wsid
      :Access Public Shared
    ⍝ Write two BAT files to the current directory: 
    ⍝ Install_Service.bat and Uninstall_Service.bat
      r←⍬
      path←#.FilesAndDirs.PWD

      aplexe←'"',(2 ⎕NQ'#' 'GetEnvironment' 'dyalog'),'\dyalogrt.exe"'
      wsid←'"%~dp0\MyAppService.DWS"'
      cmd←aplexe,' ',wsid,' APL_ServiceInstall=MyAppService'
      cmd,←' DYALOG_NOPOPUPS=1 MAXWS=64MB'
      #.APLTreeUtils.WriteUtf8File(path,'\Install_Service.bat')cmd

      cmd←⊂'sc delete MyAppService'
      cmd,←⊂'@echo off'
      cmd,←⊂'if NOT ["%errorlevel%"]==["0"] ('
      cmd,←⊂'pause'
      cmd,←⊂'exit /b %errorlevel%'
      cmd,←⊂')'
      #.APLTreeUtils.WriteUtf8File(path,'\Uninstall_Service.bat')cmd
     ⍝Done
    ∇

:EndClass
~~~

Notes:

* The install BAT will use the version of Dyalog used to create the BAT file, and it will call the runtime EXE.
* In case you are not familiar with `%~dp0`: this stand for "the directory this BAT file was loaded from". In other words: as long as the workspace `MyAppService.DWS` (which we have not created yet) is a sibling of the BAT file it will work.
* The un-install BAT file will check the `errorlevel` variable. If it detects an error it will pause so that one can actually see the error message.


### "Make" for the Service

Now it's time to create a DYAPP for the service. For that copy `Make.dyapp` as `MakeService.dyapp` and then edit it:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
Load ..\AplTree\HandleError
Load ..\AplTree\IniFiles
Load ..\AplTree\OS
Load ..\AplTree\Logger
Load ..\AplTree\EventCodes
Load Constants
Load Utilities
Load MyApp

Load ..\AplTree\ServiceState
Load ..\AplTree\Tester
Load ..\AplTree\Execute
Load ..\AplTree\WinSys
Load TestsForServices
Load ServiceHelpers

Run #.ServiceHelpers.CreateBatFiles ⍬
Run '#.⎕EX''ServiceHelpers'''
Run #.MyApp.SetLXForService 0 4512   ⍝ [1|0]: Ride/no Ride, [n] Ride port number

Load MakeService
Run #.MakeService.Run 0
~~~

Notes:

* We need some more APLTree modules: `Tester`, `Execute` and `WinSys`, so we added them.
* We make sure that the two BAT files for installing and un-installing the service are written to the disk.
* We delete the class `ServiceHelpers`: it is not needed for running the Service.
* We set `⎕LX` by calling `SetLXForService`.
* We load the class `MakeService` and run `MakeService.Run`.

That obviously requires the class `MakeService` to be introduced:

~~~
:Class MakeService
⍝ Creates a workspace "MyAppService" which can then run as a service.
⍝ * Re-create folder DESTINATION in the current directory
⍝ * Copy the INI file template over to DESTINATION\
⍝ * Save the workspace within DESTINATION
    ⎕IO←1 ⋄ ⎕ML←1
    DESTINATION←'MyAppService'

    ∇ {r}←Run offFlag;en;successFlag
      :Access Public Shared
      r←⍬
      (rc en more)←F.RmDir DESTINATION
      {⍵:.}0≠rc
      successFlag←'Create!'F.CheckPath DESTINATION
      {⍵:.}1≠successFlag
      'MyApp.ini.template' CopyTo DESTINATION,'\MyApp.ini'
      'Install_Service.bat' CopyTo DESTINATION,'\'
      'Uninstall_Service.bat' CopyTo DESTINATION,'\'
      ⎕WSID←DESTINATION,'\',DESTINATION
      #.⎕EX⍕⎕THIS
      0 ⎕SAVE ⎕WSID
      {⎕OFF}⍣(⊃offFlag)⊣⍬      
    ∇
    
    ∇ {r}←from CopyTo to;rc;more;msg
      r←⍬
      (rc more)←from ##.FilesAndDirs.CopyTo to
      msg←'Copy failed RC=' ,(⍕rc),'; ',more
      msg ⎕signal 11/⍨0≠rc
    ∇
:EndClass
~~~

Notes:

* Assigns the name of the destination folder to the global `DESTINATION`.
* Re-creates a folder with the name `DESTINATION` carries as well as a sub-folder `images`.
* Copies over the INI file as well as the two BAT files.
* Finally it sets `⎕WSID` and saved the workspace without the status indicator and without `MakeService` by deleting itself.

A> ### Self-deleting code
A>
A> In case you wonder how it is possible that the function `MakeService.Run` deletes itself and keeps running anyway:
A>
A> APL code (functions, operators and scripts) that is about to be executed is copied onto the stack. You can investigate the stack at any given moment with  `)si` and `)sinl`; for details type the command in question into the session and then press F1.
A>
A> Even if the code of a class executes `⎕EX ⍕⎕THIS` or a function or operator `⎕EX ⊃⎕SI` the code keeps running because the copy on the stack will exist until the script or function or operator quits.


## Testing the Service

We have test cases that ensure that the "business logic" of `MyApp` works just fine. What we also need are tests that make sure that it runs fine as a Service as well.

Since the two test scenarios are only loosely related we want to keep those tests separate. It is easy to see way: testing the Service means assembling all the needed stuff, installing the Service, carrying out the tests and finally un-installing the tests and cleaning up. We don't want to execute this unless we really have to.

We start be creating a new script `TestsForServices` which we save alongside the other scrips in `v13/`:

~~~
:Namespace TestsForServices
⍝ Installs a service "MyAppService" in a folder within the Windows Temp directory with 
⍝ a randomly chosen name. The tests then start, pause, continue and stop the service.\\
⍝ It also checks whether the application produces the expected results.

    ⎕IO←1 ⋄ ⎕ML←1

:EndNamespace
~~~

We now discuss the functions we are going to add one after the other. Note that the `Initial` function is particularly important in this scenario: we need to copy over all the stuff we need, code as well as input files, make adjustments, and install the Service. This could all be done in a single function but it would be lengthy and difficult to read. To avoid this we split the function into obvious units. By naming those functions carefully we should get away without adding any comments because the code explains itself. Or so we hope. Here we go:

~~~
∇ r←Initial;rc;ini;row;bat;more
   ∆Path←##.FilesAndDirs.GetTempFilename''
   #.FilesAndDirs.DeleteFile ∆Path
   ∆Path←¯4↓∆Path
   ∆ServiceName←'MyAppService'
   r←0
   :If 0=#.WinSys.IsRunningAsAdmin
       ⎕←'Sorry, but you need admin rights to run this test suite successfully!'
       :Return
   :EndIf
   ∆CreateFolderStructure ⍬
   ∆CopyFiles ⍬
   ∆CreateBATs ⍬
   ∆CreateIniFile ⍬
   ∆InstallService ⍬
   ⎕←'*** Service ',∆ServiceName,' successfully installed'
   r←1
~~~

Note that all the sub-function and global variables start their names with `∆`.

After having executed the test suite we want to clean up, so we create a function `Cleanup`. Just a reminder: in case the test framework finds a function `Initial` it executes it _before_ executing the actual test cases, while any function  `Cleanup` will be executed _after_ the test cases have been executed.

~~~
∇ {r}←Cleanup
   r←⍬
   :If 0<⎕NC'∆ServiceName'
       ∆Execute_SC_Cmd'stop'
       ∆Execute_SC_Cmd'delete'
       ##.FilesAndDirs.RmDir ∆Path
       ⎕EX¨'∆Path' '∆ServiceName'
   :EndIf
∇
~~~

We could discuss all the sub functions called by these two functions but it would tell us little. Therefore we suggest that you copy the code from the web site. We just discuss the two test functions:

~~~
∇ R←Test_01(stopFlag batchFlag);⎕TRAP;rc;more
  ⍝ Start, pause and continue the service.
  ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
  R←∆Failed
 
  (rc more)←∆Execute_SC_Cmd'start'
  →FailsIf 0≠rc
  ∆Pause 2
  (rc more)←∆Execute_SC_Cmd'query'
  →FailsIf 0≠rc
  →FailsIf 0=∨/'STATE : 4 RUNNING'⍷#.APLTreeUtils.dmb more
  ∆Pause 2
 
  (rc more)←∆Execute_SC_Cmd'pause'
  →FailsIf 0≠rc
  ∆Pause 2
  →FailsIf 1≠⍴#.FilesAndDirs.ListFiles ∆Path,'\service\Logs\'
  (rc more)←∆Execute_SC_Cmd'query'
  →FailsIf 0=∨/'STATE : 7 PAUSED'⍷#.APLTreeUtils.dmb more
 
  (rc more)←∆Execute_SC_Cmd'continue'
  →FailsIf 0≠rc
  ∆Pause 2
  (rc more)←∆Execute_SC_Cmd'query'
  →FailsIf 0=∨/'STATE : 4 RUNNING'⍷#.APLTreeUtils.dmb more
 
  (rc more)←∆Execute_SC_Cmd'stop'
  →FailsIf 0≠rc
  ∆Pause 2
  (rc more)←∆Execute_SC_Cmd'query'○
  →FailsIf 0=∨/'STATE : 1 STOPPED'⍷#.APLTreeUtils.dmb more
 
  R←∆OK
∇
~~~

This test simply starts, pauses, continues and finally stops the Service.

~~~
∇ R←Test_02(stopFlag batchFlag);⎕TRAP;rc;more;noOfCSVs;success;oldTotal;newTotal;A;F
  ⍝ Start service, check results, give it some more work to do, check and stop it.
   ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
   R←∆Failed
   (A F)←#.(APLTreeUtils FilesAndDirs)
 
   (rc more)←∆Execute_SC_Cmd'start'
   →FailsIf 0≠rc
   ∆Pause 1
   (rc more)←∆Execute_SC_Cmd'query'
   →FailsIf 0=∨/'STATE : 4 RUNNING'⍷A.dmb more
 
   ⍝ At this point the service will have processed all the text files, so there
   ⍝ must now be some CSV files, including the Total.csv file.
   ⍝ We then copy 6 more text files, so we should see 6 more CSVs & a changed Total.
   oldTotal←↑{','A.Split ⍵}¨A.ReadUtf8File ∆Path,'\input\en\total.csv'
   noOfCSVs←⍴F.ListFiles ∆Path,'\input\en\*.csv'
   (success more list)←(∆Path,'\texts')F.CopyTree ∆Path,'\input\'  ⍝ All of them
   {1≠⍵:.}success
   ∆Pause 5
   newTotal←↑{','A.Split ⍵}¨A.ReadUtf8File ∆Path,'\input\en\total.csv'
   →PassesIf(noOfCSVs+6)=⍴F.ListFiles ∆Path,'\input\en\*.csv'
   →PassesIf oldTotal≢newTotal
   oldTotal[;2]←⍎¨oldTotal[;2]
   newTotal[;2]←⍎¨newTotal[;2]
   →PassesIf oldTotal[;2]∧.≤newTotal[;2]
 
   (rc more)←∆Execute_SC_Cmd'stop'
   →FailsIf 0≠rc
   ∆Pause 2
   (rc more)←∆Execute_SC_Cmd'query'
   →FailsIf 0=∨/'STATE : 1 STOPPED'⍷A.dmb more
 
   R←∆OK
∇
~~~

Though this test starts and stops the Service, it's real purpose is to make sure that the Service processes input files as expected.

### Running the tests

First we need to make sure that everything is assembled freshly, and with admin rights. The best way to do that is to run the script `MakeService.dyapp` from a console that was started with admin rights. This is because unfortunately you cannot right-click on a DYAPP and select "Run as administrator" from the context menu.

A> ### Console with admin rights.
A> 
A> The best way to start a console window with admin rights:
A>
A> 1. Press the Windows key.
A> 1. Type "cmd"; if you are tempted to ask "what shall I type this into" then don't - just type.
A> 1. Right-click on "Command prompt" and select "Run as administrator".

A Dyalog instance is started. In the session you should see something similar to this:

~~~
Booting C:\...\v13\MakeService.dyapp
Loaded: #.APLTreeUtils
Loaded: #.FilesAndDirs
Loaded: #.HandleError
Loaded: #.IniFiles
Loaded: #.OS
Loaded: #.Logger
Loaded: #.EventCodes
Loaded: #.Constants
Loaded: #.Utilities
Loaded: #.MyApp
Loaded: #.ServiceState
Loaded: #.Tester
Loaded: #.Execute
Loaded: #.WinSys
Loaded: #.TestsForServices
Loaded: #.ServiceHelpers
#.⎕EX'ServiceHelpers'
Loaded: #.MakeService
~~~

In the next step establish the test helpers by calling `#.TestsForServices.GetHelpers`.

Finally run `#.TestsForServices.RunDebug 0`. You should see something like this:

~~~
#.TestsForServices.RunDebug 0
--- Test framework "Tester" version 3.3.0 from 2017-05-19 -----------------------------
Searching for INI file testcases_APLTEAM2.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
*** Service MyAppService successfully installed
  "Initial" found and sucessfully executed
--- Tests started at 2017-05-28 19:11:49 on #.TestsForServices ------------------------
   Pausing for 2 seconds...
   Pausing for 2 seconds...
   Pausing for 2 seconds...
   Pausing for 2 seconds...
  Test_01 (1 of 2) : Start, pause and continue the service.
   Pausing for 2 seconds...
   Pausing for 2 seconds...
   Pausing for 2 seconds...
  Test_02 (2 of 2) : Start service, check results, give it some more work to do, check and stop it.
 -------------------------------------------------------------------------------------------------- 
   2 test cases executed                                                                                
   0 test cases failed                                                                                  
   0 test cases broken                                                                                  
Time of execution recorded on variable #.TestsForServices.TestCasesExecutedAt in: 2017-05-28 19:12:04
Looking for a function "Cleanup"...
  Function "Cleanup" found and sucessfully executed.
*** Tests done

~~~