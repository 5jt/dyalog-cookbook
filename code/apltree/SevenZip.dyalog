:Class SevenZip
⍝ Use this class to zip files and directories with the Open Source software 7zip.
⍝
⍝ This class relies on an installed version of 7zip. The EXE is found via the
⍝ Windows Registry.
⍝
⍝ Note that 7-zip suffers from a bug: that these two files cannot go into the
⍝ same zip file:
⍝
⍝ ~~~
⍝ C:\My\folder2\foo
⍝ C:\My\folder1\foo
⍝ ~~~
⍝ while these:
⍝ ~~~
⍝ folder2\foo
⍝ folder1\foo
⍝ ~~~
⍝ would actually work when the current directory is C:\My. Well...
⍝
⍝ ## Examples
⍝ ~~~
⍝       myZipper←⎕new #.SevenZip (,⊂'MyZipFile')
⍝       ⎕←myZipper
⍝ [SevenZip@MyZipFile]
⍝       myZipper.Add 'foo.txt'
⍝       ⎕←myZipper.List 0
⍝ foo.txt
⍝       myZipper.Unzip 'c:\output\'
⍝ ~~~
⍝ Homepage: <http://http://aplwiki.com/SevenZip>
⍝
⍝ Author: Kai Jaeger ⋄ APL Team Ltd

    :Include APLTreeUtils

    ⎕IO←0
    ⎕ML←3

    :Field Public Shared types←'7z' 'split' 'zip' 'gzip' 'bzip2' 'tar'

    ∇ r←Version
      :Access Public Shared
    ⍝ * 1.6.0:
    ⍝   * Requires at least Dyalog version 15.0 Unicode.
    ⍝   * SevenZip now uses `FilesAndDirs` rather than `WinFile`.
    ⍝     Note however that SevenZip is **not** platform independent yet.
    ⍝ * 1.5.0:
    ⍝   * Via the left argument additional flags can be passed to `Unzip`.
    ⍝   * Bug fixes:
    ⍝     * `Unzip` should really run in `x` mode rather than 'e' mode in order to preserve paths.
      r←({⍵↓⍨1+⍵⍳'.'}⍕⎕THIS)'1.6.0' '2016-09-01'
    ∇

    :Property zipFilename
    :Access Public Instance
    ⍝ The name of the archive the instance is dealing with
        ∇ r←get
          r←zipFilename_
        ∇
    :EndProperty

    :Property  refToUtils
    ⍝ Ref that points to a namespace where we can find `APLTreeUtils` and `WinReg`
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
      ('cannot find ',pathToExe_)⎕SIGNAL 11/⍨~⎕NEXISTS pathToExe_
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

    ∇ {r}←Add pattern;fno;cmd;b;counter
    ⍝ Add zero, one or more files to the ZIP file.
    ⍝
    ⍝ `pattern` can use wildcards `*` and `?`.
    ⍝
    ⍝ **Note**: in order to get **all** files one **must** specify `*`;
    ⍝ the expression `*.*` catches only all files with an extension.
    ⍝
    ⍝ When `pattern` is something like "c:\directory\*" then all files
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
              counter←1
              :Repeat
                  r←#.Execute.Process cmd
                  ⎕DL 0.2+1<counter  ⍝ Otherwise we are very likely to see all sorts of problems
              :Until (0=↑r)∨2<counter←counter+1
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
              :If ∨/∨/¨'Duplicate filename'∘⍷¨1⊃r
                  (1⊃r)←(1⊃r),⊂'Use relative path names rather than absolute ones to avoid the problem'
              :EndIf
              :If 0=↑r
              :AndIf ∨/'ERROR'⍷∊1⊃r
                  (↑r)←2⊃r
              :EndIf
          :EndIf
          :If 0=↑r
              (↑r)←{0∊⍴⍵:0 ⋄ 'Everything is Ok'≢↑¯1↑⍵}1⊃r
          :EndIf
      :EndIf
    ∇

    ∇ r←List verboseFlag;cmd;rc;more;exitCode
    ⍝ Returns information about what is saved in the archive.
    ⍝
    ⍝ If "verboseFlag" is 1 then the 7zip output is returned which contains all
    ⍝ sorts of pieces of information. If `verboseFlag` is 0 only a vector of file
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

    ∇ r←{flags}Unzip outputFolder;cmd;more;rc;exitCode
    ⍝ Extracts the full contents of the zip file into `outputFolder`.
    ⍝ Use the left argument for adding more flags. You should know what you are doing then however.
      :Access Public Instance
      flags←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'flags'
      cmd←PathToExe,' x '
      cmd,←zipFilename_,' '
      :If ~0∊⍴outputFolder
          cmd,←' -o',outputFolder,' '
      :EndIf
      :If ~0∊⍴flags
          cmd,←' ',flags,' '
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
