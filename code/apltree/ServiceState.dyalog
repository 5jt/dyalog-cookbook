:Namespace ServiceState
⍝ This namespace provides an interface between an APL application designed
⍝ to run as a service and the Windows Service Control Manager (SCM). The
⍝ SCM is sending messages which are caught by the `ServiceState.OnServiceHandler`
⍝ callback which is in turn expected to respond to those messages reasonably.
⍝
⍝ `ServiceState` offers all sorts of functions but normally the user will call just:
⍝ * `ServiceState.CreateParmSpace`
⍝ * `ServiceState.Ini`
⍝ * `ServiceState.CheckServiceMessages`
⍝
⍝ Run `##.ServiceState.Init` to get started. You can either specify an empty
⍝ right argument (if you are happy with the defaults) or a parameter
⍝ space. It is suggested to create a parameter space by calling:
⍝ ~~~
⍝ ps←##.ServiceState.CreateParmSpace
⍝ ~~~
⍝ You can then change the defaults. Call
⍝ ~~~
⍝ ps.∆List
⍝ ~~~
⍝ for a list of all defaults. Finally pass the parameter space as right argument
⍝ to `Init`.
⍝
⍝ Note that `Init` establishes `##.ServiceState.OnServiceHandler` as the
⍝ callback function for state changes requested by SCM. This callback will
⍝ set internally a variable which indicates what state is requested by the SCM.
⍝
⍝ The application is supposed to check whether a state change is required and if that
⍝ is the case to take an appropriate action and finally signal back to the SCM that 
⍝ the state has been changed as requested.
⍝
⍝ All this can be achieved by calling the operator `CheckServiceMessages`, typically
⍝ in the main loop of the application. The operator takes a log function as operand
⍝ and a flag that indicates whether the application is running as a service (you can call
⍝ `##.ServiceState.IsRunningAsService` for this), no further actions are required.\\
⍝ All this in a single function (not recommended but as an example):
⍝ ~~~
⍝ ∇ {r}←Run dummy;S
⍝   r←⍬
⍝   parms←#.ServiceState.CreateParmSpace
⍝   parms.logFunction←'Log'
⍝   S←#.ServiceState
⍝   S.Init parms
⍝   :Repeat
⍝       ⎕DL 1
⍝       :If (Log S.CheckServiceMessages)S.IsRunningAsService
⍝           :Leave
⍝       :EndIf
⍝       Workhorse ⍬
⍝   :Until 0
⍝   S.Off 0
⍝ ~~~
⍝ This assumes that `Log` is a function that takes a text vector or a vector of text vectors
⍝ as right argument and writes them to a log file.\\
⍝ Notes:
⍝ * Any request to "Pause" (as well as "Continue") will be handled within `CheckServiceMessages`.
⍝ * `CheckServiceMessages` return a 1 in case a "Stop" is requested and a 0 otherwise.
⍝
⍝ Note that with version 1.6 the `ride` parameter was removed from `ServiceState`. The
⍝ reason for this was two-fold:
⍝ * When a service does not start it's too late - you have to ride into the service
⍝   asap.
⍝ * When you want to debug a problem within the application then the application should
⍝   give you a ride, not `ServiceState`.
⍝
⍝ That's why this feature was removed from `ServcieState`.
⍝
⍝ Needs Dyalog 14.0 or better.\\
⍝ Kai Jaeger ⋄ APL Team Ltd\\

    ⎕IO←⎕ML←1

    ∇ r←Version
      :Access Public Shared
      r←({⍵↑⍨-¯1+'.'⍳⍨⌽⍵}⍕⎕THIS)'1.7.0' '2018-02-19'
    ∇

    ∇ History
    :Access Public Shared
      ⍝ * 1.7.0:
      ⍝   * Converted from the APL wiki to GitHub
      ⍝ * 1.6.0:
      ⍝   * `timeout` reduced from 10 to 5 seconds. 10 seconds may result in Windows
      ⍝      error messages.
      ⍝   * Method `Off` added.
      ⍝   * Messages written to the log file are now clear about what is requested.
      ⍝   * The option to allow the user a Ride was removed from `ServiceState`.
      ⍝   * Testcases's `Initial` now indicates success via the result (admin rights!),
      ⍝   * Function `History` introduced.
      ⍝   * Typos in documentation fixed.
      ⍝   * Now managed by acre 3.
      ⍝ * 1.5.0:
      ⍝   * Bug fix: the "ride" parameter worked with 14.1 and earlier only.
      ⍝ * 1.4.0:
      ⍝   * Requires at least Dyalog 15.0 Unicode.
      ⍝ * 1.3.0: Doc converted to Markdown (requires at least ADOC 5.0).
    ∇

    ∇ r←SERVICE_CONTINUE_PENDING
      r←5
    ∇
    ∇ r←SERVICE_CONTROL_CONTINUE
      r←3
    ∇
    ∇ r←SERVICE_CONTROL_DEVICEEVENT
      r←11
    ∇
    ∇ r←SERVICE_CONTROL_HARDWAREPROFILECHANGE
      r←12
    ∇
    ∇ r←SERVICE_CONTROL_INTERROGATE
      r←4
    ∇
    ∇ r←SERVICE_CONTROL_NETBINDADD
      r←7
    ∇
    ∇ r←SERVICE_CONTROL_NETBINDDISABLE
      r←10
    ∇
    ∇ r←SERVICE_CONTROL_NETBINDENABLE
      r←9
    ∇
    ∇ r←SERVICE_CONTROL_NETBINDREMOVE
      r←8
    ∇
    ∇ r←SERVICE_CONTROL_PARAMCHANGE
      r←6
    ∇
    ∇ r←SERVICE_CONTROL_PAUSE
      r←2
    ∇
    ∇ r←SERVICE_CONTROL_POWEREVENT
      r←13
    ∇
    ∇ r←SERVICE_CONTROL_PRESHUTDOWN
      r←15
    ∇
    ∇ r←SERVICE_CONTROL_SESSIONCHANGE
      r←14
    ∇
    ∇ r←SERVICE_CONTROL_SHUTDOWN
      r←5
    ∇
    ∇ r←SERVICE_CONTROL_STOP
      r←1
    ∇
    ∇ r←SERVICE_PAUSED
      r←7
    ∇
    ∇ r←SERVICE_PAUSE_PENDING
      r←6
    ∇
    ∇ r←SERVICE_RUNNING
      r←4
    ∇
    ∇ r←SERVICE_START_PENDING
      r←2
    ∇
    ∇ r←SERVICE_STOPPED
      r←1
    ∇
    ∇ r←SERVICE_STOP_PENDING
      r←3
    ∇
    ∇ r←continue
      r←3
    ∇
    ∇ r←pause
      r←2
    ∇
    ∇ r←running
      r←5
    ∇
    ∇ r←start
      r←4
    ∇
    ∇ r←stop
      r←1
    ∇

    ∇ {r}←Init ps;ps2;allowed
    ⍝ Initialize `ServiceState`.\\
    ⍝ `ps` can be empty or a parameter space, typically created by calling `CreateParmSpace`.
      r←⍬
      ps2←CreateParmSpace
      :If 326=⎕DR ps
          allowed←'logFunction' 'logFunctionParent' 'timeout' 'eventQuitDQ'
          'Invalid parameter'⎕SIGNAL 11/⍨~∧/(' '~¨⍨↓ps.⎕NL 2 9)∊allowed
          ps2.{⍵{⍵{⍎⍺,'←⍵'}¨⍺.⍎¨⍵}⍵.⎕NL-2 9}ps  ⍝ Merge
      :EndIf
      ⎕THIS.{⍵{⍵{⍎⍺,'←⍵'}¨⍺.⍎¨⍵}⍵.⎕NL-2 9}ps2   ⍝ Set globals
      currentState←SERVICE_RUNNING
      requestedState←⍬
      '#'⎕WS'Event'eventQuitDQ 1    ⍝ To quit any ⎕DQ - we want be able to quit
      :If ~0∊⍴logFunction
          :If ⍬≡logFunctionParent
              _logFunction←⍎logFunction
          :Else
              _logFunction←logFunctionParent.⍎logFunction
          :EndIf
      :Else
          _logFunction←{⍬}
      :EndIf
      '#'⎕WS'Event' 'ServiceNotification'((⍕⎕THIS),'.OnServiceHandler')
     ⍝Done
    ∇

    ∇ {r}←ConfirmStateChange dummy
     ⍝ Use this to confirm that the app is happy with the state change.\\
     ⍝ Right argument is ignored.
      r←⍬
      currentState←requestedState
    ∇

    ∇ r←ShallServicePause
    ⍝ Boolean: returns 1 if the state is supposed to become "paused".
      r←SERVICE_PAUSED≡requestedState
    ∇

    ∇ r←ShallServiceContinue
    ⍝ Boolean: returns 1 if `States.requestedState` is no longer "paused".\\
    ⍝ That does not mean that it is "continue" or "running" because the
    ⍝ user may have chosen to stop the paused service.
      r←SERVICE_PAUSED≢requestedState
    ∇

    ∇ r←ShallServiceQuit
    ⍝ Boolean: returns 1 if the service is supposed to stop.
      r←requestedState≡SERVICE_CONTROL_STOP
      r←r∨SERVICE_CONTROL_SHUTDOWN≡requestedState
    ∇

    ∇ {r}←WaitForContinue dummy
    ⍝ Returns always `⍬`.\\
    ⍝ Consider calling this in case ShallServicePause has returned a 1 and you don't
    ⍝ have to do any particular gymnastics but just want to wait for a state change.\\
    ⍝ It just waits until the status changes, although not necessarily to "continue".\\
    ⍝ However, when the state changes then `currentState` is set to SERVICE_RUNNING
    ⍝ no matter which state was requested. Therefore another check for "Stop" is
    ⍝ required afterwards.
      r←⍬
      :While 0=ShallServiceContinue
          ⎕DL 1
      :EndWhile
      currentState←SERVICE_RUNNING
    ∇

    ∇ r←WaitForStateChange timeout
    ⍝ Waits until the application confirms the requested state or the time out jumps in.\\
    ⍝ Returns 0 when achieved but 1 in case of a time out.\\
    ⍝ This fns is called by the callback processing the messages
    ⍝ send from the Windows Service Control Manager (SCM).
      r←0
      :While 0≤timeout←timeout-1
          :If requestedState≡currentState
              :Return
          :EndIf
          ⎕DL 1
      :EndWhile
      r←1
    ∇

    ∇ {r}←(_logFunction CheckServiceMessages)isRunningAsService
    ⍝ Checks whether a "Pause" or a "Stop" message has arrived from the
    ⍝ Service Control Manager (SCM). Waits for resume and also logs all
    ⍝ events. Sends an `eventQuitDQ` event to `#` in case of a "Stop".\\
    ⍝ `_logFunction` must be the name of a monadic function returning a result;
    ⍝ purpose is to log events. `{⍬}` will do if you don't log anything.\\
    ⍝ Returns 1 for "Stop" and 0 otherwise.
      r←0
      :If isRunningAsService
          :If ShallServicePause
              ConfirmStateChange ⍬
              {}_logFunction{0::⍬ ⋄ ⍬⊣⍺⍺ ⍵}'The service is pausing...'
              WaitForContinue ⍬
          :EndIf
          :If r←ShallServiceQuit
              ConfirmStateChange ⍬
              {}_logFunction{0::⍬ ⋄ ⍬⊣⍺⍺ ⍵}'The service is in the process of shutting down...'
              ⎕NQ'#'eventQuitDQ
          :EndIf
      :EndIf
    ∇

    ∇ {r}←OnServiceHandler(obj event action state);state2;stateAsText
    ⍝ Callback designed to handle notifications from Windows Service Control Manager (SCM).\\
    ⍝ This function is established as a callback by `Init`.\\
    ⍝ Note that the interpreter has already responded automatically to
    ⍝ the SCM with the appropriate "_PENDING" message prior to this
    ⍝ callback being reached.\\
    ⍝ This callback waits until the application has reacted by setting
    ⍝ `ServiceStates.currentState` to `ServiceStates.requiredState` or it times out.\\
    ⍝ Returns always 0.\\
    ⍝ In case of a "STOP" or "SHUTDOWN" this function sends a `eventQuitDQ`
    ⍝ event to `#` after the requested state change was confirmed by the application
    ⍝ to ensure that any running `⎕DQ` (or `Wait`) is quit.\\
    ⍝ Note that this function is independent from both `⎕IO` and `⎕ML` and must stay so.
      state2←state
      :Select action
      :CaseList SERVICE_CONTROL_STOP SERVICE_CONTROL_SHUTDOWN
          requestedState←SERVICE_STOPPED
          state2[⎕IO+3 4 5 6]←0
          {}_logFunction'"stop" is requested'
      :Case SERVICE_CONTROL_PAUSE
          requestedState←SERVICE_PAUSED
          {}_logFunction'"pause" is requested'
      :Case SERVICE_CONTROL_CONTINUE
          requestedState←SERVICE_RUNNING
          {}_logFunction'"continue" is requested'
      :Else
          :If state[⎕IO+1]=SERVICE_START_PENDING
              currentState←requestedState←SERVICE_RUNNING
              {}_logFunction'"start" is requested'
          :Else
              {}_logFunction'',action,' was ignored'
          :EndIf
      :EndSelect
      :If 1<⍴⎕TNUMS                              ⍝ If the main thread is the only one left it's an endless loop!
      :AndIf currentState≢requestedState
          {}WaitForStateChange timeout           ⍝ Wait for the application to confirm the requested change.
          {}_logFunction'Application confirmed state change'
      :EndIf
      state2[⎕IO+1]←currentState                 ⍝ Assign accordingly.
      :If action∊SERVICE_CONTROL_STOP,SERVICE_CONTROL_SHUTDOWN
          ⎕NQ'#'eventQuitDQ                      ⍝ That should quit any DQ waiting
          {}_logFunction'"eventQuitDQ" was sent'
      :EndIf
      2 ⎕NQ'.' 'SetServiceState'state2           ⍝ Confirm to SCM.
      stateAsText←currentState{,1↑⍵⌿⍨⍺=⍎¨↓⍵}'SERVICE'{⍵⌿⍨((⍴,⍺)↑[2]⍵)∧.=⍺}⎕NL 3
      {}_logFunction'Message "SetServiceState" with value "',stateAsText,'" was sent'
      r←0
    ∇

    ∇ r←CreateParmSpace
    ⍝ Creates a namespace populated with variables holding the default settings plus a function `∆List`.
      r←#.⎕NS''
      r.(⎕IO ⎕ML)←1
      r.timeout←5
      r.logFunction←''
      r.logFunctionParent←⍬
      r.eventQuitDQ←9999
      r.⎕FX'r←∆List' 'r←{⍵,[1.5]⍎¨⍵}↓⎕nl 2 9'
    ∇

    ∇ r←MethodList

      r←'Init' 'CreateParmSpace' 'CheckServiceMessages' 'ConfirmStateChange' 'ShallServiceContinue' 'ShallServicePause'
      r,←'ShallServiceQuit' 'WaitForContinue' 'WaitForStateChange' 'IsRunningAsService' 'IsDevelopment' 'Off'
    ∇

      CheckState←{
          0::11
          ⍺←11
          ⍺/⍨~⍵∊pause start continue stop running
      }

      Off←{
    ⍝ In case `testflag←→1` the function returns ⍬.\\
    ⍝ Otherwise it ⎕OFFs (in case its a runtime EXE or runtime DLL) or executes `→`.\\
    ⍝ If you wish to pass a return code specify this as ⍺; that's then passed as right "argument" to `⎕OFF`.
          testFlag←⍵:⍬
          IsDevelopment:→
          0=⎕NC'⍺':⎕OFF
          ⎕OFF ⍺
      }

    ∇ r←IsDevelopment;⎕IO;⎕ML
    ⍝ Returns 1 if the function is running under a Dyalog development EXE or DLL and 0 otherwise.
      ⎕ML←⎕IO←1
      r←'Development'≡4⊃'#'⎕WG'APLVersion'
      r∨←'DLL'≡4⊃'#'⎕WG'APLVersion'   ⍝ May be DLLRT instead!
    ∇

    ∇ r←IsRunningAsService
      r←~0∊⍴2 ⎕NQ'.' 'GetEnvironment' 'RunAsService'
    ∇


:EndNamespace