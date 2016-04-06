:Class SevenZip
⍝ Use this class to zip files and directories with the Open Source software 7zip.
⍝ This class relies on an installed version of 7zip. The EXE is found via the _
⍝ Windows Registry.
⍝ Note that 7-zip suffers from a bug: these two files cannot go into the _
⍝ same zip file:
⍝ `C:\folder2\foo`
⍝ `C:\folder1\foo`
⍝ while these can:
⍝ `folder2\foo`
⍝ `folder1\foo`

⍝ == Examples
⍝ <pre>
⍝       myZipper←⎕new #.SevenZip (,⊂'MyZipFile')
⍝       ⎕←myZipper
⍝ [SevenZip@MyZipFile]
⍝       myZipper.Add 'foo.txt'
⍝       ⎕←myZipper.List 0
⍝ foo.txt
⍝       myZipper.Unzip 'c:\output\'
⍝       myZipper.Add 'c:\temp\*'
⍝ ⍝ This would zip everything inside c:\temp\ recursively.
⍝ </pre>
⍝ Author: Kai Jaeger ⋄ APL Team Ltd

    :Include APLTreeUtils

    ⎕IO←0 ⋄ ⎕ML←3

    :Field Public Shared types←'7z' 'split' 'zip' 'gzip' 'bzip2' 'tar'

    ∇ r←Version
      :Access Public Shared
      r←(Last⍕⎕THIS)'1.3.0' '2015-05-14'
    ⍝ 1.3.0: * Documenation improved.
    ⍝ 1.2.1: * Invalid call to GetLastError fixed.
    ⍝        * Destination (zip) filenanme must not be lowercased.
    ⍝ 1.2.0: APL inline code is now marked up with ticks.
    ∇

    :Property zipFilename
    :Access Public Instance
    ⍝ The name of the archive the instance is dealing with
        ∇ r←get
          r←zipFilename_
        ∇
    :EndProperty

    :Property  refToUtils
    ⍝ Ref that points to a namespace where we can find APLTreeUtils, WinReg, WinFile
    :Access Public
        ∇ r←get
          r←refToUtils_
        ∇
        ∇ set arg
          refToUtils_←arg.NewValue
        ∇
    :EndProperty

    :Property type
    ⍝ Returns the compress format
    :Access Public
        ∇ r←get
          r←_type_
        ∇
    :EndProperty


    ∇ make1(_zipFilename)
      :Access Public
      :Implements Constructor
      refToUtils_←#
      type_←''
      Init
      ('cannot find ',pathToExe_)⎕SIGNAL 11/⍨~refToUtils_.WinFile.DoesExistFile pathToExe_
    ∇

    ∇ make2(_zipFilename _refToUtils)
      :Access Public
      :Implements Constructor
      refToUtils_←_refToUtils
      type_←''
      Init
    ∇

    ∇ make3(_zipFilename _refToUtils _type)
      :Access Public
      :Implements Constructor
      refToUtils_←_refToUtils
      type_←_type
      Init
    ∇

    ∇ Init;filepart;extension
    ⍝ Private but called by all constructors
      zipFilename_←_zipFilename
      :If '.'∊filepart←1⊃refToUtils_.APLTreeUtils.SplitPath zipFilename_
          :If 0∊⍴type_←CheckExtension Last filepart
              'Invalid extension'⎕SIGNAL 11
          :EndIf
      :Else
          :If 0∊⍴type_
              zipFilename_,←'.zip'
              type_←'.zip'
          :Else
              :If 0∊⍴extension←CheckExtension type_
                  'Invalid type'⎕SIGNAL 11
              :EndIf
              zipFilename_,←((~'.'∊type_)/'.'),extension
          :EndIf
      :EndIf
      home_←FindPathTo7zipExe
      pathToExe_←home_,'7z.exe'
      ⎕DF(¯1↓⍕⎕THIS),'@',zipFilename_,']'
    ∇

⍝⍝⍝ Public stuff

    ∇ {r}←Add pattern;fno;cmd;b
    ⍝ Add zero, one or more files to the ZIP file.
    ⍝ `pattern` can use wildcards `*` and `?`.
    ⍝ ''Note'': in order to get ''all'' files one ''must'' specify `*`; _
    ⍝ the expression `*.*` catches all files with an extension, ''not'' all files.
    ⍝ When `pattern` is something like "c:\directory\*" then all files _
    ⍝ including all sub directories are zipped recursively.
      :Access Public Instance
      :If 0∊⍴pattern
          r←⍬
      :Else
          :Select ≡pattern
          :CaseList 0 1
              cmd←PathToExe,' a '
              cmd,←' -tzip '
              cmd,←' -r- '
              cmd,←' -- '
              cmd,←zipFilename_,' '
              cmd,←'"',(pattern~'"'),'"'
              r←#.Execute.Process cmd
          :Case 2
              b←~{∨/'?*'∊⍵}¨{0 1∊⍨≡⍵:⊂⍵ ⋄ ⍵}pattern     ⍝ Which ones do not contain any wildcards?
              cmd←PathToExe,' a '
              cmd,←' -tzip '
              cmd,←' -r- '
              cmd,←' -- '
              cmd,←zipFilename_,' '
              cmd,←↑,/{'"',(⍵~'"'),'" '}¨pattern
              r←refToUtils_.Execute.Process cmd
          :Else
              'Invalid right argument'⎕SIGNAL 11
          :EndSelect
          :If 2=2⊃r
          :AndIf ∨/∨/¨'Duplicate filename:'∘⍷¨1⊃r
          :AndIf ∨/∨/¨('\\' ':')∊¨2⍴¨pattern
              (1⊃r)←(1⊃r),⊂'Use relative path names rather than absolute ones to avoid the problem'
          :EndIf
      :EndIf
    ∇

    ∇ r←List verboseFlag;cmd;rc;more;exitCode
    ⍝ Returns information about what is saved in the archive.
    ⍝ If "verboseFlag" is 1 then the 7zip output is returned which contains all _
    ⍝ sorts of pieces of information. If `verboseFlag` is 0 only a vector of file _
    ⍝ namesis returned with the names of all files (and sub dirs) fond in this file.
      :Access Public Instance
      cmd←PathToExe,' l '
      cmd,←zipFilename_,' '
      r←refToUtils_.Execute.Process cmd
      (rc more exitCode)←refToUtils_.Execute.Process cmd
      :If 0=exitCode
      :AndIf (,1)≢,verboseFlag
          more←(2+1⍳⍨'DateTimeAttrSizeCompressedName'∘≡¨more~¨' ')↓more  ⍝ Drop everything until first name
          more↑⍨←+/∧\'------------------- '{(⊃(⍴⍺)↑¨⍵)∨.≠⍺}more          ⍝ Only the names survive
          more←{⍵↓⍨-+/∧\' '=⌽⍵}¨more                                     ⍝ Drop trailing blanks
          more←{⍵↑⍨-+/∧\' '≠⌽⍵}¨more                                     ⍝ Just the filenames
      :EndIf
      r←exitCode more
    ∇

    ∇ r←Unzip outputFolder;cmd;more;rc;exitCode
    ⍝ Extracts the full contents of the zip file into `outputFolder`.
      :Access Public Instance
      cmd←PathToExe,' e '
      cmd,←zipFilename_,' '
      :If ~0∊⍴outputFolder
          cmd,←' -o',outputFolder,' '
      :EndIf
      cmd,←' -aoa '         ⍝ Overwrite mode
      (rc more exitCode)←refToUtils_.Execute.Process cmd
      r←exitCode more
    ∇

    ∇ r←GetMsgFromExitCode code;case;msgs
    ⍝ Takes a 7zip exit code and returns a meaningful message or "[unknown}"
      :Access Public Shared
      msgs←''
      msgs,←⊂'No error'
      msgs,←⊂'Warning'
      msgs,←⊂'Fatal Error'
      msgs,←⊂'Command line error'
      msgs,←⊂'Not enough memory for operation'
      msgs,←⊂'User stopped process'
      msgs,←⊂'{unknown}'
      r←msgs[0 1 2 7 8 255⍳code]
    ∇

⍝⍝⍝ Private stuff

    ∇ r←FindPathTo7zipExe
      :If 0∊⍴r←refToUtils_.WinReg.GetString GetRegistryPathFor7zip,'\path'
          'Cannot find reference to 7zip in the Windows Registry'⎕SIGNAL 6
      :EndIf
    ∇

    ∇ r←GetRegistryPathFor7zip
      r←'HKCU\Software\7-Zip'
    ∇

    ∇ r←PathToExe
      r←'"',((FindPathTo7zipExe~'"'),'7z.exe'),'"'
    ∇

      CheckExtension←{
     ⍝ Returns the extension if it's valid or an empty vector
          ((⊂Lowercase ⍵)∊types)/⍵
      }

:EndClass