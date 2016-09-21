:Class FilesAndDirs
⍝ ## Overview
⍝ This class offers methods useful for dealing with files and directories. The class aims
⍝ to be platform-independent and work under Windows, Linux and Mac OS.
⍝
⍝ With the release of 15.0 Dyalog introduced some new `⎕n`-system functions that are helpful
⍝ for making an application platform-independent when handling files and directories.\\
⍝ However, those new functions do not fully cover the common needs of applications. Examples
⍝ include functionalities like "Move", "Copy", and recursive listings of directories.
⍝ The class attempts to fill this gap.
⍝
⍝ Note that error codes as well as messages may differ between operating systems for the same
⍝ kind of problem.
⍝
⍝ ## Characters to avoid in file names and paths
⍝ Windows file names cannot include any of these characters: `\/:*?"<>|`.
⍝ If you want platform-independent code now or in the future, 
⍝ avoid using them even in Mac OS or Linux file names. 
⍝
⍝ ## Separators in filepaths
⍝ The notion of sticking always with the `/` as separator because it works everywhere is
⍝ attractive but has important limits. When you call third-party software such as a .NET
⍝ assembly or an EXE such as 7zip.exe under Windows, then you **must** use `\` as a separator.
⍝ Even setting the `Directory` property of a `FileBox` object fails with `/` as a separator!
⍝
⍝ For platform independence, it is essential file- and directory names be _normalized_. 
⍝ That means using the correct separator for the current operating system. 
⍝ Otherwise you might create a directory or file with a catastrophic backslash in its name.
⍝
⍝ The methods of `FilesAndDirs` protect you from this problem by normalizing their filepaths.
⍝ Use its cover functions, such as `MkDir`, `NNAMES` and `NCREATE` 
⍝ in preference to the corresponding interpreter primitives. 
⍝
⍝ The `CurrentSep` method returns the correct separator for the current operating system.
⍝
⍝ The `NormalizePath` method normalizes a filepath for the current operating system.
⍝
⍝ If you have a particular reason for using `/` under Windows or `\` under Linux
⍝ or Mac OS then you can use the methods `EnforceBackslash` or `EnforceSlash`.
⍝
⍝ ## Misc
⍝ This class supports Windows, Mac OS and Linux but neither the Raspberry Pi nor AIX.\\
⍝ Kai Jaeger ⋄ APL Team Ltd\\
⍝ Homepage: http://aplwiki.com/FilesAndDirs

    :Include APLTreeUtils

    ⎕IO←0 ⋄ ⎕ML←3

    ∇ r←Version
      :Access Public shared
      ⍝ * 1.3.0
      ⍝   * New method `EnforceSlash` introduced which does exactly what the name suggests
      ⍝     except that any `\\` at the beginning remain unchanged.
      ⍝   * Spelling error corrected: It's now `EnforceBackslash` rather than `EnforceBackSlash`.
      ⍝   * Change of paradigm:
      ⍝     * `NormalizePath` now uses either `\` or `/` as separator in paths depending on the
      ⍝       current operating system.
      ⍝     * `EnforceBackslash` does exactly what the names suggests, and it does not accept a
      ⍝       left argument anymore.
      ⍝     * All functions that return a path (`Dir`, `ListFiles`, `ListDirs` ...) will provide
      ⍝       what is "the" separator on any given operating system.
      ⍝ * 1.2.0
      ⍝   * The method `EnforceBackSlash` now excepts a left argument "winOnly". The function
      ⍝     now does what the name suggests: it changes all `/` to `\`, except when "winOnly"
      ⍝     is passed as left argument and it does not run under Windows.
      ⍝ * 1.1.6
      ⍝   * `PolishCurrentDir` could have failed under Linux and Mac OS.
      ⍝   * Telling parameters spaces from a vector of key/values pairs failed in `Dir`.
      ⍝   * Documentation improved
      ⍝ * 1.1.5
      ⍝   `DeleteFile` should not crash on an empty filename but just report 0.
      ⍝ * 1.1.4
      ⍝   * Bug in `CheckPath` fixed.
      ⍝ * 1.1.3
      ⍝   * `DeleteFiles` did not trap 19 & 22 (typically access errors: hold by another process.
      ⍝     In such cases it should just report that the attempt to delete the file was unsuccessful.
      ⍝ * 1.1.2
      ⍝   * `MoveTo` on the Mac did not work.
      ⍝   * Loop implemented into `CheckPath` in order to overcome the timing issue in `CheckPath`.
      ⍝ * 1.1.1
      ⍝   * Documentation fixed (ADOC).
      ⍝ * 1.1.0
      ⍝   * `ListDirs` and `ListFiles` allow wildcard characters now.
      ⍝   * `DeleteFiles` crashed on empty vectors.
      ⍝   * Methods `IsFile`, `IsDir` and `IsSymbolicLink` except nested arguments now.
      ⍝ * 1.0.0  - First version
      r←(Last⍕⎕THIS)'1.3.0' '2016-09-15'
    ∇

    ∇ r←{parms_}Dir path;buff;list;more;parms;rc;extension;filename;folder
      :Access Public Shared
    ⍝ List contents of `path`.\\
    ⍝ `path` may be one of:
    ⍝ * A file: `Dir` returns attributes for just that file
    ⍝ * A directory without a trailing slash: `Dir` returns attributes for just that directory
    ⍝ * A directory with a trailing slash: `Dir` returns attributes for all files and directories
    ⍝   found in that directory.
    ⍝ * An empty vector: this defaults to `PWD,'/'`
    ⍝
    ⍝ Note that `*` and `?` are treated as wildcard characters. That means that `FilesAndDirs`
    ⍝ cannot deal with files that contain a `*` or a `?` as part of any name, be it directory
    ⍝ or filename; under Linux and Mac OS these are legal characters for filenames.\\
    ⍝ The result is a vector of the same length as `type` which defaults to 0: just file- and
    ⍝ directory names.
    ⍝ You may specify additional attributes via the `type` parameter either as key/value pairs or
    ⍝ via a namespace populated with variables. If you do then the number of attributes specified
    ⍝ defines the length of the result.
    ⍝ Examples:
    ⍝ ~~~
    ⍝ ('recursive' 1) FilesAndDirs.Dir ''
    ⍝ ~~~
    ⍝
    ⍝ ~~~
    ⍝ parms←⎕ns''
    ⍝ parms.recursive←1
    ⍝ parms.type←3 4 5 1 0
    ⍝ parms FilesAndDirs.Dir ''
    ⍝ ~~~
    ⍝ If `path` is empty then the current directory is subject of `Dir`.\\
    ⍝ Note that the names of parameters are case sensitive.\\
    ⍝ |Parameter  |Default|Meaning|
    ⍝ |-----------|-------|-------|
    ⍝ | follow    | 0     | Shall symbolic links be followed |
    ⍝ | recursive | 0     | Shall `Dir` scan `path` recursively |
    ⍝ | type      | 0     | Use this to select the information to be returned<<br>>by `Dir`. 0 means names. For more information see<<br>>help on `⎕NINFO`. |
    ⍝
      r←⍬
      path←NormalizePath path
      parms←⎕NS''
      parms.follow←1
      parms.recursive←0
      parms.type←0
      :If 0<⎕NC'parms_'
          :If {2::0 ⋄ 1⊣⍵.⎕NL 2}parms_
              {}parms.{{⍎⍺,'←⍵'}/⍵}¨parms_.({⍵(⍎⍵)}¨↓⎕NL 2)
              'Invalid parameter'⎕SIGNAL 11/⍨∨/~(' '~¨⍨↓parms.⎕NL 2)∊'follow' 'recursive' 'type'
          :Else
              parms_←,⊂∘,⍣(2=≡parms_)⊣parms_
              'Invalid parameter'⎕SIGNAL 11/⍨0∊(↑¨parms_)∊' '~¨⍨↓parms.⎕NL 2
              parms.{{⍎⍺,'←⍵'}/⍵}¨parms_
          :EndIf
      :EndIf
      :If 0∊⍴path
          path←PWD,CurrentSep
      :EndIf
      :If CurrentSep=¯1↑path
          'Directory does not exist'⎕SIGNAL 6/⍨0=⎕NEXISTS path
          :Trap 19 22
              'Not a directory'⎕SIGNAL 11/⍨1≠1 ⎕NINFO path
          :Else
              :If 1 5 'Access is denied.'≢⎕DMX.OSError
                  ⎕DMX.DM ⎕SIGNAL ⎕EN
              :Else
                  :Return
              :EndIf
          :EndTrap
          r←(0 1,parms.type~0 1)⎕NINFO⍠('Follow'parms.follow)('Wildcard' 1)⊣path,CurrentSep,'*'
          :If ~0∊0⊃r
              (0⊃r)←NormalizePath¨0⊃r
          :EndIf
          :If parms.recursive
          :AndIf ~0∊⍴r
          :AndIf 1∊1⊃r
              buff←parms∘Dir¨((1=1⊃r)/0⊃r),¨CurrentSep
              :If ~0∊⍴buff←(0<↑¨⍴¨buff)/buff
                  r←r,¨↑,¨/buff
              :EndIf
              :If 1=+/∧\'Dir'∘≡¨⎕SI
                  r←(⊂⍋⊃0⊃r)∘⌷¨r
              :EndIf
          :EndIf
          :If 1=+/∧\'Dir'∘≡¨⎕SI
              r←r[,(0 1,parms.type~0 1)⍳parms.type]
          :EndIf
      :Else
          :If ∨/'*?'∊path
              (folder filename extension)←⎕NPARTS path
              ('Wildcard characters are allowed only after the last "',CurrentSep,'"')⎕SIGNAL 11/⍨∨/'*?'∊folder
              :If ~0∊⍴buff←↑⎕NPARTS ¯1↓↑⎕NPARTS folder
              :AndIf 0=⎕NEXISTS buff
                  'path does not exist'⎕SIGNAL 6
              :EndIf
          :Else
              'path does not exist'⎕SIGNAL 6/⍨0=⎕NEXISTS path
          :EndIf
          r←(0 1,parms.type~0 1)⎕NINFO⍠('Follow'parms.follow)('Wildcard' 1)⊣path
          :If ~0∊0⊃r
              (0⊃r)←NormalizePath¨0⊃r
          :EndIf
          r←r[,(0 1,parms.type~0 1)⍳parms.type]
      :EndIf
    ∇

    ∇ {(rc more)}←source CopyTo target;buff;cmd;∆CopyFile;a
      :Access Public Shared
    ⍝ Copies `source` to `target`.\\
    ⍝ The left argument must be one of:
    ⍝ * A filename (simple string).
    ⍝ * A vector of text strings, each representing a filename.
    ⍝
    ⍝ In case it is a single filename then the right argument must be either a
    ⍝ directory (in which case the filename itself persists) or a filename.\\
    ⍝ In case the left argument is a vector of filenames the right argument
    ⍝ must be either a single directory (all files are copied into that
    ⍝ directory, and the filenames as such persist) or a vector of the same
    ⍝ length as the left argument.\\
    ⍝ Note that wildcard characters are not supported.\\
    ⍝ `CopyTo` overwrites the target file if there is any.\\
    ⍝ Examples:
    ⍝ ~~~
    ⍝ 'C:\readme.txt' FilesAndDirs.CopyTo 'D:\buffer\'
    ⍝ 'C:\readme.txt' FilesAndDirs.CopyTo 'D:\buffer\newname.txt'
    ⍝ 'C:\file1' 'C:\file2' FilesAndDirs.CopyTo 'D:\buffer\'
    ⍝ 'C:\file1' 'C:\file2' FilesAndDirs.CopyTo 'D:\buffer\A' D:\buffer\B
    ⍝ ~~~
    ⍝ The method always returns a (shy) two-item vector as result:
    ⍝ 1. `rc` is either 0 for "okay" or an error code.
    ⍝ 2. `more` is an empty text vector in case `rc` is 0. It might hold
    ⍝    additional information in case `rc` is not 0.
    ⍝
    ⍝ Note that in case `source` is a nested vector of text vectors than both `rc` and
    ⍝ `more` are nested as well, and the length will match the length of `source`.
      rc←0 ⋄ more←''
      :If 2=≡source
          target←Nest target
          :If ≢/⍴¨source target
          :AndIf 1≠⍴,target
              'Length of left and right argument do do not fit'⎕SIGNAL 5
          :EndIf
          (rc more)←↓⍉⊃source CopyTo¨target
      :Else
          (source target)←NormalizePath¨source target
          :Select GetOperatingSystem ⍬
          :Case 'Win'
              '∆CopyFile'⎕NA'I kernel32.C32|CopyFile* <0T <0T I2'
              :If CurrentSep=¯1↑target
                  target,←↑,/1↓⎕NPARTS source
              :EndIf
              :If 0=∆CopyFile((source~'"')(target~'"')),0
                  rc←GetLastError
                  more←GetMsgFromError rc
              :EndIf
          :CaseList 'Lin' 'Mac'
              cmd←'cp "',source,'" "',target,'"'
              (rc more buff)←##.OS.ShellExecute cmd
          :Else
              . ⍝Huuh?!
          :EndSelect
      :EndIf
    ∇

    ∇ {(rc more)}←source MoveTo target
      :Access Public Shared
    ⍝ Moves `source` to `target`.\\
    ⍝ The function returns a 0 for success and an error number otherwise. `more` is a textual message
    ⍝ which is empty in case of success.\\
    ⍝ The left argument must be a either a text vector representing a filename
    ⍝ or a vector of text vectors representing a vector of filenames.\\
    ⍝ The right argument might be a filename or a directory in case the left argument
    ⍝ is a single filename. If the left argument is a vector of filenames then the right
    ⍝ argument must be either a single directory name or a vector of te same length
    ⍝ than the left argument with filenames and/or directory names.\\
    ⍝ If the right argument specifies a directory the filename part of `source` is used for
    ⍝ the new file.\\
    ⍝ Notes:
    ⍝ * Wildcard characters are not supported.
    ⍝ * If you try to move a non-existing file you get a `¯1` as return code and
    ⍝   an appropriate message on `more`.
    ⍝ * If there is a name clash in `target` the already existing file will be overwritten.
    ⍝
    ⍝ The function returns a two-item vector. The first item is one of:
    ⍝ * ¯1 for internal errors (invalid argument(s) etc).
    ⍝ * 0 for success.
    ⍝ * OS error codes otherwise
    ⍝
    ⍝ The second item is an empty vector in case of success but may be a text vector with
    ⍝ additional information otherwise.\\
    ⍝ Both items will be vectors themselves in case `source` is a nested vector.\\
    ⍝ This function will move file(s) by first copying them over
    ⍝ and then attempt to delete the source file. Note however that when the delete operation
    ⍝ fails the copied file will be deleted. This is consistent with the behaviour of the
    ⍝ Windows `MoveFileEx` function.\\
    ⍝ Examples:
    ⍝
    ⍝ ~~~
    ⍝ 'C:\readme.txt' FilesAndDirs.MoveTo 'D:\buffer\'
    ⍝ 'C:\readme.txt' FilesAndDirs.MoveTo 'D:\buffer\newname.txt'
    ⍝ ~~~
      :If ∨/{0∊⍴⍵}¨source target
          rc←¯1
          more←'Invalid left argument'
      :EndIf
      :If 2=≡source
          target←Nest target
          source←NormalizePath¨source
          target←NormalizePath¨target
          :If ≢/⍴¨source target
          :AndIf 1≠⍴,target
              'Length of left and right argument do do not fit'⎕SIGNAL 5
          :EndIf
          (rc more)←↓⍉⊃source MoveTo¨target
      :Else
          (source target)←{NormalizePath↑,/1 ⎕NPARTS ⍵}¨source target
          :Select GetOperatingSystem ⍬
          :Case 'Win'
              (rc more)←source Win_MoveTo target
          :CaseList 'Lin' 'Mac'
              (rc more)←source Unix_MoveTo target
          :Else
              .  ⍝ Huuh?!
          :EndSelect
      :EndIf
    ∇

    ∇ (success more list)←source CopyTree target;tree;ind;buff
    ⍝ ## Overview
    ⍝ `source` must be an existing directory. `target` must be either a existing directory
    ⍝ or a name valid as a directory.\\
    ⍝ All files and directories in `source` are copied over to `target`.\\
    ⍝ ## Result
    ⍝ * `success` is Boolean with 1 indicating success. A 0 means failure, but the failure may
    ⍝ not be total: in case, say, 100 files are to be copied and some of them failed
    ⍝ because of a, say, an ACCESS DENIED error then `rc` will be 0 but `list` gives you the
    ⍝ full story.\\
    ⍝ * `more` is empty if everything is okay. It may contain additional information if
    ⍝ something goes wrong. An example is when the `target` directory cannot be created.\\
    ⍝ * `list` is a matrix with three columns:
    ⍝   * [;0] is a list of names of all files and directories that were copied.
    ⍝   * [;1] is the return code: either 0 for success or an error number.
    ⍝   * [;2] is either an empty vector (in case of success) or additional information as
    ⍝   a text vector.
    ⍝
    ⍝ ## Notes
    ⍝ * `CopyTree` does not rollback in case something goes wrong; instead it keeps trying.
    ⍝ * `target` might already contain stuff; in case of name conflicts any already
    ⍝   existing files will be overwritten.
      :Access Public Shared
      success←1 ⋄ more←'' ⋄ list←0 3⍴'' 0 0
      'Invalid left argument'⎕SIGNAL 11/⍨(~(≡source)∊0 1)∨80≠⎕DR source
      'Invalid right argument'⎕SIGNAL 11/⍨(~(≡target)∊0 1)∨80≠⎕DR target
      'Left argument is not a directory'⎕SIGNAL 11/⍨0=IsDir source
      'Right argument is a file'⎕SIGNAL 11/⍨IsFile target
      'Right argument has wildcard characters'⎕SIGNAL 11/⍨∨/'*?'∊target
      (source target)←NormalizePath¨source target
      :If 0=⎕NEXISTS target
          :Trap 19 22
              MkDir target
          :Else
              success←0
              more←'Could not create target directory'
              :Return
          :EndTrap
      :EndIf
      :Trap 11
          tree←((⍉⊃('recursive' 1)('type'(0 1))Dir source,CurrentSep),0),' '
      :Else
          success←0
          more←'Could not get contents of source directory'
          :Return
      :EndTrap
      list⍪←({⍵↓⍨-CurrentSep=¯1↑⍵}target)0 ''
      :If ~0∊⍴tree
        ⍝ We now create all directories
          ind←Where 1=tree[;1]
          tree[ind;2]←~'Create!'∘CheckPath¨target∘,¨(⍴source)↓¨tree[ind;0]
          tree[ind;3]←⊂''
          ind←Where 2=tree[;1]
          tree[ind;2 3]←⍉⊃tree[ind;0]CopyTo target∘,¨(⍴source)↓¨tree[ind;0]
          buff←tree[;0 2 3]
          buff[;0]←(⊂target),¨(⍴source)↓¨buff[;0]
          list⍪←buff
      :EndIf
    ∇

    ∇ r←CurrentSep
    ⍝ Returns what is the "correct" filename separator under the current OS.
      :Access Public Shared
      r←('Win'≡GetOperatingSystem ⍬)⊃'/\'
    ∇

    ∇ (success more list)←source MoveTree target;success;directories;ind;delFlags;isLinkOrFile;isLinkOrDir
    ⍝ ## Overview
    ⍝ `source` must be an existing directory. `target` must be either a existing directory
    ⍝ or a valid directory name.\\
    ⍝ All files and directories in `source` are copied over to `target`.\\
    ⍝ ## Result
    ⍝ `success` is Boolean with 1 indicating success. A 0 means failure, but the failure may
    ⍝ not be total: in case, say, 100 files are to be copied and just some of them failed
    ⍝ because of a, say, an ACCESS DENIED error then `success` will be 0 but `list` gives you the
    ⍝ full story.\\
    ⍝ `more` is empty if everything is okay. It may contain additional information if
    ⍝ something goes wrong. An example is when the `target` directory cannot be created.\\
    ⍝ `list` is a matrix with four columns:
    ⍝ * [;0] is a list of names of all files and directories that were copied.
    ⍝ * [;1] is the copy-related return code: 0 for success or an error number.
    ⍝ * [;2] is the delete-related return code: 0 for success or an error number.
    ⍝ * [;3] is either an empty vector (in case of success) or additional information as
    ⍝   a text vector.
    ⍝
    ⍝ ## Misc
    ⍝ Note that `MoveTree` does not rollback in case something goes wrong;
    ⍝ instead it keeps trying. That means that a copy-operation might be successful
    ⍝ but the associated delete-operation fails.\\
    ⍝ Note that `target` might already contain stuff; in case of name conflicts any already
    ⍝ existing files will be overwritten.
      :Access Public Shared
      success←1 ⋄ more←'' ⋄ list←0 4⍴'' 0 0 ''
      'Invalid left argument'⎕SIGNAL 11/⍨(~(≡source)∊0 1)∨80≠⎕DR source
      'Invalid right argument'⎕SIGNAL 11/⍨(~(≡target)∊0 1)∨80≠⎕DR target
      'Left argument is not a directory'⎕SIGNAL 11/⍨0=IsDir source
      'Right argument is a file'⎕SIGNAL 11/⍨IsFile target
      (source target)←NormalizePath¨source target
      (success more list)←source CopyTree target
      :If success
          list←list[;0 1 1 2]
          list[;0]←source∘,¨(⍴target)↓¨list[;0]
          isLinkOrFile←({1 ⎕NINFO⍠('Follow' 0)⊣⍵}¨list[;0])∊2 4
          {}{0∊⍴⍵:⍬ ⋄ {19 22::⍬ ⋄ 1 ⎕NDELETE ⍵}¨⍵}isLinkOrFile/list[;0]    ⍝ Links and files first
          isLinkOrDir←({19 22::0 ⋄ 1 ⎕NINFO⍠('Follow' 0)⊣⍵}¨list[;0])∊1 4
          directories←(isLinkOrDir)/list[;0]
          ind←⍒+/CurrentSep=⊃directories                                   ⍝ Sub directories first!
          {}{0∊⍴⍵:⍬ ⋄ {19 22::⍬ ⋄ 1 ⎕NDELETE ⍵}¨⍵}directories[ind]
          list[;2]←⎕NEXISTS¨list[;0]
      :EndIf
    ∇

    ∇ {(rc en more)}←{mustBeEmpty}RmDir path;list;bool
      :Access Public Shared
      ⍝ Removes `path`.\\
      ⍝ The method attempts to remove `path` and, by default, **all its contents**.\\
      ⍝ If for some reason you want to make sure that `path` is only removed when empty you can
      ⍝ specify a 1 as left argument. In that case the method will not do anything if `path` is
      ⍝ not empty.\\
      ⍝ Note that this method may fail for reasons as trivial as somebody looking into `path`
      ⍝ at the moment of execution. However, the method may still be partly successful because
      ⍝ it might have deleted files in `path` before it actually fails to remove `path` itself.\\
      ⍝ The result is a three-element vector:
      ⍝ 1. `rc`: return code with 0 for "okay" and 1 otherwise.
      ⍝ 1. `en`: event number (`⎕EN`) in case of an error.
      ⍝ 1. `more`: empty text vector in case `rc` is 0.
      ⍝
      ⍝ Note that wildcard characters (`*` and `?`) are not allowed as part of `path`.
      ⍝ If such characters are specified anyway then an error is signalled.
      rc←1 ⋄ en←0 ⋄ more←''
      mustBeEmpty←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'mustBeEmpty'
      'Invalid left argument.'⎕SIGNAL 11/⍨~mustBeEmpty∊0 1
      'Wildcard characters are not allowed'⎕SIGNAL 11/⍨∨/'*?'∊path
      path←NormalizePath path
      path↓⍨←-CurrentSep=¯1↑path
      :Trap 19 22
          :If 1≠1 ⎕NINFO path
              en←6
              more←'Not a directory'
              :Return
          :EndIf
      :Else
          more←{(≡⍵)∊0 1:⍵ ⋄ ↑{⍺,'; ',⍵}/⍵/⍨' '=↑¨1↑¨0⍴¨⍵}⎕DMX.OSError
          en←⎕EN
          :Return
      :EndTrap
      :Trap 19 22
          rc←~0 ⎕NDELETE path
      :Else
          :If 0=mustBeEmpty
         ⍝ First we delete all files
              list←⍉⊃('recursive' 1)('type'(0 1))Dir path,CurrentSep
              :If 0<+/bool←1≠list[;1]
                  :Trap 0
                      {}{1 ⎕NDELETE ⍵}¨bool/list[;0]  ⍝ Return code might be 0 for links!
                  :Else
                      en←⎕EN
                      more←⎕DMX.EM
                      :Return
                  :EndTrap
                  :If 0∊{19 22::1 ⋄ 0⊣1 ⎕NINFO ⍵}¨bool/list[;0]
                      en←11
                      more←'Could not delete all files.'
                      :Return
                  :EndIf
              :EndIf
         ⍝ Now we remove all sub-directories
              :If ~0∊⍴list←(~bool)/list[;0]
                  list←list[⍒↑¨⍴¨list]
                  :Trap 0
                      rc←~{1 ⎕NDELETE ⍵}¨list
                  :Else
                      en←⎕EN
                      more←⎕DMX.EM
                      :Return
                  :EndTrap
                  :If 0∊{19 22::1 ⋄ 0⊣1 ⎕NINFO ⍵}¨list
                      en←11
                      more←'Could not delete all directories.'
                      :Return
                  :EndIf
                  rc←0
              :EndIf
              :Trap 19 22
                  rc∧←~0 ⎕NDELETE path  ⍝ Now we try again
              :Else
                  rc←1
              :EndTrap
          :Else
              en←⎕EN
              more←{↑{⍺,'; ',⍵}/⍵/⍨' '=↑¨0⍴¨⍵}⎕DMX.OSError
          :EndIf
      :EndTrap
    ∇

    ∇ r←PWD
      :Access Public Shared
      ⍝ Print Work Directory; same as `Cd''`.
      r←↑1 ⎕NPARTS''
      r↓⍨←-(¯1↑r)∊'/\'
      r←NormalizePath r
    ∇

    ∇ r←{expandFlag}NormalizePath path;UNCflag;sep
      :Access Public Shared
      ⍝ `path` might be either a simple text vector or scalar representing a single filename or a
      ⍝ vector of text vectors with each item representing a text vector.
      ⍝ Enforces either `\` or `/` as separator in `path` depending on the current operating system.\\
      ⍝ If you **must** enforce a particular separator then use either `EnforceBackslash` or
      ⍝ `Enforceslash`.\\
      ⍝ Note that by default a relative path remains relative and any `../` (or `..\`) is not touched.
      ⍝ You can change this by specifying "expand" as the (optional) left argument; then `path` is
      ⍝ expanded to an absolute path. As a side effect any `../` is transformed appropriately as well.\\
      ⍝ Notes:
      ⍝ * The left argument is not case sensitive.
      ⍝ * Any pair of `//` or `\\` is reduced to a single one except the first two.
      expandFlag←'expand'≡{0<⎕NC ⍵:{0=1↑0 ⍵:⍵ ⋄ Lowercase ⍵}w←⍎⍵ ⋄ ''}'expandFlag'
      :If 1<≡r←,path
          r←expandFlag NormalizePath¨path
      :Else
          UNCflag←'\\'≡2⍴r
          :If expandFlag
              r←↑,/1 ⎕NPARTS r
          :EndIf
          sep←('Win'≡GetOperatingSystem ⍬)⌽'\/'
          ((r=0⊃sep)/r)←1⊃sep
          r←(~(2⍴1⊃sep)⍷r)/r
          :If UNCflag
              r←'\\',1↓r
          :EndIf
          :If ⍬≡⍴path
          :AndIf 1=⍴r
              r←↑r
          :EndIf
      :EndIf
    ∇

    ∇ path←EnforceBackslash path
      :Access Public Shared
    ⍝ Use this if you must make sure that `path` contains `\` rather than `/`.\\
      ((path='/')/path)←'\'
    ∇

    ∇ path←EnforceSlash path
      :Access Public Shared
    ⍝ Use this if you must make sure that `path` contains `/` rather than `\`.\\
    ⍝ Preserves the first two characters if they are `\\`.
      ((path='\')/path)←'/'
    ∇

    ∇ {r}←PolishCurrentDir;wsid
      :Access Public Shared
    ⍝ If `⎕WSID` is relative this function does nothing.\\
    ⍝ Otherwise the current directory is changed so that it becomes the path part of `⎕WSID`.\\
    ⍝ Returns either `''` or the old directory in case of a change.
      r←''
      wsid←NormalizePath ⎕WSID
      :If ('.',CurrentSep)≢2⍴⎕WSID,' '
      :AndIf CurrentSep∊wsid
          r←NormalizePath Cd 0⊃SplitPath wsid
      :EndIf
    ∇

    ∇ r←Cd path;Lin;r;rc;∆GetCurrentDirectory;∆SetCurrentDirectory;∆chdir
    ⍝ Reports and/or changes the current directory.
    ⍝ The method changes the current directory to what the right argument is ruling.\\
    ⍝ It returns the former current directory as a result.\\
    ⍝ Because an empty right argument has no effect, `Cd ''` effectively reports the
    ⍝ current directory.\\
    ⍝ See also [`PWD`](#) (Print Work Directory).
      :Access Public Shared
      path←NormalizePath path
      :Select GetOperatingSystem ⍬
      :Case 'Win'
          '∆GetCurrentDirectory'⎕NA'I4 KERNEL32.C32|GetCurrentDirectory* I4 >T[]'
          '∆SetCurrentDirectory'⎕NA'I4 KERNEL32.C32|SetCurrentDirectory* <0T'
          :If 0=↑rc←∆GetCurrentDirectory 260 260
              r←GetLastError'GetCurrentDirectory error' ''
          :Else
              r←NormalizePath↑↑/rc
          :EndIf
          :If ~0∊⍴path←path~'"'
          :AndIf ' '=1↑0⍴path
              path,←(CurrentSep≠¯1↑path)/CurrentSep
              :If ~∆SetCurrentDirectory⊂path
                  11 ⎕SIGNAL⍨⊃{⍵,'; rc=',⍕⍺}/GetLastError'SetCurrentDirectory error'
              :EndIf
          :EndIf
      :CaseList 'Lin' 'Mac'
          path←NormalizePath path
          :If 0∊⍴path
              r←↑⎕SH'pwd'
          :Else
              '∆chdir'⎕NA'I ',##.OS.GetSharedLib,'| chdir <0T1[]'
              r←∆chdir⊂path
          :EndIf
      :Else
          .  ⍝ Huuh?!
      :EndSelect
    ∇

    ∇ path←GetTempPath;∆GetTempPath
    ⍝ Returns the path to the temp directory on the current system.
      :Access Public Shared
      :Select GetOperatingSystem ⍬
      :Case 'Win'
          '∆GetTempPath'⎕NA'I4 KERNEL32.C32|GetTempPath* I4 >T[]'
          path←↑↑/∆GetTempPath 1024 1024
          :If 0∊⍴path
              11 ⎕SIGNAL⍨'Problem getting Windows temp path!; rc=',⍕GetLastError
          :Else
              path←NormalizePath path
          :EndIf
      :Case 'Lin'
          path←'/tmp/'
      :Case 'Mac'
          path←'/private/tmp/'
      :Else
          .⍝ Huuh?!
      :EndSelect
    ∇

    ∇ r←IsDir path
      :Access Public Shared
    ⍝ Returns 1 if `path` is a directory and 0 otherwise, even if `path` does exist as a file.
      :If 2=≡path
          r←IsDir¨path
      :Else
          path←NormalizePath path
          :Trap 11
              :If r←⎕NEXISTS path
                  r←1=1 ⎕NINFO path
              :EndIf
          :Else
              r←0
          :EndTrap
      :EndIf
    ∇

    ∇ r←IsFile y
      :Access Public Shared
    ⍝ Returns 1 if `filename` is a regular file and a 0 otherwise, even if `y` does exist as a directory.\\
    ⍝ `y` must be either a text vector or a (negative!) tie number of a native file.
    ⍝ If it is a number but not a tie number then an error is signalled.
      :If 2=≡y
          r←IsFile¨y
      :Else
          :If 0=1↑0⍴y
              'Not tied'⎕SIGNAL 18/⍨~y∊⎕NNUMS
              r←2=1 ⎕NINFO y
          :Else
              y←NormalizePath y
              :Trap 11
                  :If r←⎕NEXISTS y
                      r←2=1 ⎕NINFO y
                  :Else
                      r←0
                  :EndIf
              :Else
                  r←0
              :EndTrap
          :EndIf
      :EndIf
    ∇

    ∇ r←IsSymbolicLink y
      :Access Public Shared
    ⍝ Returns a 1 if `y` is a symbolic link and a 0 otherwise, even if `y` does exist as a file or directory.\\
    ⍝ `y` must be a text vector.
      :If 2=≡y
          r←IsSymbolicLink¨y
      :Else
          'Invalid right argument'⎕SIGNAL 11/⍨' '≠1↑0⍴y
          y←NormalizePath y
          :Trap 19 22
              r←4=1 ⎕NINFO⍠('Follow' 0)⊣y
          :Else
              r←0
          :EndTrap
      :EndIf
    ∇

    ∇ {success}←{new}CheckPath path;newFlag
      :Access Public Shared
    ⍝ Returns a 1 if the `path` to be checked is fine, otherwise 0.\\
    ⍝ * If `path` exists but is not a directory a 0 is returned.\\
    ⍝ * If `path` does not exist a 0 is returned.\\
    ⍝ * If `path` does not exist but the left argument is "CREATE!" it will be created,
    ⍝ including any sub directories.\\
    ⍝ The left argument is case insensitive.
      path←NormalizePath path
      :If 1=⎕NEXISTS path
          success←IsDir path
      :Else
          success←0
          newFlag←'CREATE!' 1∊⍨⊂{6::0 ⋄ {(0=1↑0⍴⍵):⍵ ⋄ Uppercase ⍵}⍎⍵}'new'
          :If newFlag
              success←MkDir path
          :EndIf
      :EndIf
    ∇

    ∇ filename←{PrefixString}GetTempFilename path;rc;start;no;fno;flag
    ⍝ Returns the name of an unused temporary filename. If `path` is empty the default temp
    ⍝ path is taken; that's what `GetTempPath` would return. This means you can overwrite
    ⍝ this by specifying a path.\\
    ⍝ `PrefixString`, if defined, is a leading string of the filename
    ⍝ going to be generated. This is **not** the same as\\
    ⍝ `'pref',GetTempFileName ''`\\
    ⍝ because specified as left argument it is taken into account
    ⍝ when the uniqueness of the created filename is tested.\\
    ⍝ This function does **not** use the Windows built-in function since
    ⍝ it has proven to be unreliable under W7 (at least).
      :Access Public Shared
      PrefixString←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'PrefixString'
      path←NormalizePath path
      path,←((~0∊⍴path)∧CurrentSep≠¯1↑path)/CurrentSep
      :If 0∊⍴path
          :Trap 0
              path←GetTempPath
          :Else
              11 ⎕SIGNAL⍨'Cannot get a temp path; rc=',⍕⎕EN
          :EndTrap
      :EndIf
      :If 0=rc←'Create!'CheckPath path
          11 ⎕SIGNAL⍨'Error during "Create <',path,'>"; rc=',⍕GetLastError
      :Else
          start←no←⍎{(,'ZI2,ZI2,ZI2'⎕FMT 3↑⍵),⍕3↓⍵}3↓⎕TS  ⍝ Expensive but successful very soon
          ⍝ no←100⊥3↓⎕TS ⍝ Not reliable: can take a large number of tries before successful
          :Repeat
              filename←path,PrefixString,(⎕AN,'_',⍕no),'.tmp'
              fno←0
              :Trap 22
                  ⎕NUNTIE fno←filename ⎕NCREATE 0
                  flag←1
              :EndTrap
              no+←10
          :Until (fno≠0)∨no>start+1000×10  ⍝ max 1000 tries
      :EndIf
      filename←NormalizePath filename
    ∇

    ∇ r←{recursive}ListDirs path;buff;recursiveFlag;part1;part2
      :Access Public Shared
      ⍝ Lists all directories (but nothing else) in `path`.\\
      ⍝ `path` must of course be a directory.\\
      ⍝ Specify the string "recursive" (not case sensitive) as left argument to make the
      ⍝ function work recursively.\\
      ⍝ `path` might contain wildcard characters (`*` and `?`) but only in the last part
      ⍝ of the path and only if "recursive" is **not** specified as left argument.\\
      ⍝ Returns a vector of text vectors in case anything was found and `''` otherwise.
      path←NormalizePath path
      (part1 part2)←SplitPath path
      'Wildcard characters are allowed only in the last part of a path'⎕SIGNAL 11/⍨∨/'?*'∊part1
      'Right argument is not a directory'⎕SIGNAL 11/⍨0=IsDir{(a b)←SplitPath ⍵ ⋄ ~∨/'*?'∊b:⍵ ⋄ a}path
      path↓⍨←-CurrentSep=¯1↑path
      recursiveFlag←'recursive'≡Lowercase{0<⎕NC ⍵:⍎⍵ ⋄ ''}'recursive'
      :If recursiveFlag
      :AndIf ∨/'*?'∊path
          '"path" must not carry wildcard chars in case "Recursive" is specified'⎕SIGNAL 11
      :EndIf
      path,←(~∨/'?*'∊path)/CurrentSep
      buff←('recursive'recursiveFlag)('type'(0 1))Dir path
      r←(1=1⊃buff)/0⊃buff
      r←NormalizePath¨r
    ∇

    ∇ r←{recursive}ListFiles path;buff;recursiveFlag;part1;part2
      :Access Public Shared
      ⍝ Lists all files (but nothing else) in `path`.\\
      ⍝ `path` must of course be a directory.
      ⍝ Specify the string "recursive" (not case sensitive) as left argument to make the
      ⍝ function work recursively.\\
      ⍝ `path` might contain wildcard characters (`*` and `?`) but only in the last part
      ⍝ of the path and only if "recursive" is **not** specified as left argument.\\
      ⍝ Returns a vector of text vectors in case anything was found and `''` otherwise.
      path←NormalizePath path
      (part1 part2)←SplitPath path
      'Wildcard characters are allowed only in the last part of a path'⎕SIGNAL 11/⍨∨/'?*'∊part1
      'Right argument is not a directory'⎕SIGNAL 11/⍨0=IsDir part1
      path↓⍨←-CurrentSep=¯1↑path
      recursiveFlag←'recursive'≡Lowercase{0<⎕NC ⍵:⍎⍵ ⋄ ''}'recursive'
      :If recursiveFlag
      :AndIf ∨/'*?'∊path
          '"path" must not carry wildcard chars in case "Recursive" is specified'⎕SIGNAL 11
      :EndIf
      path,←(~∨/'?*'∊path)/CurrentSep
      buff←('recursive'recursiveFlag)('type'(0 1))Dir path
      r←(2=1⊃buff)/0⊃buff
      r←NormalizePath¨r
    ∇

    ∇ {success}←DeleteFile filenames
      :Access Public Shared
      ⍝ Attempts to delete a file. Returns 1 in case of succes and 0 otherwise for each
      ⍝ file in `filenames`.\\
      ⍝ This function does not care whether the file exists or not, although naturally
      ⍝ `sucess` will be 0 for any non-existing files.\\
      ⍝ `filenames` can be one of:
      ⍝ * Text string representing a single filename.
      ⍝ * Vector of text vectors, each representing a single file.
      ⍝
      ⍝ `filenames` are normalized, meaning that any `\` is replaced by `/`.\\
      ⍝ In case `filenames` is empty a 0 is returned.
      :If 0∊⍴filenames
          success←0
      :Else
          filenames←Nest filenames
          filenames←NormalizePath¨filenames
          success←{19 22::0 ⋄ 0∊⍴⍵:0 ⋄ 1 ⎕NDELETE ⍵}¨filenames
      :EndIf
    ∇

    ∇ {success}←MkDir path;counter;flag
      :Access Public Shared
      ⍝ Make directory. If the directory already exists no action is taken and a 1 returned.\\
      ⍝ Any part of `path` which does not already exist will be created in preparation
      ⍝ of creating `path` itself.\\
      ⍝ In comparison with `⎕MKDIR` there some differences:
      ⍝ * This method normalizes `path`, meaning that any `\` is changed into `/`.
      ⍝ * Errors 19 & 22 are trapped.
      ⍝ * The function overcomes a strange problem: on some systems the function refuses to create
      ⍝   the directory repeatedly unless the code is traced.
      ⍝
      ⍝ `success` is 1 in case the directory was created successfully or already existed, otherwise 0.
      path←NormalizePath path
      success←0
      :If IsDir path
          success←1
      :Else
          :Trap 19 22
              counter←flag←0
              :Repeat   ⍝ This loop tries to overcome Dyalog bug <01234>; Kai 2016-09-02 ⍝CHECK⍝
                  :Trap 19 22
                      success←3 ⎕MKDIR path
                  :EndTrap
                  flag←⎕NEXISTS path
                  ⎕DL flag×0.2
              :Until flag∨10<counter←counter+1
          :EndTrap
      :EndIf
    ∇

    ∇ bool←Exists y
      :Access Public Shared
    ⍝ Same as `⎕NEXISTS` but `y` is normalized: any `\` becomes `/`.\\
    ⍝ Note that if `y` is a symbolic link that exists then a 1 will be returned, no matter
    ⍝ whether the target the link is pointing to actually does exist or not.
      y←NormalizePath y
      bool←⎕NEXISTS y
    ∇

    ∇ tno←{tno}CreateFile filename
      :Access Public Shared
      ⍝ Same as `⎕NCREATE` but `filename` is normalized first.\\
      ⍝ Returns the tie number.
      tno←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'tno'
      filename←NormalizePath filename
      tno←filename ⎕NCREATE tno
    ∇

    ∇ newline←GetNewLineCharsFor os
      :Access Public Shared
      ⍝ Returns the proper `newline` character(s) for `os` or, if `os` is empty, for the current OS.
      :If 0∊⍴os
          os←#.APLTreeUtils.GetOperatingSystem ⍬
      :EndIf
      '⍵ is not a supported Operating System'⎕SIGNAL 11/⍨~(⊂os)∊'Win' 'Lin' 'Mac'
      newline←('Win' 'Lin' 'Mac'⍳⊂os)⊃(⎕UCS 13 10)(⎕UCS 10)(⎕UCS 10)
    ∇

    ∇ r←NNAMES
    ⍝ Same as ⎕NNAMES but...
    ⍝ * returns a vector rather than a matrix.
    ⍝ * normalizes all filenames
      :Access Public Shared
      r←NormalizePath dtb↓⎕NNAMES
    ∇

    ∇ r←filename NCREATE tieNo
    ⍝ Same as ⎕NCREATE but normalizes `filename`.
      :Access Public Shared
      r←(NormalizePath filename)⎕NCREATE tieNo
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ Private stuff

    ∇ r←GetLastError;∆GetLastError
      :Select GetOperatingSystem ⍬
      :Case 'Win'
          '∆GetLastError'⎕NA'I4 kernel32.C32|GetLastError'
          r←∆GetLastError
      :CaseList 'Lin' 'Mac'
          r←⎕SH'$errno'   ⍝TODO⍝
      :Else
          .  ⍝ Huuh?!
      :EndSelect
    ∇

    ∇ (drive path)←HandlePath path
      path←NormalizePath↑,/1 ⎕NPARTS path
      drive←''
      :If '\\'≢2↑path
          :If ~':'∊path
              path←PWD,path
          :EndIf
          :If ':'∊path
              drive←1↑path
          :EndIf
      :EndIf
    ∇

    ∇ (rc more)←source Unix_MoveTo target
      rc←0 ⋄ more←''
      (source target)←EncodeBlanks¨source target
      :If IsDir target
          (rc more)←2↑##.OS.ShellExecute'mv ',((('/'≠¯1↑target)/'/'),' -f '),source,' ',target
      :Else
          (rc more)←2↑##.OS.ShellExecute'mv -f ',source,' ',target
      :EndIf
    ∇

    ∇ (rc more)←source Win_MoveTo target;∆MoveFileEx;∆MoveFile;targetDrive;sourceDrive;currDir
      rc←0 ⋄ more←''
      :If ∨/{∨/'*?'∊⍵}¨source target
          (rc more)←¯1 'Argument must not contain either "?" or "*"'
      :Else
          (sourceDrive source)←HandlePath source
          (targetDrive target)←HandlePath target
          :If ~IsFile source
              rc←¯1
              more←'Source file does not exist'
          :Else
              :If CurrentSep=¯1↑target
              :AndIf CurrentSep≠¯1↑source
                  target,←source↑⍨-CurrentSep⍳⍨⌽source
              :EndIf
              :If sourceDrive≢targetDrive
                  (rc more)←source CopyTo target
                  :If 0=rc
                      :Trap 11 19 22
                          ⎕NDELETE source
                      :Else
                          ⎕NDELETE target ⍝ This is consistent with the Windows function `MoveFileEx`!
                          rc←32
                          more←GetMsgFromError rc
                      :EndTrap
                  :EndIf
              :Else
                  '∆MoveFileEx'⎕NA'I kernel32.C32|MoveFileEx* <0T <0T I4'
                  '∆MoveFile'⎕NA'I Kernel32.C32|MoveFile* <0T <0T'
                  :If 0=∆MoveFileEx((source~'"')(target~'"')),3       ⍝ 3=REPLACE_EXISTING (1) + COPY_ALLOWED (2)
                      rc←GetLastError
                      more←GetMsgFromError rc
                  :EndIf
              :EndIf
          :EndIf
      :EndIf
    ∇

    EncodeBlanks←{0=+/b←' '=w←⍵:w ⋄ (b/w)←⊂'\ '⋄ ↑,/w}

    ∇ r←GetMsgFromError mid;FORMAT_MESSAGE_IGNORE_INSERTS;FORMAT_MESSAGE_FROM_SYSTEM;FormatMsg;mid;size;LangID;LoadLibrary;this;FORMAT_MESSAGE_FROM_HMODULE;hModule;FreeLibrary;ind;multiByte
    ⍝ Translate Message ID (mid) to something more useful for human beings.
      FORMAT_MESSAGE_IGNORE_INSERTS←512
      FORMAT_MESSAGE_FROM_HMODULE←2048
      FORMAT_MESSAGE_FROM_SYSTEM←4096
      LangID←0
      'FormatMsg'⎕NA'I KERNEL32|FormatMessage* I4 I4 I4 I4 >T[] I4 I4'
      :If 0>mid←↑mid
      :AndIf ¯16777216≤mid
          mid←-mid
      :EndIf
      multiByte←80=⎕DR' '                  ⍝ Flag: is Unicode
      size←1024×1+multiByte                ⍝ Dynamic buffer size
      r←⊃↑/FormatMsg(FORMAT_MESSAGE_FROM_SYSTEM+FORMAT_MESSAGE_IGNORE_INSERTS)0 mid LangID size size 0
      :If 0∊⍴r
          'LoadLibrary'⎕NA'I KERNEL32|LoadLibrary* <0T'
          ⎕NA'I KERNEL32|FreeLibrary I'
          :For this :In 'ADVAPI32' 'NETMSG' 'WININET' 'WSOCK32'
              :If 0≠hModule←LoadLibrary(⊂this)
                  :If this≡'WSOCK32'
                      ind←10013 10014 10024 10035 10036 10037 10038 10039 10040 10041 10042 10043 10044 10046 10047 10048 10049 10050 10051 10052 10053 10054 10055 10056 10057 10058 10059 10060 10061 10063 10064 10065 10066 10067 10068 10069 10070 10071 10091 10092 10093 10112 11001 11002 11003 11004
                      mid←(10060 10013 10023 10010 10011 10012 10026 10014 10015 10044 10036 10031 10030 10016 10029 10028 10122 10039 10046 10040 10038 10037 10127 10034 10035 10003 10047 10033 10135 10000 10042 10043 10017 10018 10019 10020 10021 10025 10001 10002 10148 10041 10005 10006 10007 10114,mid)[ind⍳mid]
                  :EndIf
                  r←⊃↑/FormatMsg(FORMAT_MESSAGE_FROM_HMODULE+FORMAT_MESSAGE_IGNORE_INSERTS)hModule mid LangID size size 0
                  {}FreeLibrary hModule
                  :If ×↑⍴r
                      :Leave
                  :EndIf
              :EndIf
          :EndFor
      :EndIf
      r←¯2↓r
    ∇

:EndClass
