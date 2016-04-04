:Namespace MyApp
⍝ Dyalog Cookbook, Chapter 1
⍝ Vern: sjt28mar16

⍝ Aliases
    (C U)←#.(Constants Utilities) ⍝ must be already defined

⍝ === VARIABLES ===

    ACCENTS←↑'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}(↓ACCENTS)U.map U.caseUp ⍵
      }

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
