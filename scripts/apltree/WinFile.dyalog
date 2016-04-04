:Class WinFile
⍝ Provides information about files and directories without using any .NET stuff.
⍝ Many methods (`Dir` + `DirX` for example) are ''much'' faster than the .NET stuff.
⍝ The class contains shared methods only.
⍝ Almost all methods throw exceptions in case of an error. However, when an _
⍝ error is very likely you have the choice to call a cover function that actually _
⍝ returns a return code.
⍝ See `→[MoveTo]` and `→[MoveToWithRC]` as well as `→[CopyTo]` and `→[CopToWithRC]`.
⍝ == Indexers for file attributes
⍝ Note that there are fields available since version 1.7.0 useful to index the _
⍝ matrix returned by `DirX`. The field names start with "COL_" and "FA_" (for the _
⍝ file attributes). They assume a `⎕IO` of 1. If you use `⎕IO←0` you have two _
⍝ options:
⍝ `WinFile.((DirX'C:\')[;COL_Size])` executes the expression inside `WinFile` which _
⍝ uses a `⎕IO` setting of 1 in any case.
⍝ This statement:
⍝ `(WinFile.DirX 'C:\')[;WinFile.COL_CreationDateName-~⎕IO]`
⍝ executed the indexing ''outside'' of `#.WinFile` which means that `⎕IO` is zero. _
⍝ Therefore you need to take action. Subtracting `~⎕IO` from the constant is _
⍝ probably the best technique in any case since it will always work, no matter _
⍝ what value `⎕IO` actually holds.
⍝ Kai Jaeger ⋄ APL Team Ltd
⍝ Homepage: http://aplwiki.com/WinFile

    ⎕IO←1 ⋄ ⎕ml←3

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public shared
      r←(Last⍕⎕THIS)'3.5.1' '2015-08-16'
      ⍝ 3.5.1  * `ExpandPath` return rubbish when path contained "
      ⍝ 3.5.0  * New methods `HasSubDirs`.
      ⍝        * Documentation improved.
      ⍝        * `Dir` ignored any setting of `noOf`.
      ⍝ 3.4.1  * ⎕IO/⎕ML fully isolated
      ⍝ 3.4.0  * APL inline code is now marked up with ticks
      ⍝        * `History` removed.
      ⍝        * `Version returns just the name, no path.
    ∇

    :Field Public Shared ReadOnly FA_READONLY←37            ⍝ 1 0x1         A file that is read-only.
    :Field Public Shared ReadOnly FA_HIDDEN←36              ⍝ 2 0x2         The file or directory is hidden. It is not included in an ordinary directory listing.
    :Field Public Shared ReadOnly FA_SYSTEM←35              ⍝ 4 0x4         A file or directory that the operating system uses a part of, or uses exclusively.
    :Field Public Shared ReadOnly FA_DIRECTORY←34           ⍝ 16 0x10       Flag that identifies a directory.
    :Field Public Shared ReadOnly FA_ARCHIVE←33             ⍝ 32 0x20       A file or directory that is an archive file or directory.
    :Field Public Shared ReadOnly FA_DEVICE←32              ⍝ 64 0x40       This value is reserved for system use.
    :Field Public Shared ReadOnly FA_NORMAL←31              ⍝ 128 0x80      A file that does not have other attributes set.
    :Field Public Shared ReadOnly FA_TEMPORARY←30           ⍝ 256 0x100     A file that is being used for temporary storage.
    :Field Public Shared ReadOnly FA_SPARSE_FILE←29         ⍝ 512 0x200     A file that is a sparse file.
    :Field Public Shared ReadOnly FA_REPARSE_POINT←28       ⍝ 1024 0x400    A file or directory that has an associated reparse point, or a file that is a symbolic link.
    :Field Public Shared ReadOnly FA_COMPRESSED←27          ⍝ 2048 0x800    A file or directory that is compressed.
    :Field Public Shared ReadOnly FA_OFFLINE←26             ⍝ 4096 0x1000   The data of a file is not available immediately (offline storage).
    :Field Public Shared ReadOnly FA_NOT_CONTENT_INDEXED←25 ⍝ 8192 0x2000   The file or directory is not to be indexed by the content indexing service.
    :Field Public Shared ReadOnly FA_ENCRYPTED  ←24         ⍝ 16384 0x4000  A file or directory that is encrypted.
    :Field Public Shared ReadOnly FA_VIRTUAL←22             ⍝ 65536 0x10000 This value is reserved for system use.

    :Field Public Shared ReadOnly COL_Name←1                ⍝ Full name
    :Field Public Shared ReadOnly COL_ShortName←2           ⍝ 8.3 name
    :Field Public Shared ReadOnly COL_Size←3                ⍝ Size in bytes
    :Field Public Shared ReadOnly COL_CreationDateName←4    ⍝ File creation date
    :Field Public Shared ReadOnly COL_LastAccessDate←5      ⍝ Last access date
    :Field Public Shared ReadOnly COL_LastWriteDate←6       ⍝ Last write date

    :Field Public Shared ReadOnly okay←0

    :Field Private Shared ReadOnly maxNoOfFiles←10000000000
    :Field Private ReadOnly NoOfCols←38                     ⍝ How much columns does DirX return by default?


    ∇ R←{noSplit}ReadAnsiFile filename;No;Size;⎕IO;⎕ML
 ⍝ Read contents as chars. File is tied in shared mode.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      noSplit←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'noSplit'
      filename←CorrectForwardSlash filename
      filename~←'"'
      No←filename ⎕NTIE 0,66
      Size←⎕NSIZE No
      R←⎕NREAD No,82,Size,0
      ⎕NUNTIE No
      :If ~noSplit
          :If 0<+/(⎕UCS 13 10)⍷R
              R←Split R
          :ElseIf (⎕UCS 10)∊R
              R←(⎕UCS 10)Split R
          :EndIf
      :EndIf
    ∇

    ∇ {r}←Data WriteAnsiFile filename;No;CrLf;⎕IO;⎕ML
    ⍝ Data must be a string or a vector of strings. If file already exists it is replaced.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      CrLf←⎕UCS 13 10
      :Trap 22
          No←(filename~'"')⎕NTIE 0
          (filename~'"')⎕NERASE No
          ⎕DL 0.1
      :EndTrap
      No←(filename~'"')⎕NCREATE 0
      :Select ≡Data
      :Case 0
          ⍝ Nothing to do
      :Case 1
          :If 2=⍴⍴Data
              Data←(-⍴CrLf)↓,Data,((↑⍴Data),2)⍴CrLf
          :EndIf
      :Case 2
          Data←(-⍴CrLf)↓∊Data,¨⊂CrLf
      :Else
          11 ⎕SIGNAL'Domain Error: check data'
      :EndSelect
      Data ⎕NAPPEND No
      ⎕NUNTIE No
      r←''
    ∇

    ∇ R←Cd Name;Rc;∆GetCurrentDirectory;∆SetCurrentDirectory;⎕IO;⎕ML
    ⍝ Report/change the current directory.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      Name←CorrectForwardSlash Name
      '∆GetCurrentDirectory'⎕NA'I4 KERNEL32.C32|GetCurrentDirectory',QnaType,' I4 >T[]'
      '∆SetCurrentDirectory'⎕NA'I4 KERNEL32.C32|SetCurrentDirectory',QnaType,' <0T'
      :If 0=↑Rc←∆GetCurrentDirectory 260 260
          R←GetLastError'GetCurrentDirectory error' ''
      :Else
          R←↑↑/Rc
      :EndIf
      :If ~0∊⍴Name←Name~'"'
      :AndIf ' '=1↑0⍴Name
          Name,←('\'≠¯1↑Name)/'\'
          :If ~∆SetCurrentDirectory⊂Name
              11 ⎕SIGNAL⍨⊃{⍵,'; rc=',⍕⍺}/GetLastError'SetCurrentDirectory error'
          :EndIf
      :EndIf
    ∇

    ∇ r←IsFilenameOkay filename;tf;fullName;f
      :Access Public Shared
    ⍝ Returns a 1 in case "filename" is okay. "filename" must not have a path.
    ⍝ In order to check this a file with the given name is created in the temp folder.
      'Invalid right argument'⎕SIGNAL 11/⍨~(⎕DR,filename)∊80 82
      'Invalid right argument'⎕SIGNAL 11/⍨∨/'\/'∊filename
      tf←CreateTempFolder                               ⍝ Create a proper folder
      fullName←tf,'\',filename                          ⍝ Full name
      r←{0::0 ⋄ _←'aa'WriteAnsiFile ⍵ ⋄ 1}fullName      ⍝ Try to write but trap errors
      :Trap 0 ⋄ 'Recursive'RmDir tf ⋄ :EndTrap          ⍝ Remove the dir
    ∇

    ∇ r←IsFoldernameOkay foldername;tf;fn
      :Access Public Shared
    ⍝ Returns a 1 in case "filename" is okay. "foldername" must not have a path.
    ⍝ In order to check this a directory "foldername" is created in the temp folder.
      'Invalid right argument'⎕SIGNAL 11/⍨~(⎕DR,foldername)∊80 82
      'Invalid right argument'⎕SIGNAL 11/⍨∨/'\/'∊foldername
      tf←CreateTempFolder
      fn←tf,'\',foldername                      ⍝ Full name
      r←{0::0 ⋄ _←MkDir ⍵ ⋄ 1}fn                ⍝ Try to ceate a folder with that name
      :Trap 0 ⋄ 'Recursive'RmDir tf ⋄ :EndTrap  ⍝ Remove the dir
    ∇

    ∇ r←PWD
    ⍝ Print Working Directory. Shortcut for `→[Cd'']`.
      :Access Public Shared
      r←Cd''
    ∇

    ∇ {r}←Source CopyTo Target;⎕IO;⎕ML;rc;more
    ⍝ Copy "Source" to "Target".
    ⍝ The left argument must be a file. Wildcard characters are not _
    ⍝ supported. The right argument might be a filename or a folder. _
    ⍝ If it is a folder the filename of "Source" is used for the new file.
    ⍝ `CopyTo` overwrites the target file if there is any.
    ⍝ Examples:
    ⍝ 'C:\readme.txt' WinFile.CopyTo 'D:\buffer\'
    ⍝ 'C:\readme.txt' WinFile.CopyTo 'D:\buffer\newname.txt'
    ⍝ When the "Copy" operation fails a DOMAIN ERROR is thrown.
    ⍝ The (shy) result `r` is always an empty vector in order to make _
    ⍝ `CopyTo` callable from a direct function.
    ⍝ If you prefer return codes over exceptions see `CopyToWithRC`.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      r←''
      (rc more)←Source CopyTo__ Target
      more ⎕SIGNAL 11/⍨okay≠rc
    ∇

    ∇ {(rc more)}←Source CopyToWithRC Target;⎕IO;⎕ML
    ⍝ Copy "Source" to "Target".
    ⍝ The left argument must be a file. Wildcard characters are not _
    ⍝ supported. The right argument might be a filename or a folder. _
    ⍝ If it is a folder the filename of "Source" is used for the new file.
    ⍝ `CopyTo` overwrites the target file if there is any.
    ⍝ Examples:
    ⍝ 'C:\readme.txt' WinFile.CopyTo 'D:\buffer\'
    ⍝ 'C:\readme.txt' WinFile.CopyTo 'D:\buffer\newname.txt'
    ⍝ When the "Copy" operation fails a DOMAIN ERROR is thrown.
    ⍝ The (shy) result r is always an empty vector in order to make _
    ⍝ `CopyToWithRC` callable from a direct function.
    ⍝ If you prefer exceptions over return codes see `→[CopyTo]`.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      rc←0 ⋄ more←''
      (rc more)←Source CopyTo__ Target
    ∇

    ∇ {Bool}←Delete Filename;Bool;i;a;∆DeleteFile;⎕ML;⎕IO
    ⍝ Delete one or more files.
    ⍝ Note that the explicit result tells you whether the file to be deleted existed upfront or not. _
    ⍝ It does <b>not</b> tell you whether the delete operation was successful or not. _
    ⍝ This is not a bug in `WinFile`, it is what the underlying Windows API function _
    ⍝ is returning. If you need to be sure that the file in question really got deleted _
    ⍝ use `→[WinFile.DoesExistFile]` afterwards to find out.
    ⍝ Note that `Delete` does ''not'' support wildcards. If it finds wildcard chars it _
    ⍝ will throw an error.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆DeleteFile'⎕NA'I kernel32.C32|DeleteFile',QnaType,' <0T'
      Filename←RavelEnclose Filename
      Filename←CorrectForwardSlash¨Filename
      Bool←1⍴⍨⍴Filename←Filename~¨'"'
      'Delete does not support wildcard chars (?*)'⎕SIGNAL 11/⍨∨/¨'?*'∘∊¨Filename
      :For i :In ⍳⍴Bool
          (i⊃Bool)←0≠∆DeleteFile Filename[i]
      :EndFor
      ⎕DL 0.01 ⍝ DON'T delete this!
    ∇

    ∇ r←{ref}GetDirList path;Block;handle;path2;mask;ok;NOOFEACH;PS;rc;⎕ML;⎕IO
         ⍝ Returns just the names of all sub-directories found in "path",
         ⍝ Therefore significantly faster than Dir/DirX.
      ⎕IO←1 ⋄ ⎕ML←3
      :If 0=⎕NC'ref'
          ref←CreateDirParms
          ref.Counter←0
          EstablishQNA_FunctionsForDir ref
      :EndIf
      (path path2 mask)←ProcessPath path
      (handle Block)←ref FindFirstFile path
      r←''
      :If 0=handle
          path←(((~':'∊path2)∧'\\'≢2⍴path)/PWD,'\'),path
          :If {∨/'*?'∊⍵:1 ⋄ DoesExistFile ⍵}(-2×'\*'≡¯2↑path)↓path
              (handle Block)←ref FindFirstFile(-2×'\*'≡¯2↑path)↓path
              :If 0=handle
                  ok←ref.∆FindClose handle
                  →∆Quit
              :Else
                  :If GetLastError∊2 3
                      →∆CarryOn
                  :Else
                      11 ⎕SIGNAL⍨'Error: ',⍕Block
                  :EndIf
              :EndIf
          :Else
              :If (¯1=ref.RECURSIVE){(⍵∊2 3):1 ⋄ ⍺∧⍵=5}rc←GetLastError  ⍝ Ignore 5 (access denied) in case of recursion and we are not on first level  (¯1)
                  :Return  ⍝ Nothing found, so we are done
              :Else
                  11 ⎕SIGNAL⍨'Error! RC=',⍕rc
              :EndIf
          :EndIf
      :Else
     ∆CarryOn:
          r←GetDirList_ r ref path Block
      :EndIf
     ∆Quit:
      :Trap 0 ⋄ {}ref.∆FindClose handle ⋄ :EndTrap
    ∇

    ∇ r←GetDirList_(r ref path Block);⎕IO;⎕ML;ok;more
    ⍝ Called by GetDirList - has no independent meaning. Its only purpose is to isolate ⎕IO.
      ⎕IO←0 ⋄ ⎕ML←3
      Block←(ref WhichAreDirs,⊂Block)/6⊃Block
      :If ref.IGNORERECYCLEBIN
      :AndIf ~0∊⍴Block←(Block≢'$RECYCLE.BIN')/Block
          :If ¯1=ref.RECURSIVE
              Block←(~(⊂,Block)∊,¨'.' '..')/Block
          :EndIf
      :AndIf ~0∊⍴Block
          r←,⊂Block
          ref.Counter+←1
      :EndIf
      :If ref.NOOFEACH>⍴r
          :Repeat
              (ok more Block)←ref ReadBlockX(handle(ref.NOOF⌊ref.BLOCKSIZE)path)  ⍝ +2 for '.' and '..'
              :If 1=ok
                  :If 0∊⍴Block
                      :Leave
                  :EndIf
              :Else
                  . ⍝ deal with serious errors; has never occured so far!
              :EndIf
              Block←(ref WhichAreDirs Block)/6⊃¨Block
              :If ¯1=ref.RECURSIVE
                  Block←(~Block∊'.' '..')/Block
              :EndIf
              r,←Block
              ref.Counter+←⍴Block
          :Until 0
      :EndIf
    ∇

    ∇ r←ref GetDirListRecursion path;list;this
      r←(⊂path),¨(ref GetDirList path)~,¨'.' '..'
      :For this :In r     ⍝ Don't each this: "access denied" and stuff!
          :If ~0∊⍴list←(ref GetDirListRecursion this,'\')~,¨'.' '..'
              r,←list
          :EndIf
      :EndFor
    ∇

    ∇ {R}←{NewFlag}CheckPath Path;This;Volume;Path_2;Rc;Hint;⎕ML;⎕IO;qmx
    ⍝ Returns a 1 if the path to be checked is fine, otheriwse 0.
    ⍝ If the path does not exist but the left argument is "CREATE!" it will be created.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      R←0
      Path←CorrectForwardSlash Path
      NewFlag←'CREATE!' 1∊⍨⊂{6::0 ⋄ {(0=1↑0⍴⍵):⍵ ⋄ Uppercase ⍵}⍎⍵}'NewFlag'
      Path←(¯1×'\'=¯1↑Path)↓Path
      :If 1=DoesExistDir Path
          R←1 ⍝ Path exists, get out!
      :Else
          Path_2←{⍵↓⍨-'\'⍳⍨⌽⍵}Path
          :If 0∊⍴Path_2
          :OrIf R←NewFlag CheckPath Path_2
              :If NewFlag
                  :Trap 0
                      MkDir Path
                      R←1
                  :Else
                      qmx←⎕DMX
                      11 ⎕SIGNAL⍨⎕IO⊃⎕DM
                  :EndTrap
              :Else
                  R←0
              :EndIf
          :Else
              R←1
          :EndIf
      :EndIf
    ∇

    ∇ R←{Type}DateOf Filenames;Rc;Hint;Length;handle;Buffer;Attr;This;ok;⎕ML;PS;⎕IO
      :Access Public Shared
    ⍝ "Type" may be one of: "Creation Time", "Last Access", "Last Write" (default!), "All"
      ⎕IO←1 ⋄ ⎕ML←3
      Type←{(0<⎕NC ⍵):⍎⍵ ⋄ 'Last Write'}'Type' ⍝ establish the default
      Filenames←RavelEnclose Filenames
      Filenames←CorrectForwardSlash¨Filenames
      WIN32_FIND_DATA←'{I4 {I4 I4} {I4 I4} {I4 I4} {I4 I4} {I4 I4} T[260] T[14]}'
      PS←⎕NS''
      EstablishQNA_FunctionsForDir PS
      Attr←''
      :For This :In Filenames
          (handle Buffer)←PS FindFirstFile This~'"'
          :If 0=handle
              R←¯1
              :Return
          :Else
              Attr,←⊂Buffer
              {}PS.∆FindClose handle
          :EndIf
      :EndFor
      Attr←⊂[1]⊃Attr
      Length←⍴Type←Uppercase,Type
      Attr←Attr[2 3 4]
      :Select Type
      :Case Length↑'LAST WRITE'
          R←PS Filetime_to_TS¨3⊃Attr
      :Case Length↑'LAST ACCESS'
          R←PS Filetime_to_TS¨2⊃Attr
      :Case Length↑'CREATION TIME'
          R←PS Filetime_to_TS¨1⊃Attr
      :Case Length↑'ALL'
          R←PS Filetime_to_TS¨Attr
      :Else
          'Invalid left argument'⎕SIGNAL 13
      :EndSelect
      :If Type≢'ALL'
          :If 1=⍴,Filenames
              R←↑R
          :Else
              R←⊃R
          :EndIf
      :EndIf
    ∇

    ∇ R←{Parms}Dir Path;⎕ML;⎕IO;Path2;Mask;PS;Parms
    ⍝ List the contents (names only) of a given directory, by default the current one.
    ⍝ Pass `('Recursive' 1)` as left argument to list all sub-directories, too.
    ⍝ Note that when `('Recursive' 1)` is specified as left argument, any wildcard chars in _
    ⍝ the right argument do effect just the result list but not the directories searched.
    ⍝ For example, this expression:
    ⍝ ````
    ⍝ WinFile.Dir '*.svn'
    ⍝ ````
    ⍝ returns a list with all directories matching the pattern, even if they are contained _
    ⍝ in a sub-folder "abc" of the current dir which obviously doesn't match the pattern.
      :Access Public Shared
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      Parms←{(0=⎕NC ⍵):CreateDirParms ⋄ ⍎⍵}'Parms'
      PS←'NoOf' 'Recursive' 'BlockSize' 'Sort'(CreateDirParms ProcessDirParms)Parms
      PS.Counter←0
      PS.FILETIME←0
      PS.COLS←COL_Name,-FA_DIRECTORY
      EstablishQNA_FunctionsForDir PS
      R←(0,38{(0∊⍴⍵):⍺ ⋄ ⍴⍵}PS.COLS)⍴' '
      (Path Path2 Mask)←ProcessPath Path
      'Invalid syntax: wildcards (*?) are not allowed in folder names'⎕SIGNAL 11/⍨∨/'*?'∊Path2
      R(ScanDirs)←PS Path Path2 0
      R←,R
    ∇

    ∇ R←{Parms}DirX Path;⎕IO;⎕ML;Path2;Mask;PS;allowed
         ⍝ List the contents (names and attributes) of a given directory, by default the current one.
         ⍝ Pass `('Recursive' 1)` as left argument to list all sub-directories, too.
         ⍝ By default, long names as well as short names together with file properties are _
         ⍝ returned but no timestamps. If you are in need for timestamps specify _
         ⍝ `('FileTime' 1)` as left argument.
         ⍝ You can restrict the number of files returned by specifying `('NoOf' {anyNumber})`.
         ⍝ Note that when a recursive scan is performed any wildcard chars in the right _
         ⍝ argument do effect the result list only but ''not'' the directories searched.
         ⍝ For example, this expression:
         ⍝ ````
         ⍝ WinFile.DirX '*.svn'
         ⍝ ````
         ⍝ returns a list with all files matching the pattern, even if they are contained _
         ⍝ in a sub-folder "abc" of the current dir which obviously doesn't match the pattern.
         ⍝ Note that the function returns an empty vector in case of a non-existing folder _
         ⍝ specified somewhere in the path. In case of any other error the error is signalled.
         ⍝ For addressing the file attributes see (and use) the `FA_*` and/or `COL_*` fields.
         ⍝ This example extracts the "Last write date" and the directory flag:
         ⍝ `WinFile.((DirX '*')[;COL_LastWriteDate,FA_DIRECTORY])`
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      Parms←{(0=⎕NC ⍵):CreateDirXParms ⋄ ⍎⍵}'Parms'
      allowed←'NoOf' 'Recursive' 'FileTime' 'BlockSize' 'Sort' 'Cols' 'IgnoreRecycleBin' 'NoOfEach'
      PS←allowed(CreateDirXParms ProcessDirParms)Parms
      PS←CheckDirCols PS
      PS.Counter←0
      EstablishQNA_FunctionsForDir PS
      R←(0,38{(0∊⍴⍵):⍺ ⋄ ⍴⍵}PS.COLS)⍴' '
      (Path Path2 Mask)←ProcessPath Path
      'Invalid syntax: wildcards (*?) are not allowed in folder names'⎕SIGNAL 11/⍨∨/'*?'∊Path2
      R(ScanDirs)←PS Path Path2 0
    ∇

    ∇ R←{NewFlag}DoesExistDir Paths;buffer;∆PathIsDirectory;⎕IO;⎕ML
    ⍝ Returns a Boolean for every dir in the right argument. The right argument can be one of:
    ⍝ * Simple string. Treated as name of a single directory.
    ⍝ * Vector of strings. Every item is treated as a directory name.
    ⍝ A 1 indicates that the corresponding directory exists.
    ⍝ A 0 however does not necessarily mean that the directory does ''not'' exist: _
    ⍝ the user might just lack the access rights. A 1 always means you can read the directory.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      Paths←RavelEnclose Paths
      Paths←CorrectForwardSlash¨Paths
      'Wildcard characters are not supported'⎕SIGNAL 11/⍨∨/¨'?*'∘∊¨Paths
      '∆PathIsDirectory'⎕NA'I Shlwapi.C32|PathIsDirectory',QnaType,' <0T >I'
      R←16=↑¨{∆PathIsDirectory ⍵ 0}¨Paths~¨'"'
    ∇

    ∇ R←DoesExistFile Filenames;∆PathFileExists;⎕IO;⎕ML
    ⍝ Returns a Boolean for every file in the right argument. The right argument can be one of:
    ⍝ * Simple string. Treated as name of a single filename.
    ⍝ * Vector of strings. Every item is treated as a filename.
    ⍝ A 1 indicates that the corresponding file does exist.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      Filenames←RavelEnclose Filenames
      Filenames←CorrectForwardSlash¨Filenames
      'Wildcard characters are not supported'⎕SIGNAL 11/⍨∨/¨'?*'∘∊¨Filenames
      '∆PathFileExists'⎕NA'I4 shlwapi.C32|PathFileExists',QnaType,' <0T >I'
      :If 0<+/R←↑¨{∆PathFileExists ⍵ 0}¨Filenames~¨'"'
          '∆PathIsDirectory'⎕NA'I Shlwapi.C32|PathIsDirectory',QnaType,' <0T >I'
          (R/R)←16≠↑¨{∆PathIsDirectory ⍵ 0}¨R/Filenames~¨'"'
      :EndIf
    ∇

    ∇ R←DoesExist pattern;∆PathFileExists;⎕IO;⎕ML
    ⍝ Returns a Boolean for every file or directory in the right argument. _
    ⍝ The right argument can be one of:
    ⍝ * Simple string. Treated as a single name (file or directory).
    ⍝ * Vector of strings. Every item is treated as a name (file or directory).
    ⍝ A 1 indicates that the corresponding file or directory does exist.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      pattern←RavelEnclose pattern
      pattern←CorrectForwardSlash¨pattern
      'Wildcard characters are not supported'⎕SIGNAL 11/⍨∨/¨'?*'∘∊¨pattern
      '∆PathFileExists'⎕NA'I4 shlwapi.C32|PathFileExists',QnaType,' <0T >I'
      R←↑¨{∆PathFileExists ⍵ 0}¨pattern~¨'"'
    ∇

    ∇ R←GetAllDrives;Values;Drives;∆GetLogicalDriveStrings;⎕IO;⎕ML
    ⍝ Returns a vector of text vectors with the names of all drives, for example:  "C:\"
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetLogicalDriveStrings'⎕NA'U4 KERNEL32.C32|GetLogicalDriveStrings',QnaType,' U4 >T[]'
      Values←∆GetLogicalDriveStrings 255 255
      Drives←⊂(↑Values)↑(⎕IO+1)⊃Values
      R←((~(⎕UCS 0)=∊Drives)⊂∊Drives)
    ∇

    ∇ R←GetDriveAndType;AllDrives;Txt;Types;∆GetDriveType;⎕IO;⎕ML
     ⍝ Returns a matrix with the names and the types of all drives.
     ⍝ The number of rows is defined by the number of drives found.
     ⍝ "Types" may be something like "Fixed", "CD-ROM", "Removable", "Remote"
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetDriveType'⎕NA'U4 KERNEL32.C32|GetDriveType',QnaType,' <0T'
      Types←∆GetDriveType∘⊂¨AllDrives←GetAllDrives
      Txt←'Invalid Path' 'Removable' 'Fixed' 'Remote' 'CD-ROM' 'Ram-Disk'
      R←AllDrives,Types,[1.5](Txt,⊂'Unknown')[(0,⍨⍳⍴Txt)⍳Types]
    ∇

    ∇ Filename←{PrefixString}GetTempFileName PathName;Rc;Hint;⎕ML;⎕IO;No;fno;Start
      ⍝ Returns the name of an unused temporary filename. If "PathName" _
      ⍝ is empty the default temp path is taken. This means you can _
      ⍝ overwrite this by specifying a path.
      ⍝ "PrefixString", if defined, is a leading string of the filename _
      ⍝ going to be generated. This is ''not'' the same as
      ⍝ `'pref',GetTempFileName ''`
      ⍝ because specified as left argument it is taken into account _
      ⍝ when the uniquness of the created filename is tested.
      ⍝ This function does ''not'' use the Windows built-in function since _
      ⍝ this one has proven to be unreliable under W7 (at least).
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      PrefixString←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'PrefixString'
      PathName←CorrectForwardSlash PathName
      PathName,←((~0∊⍴PathName)∧'\'≠¯1↑PathName)/'\'
      :If 0∊⍴PathName
          :Trap 0
              PathName←GetTempPath
          :Else
              11 ⎕SIGNAL⍨'Cannot get a temp path; rc=',⍕⎕EN
          :EndTrap
      :EndIf
      :If 0=Rc←'Create!'CheckPath PathName
          11 ⎕SIGNAL⍨'Error during "Create <',PathName,'>"; rc=',⍕GetLastError
      :Else
          Start←No←⍎{(,'ZI2,ZI2,ZI2'⎕FMT 3↑⍵),⍕3↓⍵}3↓⎕TS  ⍝ Expensive but successful very soon
          ⍝ No←100⊥3↓⎕TS ⍝ Not reliable: can take a large number of efforts before success
          :Repeat
              Filename←PathName,PrefixString,(⎕AN,'_',⍕No),'.tmp'
              fno←0
              :Trap 22
                  ⎕NUNTIE fno←Filename ⎕NCREATE 0
                  flag←1
              :EndTrap
              No+←10
          :Until (fno≠0)∨No>Start+1000×10  ⍝ max 1000 tries
      :EndIf
    ∇

    ∇ R←GetTempPath;Path;∆GetTempPath;⎕ML;⎕IO
    ⍝ Returns the name of the path to the Windows temp directory on the current system.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetTempPath'⎕NA'I4 KERNEL32.C32|GetTempPath',QnaType,' I4 >T[]'
      Path←↑↑/∆GetTempPath 1024 1024 ⍝ 260 260
      :If ~0∊⍴Path
          R←Path
      :Else
          11 ⎕SIGNAL⍨'Problem getting Windows temp path!; rc=',⍕GetLastError
      :EndIf
    ∇

    ∇ R←IsDirEmpty Paths;∆PathIsDirectoryEmpty;⎕ML;⎕IO
    ⍝ Returns 1 if empty, 0 if not and ¯1 if the directory could not be found or is a file.
    ⍝ The right argument can be one of:
    ⍝ * Simple string. Treated as a single name (file or directory).
    ⍝ * Vector of strings. Every item is treated as a name (file or directory).
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      '∆PathIsDirectoryEmpty'⎕NA'I4 Shlwapi.C32|PathIsDirectoryEmpty',QnaType,' <0T >I'
      Paths←RavelEnclose Paths
      :If 0∊R←↑¨{∆PathIsDirectoryEmpty ⍵ 0}¨Paths~¨'"'
          ((~R)/R)←¯1×~DoesExistDir(~R)/Paths
      :EndIf
    ∇

    ∇ r←HasSubDirs paths;i;noOf;WIN32_FIND_DATA;∆FindFirstFile;∆FindNextFile;∆FindClose;⎕IO;⎕ML
      :Access Public Shared
    ⍝ Takes a string or a vector os strings (paths) and returns a Boolean scalar _
    ⍝ (in case ⍵ is a simple text vector) or a vector of Booleans indicating _
    ⍝ whether the directory has sub-directories (1) or not (0).
    ⍝ Note that this function is sigificantly faster than doing just _
    ⍝ `⍴ListDirsOnly` on several directories.
      ⎕IO←1 ⋄ ⎕ML←3
      WIN32_FIND_DATA←'{I4 {I4 I4} {I4 I4} {I4 I4} {I4 I4} {I4 I4} T[260] T[14]}'
      '∆FindFirstFile'⎕NA'I4 kernel32.C32|FindFirstFile',QnaType,' <0T >',WIN32_FIND_DATA
      '∆FindNextFile'⎕NA'U4 kernel32.C32|FindNextFile',QnaType,' I4 >',WIN32_FIND_DATA
      '∆FindClose'⎕NA'kernel32.C32|FindClose I4'
      paths←,∘⊂∘,⍣(0 1∊⍨≡paths)⊣paths
      noOf←⍴paths
      r←noOf⍴0
      :For i :In ⍳noOf
          (i⊃r)←ContainsSubDirs(i⊃paths),'\*'
      :EndFor
    ∇

    ∇ R←Filename1 YoungerThan Filename2;TS_1;TS_2;⎕ML;⎕IO
      :Access Public Shared
    ⍝ Compare the "last changed at" timestamp of both, `Filename1` and `Filename2`.
      ⎕IO←1 ⋄ ⎕ML←3
      Filename1←CorrectForwardSlash Filename1
      Filename2←CorrectForwardSlash Filename2
      :Trap 0
          TS_1←('FileTime' 1)DirX Filename1
      :Else
          11 ⎕SIGNAL⍨{⎕ML←3 ⋄ 1↓∊(⎕UCS 10),¨⍵}⎕DM
      :EndTrap
      :Trap 0
          TS_2←('FileTime' 1)DirX Filename2
      :Else
          11 ⎕SIGNAL⍨{⎕ML←3 ⋄ 1↓∊(⎕UCS 10),¨⍵}⎕DM
      :EndTrap
      TS_1←6⊃TS_1[1;]
      TS_2←6⊃TS_2[1;]
      :If =/R←100⊥¨¯1↓¨TS_1 TS_2
          R←↑</¯1↑¨TS_1 TS_2
      :Else
          R←</R
      :EndIf
    ∇

    ∇ R←{Recursive}ListDirsOnly Path;Rc;ErrHint;Buffer;Buffer_2;This;Hint;⎕IO;Return;recursiveFlag;⎕ML;PS
    ⍝ Returns a list with all directories in "Path". In order to get also _
    ⍝ sub-directories specify `'recursive'` as left argument.
    ⍝ Wildcards are supported but only to the right after the last "\" character.
    ⍝ Note that when used with `'Recursive'` as left argument the wildcards only _
    ⍝ affect the resulting list of directories but ''not'' the directories searched.
    ⍝ Notes:
    ⍝ * "$RECYCLE.BIN" is included
    ⍝ * The directories "." and ".." are ''not'' included.
    ⍝ Examples:
    ⍝ ````
    ⍝ ListDirsOnly '?.svn'          ⍝ Is there a dir ".svn" in the current dir?
    ⍝ ListDirsOnly '*.acre'         ⍝ List all dirs ending with ".acre" in current dir
    ⍝ ListDirsOnly 'ThisFolder'     ⍝ Assums "ThisFolder" is a dir & looks into it
    ⍝ ListDirsOnly 'ThisFolder\'    ⍝ Same as before
    ⍝ ````
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      R←''
      Recursive←{6::'' ⋄ Uppercase⍎⍵}'Recursive'
      recursiveFlag←Recursive≡'RECURSIVE'
      Path←CorrectForwardSlash Path
      :If 0∊⍴,Path
          Path←'*'
      :Else
          :If ∧/~'*?'∊Path
              Path,←'\'/⍨'\'≠¯1↑Path
          :EndIf
      :EndIf
      PS←CreateDirParms
      PS.Counter←0
      EstablishQNA_FunctionsForDir PS
      PS.IGNORERECYCLEBIN←0
      :If recursiveFlag
          R←PS GetDirListRecursion Path
          R←(+/1≥+\'\'=Path)↓¨R
          R←R[⍋Lowercase⊃R]
      :Else
          R←PS GetDirList Path
          R~←,¨'.' '..'
      :EndIf
    ∇

    ∇ R←{Parms}ListFilesOnly Path;⎕ML;⎕IO;Path2;Mask;PS;Parms
    ⍝ List the contents (names only) of a given directory, by default the current one.
    ⍝ This function lists just the files in that directories. Neither . nor .. nor _
    ⍝ any sub directories are listed.
    ⍝ You may specify `('Extended' 1)` as left argument in order to get a listing like
    ⍝ `DirX` but just on files and `('FileTime' 1)` if you need timestamps as well.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      Parms←{(0=⎕NC ⍵):CreateListFilesOnlyParms ⋄ ⍎⍵}'Parms'
      PS←'NoOf' 'Extended' 'FileTime' 'BlockSize'(CreateListFilesOnlyParms ProcessDirParms)Parms
      PS.Counter←0
      PS.COLS←(~PS.EXTENDED)/COL_Name,FA_DIRECTORY
      EstablishQNA_FunctionsForDir PS
      R←(0,38{(0∊⍴⍵):⍺ ⋄ ⍴⍵}PS.COLS)⍴' '
      (Path Path2 Mask)←ProcessPath Path
      'Invalid syntax: wildcards (*?) are not allowed in folder names'⎕SIGNAL 11/⍨∨/'*?'∊Path2
      PS.(IGNORERECYCLEBIN RECURSIVE SORT NOOFEACH)←0 0 0,⌊maxNoOfFiles
      R(ScanDirs)←PS Path Path2 1
      :If PS.EXTENDED
          R←(0=R[;FA_DIRECTORY-~⎕IO])⌿R
      :Else
          R←(0=R[;2])⌿R[;1]
      :EndIf
    ∇

    ∇ {r}←MkDir Name;∆CreateDirectory;rc;⎕IO;⎕ML;pad
    ⍝ Create (make) a new directory.
    ⍝ Result is always an empty vector.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      'Invalid right argument: depth'⎕SIGNAL 11/⍨~0 1∊⍨≡Name
      'Invalid right argument: not char'⎕SIGNAL 11/⍨0=1↑0⍴Name
      :If Is64Bit
          '∆CreateDirectory'⎕NA'I4 KERNEL32.C32|CreateDirectory',QnaType,' <0T <{I4 I4 P I2}'
      :Else
          '∆CreateDirectory'⎕NA'I4 KERNEL32.C32|CreateDirectory',QnaType,' <0T <{I4 P I2}'
      :EndIf
      Name←CorrectForwardSlash Name
      :If 1=≡Name←∊Name
      :AndIf ' '=1↑0⍴Name
          :If Is64Bit
              pad←0
              rc←∆CreateDirectory(Name~'"')(0 pad 0 0)
          :Else
              rc←∆CreateDirectory(Name~'"')(0 0 0)
          :EndIf
          :If ~rc
              11 ⎕SIGNAL⍨'Error during create directory; rc=',⍕GetLastError
          :EndIf
      :Else
          11 ⎕SIGNAL⍨'Invalid argument'
      :EndIf
      r←''
    ∇

    ∇ {r}←Source MoveTo Target;CurrDir;Rc;Hint;SourceDrive;TargetDrive;Rc;Hint;rc;∆MoveFileEx;∆MoveFile;⎕IO;⎕ML;more
    ⍝ Moves "Source" to "Target".
    ⍝ In case of an error an exception is thrown. If you prefer a return _
    ⍝ code over an exception  see `→[MoveToWithRC]`.
    ⍝ The explicit result is always an empty text vector.
    ⍝ The left argument must be a file. Wilcard characters are not _
    ⍝ supported. The right argument might be a filename or a folder. _
    ⍝ If it is a folder the filename of "Source" is used for the new file.
    ⍝ `MoveTo` always overwrites the target file if there is any.
    ⍝ Examples:
    ⍝ ````
    ⍝ 'C:\readme.txt' WinFile.MoveTo 'D:\buffer\'
    ⍝ 'C:\readme.txt' WinFile.MoveTo 'D:\buffer\newname.txt'
    ⍝ ````
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      (rc more)←Source MoveTo__ Target
      more ⎕SIGNAL rc/⍨okay≠rc
      r←''
    ∇

    ∇ {(rc more)}←Source MoveToWithRC Target;⎕IO;⎕ML
    ⍝ Moves "Source" to "Target".
    ⍝ The function returns a return code and a textual message _
    ⍝ which is empty in case of success.
    ⍝ If you prefer an exception over a return code see `MoveTo`.
    ⍝ The left argument must be a file. Wilcard characters are not _
    ⍝ supported. The right argument might be a filename or a folder. _
    ⍝ If it is a folder the filename of "Source" is used for the new file.
    ⍝ `MoveTo` always overwrites the target file if there is any.
    ⍝ Examples:
    ⍝ ````
    ⍝ 'C:`\readme.txt' WinFile.MoveTo 'D:\buffer\'
    ⍝ 'C:\readme.txt' WinFile.MoveTo 'D:\buffer\newname.txt'
    ⍝ ````
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      (rc more)←Source MoveTo__ Target
    ∇

    ∇ {(r more)}←{Recursive}RmDir Foldername;RecursiveFlag;List;Hint;Rc;DirList;this;∆RemoveDirectory;bool;⎕ML;⎕IO
    ⍝ Removes an empty directory. If the left argument is `'Recursive'` _
    ⍝ then any files and sub-directories are deleted as well.
    ⍝ Since this operation might fail simply because another user is just looking _
    ⍝ into one of the directories that are going to be deleted, a boolean value is _
    ⍝ returned indicating success (0) or failure (positive error indicating the problem). _
    ⍝ As a second result "more" is returned.
    ⍝ Note that error 145 is returned on an attempt to delete a non-empty directory _
    ⍝ without specifying `'Recursive'` as left argument.
      :Access Public Shared
      ⎕IO←1 ⋄ ⎕ML←3
      'Invalid right argument: empty!'⎕SIGNAL 11/⍨0∊⍴Foldername
      'Invalid right argument: invalid depth!'⎕SIGNAL 11/⍨~0 1∊⍨≡Foldername
      '∆RemoveDirectory'⎕NA'I4 KERNEL32.C32|RemoveDirectory',QnaType,' <0T'
      r←0 ⋄ more←''
      Recursive←{2=⎕NC ⍵:⍎⍵ ⋄ ''}'Recursive'
      RecursiveFlag←'RECURSIVE'≡Recursive←Uppercase Recursive
      :If ' '=1↑0⍴Foldername
          Foldername←CorrectForwardSlash Foldername
          :If DoesExistDir Foldername
              :If RecursiveFlag
                  List←('BlockSize' 500)Dir Foldername,'\*.*'
                  List←(~List∊,¨'.' '..')⌿List
                  :If ~0∊⍴,List←(⊂Foldername,'\'),¨List
                      DirList←ListDirsOnly Foldername
                      DirList←(⊂Foldername,'\'),¨DirList
                      :If ~0∊⍴,DirList
                          :For this :In DirList
                              (r more)←Recursive RmDir this
                              :If 0<r
                                  :Return
                              :EndIf
                          :EndFor
                          ⎕DL 0.02
                      :EndIf
                      :If ~0∊⍴∊List←List~DirList
                          Delete List
                      :EndIf
                  :EndIf
              :EndIf
              :If ~∆RemoveDirectory⊂Foldername~'"'
                  r←{0<⍵:⍵ ⋄ 1}GetLastError
                  more←'Could not remove: ',Foldername
              :EndIf
          :Else
              more←'not found or missing rights: "',Foldername,'"'
              r←1
          :EndIf
      :Else
          11 ⎕SIGNAL⍨'Invalid argument'
      :EndIf
    ∇

    ∇ R←ListFileAttributes;buffer;⎕IO;⎕ML
      :Access Public Shared
    ⍝ Returns a matrix with all fields starting their names with `FA_`.
    ⍝ These are used to index the result of `DirX` in order to get a particular _
    ⍝ file attribute. For example. in order to find out whether a file is hidden or not:
    ⍝ `(WinFile.DirX '*')[;WinFile.FA_HIDDEN]`
    ⍝ These columns are returned:
    ⍝ [;1] Name
    ⍝ [;2] Value (decimal)
    ⍝ [;3] Value (hex)
    ⍝ [;4] Remark
    ⍝ See also `→[ListDirXIndices]`.
      ⎕IO←1 ⋄ ⎕ML←3
      buffer←⊃⎕SRC ⎕THIS
      buffer←(∨/':Field Public Shared ReadOnly FA_'⍷buffer)⌿buffer
      buffer←¯1↓↓(¯1+1⍳⍨'FA_'⍷buffer[1;])↓[2]buffer
      R←{⍵↑⍨¯1+⍵⍳'←'}¨buffer
      buffer←{⍵↓⍨⍵⍳'⍝'}¨buffer
      buffer←(+/∧\' '=⊃buffer)↓¨buffer
      R←R,[1.5]{⍵↑⍨¯1+⍵⍳' '}¨buffer
      buffer←{⍵↓⍨⍵⍳' '}¨buffer
      R,←{⍵↑⍨¯1+⍵⍳' '}¨buffer
      buffer←{⍵↓⍨⍵⍳' '}¨buffer
      buffer←(+/∧\' '=⊃buffer)↓¨buffer
      R,←buffer↓¨⍨{-+/∧\' '=⌽⊃⍵}¨buffer
    ∇

    ∇ R←ListDirXIndices;buffer;⎕ML;⎕IO
      :Access Public Shared
    ⍝ This function returns a matrix with all indices useful to index the result of `DirX`.
    ⍝ Note that these are the fields starting their names with `COL_`.
    ⍝ Example to get the last write date:
    ⍝ `(WinFile.DirX '*')[;WinFile.FA_HIDDEN]`
    ⍝ The columns returned:
    ⍝ [;1] Name
    ⍝ [;2] Value (decimal)
    ⍝ [;3] Value (hex)
    ⍝ [;4] Remark
    ⍝ See also `→[ListFileAttributes]`.
      ⎕IO←1 ⋄ ⎕ML←3
      buffer←⊃⎕SRC ⎕THIS
      buffer←(∨/':Field Public Shared ReadOnly COL_'⍷buffer)⌿buffer
      buffer←¯1↓↓(¯1+1⍳⍨'COL_'⍷buffer[1;])↓[2]buffer
      R←{⍵↑⍨¯1+⍵⍳'←'}¨buffer
      buffer←{⍵↓⍨1+⍵⍳'⍝'}¨buffer
      R←R,[1.5]buffer↓¨⍨{-+/∧\' '=⌽⊃⍵}¨buffer
    ∇

    ∇ R←ExpandEnv Y;ExpandEnvironmentStrings;⎕ML;⎕IO
      :Access Public Shared
    ⍝ If Y does not contain any "%" Y is passed untouched.
    ⍝ In case Y is empty R is empty as well.
    ⍝ Examples:
    ⍝ ````
    ⍝ 'C:\Windows\MyDir' ←→ #.WinSys.ExpandEnv '%WinDir%\MyDir'
    ⍝ 'C:\Windows\'  ←→ #.WinSys.ExpandEnv '%WinDir%\MyDir\..'
    ⍝ ````
      ⎕IO←0 ⋄ ⎕ML←3
      :If '%'∊R←Y
          'ExpandEnvironmentStrings'⎕NA'I4 KERNEL32.C32|ExpandEnvironmentStrings',QnaType,' <0T >0T I4'
          R←1⊃ExpandEnvironmentStrings(Y 1024 1024)
      :EndIf
    ∇

    ∇ r←ExpandPath path;char;bin;⎕IO;⎕ML;GetFullPathName
      :Access Public shared
     ⍝ Expands "path" by replacing ".\" and "..\" with the real thing.
      ⎕IO←1 ⋄ ⎕ML←3
      {}'GetFullPathName'⎕NA'I kernel32|GetFullPathName* <0T I4 >0T P'
      r←⊃↑/GetFullPathName(path~'"')1024 1024 0
      :If '""'≡2⍴¯1⌽path
          r←'"',r,'"'
      :EndIf
    ∇

    ∇ r←DirTree path
      :Access Public Shared
    ⍝ Returns a vector of character vectors each representing a fully _
    ⍝ qualified path which is a sub path of "path". Empty if "path" _
    ⍝ does not contain any directories.
      'Invalid right argument'⎕SIGNAL 11/⍨~(≡path)∊0 1
      path↓⍨←¯1×(¯1↑path)∊'/\'
      r←DirTree_ path
    ∇

    ∇ {r}←PolishCurrentDir
      :Access Public Shared
    ⍝ If `⎕WSID` is relative (no "/" or "\" char in the path) the function does nothing.
    ⍝ Otherwise the current directory is changed to that it becomse the path part of `⎕WSID`.
    ⍝ Returns `''` or the old directory in case of a change.
      r←''
      :If ∨/'/\'∊⎕WSID
          r←Cd 1⊃SplitPath ⎕WSID
      :EndIf
    ∇

    ∇ bool←{noPath}IsValidWin32Filename filename
    ⍝ Checks whether "filename" is valid in terms of the Win32 sub-system.
    ⍝ Note that POSIX and NTFS rules are different!!
    ⍝ Note also that this function does not check for ":/\" which strictly _
    ⍝ speaking are not allowed in a filename but in a path.
    ⍝ If you want perform strict checking then specify "NoPath" as right argument. _
    ⍝ The left argument defaults to `''`, meaning that "filename" is considered _
    ⍝ to be a full path; that includes `/\` as well as `:.`.
      :Access Public Shared
      noPath←{(0<⎕NC ⍵):⍎⍵ ⋄ ''}'noPath'
      noPath←'NOPATH'≡Uppercase noPath
      bool←0
      :If ~0∊⍴filename←,filename
      :AndIf {(0=+/∧\'.'=⍵)∧(0=+/∧\' '=⍵)}⌽filename  ⍝ Check for trailing blanks and dots
          bool←∧/~filename∊'*|"<>?',noPath/':/\'
      :EndIf
    ∇

    ∇ r←CreateDirXParms
      :Access Public Shared
      ⍝ Creates a parameter space with default settings for the `→[DirX]` function.
      ⍝ || NoOf || Use this to restrict the total number of files/directories to be returned. Defaults to 1E10. ||
      ⍝ || NoOfEach|| Use this to restrict the number of files to be returned per directory. Defaults to 1E10. ||
      ⍝ || Recursive || Booleans that defaults to 0. Specify a 1 to make it work recursively.||
      ⍝ || FileTime || Boolean that defaults to 0, meaning that no FileTime information is returned.||
      ⍝ || BlockSize || The number of files to be processed in one block. Highe values speed things up but need more memory.||
      ⍝ || Sort || Boolean that defaults to 1 meaning that the result is sorted by path name.||
      ⍝ || Cols || Empty by default. May be a vector of column names instead as in `'Cols' (WinFile.(COL_ShortName COL_Size))`||
      ⍝ || IgnoreRecycleBin || Booleand that defaults to 0. A 1 makes it ignore the bin.||
      r←#.⎕NS''
      r.NOOFEACH←r.NOOF←maxNoOfFiles
      r.RECURSIVE←0
      r.FILETIME←0      ⍝ If you need a filetime, set this to 1; however, without FileTime, DirX is *much* faster!
      r.BLOCKSIZE←2000
      r.SORT←1
      r.COLS←⍬
      r.IGNORERECYCLEBIN←1
    ∇

    ∇ r←CreateListFilesOnlyParms
      :Access Public Shared
      ⍝ Creates a parameter space with default settings for the `→[ListFilesOnly]` function.
      ⍝ || NoOf || Use this to restrict the number of files/directories to be returned. Defaults to 1E10. ||
      ⍝ || FileTime || Boolean that defaults to 0, meaning that no FileTime information is returned. Works only with `('Extended' 1)`.||
      ⍝ || BlockSize || The number of files to be processed in one block. Highe values speed things up but need more memory.||
      ⍝ || Extended || Boolean that defaults to 0; in that case just file names are returned. Set this to 1 in order to get all columns.||
      ⍝ || IgnoreRecycleBin || Booleand that defaults to 0. A 1 makes it ignore the bin.||
      r←#.⎕NS''
      r.NOOF←maxNoOfFiles
      r.FILETIME←0
      r.BLOCKSIZE←2000
      r.EXTENDED←0
      r.IGNORERECYCLEBIN←1
    ∇

    ∇ r←CreateDirParms
      :Access Public Shared
      ⍝ Creates a parameter space with default settings for the `→[DirParms]` function.
      ⍝ || NoOf || Use this to restrict the number of files/directories to be returned. Defaults to 1E10. ||
      ⍝ || NoOfEach|| Use this to restrict the number of files to be returned per directory. Defaults to 1E10. ||
      ⍝ || Recursive || Booleans that defaults to 0. Specify a 1 to make it work recursively.||
      ⍝ || BlockSize || The number of files to be processed in one block. Highe values speed things up but need more memory.||
      ⍝ || Sort || Boolean that defaults to 1 meaning that the result is sorted by path name.||
      ⍝ || IgnoreRecycleBin || Booleand that defaults to 0. A 1 makes it ignore the bin.||
      r←#.⎕NS''
      r.NOOFEACH←r.NOOF←maxNoOfFiles
      r.RECURSIVE←0
      r.BLOCKSIZE←2000
      r.SORT←1
      r.IGNORERECYCLEBIN←1
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ Internal stuff ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
    ∇ rslt←ref FindFirstFile path;⎕IO
      ⎕IO←0 ⋄ ⎕ML←3
      :If ¯1=↑rslt←ref.∆FindFirstFile path 0
          rslt←0 GetLastError
      :Else
          (1 6⊃rslt)←FindTrim(1 6⊃rslt)        ⍝ shorten the file name at the null delimiter
          (1 7⊃rslt)←FindTrim(1 7⊃rslt)        ⍝ and for the alternate name
          (1 0⊃rslt)←(32⍴2)⊤1 0⊃rslt
      :EndIf
    ∇

    ∇ rslt←ref Filetime_to_TS filetime;⎕IO;⎕ML
      ⎕IO←0 ⋄ ⎕ML←3
      rslt←ref.∆FileTimeToLocalFileTime filetime 0
      :If 1≠↑rslt
      :OrIf 1≠↑rslt←ref.∆FileTimeToSystemTime(1⊃rslt)0
          rslt←0 0                   ⍝ if either call failed then zero the time elements
      :EndIf
      rslt←1 1 0 1 1 1 1 1/1⊃rslt    ⍝ remove day of week
    ∇

      FindNextFile←{
          ⎕IO←0 ⋄ ⎕ML←3
          ref←⍺
          1≠↑rslt←ref.∆FindNextFile ⍵:0 GetLastError
          (1 6⊃rslt)←FindTrim(1 6⊃rslt)   ⍝ shorten the filename
          (1 7⊃rslt)←FindTrim(1 7⊃rslt)   ⍝ shorten the alternate name
          rslt
      }

      FindTrim←{
          ⎕IO←1 ⋄ ⎕ML←3
          ⍵↑⍨(⍵⍳⎕UCS 0)-1
      }


    ∇ r←str Between what;⎕IO;⎕ML
      ⎕IO←1 ⋄ ⎕ML←3
      r←{⍵∨≠\⍵}what∊str
    ∇

    ∇ R←GetLastError;∆GetLastError;⎕ML;⎕IO
      ⎕IO←1 ⋄ ⎕ML←3
      '∆GetLastError'⎕NA'I4 kernel32.C32|GetLastError'
      R←∆GetLastError
    ∇

    ∇ (ok more block)←ref ReadBlockX(handle noOfRecords path);i;next;rc;⎕IO;⎕ML
      ⎕IO←0 ⋄ ⎕ML←3
      more←block←''
      ok←1 ⍝ success
      :For i :In ⍳noOfRecords
          (rc next)←ref FindNextFile handle 0
          :If 1=rc
              block,←⊂next
          :Else
              :If 0≠↑rc
              :AndIf ~(↑next)∊0 18
                  ok←11
                  more←'Dir(X) error with: ',path
                  :Trap 0
                      {}ref.∆FindClose handle
                  :EndTrap
                  ok←0 ⍝ failed
                  :Return
              :EndIf
              :Leave
          :EndIf
      :EndFor
      :If ~0∊⍴block
          block←⊃block
          block[;0]←↓,[0 1]⍉(32⍴2)⊤,[0.5]block[;0]
          block[;7]←{(↓⍵)↑¨⍨+/∧\(⎕UCS 0)≠⍵}{⍵⌽⍨+/∧\(⎕UCS 0)=⍵}⊃block[;7]
          block←↓block
      :EndIf
    ∇

    ∇ r←(fns Each)array;unique;result
    ⍝ Fast "Each": applies "fns" on unique data tokens only
      unique←∪array
      result←fns¨unique
      r←(⍴array)⍴result[unique⍳array]
    ∇

    ∇ r←av;val
    ⍝ Holding this in a global variable would be faster indeed but
    ⍝ also not compatible with the Classic version
      :If 82=⎕DR' ' ⍝ For compatability with Dyalog Classic
          r←⎕AV
      :Else
          val←0 8 10 13 32 12 6 7 27 9 9014 619 37 39 9082 9077 95 97 98 99 100 101 102 103 104 105 106 107 108 109
          val,←110 111 112 113 114 115 116 117 118 119 120 121 122 1 2 175 46 9068 48 49 50 51 52 53 54 55 56 57 3
          val,←164 165 36 163 162 8710 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90
          val,←4 5 253 183 127 9049 193 194 195 199 200 202 203 204 205 206 207 208 210 211 212 213 217 218 219 221
          val,←254 227 236 240 242 245 123 8364 125 8867 9015 168 192 196 197 198 9064 201 209 214 216 220 223 224
          val,←225 226 228 229 230 231 232 233 234 235 237 238 239 241 91 47 9023 92 9024 60 8804 61 8805 62 8800
          val,←8744 8743 45 43 247 215 63 8714 9076 126 8593 8595 9075 9675 42 8968 8970 8711 8728 40 8834 8835 8745
          val,←8746 8869 8868 124 59 44 9073 9074 9042 9035 9033 9021 8854 9055 9017 33 9045 9038 9067 9066 8801 8802
          val,←243 244 246 248 34 35 30 38 8217 9496 9488 9484 9492 9532 9472 9500 9508 9524 9516 9474 64 249 250 251
          val,←94 252 8216 8739 182 58 9079 191 161 8900 8592 8594 9053 41 93 31 160 167 9109 9054 9059
          r←⎕UCS val
      :EndIf
    ∇

    RavelEnclose←    {(,∘⊂∘,⍣(1=≡,⍵))⍵}

    CorrectForwardSlash←{t←⍵ ⋄ ((t='/')/t)←'\' ⋄ t}

    ∇ r←CheckParms(parms allowed);depth;bool;buffer;⎕ML;⎕IO
    ⍝ "parms" is supposed to be a vector of two-item vectors like:
    ⍝ ('abc' 1)('Foo' 'hello')
    ⍝
      ⎕IO←1 ⋄ ⎕ML←3
      r←0 2⍴''                            ⍝ Initialyze the result
      :If 0∊⍴parms
          r←0 2⍴''
          :Return
      :EndIf
      :If 0∊⍴allowed
          'Invalid Parameter'⎕SIGNAL 11
      :EndIf
      :If 2=≡parms
      :AndIf 2=⍴parms
          parms←,⊂parms
      :EndIf
      :If 3>≡parms                    ⍝ Handle...
      :AndIf 2∨.≠↑∘⍴¨parms
          parms←,⊂parms               ⍝ ...Parms!
      :EndIf
      :If 0<+/bool←2<↑∘⍴¨parms
          (bool/parms)←{(↑⍵)(1↓⍵)}¨bool/parms
      :EndIf
      parms/⍨←0<↑∘⍴¨parms
      :If 2∨.≠↑∘⍴¨parms←,parms        ⍝ Check for proper structure.
          r←''                        ⍝ Structure invalid, complete faulty!
          :Return
      :EndIf
      :If 0∊⍴parms←(0<↑∘⍴¨parms)/parms
          r←0 2⍴''
          :Return
      :EndIf
      parms←↑,/parms                  ⍝ Make simple vector
      depth←≡parms                    ⍝ Save the Depth
      :If 0=depth
          r←0 2⍴''                    ⍝ Ready if empty: nothing right, nothing wrong...
          :Return
      :EndIf
      :If depth∊0 1                   ⍝ Jump if not simple
          parms←,⊂parms               ⍝ Enforce a nested vector
      :EndIf
      :If 0≠2|⍴parms←,parms           ⍝ Jump if even number of items
          r←''                        ⍝ Structur invalid, get out!
      :Else
          buffer←((⌊0.5×⍴parms),2)⍴parms ⍝ Build a matrix
          buffer[;1]←' '~¨⍨↓Uppercase⊃buffer[;1]
          :If ~0∊⍴allowed
              :If (|≡allowed)∊0 1     ⍝ Jump if Allowed is not simple
                  allowed←⊂allowed    ⍝ Enforce nested
              :EndIf
              allowed←,allowed        ⍝ Enforce a vector
              allowed←Uppercase allowed
              bool←buffer[;1]∊allowed ⍝ Column 1 must be member of Allowed
              :If 1∨.≠bool
                  ('Invalid Parameter: ',1↓↑,/' ',¨(~bool)/buffer[;1])⎕SIGNAL 11
              :EndIf
          :EndIf
          r←buffer                    ⍝ All is fine
      :EndIf
    ∇

    ∇ r←GetVarsFromParms parms;∆DUMMY;⎕IO;⎕ML
    ⍝ Establishes variables from "parms" which is supposed to be a vector of _
    ⍝ two-item vectors.
    ⍝ Example:
    ⍝ GetVarsFromParms  ('abc' 1)('Foo' 2)
    ⍝ creates two variables "∆ABC" and "∆FOO" with the values 1 and 2.
    ⍝ "r" is a vector of text vectors with the names of the variables created.
      ⎕IO←1 ⋄ ⎕ML←3
      parms⍪←'DUMMY'⍬                    ⍝ DUMMY is added to make the statement run if Parms is empty.
      parms[;1]←'∆',¨parms[;1]           ⍝ Add "∆" to avoid name conflicts.
      ⍎(↑,/' ',¨parms[;1]),'←parms[;2]'  ⍝ Create external parameters.
      r←¯1↓parms[;1]                     ⍝ ¯1↓ drops the DUMMY.
    ∇

    ∇ path←CreateTempFolder;flag;tf;fn;path
    ⍝ Creates a randomly named in the temp dir and takes some precautions
      tf←GetTempPath           ⍝ Path to the temp folder
      flag←0
      :Repeat
          path←tf,' '~⍨⍕⎕TS              ⍝ Create a random name
          flag←DoesExistDir path         ⍝ Must not exist yet
      :Until ~flag                       ⍝ Otherwise try again
      MkDir path                         ⍝ Okay, fine, lets create it
    ∇

    ∇ {(rc more)}←Source MoveTo__ Target;∆MoveFileEx;∆MoveFile;CurrDir;SourceDrive;TargetDrive;⎕IO;⎕ML
    ⍝ Sub-function for both, MoveTo and MoveToWithRC.
      ⎕IO←1 ⋄ ⎕ML←3
      :If 0∊⍴Source
          rc←11
          more←'Invalid left argument'
      :EndIf
      :If 0∊⍴Target
          rc←11
          more←'Invalid right argument'
      :EndIf
      rc←0 ⋄ more←''
      '∆MoveFileEx'⎕NA'I kernel32.C32|MoveFileEx',QnaType,' <0T <0T I4'
      '∆MoveFile'⎕NA'I Kernel32.C32|MoveFile',QnaType,' <0T <0T'
      Source←CorrectForwardSlash Source
      Target←CorrectForwardSlash Target
      :If ∨/'*?'∊Source
          'Left argument must not contain either "?" or "*"'⎕SIGNAL 11
      :ElseIf ∨/'*?'∊Target
          'Right argument must not contain either "?" or "*"'⎕SIGNAL 11
      :Else
          CurrDir←PWD
          SourceDrive←TargetDrive←''
          (('/'=Source)/Source)←'\'
          (('/'=Target)/Target)←'\'
          :If '\\'≢2↑Source
              :If ':'∊Source
                  SourceDrive←Source↑⍨¯1+Source⍳':'
              :Else
                  SourceDrive←CurrDir↑⍨¯1+CurrDir⍳':'
                  Source,⍨←CurrDir,'\'
              :EndIf
              SourceDrive←{('abcdefghijklmnopqrstuvwxyz',av)[(⎕A,av)⍳⍵]}SourceDrive
          :EndIf
          :If '\\'≢2↑Target
              :If ':'∊Target
                  TargetDrive←Target↑⍨¯1+Target⍳':'
              :Else
                  TargetDrive←CurrDir↑⍨¯1+CurrDir⍳':'
                  Target,⍨←CurrDir,'\'
              :EndIf
              TargetDrive←{('abcdefghijklmnopqrstuvwxyz',av)[(⎕A,av)⍳⍵]}TargetDrive
          :EndIf
          :If '\'=¯1↑Target
          :AndIf '\'≠¯1↑Source
              Target,←1↓Source↑⍨-'\'⍳⍨⌽Source
          :EndIf
          :If SourceDrive≢TargetDrive
          :AndIf '\'=¯1↑Source
              rc←1
              more←'"MoveTo" cannot move directories between different drives'
          :Else
              :If 0=∆MoveFileEx((Source~'"')(Target~'"')),3       ⍝ 3=REPLACE_EXISTING (1) + COPY_ALLOWED (2)
                  rc←GetLastError
                  more←'MoveFile error'
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ {(rc more)}←Source CopyTo__ Target;∆CopyFile
    ⍝ Called by both, CopyTo and CopyToWithRC
      rc←0 ⋄ more←''
      Source←CorrectForwardSlash Source
      Target←CorrectForwardSlash Target
      '∆CopyFile'⎕NA'I kernel32.C32|CopyFile',QnaType,' <0T <0T I2'
      :If '\'=¯1↑Target
          Target,←1↓Source↑⍨-'\'⍳⍨⌽Source
      :EndIf
      :If 0=∆CopyFile((Source~'"')(Target~'"')),0
          rc←GetLastError
          more←'Copy File error'
      :EndIf
    ∇

    ∇ r←DirTree_ path;list;this;buf;i;If
      ⍝ Private sub-function of DirTree
      list←ListDirsOnly path
      r←''
      :If ~0∊⍴list
          :For i :In ⍳⍴list
              this←i⊃list
              r,←⊂path,'\',this
              :If ~0∊⍴buf←DirTree_ path,'\',this
                  r,←buf
              :EndIf
          :EndFor
      :EndIf
    ∇

      TransformWildcardsToRegEx←{
      ⍝ Transform wildcards (* and ?) into a RegEx
      ⍝ Also escapes any special character, of course
          m←⍵
          mc←'[]().+$'                                  ⍝ Metacharacters that might appear in a file matching pattern in Windows
          b←m∊mc                                        ⍝ Boolean: where are metachars?
          m{0=+/⍵:⍺ ⋄ w←⍺ ⋄ (b/w)←⊂¨'\',¨b/w ⋄ ∊w}←b    ⍝ Escape all metachars, if any
          b←'?'=m
          (b/m)←'.'
          b←'*'=m
          (b/m)←⊂'.*'
          ∊m
      }

      SortByFilename←{
      ⍝ ⍵ is the result of DirX
      ⍝ Result is ⍵ but sorted.
      ⍝ The "." and ".." directories however are ALWAYS the two first ones
          PS←⍺
          ind1←Where ⍵[;0]∊,¨'.' '..'
          ⍵[ind1,(⍋⊃Lowercase ⍵[;(|PS.COLS)⍳COL_Name])~ind1;]
      }

      ProcessPath←{
          path←⍵~'"'
          path←CorrectForwardSlash path
          path{⍵:PWD,'\*' ⋄ ⍺}←0∊⍴path
          path,←'*'/⍨'/\'∊⍨¯1↑path
          (path2 mask)←{⍵{(⍵↓⍺)(⍵↑⍺)}1+-'\'⍳⍨⌽⍵}path
          path path2 mask
      }

      ProcessDirParms←{
          Parms←⍵
          PS←⍺⍺
          Allowed←⍺
          (9=⎕NC'Parms'):Parms
          (0∊⍴,Parms):{⍵.Counter←0 ⋄ ⍵}CreateDirParms
          Parms←CheckParms(Parms Allowed)
          (0∊⍴Parms):'Invalid Parameters'⎕SIGNAL 11
          Parms⍪←'DUMMY'⍬                       ⍝ DUMMY is added to make the statement run if Parms is empty.
          PS.(⎕IO ⎕ML)←1 3
          _←PS.{⍎(↑,/' ',¨⍵[;1]),'←⍵[;2]'}Parms ⍝ Create external parameters.
          _←PS.⎕EX'DUMMY'
          PS.Counter←0                          ⍝ Use to check whether we reached NOOF
          PS
      }

      GetFileTime←{
          (filetime ref)←⍵.FILETIME ⍵
          Buffer←⍺
          (~filetime):Buffer⊣Buffer[;1 2 3]←⊂7⍴0
          Buffer[;1]←ref Filetime_to_TS¨Buffer[;1]
          Buffer[;2]←ref∘Filetime_to_TS Each Buffer[;2] ⍝ Because this column contains potentially many copies
          Buffer[;3]←ref Filetime_to_TS¨Buffer[;3]
          Buffer
      }


      ProcessAttributes←{
          Buffer←⊃⍵
          PS←⍺
          ⎕IO←0
          Buffer←Buffer GetFileTime PS
          Buffer[;4]←0(2*32)⊥⍉⊃Buffer[;4]            ⍝ combine size elements
          Buffer←⊂[0]Buffer
          (1⊃Buffer)←⊃1⊃Buffer
          (2⊃Buffer)←⊃2⊃Buffer
          (3⊃Buffer)←⊃3⊃Buffer
          Buffer/⍨←5≠⍳8                              ⍝ bin the reserved elements
          attrs←0⊃Buffer
          Buffer←Buffer[5 6 4 1 2 3]
          Bool←2=↑∘⍴∘⍴¨Buffer
          (Bool/Buffer)←⊂[1]¨Bool/Buffer
          Buffer←⍉⊃Buffer
          Buffer,←⍉attrs
          Buffer←Buffer[;(⍳6)],⊃Buffer[;6]
        ⍝ ↓ Needed because FindFile searches both, long and short filenames
          Buffer←Buffer{⍵:({(0,⍴,⍵)≡↑((TransformWildcardsToRegEx Mask)⎕S 0 1 ⎕OPT('IC' 1))⍵}¨⍺[;0])⌿⍺ ⋄ ⍺}'?'∊Mask
          Buffer[{⍵/⍳⍴⍵}8≥{⍵⍳'.'}¨Buffer[;0];1]←⊂''  ⍝ Reset 8-byte names where appropriate
          Buffer
      }

      WhichAreDirs←{
          Buffer←⊃⍵
          PS←⍺
          ⎕IO←0
          (⊃Buffer[;0])[;27]
      }

    ∇ R←HandleDirXRecursion(R PS Path wildcardFlag);name;this;Buffer;DirList;PS2;⎕ML;⎕IO
      ⎕IO←0 ⋄ ⎕ML←3
      Path↓⍨←-2×'*/'≡¯2↑Path
      :If ∨/'*?'∊Path
          (Path name)←SplitPath Path
          name←'\',name
      :Else
          name←''
      :EndIf
      :If PS.NOOFEACH≡maxNoOfFiles
          :If wildcardFlag
              DirList←ListDirsOnly Path
          :Else
              :If 2=1⊃⍴R
                  DirList←(R[;1]⌿R[;0])~,¨'.' '..'
              :Else
                  DirList←((R[;FA_DIRECTORY-~⎕IO])⌿R[;COL_Name-~⎕IO])~,¨'.' '..'
              :EndIf
              DirList←((PS.NOOF-PS.Counter)⌊0⊃⍴DirList)↑[0]DirList
          :EndIf
      :Else
          DirList←PS GetDirList Path
      :EndIf
      PS2←⎕NS PS
      :For this :In DirList
          :If 0<0⊃⍴Buffer←PS2 DirX Path,this,name
              Buffer[;(|PS2.COLS)⍳COL_Name]←(this,'\')∘,¨Buffer[;(|PS2.COLS)⍳COL_Name]
          :EndIf
          PS.Counter+←⎕IO⊃⍴Buffer
          PS2.Counter←PS.Counter
          R⍪←Buffer
          :If PS.NOOF<⎕IO⊃⍴R
              :Leave
          :EndIf
      :EndFor
    ∇

    ∇ {r}←EstablishQNA_FunctionsForDir ref;WIN32_FIND_DATA;⎕IO
      r←⍬
      ⎕IO←1
      :If 0=ref.⎕NC'∆FindFirstFile'
          '∆FileTimeToLocalFileTime'ref.⎕NA'I4 kernel32.C32|FileTimeToLocalFileTime <{I4 I4} >{I4 I4}'
          '∆FileTimeToSystemTime'ref.⎕NA'I4 kernel32.C32|FileTimeToSystemTime <{I4 I4} >{I2 I2 I2 I2 I2 I2 I2 I2}'
          :If 3∨.≠ref.⎕NC⊃'∆FindFirstFile' '∆FindNextFile' '∆FindClose'
              WIN32_FIND_DATA←'{I4 {I4 I4} {I4 I4} {I4 I4} {I4 I4} {I4 I4} T[260] T[14]}'
              '∆FindFirstFile'ref.⎕NA'I4 kernel32.C32|FindFirstFile',QnaType,' <0T >',WIN32_FIND_DATA
              '∆FindNextFile'ref.⎕NA'U4 kernel32.C32|FindNextFile',QnaType,' I4 >',WIN32_FIND_DATA
              '∆FindClose'ref.⎕NA'kernel32.C32|FindClose I4'
          :EndIf
      :EndIf
    ∇

    ∇ R←R ScanDirs(PS Path Path2 NoDirsFlag);handle;ok;More;Block;⎕IO;⎕ML
    ⍝ Non-independent sub-function of Dir, DirX and a couple of others
      ⎕IO←1 ⋄ ⎕ML←3
      (handle Block)←PS FindFirstFile Path
      :If 0=handle
          Path←(((~':'∊Path2)∧'\\'≢2⍴Path)/PWD,'\'),Path
          :If {∨/'*?'∊⍵:1 ⋄ DoesExistFile ⍵}(-2×'\*'≡¯2↑Path)↓Path
              (handle Block)←PS FindFirstFile(-2×'\*'≡¯2↑Path)↓Path
              :If 0=handle
                  ok←PS.∆FindClose handle
                  →(1+|PS.RECURSIVE)⊃∆Quit ∆Go
              :Else
                  ('Error: ',⍕Block)⎕SIGNAL 11/⍨~GetLastError∊2 3
                  →∆CarryOn
              :EndIf
          :Else
              ('Error: ',⍕Block)⎕SIGNAL 11/⍨~(¯1=PS.RECURSIVE){(⍵∊2 3):1 ⋄ ⍺∧⍵=5}GetLastError  ⍝ Ignore 5 (access denied) in case of recursion and we are not on first level  (¯1)
              :Return  ⍝ Nothing found, so we are done
          :EndIf
      :Else
     ∆CarryOn:
          R←ProcessScanDirBlocks(R PS Block Path handle)
     ∆Go:
          R←FinalScanDirProcessing(R PS Path)
      :EndIf
     ∆Quit:
      :Trap 0 ⋄ {}PS.∆FindClose handle ⋄ :EndTrap
    ∇

    ∇ R←FinalScanDirProcessing(R PS Path);⎕IO;⎕ML;PS2
      ⎕IO←0 ⋄ ⎕ML←3
      :If |PS.RECURSIVE
      :AndIf PS.Counter<PS.NOOF
          PS2←⎕NS PS
          PS2.(RECURSIVE SORT)←¯1 0
          R←HandleDirXRecursion R PS2 Path(∨/'*?'∊Path)
      :EndIf
      :If 2=⍴⍴R
          :If PS.NOOF≤↑⍴R
          :AndIf 1=PS.RECURSIVE
              R←PS.NOOF↑[0]R
          :EndIf
          :If PS.SORT∧0<1⊃⍴R
              R←PS SortByFilename R
          :EndIf
      :EndIf
      :If (PS.RECURSIVE∊0 1)∧~0∊⍴PS.COLS
          R/⍨←1=×PS.COLS
      :EndIf
    ∇

    ∇ R←ProcessScanDirBlocks(R PS Block Path handle);⎕IO;⎕ML;ok;more
      ⎕IO←0 ⋄ ⎕ML←3
      Block←PS ProcessAttributes,⊂Block
      :If PS.IGNORERECYCLEBIN
      :AndIf ~0∊⍴Block←(Block[;0]≢¨⊂'$RECYCLE.BIN')⌿Block
          :If ¯1=PS.RECURSIVE
              Block←(~Block[;0]∊,¨'.' '..')⌿Block
          :EndIf
      :EndIf
      :If ~0∊⍴Block
          :If 0∊⍴PS.COLS
              R⍪←Block
          :Else
              R⍪←Block[;{(|⍵)-~⎕IO}PS.COLS]
          :EndIf
          PS.Counter+←0⊃⍴Block
      :EndIf
      :If (GetMaxNumber PS)>0⊃⍴R
          :Repeat
              (ok more Block)←PS ReadBlockX(handle((2+PS.NOOFEACH)⌊PS.NOOF⌊PS.BLOCKSIZE)Path)  ⍝ +2 for '.' and '..'
              :If 1=ok
                  :If 0∊⍴Block
                      :Leave
                  :EndIf
              :Else
                  . ⍝ Deal with serious errors! However, this has never occured so far.
              :EndIf
              Block←PS ProcessAttributes Block
              :If ¯1=PS.RECURSIVE
                  Block←(~Block[;0]∊,¨'.' '..')⌿Block
              :EndIf
              Block←(PS.NOOFEACH⌊⎕IO⊃⍴Block)↑[⎕IO]Block
              R⍪←Block[;R{(0∊⍴⍵):⍳1⊃⍴⍺ ⋄ (|⍵)-~⎕IO}PS.COLS]
              PS.Counter+←0⊃⍴Block
              :If 1=PS.RECURSIVE
                  :If (PS.Counter≥PS.NOOF)
                      R←((↑⍴R)⌊GetMaxNumber PS)↑[0]R
                      :If PS.SORT
                          R{⍵:PS SortByFilename ⍺ ⋄ ⍺}←0<1⊃⍴R
                      :EndIf
                      ok←PS.∆FindClose handle
                      :Return
                  :EndIf
              :Else

              :EndIf
              :If PS.BLOCKSIZE>0⊃⍴Block
                  :Leave
              :EndIf
          :Until 0
      :EndIf
    ∇

      CheckDirCols←{
          (0∊⍴PS.COLS):⍵
          PS←⎕NS ⍵
          PS.COLS,←(~COL_Name∊|PS.COLS)/-COL_Name
          PS.COLS,←(~FA_DIRECTORY∊|PS.COLS)/-FA_DIRECTORY
          PS
      }

      GetCols←{
    ⍝ ⍵ is PS.COLS
    ⍝ If empty all cols are returned.
    ⍝ Takes ⎕IO from caller into account
          (0∊⍴⍵):. ⍝          NoOfCols
          (|⍵)
      }

    ∇ r←QnaType;⎕IO;⎕ML
      ⎕IO←0 ⋄ ⎕ML←3
      r←(12>{⍎⍵↑⍨¯1+⍵⍳'.'}1⊃'.'⎕WG'APLVersion')⊃'A*'
    ∇

    ∇ r←Is64Bit
      r←'-64'≡¯3↑⎕IO⊃'#'⎕WG'APLVersion'
    ∇

      GetMaxNumber←{
          PS←⍵
          (1=PS.RECURSIVE)⊃PS.(NOOF NOOFEACH)
      }

    ∇ R←ContainsSubDirs path;handle;next;ok;Flag;fns;⎕IO;⎕ML
    ⍝ Returns a 1 if "path" does not contain a sub directory, otherwise 0.
    ⍝ Pure sub function of `HasSubDirs` without independent value.
      ⎕IO←0 ⋄ ⎕ML←3
      R←0
      handle←↑∆FindFirstFile path 0
      fns←{∆FindNextFile ⍵ 0}
      :If 0≠handle
          Flag←0
          {}fns handle
          :Repeat
              (ok next)←fns handle
              :If 1=ok
                  :If R←27⊃(32⍴2)⊤↑next
                      :Leave
                  :EndIf
              :Else
                  Flag←1
              :EndIf
          :Until Flag
      :EndIf
      ok←∆FindClose handle
    ∇

:EndClass ⍝ WinFile