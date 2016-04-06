:Namespace MyApp
⍝ Dyalog Cookbook, Version 02
⍝ Logging installed
⍝ Vern: sjt06apr16

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    (A L W)←#.(APLTreeUtils Logger WinFile) ⍝ from APLTree
    (C U)←#.(Constants Utilities) ⍝ must be defined previously

⍝ === VARIABLES ===

    ACCENTS←↑'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}(↓ACCENTS)U.map U.caseUp ⍵
      }
      
    ∇ SetLX
   ⍝ Set Latent Expression in root ready to export workspace as EXE
      #.⎕LX←'MyApp.StartFromCmdLine'
    ∇

    ∇ StartFromCmdLine
   ⍝ Read command parameters, run the application
      {}TxtToCsv 2⊃2↑⌷2 ⎕NQ'.' 'getcommandlineargs'
      W.PolishCurrentDir ⍝ set current dir to that of EXE
    ∇

    ∇ {ok}←TxtToCsv fullfilepath;∆;xxx;Log;csv;stem;path;files;txt;type;lines;nl;enc;tgt;src;tbl
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
     
      ok←0
      :If ~⎕NEXISTS fullfilepath
          Log.Log'Invalid source'
      :Else
          csv←'.csv'
          :Select type←1 ⎕NINFO fullfilepath
          :Case 1 ⍝ folder
              tgt←fullfilepath,csv
              files←⊃(⎕NINFO⍠C.NINFO.WILDCARD)fullfilepath,'\*.txt'
          :Case 2 ⍝ file
              (path stem xxx)←⎕NPARTS fullfilepath
              tgt←path,stem,csv
              files←,⊂fullfilepath
          :EndSelect
          Log.Log'Target: ',tgt
     
          :If ~⎕NEXISTS⊃⎕NPARTS tgt
              Log.Log'Invalid target folder'
          :Else
              tbl←0 2⍴'A' 0
              :For src :In files
                  (txt enc nl)←⎕NGET src
                  tbl⍪←CountLetters txt
              :EndFor
              lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
              ok←×∆←(lines enc nl)⎕NPUT tgt C.NPUT.OVERWRITE
              Log.Log(⍕∆),' bytes written to ',tgt
              Log.Log'All done'
          :EndIf
      :EndIf
    ∇

:EndNamespace
