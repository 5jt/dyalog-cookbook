{:: encoding="utf-8" /}

# Debugging a stand-alone EXE

Imagine the following situation: when MyApp is started with a double-click on the DYAPP and then tested everything works just fine. When you create a stand-alone EXE from the DYAPP and execute it with some appropriate parameter it does not create the CSV files. In this situation obviously you need to debug the EXE. In this chapter we'll discuss how to achieve that.


## Configuration settings

In the INI file we have already a `[Ride]` section. By setting `Active` to 1 and defining a `Port` number for the communication between Ride and the EXE (4502 is Ride's default port) you can tell MyApp that you want "to give it a ride".

That's not always appropriate of course, because it allows anybody to jump into your code. If that's something you have to avoid then you have to find other ways to make the EXE communicate with Ride, most likely by making temporary changes to the code. The approach would be in both cases the same.

In MyApp we keep things simple and allow the INI file to rule whether the user may Ride into the application or not.

Copy v05 to v06.


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
∇ (G MyLogger)←Initial dummy
⍝ Prepares the application.
⍝ Side effect: creates `MyLogger`, an instance of the `Logger` class.
  #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
  G←CreateGlobals ⍬
leanpub-start-insert  
  CheckForRide G
leanpub-end-insert  
  MyLogger←OpenLogFile G.LogFolder
  MyLogger.Log↓⎕FMT G.∆List
∇
~~~    

We have to make sure that `Ride` makes it into `G`, so we establish a default 0 (no Ride) and overwrite with INI settings.

~~~
∇ G←CreateGlobals dummy;myIni;iniFilename
⍝ Create a namepsace `G` and populate it with defaults.
  G←⎕NS''
  ...  
  G.Ride←0  ⍝ If this is not 0 the app accepts a Ride & treats G.Ride as port number
  ...
      :If myIni.Exist'Ride'
      :AndIf myIni.Get'Ride:Active'
          G.Ride←⊃G.Ride myIni.Get'Ride:Port'
      :EndIf
  :EndIf
  ...
∇
~~~

Finally we add a function `CheckForRide`:

~~~
∇ {r}←CheckForRide G
⍝ Checks whether the user wants to have a Ride and if so make it possible.
  r←⍬
  :If 0≠G.Ride
      rc←3502⌶0
      {0=⍵:r←1 ⋄ ⎕←'Problem! rc=',⍕⍵ ⋄ .}rc
      rc←3502⌶'SERVE::',⍕G.Ride
      {0=⍵:r←1 ⋄ ⎕←'Problem! rc=',⍕⍵ ⋄ .}rc
      rc←3502⌶1
      {0=⍵:r←1 ⋄ ⎕←'Problem! rc=',⍕⍵ ⋄ .}rc
      {_←⎕DL ⍵ ⋄ ∇ ⍵}1
  :EndIf
∇
~~~

Notes:

* In this case we pass a reference to `G` as argument. There are two reasons for that:
  * `CheckForRide` really needs `G`.
  * We have nothing else to pass but we don't want to have niladic functions around (except very special circumstances).
  
* If `Ride` is 0 we don't give a ride but if it's not then it's treated as a port number.

* We catch the return codes from the calls to `3502⌶` and check them on the next line. This is important because the calls may fail for several reasons; see below for an example.

* With `3502⌶0` we switch Ride off, just in case. (That way we make sure that we can execute `→1` at any point if we wish to)

* With `3502⌶'SERVE::',⍕G.Ride` we establish Ride parameters: host (nothing between the two colons, so it defaults to localhost) and port number.

* With `3502⌶1` we enable Ride.

* With `{_←⎕DL ⍵ ⋄ ∇ ⍵}1` we start an endless loop: delay for a second, then call the function again. Its a dfn, so there is no stack growing on recursive calls.

Now you can start Ride, enter "localhost" and the port number as parameters, connect to the interpreter or stand-alone EXE etc. and then select "Strong interrupt" from the "Actions" menu in order to interrupt the endless loop; you can then start debugging the application.

T> Prior to version 16.0 one had to copy the files "ride27_64.dll" (or "ride27_32.dll") and "ride27ssl64.dll" (or "ride27ssl32.dll") so that they are siblings of the EXE. From 16.0 onwards you must copy the Conga DLLs instead. Failure in doing that will make `3502⌶1` fail. Note that "2.7" refers to the version of Conga, not Ride. Prior to version 3.0 of Conga every application (interpreter, Ride, etc.) needed to have their own copy of the Conga DLLs. Since 3.0 Conga can serve several applications in parallel.