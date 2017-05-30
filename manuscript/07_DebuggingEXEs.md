{:: encoding="utf-8" /}

# Debugging a stand-alone EXE

Imagine the following situation: when MyApp is started with a double-click on the DYAPP and then tested everything works just fine. When you create a stand-alone EXE from the DYAPP and execute it with some appropriate parameter it does not create the CSV files. In this situation obviously you need to debug the EXE. In this chapter we'll discuss how to achieve that.

In addition we will make `MyApp.exe` return an exit code. 


## Configuration settings

In the INI file we have already a `[Ride]` section. By setting `Active` to 1 and defining a `Port` number for the communication between Ride and the EXE (4502 is Ride's default port) you can tell MyApp that you want "to give it a ride".

That's not always appropriate of course, because it allows anybody to jump into your code. If that's something you have to avoid then you have to find other ways to make the EXE communicate with Ride, most likely by making temporary changes to the code. The approach would be in both cases the same.

In MyApp we keep things simple and allow the INI file to rule whether the user may Ride into the application or not.

Copy `Z:\code\v05` to `Z:\code\v06` and then run the DYAPP to recreate the `MyApp` workspace. 


## The "Console application" flag

In case you've exported the EXE with the "console application" check box ticked there is a problem: although you will be able to connect to the EXE with Ride, all output goes into the console window. That means that you can enter statements in Ride but any response from the interpreter goes to the console window rather than Ride.

For debugging purposes it is therefore recommended to recreate the EXE with the check box unticked. As mentioned in the 


## INI file changes

Don't forget to change the Ride parameters:

~~~
[Ride]
Active      = 1
Port        = 4502
~~~


## Code changes

We want to make the Ride configurable. That means we cannot do it earlier than after having instantiated the INI file. But not long after either, so we change `Initial`:

~~~
∇ (Config MyLogger)←Initial dummy
⍝ Prepares the application.
  #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
  Config←CreateConfig ⍬
  CheckForRide (0≠Config.Ride) Config.Ride
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
  Config.Ride←0      ⍝ If not 0 the app accepts a Ride (Config.Ride = port number)
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
      :EndIf
leanpub-start-insert
  :EndIf
  Config.LogFolder←'expand'F.NormalizePath Config.LogFolder
  Config.DumpFolder←'expand'F.NormalizePath Config.DumpFolder
∇
~~~

We add a function `CheckForRide`:

~~~
 ∇ {r}←{wait}CheckForRide (rideFlag ridePort);rc
  ⍝ Depending on what's provided as right argument we prepare
  ⍝ for a Ride or we don't.
    r←1
    wait←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'wait'
    :If rideFlag 
        rc←3502⌶0
        :If ~rc∊0 ¯1
            11 ⎕SIGNAL⍨'Problem switching off Ride, rc=',⍕rc
        :EndIf
        rc←3502⌶'SERVE::',ridePort
        :If 0≠rc
            11 ⎕SIGNAL⍨'Problem setting the Ride connecion string to SERVE::',(⍕ridePort),', rc=',⍕rc
        :EndIf
        rc←3502⌶1
        :If ~rc∊0 ¯1
            11 ⎕SIGNAL⍨'Problem switching on Ride, rc=',⍕rc
        :EndIf
        {_←⎕DL ⍵ ⋄ ∇ ⍵}⍣(⊃wait)⊣⍬
    :EndIf
 ∇
~~~

* The optional left argument defaults to 0. If it is 1 then the function waits for Ride to hook on.
* `rideFlag` determines whether the function takes action (1) or not (0).
* `ridePort` defines the port to be used for communicating with Ride.
* In case something goes wrong the function signals an error.
* For principle reasons the function first tries to disable Ride. This allows a restart of the application without any further ado. It then specifies the port and then it activates Ride.
* Finally, in case `⍺` was 1, an endless loop is entered. In case you are worried about the status indicator because the loop if established as a recursive call: recursive dfn calls do not have an impact on the status indicator.

Finally we amend the `Version` function:

~~~
∇r←Version
   ⍝ * 1.3.0:
   ⍝   * MyApp gives a Ride now, INI settings permitted.
   ...
∇   
~~~

Notes:

* In this case we pass a reference to `Config` as argument to `CheckForRide`. There are two reasons for that:
  * `CheckForRide` really needs `Config`.
  * We have nothing else to pass but we don't want to have niladic functions around (except in very special circumstances).
  
* If `Ride` is 0 we don't give a ride, but if it's not, then it's treated as a port number.

* We catch the return codes from the calls to `3502⌶` and check them on the next line. This is important because the calls may fail for several reasons; see below for an example.

* With `3502⌶0` we switch Ride off, just in case. That way we make sure that we can execute `→1` while tracing `CheckForRide` at any point if we wish to; see "Restartable functions" underneath this list.

* With `3502⌶'SERVE::',⍕Config.Ride` we establish Ride parameters: host (nothing between the two colons, so it defaults to "localhost") and port number.

* With `3502⌶1` we enable Ride.

* With `{_←⎕DL ⍵ ⋄ ∇ ⍵}1` we start an endless loop: wait for a second, then call the function again recursively. Its a dfn, so there is no stack growing on recursive calls.

Now you can start Ride, enter "localhost" and the port number as parameters, connect to the interpreter or stand-alone EXE etc. and then select "Strong interrupt" from the "Actions" menu in order to interrupt the endless loop; you can then start debugging the application. Note that this does not require the development EXE to be involved: it may well be a runtime EXE. However, you need of course a development license in order to be legally entitled to do this.

T> Prior to version 16.0 one had to copy the files "ride27_64.dll" (or "ride27_32.dll") and "ride27ssl64.dll" (or "ride27ssl32.dll") so that they are siblings of the EXE. From 16.0 onwards you must copy the Conga DLLs instead. Failure in doing that will make `3502⌶1` fail. Note that "2.7" refers to the version of Conga, not Ride. Prior to version 3.0 of Conga every application (interpreter, Ride, etc.) needed to have their own copy of the Conga DLLs, with a different name. Since 3.0 Conga can serve several applications in parallel.

A> ### Restartable functions
A> 
A> Not only do we try to exit functions at the bottom, we also like them to be "restartable". What we mean by that is that we want a function -- and its variables -- to survive `→1`. This is not always possible, for example when a function starts a thread and must not start a second one for the same task, or a file was tied etc. but most of the time it is possible to achieve that. That means that something like this must be avoided:
A>
A>~~~
A> ∇r←MyFns arg
A> r←⍬
A> :Repeat
A>     r,← DoSomethingSensible ⊃arg
A> :Until 0∊⍴arg←1↓arg
A>~~~
A> 
A> This function does not make much sense but the point is that the right argument is mutilated; one cannot restart this function with `→1`. Don't do something like that!