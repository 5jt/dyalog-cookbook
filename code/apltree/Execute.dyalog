:Class Execute
⍝ This class allows you two different things:
⍝ * Start a process and catch its return code.
⍝ * Start an application and catch its standard output.
⍝
⍝ The two goals are quite different and therefore handled by two
⍝ different methods: `Process` and `Application`.
⍝
⍝ You would use `Application` in order to start...
⍝ * another instance of Dyalog from Dyalog.
⍝ * a console application from within Dyalog.
⍝ * any EXE from Dyalog.
⍝ * a batch script from Dyalog.
⍝
⍝ When you need the actual output then you would use `Process`. Examples are:
⍝
⍝ * Get a list with a SubVersion command.
⍝ * Get a directory listing with the console DIR command.
⍝
⍝ Note that if you specify `/` as a delimiter at the beginning then `Execute`
⍝ enforces `\` characters for you. Example:
⍝
⍝ ~~~
⍝ #.Execute.Process'"C:/My Scripts/foo.bat"  ⍝ this will work
⍝ ~~~
⍝
⍝ If however a parameter passed later on happens to be a directory name then
⍝ it is up to you to specify `\` rather than `/` as separator. Example:
⍝
⍝ ~~~
⍝ #.Execute.Process'CMD' 'dir C:/' 'Exit 199' ⍝ this won't work
⍝ ~~~
⍝
⍝ Thanks to Peter Michael Hager (<mailto:Hager@Dortmund.net>) without whom
⍝ this class would hardly exist.
⍝
⍝ Author: Kai Jaeger ⋄ APL Team Ltd
⍝
⍝ Home page: <http://aplwiki.com/Execute>

    :Include APLTreeUtils

    okay←false←null←0 ⋄ true←1

    ∇ r←Version
      :Access Public shared
      r←(Last⍕⎕THIS)'1.8.1' '2017-08-23'
    ∇

    ∇ History
      :Access Public Shared
    ⍝ * 1.8.1
    ⍝   * Glitches in the documentation fixed.
    ⍝ * 1.8.0
    ⍝   * Method `History` polished.
    ⍝   * Now managed by acre 3.
    ⍝ * 1.7.1
    ⍝   * Syntax fix for new version of `FilesAndDirs`.
    ⍝ * 1.7.0
    ⍝   * Now requires at least Dyalog 15.0 Unicode
    ⍝   * Uses `FilesAndDirs` rather than `WinFile`.
    ⍝ * 1.6.0
    ⍝   * Doc converted to Markdown (requires at least ADOC 5.0).
    ⍝ * 1.5.0
    ⍝   * `Version` is now returning just the name (no path).
    ⍝   * For marking up inline APL code now ticks (`) are used.
    ∇

    ∇ {(rc processInfo result more)}←{cs}Application program;⎕IO;⎕ML;NORMAL_PRIORITY_CLASS;nl;bool;startupInfo;processHandle;threadHandle;StillActive;Ctrl_C_Is;ProcessAborted;i;∆CreateProcess;∆GetCurrentDirectory;∆GetExitCodeProcess;∆GetExitCodeThread;∆WaitForSingleObject;∆TerminateProcess;∆TerminateThread
    ⍝ # Overview
    ⍝
    ⍝ Run "program" in the same environment as the calling process.
    ⍝
    ⍝ The left argument is optional. If passed this must be a command space.
    ⍝ You can call the public shared method `DefaultParms` in order to get
    ⍝ a command space pre-populated with default settings. Then make
    ⍝ appropriate changes and pass it as left argument.
    ⍝
    ⍝ ## Explicit Result
    ⍝
    ⍝ There are four items returned as explicit result:
    ⍝ * `rc` (return code) with 0 being okay.
    ⍝ * `processInfo`: an integer vector with process related information.
    ⍝ * `result`: that's what is returned by `⎕OFF n` where `n` gets the result,
    ⍝   or "Exit n" in a batch program. When wait is 0 there is no result
    ⍝   so this is always 0 then.
    ⍝ * `more`: might carry additional information in case something went wrong.
      :Access Public Shared
      ⎕IO←0 ⋄ ⎕ML←3
      result←⍬ ⋄ more←''
      NORMAL_PRIORITY_CLASS←32
      'Invalid right argument'⎕SIGNAL 11/⍨(' '≠1↑0⍴∊program)∨~(≡program)∊0 1
      cs←{0<⎕NC ⍵:⍎⍵ ⋄ DefaultParms}'cs'
      nl←cs.⎕NL-2
      :If 0<+/bool←~nl∊'dir' 'hidden' 'wait' 'timeoutAfter'
          11 ⎕SIGNAL⍨'Unknown parameters: ',↑{⍺,',',⍵}/bool/nl
      :EndIf
      program←EnforceBackslash program
      :If Is64Bit
          '∆CreateProcess'⎕NA'I4 KERNEL32.C32|CreateProcess',QnaType,'I4 <0T P P I4 I4 P <0T <{I4 U4 P P P I4 I4 I4 I4 I4 I4 I4 I4 I2 I2 U4 P P P P} >{P P I4 I4}'
      :Else
          '∆CreateProcess'⎕NA'I4 KERNEL32.C32|CreateProcess',QnaType,' I4 <0T I4 I4 I4 I4 I4 <0T <{I4 I4 I4 I4 I4 I4 I4 I4 I4 I4 I4 I4 I2 I2 I4 I4 I4 I4} >{I4 I4 I4 I4}'
      :EndIf
      '∆CloseHandle'⎕NA'I4 KERNEL32.C32|CloseHandle I4'
      'GetLastError'⎕NA'I4 KERNEL32.C32|GetLastError'
      '∆ExpandEnvironmentStrings'⎕NA'I4 KERNEL32.C32|ExpandEnvironmentStrings',QnaType,' <0T >0T I4'
      :If 0∊⍴,cs.dir
          '∆GetCurrentDirectory'⎕NA'I4 KERNEL32.C32|GetCurrentDirectory',QnaType,' I4 >T[]'
          :If 0=↑rc←∆GetCurrentDirectory 260 260
              rc←GetLastError
              more←'GetCurrentDirectory error'
              :Return
          :Else
              cs.dir←↑↑/rc
          :EndIf
      :EndIf
      startupInfo←CreateStartupInfo cs.hidden
      program←ExpandEnv program
      (rc processInfo)←∆CreateProcess null program null null true NORMAL_PRIORITY_CLASS null cs.dir startupInfo 0
      :If false=rc
          rc←GetLastError
          more←'Creating process failed'
      :Else
          (processHandle threadHandle)←2↑processInfo
          :If cs.wait
              StillActive←259
              Ctrl_C_Is←¯1073741510
              ProcessAborted←1067
              '∆GetExitCodeProcess'⎕NA'I4 KERNEL32.C32|GetExitCodeProcess I4 >I4'
              '∆GetExitCodeThread'⎕NA'I4 KERNEL32.C32|GetExitCodeThread I4 >I4'
              '∆WaitForSingleObject'⎕NA'I4 KERNEL32.C32|WaitForSingleObject I4 I4'
              '∆TerminateProcess'⎕NA'I4 KERNEL32.C32|TerminateProcess I4 I4'
              '∆TerminateThread'⎕NA'I4 KERNEL32.C32|TerminateThread I4 I4'
              i←0
              :Trap 1002 1003
                  :While (okay StillActive)≡2↑(∆GetExitCodeProcess GetExitCodeProcess)processHandle
                      i←i+⎕DL 0.5
                      :If 0≠cs.timeoutAfter
                      :AndIf cs.timeoutAfter<i
                          result←1⊃(∆GetExitCodeProcess GetExitCodeProcess)processHandle
                          (∆TerminateProcess TerminateProcess)(processHandle Ctrl_C_Is)
                          more←ProcessAborted('Timeout after ',(⍕cs.timeoutAfter),' seconds')
                          :Leave
                      :EndIf
                  :Until null=↑(∆WaitForSingleObject WaitForSingleObject)processHandle 10
                  result←1⊃(∆GetExitCodeProcess GetExitCodeProcess)processHandle
              :Else
                  result←1⊃(∆GetExitCodeProcess GetExitCodeProcess)processHandle
                  (∆TerminateProcess TerminateProcess)(processHandle Ctrl_C_Is)
                  more←ProcessAborted'Process has died away'
              :EndTrap
              :While (true StillActive)≡(∆GetExitCodeThread GetExitCodeThread)(threadHandle)
                  (∆TerminateThread TerminateThread)(threadHandle 0) ⍝ Wait Status
              :EndWhile
          :EndIf
          rc←okay
      :EndIf
      :Trap 0
          {}∆CloseHandle¨processHandle threadHandle
      :EndTrap
    ∇

    ∇ (rc stdOutput exitCode)←{directory}Process commandLine;stdInput;hStdInputRead;hStdInputWrite;hStdOutputRead;hStdOutputWrite;numberOfBytesRead;numberOfBytesWritten;cbAvail;Buffer;pEnvironment;validFlag;securityAttributes;startupInfo;processInformation;hProcess;hThread;processId;threadId;MAX_PATH;ExpandEnvironmentStrings;SECURITY_ATTRIBUTES;CreatePipe;NORMAL_PRIORITY_CLASS;CREATE_SEPARATE_WOW_VDM;CloseHandle;CreateProcess;FreeEnvironmentStrings;CharToOemCBuff;WriteFileC;STILL_ACTIVE;∆GetExitCodeProcess;∆TerminateProcess;CONTROL_C_EXIT;rc;ERROR_PROCESS_ABORTED;WAIT_OBJECT_0;∆WaitForSingleObject;PeekNamedPipeAvail;ReadFileC;OemCToCharBuff;∆GetExitCodeThread;∆TerminateThread;STATUS_WAIT_0;GetLastError;⎕ML;⎕IO;consist;nl;bool;STARTF_USESHOWWINDOW;STARTF_USESTDHANDLES;∆GetCurrentDirectory;strstartupinfo;pad
      :Access Public Shared
    ⍝ # Overview
    ⍝ Run "program" in the same environment as the calling process.
    ⍝
    ⍝ Executes a new task in a hidden window and returns stdout.
    ⍝
    ⍝ ## The right argument
    ⍝ `commandLine` can be one of:
    ⍝ * Simple char vector naming the task and blank separated command line arguments.
    ⍝ * Vector of char vectors. All items but the first are taken as input then.
    ⍝
    ⍝ An example for the latter case would be:  `'cmd' 'dir' 'exit 129'`
    ⍝
    ⍝ This starts a console, runs the "DIR" command and then exits with code 129.
    ⍝
    ⍝ ## The optional left argument
    ⍝ The task is executed in "directory" if given or in the current directory if not.
    ⍝
    ⍝ ## The explicit result
    ⍝ The result of the function is:
    ⍝ 1) the return code, 0 is okay. Note that is is **not** the exit code of the application!
    ⍝ 2) the task's result, converted to a vector of vectors.
    ⍝
    ⍝ If the function hangs it may be interrupted by Ctrl-Break.
    ⍝
    ⍝ The accumulated result is always returned.
      ⎕IO←0 ⋄ ⎕ML←3
      rc←0 ⋄ exitCode←¯1
      '∆GetCurrentDirectory'⎕NA'I4 KERNEL32.C32|GetCurrentDirectory',QnaType,' I4 >T[]'
      ⎕NA'I KERNEL32|GetEnvironmentStrings'
      'ExpandEnvironmentStrings'⎕NA'I KERNEL32|ExpandEnvironmentStrings',QnaType,' <0T >0T I'
      :If Is64Bit
          ⎕NA'I4 KERNEL32|CreatePipe >P  >P <{I4 I4 P I4} I4'
      :Else
          ⎕NA'I4 KERNEL32|CreatePipe >P >P <{I4 P I4} I4'
      :EndIf
      ⎕NA'I KERNEL32|GetEnvironmentStrings'
      ⎕NA'I KERNEL32|CloseHandle I'
      :If Is64Bit
          strstartupinfo←' <{I4 U4 P P P I4 I4 I4 I4 I4 I4 I4 I4   I2 I2 U4 P P P P} '
      :Else
          strstartupinfo←' <{I4    P P P I4 I4 I4 I4 I4 I4 I4 I4   I2 I2    P P P P} '
      :EndIf
      'CreateProcess'⎕NA'I4 kernel32.dll|CreateProcess* I4 <0T P P I4 I4 P <0T ',strstartupinfo,'>{P P I4 I4}'
      'FreeEnvironmentStrings'⎕NA'I KERNEL32|FreeEnvironmentStrings',QnaType,' I'
      'CharToOemCBuff'⎕NA'I USER32|CharToOemBuff',QnaType,' <T[] >C[] I'
      'OemCToCharBuff'⎕NA'I USER32|OemToCharBuff',QnaType,' <C[] >T[] I'
      'WriteFileC'⎕NA'I KERNEL32|WriteFile I <C[] I >I I'
      '∆GetExitCodeProcess'⎕NA'I4 KERNEL32.C32|GetExitCodeProcess I4 >I4'
      '∆GetExitCodeThread'⎕NA'I4 KERNEL32.C32|GetExitCodeThread I4 >I4'
      '∆TerminateProcess'⎕NA'I4 KERNEL32.C32|TerminateProcess I4 I4'
      '∆TerminateThread'⎕NA'I4 KERNEL32.C32|TerminateThread I4 I4'
      'PeekNamedPipeAvail'⎕NA'I KERNEL32|PeekNamedPipe I I I I >I I'
      'GetLastError'⎕NA'I4 KERNEL32.C32|GetLastError'
      '∆WaitForSingleObject'⎕NA'I KERNEL32|WaitForSingleObject& I I'
      'ReadFileC'⎕NA'I KERNEL32|ReadFile I >C[] I >I I'
      NORMAL_PRIORITY_CLASS←32
      CREATE_SEPARATE_WOW_VDM←2048
      STILL_ACTIVE←259
      CONTROL_C_EXIT←¯1073741510
      ERROR_PROCESS_ABORTED←1067
      WAIT_OBJECT_0←0
      STATUS_WAIT_0←0
      MAX_PATH←520
      STARTF_USESHOWWINDOW←1
      STARTF_USESTDHANDLES←256
      :If 0=⎕NC'directory'
          directory←⊃↑/∆GetCurrentDirectory MAX_PATH MAX_PATH
      :Else
          directory←1⊃ExpandEnvironmentStrings directory MAX_PATH MAX_PATH
      :EndIf
      :If 1<≡commandLine
          stdInput←∊(1↓commandLine),¨⊂⎕UCS 13 10
          commandLine←↑commandLine
      :Else
          stdInput←''
          commandLine←,commandLine
      :EndIf
      commandLine←1⊃ExpandEnvironmentStrings commandLine 2048 2048
      :If Is64Bit
          pad←0
          SECURITY_ATTRIBUTES←20 pad 0 0
          securityAttributes←SECURITY_ATTRIBUTES
          securityAttributes[3]←true
          (validFlag hStdInputRead hStdInputWrite)←CreatePipe 0 0 securityAttributes(0×↑⍴stdInput)
      :Else
          SECURITY_ATTRIBUTES←12 0 0
          securityAttributes←SECURITY_ATTRIBUTES
          securityAttributes[2]←true
          (validFlag hStdInputRead hStdInputWrite)←CreatePipe 0 0 securityAttributes(0×↑⍴stdInput)
      :EndIf
      :If validFlag
          securityAttributes←SECURITY_ATTRIBUTES
          securityAttributes[2+Is64Bit]←true
          (validFlag hStdOutputRead hStdOutputWrite)←CreatePipe 0 0 securityAttributes 0
          :If validFlag
              pEnvironment←GetEnvironmentStrings
              startupInfo←(¯3↓CreateStartupInfo(1+STARTF_USESTDHANDLES)),hStdInputRead,hStdOutputWrite,hStdOutputWrite
              (validFlag processInformation)←CreateProcess null commandLine null null true(NORMAL_PRIORITY_CLASS+CREATE_SEPARATE_WOW_VDM)pEnvironment directory startupInfo 0
              :If validFlag
                  (hProcess hThread processId threadId)←processInformation
                  validFlag←CloseHandle¨hStdInputRead hStdOutputWrite
                  validFlag←FreeEnvironmentStrings pEnvironment
                  :If 0=↑⍴stdInput
                  :OrIf ↑validFlag numberOfBytesWritten←WriteFileC hStdInputWrite(1⊃CharToOemCBuff(⊂stdInput),2⍴↑⍴stdInput)(↑⍴stdInput)0 0
                      validFlag←CloseHandle hStdInputWrite
                      stdOutput←''
                      :Trap 1000
                          :While true STILL_ACTIVE≡2↑∆GetExitCodeProcess hProcess 1
                              :If ↑validFlag cbAvail←PeekNamedPipeAvail hStdOutputRead 0 0 0 0 0
                              :AndIf 0≠cbAvail
                                  validFlag Buffer numberOfBytesRead←ReadFileC hStdOutputRead cbAvail cbAvail 0 0
                                  stdOutput,←1⊃OemCToCharBuff Buffer numberOfBytesRead numberOfBytesRead
                              :EndIf
                          :Until WAIT_OBJECT_0=∆WaitForSingleObject hProcess 10
                          exitCode←1⊃(∆GetExitCodeProcess GetExitCodeProcess)hProcess
                      :Else
                          validFlag←∆TerminateProcess hProcess CONTROL_C_EXIT
                          rc←ERROR_PROCESS_ABORTED
                      :EndTrap
                      (validFlag cbAvail)←PeekNamedPipeAvail hStdOutputRead 0 0 0 0 0
                      :If validFlag
                      :AndIf 0≠cbAvail
                          (validFlag Buffer numberOfBytesRead)←ReadFileC hStdOutputRead cbAvail cbAvail 0 0
                          stdOutput,←1⊃OemCToCharBuff Buffer numberOfBytesRead numberOfBytesRead
                      :EndIf
                      :While true STILL_ACTIVE≡2↑∆GetExitCodeThread hThread 1
                          validFlag←∆TerminateThread hThread STATUS_WAIT_0
                      :EndWhile
                      validFlag←CloseHandle¨hStdOutputRead hProcess hThread
                      stdOutput←{(-0=⍴↑¯1↑⍵)↓⍵}{1↓¨(+\LF=⍵)⊂⍵}{LF,(~(CR,LF)⍷⍵)/⍵}stdOutput
                  :Else
                      rc←GetLastError
                      stdOutput←0↑⊂''
                      validFlag←CloseHandle¨hStdInputWrite hStdOutputRead hProcess hThread
                  :EndIf
              :Else
                  rc←GetLastError
                  stdOutput←0↑⊂''
                  validFlag←CloseHandle¨hStdInputRead hStdInputWrite hStdOutputRead hStdOutputWrite
                  validFlag←FreeEnvironmentStrings pEnvironment
              :EndIf
          :Else
              stdOutput←0↑⊂''
              rc←GetLastError
              validFlag←CloseHandle¨hStdInputRead hStdInputWrite
          :EndIf
      :Else
          stdOutput←0↑⊂''
          rc←GetLastError
      :EndIf
    ∇

    ∇ r←DefaultParms
      :Access Public Shared
      ⍝ Returns a command space with all the parameters and their default settings
      ⍝ you may specify when calling `Application`.
      ⍝
      ⍝ Note that the namespace provides a method `List` which you can use in
      ⍝ order to list all names and their current values.
      ⍝
      ⍝ ## The parameters
      ⍝ ### dir
      ⍝ By default the process is running in the current directory. By
      ⍝ specifying a different directory you can change this.
      ⍝
      ⍝ ### wait
      ⍝ Defaults to 1 which means that `Application` waits until program
      ⍝ finishes. Note the the "result" part returned by `Application` is meaningless
      ⍝ if "wait" is 0: naturally you cannot expect a result in such a case.
      ⍝
      ⍝ ### hidden
      ⍝ Defaults to 0. That means that command.com will show a console window --
      ⍝ just an example. If Dyalog is fired up and the app writes to the
      ⍝ session you will see the session window.
      ⍝
      ⍝ However, if you set this to 1, the session window won't turn up
      ⍝ no matter whether the app does write to it or not.
      ⍝
      ⍝ Note the danger: if APL crashs and no error trapping is used, then
      ⍝ the session manager should pop up. If that is suppressed but setting
      ⍝ "hidden" to 1 then the user has no means to quit that APL task. The only
      ⍝ way to get rid of it is to cancel the process in the task manager.
      r←⎕NS''
      r.dir←''              ⍝ Default: Current Dir
      r.hidden←0            ⍝ Allow Window to pop up
      r.wait←1              ⍝ Wait for app to return
      r.timeoutAfter←0      ⍝ Specify the number of seconds; 0=no timeout
      r.⎕FX'r←List' '{⍵,[⎕io+.1]⍎¨⍵}⎕nl -2'
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ Private stuff

    ∇ r←ExpandEnv string
    ⍝  'C:\Windows\MyDir' ←→ ExpandDir '%WinDir%\MyDir'
      :If '%'∊r←string
          r←1⊃∆ExpandEnvironmentStrings(string 1024 1024)
      :EndIf
    ∇

    ∇ (rc result more)←(ExFns GetExitCodeProcess)processHandle;result
      (rc result more)←0 0 ''
      result←ExFns processHandle 1
      :If 0=↑result
          rc←GetLastError
          more←'Error in GetExitCodeProcess'
      :Else
          result←1⊃result
      :EndIf
    ∇

    ∇ (status rc)←(ExFns WaitForSingleObject)parms;waitForTimeout;handle;full;last;milliseconds
      waitForTimeout←258
      (handle milliseconds)←2↑parms,¯1 ⍝ ¯1=Infinite wait for internal timeout
      (full last)←0(milliseconds←25)⊤milliseconds
      (status rc)←0 ⍬
      :Trap 1000
          :Repeat
              :If ¯1=full←¯1+full
                  milliseconds←last
              :EndIf
              status←ExFns(handle milliseconds)
              :If waitForTimeout≠status
                  :Leave
              :EndIf
          :Until ¯1=full
          :OrIf 0 0≡full last
      :Else
          rc←GetLastError
      :EndTrap
    ∇

    ∇ {(rc more)}←(ExFns GetExitCodeThread)threadHandle;rc_;exitCode
      (rc more)←0 ''
      (rc_ exitCode)←ExFns(threadHandle 1)
      :If 0=rc_
          rc←GetLastError
          more←'Error in "GetExitCodeThread"'
      :EndIf
    ∇

    ∇ {(rc more)}←(ExFns TerminateProcess)Parms;processHandle;exitCode
      (rc more)←0 ''
      (processHandle exitCode)←2↑Parms
      :If 0=ExFns(processHandle exitCode)
          rc←GetLastError
          more←'Error in "TerminateProcess"'
      :EndIf
    ∇

    ∇ r←CR
      :If 82=⎕DR' ' ⍝ Classic version?
          r←⎕UCS 13
      :Else
          r←⎕UCS 9834
      :EndIf
    ∇

    ∇ r←LF
      :If 82=⎕DR' ' ⍝ Classic version?
          r←⎕UCS 10
      :Else
          r←⎕UCS 9689
      :EndIf
    ∇

    ∇ r←QnaType;⎕IO
      ⎕IO←0
      r←(12>{⍎⍵↑⍨¯1+⍵⍳'.'}1⊃'.'⎕WG'APLVersion')⊃'A*'
    ∇

    ∇ r←Is64Bit
      r←'-64'≡¯3↑⎕IO⊃'#'⎕WG'APLVersion'
    ∇

    ∇ r←CreateStartupInfo hiddenFlag;pad
      :If Is64Bit
          pad←0              ⍝ for Dyalog 64-bit
          r←104 pad 0 0 0 0 0 640 480 80 25 30,hiddenFlag,0 0 pad 0 0 0 0
      :Else
          r←68 0 0 0 0 0 640 480 80 25 30,hiddenFlag,0 0 0 0 0 0
      :EndIf
    ∇

    ∇ cmd←EnforceBackslash cmd;ind;path
      cmd←dlb dtb cmd
      :If '"'=1⍴cmd
          ind←+/∧\2>+\'"'=cmd
          path←ind↑cmd
      :Else
          ind←cmd⍳' '
          path←ind↑cmd
      :EndIf
      ((path='/')/path)←'\'
      cmd←path,ind↓cmd
    ∇

:EndClass
