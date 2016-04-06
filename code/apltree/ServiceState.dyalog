:Namespace ServiceState
⍝ This namespace provides an interface between an APL application designed _
⍝ to run as a service and the Windows Service Control Manager (SCM). The _
⍝ SCM is sending messages which are caught by the ServiceState.OnServiceHandler _
⍝ callback.
⍝ ServiceState offers all sort of functions but normally the user will call just:
⍝ * ServiceState.CreateParmSpace
⍝ * ServiceState.Ini
⍝ * ServiceState.CheckServiceMessages
⍝
⍝ To start run  #.ServiceState.Init. You can either specify an empty _
⍝ right argument (if you are happy with the defaults) or a parameter _
⍝ space. It is suggested to create a parameter space by calling: _
⍝ `ps←#.ServiceState.CreateParmSpace`.
⍝ You can then change the defaults. Call
⍝ `ps.∆List`
⍝ for a list of all settings. Finally pass this as right argument to `Init`.
⍝
⍝ Note that `Init` associates #.ServiceState.OnServiceHandler as the _
⍝ callback function for state changes signalled by SCM. This callback will _
⍝ set internally a variable which indicates what state is requested by the SCM.
⍝
⍝ In general the application is supposed to...
⍝ [1] check whether a state change is required.
⍝ [2] take appropriate action (if any).
⍝ All this can be achieved by calling the operator `CheckServiceMessages`. _
⍝ This takes a log function as operand and a flag that indicates whether the _
⍝ application is running as a service. Call #.ServiceState.IsRunningAsService _
⍝ for this.
⍝
⍝ See the test cases for examples.
⍝
⍝ Needs Dyalog 14.0 or better
⍝ Kai Jaeger ⋄ APL Team Ltd
⍝ Homepage: http://aplwiki.com/ServiceState

    ⎕IO←⎕ML←1

    ∇ r←Version
      :Access Public Shared
      r←({⍵↑⍨-¯1+'.'⍳⍨⌽⍵}⍕⎕THIS)'1.2.2' '2015-02-01'
      ⍝ 1.2.2 Bug fix
      ⍝ 1.2.1 Script update
      ⍝ 1.2.0 APL inline code is now marked up with ticks
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
    ⍝ Initialize ServiceState.
    ⍝ ps can be empty or a parameter space, typically created by calling CreateParmSpace.
      r←⍬
      ps2←CreateParmSpace
      :If 326=⎕DR ps
          allowed←'logFunction' 'logFunctionParent' 'ride' 'timeout' 'eventQuitDQ'
          'Invalid parameter'⎕SIGNAL 11/⍨~∧/(' '~¨⍨↓ps.⎕NL 2 9)∊allowed
          ps2.{⍵{⍵{⍎⍺,'←⍵'}¨⍺.⍎¨⍵}⍵.⎕NL-2 9}ps  ⍝ Merge
      :EndIf
      ⎕THIS.{⍵{⍵{⍎⍺,'←⍵'}¨⍺.⍎¨⍵}⍵.⎕NL-2 9}ps2   ⍝ Set globals
      currentState←SERVICE_RUNNING
      requestedState←⍬
      {}MakeRuntimeListenToRide⍣(0=IsDevelopment)⊣⍬
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
     ⍝ Use this to confirm that the app is happy with the state change.
     ⍝ Right argument is ignored.
      r←⍬
      currentState←requestedState
    ∇

    ∇ r←ShallServicePause
    ⍝ Boolean: returns 1 if the state is supposed to become "pause".
      r←SERVICE_PAUSED≡requestedState
    ∇

    ∇ r←ShallServiceContinue
    ⍝ Boolean: returns 1 if States.requestedState is no longer "paused".
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
    ⍝ Returns always ⍬.
    ⍝ Consider calling this in case ShallServicePause has returned a 1 and you don't _
    ⍝ have to do any particular gymnastics but just want to wait for a state change.
    ⍝ It just waits until the status changes, although not necessarily to "continue".
    ⍝ However, when the state changes then currentState is set to SERVICE_RUNNING
    ⍝ no matter which state was requested. Therefore another check for "Stop" is
    ⍝ required afterwards.
      r←⍬
      :While 0=ShallServiceContinue
          ⎕DL 1
      :EndWhile
      currentState←SERVICE_RUNNING
    ∇

    ∇ r←WaitForStateChange timeout
    ⍝ Waits until the application confirms the requested state or the time out jumps in.
    ⍝ Returns 0 when achieved but 1 in case of a time out.
    ⍝ This fns is called by the callback processing the messages _
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
    ⍝ Check whether a "Pause" or a "Stop" message has arrived from the _
    ⍝ Service Control Manager (SCM). Waits for resume and also logs all _
    ⍝ events. Sends a "eventQuitDQ" event to # in case of a "Stop".
    ⍝ `_logFunction` must be the name of a monadic function returning a result; _
    ⍝ purpose is to log events. {⍬} will do if you don't log anything.
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

    ∇ {r}←OnServiceHandler(obj event action state);state2
    ⍝ Callback to handle notifications from Windows Service Control Manager (SCM).
    ⍝ This function is established as a callback by `Init`.
    ⍝ Note that the interpreter has already responded automatically to _
    ⍝ the SCM with the appropriate "_PENDING" message prior to this _
    ⍝ callback being reached.
    ⍝ This callback waits until the application has reacted by setting _
    ⍝ ServiceStates.currentState to ServiceStates.requiredState or it times out.
    ⍝ Returns always 0.
    ⍝ In case of a "STOP" or "SHUTDOWN" this function sends a eventQuitDQ _
    ⍝ event to # after the requested state change was confirmed by the application _
    ⍝ to ensure that any running ⎕DQ (or wait) is quit.
    ⍝ Note that this function is ⎕IO- and ⎕ML independent and must stay so.
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
      {}_logFunction'Message "SetServiceState" was sent'
      r←0
    ∇

    ∇ r←CreateParmSpace
    ⍝ Creates a namespace populated with variables holding the default settings.
      r←#.⎕NS''
      r.(⎕IO ⎕ML)←1
      r.ride←0
      r.timeout←10
      r.logFunction←''
      r.logFunctionParent←⍬
      r.eventQuitDQ←9999
      r.⎕FX'r←∆List' 'r←{⍵,[1.5]⍎¨⍵}↓⎕nl 2 9'
    ∇

    ∇ r←MethodList
     
      r←'Init' 'CreateParmSpace' 'CheckServiceMessages' 'ConfirmStateChange' 'ShallServiceContinue' 'ShallServicePause' 'ShallServiceQuit' 'WaitForContinue' 'WaitForStateChange' 'IsRunningAsService'
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝  Private stuff

      CheckState←{
          0::11
          ⍺←11
          ⍺/⍨~⍵∊pause start continue stop running
      }

      MakeRuntimeListenToRide←{
          0::0                   ⍝ This ↓ can cause a DOMAIN ERROR
          3502⌶⍬                 ⍝ Make a Runtime EXE/DLL listen to Ride
      }

      Off←{
    ⍝ In case testflag←→1 the function returns ⍬.
    ⍝ Otherwise it ⎕OFFs (runtime EXE/DLL) or executes:
    ⍝ →
          testFlag←⍵:⍬
          0=IsDevelopment:⎕OFF
          →
      }

    ∇ r←IsDevelopment;⎕IO;⎕ML
    ⍝ Returns a one if the function is running under a Dyalog development EXE or DLL.
      ⎕ML←⎕IO←1
      r←'Development'≡4⊃'#'⎕WG'APLVersion'
      r∨←'DLL'≡4⊃'#'⎕WG'APLVersion'   ⍝ May be DLLRT instead!
    ∇

    ∇ r←IsRunningAsService
      r←~0∊⍴2 ⎕NQ'.' 'GetEnvironment' 'RunAsService'
    ∇

:EndNamespace