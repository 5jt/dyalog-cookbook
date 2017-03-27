# The Windows Event Log

Now that we have managed to establish `MyApp` as a Windows Service we have to make sure that it behaves. That means we need to make it report to the Windows Event Log.


## What exactly is the Windows Event Log?

In case you've never heard of it, or you are not sure what exactly the purpose of it is, this is for you; otherwise jump to "Why is the Windows Event Log important?".

The Windows Event Log is by no means an alternative to application specific log files. Some applications do not write to the Windows Event Log at all, some only when things go wrong and some always. In short the Windows Event Log is a kind of central repository for log entries.

For example, any application that runs as a Windows Service is expected to write to the Windows Event Log when it starts, when it quits and when it encounters problems, and it also might add even more information. You will find it hard to find an exception.

Similarly any Schduled Tasks are excpected to do the same, although some don't, or report just errors.


## Is the Windows Event Log important?

On a server all applications run either as Windows Services (most likely all of them) or as Windows Scheduled Tasks. Since no human is sitting in front of a server we need a way to detect problems on a server automatically. That can be achieved by using software that automaticallt scans the Windows Event Logs of any given computer. It can email or text admins when an application that's supposed to run doesn't, or when an application goes astray, drawing attention to that server.

So yes, the Windows Event Log is indeed really important.


## How to investigate the Windows Event Log

In modern versions of Windows you just press the Win key and then type "Event". That brings up a list which contains at least "Event Viewer".

By default the Event Viewer displayes all Event Logs on the current (local) machine. However, you can connect to another computer and investigate its Event Log, rights permitted. We keep it simple and focus just on the local Windows Event Log.


## Terms used

From the Microsoft documentation: "Each log in the Eventlog key contains subkeys called event sources. The event source is the name of the software that logs the event. It is often the name of the application or the name of a subcomponent of the application if the application is large. You can add a maximum of 16,384 event sources to the registry. The Security log is for system use only. Device drivers should add their names to the System log. Applications and services should add their names to the Application log or create a custom log." [^winlog]


## Application log versus custom log

Only few applications write to the Windows Event Log. The vast majority of those which do, write into "Windows Logs\Application", but if you wish you can create your own log under "Applications and services logs".


## Let's do it

Copy `Z:\code\v??` to `Z:\code\v??`.

First we need to load the module `WindowsEventLog` from within `MyApp.dyapp`:

~~~
...
Load ..\AplTree\OS
Load ..\AplTree\WindowsEventLog
Load ..\AplTree\Logger
...
~~~

⍝TODO⍝ ⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹

We now add a flag to the INI file that allows us to switch writing to the Window Event Log on and off:

~~~

~~~

For writing to the Windows Event Log we invent a new function `Log2WindowsEventLog`:

~~~
∇ {r}←{type}Log2WindowsEventLog msg
  r←⍬
  :If G.WindowEventLag
      type←{0<⎕NC ⍵:⍵ ⋄ 'info'}'type'
      :Select type
      :Case 'info'
          MyWinEventLog.WriteInfo msg
      :Case 'warn'
          MyWinEventLog.WriteWarning msg
      :Case 'error'
          MyWinEventLog.WriteError msg
      :Else
          'Invalid left argument; must be one of: "warn", "info", "error"'⎕SIGNAL 11
      :EndSelect
  :EndIf
∇
~~~

⍝TODO⍝ ⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹



Now we change `Initial` so that it creates an instance of `WindowsEventLog` and returns it as part of the result. We also tell the Windows Event Log that the application has started:

~~~
leanpub-start-insert  
∇ {(MyLogger MyWinEventLog)}←Initial dummy
leanpub-end-insert  
⍝ Prepares the application.
⍝ Side effect: creates `MyLogger`, an instance of the `Logger` class.
  #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
  MyLogger←OpenLogFile'Logs'      
  MyLogger.Log'Started MyApp in ',F.PWD
leanpub-start-insert  
  MyWinEventLog←⎕NEW ##.WindowsEventLog(,⊂'Myapp')
  MyWinEventLog.WriteInfo'Application started'
leanpub-end-insert  
∇
~~~

`Initial` is called by `StartFromCmdLine`, so that functions needs to be amended as well. We localize `MyWinEventLog`, the name of the instance, and change the call to `Initial` since it now returns two rather than one instance. Finally we tell the Windows Event Log that we are shutting down after `TxtToCsv` was called:

~~~
leanpub-start-insert  
∇ {r}←StartFromCmdLine arg;MyLogger;MyWinEventLog
leanpub-end-insert  
⍝ Needs command line parameters, runs the application.
  r←⍬
leanpub-start-insert  
  (MyLogger MyWinEventLog)←Initial ⍬
leanpub-end-insert    
  r←TxtToCsv arg
leanpub-start-insert    
  MyWinEventLog.WriteInfo'Application shuts down'
leanpub-end-insert      
∇
~~~

So far we have used the method `WriteInfo`. For demonstration purposes we use the two other methods available, `WriteWarning` and `WriteError`:

~~~
∇ rc←TxtToCsv fullfilepath;files;tbl;lines;target
  ...
leanpub-start-insert        
  MyWinEventLog.WriteWarning'MyApp warning'
  MyWinEventLog.WriteError'MyApp Error'
leanpub-end-insert        
  (target files)←GetFiles fullfilepath
  ...
∇
~~~

Having made all these changes we are ready to compile the WS from scratch: 

1. Double-click the DYAPP in `v??`.
1. Change the WSID to "MyApp"
1. Execute the command `)save` in order to save the WS.
1. Execute `)off`

Why do we need to do this? Because the source "MyApp" is very unlikely to exist yet on your computer. Although we assume that you are using a user ID with admin rights, that's not enough the create a new Windows Event Log source. You have to select "Run as admin" from the context menu, and that is not available for workspaces and DYAPPs.

But it is available for the EXE that starts your version of Dyalog. Find it, right-click on it and select "Run as admin". Windows will most likely ask whether you are sure about this and then start an instance of Dyalog with elevated rights. Now you can `)load` the workspace we have just created and run `⎕LX`.

Now start the Event Viewer; as a result of running the program with admin rights you should see something like this:

![The Windows Event Log](images/WindowsEventLog.jpg)

You might need to scroll down a bit.

You can execute `)off` now in the admin-dyalog session: when you run the program again the source already exists, so from now on you don't need admin rights anymore. In a real-life scenario this business of creating the Windows Event Log source is done by an installer, one of the several reasons why a user who wants to install a program needs admin rights. We will come back to this when we discuss installers.


### Tricks, tips and traps

No doubt you feel now confident with the Windows Event Log, right? Well, keep reading:

* When you create a new source in a (new) custom log then in the Registry the new log is listed as expected but it has _two_ keys, one carrying the name of the source you intended to create and a second one with the same name as the log itself. In the Event Viewer however only the intended source is listed.

* The names of sources must be _unqiue_ across _all_ logs.

* Only the first 8 characters of the name of a source are really taken into account; everything else is ignored. That means that when you have a source `S1234567_1` and you want to register `S1234567_2` you will get an error "Source already exists".

* When the Event Viewer is up and running and you either create or delete a log or a source and then press F5 then the Event Viewer GUI flickers, and you might expect that to be an indicator for the GUI having updated itself but that's not the case, at least not at the time of writing (2017-03). You have to close the Event Viewer and re-open it to actually see your changes.

* Even when your user ID has admin rights and you've started Dyalog in elevated mode ("Run as administrator" in the context menu) you _cannot_ delete a custom log with calls to `WinReg` (the APLTree member that deals with the Windows Registry). The only way to delete custom logs is with the Registry Editor: go to the key

  `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\`
  
  and delete the key(s) (=children) you want to get rid of. It's not a bad idea to create a system restore point [^restore] before you do that. By the way, if you never payed attention to System Restore Points you really need to follow the link because under Windows 10 System Restore Points are not generated automaticelly by default anymore; you have to switch them on explicitly.
  
* Once you have written events to a source and then deleted the log the source pretends to belong to, the events remain saved anyway. They are just not vsisible anymore. That can be proven by re-creating the log: all the events make a come-back and show up again as they did before. 

  If you really want to get rid of the logs then you have to select the "Clear log" command from the context menu in the Event Viewer (tree only!) before you delete the log.

* If you want to analyze the contents of a log in APL you will find the instance methods `Read` (which reads the whole log) and `ReadThese` (which takes line numbers and reads just them) useful. 
 

[^winlog]: Microsoft on the Windows Event Log: <https://msdn.microsoft.com/en-us/library/windows/desktop/aa363648(v=vs.85).aspx>
 
[^restore]: Details about System Restore Point: <https://en.wikipedia.org/wiki/System_Restore>