:Namespace MyApp
⍝ Counting letter frequencies in text.\\
⍝ Can do one of:
⍝ * calculate the letters in a given document.
⍝ * calculate the letters in all documents in a given folder.
⍝
⍝ Sample application used by the Dyalog Cookbook.\\
⍝ Authors: Kai Jaeger & Stephen Taylor.
⍝ For more details see <http://cookbook.dyalog.com>

    ⎕IO←1 ⋄ ⎕ML←1 ⋄ ⎕WX←3 ⋄ ⎕PP←15 ⋄ ⎕DIV←1

    ∇ Z←Copyright
      Z←'The Dyalog Cookbook, Kai Jaeger & Stephen Taylor 2017'
    ∇

    ∇ r←Version
      r←(⍕⎕THIS)'1.5.0' '2017-02-26'
    ∇

    ∇ History      
      ⍝ * 1.5.0:
      ⍝   * MyApp is now ADOCable (function PublicFns).
      ⍝ * 1.4.0:
      ⍝   * Handles errors with a global trap.
      ⍝   * Returns an exit code to calling environment.
      ⍝ * 1.3.0:
      ⍝   * MyApp gives a Ride now, INI settings permitted.
      ⍝ * 1.2.0:
      ⍝   * The application now honours INI files.
      ⍝ * 1.1.0:
      ⍝   * Can now deal with non-existent files.
      ⍝   * Logging implemented.
      ⍝ * 1.0.0
      ⍝   * Runs as a stand-alone EXE and takes parameters from the command line.
    ∇

⍝ === Aliases (referents must be defined previously)

    F←##.FilesAndDirs ⋄ A←##.APLTreeUtils ⍝ from the APLTree lib
    U←##.Utilities ⋄ C←##.Constants

    :Namespace EXIT
        OK←0
        APPLICATION_CRASHED←104
        INVALID_SOURCE←111
        SOURCE_NOT_FOUND←112
        UNABLE_TO_READ_SOURCE←113
        UNABLE_TO_WRITE_TARGET←114
          GetName←{
              l←' '~¨⍨↓⎕NL 2
              ind←({⍎¨l}l)⍳⍵
              ind⊃l,⊂'Unknown error'
          }
    :EndNamespace

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}Config.Accents U.map A.Uppercase ⍵
      }

    ∇ rc←TxtToCsv fullfilepath;files;tbl;lines;target;success
   ⍝ Write a sibling CSV containing a frequency count of the letters in the input files(s).\\
   ⍝ `fullfilepath` can point to a file or a folder. In case it is a folder then all TXTs
   ⍝ within that folder are processed. The resulting CSV holds the total frequency count.\\
   ⍝ Returns one of the values defined in `EXIT`.
      (rc target files)←GetFiles fullfilepath
      {⍵:⍎'. ⍝ Deliberate error (INI flag "ForceError")'}Config.ForceError
      :If rc=EXIT.OK
          :If 0∊⍴files
              MyLogger.Log'No files found to process'
          :Else
              tbl←⊃⍪/(CountLetters ProcessFiles)files
              lines←{⍺,',',⍕⍵}/{⍵[⍒⍵[;2];]}⊃{⍺(+/⍵)}⌸/↓[1]tbl
              :Trap Config.Trap/FileRelatedErrorCodes
                  A.WriteUtf8File target lines
                  success←1
              :Case
                  success←0
                  MyLogger.LogError ⎕EN('Writing to <',target,'> failed; ',⊃⎕DM)
                  rc←EXIT.UNABLE_TO_WRITE_TARGET
              :EndTrap
              :If success
                  MyLogger.Log(⍕⍴files),' file',((1<⍴files)/'s'),' processed:'
                  MyLogger.Log' ',↑files
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ (rc target files)←GetFiles fullfilepath;csv;target;path;stem;isDir
   ⍝ Checks argument and returns liast of files (or single file).
      fullfilepath~←'"'
      files←target←''
      :If 0∊⍴fullfilepath
          rc←EXIT.INVALID_SOURCE
          :Return
      :EndIf
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
          rc←EXIT.OK
      :EndIf
    ∇

    ∇ data←(fns ProcessFiles)files;txt;file
   ⍝ Reads all files and executes `fns` on the contents.
      data←⍬
      :For file :In files
          :Trap Config.Trap/FileRelatedErrorCodes
              txt←'flat'A.ReadUtf8File file
          :Case
              MyLogger.LogError ⎕EN('Unable to read source: ',file)
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

    ∇ {r}←StartFromCmdLine arg;MyLogger;Config;rc;⎕TRAP
   ⍝ Needs command line parameters, runs the application.
      r←⍬
      ⎕TRAP←#.HandleError.SetTrap ⍬
      ⎕WSID←⊃⊣2⎕nq # 'GetCommandLineArgs'
      #.FilesAndDirs.PolishCurrentDir
      #.⎕SHADOW'ErrorParms'
      (Config MyLogger)←Initial ⍬
      ⎕TRAP←(Config.Debug=0)SetTrap Config
      rc←TxtToCsv arg~''''
      Off rc
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
      CheckForRide Config.Ride
      MyLogger←OpenLogFile Config.LogFolder
      MyLogger.Log'Started MyApp in ',F.PWD
      MyLogger.Log #.GetCommandLine
      MyLogger.Log↓⎕FMT Config.∆List
    ∇

    ∇ Config←CreateConfig dummy;myIni;iniFilename
      Config←⎕NS''
      Config.⎕FX'r←∆List' 'r←{0∊⍴⍵:0 2⍴'''' ⋄ ⍵,[1.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2'
      Config.Debug←A.IsDevelopment
      Config.Trap←1
      Config.Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'
      Config.LogFolder←'./Logs'
      Config.DumpFolder←'./Errors'
      Config.Ride←0      ⍝ If this is not 0 the app accepts a Ride & treats Config.Ride as port number
      Config.ForceError←0
      iniFilename←'expand'F.NormalizePath'MyApp.ini'
      :If F.Exists iniFilename
          myIni←⎕NEW ##.IniFiles(,⊂iniFilename)
          Config.ForceError←myIni.Get'Config:ForceError'
          Config.Debug{¯1≡⍵:⍺ ⋄ ⍵}←myIni.Get'Config:debug'
          Config.Trap←⊃Config.Trap myIni.Get'Config:trap'
          Config.Accents←⊃Config.Accents myIni.Get'Config:Accents'
          Config.LogFolder←'expand'F.NormalizePath⊃Config.LogFolder myIni.Get'Folders:Logs'
          Config.DumpFolder←'expand'F.NormalizePath⊃Config.DumpFolder myIni.Get'Folders:Errors'
          :If myIni.Exist'Ride'
          :AndIf myIni.Get'Ride:Active'
              Config.Ride←⊃Config.Ride myIni.Get'Ride:Port'
          :EndIf
      :EndIf
      Config.LogFolder←'expand'F.NormalizePath Config.LogFolder
      Config.DumpFolder←'expand'F.NormalizePath Config.DumpFolder
    ∇

    ∇ {r}←{wait}CheckForRide ridePort;rc
    ⍝ Depending on what's provided as right argument we prepare
    ⍝ for a Ride or we don't.
      r←1
      wait←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'wait'
      :If 0≠ridePort
          rc←3502⌶0
          :If ~rc∊0 ¯1
              11 ⎕SIGNAL⍨'Problem switching off Ride, rc=',⍕rc
          :EndIf
          rc←3502⌶'SERVE::',ridePort
          :If 0≠rc
              11 ⎕SIGNAL⍨'Problem setting the Ride connecion string to SERVE::',(⍕ridePort),', rc=',⍕rc
          :EndIf
          rc←3502⌶1
          :If ~rc∊0 ¯1
              11 ⎕SIGNAL⍨'Problem switching on Ride, rc=',⍕rc
          :EndIf
          {_←⎕DL ⍵ ⋄ ∇ ⍵}⍣(⊃wait)⊣⍬
      :EndIf
    ∇    

    ∇ Off exitCode
      :If 0<⎕NC'MyLogger'
          :If exitCode=EXIT.OK
              MyLogger.Log'Shutting down MyApp'
          :Else
              MyLogger.LogError exitCode('MyApp is unexpectedly shutting down: ',EXIT.GetName exitCode)
          :EndIf
      :EndIf
      :If A.IsDevelopment
          →
      :Else
          ⎕OFF exitCode
      :EndIf
    ∇

    ∇ r←FileRelatedErrorCodes;E
    ⍝ Returns all the error codes that are related to files and directories.
    ⍝ Useful to trap all those errors.
      r←''
      E←##.EventCodes
      r,←E.HOLD_ERROR
      r,←E.FILE_TIE_ERROR
      r,←E.FILE_INDEX_ERROR
      r,←E.FILE_FULL
      r,←E.FILE_NAME_ERROR
      r,←E.FILE_DAMAGED
      r,←E.FILE_TIED
      r,←E.FILE_TIED_REMOTELY
      r,←E.FILE_SYSTEM_ERROR
      r,←E.FILE_SYSTEM_NOT_AVAILABLE
      r,←E.FILE_SYSTEM_TIES_USED_UP
      r,←E.FILE_TIE_QUOTA_USED_UP
      r,←E.FILE_NAME_QUOTA_USED_UP
      r,←E.FILE_SYSTEM_NO_SPACE
      r,←E.FILE_ACCESS_ERROR_CONVERTING_FILE
    ∇

    ∇ trap←{force}SetTrap Config
    ⍝ Returns a nested array that can be assigned to `⎕TRAP`.
      force←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'force'
      #.ErrorParms←##.HandleError.CreateParms
      #.ErrorParms.errorFolder←Config.DumpFolder
      #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED
      #.ErrorParms.(logFunctionParent logFunction)←MyLogger'Log'
      #.ErrorParms.windowsEventSource←'MyApp'
      #.ErrorParms.addToMsg←' --- Something went terribly wrong'
      trap←force ##.HandleError.SetTrap'#.ErrorParms'
    ∇

    ∇ r←PublicFns
      r←'StartFromCmdLine' 'TxtToCsv' 'SetLX' 'GetCommandLineArg'
    ∇

:EndNamespace
