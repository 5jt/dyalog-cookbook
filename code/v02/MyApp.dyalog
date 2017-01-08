:Namespace MyApp
⍝ Dyalog Cookbook, MyApp Version 02
⍝ Logging installed
⍝ Vern: sjt21sep16

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    (A F L)←#.(APLTreeUtils FilesAndDirs Logger) ⍝ from APLTree
    (C U)←#.(Constants Utilities) ⍝ must be defined previously

⍝ === VARIABLES ===

    ACCENTS←↑'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}(↓ACCENTS)U.map U.toUppercase ⍵
      }

    ∇ SetLX
   ⍝ Set Latent Expression ready to export workspace as EXE
      ⎕LX←'#.MyApp.StartFromCmdLine'
    ∇

    ∇ StartFromCmdLine
   ⍝ Read command parameters, run the application
      {}TxtToCsv 2⊃2↑⌷2 ⎕NQ'.' 'GetCommandLineArgs'
    ∇

    ∇ {ok}←TxtToCsv ffp;fullfilepath;∆;Log;csv;stem;path;files;txt;type;lines;nl;enc;tgt;src;tbl
   ⍝ Write a sibling CSV of the TXT located at full filepath ffp,
   ⍝ containing a frequency count of the letters in the file text
      fullfilepath←F.NormalizePath ffp
      'CREATE!'F.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←L.CreateParms
      ∆.path←'Logs\' ⍝ subfolder of current directory
      ∆.encoding←'UTF8'
      ∆.filenamePrefix←'MyApp'
      Log←⎕NEW L(,⊂∆)
      Log.Log'Started MyApp in ',F.PWD
      Log.Log'Source: ',fullfilepath
     
      ok←0
      :If ~⎕NEXISTS fullfilepath
          Log.Log'Invalid source'
      :Else
          csv←'.csv'
          :Select type←C.NINFO.TYPE ⎕NINFO fullfilepath
          :Case 1 ⍝ folder
              tgt←fullfilepath,csv
              files←⊃(⎕NINFO⍠'Wildcard' 1)fullfilepath,'\*.txt'
          :Case 2 ⍝ file
              (path stem)←2↑⎕NPARTS fullfilepath
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
