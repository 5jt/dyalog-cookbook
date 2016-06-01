:Namespace MyApp
⍝ Dyalog Cookbook, Version 04
⍝ Error handling
⍝ Vern: sjt01jun16

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    (A H L W)←#.(APLTreeUtils HandleError Logger WinFile) ⍝ from APLTree
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

    :Namespace ALPHABETS
        English←⎕A
        French←'AÁÂÀBCÇDEÈÊÉFGHIÌÍÎJKLMNOÒÓÔPQRSTUÙÚÛVWXYZ'
        German←'AÄBCDEFGHIJKLMNOÖPQRSßTUÜVWXYZ'
        Greek←'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'
    :EndNamespace

⍝ === VARIABLES ===

    ∆←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝάΆέΈήΉίϊΐΊόΌύϋΎώΏ'
    ACCENTS←↑∆ 'AAAAAACDEEEEIIIINOOOOOOUUUUYΑΑΕΕΗΗΙΙΙΙΟΟΥΥΥΩΩ'

⍝ === End of variables definition ===

      CountLetters←{
          accents←↓ACCENTS/⍨~ACCENTS[2;]∊⍺ ⍝ ignore accented chars in alphabet ⍺
          ⍺{⍵[⍺⍋⍵[;1];]}{⍺(≢⍵)}⌸⍺{⍵⌿⍨⍵∊⍺}accents U.map U.toUppercase ⍵
      }

      retry←{
          ⍺←⊣
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          ⍺ ⍺⍺ ⍵
      }

    ∇ Start mode
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
          #.⎕LX←'Start ''Application''' ⍝ ready to export
      :Case 'Application'
          exit←Params TxtToCsv Params.source
          Off exit
      :EndSelect
    ∇
    
    ∇ Off returncode
      :If #.A.IsDevelopment
        →
      :Else
        ⎕OFF returncode
      :Endif
    ∇

    ∇ p←GetParameters mode;args;fromexe;fromallusers;fromcmdline;fromuser;env;paths;ini;alp
     ⍝ Derive parameters from defaults and command-line args (if any)

     ⍝ Application defaults: in the absence of any other values
      (p←⎕NS'').(accented alphabet source)←0 'English' '' ⍝ defaults
      p.ALPHABETS←⎕NS'' ⍝ container for new alphabet definitions
     
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

      :If ×≢paths←{⍵/⍨⎕NEXISTS¨⍵}{⍵/⍨×≢¨⍵~¨U.trim¨⍵}paths
          ini←(⎕NEW #.IniFiles paths).Convert p ⍝ FIXME alphabet defns?
         ⍝ read only specific parameters
          :If ×ini.⎕NC'alphabetName' ⋄ p.alphabetName←ini.defaultalphabet ⋄ :EndIf
          :If ×ini.⎕NC'source' ⋄ p.source←ini.source ⋄ :EndIf
         ⍝ import definitions into ALPHABETS
          :For alp :In ↓p.ALPHABETS.⎕NC 2
              ⍎'ALPHABETS.',alp,'←p,ALPHABETS.',alp
          :EndFor
      :EndIf
    ∇

    ∇ exit←{alphabetName}TxtToCsv fullfilepath;∆;isDev;Log;LogError;files;tgt;alpha
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text
      'CREATE!'W.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←L.CreatePropertySpace
      ∆.path←'Logs\' ⍝ subfolder of current directory
      ∆.encoding←'UTF8'
      ∆.filenamePrefix←'MyApp'
      ∆.refToUtils←#
      Log←⎕NEW L(,⊂∆)
      Log.Log'Started MyApp in ',W.PWD
      Log.Log'Source: ',fullfilepath
     
      LogError←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
     
      isDev←'Development'≡4⊃'.'⎕WG'APLVersion'
      ⍝ refine trap definition
      #.ErrorParms←H.CreateParms
      #.ErrorParms.errorFolder←W.PWD
      #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED
      #.ErrorParms.(logFunctionParent logFunction)←Log'Log'
      #.ErrorParms.trapInternalErrors←~isDev
      :If isDev
          ⎕TRAP←0⍴⎕TRAP
      :Else
          ⎕TRAP←0 'E' '#.HandleError.Process ''#.ErrorParms'''
      :EndIf
     
      :If 2≠⎕NC'alphabetName' ⋄ alphabetName←Params.alphabetName ⋄ :EndIf
     
      :If EXIT.OK=⊃(exit files alpha)←CheckAgenda alphabetName fullfilepath
          Log.Log'Target: ',tgt←(⊃,/2↑⎕NPARTS fullfilepath),'.CSV'
          exit←alpha CountLettersIn files tgt
      :EndIf
      Log.Log'All done'
    ∇

    ∇ (exit files alphabet)←CheckAgenda(alphabetName fullfilepath);type
      :If 0=≢fullfilepath~' '
      :OrIf ~⎕NEXISTS fullfilepath
          (exit files alphabet)←(LogError'SOURCE_NOT_FOUND')('')('')
      :ElseIf ~(type←C.NINFO.TYPE ⎕NINFO fullfilepath)∊C.NINFO.TYPES.(DIRECTORY FILE)
          (exit files alphabet)←(LogError'INVALID_SOURCE')('')('')
      :ElseIf 2≠ALPHABETS.⎕NC alphabetName
          (exit files alphabet)←(LogError'INVALID_ALPHABET_NAME')('')('')
      :Else
          exit←EXIT.OK
          :Select type
          :Case C.NINFO.TYPES.DIRECTORY
              files←⊃(⎕NINFO⍠'Wildcard' 1)fullfilepath,'\*.txt'
          :Case C.NINFO.TYPES.FILE
              files←,⊂fullfilepath
          :EndSelect
          alphabet←ALPHABETS⍎alphabetName
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
