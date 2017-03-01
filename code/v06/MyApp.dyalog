:Namespace MyApp

    ⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3 ⋄ ⎕PP←15 ⋄ ⎕DIV←1

    ∇ r←Version
   ⍝ * 1.3.0:
   ⍝   * Allows to Ride into the application, INI settings permitted.
   ⍝ * 1.2.0:
   ⍝   * The application now honours INI files.
   ⍝ * 1.1.0:
   ⍝   * Can now deal with non-existent files.
   ⍝   * Logging implemented.
   ⍝ * 1.0.0
   ⍝   * Runs as a stand-alone EXE and takes parameters from the command line.
      r←(⍕⎕THIS)'1.3.0' '2017-02-26'
    ∇

⍝ === Aliases (referents must be defined previously)

    F←##.FilesAndDirs ⋄ A←##.APLTreeUtils ⍝ from the APLTree lib
    U←##.Utilities ⋄ C←##.Constants

    :Namespace EXIT
        OK←0
        INVALID_SOURCE←101
        SOURCE_NOT_FOUND←102
        UNABLE_TO_READ_SOURCE←103
        UNABLE_TO_WRITE_TARGET←104
          GetName←{
              l←' '~¨⍨↓⎕NL 2
              ind←({⍎¨l}l)⍳⍵
              ind⊃l,⊂'Unknown error'
          }
    :EndNamespace

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}G.Accents U.map A.Uppercase ⍵
      }

    ∇ rc←TxtToCsv fullfilepath;files;tbl;lines;target
   ⍝ Write a sibling CSV of the TXT located at fullfilepath,
   ⍝ containing a frequency count of the letters in the file text.
   ⍝ Returns one of the values defined in `EXIT`.
      MyLogger.Log'Started MyApp in ',F.PWD
      MyLogger.Log'Source: ',fullfilepath
      (rc target files)←GetFiles fullfilepath
      :If rc=EXIT.OK
          :If 0∊⍴files
              MyLogger.Log'No files found to process'
              rc←EXIT.SOURCE_NOT_FOUND
          :Else
              tbl←⊃⍪/(CountLetters ProcessFiles)files
              lines←{⍺,',',⍕⍵}/{⍵[⍒⍵[;2];]}⊃{⍺(+/⍵)}⌸/↓[1]tbl
              :Trap G.Trap/FileRelatedErrorCodes
                  A.WriteUtf8File target lines
              :Case
                  MyLogger.LogError'Writing to <',target,'> failed, rc=',(⍕⎕EN),'; ',⊃⎕DM
                  rc←EXIT.UNABLE_TO_WRITE_TARGET
                  :Return
              :EndTrap
              MyLogger.Log(⍕⍴files),' file',((1<⍴files)/'s'),' processed:'
              MyLogger.Log' ',↑files
          :EndIf
      :EndIf
    ∇

    ∇ (rc target files)←GetFiles fullfilepath;csv;target;path;stem;isDir
   ⍝ Checks argument and returns liast of files (or single file).
      fullfilepath~←'"'
      :If 0∊⍴fullfilepath
          rc←EXIT.INVALID_SOURCE
          :Return
      :EndIf
      files←target←''
      csv←'.csv'
      :If 0=F.Exists fullfilepath
          rc←EXIT.SOURCE_NOT_FOUND
      :ElseIf ~isDir←F.IsDir fullfilepath
      :AndIf ~F.IsFile fullfilepath
          rc←EXIT.INVALID_SOURCE
      :Else
          :If isDir
              target←F.NormalizePath fullfilepath,'\total',csv
              files←⊃F.Dir fullfilepath,'/*.txt'
          :Else
              (path stem)←2↑⎕NPARTS fullfilepath
              target←path,stem,csv
              files←,⊂fullfilepath
          :EndIf
          target←(~0∊⍴files)/target
          rc←(1+0∊⍴files)⊃EXIT.(OK SOURCE_NOT_FOUND)
      :EndIf
    ∇

    ∇ data←(fns ProcessFiles)files;txt;file
   ⍝ Reads all files and executes `fns` on the contents.
      data←⍬
      :For file :In files
          :Trap G.Trap/FileRelatedErrorCodes
              txt←'flat'A.ReadUtf8File file
          :Case
              MyLogger.LogError'Unable to read source: ',file
              Off EXIT.UNABLE_TO_READ_SOURCE
     
          :EndTrap
          data,←⊂fns txt
      :EndFor
    ∇

    ∇ {r}←SetLX dummy
   ⍝ Set Latent Expression (needed in order to export workspace as EXE)
      r←⍬
      ⎕LX←'#.MyApp.StartFromCmdLine #.MyApp.GetCommandLineArg ⍬'
    ∇

    ∇ {r}←StartFromCmdLine arg;MyLogger;G
   ⍝ Needs command line parameters, runs the application.
      r←⍬
      (G MyLogger)←Initial ⍬
      Off TxtToCsv arg
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

    ∇ (G MyLogger)←Initial dummy
    ⍝ Prepares the application.
    ⍝ Side effect: creates `MyLogger`, an instance of the `Logger` class.
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
      G←CreateGlobals ⍬
      CheckForRide G
      MyLogger←OpenLogFile G.LogFolder
      MyLogger.Log↓⎕FMT G.∆List
    ∇

    ∇ G←CreateGlobals dummy;myIni;iniFilename
      G←⎕NS''
      G.⎕FX'r←∆List' 'r←{0∊⍴⍵:0 2⍴'''' ⋄ ⍵,[1.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2'
      G.Debug←A.IsDevelopment
      G.Trap←1
      G.Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'
      G.LogFolder←'./Logs'
      G.DumpFolder←'./Errors'
      G.Watch←''    ⍝ not used yet
      G.Ride←0      ⍝ If this is not 0 the app accepts a Ride & treats G.Ride as port number
      iniFilename←'expand'F.NormalizePath'MyApp.ini'
      :If F.Exists iniFilename
          myIni←⎕NEW ##.IniFiles(,⊂iniFilename)
          G.Debug{¯1≡⍵:⍺ ⋄ ⍵}←myIni.Get'Config:debug'
          G.Trap←⊃G.Trap myIni.Get'Config:trap'
          G.Accents←⊃G.Accents myIni.Get'Config:Accents'
          G.LogFolder←'expand'F.NormalizePath⊃G.LogFolder myIni.Get'Folders:Logs'
          G.DumpFolder←'expand'F.NormalizePath⊃G.DumpFolder myIni.Get'Folders:Errors'
          G.Watch←⊃G.Watch myIni.Get'Folders:Watch'
          :If myIni.Exist'Ride'
          :AndIf myIni.Get'Ride:Active'
              G.Ride←⊃G.Ride myIni.Get'Ride:Port'
          :EndIf
      :EndIf
      G.LogFolder←'expand'F.NormalizePath G.LogFolder
      G.DumpFolder←'expand'F.NormalizePath G.DumpFolder
    ∇
    
    ∇ {r}←CheckForRide G;rc
    ⍝ Checks whether the user wants to have a Ride and if so make it possible.
      r←⍬
      :If 0≠G.Ride
          rc←3502⌶0
          {0=⍵:r←1 ⋄ ⎕←'Problem! rc=',⍕⍵ ⋄.}rc
          rc←3502⌶'SERVE::',⍕G.Ride
          {0=⍵:r←1 ⋄ ⎕←'Problem! rc=',⍕⍵ ⋄.}rc
          rc←3502⌶1
          {0=⍵:r←1 ⋄ ⎕←'Problem! rc=',⍕⍵ ⋄.}rc
          {_←⎕DL ⍵ ⋄ ∇ ⍵}1
      :EndIf
    ∇

    ∇ Off exitCode
      :If 0<⎕NC'MyLogger'
          :If exitCode=EXIT.OK
              MyLogger.Log'MyApp is closing down gracefully'
          :Else
              MyLogger.LogError'MyApp is closing down, return code is ',EXIT.GetName exitCode
          :EndIf
      :EndIf
      :If A.IsDevelopment
          →
      :Else
          ⎕OFF exitCode
      :EndIf
    ∇

    ∇ r←FileRelatedErrorCodes
    ⍝ Useful to trap all file (and directory) related errors.
      r←12 18 20 21 22 23 24 25 26 28 30 31 32 34 35
    ∇

:EndNamespace