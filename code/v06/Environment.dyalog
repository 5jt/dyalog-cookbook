:Namespace Environment
⍝ Dyalog Cookbook, Version 06
⍝ Vern: sjt10aug16

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    U←#.Utilities ⍝ must be defined previously

    ∇ Start mode;∆;args;env
    ⍝ Initialise workspace for development, export or use
    ⍝ mode: ['Develop' | 'Export' | 'Run']
      :If mode≡'Run'
          ⍝ trap problems in startup
          #.⎕TRAP←0 'E' '#.HandleError.Process '''''
      :EndIf
      ⎕WSID←'MyApp'
     
      'CREATE!'#.FilesAndDirs.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←mode{
          ⍵.path←'Logs\' ⍝ subfolder of current directory
          ⍵.encoding←'UTF8'
          ⍵.filenamePrefix←'MyApp_',⊃⍺ ⍝ distinct logfiles for devt, export and run
          ⍵.refToUtils←#
          ⍵
      }#.Logger.CreatePropertySpace
      #.MyApp.Log←⎕NEW #.Logger(,⊂∆)
     
      args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'   ⍝ command line
      #.MyApp.Log.Log¨('Command line arg ['∘,¨(⍕¨⍳≢args),¨⊂']: '),¨args
     
      env←U.GetEnv                          ⍝ Windows Environment
      #.MyApp.PARAMETERS GetParameters mode args env
     
      :Select mode
     
      :Case 'Develop'
          #.⎕TRAP←0⍴#.⎕TRAP
          ⎕←'Alphabet is ',#.MyApp.PARAMETERS.alphabet
          ⎕←'Defined alphabets: ',⍕U.m2n #.MyApp.PARAMETERS.ALPHABETS.⎕NL 2
          #.Tester.EstablishHelpersIn #.Tests
          #.Tests.Run
     
      :Case 'Export'
          ⎕←U.ScriptFollowing
          ⍝ Exporting to an EXE can fail unpredictably.
          ⍝ Retry the following expression if it fails,
          ⍝ or use the File>Export dialogue from the menus.
          ⍝      #.Environment.Export '.\MyApp.exe'
     
      :Case 'Run'
          #.ErrorParms←{
              ⍵.errorFolder←#.FilesAndDirs.PWD
              ⍵.returnCode←#.MyApp.EXIT.APPLICATION_CRASHED
              ⍵.(logFunctionParent logFunction)←(#.MyApp.Log)('Log')
              ⍵.trapInternalErrors←~#.APLTreeUtils.IsDevelopment
              ⍵
          }#.HandleError.CreateParms
          #.⎕TRAP←0 'E' '#.HandleError.Process ''#.ErrorParms'''
          mode Off #.MyApp.TxtToCsv #.MyApp.PARAMETERS.source
     
      :EndSelect
    ∇

    ∇ msg←Export filename;type;flags;resource;icon;cmdline;nl;success;try
      #.⎕LX←'#.Environment.Start ''Run'''
     
      type←'StandaloneNativeExe'
      flags←2 ⍝ BOUND_CONSOLE
      resource←''
      icon←'.\images\gear.ico'
      cmdline←''
     
      success←try←0
      :Repeat
          :Trap 11
              2 ⎕NQ'.' 'Bind',filename type flags resource icon cmdline
              success←1
          :Else
              ⎕DL 0.2
          :EndTrap
      :Until success∨50<try+←1
      msg←⊃success⌽('**ERROR: Failed to export EXE')('Exported ',filename)
      msg,←(try>1)/' after ',(⍕try),'tries'
      #.MyApp.Log.Log msg
    ∇

    ∇ mode Off returncode
      :If mode≡'Run'
          ⎕OFF returncode
      :Else
          →
      :EndIf
    ∇

    ∇ p GetParameters(mode args env);fromexe;fromallusers;fromcmdline;fromuser;alp;path;paths;ini;parm;vars;a;∆;PARAMS;k;v
     ⍝ Derive parameters from defaults and command-line args (if any)
     
     ⍝ An INI for this app as a sibling of the EXE
      fromexe←(⊃⎕NPARTS⊃args),⎕WSID,'.INI' ⍝ first arg is source of EXE
     ⍝ First INI on the command line, if any
      fromcmdline←{×≢⍵:⊃⍵ ⋄ ''}{⍵/⍨'.INI'∘≡¨¯4↑¨⍵}(1↓args)
     ⍝ An INI for this app in the ALLUSERS profile
      fromallusers←env.ALLUSERSPROFILE,'\',⎕WSID,'.INI'
     ⍝ An INI for this app in the USER profile
      fromuser←env.USERPROFILE,'\',⎕WSID,'.INI'
     
      :Select mode
      :Case 'Develop'
          paths←fromexe fromallusers fromuser
      :Case 'Export'
          paths←''
      :Case 'Run'
          paths←fromexe fromallusers fromcmdline
      :EndSelect
     
      PARAMS←'accented' 'alphabet' 'source' 'output'
     
      :For path :In {⍵/⍨⎕NEXISTS¨⍵}{⍵/⍨×≢¨U.trim¨⍵}paths
         ⍝ Allow INI entries to be case-insensitive
          ini←⎕NEW #.IniFiles(,⊂path)
          vars←U.m2n ini.⎕NL 2
          :For parm :In {⍵/⍨ini.Exist¨'Config:'∘,¨⍵}PARAMS
             ⍝ Alphabet names are title case, eg Greek
              parm p.{⍎⍺,'←⍵'}U.toTitlecase⍣(parm≡'alphabet')⊃ini.Get'Config:',parm
          :EndFor
          :If ini.Exist'Alphabets:'
              ∆←(ini.Convert ⎕NS'') ⍝ breaks if key names are not valid APL names
              a←∆.⍎'ALPHABETS'U.ciFindin U.m2n ∆.⎕NL 9
             ⍝ Alphabet names are title case, eg Russian
              ∆←,' ',a.⎕NL 2 ⍝ alphabet names
              (U.toTitlecase ∆)p.ALPHABETS.{⍎⍺,'←⍵'}a⍎∆
          :EndIf
      :EndFor
     
      :If mode≡'Run' ⍝ set params from the command line
      :AndIf ×≢a←{⍵/⍨'='∊¨⍵}args
          ∆←a⍳¨'=' ⋄ (k v)←((∆-1)↑¨a)(∆↓¨a)
          ∆←(≢PARAMS)≥i←⊃⍳/U.toUppercase¨¨PARAMS k
          (⍕PARAMS[∆/i])p.{⍎⍺,'←⍵'}(⊃⍣(1=+/∆))∆/v
      :EndIf
    ∇


:EndNamespace
