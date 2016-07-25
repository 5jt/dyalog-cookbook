:Namespace Environment
⍝ Dyalog Cookbook, Version 06
⍝ Vern: sjt25jul16

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    U←#.Utilities ⍝ must be defined previously

    ∇ Start mode;∆
    ⍝ Initialise workspace for development, export or use
    ⍝ mode: ['Develop' | 'Export' | 'Run']
      :If mode≡'Run`'
          ⍝ trap problems in startup
          #.⎕TRAP←0 'E' '#.HandleError.Process '''''
      :EndIf
      ⎕WSID←'MyApp'
     
      'CREATE!'#.WinFile.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←{
          ⍵.path←'Logs\' ⍝ subfolder of current directory
          ⍵.encoding←'UTF8'
          ⍵.filenamePrefix←'MyApp'
          ⍵.refToUtils←#
          ⍵
      }#.Logger.CreatePropertySpace
      #.MyApp.Log←⎕NEW #.Logger(,⊂∆)
     
      #.MyApp.Params←mode GetParameters #.MyApp.PARAMETERS 
     
      :Select mode
     
      :Case 'Develop'
          #.⎕TRAP←0⍴#.⎕TRAP
          ⎕←'Alphabet is ',#.MyApp.Params.alphabet
          ⎕←'Defined alphabets: ',⍕U.m2n #.MyApp.Params.ALPHABETS.⎕NL 2
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
              ⍵.errorFolder←#.WinFile.PWD
              ⍵.returnCode←#.MyApp.EXIT.APPLICATION_CRASHED
              ⍵.(logFunctionParent logFunction)←(#.MyApp.Log)('Log')
              ⍵.trapInternalErrors←~#.APLTreeUtils.IsDevelopment
          }#.HandleError.CreateParms
          #.⎕TRAP←0 'E' '#.HandleError.Process ''#.ErrorParms'''
          Off #.MyApp.TxtToCsv #.MyApp.Params.source
     
      :EndSelect
    ∇

    ∇ msg←Export filename;type;flags;resource;icon;cmdline;nl
      #.⎕LX←'#.Environment.Start ''Run'''
     
      type←'StandaloneNativeExe'
      flags←2 ⍝ BOUND_CONSOLE
      resource←''
      icon←'.\images\gear.ico'
      cmdline←''
      :Trap 0
          2 ⎕NQ'.' 'Bind',filename type flags resource icon cmdline
          msg←'Exported ',filename
      :Else
          msg←'**ERROR: Failed to export EXE.'
      :EndTrap
    ∇

    ∇ Off returncode
      :If #.APLTreeUtils.IsDevelopment
          →
      :Else
          ⎕OFF returncode
      :EndIf
    ∇

    ∇ p←mode GetParameters p;args;fromexe;fromallusers;fromcmdline;fromuser;env;alp;path;paths;ini;parm;vars;a;∆;PARAMS;k;v
     ⍝ Derive parameters from defaults and command-line args (if any)
     
      args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'   ⍝ Command Line
      env←U.GetEnv                          ⍝ Windows Environment
     
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
          ∆←a⍳¨'=' ⋄ (k v)←((∆-1)↑¨a)((∆+1)↓¨a)
          ∆←(≢PARAMS)≥i←⊃⍳/U.toUppercase¨¨PARAMS k
          (⍕PARAMS[∆/i])p.{⍎⍺,'←⍵'}∆/v
      :EndIf
    ∇


:EndNamespace
