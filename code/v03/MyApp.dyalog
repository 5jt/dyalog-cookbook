:Namespace MyApp

    (⎕IO ⎕ML ⎕WX ⎕PP ⎕DIV)←1 1 3 15 1

    ∇ r←Version
    ⍝ * 1.0.0
    ⍝   * Runs as an exe and takes parameters from the command line
      r←(⍕⎕THIS)'1.0.0' 'YYYY-MM-DD'
    ∇

⍝ === Aliases

    U←##.Utilities ⋄ C←##.Constants   ⍝ must be defined previously

⍝ === VARIABLES ===

    Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}Accents U.map U.toUppercase ⍵
      }

    ∇ noOfBytes←TxtToCsv fullfilepath;csv;stem;path;files;lines;nl;enc;tgt;tbl
   ⍝ Write a sibling CSV containing a frequency count of the letters in the input files(s).\\
   ⍝ `fullfilepath` can point to a file or a folder. In case it is a folder then all TXTs
   ⍝ within that folder are processed. The resulting CSV holds the total frequency count.
      fullfilepath~←'"'
      csv←'.csv'
      :Select C.NINFO.TYPE ⎕NINFO fullfilepath
      :Case C.TYPES.DIRECTORY
          tgt←fullfilepath,'\total',csv
          files←⊃(⎕NINFO⍠'Wildcard' 1)fullfilepath,'\*.txt'
      :Case C.TYPES.FILE
          (path stem)←2↑⎕NPARTS fullfilepath
          tgt←path,stem,csv
          files←,⊂fullfilepath
      :EndSelect
      (tbl enc nl)←{(⍪/⊃⍵),1↓⍵}(CountLetters ProcessFiles)files
      lines←{⍺,',',⍕⍵}/{⍵[⍒⍵[;2];]}⊃{⍺(+/⍵)}⌸/↓[1]tbl
      noOfBytes←(lines enc nl)⎕NPUT tgt C.NPUT.OVERWRITE
    ∇

    ∇ (data enc nl)←(fns ProcessFiles)files;txt;file
    ⍝ Reads all files and executes `fns` on the contents. `files` must not be empty.
      data←⍬
      :For file :In files
          (txt enc nl)←⎕NGET file
          data,←⊂fns txt
      :EndFor
    ∇

    ∇ {r}←SetLX dummy
   ⍝ Set Latent Expression (needed in order to export workspace as EXE)
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1   
      r←⍬
      ⎕LX←'#.MyApp.StartFromCmdLine #.MyApp.GetCommandLineArg ⍬'
    ∇

    ∇ {r}←StartFromCmdLine arg
   ⍝ Read command parameters, run the application
      r←⍬
      r←TxtToCsv arg~''''
    ∇

    ∇ r←GetCommandLineArg dummy
      r←⊃¯1↑1↓2 ⎕NQ'.' 'GetCommandLineArgs' ⍝ Take the last one
    ∇

:EndNamespace
