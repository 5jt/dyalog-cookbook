:Namespace MyApp
⍝ Dyalog Cookbook, Chapter 02
⍝ Vern: sjt29mar16


⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
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
    ∇

    ∇ {ok}←TxtToCsv fullfilepath;xxx;csv;stem;path;files;txt;type;lines;nl;enc;tgt;src;tbl
   ⍝ Write a sibling CSV of the TXT located at fullfilepath,
   ⍝ containing a frequency count of the letters in the file text
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
      tbl←0 2⍴'A' 0
      :For src :In files
          (txt enc nl)←⎕NGET src
          tbl⍪←CountLetters txt
      :EndFor
      lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
      ok←×(lines enc nl)⎕NPUT tgt C.NPUT.OVERWRITE
    ∇

:EndNamespace
