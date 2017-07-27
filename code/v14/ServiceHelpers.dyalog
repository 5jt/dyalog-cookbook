:Class ServiceHelpers

    ∇ {r}←CreateBatFiles dummy;path;cmd;aplexe;wsid
      :Access Public Shared
    ⍝ Write two BAT files to the current directory: 
    ⍝ Install_Service.bat and Uninstall_Service.bat
      r←⍬
      path←#.FilesAndDirs.PWD

      aplexe←'"',(2 ⎕NQ'#' 'GetEnvironment' 'dyalog'),'\dyalogrt.exe"'
      wsid←'"%~dp0\MyAppService.DWS"'
      cmd←aplexe,' ',wsid,' APL_ServiceInstall=MyAppService'
      cmd,←' DYALOG_NOPOPUPS=1 MAXWS=64MB'
      #.APLTreeUtils.WriteUtf8File(path,'\Install_Service.bat')cmd

      cmd←⊂'sc delete MyAppService'
      cmd,←⊂'@echo off'
      cmd,←⊂'    echo Error %errorlevel%'      
      cmd,←⊂'if NOT ["%errorlevel%"]==["0"] ('
      cmd,←⊂'pause'
      cmd,←⊂'exit /b %errorlevel%'
      cmd,←⊂')'
      #.APLTreeUtils.WriteUtf8File(path,'\Uninstall_Service.bat')cmd
     ⍝Done
    ∇

:EndClass
