:Class HandleError
⍝ This class offers the method `Process` which is useful to handle application
⍝ errors on a general level. `Process` in turn is triggered via `⎕TRAP`; use
⍝ the method `SetTrap` in order to set `⎕TRAP` properly.
⍝
⍝ ## Goals
⍝ * Create a namespace `crash` and populate it with variables providing all
⍝   sorts of information potentially important for analyzing the error.
⍝   The namespace "crash" is saved in a component file by default. By default
⍝   all variables visible at the time of the crash are saved in a sub namespace
⍝    of "crash" called "Vars".
⍝
⍝   In case os a threaded application this might all you get (together with the
⍝   HTML page, see belwo) for analysing the problem.
⍝ * Create an HTML page with essential information regarding the error.
⍝ * Attempt to save an error workspace. In order to achieve that, all
⍝   running threads are killed except the main thread and, if different, the
⍝   thread running `Process`.
⍝
⍝ ## Parameters
⍝ All parameters can be changed by setting variables in the namespace
⍝ returned by `CreateParms` which can be passed as right argument to the main
⍝ function `Process`. For defaults just pass an empty vector to `Process`.
⍝
⍝ ## Custom stuff
⍝ You can make `Process` execute your own code by specifying a custom log function
⍝ and / or a custom function for other purposes:
⍝ * `logFunction` is supposed to be the name of a monadic function that
⍝   returns a shy result. That function must be able to deal with a simple
⍝   string as well as vectors of strings.
⍝ * `customFns` can be used to do anything you like. A typical application for this
⍝   is sending an email to notify certain people about the crash.
⍝
⍝   The `customFns` must expect a right argument. This is the parameter namespace
⍝   which holds all the parameters plus two additional variables:
⍝   * `LastError` hold `⎕DM` at the moment of the crash.
⍝   * `LastErrorNumber` holds `⎕EN` at the moment of the crash.
⍝
⍝   This is necessary because something might go wrong inside `HandleError` and, as a
⍝   result, overwrite the `⎕DM` and `⎕EN`.
⍝
⍝   The `customFns` shall not return a result. If it does it must be of type "shy";
⍝   the result will be ignored.
⍝
⍝ Although both function names may use dotted syntax that would not help in case
⍝ they live in an instance of a class. In that case use `logFunctionParent`
⍝ and `customFnsParent` respectively in order to define the parent of the functions.
⍝
⍝ ## How tos
⍝ * At an early stage (we don't know yet where to save stuff etc) specify an
⍝   empty vector as right argument to `SetTrap`.
⍝ * As soon as you can create a parameter space by calling `CreateParms`,
⍝   specify the details in it, typically by `#.⎕SHADOW`ing the name of that
⍝   parameter space in the root within your `⎕LX` function and then assiging
⍝   it to something like `#.MyParms`.
⍝
⍝   `Process` is then able to see this when you specify\\
⍝   `⎕TRAP←0 'E' '#.HandleError.Process' '#.MyParms'`
⍝
⍝ ## Notes
⍝ The attempt to save an error WS will fail if there are any open acre
⍝ projects. In a production environment that should not be the case normally.
⍝ If you do not share this opinion then use your own function (see the
⍝ `customFns` parameter) to close all open acre projects.
⍝
⍝ Kai Jaeger ⋄ APL Team Ltd
⍝
⍝ Homepage: <http://aplwiki.com/HandleError>

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public Shared
      ⍝ * 2.1.1
      ⍝   * Writing to the Windows Event Log did not work.
      ⍝   * `⎕LX` got mutilated.
      ⍝ * 2.1.0
      ⍝   * The command line added to the crash report and the component file.
      ⍝   * `HandleError` does not require `FilesAndDirs` any more.
      ⍝   * Bug fixes
      ⍝     * Current directory was not reported under Linux/Mac OS.
      ⍝ * 2.0.0
      ⍝   * Supports Windows, Linux, Mac OS.
      ⍝   * Needs at least Dyalog 15.0 Unicode
      ⍝ * 1.9.1:
      ⍝   * `⎕WA` was reported as `⎕ML`.
      ⍝   * Documentation improved
      r←(Last⍕⎕THIS)'2.1.1' '2017-01-23'
    ∇

    ∇ {filename}←{signal}Process parms;crash;TRAP;⎕IO;⎕ML;⎕TRAP
      :Access Public Shared
    ⍝ Returns the name of the error workspace saved by this function as shy result.
    ⍝
    ⍝ `⎕OFF`s in runtime or if `enforceOff` is 1 but not otherwise.
    ⍝
    ⍝ All actions are performed under error trapping, so it should never fail.
    ⍝
    ⍝ "signal": if specified this overwrites `parms.signal`; this is for test cases only.
      ⎕IO←1 ⋄ ⎕ML←1
      TRAP←⎕TRAP                                    ⍝ Remember old setting (for reporting)
      ⎕TRAP←(0 1000)'C' '→∆End'                     ⍝ Make sure that it does not crash itself
      parms←⍎⍣((~0∊⍴parms)∧(⎕DR parms)∊320 160 80 82)⊣parms     ⍝ Convert name into reference
      :If 9≠⎕NC'parms'
      :OrIf 0∊⍴parms
          parms←CreateParms
      :EndIf
      :If 0<⎕NC'signal'
          parms.signal←signal
      :EndIf
      parms.(LastError LastErrorNumber)←⎕DM ⎕EN
      CheckErrorFolder parms
      crash←CreateCrash parms TRAP
      filename←CreateFilename parms.errorFolder
      0 ⎕TKILL ⎕TNUMS~⎕TID   ⍝ Try to kill all threads but itself and the main thread
      WriteToLogFile parms
      WriteHtmlFile parms crash filename
      SaveCrash filename crash parms
      SaveErrorWorkspace filename parms
      WriteToWindowsEvents parms
      ExecuteCustomFns parms
      :If 0≠parms.signal
          ⎕SIGNAL parms.signal
      :ElseIf parms.off
          :If IsDevelopment∧0=parms.enforceOff
              PrintErrorToSession 1⊃parms.LastError
              →
          :Else
              ⎕OFF parms.returnCode
          :EndIf
      :Else
          :If IsDevelopment∧0=parms.enforceOff
              PrintErrorToSession 1⊃parms.LastError
          :EndIf
          →
      :EndIf
     ∆End:⎕TRAP←TRAP
    ∇

    ∇ r←{force}SetTrap parameterSpaceName;⎕TRAP;⎕ML;⎕IO;calledFrom
      :Access Public Shared
    ⍝ Returns a vector useful to set `⎕TRAP` depending on whether it's
    ⍝ a development session or not.
    ⍝
    ⍝ The right argument can be either an empty vector or the name of
    ⍝ a parameter space - **not** a reference!
    ⍝
    ⍝ The left argument defaults to 0. Setting this to 1 enforces error
    ⍝ trapping even under a development exe. Useful for test cases.
      ⎕TRAP←0⍴⎕TRAP
      ⎕IO←1 ⋄ ⎕ML←0
      force←{0=⎕NC ⍵:0 ⋄ ⍎⍵}'force'
      r←(0 1000)'S'
      calledFrom←{⌽{⍵/⍨2≤+\'.'=⍵}⌽⍵}1⊃⎕XSI
      :If ~0∊⍴parameterSpaceName
          :If 1≠≡,parameterSpaceName
          :OrIf ~(⎕DR parameterSpaceName)∊80 82 160
              'Invalid right argument: must be a name'⎕SIGNAL 11
          :EndIf
      :EndIf
      :If 0∊⍴parameterSpaceName  ⍝ At a very early stage error trapping does not make sense
      :AndIf (0=IsDevelopment)∨force
          r←⊂0 'E'(calledFrom,'HandleError.Process ⍬')
      :Else
          :If (0=IsDevelopment)∨force
              r←⊂0 'E'(calledFrom,'HandleError.Process ''',parameterSpaceName,'''')
          :EndIf
      :EndIf
    ∇

    ∇ r←CreateParms;rk;buf;⎕IO;⎕ML
    ⍝ Returns a namespace with default values for the `HandleError` method
    ⍝ | Parameter    | Description|
    ⍝ | - | - |
    ⍝ | `checkErrorFolder` | Boolean that defaults to 1. If this is 1 and the folder `errorFolder` is pointing to does not exist it will be created. Needs `FilsAndDirs`! |
    ⍝ | `createHTML` | Boolean that defaults to 1. A 0 suppresses the creation of the HTML file.|
    ⍝ | `customFns`  | Fully qualified name of a monadic function to be executed by `Process`.<<br>>Useful to send an email, for example. See also `customFnsParent`.|
    ⍝ | `customFnsParent` | No default. May be a reference pointing to the parent of the `customFns`.<<br>>Needed only in case that the parent is a class instance since `logFunction` may use dottet syntax.|
    ⍝ | `enforceOff` | 1: `⎕OFF` no matter whether is's a runtime EXE or not. Mainly for test cases.|
    ⍝ | `errorFolder`| Folder that keeps the component file (`crash`), the HTML page and the error WS.<<br>>If this is relative then the current directory is added.|
    ⍝ | `logFunction`| Name of the logging function to be used. See also `logFnsParent`.|
    ⍝ | `logFnsParent` | No default. May be a reference pointing to the parent of `logFunction`.<<br>>Needed only in case that the parent is a class instance since `logFunction` may use dottet syntax.|
    ⍝ | `off`        | By default this function executes `⎕OFF` with `returnCode` when in Runtime. A 0 suppresses this.|
    ⍝ | `returnCode` | The return code passed on to `⎕OFF`.|
    ⍝ | `saveCrash`  | Boolean that defaults to 1.<<br>>A 0 suppresses the creation of `crash` & a component file in which `crash` is saved.|
    ⍝ | `saveErrorWS`| Boolean that defaults to 1.<<br>>A 0 suppresses the creation of a crash workspace.|
    ⍝ | `saveVars`   | Boolean that defaults to 1.<<br>>Is ignored when `saveCrash` is 0. If 1 all visible variables are saved in a sub namepsace `Vars` within `crash`.|
    ⍝ | `signal`     | When `off` is 0 and `signal` is not 0 then `signal` is signalled by `Process`.<<br>>This can be used for a restart attempt.|
    ⍝ | `trapInternalErrors` | By default all internal errors are trapped:<<br>>`Process` should never crash an application.|
    ⍝ | `trapSaveWSID`       | Boolean that defaults to 1. Makes sure that the `⎕SAVE` statement is guarded.<<br>>Useful to trace through it without a problem in versions prior to 14.1.|
    ⍝ | `windowsEventSource` | Name of the Windows Event Log to write to. Ignored when empty.|
    ⍝ | `addToMsg`           | Will be added to the log file as well as the Windows Event Log messages.<<br>>Mainly for test cases.|
      :Access Public Shared
      ⎕IO←0 ⋄ ⎕ML←3
      r←⎕NS''
      r.⎕FX'r←∆List;⎕IO' '⍝ List all variables and possible references in this namespace' '⎕IO←0' 'r←{⍵,[0.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2 9'
      r.checkErrorFolder←1
      r.createHTML←1
      r.customFns←''
      r.customFnsParent←⍬
      r.enforceOff←0
      r.errorFolder←'Errors/'
      r.logFunction←''
      r.logFunctionParent←⍬
      r.off←1
      r.returnCode←1
      r.saveCrash←1
      r.saveErrorWS←1
      r.saveVars←1
      r.signal←0
      r.trapInternalErrors←1
      r.trapSaveWSID←1
      r.windowsEventSource←''
      r.addToMsg←''
     ⍝Done
    ∇

    ∇ {r}←ReportErrorToWindowsLog(appName message);⎕USING
    ⍝ Reports an error to the Windows Event Log, by default to source="APL"
      :Access Public Shared
      r←⍬
      ⎕USING←'System,system.dll' 'System.Diagnostics,system.dll'
      :If 0∊⍴appName
          appName←'APL'
      :EndIf
      message←Nest message
      WriteWindowsLog_ appName EventLogEntryType.Error message
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ Private stuff

    MarkupAsTableRow←{CR,'<tr><td><b>',⍺,((0<⍴⍺)/': </b></td><td>'),(⍕⍵),'</td></tr>'}

    ∇ r←CR
      r←⎕UCS 13
    ∇


    ∇ {html}←WriteHtmlFile(parms crash filename);If
      :If parms.createHTML
          html←'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> ',CR
          html,←'<html>',CR
          html,←'<head>',CR
          html,←'<meta http-equiv="Content-Type" content="text/html;charset=utf-8">',CR
          html,←'<title>',('/'Last filename),'</title>',CR
          html,←'<style media="screen" type="text/css">',CR
          html,←'pre {',CR
          html,←'font-family: "APL385 Unicode"; font-size: 14px;',CR
          html,←'}',CR
          html,←'h1 {',CR
          html,←'font-family: "Courier New";',CR
          html,←'}',CR
          html,←'table#apl {',CR
          html,←'font-family: "APL385 Unicode"; font-size: 14px;',CR
          html,←'}',CR
          html,←'</style>',CR
          html,←'</head>',CR
          html,←'<body>',CR
          html,←'<h1>',('/'Last filename),'</h1>',CR
          html,←'<table id="apl">'
          html,←'Version'MarkupAsTableRow⍕'#'⎕WG'APLVersion'
          html,←'⎕WSID'MarkupAsTableRow⍕'/'Last 1↓' ',crash.WSID  ⍝ Enforce ⎕DR 80/82 with 1↓' ',
          html,←'⎕IO'MarkupAsTableRow⍕⎕IO
          html,←'⎕ML'MarkupAsTableRow⍕⎕ML
          html,←'⎕WA'MarkupAsTableRow⍕⎕WA
          html,←'⎕TNUMS'MarkupAsTableRow⍕⎕TNUMS
          html,←'Category'MarkupAsTableRow crash.Category
          html,←'EM'MarkupAsTableRow crash.EM
          html,←'HelpURL'MarkupAsTableRow crash.HelpURL
          html,←'EN'MarkupAsTableRow⍕crash.EN
          html,←'ENX'MarkupAsTableRow⍕crash.ENX
          html,←'InternalLocation'MarkupAsTableRow⍕crash.InternalLocation
          html,←'Message'MarkupAsTableRow crash.Message
          html,←'OSError'MarkupAsTableRow⍕crash.OSError
          html,←'Current Dir'MarkupAsTableRow⍕crash.CurrentDir
          html,←'Command line'MarkupAsTableRow⍕crash.CommandLine
          :If ~0∊⍴parms.addToMsg
              html,←'Added Msg'MarkupAsTableRow parms.addToMsg
          :EndIf
          html,←'</table>'
          html,←'<p><b>Stack:</b></p>',CR
          :If ~0∊⍴crash.XSI
              html,←'<pre>',(⊃,/CR,¨crash.XSI,¨{'[',(⍕⍵),']'}¨crash.LC),CR,'</pre>',CR
          :EndIf
          html,←'<p><b>Error Message:</b></p>',CR
          :If ~0∊⍴crash.DM
              html,←'<pre>',(ExchangeHtmlChars⊃,/CR,¨crash.DM),CR,'</pre>',CR
          :EndIf
          html,←'</body>',CR
          html,←'</html>',CR
          :Trap (parms.trapInternalErrors)/0
              WriteUtf8File(filename,'.html')html
          :Else
              :Trap (parms.trapInternalErrors)/0
                  :If IsDevelopment
                      ⎕←'Writing HTML file failed, ',1⊃parms.LastError
                  :EndIf
              :EndTrap
          :EndTrap
      :Else
          html←''
      :EndIf
    ∇

    ∇ {r}←WriteWindowsLog_(source type message);eventLog;sep;⎕USING;buffer;⎕ML
    ⍝ This function writes to the Windows Event Log.
    ⍝ "message" must either be a string or a vector of strings.
    ⍝ "type"
      ⎕ML←1
      r←⍬
      ⎕USING←'System,system.dll' 'System.Diagnostics,system.dll'
    ⍝ Should check the source/log exist.
      eventLog←⎕NEW EventLog
      eventLog.Source←source
      sep←⎕UCS 10
      buffer←¯1↓⊃,/message,¨sep
      eventLog.WriteEntry buffer type
    ∇

    ∇ html←ExchangeHtmlChars html;b;⎕ML
      ⎕ML←3
      :If 0<+/b←html='&'
          (b/html)←⊂'&amp;'
          html←∊html
      :EndIf
      :If 0<+/b←html='<'
          (b/html)←⊂'&lt;'
          html←∊html
      :EndIf
      :If 0<+/b←html='>'
          (b/html)←⊂'&gt;'
          html←∊html
      :EndIf
    ∇

    ∇ WriteToLogFile parms;fns;parent
      :If ~0∊⍴parms.logFunction
          :Trap (parms.trapInternalErrors)/0
              :If '.'∊parms.logFunction
                  fns←⍎parms.logFunction
              :Else
                  :If ⍬≢parms.logFunctionParent
                      fns←parms.logFunctionParent⍎parms.logFunction
                  :Else
                      'Cannot find the log function'⎕SIGNAL 6
                  :EndIf
              :EndIf
              fns'*** Error'
              fns'Error number=',⍕parms.LastErrorNumber
              fns parms.LastError
              :If ~0∊⍴parms.addToMsg
                  fns parms.addToMsg
              :EndIf
          :Else
          ⍝ Useful to realize in the tracer that something went wrong
          :EndTrap
      :EndIf
    ∇

    ∇ ExecuteCustomFns parms;fns;parent
      :If ~0∊⍴parms.customFns
          :Trap (parms.trapInternalErrors)/0
              :If '.'∊parms.customFns
                  fns←⍎parms.customFns
              :Else
                  :If ⍬≢parms.customFnsParent
                      fns←parms.customFnsParent⍎parms.customFns
                  :Else
                      'Cannot find the custom function'⎕SIGNAL 6
                  :EndIf
              :EndIf
              fns parms
          :Else
        ⍝ Useful to realize in the tracer that something went wrong
          :EndTrap
      :EndIf
    ∇

    ∇ {r}←SaveErrorWorkspace(filename parms);wsid;lx
      :If parms.saveErrorWS
          wsid←⎕WSID
          ⎕WSID←filename
          lx←⎕LX
          ⎕LX←'⎕TRAP←0 ''S'' ⍝',⎕LX
          :Trap parms.trapSaveWSID/0
              ⎕SAVE ⎕WSID
          :EndTrap
          ⎕WSID←wsid       ⍝ Potentially important (for example when running test cases)
          ⎕LX←lx
      :EndIf
    ∇

    ∇ crash←CreateCrash(parms Trap)
      crash←⎕NS''
      crash.(AN DM EN XSI LC WSID TID TNUMS)←⎕AN ⎕DM ⎕EN ⎕XSI ⎕LC ⎕WSID ⎕TID ⎕TNUMS
      crash.WA←⎕WA
      crash.Trap←Trap
      crash.CurrentDir←GetCurrentDir ⍬
      crash.CommandLine←2 ⎕NQ'#' 'GetCommandLine'
      :Trap (parms.trapInternalErrors)/0
          crash.(Category DM EM HelpURL EN ENX InternalLocation Message OSError)←⎕DMX.(Category DM EM HelpURL EN ENX InternalLocation Message OSError)
          crash.(XSI LC)←1↓¨crash.(XSI LC)
      :EndTrap
      :If ~0∊⍴parms.addToMsg
          crash.addedMsg←parms.addToMsg
      :EndIf
      :If parms.saveVars
          crash←SaveVisibleVars crash
      :EndIf
    ∇


    ∇ {r}←SaveCrash(filename crash parms);tno
      :If parms.saveCrash
          :Trap (parms.trapInternalErrors)/0
              tno←filename ⎕FCREATE 0
              crash ⎕FAPPEND tno
              ⎕FUNTIE tno
          :Else
            ⍝ For the Tracer
          :EndTrap
      :EndIf
    ∇

      CreateFilename←{
          folder←⍵
          folder,←((~0∊⍴folder)∧'/'≠¯1↑folder)/'/'
          folder,({⍵↑⍨¯1+⍵⍳'.'}2⊃SplitPath crash.WSID),'_',14 0⍕100⊥6↑⎕TS}

    ∇ {r}←WriteToWindowsEvents parms;msg
      r←⍬
      :If ~0∊⍴parms.windowsEventSource
          :Trap (parms.trapInternalErrors)/0
              msg←('Application has crashed, RC=',⍕crash.EN,'; MSG=',1⊃crash.DM)
              :If ~0∊⍴parms.addToMsg
                  msg,←parms.addToMsg
              :EndIf
              ReportErrorToWindowsLog parms.windowsEventSource msg
          :EndTrap
      :EndIf
    ∇

    ∇ {r}←PrintErrorToSession msg
      r←⍬
      ⎕←'HandleError.Process caught ',msg
    ∇

    ∇ crash←SaveVisibleVars crash;rf;list;this
      rf←{⊃⍵~⊃⍵}⎕RSI
      list←' '~¨⍨↓rf.⎕NL 2
      'Vars'crash.⎕NS''
      :For this :In list
          ⍎'crash.Vars.',this,'←rf.⍎this'
      :EndFor
    ∇

    ∇ {r}←CheckErrorFolder parms
      r←⍬
      :If ~0∊⍴parms.errorFolder
          parms.errorFolder←{(-(¯1↑⍵)∊'/\')↓⍵}parms.errorFolder
          :If 0=⎕NEXISTS parms.errorFolder
          :AndIf parms.checkErrorFolder
              :If 'Win'≡GetOperatingSystem ⍬
                  ⎕CMD'MkDir "',parms.errorFolder,'"'
              :Else
                  ⎕CMD'MkDir -p ',parms.errorFolder,'"'
              :EndIf
          :EndIf
      :EndIf
    ∇

      GetCurrentDir←{
      ⍝ We don't know whether FilsAndDirs is around
          'Win'≡#.APLTreeUtils.GetOperatingSystem ⍬:⊃⎕CMD'cd'
          ⊃⎕SH'pwd'
      }

:EndClass
