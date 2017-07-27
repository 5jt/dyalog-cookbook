:Class Make
⍝ Puts the application `MyApp` together:
⍝ 1. Remove folder `DESTINATION\` in the current directory
⍝ 2. Create folder `DESTINATION\` in the current directory
⍝ 3. Copy icon to `DESTINATION\`
⍝ 4. Copy the INI file template over to `DESTINATION`
⍝ 5. Creates `MyApp.exe` within `DESTINATION\`
⍝ 6. Copy the Help system into `DESTINATION\Help\files`
⍝ 7. Copy the stand-alone Help viewer into `DESTINATION\Help`
    ⎕IO←1 ⋄ ⎕ML←1

    DESTINATION←'MyApp'
    
    ∇ {filename}←Run offFlag;rc;en;more;successFlag;F;U;msg
      :Access Public Shared
      (F U)←##.(FilesAndDirs Utilities)
      (rc en more)←F.RmDir DESTINATION
      U.Assert 0=rc
      U.Assert 'Create!'F.CheckPath DESTINATION
      (successFlag more)←2↑'images'F.CopyTree DESTINATION,'\images'
      U.Assert successFlag
      (rc more)←'MyApp.ini.template'F.CopyTo DESTINATION,'\MyApp.ini'
      U.Assert 0=rc
      (successFlag more)←2↑'Help\files'F.CopyTree DESTINATION,'\Help\files'
      U.Assert successFlag
      (rc more)←'..\apltree\Markdown2Help\help\ViewHelp.exe'F.CopyTo DESTINATION,'\Help\'
      U.Assert 0=rc
      Export'MyApp.exe'
      filename←DESTINATION,'\MyApp.exe'
      :If offFlag
          ⎕OFF
      :EndIf
    ∇
    
    ∇ {r}←{flags}Export exeName;type;flags;resource;icon;cmdline;try;max;success
    ⍝ Attempts to export the application
      r←⍬
      flags←{0<⎕NC ⍵:⍎⍵ ⋄ 8}'flags'       ⍝ 2=BOUND_CONSOLE; 8=RUNTIME
      max←50
      type←'StandaloneNativeExe'
      icon←F.NormalizePath DESTINATION,'\images\logo.ico'
      resource←cmdline←''
      success←try←0
      :Repeat
          :Trap 11
              2 ⎕NQ'.' 'Bind',(DESTINATION,'\',exeName)type flags resource icon cmdline
              success←1
          :Else
              ⎕DL 0.2
          :EndTrap
      :Until success∨max<try←try+1
      :If 0=success
          ⎕←'*** ERROR: Failed to export EXE to ',DESTINATION,'\',exeName,' after ',(⍕try),' tries.'
          . ⍝ Deliberate error; allows investigation
      :EndIf
    ∇

:EndClass
