{:: encoding="utf-8" /}

# Scheduled Tasks


## What is a Scheduled Task?

Windows offers a task scheduler in order to run applications at specific times. Like Services Scheduled Tasks are designed for background job, meaning that such applications have no GUI, and cannot have a GUI.

The Scheduler allows you to start the application on a specific date and time once, or every day, every week or every month. The user does not have to be logged on (that's different from old versions of Windows) and it allows to run an application in elevated mode (soon to be discussed).


## What can and cannot be achieved by Scheduled Tasks

Scheduled Tasks -- like Services -- are perfect for background tasks. Examples are:

* Take a backup once a week
* Check the availability of your website once every hour
* Send a test email to all your email addresses once a week

Scheduled Tasks cannot interact with the user: when you try to put up a GUI and ask a question then nothing will appear on the screen: you just can't do this.


## Scheduled Tasks versus Services

If your application needs to run all the time, even with delays between actions, then running as a Service would be more appropriate. Services are typically started automatically when the machine is booted, and they typically keep running until the next boot.

To make this point clear, imagine these two scenarios:

* You need an application to start once a week and take a backup of a specific folder.
* You need an application to constantly monitor a specific folder for certain file types (say Markdown) and convert them (say into HTML files).

The former is clearly a candidate for a Scheduled Task while the latter is a candidate for a Service.


## Preconditions for a Scheduled Task

You need either a saved workspace with `⎕LX` set or an EXE created from a workspace. Unless you need to make sure that your code cannot be looked at, an EXE has no advantages over a simple saved workspace; it just adds complexity and therefore should be avoided if there aren't any advantages. However, if you cannot be sure whether the required version of Dyalog is installed on the target machine then you have no choice: it has to be a stand-alone EXE.

We have already taken care of handling errors and writing to log files, which are the only sources of information in general, and in particular for analyzing any problems that pop up when a Scheduled Task runs, or crashes. In other words, we are ready to go.

Our application does not suggest itself as a Scheduled Task; it's obviously a candidate for running as a Service, but that does not mean it cannot run as a Scheduled Task, so let's start.


## Precautions: ensure one instance only

When dealing with Scheduled Tasks then usually you don't want more than one instance of the application running at the same time. When there is a problem with a Scheduled Task then one of the most common reasons why getting to the bottom of the problem turns out to be difficult is that you fire up another instance when there is already one running. For example, you try to Ride into it but the port used by Ride is already occupied by an instance that was started earlier without you being aware of this. For that reason we are going to prevent this from happening.

A> Even in the rare circumstances when you want an application managed by the Task Scheduler to run in parallel more than once you should establish a mechanism that allows you to enforce having just one instance running if this is needed for debugging purposes. Make it an INI entry (like "AllowMultipleInstances") and document it appropriately.

We resume, as usual, by saving a copy of `Z:\code\v11` as `Z:\code\v12`.

In order to force the application to run only once at any given time we add a function `CheckForOtherInstances` to `MyApp.dyalog`:

~~~
∇ {tno}←CheckForOtherInstances dummy;filename;listOfTiedFiles;ind
 ⍝ Attempts to tie the file "MyAppCtrl.dcf" exclusively and returns the tie number.
 ⍝ If that is not possible then an error is thrown because we can assume that the
 ⍝ application is already running.\\
 ⍝ Notes:
 ⍝ * In case the file is already tied it is untied first.
 ⍝ * If the file does not exist it is created.
   filename←'MyAppCtrl.dcf'
   :If 0=F.IsFile filename
       tno←filename ⎕FCREATE 0
   :Else
       :If ~0∊⍴⎕FNUMS
           listOfTiedFiles←A.dtb↓⎕FNAMES
           ind←listOfTiedFiles⍳⊂filename
       :AndIf ind≤⍴⎕FNUMS
           ⎕FUNTIE ind⊃⎕FNUMS
       :EndIf
       :Trap 24
           tno←filename ⎕FTIE 0
       :Else
           'Application is already running'⎕SIGNAL C.APP_STATUS.ALREADY_RUNNING
       :EndTrap
   :EndIf
∇
~~~

Notes:

* First we check whether the file `MyAppCtrl.dcf` exists. If it doesn't we create it and the job is done: creating a file always implies an exclusive tie.
* If it does exist we check whether it is tied by itself, in case we are developing and have restarted the application without having closed it down properly. We then untie the file.
* Finally we attempt to tie the file exclusively but trap error 24 - that's "FILE TIED". If that's the case we throw an error `Constants.APP_STATUS.ALREADY_RUNNING`.
* The file is expected (or will be created) in the current directory. 

Since this function will throw an error `Constants.APP_STATUS.ALREADY_RUNNING` we need to add this to the `EXIT` namespace in `MyApp`:

~~~
:Namespace EXIT
...
        UNABLE_TO_WRITE_TARGET←114
leanpub-start-insert           
        ALREADY_RUNNING←115
leanpub-end-insert           
          GetName←{
        ....
:EndNamespace        
~~~

We change `Initial` so that it calls this new function:

~~~
∇ (Config MyLogger)←Initial dummy
...
   Config←CreateConfig ⍬
leanpub-start-insert   
   Config.ControlFileTieNo←CheckForOtherInstances ⍬
leanpub-end-insert   
   CheckForRide Config.(Ride WaitForRide)
...
∇
~~~

We want to untie the file as well. So far we have not paid any attention to how to close the application down properly, therefore we take the opportunity to introduce a function `Cleanup` which is doing that:

~~~
∇ {r}←Cleanup
   r←⍬   
   ⎕FUNTIE Config.ControlFileTieNo
   Config.ControlFileTieNo←⍬   
∇

:EndNamespace
~~~

Of course we have to call `Cleanup` from somewhere:

~~~
∇ {r}←StartFromCmdLine arg;MyLogger;Config;rc;⎕TRAP
 ...
   rc←TxtToCsv arg~''''
leanpub-start-insert      
   Cleanup
leanpub-end-insert      
   Off rc
∇
~~~

After all these changes it's time to execute our test cases. Execute `#.Tests.Run`.

Turns out that two of them fail! The reason: when we run `Test_exe_01` and `Test_exe_02` the control file is already tied. That's because `Test_TxtToCsv` runs first, and it calls `Initial` -- which ties the control file -- but not `Cleanup`, which would untie it. The fix is simple: we need to call `Cleanup` in the test. However, we can't just do this at the end of `Test_TxtToCsv_01`:

~~~
∇ R←Test_TxtToCsv_01(stopFlag batchFlag);⎕TRAP;rc
...
   →FailsIf rc≢##.MyApp.EXIT.SOURCE_NOT_FOUND
   #.MyApp.Cleanup ⍬
   R←∆OK
∇
~~~

If we do this then `Cleanup` would not be called in case the check fails. Let's do it properly instead:

~~~
∇ R←Test_TxtToCsv_01(stopFlag batchFlag);⎕TRAP;rc
...
   →GoToTidyUp rc≢##.MyApp.EXIT.SOURCE_NOT_FOUND                        
   R←∆OK                                                                
  ∆TidyUp:                                                              
   ##.MyApp.Cleanup ⍬                                                   
~~~

I> Note that we must call `MyApp.Cleanup` rather than just `Cleanup` because we are at that moment in `Tests`, and we don't want to execute `Tests.Cleanup`!

We can learn some lessons from the failure of those two test cases:

1. Obviously the sequence in which the test cases are executed can have an impact on whether tests fail or not. If `Test_TxtToCsv` would have been the last test case the problem would have slipped through undetected.

1. That a test suite runs through OK does not necessarily mean it will keep doing so when you execute it again.

In our specific case it was actually a problem in the test cases, _not_ in `MyApp`, but the conclusion holds true in any case.


## Create a Scheduled Task


### Start the Scheduler

Press the <Win> key and type Scheduler. Select "Task Scheduler" form the list. This is what will come up:

![The Windows Task Scheduler](images/scheduler_01.png)

First thing to check is that the contents of the black rectangle in the "Actions" pane on the right reads "Disable All Tasks History" - if it does not you won't be able to get any details regarding any Scheduled Task.

The arrow points to the "Create Task" command - click it.

![Create Task](images/scheduler_02.png)

#### The "General" tab

Name 
: Used in the list presented by the Task Scheduler.

Description
: Shown in the list presented by the Task Scheduler. Keep it concise.

Run only when user is logged on
: You will almost certainly change this to "Run whether user is logged on or not".

Do not store password
: The password is stored safely, so there is not really a reason not to provide it.

Running with highest privileges
: Unfortunately this check box is offered no matter whether your user account has admin rights or not. If it does not, then ticking the box won't make a difference at all.

: If your user account has no admin rights but your Scheduled Task needs to run with highest privileges then you need to specify a different user id / password after clicking the "Change user or group" button.

: Whether your application needs to run with higgest privileges or not is impossible to say. Experience shows that sometimes something that does not work when -- and only when -- the application is running as a Scheduled Task will work fine with highest privileges although it is by no means clear what those rights are required for.

Configure for
: Generally you should select the OS the task is running on.

A> ### UAC, admin rights and all the rest
A> 
A> With the UAC, users of the admin group have 2 tokens. The filtered token represents standard user rights. This token is used by default, for example when you create a shell (console). Therefore you have just standard user rights by default even when using a user account with admin rights. However, when you have admin rights and you click an EXE and select "run as administrator", the full token is used which contains admin rights.
A> 
A> Notes:
A> 
A> * Some applications ask for admin rights even when you do not right-click on the EXE and select "Run as administrator"; the Registry Editor and the Task Explorer are examples.
A> * Even if you run an application with admin rights (sometimes called "in elevated mode") it does not mean that the application can do whatever it likes, but as an admin you can always grab any missing rights.


#### The "Trigger" tab

The tab does not carry any mysteries.


#### The "Action" tab 

After clicking "New" this is what you get:

![New Action](images/scheduler_03.png)

Make sure that you use the "Browse" button to navigate to the EXE/BAT/whatever you want to run as a Scheduled Task. That avoids typos.

"Add arguments" allows you specify something like "maxws=345MB" or the name of a workspace in case "Program" is not an EXE but a Dyalog interpreter. In particular you should add `DYALOG_NOPOPUPS=1`. This prevents any dialogs from popping up (aplcore, WS FULL etc.). You don't want them when Dyalog is running in the background because there's nobody around to click the "OK" button...

"Start in" is useful for specifying what will become the current (or working) directory for the running program. We recommend to set the current directory from within your workspace, so you don't really need to set this here except that when you don't you might well get an error code 2147942512. We will discuss later how such error codes can be analyzed, but for the time being you have to believe us that it actually means "Not enough space available on the disk". When you do specify the "Start in" parameter it runs just fine. 

However, note that you _must not embrace_ the path with double-quotes. It's understandable that Microsoft does not require them in this context because by definition any blanks are part of the path, but why they do not just ignore them when specified is less understandable.


#### The "Conditions" tab

The tab does not carry any mysteries.


#### The "Settings" tab

Unless you have a very good reason not to you should "Allow task to be run on demand" which means you have the "Run" command available on the context menu.

Note that you may specify restart parameters in case the task fails. Whether that makes any sense at all depends on the application.

The combo box at the bottom allows you to select "Stop the existing instance" which can be quite useful while debugging the application.


### Running a Scheduled Task

To start the task right-click on it in the Task Scheduler and select "Run" from the context menu. Then check the log file. We have tested the application well, we know it works, so you should see a log file that contains something like this:

~~~
2017-03-31 10:03:35 *** Log File opened
2017-03-31 10:03:35 (0) Started MyApp in ...\code\v12\MyApp
2017-03-31 10:03:35 (0)  ...\code\v12\MyApp\MyApp.exe maxws=370MB
2017-03-31 10:03:35 (0)  Accents            ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ  AAAAAA...
2017-03-31 10:03:35 (0)  ControlFileTieNo   1 
2017-03-31 10:03:35 (0)  Debug              0 
2017-03-31 10:03:35 (0)  DumpFolder         C:\Users\kai\AppData\Local\MyApp\Errors 
2017-03-31 10:03:35 (0)  ForceError         0 
2017-03-31 10:03:35 (0)  LogFolder          C:\Users\kai\AppData\Local\MyApp\Log 
2017-03-31 10:03:35 (0)  Ride               0 
2017-03-31 10:03:35 (0)  Trap               1 
2017-03-31 10:03:35 (0) Source: maxws=370MB
2017-03-31 10:03:35 (0) *** ERROR RC=112; MyApp is unexpectedly shutting down: SOURCE_NOT_FOUND
~~~

Since we have not provided a filename, `MyApp` assumed that "maxws=370MB" would be the filename. Since that does not exist the application quits with a return code SOURCE_NOT_FOUND, which is exactly what we expected.

However, from experience we know that the likelihood of the task _not_ running as intended is high. We have already discussed some of the issues that might pop up, and we will now discuss some more we have enjoyed over the years.


## Tips, tricks, pitfalls.


### Riding into a Scheduled Task

If you want to Ride into a Scheduled Task and therefore set in the INI file the `[Ride]Active` flag to `1` and the Windows Firewall has yet no rules for this port and this application then you _won't_ see the usual message (assuming that you use a user id with admin rights) you expect to see when you run the application for the very first time:

![Windows Firewall](images\Firewall_01.jpg)

The application would start, seemingly run for a short period of time and then stop again without leaving any traces: no error codes, no log files, no crash files, nothing.

It is different when you simply double-click the `MyApp.exe`: in that case the "Security Alert" dialog box would pop up, giving you an easy way to create a rule that allows the application to communicate via the given port.

BTW, when you click "Cancel" in the "Security Alert" dialog box then you might expect that the Windows Firewall does not allow access to the port but wouldn't create a rule either, but you would be mistaken. The two buttons "Allow access" and "Cancel" shouldn't be buttons at all! Instead there should be a group "Create rule" with two radio buttons: "Allow access" and "Deny access". In case the user clicks the "Cancel" button a message should pop up saying that although no rule will be created, access to the port in question is denied. That would imply that when the application is started again the "Security Alert" dialog box would pop up again, too. Instead when "Cancel" is clicked a blocking rule for that combination of application and port number is created, and you will not see that dialog box again for this combination.


### The Task Scheduler GUI

Once you have executed the "Run" command from the context menu the GUI changes the status from "Ready" to "Running". That's fine. Unfortunately it won't change automatically back to "Ready" once the job has finished, at least not at the time of writing (2017-03) under Windows 10. For that you have to press F5.


### Re-make "MyApp"

In case you've found a bug and execute `MyApp`'s `Make.bat` again keep in mind that this means the INI file will be overwritten. So in case you've changed, say, Ride's `Active` flag in the INI file from `0` to `1`, it will be `0` again after the call too `Make.bat`, so any attempt to Ride into the EXE will fail. That's something easy to forget.


### MyApp crashes with rc=32

You most probably forgot to copy over the DLLs needed by Ride [^ride] itself. That's what triggers the return code 32 which stands for "File not find".

A> ### Windows return codes
A> 
A> In case you want to translate a Windows return code like 32 into a more meaningful piece of information you might consider downloading the user command `GetMsg`. Once installed properly you can do this:
A> 
A> ~~~
A>       ]GetMsgFrom 32
A> The process cannot access the file because it is being used by another process.
A> ~~~
A>
A> However, Microsoft being Microsoft, the error messages are not always that helpful. The above message is issued in case you try to switch on Ride in an application and the interpreter cannot find the DLLs needed by Ride.


### Binding MyAPP with the Dyalog development EXE

If for some reason you've created `MyApp.exe` by binding the application with the development version of Dyalog rather than the Runtime (you can do this by providing a 0 as left argument to the `MakeExport` function) then you might run into a problem: Our code takes into account whether it is running under a development EXE or a runtime EXE: error trapping will be inactive (unless it is enforced via the INI file) and `⎕OFF` won't be executed; instead it would execute `→` and hang around but without you being able to see the session. Therefore you are advised not to do this: because you have Ride at your disposal the development version of Dyalog has no advantages over the runtime EXE anyway.


### Your application doesn't do what it's supposed to do

... but only when running as a task. Start the Task Scheduler and go to the "History" tab; if this is empty then you have not clicked at "Enable all tasks history" as suggested earlier. Don't get fooled by "Action completed" and "Task completed" - whether a task failed or not does not become apparent this way. Click at "Action completed": at the bottom you get information regarding that run. You might read something like:

"Task Scheduler successfully completed task "\MyApp" , instance "{c7cb733a-be97-4988-afca-a551a7907918}" , action "...\code\v12\MyApp\MyApp.exe" with return code 2147942512."

That tells you that the task did not run at all. Consequently you won't find either a log file or a crash file, and you cannot Ride into the application.


### Task Scheduler error codes

In case the Task Scheduler itself throws an error you will find them of little value at first sight. You can provoke such an error quite easily: edit the task we've created and change the contents of the "Program/script" field in the "Edit action" dialog to something that does not exist, meaning that the Task Scheduler won't find such a program. Then issue the "Run" command from the context menu.

Update the GUI by pressing F5 and you will see that errors are reported. The row that reads "Task Start Failed" in the "Task Category" columns and "Launch Failure" in the "Operational Code" columns is the one we are interested in. When you click at this row you will find that it reports an "Error Value 2147942402". What exactly does this mean?

One way to find out is to google for 2147942402. For this particular error this will certainly do, but sometimes you will have to go through plenty of pages when people managed to produce the same error code in very different circumstances, and it can be quite time consuming to find a page that carries useful information for _your_ circumstances.

Instead we use the user command [^hex] `Int2Hex` which is based on code written and contributed by Phil Last [^last]. With this user command we can convert the value 2147942402 into a hex value:

~~~
      ]Int2Hex 2147942402
80070002
~~~

A> ### Third-party user commands
A> 
A> Naturally there are quite a number of useful third-party user commands available. For details how to install them see Appendix 2.

Now the first four digits, 8007, mean that what follows is a win32 status code. The last 4 are the status code. This is a  number that needs to be converted into decimal:

~~~
      ]Hex2Int 0002
~~~

but in our case that is of course not necessary because the number is so small that there is no difference between hex and integer anyway, so we can convert it into an error message straight away. Again we use a user command that is not part of a standard Dyalog installation but because it is so useful we strongly recommend to install this as well [^getmsg]; it translates any Windows error code into meaningful text.

~~~
      ]GetMsgFrom
The system cannot find the file specified.      
~~~

That's the reason why it failed.


## Creating tasks programmatically

It is possible to create Scheduled Tasks by a program, although this is beyond the scope of this book. See

<https://msdn.microsoft.com/en-us/library/windows/desktop/bb736357(v=vs.85).aspx>

for details.


[^ride]: This topic was discussed in the chapter "Debugging a stand-alone EXE"

[^last]: <http://aplwiki.com/PhilLast>

[^hex]: For details and download regarding the user commands `Hex2Int` and `Int2Hex` see <http://aplwiki.com/UserCommands/Hex>

[^getmsg]: For details and download regarding the user command `GetMsgFrom` see <http://aplwiki.com/UserCommands/GetMsgFrom>