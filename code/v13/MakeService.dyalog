﻿:Class MakeService
⍝ Creates a workspace "MyAppService" which can then run as a service.
⍝ * Re-create folder DESTINATION in the current directory
⍝ * Copy the INI file template over to DESTINATION\ as MyApp.ini
⍝ * Save the workspace within DESTINATION
    ⎕IO←1 ⋄ ⎕ML←1
    DESTINATION←'MyAppService'

    ∇ {r}←Run offFlag;en;rc;more;F;U
      :Access Public Shared
      r←⍬
      (F U)←##.(FilesAndDirs Utilities)
      (rc en more)←F.RmDir DESTINATION
      U.Assert 0=rc
      U.Assert 'Create!'F.CheckPath DESTINATION
      'MyApp.ini.template' CopyTo DESTINATION,'\MyApp.ini'
      'Install_Service.bat' CopyTo DESTINATION,'\'
      'Uninstall_Service.bat' CopyTo DESTINATION,'\'
      ⎕WSID←DESTINATION,'\',DESTINATION
      #.⎕EX⍕⎕THIS
      0 ⎕SAVE ⎕WSID
      {⎕OFF}⍣(⊃offFlag)⊣⍬      
    ∇
    
    ∇ {r}←from CopyTo to;rc;more;msg
      r←⍬
      (rc more)←from F.CopyTo to
      msg←'Copy failed RC=' ,(⍕rc),'; ',more
      msg ⎕signal 11/⍨0≠rc
    ∇
:EndClass
