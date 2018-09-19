:Namespace TestsForServices
⍝ Installs a service "MyAppService" in a folder within the Windows Temp directory with
⍝ a randomly chosen name. The tests then start, pause, continue and stop the service.\\
⍝ They also check whether the application produces the expected results.

    ⎕IO←1 ⋄ ⎕ML←1

    ∇ r←Initial;rc;ini;row;bat;more
      :If #.WinSys.IsRunningAsAdmin
          ∆Path←##.FilesAndDirs.GetTempFilename''
          #.FilesAndDirs.DeleteFile ∆Path
          ∆Path←¯4↓∆Path        ⍝ Because we use it as a folder name no extension needed
          ∆ServiceName←'MyAppService'
          ∆CreateFolderStructure ⍬
          ∆CopyFiles ⍬
          ∆CreateBATs ⍬
          ∆CreateIniFile ⍬
          ∆InstallService ⍬
          ⎕←'*** Service ',∆ServiceName,' successfully installed'
          r←1
      :Else
          ⎕←'Sorry, but you need admin rights to run this test suite!'
          r←0          
      :EndIf    
    ∇

    ∇ R←Test_01(stopFlag batchFlag);⎕TRAP;rc;more
     ⍝ Start, pause, continue and stop the service.
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
     
      (rc more)←∆Execute_SC_Cmd'start'
      →FailsIf 0≠rc
      ∆Pause 2 
      (rc more)←∆Execute_SC_Cmd'query'
      →FailsIf 0≠rc
      →FailsIf 0=∨/'STATE : 4 RUNNING'⍷#.APLTreeUtils.dmb more
     
      (rc more)←∆Execute_SC_Cmd'pause'
      →FailsIf 0≠rc
      ∆Pause 2
      →FailsIf 1≠⍴#.FilesAndDirs.ListFiles ∆Path,'\service\Logs\'
      (rc more)←∆Execute_SC_Cmd'query'
      →FailsIf 0=∨/'STATE : 7 PAUSED'⍷#.APLTreeUtils.dmb more
     
      (rc more)←∆Execute_SC_Cmd'continue'
      →FailsIf 0≠rc
      ∆Pause 2
      (rc more)←∆Execute_SC_Cmd'query'
      →FailsIf 0=∨/'STATE : 4 RUNNING'⍷#.APLTreeUtils.dmb more
     
      (rc more)←∆Execute_SC_Cmd'stop'
      →FailsIf 0≠rc
      ∆Pause 2
      (rc more)←∆Execute_SC_Cmd'query'
      →FailsIf 0=∨/'STATE : 1 STOPPED'⍷#.APLTreeUtils.dmb more
     
      R←∆OK
    ∇

    ∇ R←Test_02(stopFlag batchFlag);⎕TRAP;rc;more;noOfCSVs;success;oldTotal;newTotal;A;F
      ⍝ Start service, check results, give it some more work to do, check and stop it.
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
      (A F)←#.(APLTreeUtils FilesAndDirs)
     
      (rc more)←∆Execute_SC_Cmd'start'
      →FailsIf 0≠rc
      ∆Pause 2
      (rc more)←∆Execute_SC_Cmd'query'
      →FailsIf 0=∨/'STATE : 4 RUNNING'⍷A.dmb more
     
      ⍝ At this point the service will have processed all the text files, so there
      ⍝ must now be some CSV files, including the Total.csv file.
      ⍝ We then copy 6 more text files, so we should see 6 more CSVs & a changed Total.
      oldTotal←↑{','A.Split ⍵}¨A.ReadUtf8File ∆Path,'\input\en\total.csv'
      noOfCSVs←⍴F.ListFiles ∆Path,'\input\en\*.csv'
      (success more list)←(∆Path,'\texts')F.CopyTree ∆Path,'\input\'  ⍝ All of them
      {1≠⍵:.}success
      ∆Pause 2
      newTotal←↑{','A.Split ⍵}¨A.ReadUtf8File ∆Path,'\input\en\total.csv'
      →PassesIf(noOfCSVs+6)=⍴F.ListFiles ∆Path,'\input\en\*.csv'
      →PassesIf oldTotal≢newTotal
      oldTotal[;2]←⍎¨oldTotal[;2]
      newTotal[;2]←⍎¨newTotal[;2]
      →PassesIf oldTotal[;2]∧.≤newTotal[;2]
     
      (rc more)←∆Execute_SC_Cmd'stop'
      →FailsIf 0≠rc
      ∆Pause 2
      (rc more)←∆Execute_SC_Cmd'query'
      →FailsIf 0=∨/'STATE : 1 STOPPED'⍷A.dmb more
     
      R←∆OK
    ∇


    ∇ {r}←GetHelpers
      r←##.Tester.EstablishHelpersIn ⎕THIS
    ∇

    ∇ {r}←Cleanup
      r←⍬
      :If 0<⎕NC'∆ServiceName'
          ∆Execute_SC_Cmd'stop'
          ∆Execute_SC_Cmd'delete'
          ##.FilesAndDirs.RmDir ∆Path
          ⎕EX¨'∆Path' '∆ServiceName'
      :EndIf
    ∇

    ∇ {(rc msg)}←∆Execute_SC_Cmd command;cmd;buff
    ⍝ Executes an SC (Service Control) command
      rc←1 ⋄ msg←'Could not execute the command'
      cmd←'SC ',command,' ',∆ServiceName
      buff←#.Execute.Process cmd
      →FailsIf 0≠1⊃buff
      msg←⊃,/2⊃buff
      rc←3⊃buff
    ∇

    ∇ {r}←∆CheckPath path;success
      r←⍬
      success←'Create!'##.FilesAndDirs.CheckPath path
      'Checking the path failed!'⎕SIGNAL 11/⍨0=success
    ∇

    ∇ {r}←∆CreateFolderStructure dummy
      ##.FilesAndDirs.RmDir ∆Path
      ∆CheckPath ∆Path,'\service'
      ∆CheckPath ∆Path,'\texts'
      ∆CheckPath ∆Path,'\input'
    ∇

    ∇ {r}←from ∆CopyTo to;rc;more;msg
      r←⍬
      (rc more)←from #.FilesAndDirs.CopyTo to
      msg←'Copy failed RC=',(⍕rc),'; ',more
      msg ⎕SIGNAL 11/⍨0≠rc
    ∇

    ∇ {r}←∆CopyFiles dummy;list;more;success;rc
      r←⍬
      (success more list)←'..\..\texts\'#.FilesAndDirs.CopyTree ∆Path,'\texts\'
      {1≠⍵:.}success
      #.FilesAndDirs.DeleteFile↑('recursive' 1)#.FilesAndDirs.Dir ∆Path,'\texts\*.dat'
      'MyAppService/MyAppService.dws'∆CopyTo ∆Path,'\service\'
      'MyAppService/Install_Service.bat'∆CopyTo ∆Path,'\service\'
      (rc more list)←(∆Path,'\texts\')#.FilesAndDirs.CopyTree ∆Path,'\input\'
      {⍵:.}1≠rc
      #.FilesAndDirs.DeleteFile ¯6↑list[;1]  ⍝ We will add these at a later stage
    ∇

    ∇ {r}←∆CreateBATs dummy;bat;rc;more
      r←⍬
      'MyAppService/Install_Service.bat'∆CopyTo ∆Path,'\service\'
      'MyAppService/Uninstall_Service.bat'∆CopyTo ∆Path,'\service\'
    ∇

    ∇ {r}←∆CreateIniFile dummy;ini;row
      'MyAppService/MyApp.ini'∆CopyTo ∆Path,'\service\'
      ini←#.APLTreeUtils.ReadUtf8File ∆Path,'\service\MyApp.ini'
      row←#.APLTreeUtils.Where'Watch='{⍺∘≡¨(⍴,⍺)↑¨(⍵~¨' ')}ini
      ini←(row↑ini),(⊂'Watch ,= ''',∆Path,'\input\en'''),row↓ini
      (1⊃ini)←'localhome = ''',∆Path,'\service'''
      #.APLTreeUtils.WriteUtf8File(∆Path,'\service\MyApp.ini')ini
    ∇

    ∇ {r}←∆InstallService dummy;rc;more
      (rc more)←∆Execute_SC_Cmd'Query ',∆ServiceName
      :If 1060≠rc
          ∆Execute_SC_Cmd'stop'      ⍝ Precautionary measure
          ∆Execute_SC_Cmd'delete'    ⍝ Delete the service
      :EndIf
      rc←#.Execute.Application'cmd /c ',∆Path,'\service\Install_Service.bat'
      {⍵:.}0≠1⊃rc
      (rc more)←∆Execute_SC_Cmd'Query ',∆ServiceName
      →FailsIf 0=∨/'STATE : 1 STOPPED'⍷#.APLTreeUtils.dmb more
    ∇

    ∇ {r}←∆Pause seconds
      r←⍬
      ⎕←'   Pausing for ',(⍕seconds),' seconds...'
      ⎕DL seconds
    ∇

:EndNamespace
