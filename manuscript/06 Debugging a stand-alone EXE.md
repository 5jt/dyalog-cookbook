{:: encoding="utf-8" /}
[parm]:title='Debugging'

# Debugging a stand-alone EXE

Imagine the following situation: when MyApp is started with a double-click on the DYAPP and then tested everything works just fine. When you create a stand-alone EXE from the DYAPP and execute it with some appropriate parameter it does not create the CSV files. In this situation obviously you need to debug the EXE. In this chapter we'll discuss how to achieve that. In addition we will make `MyApp.exe` return an exit code. 

For debugging we are going to use Ride. (If you don't know what Ride is refer to the documentation) If enabled you can use Ride to hook into a running interpreter, interrupt any running code, investigate and even change that code.


## Configuration settings

We introduce a `[RIDE]` section into the INI file:

~~~
[Ride]
Active      = 1
Port        = 4599
Wait        = 1
~~~

By setting `Active` to 1 and defining a `Port` number for the communication between Ride and the EXE you can tell MyApp that you want "to give it a ride". Setting `Wait` to 1 lets the application wait for a ride. That simply means it enters an endless loop.

That's not always appropriate of course, because it allows anybody to read your code. If that's something you have to avoid then you have to find other ways to make the EXE communicate with Ride, most likely by making temporary changes to the code. The approach would be in both cases the same. In MyApp we keep things simple and allow the INI file to rule whether the user may ride into the application or not.

Copy `Z:\code\v05` to `Z:\code\v06` and then run the DYAPP to recreate the `MyApp` workspace. 

I>Note that 4502 is Ride's default port, and that we've settled for a different port, and for good reasons. Using the default port leaves room for mistakes. Using a dedicated port rather than just using the default minimises the risk of connecting with the wrong application.


## The "Console application" flag

In case you've exported the EXE with the "console application" check box ticked there is a problem: although you will be able to connect to the EXE with Ride, all output goes into the console window. That means that you can enter statements in Ride but any response from the interpreter goes to the console window rather than Ride.

For debugging purposes it is therefore recommended to create the EXE with the check box unticked.


## Code changes

### Making Ride configurable

We want to make the ride configurable. That means we cannot do it earlier than after having instantiated the INI file. But not long after either, so we change `Initial`:

~~~
∇ (Config MyLogger)←Initial dummy
⍝ Prepares the application.
  #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
  Config←CreateConfig ⍬
leanpub-start-insert  
  CheckForRide Config.(Ride WaitForRide)
leanpub-end-insert  
  MyLogger←OpenLogFile Config.LogFolder
  MyLogger.Log'Started MyApp in ',F.PWD   
  MyLogger.Log #.GetCommandLine
  MyLogger.Log↓⎕FMT Config.∆List
∇
~~~    

We have to make sure that `Ride` makes it into `Config`, so we establish a default 0 (no Ride) and overwrite with INI settings.

~~~
∇ Config←CreateConfig dummy;myIni;iniFilename
  Config←⎕NS''
  Config.⎕FX'r←∆List' 'r←{0∊⍴⍵:0 2⍴'''' ⋄ ⍵,[1.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2'
  Config.Debug←A.IsDevelopment
  Config.Trap←1
  Config.Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'
  Config.LogFolder←'./Logs'
  Config.DumpFolder←'./Errors'
leanpub-start-insert
  Config.Ride←0        ⍝ If not 0 the app accepts a Ride & treats Config.Ride as port number.
  Config.WaitForRide←0 ⍝ If 1 `CheckForRide` will enter an endless loop.
leanpub-end-insert
  iniFilename←'expand'F.NormalizePath'MyApp.ini'
  :If F.Exists iniFilename
      myIni←⎕NEW ##.IniFiles(,⊂iniFilename)
      Config.Debug{¯1≡⍵:⍺ ⋄ ⍵}←myIni.Get'Config:debug'
      Config.Trap←⊃Config.Trap myIni.Get'Config:trap'
      Config.Accents←⊃Config.Accents myIni.Get'Config:Accents'
      Config.LogFolder←'expand'F.NormalizePath⊃Config.LogFolder myIni.Get'Folders:Logs'
      Config.DumpFolder←'expand'F.NormalizePath⊃Config.DumpFolder myIni.Get'Folders:Errors'
leanpub-start-insert
      :If myIni.Exist'Ride'
      :AndIf myIni.Get'Ride:Active'
          Config.Ride←⊃Config.Ride myIni.Get'Ride:Port'
          Config.WaitForRide←⊃Config.Ride myIni.Get'Ride:Wait'
      :EndIf
leanpub-start-insert
  :EndIf
  Config.LogFolder←'expand'F.NormalizePath Config.LogFolder
  Config.DumpFolder←'expand'F.NormalizePath Config.DumpFolder
∇
~~~

### Allowing a Ride

We add a function `CheckForRide`:

~~~
∇ {r}←CheckForRide (ridePort waitFlag);rc;init;msg
 ⍝ Depending on what's provided as right argument we prepare for a Ride 
 ⍝ or we don't. In case `waitFlag` is 1 we enter an endless loop.
  r←1
  :If 0<ridePort
      {}3502⌶0                     ⍝ Switch Ride off
      init←'SERVE::',⍕ridePort     ⍝ Initialisation string
      rc←3502⌶ini                  ⍝ Specify INIT string
      :If 32=rc
          11⎕Signal⍨'Cannot Ride: Conga DLLs are missing'
      :ElseIf 64=rc
          11 ⎕Signal⍨'Cannot Ride; invalid initialisation string: ',ini
      :ElseIf 0≠rc
          msg←'Problem setting the Ride connecion string to SERVE::'
          msg,←,(⍕ridePort),', rc=',⍕rc
          11 ⎕SIGNAL⍨msg
      :EndIf
      rc←3502⌶1
      :If ~rc∊0 ¯1
          11 ⎕SIGNAL⍨'Switching on Ride failed, rc=',⍕rc
      :EndIf
      {}{_←⎕DL ⍵ ⋄ ∇ ⍵}⍣(⊃waitFlag)⊣1  ⍝ Endless loop for an early RIDE
  :EndIf
∇
~~~

Notes:

* `ridePort` will be either the port to be used for communicating with Ride or 0 if no Ride is required.

* The optional left argument defaults to 0. If it is 1 then the function waits for Ride to hook on.

* In this specific case we pass a reference to `Config` as argument to `CheckForRide`. There are two reasons for that:
  * `CheckForRide` really needs `Config`.
  * We have nothing else to pass but we don't want to have niladic functions around (except in very special circumstances).

* We catch the return codes from the calls to `3502⌶` and check them on the next line. This is important because the calls may fail for several reasons; see below for an example. In case something goes wrong the function signals an error.

* With `3502⌶0` we switch Ride off, just in case. That way we make sure that we can execute `→1` while tracing `CheckForRide` at any point if we wish to; see "Restartable functions" underneath this list.

* With `3502⌶'SERVE::',⍕ridePort` we establish the Ride parameters: type ("SERVE"), host (nothing between the two colons, so it defaults to "localhost") and port number.

* With `3502⌶1` we enable Ride.

* With `{_←⎕DL ⍵ ⋄ ∇ ⍵}1` we start an endless loop: wait for a second, then calls itself (`∇`) recursively. It's a dfn, so there is no stack growing on recursive calls.

* We could have passed `Config` rather than `Config.(Ride WaitForRide)` to `CheckForRide`. By _not_ doing this we allow the function `CheckForRide` to be tested independently from `Config`. This is an important point. There is value in keeping the function independent in this way, but if you suspect that later you will most likely be in need for other parameters in `Config` then the flexibility you gain this way outperforms the value of keeping the function independent from `Config`. 

Finally we amend the `Version` function:

~~~
∇r←Version
   ⍝ * 1.3.0:
   ⍝   * MyApp gives a Ride now, INI settings permitted.
   ...
∇   
~~~

Now you can start Ride, enter both "localhost" and the port number as parameters, connect to the interpreter or stand-alone EXE etc. and then select "Strong interrupt" from the "Actions" menu in order to interrupt the endless loop; you can then start debugging the application. Note that this does not require the development EXE to be involved: it may well be a runtime EXE. However, of course you need a development license in order to be legally entitled to Ride into an application run by the RunTime EXE (DyalogRT.exe).

A> # DLLs required by Ride
A>
A> Prior to version 16.0 one had to copy the files "ride27_64.dll" (or "ride27_32.dll") and "ride27ssl64.dll" (or "ride27ssl32.dll") so that they are siblings of the EXE. From 16.0 onward you must copy the Conga DLLs instead. 
A>
A> Failure in doing that will make `3502⌶1` fail. Note that "2.7" refers to the version of Conga, not Ride. Prior to version 3.0 of Conga every application (interpreter, Ride, etc.) needed to have their own copy of the Conga DLLs, with a different name. Since 3.0 Conga can serve several applications in parallel. We suggest that you copy the 32-bit and the 64-bit DLLs over to where your EXE lives.
A>
A> In case you forgot to copy "ride27ssl64.dll" and/or "ride27ssl32.dll" then you will see an error "Can't find Conga DLL". This is because the OS does not bother to tell you about dependencies. You need a tool like DependencyWalker for finding out what's really missing. Note that we said "OS" because this is _not_ a Windows-only problem.


A> # Restartable functions
A> 
A> Not only do we try to exit functions at the bottom, we also like them to be "restartable". What we mean by that is that we want a function -- and its variables -- to survive `→1`whenever that is possible; sometimes it is not like a function that starts a thread and _must not_ start a second one for the same task, or a file was tied etc. but most of the time it is possible to achieve that. 
A>
A> That means that something like this should be avoided:
A>
A> ~~~
A> ∇r←MyFns arg
A> r←⍬
A> :Repeat
A>     r,← DoSomethingSensible ⊃arg
A> :Until 0∊⍴arg←1↓arg
A> ~~~
A> 
A> This function does not make much sense but the point is that the right argument is mutilated; one cannot restart this function with `→1`. Don't do something like that unless there are very good reasons. In this example a counter is a better way to do this. It's also faster.








































*[HTML]: Hyper Text Mark-up language
*[DYALOG]: File with the extension 'dyalog' holding APL code
*[TXT]: File with the extension 'txt' containing text
*[INI]: File with the extension 'ini' containing configuration data
*[DYAPP]: File with the extension 'dyapp' that contains 'Load' and 'Run' commands in order to compile an APL application
*[EXE]: Executable file with the extension 'exe'
*[BAT]: Executeabe file that contains batch commands
*[CSS]: File that contains layout definitions (Cascading Style Sheet)
*[MD]: File with the extension 'md' that contains markdown
*[CHM]: Executable file with the extension 'chm' that contains Windows Help(Compiled Help) 
*[DWS]: Dyalog workspace
*[WS]: Short for Workspaces