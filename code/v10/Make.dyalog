﻿:Class Make
⍝ Puts the application `MyApp` together:
⍝ 1. Remove folder `DESTINATION\` in the current directory
⍝ 2. Create folder `DESTINATION\` in the current directory
⍝ 3. Copy icon to `DESTINATION\`
⍝ 4. Copy the INI file template over to `DESTINATION`
⍝ 5. Creates `MyApp.exe` within `DESTINATION\`
    ⎕IO←1 ⋄ ⎕ML←1

    DESTINATION←'MyApp'

    ∇ {filename}←Run offFlag;rc;en;more;F;U;msg;successFlag
      :Access Public Shared      
      (F U)←##.(FilesAndDirs Utilities)
      (rc en more)←F.RmDir DESTINATION
      U.Assert 0=rc
      U.Assert'Create!'F.CheckPath DESTINATION
      (successFlag more)←2↑'images'F.CopyTree DESTINATION,'\images'
      U.Assert successFlag
      (rc more)←'MyApp.ini.template'F.CopyTo DESTINATION,'\MyApp.ini'
      U.Assert 0=rc
      Export'MyApp.exe'
      filename←DESTINATION,'\MyApp.exe'
      :If offFlag
          ⎕OFF
      :EndIf
    ∇

    ∇ {r}←{flags}Export exeName;type;flags;resource;icon;cmdline;try;max;success;details;fn
    ⍝ Attempts to export the application
      r←⍬
      flags←{0<⎕NC ⍵:⍎⍵ ⋄ 8}'flags'       ⍝ 2=BOUND_CONSOLE; 8=RUNTIME
      max←50
      type←'StandaloneNativeExe'
      icon←F.NormalizePath DESTINATION,'\images\logo.ico'
      resource←cmdline←''
      details←''
      details,←⊂'CompanyName' 'My company'
      details,←⊂'ProductVersion'(2⊃##.MyApp.Version)
      details,←⊂'LegalCopyright' 'Dyalog Ltd 2018'
      details,←⊂'ProductName' 'MyApp'
      details,←⊂'FileVersion' (2⊃##.MyApp.Version)
      details←↑details
      success←try←0
      fn←DESTINATION,'\',exeName   ⍝ filename
      :Repeat
          :Trap 11
              2 ⎕NQ'.' 'Bind' fn type flags resource icon cmdline details
              success←1
          :Else
              ⎕DL 0.2
          :EndTrap
      :Until success∨max<try←try+1
      :If 0=success
          ⎕←'*** ERROR: Failed to export EXE to ',fn,' after ',(⍕try),' tries.'
          . ⍝ Deliberate error; allows investigation
      :EndIf
    ∇
:EndClass
