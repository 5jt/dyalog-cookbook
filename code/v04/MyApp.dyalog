:Namespace MyApp
⍝ Dyalog Cookbook, Version 04
⍝ Error handling
⍝ Vern: sjt03jun16

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    (A F H L)←#.(APLTreeUtils FilesAndDirs HandleError Logger) ⍝ from APLTree
    (C U)←#.(Constants Utilities) ⍝ must be defined previously

⍝ Constants

    :Namespace EXIT
       ⍝ Custom Windows exit codes
        OK←0
        APPLICATION_CRASHED←100
        INVALID_SOURCE←101
        SOURCE_NOT_FOUND←102
        UNABLE_TO_READ_SOURCE←103
        UNABLE_TO_WRITE_TARGET←104
        INVALID_ALPHABET_NAME←105
    :EndNamespace

⍝ === VARIABLES ===

    ∆←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝάΆέΈήΉίϊΐΊόΌύϋΎώΏ'
    ACCENTS←↑∆ 'AAAAAACDEEEEIIIINOOOOOOUUUUYΑΑΕΕΗΗΙΙΙΙΟΟΥΥΥΩΩ'

⍝ === End of variables definition ===

      CountLetters←{
          accents←↓ACCENTS/⍨~ACCENTS[2;]∊⍺ ⍝ ignore accented chars in alphabet ⍺
          ⍺{⍵[⍺⍋⍵[;1];]}{×≢⍵:{⍺(≢⍵)}⌸⍵ ⋄ 0 2⍴' ' 0}⍺{⍵⌿⍨⍵∊⍺}accents U.map U.toUppercase ⍵
      }

      retry←{
          ⍺←⊣
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          ⍺ ⍺⍺ ⍵
      }

    ∇ Start mode;exit
    ⍝ Initialise workspace for session or application
    ⍝ mode: ['Application' | 'Session']
      :If mode≡'Application'
          ⍝ trap problems in startup
          ⎕TRAP←0 'E' '#.HandleError.Process '''''
      :EndIf
      ⎕WSID←'MyApp'
      Params←GetParameters mode
      :Select mode
      :Case 'Session'
          ⎕←'Alphabet is ',Params.alphabet
          ⎕←'Defined alphabets: ',⍕U.m2n Params.ALPHABETS.⎕NL 2
          #.⎕LX←'#.MyApp.Start ''Application''' ⍝ ready to export
      :Case 'Application'
          exit←TxtToCsv Params.source
          Off exit
      :EndSelect
    ∇

    ∇ Off returncode
      :If A.IsDevelopment
          →
      :Else
          ⎕OFF returncode
      :EndIf
    ∇

    ∇ p←GetParameters mode;args;fromexe;fromallusers;fromcmdline;fromuser;env;alp;path;paths;ini;parm;vars;a;∆;PARAMS;k;v
     ⍝ Derive parameters from defaults and command-line args (if any)
     
     ⍝ Application defaults: in the absence of any other values
      (p←⎕NS'').(accented alphabet source output)←0 'English' '' '' ⍝ defaults
      p.ALPHABETS←⎕NS'' ⍝ container for new alphabet definitions
      p.ALPHABETS.English←⎕A
      p.ALPHABETS.French←'AÁÂÀBCÇDEÈÊÉFGHIÌÍÎJKLMNOÒÓÔPQRSTUÙÚÛVWXYZ'
      p.ALPHABETS.German←'AÄBCDEFGHIJKLMNOÖPQRSßTUÜVWXYZ'
      p.ALPHABETS.Greek←'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'
     
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
      :Case 'Application'
          paths←fromexe fromallusers fromcmdline
      :Case 'Session'
          paths←fromexe fromallusers fromuser
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
     
      :If mode≡'Application' ⍝ set params from the command line
      :AndIf ×≢a←{⍵/⍨'='∊¨⍵}args
          ∆←a⍳¨'=' ⋄ (k v)←((∆-1)↑¨a)((∆+1)↓¨a)
          ∆←(≢PARAMS)≥i←⊃⍳/U.toUppercase¨¨PARAMS k
          (⍕PARAMS[∆/i]) p.{⍎⍺,'←⍵'} ∆/v
      :EndIf
    ∇

    ∇ exit←TxtToCsv fullfilepath;∆;Log;LogError;files;alpha;out
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text
      'CREATE!'F.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←L.CreatePropertySpace
      ∆.path←'Logs\' ⍝ subfolder of current directory
      ∆.encoding←'UTF8'
      ∆.filenamePrefix←'MyApp'
      ∆.refToUtils←#
      Log←⎕NEW L(,⊂∆)
     
      Log.Log'Started MyApp in ',F.PWD
      Log.Log'Source: ',fullfilepath
     
     ⍝ Output defaults to CSV sibling of source
      :If 0=×≢out←Params.output
      :select C.NINFO.TYPE ⎕NINFO fullfilepath
      :case C.TYPES.DIRECTORY
          out←{'.CSV',⍨⍵↓⍨-'\'=⊃⌽⍵}fullfilepath
      :case C.TYPES.FILE
          out←(⊃,/2↑⎕NPARTS fullfilepath),'.CSV'
      :endselect
      :EndIf
     
      LogError←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
     
      ⍝ Refine trap definition
      #.ErrorParms←H.CreateParms
      #.ErrorParms.errorFolder←F.PWD
      #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED
      #.ErrorParms.(logFunctionParent logFunction)←Log'Log'
      #.ErrorParms.trapInternalErrors←~A.IsDevelopment
      :If A.IsDevelopment
          ⎕TRAP←0⍴⎕TRAP
      :Else
          ⎕TRAP←0 'E' '#.HandleError.Process ''#.ErrorParms'''
      :EndIf
     
      :If EXIT.OK=⊃(exit files alpha)←Params CheckAgenda fullfilepath
          exit←alpha CountLettersIn files out
      :EndIf
      Log.Log'All done'
    ∇

    ∇ (exit files alphabet)←params CheckAgenda fullfilepath;type
      (files alphabet)←'' '' ⍝ error defaults
      :If 0=≢fullfilepath~' '
      :OrIf ~⎕NEXISTS fullfilepath
          exit←LogError'SOURCE_NOT_FOUND'
      :ElseIf ~(type←C.NINFO.TYPE ⎕NINFO fullfilepath)∊C.NINFO.TYPES.(DIRECTORY FILE)
          exit←LogError'INVALID_SOURCE'
      :ElseIf 2≠params.(ALPHABETS.⎕NC alphabet)
          exit←LogError'INVALID_ALPHABET_NAME'
      :Else
          exit←EXIT.OK
          :Select type
          :Case C.NINFO.TYPES.DIRECTORY
              files←⊃(⎕NINFO⍠'Wildcard' 1)fullfilepath,'\*.txt'
          :Case C.NINFO.TYPES.FILE
              files←,⊂fullfilepath
          :EndSelect
          alphabet←params.{(ALPHABETS⍎alphabet)~(~accented)/⍵}ACCENTS[1;]
      :EndIf
    ∇

    ∇ exit←alphabet CountLettersIn(files tgt);i;txt;tbl;enc;nl;lines;bytes
     ⍝ Exit code from writing a letter-frequency count for a list of files
      tbl←0 2⍴'A' 0
      exit←EXIT.OK ⋄ i←1
      :While exit=EXIT.OK
          :Trap 0
              (txt enc nl)←⎕NGET retry i⊃files
              tbl⍪←alphabet CountLetters txt
          :Else
              exit←LogError'UNABLE_TO_READ_SOURCE'
          :EndTrap
          ⍝ . ⍝ DEBUG
      :Until (≢files)<i←i+1
      :If exit=EXIT.OK
          lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
          :Trap 0
              bytes←(lines enc nl)⎕NPUT retry tgt C.NPUT.OVERWRITE
          :Else
              exit←LogError'UNABLE_TO_WRITE_TARGET'
              bytes←0
          :EndTrap
          Log.Log(⍕bytes),' bytes written to ',tgt
      :EndIf
    ∇

:EndNamespace
