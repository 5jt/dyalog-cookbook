:Namespace MyApp

    ⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3 ⋄ ⎕PP←15 ⋄ ⎕DIV←1
    
    ∇r←Version
   ⍝ * 1.1.0:
   ⍝   * Can now deal with non-existent files.
   ⍝   * Logging implemented.    
   ⍝ * 1.0.0
   ⍝   * Runs as a stand-alone EXE and takes parameters from the command line.
      r←(⍕⎕THIS) '1.1.0' '2017-02-26'             
    ∇

⍝ === Aliases (referents must be defined previously)

    F←##.FilesAndDirs ⋄ A←##.APLTreeUtils ⍝ from the APLTree lib
    U←##.Utilities ⋄ C←##.Constants

⍝ === VARIABLES ===

    Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}Accents U.map A.Uppercase ⍵
      }

    ∇ rc←TxtToCsv fullfilepath;files;tbl;lines;target
   ⍝ Write a sibling CSV of the TXT located at fullfilepath,
   ⍝ containing a frequency count of the letters in the file text 
      MyLogger.Log'Started MyApp in ',F.PWD
      MyLogger.Log'Source: ',fullfilepath
      (target files)←GetFiles fullfilepath
      :If 0∊⍴files
          MyLogger.Log'No files found to process'
          rc←1
      :Else
          tbl←⊃⍪/(CountLetters ProcessFiles)files
          lines←{⍺,',',⍕⍵}/{⍵[⍒⍵[;2];]}⊃{⍺(+/⍵)}⌸/↓[1]tbl
          A.WriteUtf8File target lines 
          MyLogger.Log(⍕⍴files),' file',((1<⍴files)/'s'),' processed:'
          MyLogger.Log' ',↑files
          rc←0
      :EndIf
    ∇

    ∇ (target files)←GetFiles fullfilepath;csv;target;path;stem
      fullfilepath~←'"'
      csv←'.csv'
      :Select C.NINFO.TYPE ⎕NINFO fullfilepath
      :Case C.TYPES.DIRECTORY
          target←fullfilepath,'total',csv
          files←⊃F.Dir fullfilepath,'\*.txt'
      :Case C.TYPES.FILE
          (path stem)←2↑⎕NPARTS fullfilepath
          target←path,stem,csv
          files←,⊂fullfilepath
      :EndSelect
      target←(~0∊⍴files)/target
    ∇

    ∇ data←(fns ProcessFiles)files;txt;file
   ⍝ Reads all files and executes `fns` on the contents.
      data←⍬
      :For file :In files
          txt←'flat' A.ReadUtf8File file
          data,←⊂fns txt
      :EndFor
    ∇

    ∇ {r}←SetLX dummy
   ⍝ Set Latent Expression (needed in order to export workspace as EXE)
      r←⍬
      ⎕LX←'#.MyApp.StartFromCmdLine #.MyApp.GetCommandLineArg ⍬'
    ∇

    ∇ {r}←StartFromCmdLine arg;MyLogger
   ⍝ Needs command line parameters, runs the application.
      r←⍬
      MyLogger←Initial ⍬
      r←TxtToCsv arg
    ∇

    ∇ r←GetCommandLineArg dummy;buff
      r←⊃¯1↑1↓2 ⎕NQ'.' 'GetCommandLineArgs'
    ∇

    ∇ instance←OpenLogFile path;logParms
      ⍝ Creates an instance of the "Logger" class.
      ⍝ Provides methods `Log` and `LogError`.
      ⍝ Make sure that `path` (that is where log files will end up) does exist.
      ⍝ Returns the instance.
      logParms←##.Logger.CreateParms
      logParms.path←path
      logParms.encoding←'UTF8'
      logParms.filenamePrefix←'MyApp'
      'CREATE!'F.CheckPath path
      instance←⎕NEW ##.Logger(,⊂logParms)
    ∇

    ∇ {MyLogger}←Initial dummy
    ⍝ Prepares the application.
    ⍝ Side effect: creates `MyLogger`, an instance of the `Logger` class.
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
      MyLogger←OpenLogFile'Logs'
    ∇

:EndNamespace
