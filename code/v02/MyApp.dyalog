:Namespace MyApp

   (⎕IO ⎕ML ⎕WX ⎕PP ⎕DIV)←1 1 3 15 1

⍝ === Aliases

    U←##.Utilities ⋄ C←##.Constants  ⍝ must be defined previously

⍝ === VARIABLES ===

    Accents←↑'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}(↓Accents)U.map U.toUppercase ⍵
      }

    ∇ noOfBytes←TxtToCsv fullfilepath;csv;stem;path;files;lines;nl;enc;tgt;tbl
   ⍝ Write a sibling CSV of the TXT located at fullfilepath,
   ⍝ containing a frequency count of the letters in the file text
      fullfilepath~←'"'
      csv←'.csv'
      :Select C.NINFO.TYPE ⎕NINFO fullfilepath
      :Case C.TYPES.DIRECTORY
          tgt←fullfilepath,'total',csv
          files←⊃(⎕NINFO⍠'Wildcard' 1)fullfilepath,'\*.txt'
      :Case C.TYPES.FILE
          (path stem)←2↑⎕NPARTS fullfilepath
          tgt←path,stem,csv
          files←,⊂fullfilepath
      :EndSelect      
      (tbl enc nl)←{(⍪/⊃⍵),1↓⍵}(CountLetters ProcessFiles) files
      lines←{⍺,',',⍕⍵}/{⍵[⍒⍵[;2];]}⊃{⍺(+/⍵)}⌸/↓[1]tbl
      noOfBytes←(lines enc nl)⎕NPUT tgt C.NPUT.OVERWRITE
    ∇
    
    ∇(data enc nl)←(fns ProcessFiles) files;txt;file
    ⍝ Reads all files and executes `fns` on the contents. `files` must not be empty.
      data←⍬
      :For file :In files
          (txt enc nl)←⎕NGET file
          data,←⊂fns txt
      :EndFor     
    ∇

:EndNamespace
