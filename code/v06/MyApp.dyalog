:Namespace MyApp

    ⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3 ⋄ ⎕PP←15 ⋄ ⎕DIV←1

    ∇ r←Version
   ⍝ * 1.3.0:
   ⍝   * MyApp gives a Ride now, INI settings permitted.
   ⍝ * 1.2.0:
   ⍝   * The application now honours INI files.
   ⍝ * 1.1.0:
   ⍝   * Can now deal with non-existent files.
   ⍝   * Logging implemented.
   ⍝ * 1.0.0
   ⍝   * Runs as a stand-alone EXE and takes parameters from the command line.
      r←(⍕⎕THIS)'1.3.0' 'YYYY-MM-DD'
    ∇

⍝ === Aliases (referents must be defined previously)

    F←##.FilesAndDirs ⋄ A←##.APLTreeUtils ⍝ from the APLTree lib
    U←##.Utilities ⋄ C←##.Constants

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}Config.Accents U.map A.Uppercase ⍵
      }

    ∇ rc←TxtToCsv fullfilepath;files;tbl;lines;target
   ⍝ Write a sibling CSV containing a frequency count of the letters in the input files(s).\\
   ⍝ `fullfilepath` can point to a file or a folder. In case it is a folder then all TXTs
   ⍝ within that folder are processed. The resulting CSV holds the total frequency count.
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
    ⍝ Investigates `fullfilepath` and returns a list with files.
    ⍝ May return zero, one or many filenames.
      fullfilepath~←'"'
      csv←'.csv'
      :If F.Exists fullfilepath
          :Select C.NINFO.TYPE ⎕NINFO fullfilepath
          :Case C.TYPES.DIRECTORY
              target←F.NormalizePath fullfilepath,'\total',csv
              files←⊃F.Dir fullfilepath,'\*.txt'
          :Case C.TYPES.FILE
              (path stem)←2↑⎕NPARTS fullfilepath
              target←path,stem,csv
              files←,⊂fullfilepath
          :EndSelect
          target←(~0∊⍴files)/target
      :Else
          files←target←''
      :EndIf
    ∇

    ∇ data←(fns ProcessFiles)files;txt;file
   ⍝ Reads all files and executes `fns` on the contents.
      data←⍬
      :For file :In files
          txt←'flat'A.ReadUtf8File file
          data,←⊂fns txt
      :EndFor
    ∇

    ∇ {r}←SetLX dummy
   ⍝ Set Latent Expression (needed in order to export workspace as EXE)
      r←⍬
      ⎕LX←'#.MyApp.StartFromCmdLine #.MyApp.GetCommandLineArg ⍬'
    ∇

    ∇ {r}←StartFromCmdLine arg;MyLogger;Config
    ⍝ Needs command line parameters, runs the application.
      r←⍬
      (Config MyLogger)←Initial ⍬
      r←TxtToCsv arg~''''
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

    ∇ (Config MyLogger)←Initial dummy
    ⍝ Prepares the application.
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
      Config←CreateConfig ⍬
      CheckForRide Config.(Ride WaitForRide)
      MyLogger←OpenLogFile Config.LogFolder
      MyLogger.Log'Started MyApp in ',F.PWD
      MyLogger.Log #.GetCommandLine
      MyLogger.Log↓⎕FMT Config.∆List
    ∇

    ∇ Config←CreateConfig dummy;myIni;iniFilename
    ⍝ Instantiate the INI file and copy values over to a namespace `Config`.
      Config←⎕NS''
      Config.⎕FX'r←∆List' 'r←{0∊⍴⍵:0 2⍴'''' ⋄ ⍵,[1.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2'
      Config.Debug←A.IsDevelopment
      Config.Trap←1
      Config.Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'
      Config.LogFolder←'./Logs'
      Config.DumpFolder←'./Errors'
      Config.Ride←0        ⍝ If not 0 the app accepts a Ride & treats Config.Ride as port number.
      Config.WaitForRide←0 ⍝ If 1 `CheckForRide` will enter an endless loop.
      iniFilename←'expand'F.NormalizePath'MyApp.ini'
      :If F.Exists iniFilename
          myIni←⎕NEW ##.IniFiles(,⊂iniFilename)
          Config.Debug{¯1≡⍵:⍺ ⋄ ⍵}←myIni.Get'Config:debug'
          Config.Trap←⊃Config.Trap myIni.Get'Config:trap'
          Config.Accents←⊃Config.Accents myIni.Get'Config:Accents'
          Config.LogFolder←'expand'F.NormalizePath⊃Config.LogFolder myIni.Get'Folders:Logs'
          Config.DumpFolder←'expand'F.NormalizePath⊃Config.DumpFolder myIni.Get'Folders:Errors'
          :If myIni.Exist'Ride'
          :AndIf myIni.Get'Ride:Active'
              Config.Ride←⊃Config.Ride myIni.Get'Ride:Port'
              Config.WaitForRide←⊃Config.Ride myIni.Get'Ride:Wait'
          :EndIf
      :EndIf
      Config.LogFolder←'expand'F.NormalizePath Config.LogFolder
      Config.DumpFolder←'expand'F.NormalizePath Config.DumpFolder
    ∇

    ∇ {r}←CheckForRide (ridePort waitFlag);rc
     ⍝ Depending on what's provided as right argument we prepare for a Ride 
     ⍝ or we don't. In case `waitFlag` is 1 we enter an endless loop.
      r←1
      :If 0≠ridePort
          rc←3502⌶0
          :If ~rc∊0 ¯1
              11 ⎕SIGNAL⍨'Problem switching off Ride, rc=',⍕rc
          :EndIf
          rc←3502⌶'SERVE::',⍕ridePort
          :If 0≠rc
              11 ⎕SIGNAL⍨'Problem setting the Ride connecion string to SERVE::',(⍕ridePort),', rc=',⍕rc
          :EndIf
          rc←3502⌶1
          :If ~rc∊0 ¯1
              11 ⎕SIGNAL⍨'Problem switching on Ride, rc=',⍕rc
          :EndIf
          {}{_←⎕DL ⍵ ⋄ ∇ ⍵}⍣(⊃waitFlag)⊣1
      :EndIf
    ∇

:EndNamespace
