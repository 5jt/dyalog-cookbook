:Namespace Environment
⍝ Dyalog Cookbook, Version 07
⍝ Vern: sjt29sep16

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

   ⍝ aliases in all modes
    (A F I L M U)←#.(APLTreeUtils FilesAndDirs IniFiles Logger MyApp Utilities)

    ∇ Start mode;∆;args;env
    ⍝ Initialise workspace for development, export or running
    ⍝ mode: ['Develop' | 'Export' | 'Run']
      :Select mode
      :Case 'Develop'
          (H T Tr)←#.(HandleError Tests Tester) ⍝ further aliases
      :Case 'Export'
      :Case 'Run'
          H←#.HandleError ⍝ further aliases
          ⍝ trap problems in startup
          #.⎕TRAP←0 'E' '#.HandleError.Process '''''
      :EndSelect
      ⎕WSID←'MyApp'
     
      'CREATE!'F.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←mode{
          ⍵.path←'Logs',F.CurrentSep ⍝ subfolder of current directory
          ⍵.encoding←'UTF8'
          ⍵.filenamePrefix←'MyApp_',⊃⍺ ⍝ distinct logfiles for devt, export and run
          ⍵.refToUtils←#
          ⍵
      }L.CreatePropertySpace
      M.Log←⎕NEW L(,⊂∆)
     
      args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'
      M.Log.Log¨('Command line arg ['∘,¨(⍕¨⍳≢args),¨⊂']: '),¨args
     
      env←U.GetEnv                              ⍝ Windows Environment
      M.PARAMETERS GetParameters mode args env  ⍝ MyApp parameters
     
      ⍝ array components of application icon, already defined in EXE
      :If mode≢'Run'
          IconComponents←⎕NS''
          ∆←⎕NEW'Icon'(('File' '.\images\gear.ico')('Style' 'Small'))
          IconComponents.(Bits CMap Mask)←∆.(Bits CMap Mask)
      :EndIf
     
      :Select mode
     
      :Case 'Develop' ⍝ in active workspace
          #.⎕TRAP←0⍴#.⎕TRAP
          ⎕←'Alphabet is ',M.PARAMETERS.alphabet
          ⎕←'Defined alphabets: ',⍕U.m2n M.PARAMETERS.ALPHABETS.⎕NL 2
          Tr.EstablishHelpersIn T
          T.Run
     
      :Case 'Export' ⍝ to EXE
          ⎕←U.ScriptFollowing
          ⍝ Exporting to an EXE can fail unpredictably.
          ⍝ Retry the following expression if it fails,
          ⍝ or use the File>Export dialogue from the menus.
          ⍝      #.Environment.Export '.\MyApp.exe'
     
      :Case 'Run' ⍝ in EXE
          #.ErrorParms←{
              ⍵.errorFolder←#.FilesAndDirs.PWD
              ⍵.returnCode←#.MyApp.ExitOn'APPLICATION CRASHED'
              ⍵.(logFunctionParent logFunction)←(#.MyApp.Log)('Log')
              ⍵.trapInternalErrors←~#.APLTreeUtils.IsDevelopment
              ⍵
          }H.CreateParms
          #.⎕TRAP←0 'E' '#.HandleError.Process ''#.ErrorParms'''
          mode Off M.TxtToCsv M.PARAMETERS.source
     
      :EndSelect
    ∇

    ∇ msg←Export filename;type;flags;resource;icon;cmdline;nl;success;try
      #.⎕LX←'#.Environment.Start ''Run'''
     
      type←'StandaloneNativeExe'
      flags←2 ⍝ BOUND_CONSOLE
      resource←''
      icon←F.NormalizePath'.\images\gear.ico'
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
      msg,←(try>1)/' after ',(⍕try),' tries'
      M.Log.Log msg
    ∇

    ∇ mode Off job
      :If mode≡'Run'
          ⎕OFF M.ExitOn⊃A.Nest job.status
      :Else
          →
      :EndIf
    ∇

    ∇ p GetParameters(mode args env);fromexe;fromallusers;fromcmdline;fromuser;alp;path;paths;ini;parm;vars;a;∆;PARAMS;k;v
     ⍝ Update parameters in p from defaults and command-line args (if any)
     ⍝ p: (ns)
     
     ⍝ An INI for this app as a sibling of the EXE
      fromexe←(⊃⎕NPARTS⊃args),⎕WSID,'.INI' ⍝ first arg is source of EXE
     ⍝ First INI on the command line, if any
      fromcmdline←{×≢⍵:⊃⍵ ⋄ ''}{⍵/⍨'.INI'∘≡¨¯4↑¨⍵}(1↓args)
     ⍝ An INI for this app in the ALLUSERS profile
      fromallusers←env.ALLUSERSPROFILE,'\',⎕WSID,'.INI'
     ⍝ An INI for this app in the USER profile
      fromuser←env.USERPROFILE,'\',⎕WSID,'.INI'
     
     ⍝ identify INI files to read
      :Select mode
      :Case 'Develop'
          paths←fromexe fromallusers fromuser
      :Case 'Export'
          paths←'' ⍝ export no settings from INI files
      :Case 'Run'
          paths←fromexe fromallusers fromuser fromcmdline
      :EndSelect
      paths←{⍵/⍨⎕NEXISTS¨⍵}F.NormalizePath¨{⍵/⍨×≢¨⍵~¨' '}paths
     
      PARAMS←'accented' 'alphabet' 'source' 'output'
     
      :For path :In paths
         ⍝ Allow INI entries to be case-insensitive
          ini←⎕NEW I(,⊂path)
          vars←U.m2n ini.⎕NL 2
          :For parm :In {⍵/⍨ini.Exist¨'Config:'∘,¨⍵}PARAMS
             ⍝ Alphabet names are title case, eg Greek
              parm p.{⍎⍺,'←⍵'}U.toTitlecase⍣(parm≡'alphabet')⊃ini.Get'Config:',parm
          :EndFor
          :If ini.Exist'Alphabets:'
              ∆←(ini.Convert ⎕NS'') ⍝ FIXME breaks if key names are not valid APL names
              a←∆.⍎'ALPHABETS'U.ciFindin U.m2n ∆.⎕NL 9
             ⍝ Alphabet names are title case, eg Russian
              ∆←,' ',a.⎕NL 2 ⍝ alphabet names
              (U.toTitlecase ∆)M.ALPHABETS.{⍎⍺,'←⍵'}a⍎∆
          :EndIf
      :EndFor
     
      :If mode≡'Run' ⍝ set params from the command line
      :AndIf ×≢a←{⍵/⍨'='∊¨⍵}args
          ∆←a⍳¨'=' ⋄ (k v)←((∆-1)↑¨a)(∆↓¨a)
          ∆←(≢PARAMS)≥i←⊃⍳/U.toUppercase¨¨PARAMS k
          (⍕PARAMS[∆/i]) p.{⍎⍺,'←⍵'}⍣(1∊∆) ⊣∆/{'"'∧.=⊃¨(⍵)(⌽⍵):1↓¯1↓⍵ ⋄ ⍵}¨v
      :EndIf
    ∇


:EndNamespace
