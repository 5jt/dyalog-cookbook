:Class OS
⍝ This class offers methods that return the same result under Windows, Linux (without the PI) and Mac OS.
⍝ Examples are `GetPID` and `KillPID`.\\
⍝ Exceptions are the functions `ShellExecute` (Linux/Mac only) and `WinExecute` (Windows only). They
⍝ perform very similar tasks but with very different parameters and results, so they were separated.\\
⍝ Kai Jaeger - APL Team Ltd.\\
⍝ Homepage: <http://aplwiki.com/OS>

    :Include ##.APLTreeUtils

    ⎕IO←0 ⋄ ⎕ML←3

    ∇ r←Version
      :Access Public shared
      r←(Last⍕⎕THIS)'1.4.0' '2018-02-16'
    ∇

    ∇ History
      :Access Public shared
      ⍝ * 1.4.0
      ⍝   * Converted from the APL wiki to GitHub
      ⍝ * 1.3.1
      ⍝   * Some glitches in the documentation fixed.
      ⍝ * 1.3.0
      ⍝   * Bug fixed in `KillPID`: did not always return a result.
      ⍝   * Method `History` introduced.
      ⍝   * Managed by acre 3 now.
      ⍝ * 1.2.1
      ⍝   * Fix in `ShellExecute`: when `rc` is not 0 then result should be empty and `more` shouldn't.
      ⍝ * 1.2.0
      ⍝   * Documentation improved.
      ⍝   * Bug fix in `ShellExecute` (Linux and Mac OS only).
    ∇

    ∇ (rc more result)←ShellExecute cmd;buff
      :Access Shared Public
      ⍝ Simple way to fire up an application under Linux/Mac OS.\\
      ⍝ cmd must be a command line ready to be executed.
      ⍝ * `rc` is the exit code of the command executed.
      ⍝ * `more` is currently always an empty text vector.
      ⍝ * `result` is what's returned by the command executed.
      result←more←''
      rc←0
      :Trap 11
          cmd←dtb cmd
          :If '&'=¯1↑cmd
              cmd←(¯1↓cmd),' </dev/null 1>/dev/null 2>/dev/null &'
              {}⎕SH cmd
          :Else
              cmd,←' 2>&1; echo "CMDEXIT=$?"; exit 0'
              buff←⎕SH cmd
              rc←⍎(⍴'CMDEXIT=')↓↑¯1↑buff
              :If 0=rc
                  result←¯1↓buff
              :Else
                  more←¯1↓buff
              :EndIf
          :EndIf
      :Else
          rc←1
          more←⎕DMX.Message
      :EndTrap
    ∇

    ∇ {(success rc more)}←{adminFlag}WinExecute x;ShellOpen;parms;flag
      :Access Public Shared
      ⍝ Simple way to fire up an application or a document.\\
      ⍝ Note that you **cannot** catch the standard output of any application executed with `WinExecute`.
      ⍝ However, you might be able to execute it with `WinExecBatch` which _can_ return the standard
      ⍝ output returned by whatever you've executed - see there.
      ⍝
      ⍝ `⍵` can be one of:
      ⍝ * A namespace, typically created by calling [`CreateParms_WinExecute`](#). This is called a
      ⍝   parameter space.
      ⍝ * A text string typically specifying a document or an EXE, possibly with command line parameters.
      ⍝
      ⍝ In case a text string is passed and the name of the file (first parameter: the EXE/document) contains
      ⍝ a space then this filename **must** be enclosed within double quotes.
      ⍝
      ⍝ Any other filename with spaces in the name must be enclosed by double-quotes as well.
      ⍝
      ⍝ A parameter space is usually created by calling `CreateParms_WinExecute`. You can then make
      ⍝ amendments to it and pass it as right argument. See there for details.
      ⍝
      ⍝ If the defaults are fine for you and you want just start an EXE or, say, display an
      ⍝ HTML file then you can just specify a path pointing either to the EXE or to the document.
      ⍝
      ⍝ You can even specify command line parameters this way but you **must** then enclose `file` with
      ⍝ double quotes (") even if the file does not contain any blanks. (The `ShellExecute` Windows function
      ⍝ does not like double quotes but they will be removed before it is called).
      ⍝
      ⍝ The optional left argument defaults to 0 which makes the verb default to "OPEN". By specifying
      ⍝ a 1 here it's going to be "RUNAS" meaning that the application is executed in elevated mode
      ⍝ (=with admin rights). Of course for this the user must have admin rights.
      ⍝
      ⍝ See the test cases for examples.\\
      ⍝ The function returns a three-element vector:
      ⍝ 1. A Boolean flag, 1 indicating success.
      ⍝ 2. The return code of the Windows API function `ShellOpen`. Is 42 in case of success.
      ⍝ 3. An empty text string in case of success. In case of failure this may provide additional information.
      'Runs under Windows only'⎕SIGNAL 11/⍨'Win'≢GetOperatingSystem ⍬
      success←0 ⋄ more←'' ⋄ rc←0
      :If (⎕DR x)∊80 82
          :If 0≠2|'"'+.=x
              more←'Odd nunmber of doubles quotes detected'
              :Return
          :EndIf
          parms←CreateParms_WinExecute
          :If '"'=1⍴x
              parms.(file lpParms)←x{(⍵↑⍺)(⍵↓⍺)}1++/∧\2>+\'"'=x
          :Else
              parms.(file lpParms)←x{(⍵↑⍺)(⍵↓⍺)}⌊/x⍳' "'
          :EndIf
      :ElseIf 326=⎕DR x
      :AndIf 9=⎕NC'x'
          parms←x
          parms.verb←Uppercase parms.verb
          :If 0≠2|'"'+.=parms.lpParms
              more←'Odd nunmber of doubles quotes in "lpParms" detected'
              :Return
          :EndIf
      :Else
          'Invalid right argument'⎕SIGNAL 11
      :EndIf
      'Invalid verb'⎕SIGNAL 11/⍨~(⊂parms.verb)∊'EXPLORE' 'FIND' 'OPEN' 'PRINT' 'RUNAS' ''
      'ShellOpen'⎕NA'U Shell32.C32|ShellExecute* I <0T <0T <0T <0T I'
      adminFlag←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'adminFlag'
      :If adminFlag
          parms.verb←'RUNAS'
      :EndIf
      parms.file~←'"'
      :Trap 0
          rc←ShellOpen parms.(handle verb file lpParms lpDirectory show)
          success←42=rc
      :Else
          rc←⎕EN
          more←⎕DMX.Message
          :Return
      :EndTrap
    ∇

    ∇ parms←CreateParms_WinExecute
      :Access Public Shared
      ⍝ This method returns a parameter space populated with default values that can be fed to the [`WinExecute`](#) method.
      ⍝ | **Parameter**| **Notes** |
      ⍝ | `verb`       | Must be one of: EDIT, EXPLORE, FIND, OPEN, PRINT, RUNAS, NULL (default). Note that "RUNAS" is "Open" with admin rights. |
      ⍝ | `file`       | Name of the file `verb` is performed on. Usually this is an EXE but it can be a document as well. |
      ⍝ | `handle`     | Handle pointing to a window or 0 (default). |
      ⍝ | `show`       | 1 (default) allows the application involved to show its windows. 0 hides any windows. |
      ⍝ | `lpParms`    | Command line parameters in case the verb is "OPEN". |
      ⍝ | `lpDirectory`| The working directory for the application involved. |
      ⍝
      ⍝ For more information see <https://msdn.microsoft.com/en-us/library/windows/desktop/bb762153(v=vs.85).aspx>
      parms←⎕NS''
      parms.verb←''
      parms.file←''
      parms.handle←0
      parms.show←1          ⍝ Allow the app to show its windows. Suppress with  0.
      parms.lpParms←''
      parms.lpDirectory←''
    ∇

    ∇ (success rc result)←{adminFlag}WinExecBatch cmd;batFilename;tempFilename;en;more
    ⍝ This method executes a command and returns its standard output on `result`.\\
    ⍝ ** Don't** use this for programs that interact with a user! For example, don't use
    ⍝ this to fire up an APL session! This cannot work because standard output is redirected.\\
    ⍝ Use `WinExecute` for this which cannot capture standard output itself.\\
    ⍝ Performes the following actions:
    ⍝ * Puts `cmd` into a batch file which is a temp file.
    ⍝ * Execute that batch file with `WinExecute`.
    ⍝ * Circumvent the standard output of the batch file into another temp file.
    ⍝ * Waits until the temp file makes an appearance.
    ⍝ * Reads that temp file and returns the contents as `result`.
    ⍝ \\
    ⍝ * `success` is a Boolean with 1 indicating success.
    ⍝ * `rc` is a return code. 42 stands for "okay".
      :Access Public Shared
      'Runs under Windows only'⎕SIGNAL 11/⍨'Win'≢GetOperatingSystem ⍬
      tempFilename←##.FilesAndDirs.GetTempFilename''
      batFilename←(¯3↓tempFilename),'BAT'
      cmd,←' >',tempFilename
      ##.FilesAndDirs.DeleteFile tempFilename
      WriteUtf8File batFilename cmd
      adminFlag←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'adminFlag'
      (success rc more)←adminFlag WinExecute batFilename
      :If success
          result←{##.FilesAndDirs.IsFile ⍵:ReadUtf8File ⍵ ⋄ _←⎕DL 0.1 ⋄ ∇ ⍵}tempFilename
      :Else
          result←more
      :EndIf
      ##.FilesAndDirs.DeleteFile batFilename tempFilename
    ∇

    ∇ r←GetSharedLib
      :Access Public Shared
      :Select GetOperatingSystem ⍬
      :Case 'Lin'
          r←GetLibcName ⍬
      :Case 'Mac'
          r←'/usr/lib/libc.dylib'
      :Else
          . ⍝ Huuh?!
      :EndSelect
    ∇

    ∇ r←GetPID;∆GetPID;∆GetCurrentProcessId
    ⍝ Returns the process ID of the current process ID.
    ⍝ In case of an error a 0 is returned.\\
    ⍝ See also [`KillPID`](#).
      :Access Public Shared
      :Select GetOperatingSystem ⍬
      :Case 'Win'
          :Trap 11
              '∆GetCurrentProcessId'⎕NA'I KERNEL32|GetCurrentProcessId'
              r←∆GetCurrentProcessId
          :Else
              r←0
          :EndTrap
      :CaseList 'Mac' 'Lin'
          '∆GetPID'⎕NA'I4 ',GetSharedLib,'| getpid'
          :Trap 11
              r←∆GetPID
          :Else
              r←0
          :EndTrap
      :Else
          .⍝ Huuh?!
      :EndSelect
    ∇

    ∇ r←KillPID pid;∆KillPID;PROCESS_TERMINATE;False;OpenProcess;TerminateProcess;h;∆OpenProcess;∆CloseHandle;∆TerminateProcess;thisPID
    ⍝ Kill one or more processes identified by their process ID.\\
    ⍝ See also [`GetPID`](#).
      :Access Public Shared
      r←0
      :Select GetOperatingSystem ⍬
      :Case 'Win'
          '∆OpenProcess'⎕NA'U4 KERNEL32.C32|OpenProcess I4 I2 I4'
          PROCESS_TERMINATE←↑83 323 ⎕DR 1
          False←↑83 323 ⎕DR 0
          '∆CloseHandle'⎕NA'U KERNEL32.C32|CloseHandle I4'
          :Repeat
              thisPID←↑pid
              'Invalid PID: not an integer'⎕SIGNAL 11/⍨0≠1↑0⍴thisPID
              :If 0≠h←∆OpenProcess PROCESS_TERMINATE False thisPID   ⍝ Get handle to the process
                  '∆TerminateProcess'⎕NA'KERNEL32.C32|TerminateProcess P I4'
                  {}∆TerminateProcess h 0                         ⍝ Kill it
                  r←1
              :End
              {}∆CloseHandle h
          :Until 0∊⍴pid←1↓pid
      :CaseList 'Lin' 'Mac'
          '∆KillPID'⎕NA'I4 ',GetSharedLib,'| kill I4 I4'
          :Repeat
              :Trap 11
                  r←∆KillPID 2↑↑pid
              :EndTrap
          :Until 0∊⍴pid←1↓pid
      :Else
          . ⍝ Huuh?!
      :EndSelect
    ∇

⍝ Private stuff

      GetLibcName←{   ⍝ Linux: extract real name of libc that is actually used
          pid←↑⎕SH'echo $PPID'
          libs←⎕SH'ldd /proc/',pid,'/exe'
          ↑('^[[:space:]]*libc\.so\b.*=>[[:space:]]*([^[:space:]]*)'⎕S'\1')libs
      }

    GetAPL_Width←{z←⍵ ⋄ 2×⍬⍴⎕SIZE'z'}

    ∇ r←GetDyaLib
      r←'dyalog',(⍕GetAPL_Width ⍬),'.dylib'
    ∇

:EndClass