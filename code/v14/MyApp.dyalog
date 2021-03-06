﻿:Namespace MyApp
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
      r←(⍕⎕THIS)'1.8.0' 'YYYY-MM-DD'
    ∇

    ∇ History
      ⍝ * 1.8.0:
      ⍝   * Now reports to the Windows Event Log when running as a service
      ⍝ * 1.7.0:
      ⍝   * Method `RunAsService` added. 
      ⍝ * 1.6.0:
      ⍝   * MyApp has now its own help system.
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
        ALREADY_RUNNING←115
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
              Log'No files found to process'
          :Else
              tbl←⊃⍪/(CountLetters ProcessFiles)files
              lines←{⍺,',',⍕⍵}/{⍵[⍒⍵[;2];]}⊃{⍺(+/⍵)}⌸/↓[1]tbl
              :Trap Config.Trap/FileRelatedErrorCodes
                  A.WriteUtf8File target lines
                  success←1
              :Case
                  success←0
                  LogError ⎕EN('Writing to <',target,'> failed; ',⊃⎕DM)
                  rc←EXIT.UNABLE_TO_WRITE_TARGET
              :EndTrap
              :If success
                  Log(⍕⍴files),' file',((1<⍴files)/'s'),' processed:'
                  Log' ',↑files
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ {r}←RunAsService(earlyRide ridePort);⎕TRAP;MyLogger;Config;∆FileHashes;MyWinEventLog
    ⍝ Main function when app is running as a Windows Service.
    ⍝ `earlyRide`: flag that allows a very early Ride.
    ⍝ `ridePort`: Port number used by Ride.
      r←⍬
      CheckForRide ridePort earlyRide 
      #.FilesAndDirs.PolishCurrentDir
      ⎕TRAP←#.HandleError.SetTrap ⍬
      (Config MyLogger)←Initial #.ServiceState.IsRunningAsService
      ⎕TRAP←(Config.Debug=0)SetTrap Config
      Config.ControlFileTieNo←CheckForOtherInstances ⍬
      ∆FileHashes←0 2⍴''
      :If #.ServiceState.IsRunningAsService
          {MainLoop ⍵}&⍬
          ⎕DQ'.'
      :Else
          MainLoop ⍬
      :EndIf
      Cleanup ⍬
      Off EXIT.OK
    ∇

    ∇ {r}←MainLoop dummy;S
      r←⍬
      'both'Log'"MyApp" server started'
      S←#.ServiceState
      :Repeat
          LoopOverFolder ⍬
          :If ('both'∘Log S.CheckServiceMessages)S.IsRunningAsService
              'both'Log'"MyApp" is about to shut down...'
              :Leave
          :EndIf
          ⎕DL 2
      :Until 0
     ⍝Done
    ∇

    ∇ {r}←LoopOverFolder dummy;folder;files;hashes;noOf;rc
      r←⍬
      :For folder :In Config.WatchFolders
          files←#.FilesAndDirs.ListFiles folder,'\*.txt'
          hashes←GetHash¨files
          (files hashes)←(~hashes∊∆FileHashes[;2])∘/¨files hashes
          :If 0<noOf←LoopOverFiles files hashes
              :If EXIT.OK=rc←TxtToCsv folder
                  Log'Totals.csv updated'
              :Else
                  LogError rc('Could not update Totals.csv, RC=',EXIT.GetName rc)
              :EndIf
          :EndIf
      :EndFor
    ∇

    ∇ noOf←LoopOverFiles(files hashes);file;hash;rc
      noOf←0
      :For file hash :InEach files hashes
          :If EXIT.OK=rc←TxtToCsv file
              ∆FileHashes⍪←file hash
              noOf+←1
          :EndIf
      :EndFor
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
              LogError ⎕EN('Unable to read source: ',file)
              Off EXIT.UNABLE_TO_READ_SOURCE
          :EndTrap
          data,←⊂fns txt
      :EndFor
    ∇

    ∇ {r}←SetLXForApplication dummy
   ⍝ Set Latent Expression (needed in order to export workspace as EXE)
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1   
      r←⍬
      ⎕LX←'#.MyApp.StartFromCmdLine #.MyApp.GetCommandLineArg ⍬'
    ∇

    ∇ {r}←SetLXForService(earlyRide ridePort)
   ⍝ Set Latent Expression (needed in order to export workspace as EXE)
   ⍝ `earlyRide` is a flag. 1 allows a Ride.
   ⍝ `ridePort`  is the port number to be used for a Ride.
      #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
      r←⍬
      ⎕LX←'#.MyApp.RunAsService ',(⍕earlyRide),' ',(⍕ridePort)
    ∇

    ∇ {r}←StartFromCmdLine arg;MyLogger;Config;rc;⎕TRAP
   ⍝ Needs command line parameters, runs the application.
      r←⍬
      ⎕WSID←⊃{⍵/⍨~'='∊¨⍵}{⍵/⍨'-'≠⊃¨⍵}1↓2⎕NQ # 'GetCommandLineArgs'
      ⎕SIGNAL 0
      ⎕TRAP←#.HandleError.SetTrap ⍬
      #.⎕SHADOW'ErrorParms'
      (Config MyLogger)←Initial #.ServiceState.IsRunningAsService
      ⎕TRAP←(Config.Debug=0)SetTrap Config
      rc←TxtToCsv arg~''''
      Cleanup ⍬
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

    ∇ (Config MyLogger)←Initial isService;parms
    ⍝ Prepares the application.
      Config←CreateConfig isService
      Config.ControlFileTieNo←CheckForOtherInstances ⍬
      CheckForRide Config.(Ride WaitForRide)
      MyLogger←OpenLogFile Config.LogFolder
      Log'Started MyApp in ',F.PWD
      MyLogger.Log 2 ⎕NQ # 'GetCommandLineArgs'
      Log↓⎕FMT Config.∆List
      r←Config MyLogger
      :If isService
          MyWinEventLog←⎕NEW #.WindowsEventLog(,⊂'MyAppService')
          parms←#.ServiceState.CreateParmSpace
          parms.logFunction←'''both''∘Log'
          parms.logFunctionParent←⎕THIS
          #.ServiceState.Init parms
          r,←MyWinEventLog
      :EndIf
    ∇

    ∇ Config←CreateConfig isService;myIni;iniFilename
      Config←⎕NS''
      Config.⎕FX'r←∆List' 'r←{0∊⍴⍵:0 2⍴'''' ⋄ ⍵,[1.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2'
      Config.Debug←A.IsDevelopment
      Config.Trap←1
      Config.Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'
      Config.LogFolder←'./Logs'
      Config.DumpFolder←'./Errors'
      Config.Ride←0      ⍝ If this is not 0 the app accepts a Ride & treats Config.Ride as port number
      Config.WaitForRide←0 ⍝ If 1 `CheckForRide` will enter an endless loop.
      Config.ForceError←0
      Config.IsService←isService
      iniFilename←'expand'F.NormalizePath'MyApp.ini'
      :If F.Exists iniFilename
          myIni←⎕NEW ##.IniFiles(,⊂iniFilename)
          Config.ForceError←myIni.Get'Config:ForceError'
          Config.Debug{¯1≡⍵:⍺ ⋄ ⍵}←myIni.Get'Config:debug'
          Config.Trap←⊃Config.Trap myIni.Get'Config:trap'
          Config.Accents←⊃Config.Accents myIni.Get'Config:Accents'
          :If 0=isService
              Config.LogFolder←'expand'F.NormalizePath⊃Config.LogFolder myIni.Get'Folders:Logs'
          :Else
              Config.WatchFolders←⊃myIni.Get'Folders:Watch'
              Config.WriteToWindowsEventLog←0
          :EndIf
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

    ∇ {r}←CheckForRide(ridePort waitFlag);rc;init;msg
     ⍝ Depending on what's provided as right argument we prepare for a Ride
     ⍝ or we do not. In case `waitFlag` is 1 we enter an endless loop.
     r←1
     :If 0<ridePort
      :AndIf 0=3501⌶⊣⍬                 ⍝ Only if not already riding
          init←'SERVE::',⍕ridePort     ⍝ Initialisation string
          rc←3502⌶init                 ⍝ Specify INIT string
          :If 32=rc
              11 ⎕SIGNAL⍨'Cannot Ride: Conga DLLs are missing'
          :ElseIf 64=rc
              11 ⎕SIGNAL⍨'Cannot Ride; invalid initialisation string: ',init
          :ElseIf 0≠rc
             msg←'Problem setting the Ride connecion string to SERVE::'
             msg,←,(⍕ridePort),', rc=',⍕rc
             11 ⎕SIGNAL⍨msg
         :EndIf
         rc←3502⌶1
         :If ~rc∊0 ¯1
              11 ⎕SIGNAL⍨'Switching on Ride failed, rc=',⍕rc
         :EndIf
         {}{_←⎕DL ⍵ ⋄ ∇ ⍵}⍣(⊃waitFlag)⊣1  ⍝ Endless loop for an early RIDE
     :EndIf
    ∇
    
    ∇ Off exitCode
      :If exitCode=EXIT.OK
          'both'Log'Shutting down MyApp'
      :Else
          LogError exitCode('MyApp is unexpectedly shutting down: ',EXIT.GetName exitCode)
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
      #.ErrorParms.(logFunctionParent logFunction)←⎕THIS'LogError'
      #.ErrorParms.windowsEventSource←'MyApp'
      #.ErrorParms.addToMsg←' --- Something went terribly wrong'
      trap←force ##.HandleError.SetTrap'#.ErrorParms'
    ∇

    ∇{r}←ShowHelp pagename;ps
     ps←#.Markdown2Help.CreateParms ⍬
     ps.source←#.MyHelp     
     ps.foldername←'Help'
     ps.helpAbout←'MyApp''s help system by John Doe'
     ps.helpCaption←'MyApp Help'
     ps.helpIcon←'file://',##.FilesAndDirs.PWD,'\images\logo.ico'
     ps.helpVersion←'1.0.0'
     ps.helpVersionDate←'YYYY-MM-DD'
     ps.page←pagename
     ps.regPath←'HKCU\Software\MyApp'
     ps.noClose←1
     r←#.Markdown2Help.New ps
   ∇

    ∇ {tno}←CheckForOtherInstances dummy;filename;listOfTiedFiles;ind
    ⍝ Attempts to tie the file "MyApp.dcf" exclusively and returns the tie number.
    ⍝ If that is not possible than an error is thrown because we can assume that the
    ⍝ application is already running.\\
    ⍝ Notes:
    ⍝ * In case the file is already tied it is untied first.
    ⍝ * If the file does not exist it is created.
      filename←'MyAppCtrl.dcf'
      :If 0=F.IsFile filename
          tno←filename ⎕FCREATE 0
      :Else
          :If ~0∊⍴⎕FNUMS
              listOfTiedFiles←A.dtb↓⎕FNAMES
              ind←listOfTiedFiles⍳⊂filename
          :AndIf ind≤⍴⎕FNUMS
              ⎕FUNTIE ind⊃⎕FNUMS
          :EndIf
          :Trap 24
              tno←filename ⎕FTIE 0
          :Else
              'Application is already running'⎕SIGNAL EXIT.ALREADY_RUNNING
          :EndTrap
      :EndIf
    ∇

    ∇ {r}←Cleanup dummy
      r←⍬
      ⎕FUNTIE Config.ControlFileTieNo
      Config.ControlFileTieNo←⍬
      '#'⎕WS'Event' 'ServiceNotification' 0
    ∇

    ∇ r←PublicFns
      r←'StartFromCmdLine' 'TxtToCsv' 'SetLXForApplication' 'SetLXForService' 'RunAsService'
    ∇

      GetHash←{
      ⍝ Get hash for file ⍵
          ⊣2 ⎕NQ'#' 'GetBuildID'⍵
      }

    ∇ {r}←{both}Log msg
    ⍝ Writes to the application's log file only by default.
    ⍝ By specifying 'both' as left argument one can force the fns to write
    ⍝ `msg` also to the Windows Event Log if Config.WriteToWindowsEventLog.
      r←⍬
      both←(⊂{0<⎕NC ⍵:⍎⍵ ⋄ ''}'both')∊'both' 1
      :If 0<⎕NC'MyLogger'
          MyLogger.Log msg
      :EndIf
      :If both
      :AndIf Config.WriteToWindowsEventLog
          :Trap 0    ⍝ Don't allow logging to break!
              MyWinEventLog.WriteInfo msg
          :Else
              MyLogger.LogError'Writing to the Windows Event Log failed for:'
              MyLogger.LogError msg
          :EndTrap
      :EndIf
    ∇

    ∇ {r}←LogError(rc msg)
    ⍝ Write to **both** the application's log file and the Windows Event Log.
      MyLogger.LogError msg
      :If Config.WriteToWindowsEventLog
          :Trap 0
              MyWinEventLog.WriteError msg
          :Else
              MyLogger.LogError'Could not write to the Windows Event Log:'
              MyLogger.LogError msg
          :EndTrap
      :EndIf
    ∇

:EndNamespace
