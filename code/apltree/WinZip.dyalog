:Class WinZip
⍝ Cover class for using WinZip.
⍝ Needs WinZip installed on your machine.
⍝ Note that like 7-zip WinZip requires every single filename to be unique. That means you cannot
⍝ zip these two files into the same archive:
⍝ `foo`
⍝ `folder\foo`
⍝ Kai Jaeger ⋄ APL Team Ltd
⍝ Homepage: http://aplwiki.com/WinZip

    ⎕IO←0 ⋄ ⎕ml←3
    :Include APLTreeUtils

    :Field Public Shared refToUtils←''  ⍝ Make this a pointer to the namespace holding utilities

    ∇ r←Version
      :Access Public Shared
      r←(Last⍕⎕THIS)'1.3.0' '2015-01-10'
      ⍝ 1.3.0:  APL inline code is now marked up with ticks.
      ⍝         `Version` returns just the name, no path.
      ⍝         `History` removed
    ∇

    ∇ (rc more)←{exclude}Create(pattern zipFilename);cmd;path;rc;more;buffer;tfn1;tfn2;flag
      :Access Public Shared
    ⍝ Zip all files caught by "pattern" (one to many) into "zipFilename" together _
    ⍝ with the file structure. For that you want to use relative filenames in pattern.
      exclude←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'exclude'
      zipFilename←CheckExtension zipFilename
      pattern←Nest pattern
      'Invalid ZIP request (names must be unique)'⎕SIGNAL 11/⍨∨/{(⍵⍳⍵)≠⍳⍴⍵}⊃,/#.WinFile.Dir¨pattern
      tfn1←refToUtils_.WinFile.GetTempFileName''
      WriteUtf8File tfn1 pattern
      path←refToUtils_.WinReg.GetString GetWinZipRegistryPath,'Programs\zip2exe'
      path←(0⊃SplitPath path),'wzzip.exe'
      cmd←'"',(path~'"'),'" '
      cmd,←'-r -p '
      :If flag←~0∊⍴exclude
          tfn2←refToUtils_.WinFile.GetTempFileName''
          WriteUtf8File tfn2 exclude
          cmd,←'-x@',tfn2,' '
      :EndIf
      cmd,←zipFilename,' '
      cmd,←'@',tfn1,' '
      buffer←refToUtils_.Execute.Process cmd
      :If 0≠0⊃buffer
          rc←1
          more←'Could not execute WinZip'
      :Else
          (rc more)←(2⊃buffer)(1⊃buffer)
      :EndIf
      refToUtils_.WinFile.Delete tfn1
      refToUtils_.WinFile.Delete flag{⍺:⍎⍵ ⋄ ''}'tfn2'
    ∇

    ∇ r←List zipFilename;cmd;path;rc;more;tfn;buffer;b;ind;list
      :Access Public Shared
    ⍝ List conents of "zipFilename"
      zipFilename←CheckExtension zipFilename
      path←refToUtils_.WinReg.GetString GetWinZipRegistryPath,'Programs\zip2exe'
      path←(0⊃SplitPath path),'wzzip.exe'
      cmd←'"',(path~'"'),'" '
      cmd,←'-v  '
      cmd,←zipFilename,' '
      buffer←refToUtils_.Execute.Process cmd
      :If 0≠0⊃buffer
          'Could not execute WinZip'⎕SIGNAL 11
      :Else
          list←1⊃buffer
          ind←¯1 2+{⍵/⍳⍴⍵}(∪¨list)∊' -' '- '            ⍝ These sourround the real contents
          list←ind[1]↑list                              ⍝ Drop footer
          r←Mix ind[0]↓list                             ⍝ Drop header
      :EndIf
    ∇

    ∇ (rc more)←Extract(zipFilename targetPath);path;cmd;buffer
    ⍝ Extracts contents of "zipFilename" while preserving the folder structure.
    ⍝ Existing files are overwritten.
      :Access Public Shared
      zipFilename←CheckExtension zipFilename
      path←refToUtils_.WinReg.GetString GetWinZipRegistryPath,'Programs\zip2exe'
      path←(0⊃SplitPath path),'wzunzip.exe'
      cmd←'"',(path~'"'),'" '
      cmd,←'-d -o '
      cmd,←zipFilename,' ',targetPath
      buffer←refToUtils_.Execute.Process cmd
      :If 0≠0⊃buffer
          rc←1
          more←'Could not execute WinZip'
      :Else
          (rc more)←(2⊃buffer)(1⊃buffer)
      :EndIf
    ∇

⍝⍝⍝ Private stuff

    ∇ r←GetWinZipRegistryPath
      r←'HKLM\SOFTWARE\Nico Mak Computing\WinZip\'
    ∇

    ∇ r←refToUtils_
      :If 0∊⍴refToUtils
          r←##
      :Else
          r←refToUtils
      :EndIf
    ∇

      CheckExtension←{
    ⍝ If there is no extension add ".zip"
          (p fn)←SplitPath ⍵
          fn←{'.'∊⍵:⍵ ⋄ ⍵,'.zip'}fn
          p,fn
      }

      CheckFilesForDoublettes←{
          list1←⍵
          list2←Lowercase list1
          names←1⊃∘SplitPath¨list2
          sortIndex←⍋⊃names
          (names list1 list2)←sortIndex∘{(⊂⍺)⌷⍵}¨names list1 list2
          unique←∪names
          (↑=/⍴¨unique list1):⍬ ⍬
          names2←({(⍳⍴⍵)≠⍵⍳⍵}names)/names
          list←↑,/' ',¨⊃¨(names∊names2)∘/¨names list1
          11 ⎕SIGNAL⍨'Invalid ZIP request (cannot repeat names in Zip file); check: ',⊃,/(⎕UCS 13),¨↓list
      }

:EndClass