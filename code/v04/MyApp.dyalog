:Namespace MyApp
⍝ Dyalog Cookbook, Version 03
⍝ Error handling
⍝ Vern: sjt02may16

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    (A H L W)←#.(APLTreeUtils HandleError Logger WinFile) ⍝ from APLTree
    (C U)←#.(Constants Utilities) ⍝ must be defined previously

    :Namespace EXIT
       ⍝ Custom Windows exit codes
        OK←0
        APPLICATION_CRASHED←100
        INVALID_SOURCE←101
        SOURCE_NOT_FOUND←102
        UNABLE_TO_READ_SOURCE←103
        UNABLE_TO_WRITE_TARGET←104
    :EndNamespace

⍝ === VARIABLES ===

    ACCENTS←↑'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}(↓ACCENTS)U.map U.caseUp ⍵
      }

      retry←{
          ⍺←⊣
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          ⍺ ⍺⍺ ⍵
      }

    ∇ SetLX
    ⍝ set Latent Expression ready to export EXE
      #.⎕LX←'StartFromCmdLine'
    ∇

    ∇ StartFromCmdLine;exit;args
     ⍝ Read command parameters, run the application
      ⎕TRAP←0 'E' '#.HandleError.Process ''''' ⍝ trap unforeseen problems 
      ⎕WSID←'MyApp'
      args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'
      exit←TxtToCsv 2⊃2↑args
      ⎕OFF exit
    ∇

    ∇ exit←TxtToCsv fullfilepath;∆;isDev;Log;Error;files;tgt
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
     
      Error←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
     
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
     
      :If EXIT.OK=⊃(exit files)←CheckAgenda fullfilepath
          Log.Log'Target: ',tgt←(⊃,/2↑⎕NPARTS fullfilepath),'.CSV'
          exit←CountLettersIn files tgt
      :EndIf
      Log.Log'All done'
    ∇

    ∇ (exit files)←CheckAgenda fullfilepath;type
      :If 0=≢fullfilepath~' '
      :OrIf ~⎕NEXISTS fullfilepath
          (exit files)←(Error'SOURCE_NOT_FOUND')('')
      :ElseIf ~(type←1 ⎕NINFO fullfilepath)∊C.NINFO.TYPE.(DIRECTORY FILE)
          (exit files)←(Error'INVALID_SOURCE')('')
      :Else
          :Select type
          :Case C.NINFO.TYPE.DIRECTORY
              files←⊃(⎕NINFO⍠C.NINFO.WILDCARD)fullfilepath,'\*.txt'
          :Case C.NINFO.TYPE.FILE
              files←,⊂fullfilepath
          :EndSelect
          exit←EXIT.OK
      :EndIf
    ∇

    ∇ exit←CountLettersIn(files tgt);i;txt;tbl;enc;nl;lines;bytes
     ⍝ Exit code from writing a letter-frequency count for a list of files
      tbl←0 2⍴'A' 0
      exit←EXIT.OK ⋄ i←1 
      :While exit=EXIT.OK
          :Trap 0
              (txt enc nl)←⎕NGET retry i⊃files
              tbl⍪←CountLetters txt
          :Else
              exit←Error'UNABLE_TO_READ_SOURCE'
          :EndTrap
          ⍝ . ⍝ DEBUG
      :Until (≢files)<i←i+1
      :If exit=EXIT.OK
          lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
          :Trap 0
              bytes←(lines enc nl)⎕NPUT retry tgt C.NPUT.OVERWRITE
          :Else
              exit←Error'UNABLE_TO_WRITE_TARGET'
              bytes←0
          :EndTrap
          Log.Log(⍕bytes),' bytes written to ',tgt
      :EndIf
    ∇

:EndNamespace
