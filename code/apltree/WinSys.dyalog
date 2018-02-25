:Class WinSys
⍝ This class makes a variety of methods available which are somehow related
⍝ to the Windows Operating System.\\
⍝ In particular it features the `GetSystemMetric` function as well as all
⍝ the constants this function is able to deal with.\\
⍝ It also offers the method `GetMsgFromErrCode` which takes a Windows
⍝ error code and returns a message meaningful to humans. Well, hopefully.\\
⍝ Homepage: <http://aplwiki.com/WinSys>\\
⍝ Kai Jaeger ⋄ APL Team Ltd.

    :Include ##.APLTreeUtils

    ⎕IO←0
    ⎕ML←3

    ∇ r←Version
      :Access Public shared
      r←({⍵↑⍨-'.'⍳⍨⌽⍵}⍕⎕THIS)'2.7.0' '2018-02-15'
    ∇

    ∇ History
      :Access Public shared
      ⍝ * 2.7.0:
      ⍝   * Converted from the APL wiki to GitHub.
      ⍝ * 2.6.0:
      ⍝   Method `History` introduced.
      ⍝   `WinSys` is no managed by acre 3.
      ⍝ * 2.5.0:
      ⍝   * This version requires Dyalog 15.0 Unicode or better.
      ⍝   * Old code removed.
      ⍝   * New methods `GetAllDrives` and `GetDriveAndType` added.
      ⍝   * `ShellExecute` is more flexible now regarding the right argument.
      ⍝   * `FindWindow` added.
      ⍝   * Bug fix: `GetModuleFileName` worked on 32-bit systems only.
      ⍝
      ⍝ Note that a couple of functions are deprecated now. Search for `⍝Deprecated⍝`. \\
      ⍝ These functions are not mantained any more and will be removed from `WinSys`
      ⍝ in a future release. See the `OS` class which offers platform-independent
      ⍝ alternatives for these functions.
    ∇

    :Field Public Shared ReadOnly SM_CXSCREEN←0                 ⍝ Screen size
    :Field Public Shared ReadOnly SM_CYSCREEN←1
    :Field Public Shared ReadOnly SM_CXVSCROLL←2                ⍝ Vertical scroll bar width
    :Field Public Shared ReadOnly SM_CYVSCROLL←20               ⍝ Vertical scroll bar arrow bitmap height
    :Field Public Shared ReadOnly SM_CXHSCROLL←21               ⍝ Horizontal scroll bar arrow bitmap width
    :Field Public Shared ReadOnly SM_CYHSCROLL←3                ⍝ Horizontal scroll bar height
    :Field Public Shared ReadOnly SM_CYCAPTION←4                ⍝ Window title height of with frame
    :Field Public Shared ReadOnly SM_CXBORDER←5                 ⍝ 2D window border size
    :Field Public Shared ReadOnly SM_CYBORDER←6
    :Field Public Shared ReadOnly SM_CXFIXEDFRAME←7             ⍝ Frame thickness of non sizable window with caption
    :Field Public Shared ReadOnly SM_CYFIXEDFRAME←8
    :Field Public Shared ReadOnly SM_CXHTHUMB←10                ⍝ Thumb box width in a horizontal scroll bar
    :Field Public Shared ReadOnly SM_CYVTHUMB←9                 ⍝ Thumb box height in a vertical scroll bar
    :Field Public Shared ReadOnly SM_CXICON←11                  ⍝ Def icon size (32x32)
    :Field Public Shared ReadOnly SM_CYICON←12
    :Field Public Shared ReadOnly SM_CXCURSOR←13                ⍝ Cursor size
    :Field Public Shared ReadOnly SM_CYCURSOR←14
    :Field Public Shared ReadOnly SM_CYMENU←15                  ⍝ Menu bar height
    :Field Public Shared ReadOnly SM_CXFULLSCREEN←16            ⍝ Client area size of full-screen window
    :Field Public Shared ReadOnly SM_CYFULLSCREEN←17
    :Field Public Shared ReadOnly SM_CYKANJIWINDOW←18           ⍝ Kanji window height
    :Field Public Shared ReadOnly SM_MOUSEPRESENT←19            ⍝ Mouse hardware installed
    :Field Public Shared ReadOnly SM_DEBUG←22                   ⍝ Windows is debugging version
    :Field Public Shared ReadOnly SM_SWAPBUTTON←23              ⍝ Mouse buttons swapped
    :Field Public Shared ReadOnly SM_CXMIN←28                   ⍝ Min window size
    :Field Public Shared ReadOnly SM_CYMIN←29
    :Field Public Shared ReadOnly SM_CXSIZE←30                  ⍝ Button size in caption or title bar
    :Field Public Shared ReadOnly SM_CYSIZE←31
    :Field Public Shared ReadOnly SM_CXSIZEFRAME←32             ⍝ Border thickness of resizeable window
    :Field Public Shared ReadOnly SM_CYSIZEFRAME←33
    :Field Public Shared ReadOnly SM_CXMINTRACK←34              ⍝ Def min size of window with caption and sizing borders
    :Field Public Shared ReadOnly SM_CYMINTRACK←35
    :Field Public Shared ReadOnly SM_CXDOUBLECLK←36             ⍝ Double-click rectangle
    :Field Public Shared ReadOnly SM_CYDOUBLECLK←37
    :Field Public Shared ReadOnly SM_CXICONSPACING←38           ⍝ Grid cell size in large icon view
    :Field Public Shared ReadOnly SM_CYICONSPACING←39
    :Field Public Shared ReadOnly SM_MENUDROPALIGNMENT←40       ⍝ Pop-up menu alignment
    :Field Public Shared ReadOnly SM_PENWINDOWS←41
    :Field Public Shared ReadOnly SM_DBCSENABLED←42             ⍝ Double-byte character support
    :Field Public Shared ReadOnly SM_CMOUSEBUTTONS←43
    :Field Public Shared ReadOnly SM_SECURE←44                  ⍝ Security present
    :Field Public Shared ReadOnly SM_CXEDGE←45                  ⍝ 3D window border size
    :Field Public Shared ReadOnly SM_CYEDGE←46
    :Field Public Shared ReadOnly SM_CXMINSPACING←47            ⍝ Grid cell size for minimized windows
    :Field Public Shared ReadOnly SM_CYMINSPACING←48
    :Field Public Shared ReadOnly SM_CXSMICON←49                ⍝ Def small icon size
    :Field Public Shared ReadOnly SM_CYSMICON←50
    :Field Public Shared ReadOnly SM_CYSMCAPTION←51             ⍝ Small caption height
    :Field Public Shared ReadOnly SM_CXSMSIZE←52                ⍝ Small caption button size
    :Field Public Shared ReadOnly SM_CYSMSIZE←53
    :Field Public Shared ReadOnly SM_CXMENUSIZE←54              ⍝ Menu bar button size eg MDI child close
    :Field Public Shared ReadOnly SM_CYMENUSIZE←55
    :Field Public Shared ReadOnly SM_ARRANGE←56
    :Field Public Shared ReadOnly SM_CXMINIMIZED←57             ⍝ Minimized window size
    :Field Public Shared ReadOnly SM_CYMINIMIZED←58
    :Field Public Shared ReadOnly SM_CXMAXTRACK←59              ⍝ Def max window size with caption and sizing borders
    :Field Public Shared ReadOnly SM_CYMAXTRACK←60
    :Field Public Shared ReadOnly SM_CXMAXIMIZED←61             ⍝ Maximized top-level window size
    :Field Public Shared ReadOnly SM_CYMAXIMIZED←62
    :Field Public Shared ReadOnly SM_NETWORK←63                 ⍝ Network present
    :Field Public Shared ReadOnly SM_CLEANBOOT←67               ⍝ System start type
    :Field Public Shared ReadOnly SM_CXDRAG←68                  ⍝ Drag operation rectangle
    :Field Public Shared ReadOnly SM_CYDRAG←69
    :Field Public Shared ReadOnly SM_SHOWSOUNDS←70              ⍝ Visualize audible information
    :Field Public Shared ReadOnly SM_CXMENUCHECK←71             ⍝ Menu check-mark bitmap size
    :Field Public Shared ReadOnly SM_CYMENUCHECK←72
    :Field Public Shared ReadOnly SM_SLOWMACHINE←73             ⍝ Slow processor flag
    :Field Public Shared ReadOnly SM_MIDEASTENABLED←74          ⍝ Hebrew/Arabic language flag
    :Field Public Shared ReadOnly SM_MOUSEWHEELPRESENT←75       ⍝ Mouse wheel flag
    :Field Public Shared ReadOnly SM_CMETRICS←76
    :Field Public Shared ReadOnly SM_XVIRTUALSCREEN←76
    :Field Public Shared ReadOnly SM_YVIRTUALSCREEN←77
    :Field Public Shared ReadOnly SM_CXVIRTUALSCREEN←78
    :Field Public Shared ReadOnly SM_CYVIRTUALSCREEN←79
    :Field Public Shared ReadOnly SM_CMONITORS←80
    :Field Public Shared ReadOnly SM_SAMEDISPLAYFORMAT←81

    ∇ {r}←{adminFlag}ShellExecute x;ShellOpen;parms
      :Access Public Shared
      ⍝Deprecated⍝ See the `OS` class.
      ⍝ Simple way to fire up an application or a document.\\
      ⍝ `⍵` can be one of:
      ⍝ * A namespace, typically created by calling [`CreateParms_ShellExecute`](#). This is called a
      ⍝   parameter space.
      ⍝ * A text string typically specifying a document or an EXE, possibly with command line parameters.
      ⍝ In case a text string is passed and the name of the file (first parameter) contains a space then
      ⍝ this filename **must** be enclosed within double quotes.\\
      ⍝ A parameter space is usually created by calling `CreateParms_ShellExecute`. You can then make
      ⍝ amendments to it and pass it as right argument. See there for details.\\
      ⍝ If the defaults are fine for you and you want just start an EXE or, say, display an
      ⍝ HTML file then you can just specify a path, either to the EXE or to the document.\\
      ⍝ You can even specify command line parameters this way but you must enclose `file` with
      ⍝ double quotes (") if it contains blanks. (The `ShellExecute` Windows function does not like
      ⍝ double quotes but we remove them before we call it).\\
      ⍝ The optional left argument defaults to 0 which makes the verb default to "OPEN". By specifying
      ⍝ a 1 here it's going to be "RUNAS" meaning that the application is executed in elevated mode (=with admin rights).
      :If (⎕DR x)∊80 82
          parms←CreateParms_ShellExecute
          :If '"'=1⍴x
              parms.(file lpParms)←x{(⍵↑⍺)(⍵↓⍺)}1++/∧\2>+\'"'=x
          :Else
              parms.(file lpParms)←x{(⍵↑⍺)(⍵↓⍺)}⌊/x⍳' "'
          :EndIf
      :ElseIf 326=⎕DR x
      :AndIf 9=⎕NC'x'
          parms←x
          parms.verb←Uppercase parms.verb
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
      r←ShellOpen parms.(handle verb file lpParms lpDirectory show)
      r←42≠r
    ∇

    ∇ parms←CreateParms_ShellExecute
      :Access Public Shared
      ⍝Deprecated⍝ See the `OS` class.
      ⍝ | **Parameter**| **Notes** |
      ⍝ | `verb`       | Must be one of: EDIT, EXPLORE, FIND, OPEN, PRINT, RUNAS, NULL (default). Note the "RUNAS" is "Open" but with admin rights. |
      ⍝ | `file`       | Name of the file `operation` is performed on. Usually this is an EXE but it can be a document as well. |
      ⍝ | `handle`     | Handle pointing to a window or 0 (default. |
      ⍝ | `show`       | 1 (default) allows the application involved to show its windows. 0 hides any windows. |
      ⍝ | `lpParms`    | Any parameters, for example command line parameters in case the verb is "OPEN". |
      ⍝ | `lpDirectory`| The working direcotry for the application involved. |
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

    ∇ R←CONSTANT Y;name;value;tf;cf
      :Access Public Shared
    ⍝ Returns a string. Executing this string creates a niladic function with
    ⍝ the name of the "Constant". Calling this function returns the desired result.
    ⍝ The function created this way acts in many respects like a "Constant" in
    ⍝ other programming languages.\\
    ⍝ In case `Y` is empty `R` is empty, too.\\
    ⍝ Example:  (creates a function `PI` that returns 3.14)\\
    ⍝ ~~~
    ⍝ ⍎CONSTANT 'PI←3.14'
    ⍝ ~~~
      :If 0∊⍴Y
          R←''
      :Else
          (name value)←Y{(⍵↑⍺)(1↓⍵↓⍺)}Y⍳'←'
          cf←0⊃⎕NSI                     ⍝ Called from
          ('Name is invalid: ',name)⎕SIGNAL 11/⍨¯1=⎕NC name
          tf←''''''≡2⍴¯1⌽value          ⍝ Text flag
          R←∊'⎕FX ''R←',name,'' ''' ''R←',(tf/''''),(⍕value),(tf/''''),''''
      :EndIf
    ∇

    ∇ r←GetVersion;VOID;∆GetVersion;OSVERSIONINFO;rc;multiByte
      :Access Public Shared
   ⍝ Gets the OS version.
   ⍝ |r[1] | Major version
   ⍝ |r[2] | Minor version
   ⍝ |r[3] | BuildNumber
   ⍝ |r[4] | Service pack information or empty
      multiByte←1+80=⎕DR' '   ⍝ Unicode version?!
      '∆GetVersion'⎕NA'I KERNEL32|GetVersionEx* ={I4 I4 I4 I4 I4 T[',(⍕multiByte×128),']}'
      OSVERSIONINFO←((multiByte×128)+5×4)0 0 0 0((multiByte×128)⍴' ')
      (rc r)←∆GetVersion⊂OSVERSIONINFO
      r←r[1 2 3 5]
      r[3]←⊂{⍵↓⍨-+/∧\' '=⌽⍵}3⊃r
    ∇

    ∇ R←ExpandEnv Y;ExpandEnvironmentStrings;multiByte
      :Access Public Shared
    ⍝ If `Y` does not contain any "%", `Y` is passed untouched.\\
    ⍝ In case `Y` is empty `R` is empty as well.\\
    ⍝ Example:\\
    ⍝ ~~~
    ⍝ 'C:\Windows\MyDir' ←→ #.WinSys.ExpandEnv '%WinDir%\MyDir'
    ⍝ ~~~
      :If '%'∊R←Y
          'ExpandEnvironmentStrings'⎕NA'I4 KERNEL32.C32|ExpandEnvironmentStrings* <0T >0T I4'
          multiByte←1+80=⎕DR' '       ⍝ Unicode version? (used to double the buffer size)
          R←1⊃ExpandEnvironmentStrings(Y(multiByte×1024)(multiByte×1024))
      :EndIf
    ∇

    ∇ r←GetDiskFreeSpace drive;GetDiskFreeSpaceEx;rc;freeForCaller;capacity;freeInTotal
      :Access Public Shared
    ⍝ Returns information about a drive.
    ⍝ | r[1] | How many KB are available to caller
    ⍝ | r[2] | Capacity of disk in KB
    ⍝ | r[3] | How many KB are available in total
    ⍝ In case of an error `r ←→ (¯1 ¯1 ¯1)`
      'GetDiskFreeSpaceEx'⎕NA'I KERNEL32|GetDiskFreeSpaceEx* <0T >U[2] >U[2] >U[2]'
      (rc freeForCaller capacity freeInTotal)←GetDiskFreeSpaceEx drive 2 2 2
      :If 0≠rc
          r←⌊(65536*2)⊥¨⌽¨freeForCaller capacity freeInTotal
          r←⌊r÷1000
      :Else
          r←¯1 ¯1 ¯1
      :EndIf
    ∇

    ∇ R←GetComputerName;∆GetComputerName;rc;buffer;size;multiByte
    ⍝ Returns the NETBIOS name of the current system.\\
    ⍝ In case of an error R is empty.
      :Access Public Shared
      '∆GetComputerName'⎕NA'P KERNEL32.C32|GetComputerName* >0T =P'
      multiByte←1+80=⎕DR' '           ⍝ Unicode version? (used to double the buffer size)
      (rc buffer size)←∆GetComputerName multiByte×2⍴32
      R←(0=↑rc)⊃buffer''
    ∇

    ∇ R←GetSystemMetrics Value;∆GetSystemMetrics
      :Access Public Shared
    ⍝ Example: Hight of single line menu bar in pixels:\\
    ⍝ ~~~
    ⍝ #.WinSys.(GetSystemMetrics SM_CYMENU)
    ⍝ ~~~
      '∆GetSystemMetrics'⎕NA'I4 USER32.C32|GetSystemMetrics I4'
      R←∆GetSystemMetrics Value
    ∇

    ∇ R←GetWindowsDirectory;∆GetWindowsDirectory;buffer;size;length;multiByte
      :Access Public Shared
    ⍝ Returns the directory name of the currently running Windows.
      '∆GetWindowsDirectory'⎕NA'I4 KERNEL32.C32|GetWindowsDirectory* >0T =I4'
      multiByte←1+80=⎕DR' '           ⍝ Unicode version? (used to double the buffer size)
      :Trap 0
          (length buffer)←2↑∆GetWindowsDirectory 2⍴multiByte×256
          R←length↑buffer
      :Else
          R←''
      :EndTrap
    ∇

    ∇ r←GetDPI;GetDC;GetDeviceCaps;hdc;sy;ReleaseDC
      :Access Public Shared
    ⍝ Returns the current setting of DPI. Typical settings are 100 (default), 125, 150.\\
    ⍝ Use this to make your application DPI aware.
      ⎕NA'u user32|GetDC u'
      ⎕NA'u user32|ReleaseDC u u'
      ⎕NA'u gdi32|GetDeviceCaps u u'
      hdc←GetDC 0
      sy←GetDeviceCaps hdc 90
      {}ReleaseDC 0 hdc
      r←⌊0.5+100×sy÷96
    ∇

    ∇ (rc exe)←{directory}FindExecutable filename;f;length;buffer;∆FindExecutable;SE_ERR_NOASSOC;SE_ERR_OOM;SE_ERR_ACCESSDENIED;SE_ERR_PNF;SE_ERR_FNF;directory;hinstance;multiByte
      :Access Public Shared
    ⍝ Returns the name of the file associated with the extension of `filename`.\\
    ⍝ For "foo.html" it fires up the default browser, for example.
    ⍝ The optional parameter `directory` allows you to set the default directory.\\
    ⍝ Note that you cannot fake a filename in order to find out what program is
    ⍝ associated with a particular extension. The contents of the file, however,
    ⍝ doesn't matter at all.\\
    ⍝ `exe`: either empty (see `rc`) or the path to the exe which can handle `filename`.\\
    ⍝ `rc`: 0 in case of success, otherwise one of:
      SE_ERR_FNF←2          ⍝ The specified file was not found.
      SE_ERR_PNF←3          ⍝ The specified path is invalid.
      SE_ERR_ACCESSDENIED←5 ⍝ The specified file cannot be accessed.
      SE_ERR_OOM←8          ⍝ The system is out of memory or resources.
      SE_ERR_NOASSOC←31     ⍝ There is no association for the specified file type with an executable file.
      ⍝ ------------------------
      directory←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'directory'
      '∆FindExecutable'⎕NA'I4 shell32.C32|FindExecutable* <0T <0T >0T'
      multiByte←1+80=⎕DR' '           ⍝ Unicode version? (used to double the buffer size)
      (hinstance exe)←∆FindExecutable filename directory(multiByte×1024)
      :If 32<hinstance
          rc←0
      :Else
          rc←hinstance
          exe←''
      :EndIf
    ∇

    ∇ R←GetProcessID;GetCurrentProcessId
     ⍝Deprecated⍝ See the `OS` class.
      :Access Public Shared
     ⍝ Returns the process ID of the current process.\\
     ⍝ In case of an error R is zero.
      :Trap 0
          ⎕NA'I KERNEL32|GetCurrentProcessId'
          R←GetCurrentProcessId
      :Else
          R←0
      :EndTrap
    ∇

    ∇ R←GetAllDrives;Values;Drives;∆GetLogicalDriveStrings;⎕IO;⎕ML
    ⍝ Returns a vector of text vectors with the names of all drives, for example:  "C:\"
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetLogicalDriveStrings'⎕NA'U4 KERNEL32.C32|GetLogicalDriveStrings* U4 >T[]'
      Values←∆GetLogicalDriveStrings 255 255
      Drives←⊂(↑Values)↑(⎕IO+1)⊃Values
      R←((~(⎕UCS 0)=∊Drives)⊂∊Drives)
    ∇

    ∇ R←GetDriveAndType;AllDrives;Txt;Types;∆GetDriveType;⎕IO;⎕ML
     ⍝ Returns a matrix with the names and the types of all drives.\\
     ⍝ The number of rows is defined by the number of drives found.\\
     ⍝ "Types" may be something like "Fixed", "CD-ROM", "Removable", "Remote".
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetDriveType'⎕NA'U4 KERNEL32.C32|GetDriveType* <0T'
      Types←∆GetDriveType∘⊂¨AllDrives←GetAllDrives
      Txt←'Invalid Path' 'Removable' 'Fixed' 'Remote' 'CD-ROM' 'Ram-Disk'
      R←AllDrives,Types,[1.5](Txt,⊂'Unknown')[(0,⍨⍳⍴Txt)⍳Types]
    ∇

    ∇ R←List_SM
      :Access Public Shared
    ⍝ Lists all fields with names that start with "SM\_"
      R←⊃⎕NL-2
      R←(R[;⍳3]∧.='SM_')⌿R
      R←(↓R)~¨' '
    ∇

    ∇ r←GetMsgFrom mid;FORMAT_MESSAGE_IGNORE_INSERTS;FORMAT_MESSAGE_FROM_SYSTEM;FormatMsg;mid;size;LangID;LoadLibrary;this;FORMAT_MESSAGE_FROM_HMODULE;hModule;FreeLibrary;ind;multiByte
      :Access Public Shared
    ⍝ Translate Message ID (mid) to something more useful for human beings.
      FORMAT_MESSAGE_IGNORE_INSERTS←512
      FORMAT_MESSAGE_FROM_HMODULE←2048
      FORMAT_MESSAGE_FROM_SYSTEM←4096
      LangID←0
      'FormatMsg'⎕NA'I KERNEL32|FormatMessage* I4 I4 I4 I4 >T[] I4 I4'
      :If 0>mid←↑mid
      :AndIf ¯16777216≤mid
          mid←-mid
      :EndIf
      multiByte←80=⎕DR' '                  ⍝ Flag: is Unicode
      size←1024×1+multiByte                ⍝ Dynamic buffer size
      r←⊃↑/FormatMsg(FORMAT_MESSAGE_FROM_SYSTEM+FORMAT_MESSAGE_IGNORE_INSERTS)0 mid LangID size size 0
      :If 0∊⍴r
          'LoadLibrary'⎕NA'I KERNEL32|LoadLibrary* <0T'
          ⎕NA'I KERNEL32|FreeLibrary I'
          :For this :In 'ADVAPI32' 'NETMSG' 'WININET' 'WSOCK32'
              :If 0≠hModule←LoadLibrary(⊂this)
                  :If this≡'WSOCK32'
                      ind←10013 10014 10024 10035 10036 10037 10038 10039 10040 10041 10042 10043 10044 10046 10047 10048 10049 10050 10051 10052 10053 10054 10055 10056 10057 10058 10059 10060 10061 10063 10064 10065 10066 10067 10068 10069 10070 10071 10091 10092 10093 10112 11001 11002 11003 11004
                      mid←(10060 10013 10023 10010 10011 10012 10026 10014 10015 10044 10036 10031 10030 10016 10029 10028 10122 10039 10046 10040 10038 10037 10127 10034 10035 10003 10047 10033 10135 10000 10042 10043 10017 10018 10019 10020 10021 10025 10001 10002 10148 10041 10005 10006 10007 10114,mid)[ind⍳mid]
                  :EndIf
                  r←⊃↑/FormatMsg(FORMAT_MESSAGE_FROM_HMODULE+FORMAT_MESSAGE_IGNORE_INSERTS)hModule mid LangID size size 0
                  {}FreeLibrary hModule
                  :If ×↑⍴r
                      :Leave
                  :EndIf
              :EndIf
          :EndFor
      :EndIf
      r←¯2↓r
    ∇

    ∇ (rc info)←GetSystemParametersInfo;font;ncm;val;fsize;nsize;fval;nval;SystemParametersInfo;SPI_GETNONCLIENTMETRICS
  ⍝ Returns the "SystemParametersInfo" structure. See <http://msdn.microsoft.com/en-us/library/ms724947.aspx> for details.
      :Access Public Shared
      font←' {I I I I I U1 U1 U1 U1 U1 U1 U1 U1 T[32]} '
      fval←⊂0 0 0 0 0 0 0 0 0 0 0 0 0(32⍴' ')
      fsize←92
      SPI_GETNONCLIENTMETRICS←41
      nsize←40+5×fsize
      ncm←'{ U4 I I I I I',font,'I I ',font,'I I',font,font,font,' }'
      nval←nsize 0 0 0 0 0,fval,0 0,fval,0 0,fval,fval,fval
      ⎕NA'u user32|SystemParametersInfo* U U =',ncm,'U'
      (rc info)←SystemParametersInfo SPI_GETNONCLIENTMETRICS nsize nval 0
    ∇

    ∇ r←GetFormCaptionFontInfo;rc;info
      :Access Public Shared
      (rc info)←GetSystemParametersInfo
      'Error requesting "SystemParametersInfo"'⎕SIGNAL 11/⍨1≠rc
      r←6⊃info
    ∇

    ∇ h←{className}FindWindow caption;FindWindow
    ⍝ Return handle to window with "caption".\\
    ⍝ Notes:
    ⍝ * `caption` must match the caption of the **window** exactly buy is **not** case sensitive.\\
    ⍝ * `className` is optional. With the default 0 it finds _any_ window that matches `caption`.
    ⍝ For details see <https://msdn.microsoft.com/en-us/library/windows/desktop/ms633499(v=vs.85).aspx>
      :Access Public Shared
      className←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'className'
      'FindWindow'⎕NA'P User32.C32|FindWindow* P <0T'
      h←FindWindow className caption
    ∇

    ∇ h←GetHandleFromCaption caption
    ⍝ Return handle to window with `caption`.\\
    ⍝ Note that `caption` is not case sensitive.\\
    ⍝ This is an alias for `FindWindow`.
      :Access Public Shared
      h←FindWindow caption
    ∇

    ∇ filename←GetModuleFileName dllName;dll;length;buffer;∆GetModuleFileName;∆LoadLibrary
      :Access Public Shared
      ⍝ Retrieves the fully qualified path for the file that contains the specified module.\\
      ⍝ The module must have been loaded by the current process.\\
      ⍝ When `filename` is empty `GetLastError` gives more information.\\
      ⍝ <http://msdn.microsoft.com/en-us/library/windows/desktop/ms683197(v=vs.85).aspx>\\
      ⍝ Note: this method can be helpful to find out which DLL was **really** loaded, in
      ⍝ particular when a DLL is loaded from `.\` because in this case Windows tries
      ⍝ to be smart and not only checks several directories rather than just the working dir!\\
      ⍝ See <https://msdn.microsoft.com/en-us/library/windows/desktop/ms684175(v=vs.85).aspx>
      ⍝ and search for "Remarks" on that page for details.
      filename←''
      ((dllName='/')/dllName)←'\'
      '∆LoadLibrary'⎕NA'P kernel32|LoadLibrary* <0T'
      :If 0<dll←∆LoadLibrary⊂dllName
          '∆GetModuleFileName'⎕NA'P kernel32|GetModuleFileName* P >0T U'
          (length buffer)←∆GetModuleFileName dll 255 255
      :AndIf 0≠length
          filename←length↑buffer
      :EndIf
    ∇

    ∇ r←IsRunningAsAdmin;IsUserAnAdmin
      ⍝ Tells whether this process is being "Run as Administrator"
      :Access Public Shared
      :Trap r←0
          r←⍎⎕NA'I Shell32|IsUserAnAdmin'
      :EndTrap
    ∇

    ∇ {rc}←{posn}SetWindowParms(hwnd size);∆Setwinpos
    ⍝ Use this to specify Posn or Posn + Size for the window `hwnd` is pointing to.\\
    ⍝ Examples:\\
    ⍝ ~~~
    ⍝ ⍝ (Re-)size the window but does not affect the position.:
    ⍝ WinSys.SetWindowParms hwnd (300 400)
    ⍝
    ⍝ ⍝ (Re-)size the window and position it at (5 6):
    ⍝ (5 6) WinSys.SetWindowParms hwnd (300 400)
    ⍝ ~~~
    ⍝ If the function failes it returns 1 otherwise 0.
      :Access Public Shared
      '∆Setwinpos'⎕NA'U4 User32|SetWindowPos P P  I4 I4 I4 I4 U4'
      'Invalid: "size"'⎕SIGNAL 11/⍨2≠⍴,size
      :If 0=⎕NC'posn'
          rc←0=∆Setwinpos hwnd 0 0 0,size,582
      :Else
          'Invalid: "posn"'⎕SIGNAL 11/⍨2≠⍴,posn
          rc←0=∆Setwinpos hwnd 0,posn,size,580
      :EndIf

    ∇

    ∇ R←GetLastError;∆GetLastError;⎕ML;⎕IO
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetLastError'⎕NA'I4 kernel32.C32|GetLastError'
      R←∆GetLastError
    ∇

    ∇ {r}←KillProcess ID;h;PROCESS_TERMINATE;False;OpenProcess;TerminateProcess;CloseHandle
    ⍝Deprecated⍝ See the `OS` class.
    ⍝ Kill one or more processes with ID(s).\\
    ⍝ R is 1 if the process got killed, otherwise 0.
    ⍝Deprecated⍝ See the `OS` class.
      :Access Public Shared
      r←0
      ⎕NA'P KERNEL32.C32|OpenProcess I4 I2 I4'
      PROCESS_TERMINATE←↑83 323 ⎕DR 1
      False←↑83 323 ⎕DR 0
      ⎕NA'U KERNEL32.C32|CloseHandle I4'
      :Repeat
          :If 0≠h←OpenProcess PROCESS_TERMINATE False(↑ID)   ⍝ Get handle to the process
              ⎕NA'KERNEL32.C32|TerminateProcess P I4'
              {}TerminateProcess h 0                         ⍝ Kill it
              r←1
          :End
          {}CloseHandle h
      :Until 0∊⍴ID←1↓ID
    ∇

    ∇ r←Is64Bit
      r←'-64'≡¯3↑⎕IO⊃'#'⎕WG'APLVersion'
    ∇

:EndClass