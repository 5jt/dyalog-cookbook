:Class SevenZip
⍝ Use this class to zip/unzip files and directories with the Open Source software 7zip.\\
⍝ This class relies on an installed version of 7zip. The EXE must be on the PATH environment variable.\\
⍝ This class is supported under Linux and Windows but not Mac OS because 7zip is not available on the Mac.\\
⍝ Note that the file extension **must** be lowercase!\\
⍝ If `type` is not specified then the extension of the filename rules the day.\\
⍝ Note also that 7-zip suffers from a bug: that these two files cannot go into the same zip file:
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
⍝ would actually work when the current directory is `C:\My`. Well...
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

    :Field Public Shared types←'7z' 'split' 'zip' 'gzip' 'bzip2' 'tar' 'gz'

    ∇ r←Version
      :Access Public Shared
      r←(Last⍕⎕THIS)'2.1.2' '2017-10-30'
    ∇

    ∇ History
      :Access Public Shared
    ⍝ * 2.1.2:
    ⍝   * Documentation improved.
    ⍝   * Better performance in case a file does not exist.
    ⍝ * 2.1.1:
    ⍝   * Bug fix: list of types was missing "gz".
    ⍝ * 2.1.0:
    ⍝   * New method `History`.
    ⍝   * `SevenZip` is now managed by acre 3.
    ⍝ * 2.0.3: `type`...
    ⍝ * 2.0.2:
    ⍝   * Finally I got to the bottom of the occasionally failure that disappeared
    ⍝     by simply trying again, or trace through the code. Should be fine now.
    ⍝ * 2.0.1:
    ⍝   Uses the new version of FilesAndDirs` (syntax change).
    ⍝ * 2.0.0:
    ⍝   * Runs on Windows and Linux now. (There is no 7z on Mac OS)
    ⍝   * `7z` must be on the PATH variable in order to be found. Does not require WinReg
    ⍝     under Windows anymore as a side effect.
    ⍝   * Bug fixes:
    ⍝     * The were problems with filenames containing a space.
    ∇

    :Property zipFilename
    :Access Public Instance
    ⍝ The name of the archive the instance is dealing with
        ∇ r←get
          r←refToUtils.FilesAndDirs.(EnforceBackSlash NormalizePath)zipFilename_
        ∇
    :EndProperty

    :Property  refToUtils
    ⍝ Obsolete and therefore ignored
    :Access Public
        ∇ r←get
          r←refToUtils_
        ∇
        ∇ set arg
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
      refToUtils_←FindUtils
      type_←''
      Init
    ∇

    ∇ make2(_zipFilename _refToUtils)
      :Access Public
      :Implements Constructor
      refToUtils_←FindUtils
      type_←''
      Init
    ∇

    ∇ make3(_zipFilename _refToUtils _type)
      :Access Public
      :Implements Constructor
      refToUtils_←FindUtils
      type_←_type
      Init
    ∇

    ∇ Init;filepart;extension
    ⍝ Private but called by all constructors
      zipFilename_←refToUtils_.FilesAndDirs.NormalizePath _zipFilename
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
      ⎕DF(¯1↓⍕⎕THIS),'@',zipFilename_,']'
    ∇

⍝⍝⍝ Public stuff

    ∇ {(rc msg more)}←Add pattern;fno;cmd;counter;Until;this;buff
    ⍝ Add zero, one or more files to the ZIP file.\\
    ⍝ `pattern` can use wildcards `*` and `?`.\\
    ⍝ **Note**: in order to get **all** files one **must** specify `*`;
    ⍝ the expression `*.*` catches only all files with an extension.\\
    ⍝ When `pattern` is something like "c:\directory\*" then all files
    ⍝ including all sub directories are zipped recursively.
    ⍝ `rc` is 0 when okay.
      :Access Public Instance
      :If 0∊⍴pattern
          rc←0 ⋄ msg←more←''
      :Else
          cmd←''
          cmd,←'7z '
          cmd,←' a '
          cmd,←' -r- '
          cmd,←' -- '
          cmd,←'"""',(zipFilename_~'"'),'""" '
          :Select ≡pattern
          :CaseList 0 1
              pattern←refToUtils.FilesAndDirs.NormalizePath pattern~'"'
              cmd,←'"""',pattern,'"""'
              counter←1
          :Case 2
              pattern←{refToUtils.FilesAndDirs.NormalizePath ⍵~'"'}¨pattern
              cmd,←⊃,/' ',¨{'"""',⍵,'"""'}¨pattern
          :Else
              'Invalid right argument'⎕SIGNAL 11
          :EndSelect
          :Repeat
              (rc msg more)←Run_7zip cmd
              :If 0=rc
              :AndIf 'Everything is Ok'≡↑¯1↑msg
                  :Leave
              :EndIf
              :If ∨/'The system cannot find the file specified'⍷∊msg
              :OrIf ∨/'Duplicate filename'⍷∊msg
                  :Leave
              :EndIf
              ⎕DL 0.2                               ⍝ Otherwise we are very likely to see all sorts of problems
          :Until 20<counter←counter+1
          :If 0=rc
          :AndIf ~0∊⍴msg
              rc←'Everything is Ok'≢↑¯1↑msg
          :EndIf
          refToUtils.FilesAndDirs.DeleteFile zipFilename_,'.tmp'
          :If 0≠rc
              :If ∨/'Duplicate filename'∘⍷∊msg
                  msg,←⊂'Use relative path names rather than absolute ones to avoid the problem'
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←List verboseFlag;cmd;rc;more;exitCode
    ⍝ Returns information about what is saved in the archive.
    ⍝
    ⍝ If `verboseFlag` is 1 then the 7zip output is returned which contains all
    ⍝ sorts of pieces of information. If `verboseFlag` is 0 only a vector of file
    ⍝ names is returned with the names of all files (and sub folders) found in this file.
      :Access Public Instance
      cmd←''
      cmd,←'7z'
      cmd,←' l '
      cmd,←'"""',(zipFilename_~'"'),'""" '
      (rc more exitCode)←Run_7zip cmd
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
      cmd←''
      cmd,←'7z'
      cmd,←' x '
      cmd,←'"""',(zipFilename_~'"'),'""" '
      :If ~0∊⍴outputFolder
          cmd,←' -o',outputFolder,' '
      :EndIf
      :If ~0∊⍴flags
          cmd,←' ',flags,' '
      :EndIf
      cmd,←' -aoa '         ⍝ Overwrite mode
      (rc more exitCode)←Run_7zip cmd
      r←exitCode more
    ∇

    ∇ r←GetMsgFromExitCode code;case;msgs
    ⍝ Takes a 7zip exit code and returns a meaningful message or "[unknown]"
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

      CheckExtension←{
     ⍝ Returns the extension if it's valid or an empty vector
          ((⊂⍵)∊types)/⍵
      }

    ∇ r←Run_7zip cmd
      :Select GetOperatingSystem ⍬
      :Case 'Win'
          r←refToUtils.Execute.Process cmd
      :Case 'Lin'
          r←refToUtils.OS.ShellExecute cmd
          r←r[0 2],0
      :Case 'Mac'
          . ⍝ Not supported I am afraid
      :EndSelect
    ∇

    ∇ r←FindUtils
      r←FindPathTo↑⎕THIS
    ∇

:EndClass
