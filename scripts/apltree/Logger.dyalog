:Class Logger
⍝ <h2>Overview
⍝ This class is designed to write log files. It does not need any parameters _
⍝ when instantiated but you can specify up to
⍝ # path          Where the lgo file should be created; default is current dir.
⍝ # encoding      Is ANSI in Classic and may be UTF8 or ASCII in a Unicode interpreter.
⍝ # filenameType  Determines the file name. Defaults to yyyymmdd.log
⍝ # debug         By default (0) all internal errors are trapped.
⍝ # timestamp     Practically never used accept for test cases.
⍝ # refToUtils    Points to where `Logger` will find `WinSys`. See there.
⍝ <h2> Syntax
⍝ <pre>⎕NEW Logger ([path encoding filenameType debug timestamp refToUtils])
⍝ ⎕NEW Logger
⍝ ⎕NEW Logger (,⊂commandSpace)
⍝ ⎕NEW Logger</pre>
⍝ Only by creating a command space can one set <b>all</b> possible parameters.
⍝ Example:
⍝ <pre>
⍝ myParms←#.Logger.CreatePropertySpace
⍝ myParms.filenamePrefix←'MYAPP'
⍝ ⍝ ....
⍝ ⍝ Note that the namespace returned by `CreatePropertySpace` offers a method _
⍝ `List` which list both, the names and their current values.
⍝ ⎕NEW Logger (,⊂myParms)
⍝ </pre>
⍝ <h2>Misc
⍝ Needs: Dyalog Version 12, Unicode or Classic
⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/Logger

    :Include APLTreeUtils

    ⎕IO←1
    ⎕ML←3
    CrLf←⎕UCS 13 10

    ∇ r←Version
      :Access Public shared
      ⍝ Returns a three-element vector each of which is a string:
      ⍝ # The (fully qualified) name
      ⍝ # The version number as a.b.c
      ⍝ # The version date as YYYY-MM-DD
      r←(Last⍕⎕THIS)'1.9.0' '2015-01-10'
      ⍝ 1.9.0: APL inline code is marked up now with ticks (`).
      ⍝        The `Version` function returns just the name (no path).
      ⍝        `History` method removed.
      ⍝ 1.8.2: odd numbers of " made ADOC crash on ADOC.Browser Logger
    ∇

    ∇ r←Copyright
      :Access Public Shared
    ⍝ Prints copyright information
      r←''
      r,←⊂'This software comes on an "as-is" basis without any obligations.'
      r,←⊂'It can be used in any way you like!'
      r←⎕FMT,[1.5]r
    ∇

⍝ --------------- Properties and Fields

    :Field Private ReadOnly  constructorIsRunning←0

    :Property encoding
    ⍝ In a Unicode interprter, this can be either 'ASCII' or 'UTF8'.
    ⍝ In a Classic interpreter any other setting than ANSII will be ignored.
    :Access Public
        ∇ r←get
          r←_encoding
        ∇
    :EndProperty

    :Property autoReOpen
    ⍝ Boolean. Defaults to 1, meaning that an instance of `Logger` re-opens its log file _
    ⍝ itself when this is appropriate. For example, if `filenameType` is "year", the file _
    ⍝ re-opens with a new name  as soon as a new year comes along.
    ⍝ Note that `Logger` throws an error when `autoReOpen` is 1 and `filename` is _
    ⍝ not empty.
    :Access Public Instance
        ∇ r←get
          r←_autoReOpen
        ∇
        ∇ set arg
          'Must be a Boolean'⎕SIGNAL 11/⍨~arg.NewValue∊0 1
          _autoReOpen←arg.NewValue
        ∇
    :EndProperty

    :Property filenameType
    ⍝ Might be one of: "DATE" (the default) or "YEAR" or "MONTH".
    ⍝ The name of the logfile then becomes accordingly "yyyymmdd" or "yyyy" of "yyyymm"
    :Access Public Instance
        ∇ r←get
          r←_filenameType
        ∇
        ∇ set arg;buffer
          buffer←Uppercase arg.NewValue
          'Invalid filenameType'⎕SIGNAL 11/⍨~(⊂buffer)∊'DATE' 'YEAR' 'MONTH' ''
          _filenameType←arg.NewValue
        ∇
    :EndProperty

    :Property debug
    ⍝ Since logging information to a file for analyzing purposes should never break an application, _
    ⍝ error trapping is used heavily within `Logger`. However, this is not appropriate for debugging _
    ⍝ `Logging`. Therefore, setting `debug` to 1 switches error trapping off completely.
    :Access Public Instance
        ∇ r←get
          r←_debug
        ∇
        ∇ set arg
          'Must be a Boolean'⎕SIGNAL 11/⍨~arg.NewValue∊0 1
          _debug←arg.NewValue
        ∇
    :EndProperty

    :Property printToSession
    ⍝ Setting this to 1 let an instance print every entry not only to the underlying file but also _
    ⍝ to the session. Appropriate when debugging an application. Is ignored if `debug` is 0!
    ⍝ Defaults to 0.
    :Access Public Instance
        ∇ r←get
          r←_printToSession
        ∇
        ∇ set arg
          'Must be a Boolean'⎕SIGNAL 11/⍨~arg.NewValue∊0 1
          _printToSession←arg.NewValue
        ∇
    :EndProperty

    :Property extension
    ⍝ This defines the file extension of the log file to be created. Defaults to "log"
    :Access Public Instance
        ∇ r←get
          r←_extension
        ∇
        ∇ set arg
          'Must be simple'⎕SIGNAL 11/⍨~0 1∊⍨≡arg.NewValue
          'Must be a string'⎕SIGNAL 11/⍨~IsChar arg.NewValue
          _extension←arg.NewValue
        ∇
    :EndProperty

    :Property refToUtils
    ⍝ The `Logger` class needs two scripts, `WinFile` and `APLTreeUtils`. While `APLTreeUtils` _
    ⍝ <b>must</b> be situated in the same namespace as `Logger` because it's :Included, _
    ⍝ Logger looks for `WinFile` at several places: it will find it automatically if _
    ⍝ it is situated either in the same namespace as `Logger` itself or in # or where _
    ⍝ `Logger` got instanciated from. If this is not appropriate for you, you <b>must</b> _
    ⍝  set `refToUtils` to the namespace which keeps `WinFile`.
    :Access Public Instance
        ∇ r←get
          r←_refToUtils
        ∇
        ∇ set arg
          _refToUtils←arg.NewValue
        ∇
    :EndProperty

    :Property timestamp
    ⍝ Use this for debugging purposes only: if `timestamp` is not empty it is used instead of _
    ⍝ `⎕TS`. Useful to test the "re-open" feature, for example.
    ⍝ `timestamp` must be a vector of integers with 6 items: y,m,d,h,m,s.
    ⍝ Note that this is <b>ignored</b> if `debug` is 0!
    :Access Public Instance
        ∇ r←get
          r←_timestamp
        ∇
        ∇ set arg
          →(0∊⍴,arg.NewValue)/0
          'Invalid time stamp'⎕SIGNAL 11/⍨~(⍴,arg.NewValue)∊3 6
          'Invalid time stamp'⎕SIGNAL 11/⍨∨/~(⎕DR¨arg.NewValue)∊163 83
          _timestamp←6↑arg.NewValue
        ∇
    :EndProperty

    :Property active
    ⍝ Use this to switch logging effectively on and off. If it is zero, there is not even _
    ⍝ a log file opened. If later `active` is set to 1, the log file will be opened by then.
    ⍝ If an instance is created with `active←1` and is set later to 0 the then opened _
    ⍝ logfile will not be closed, however. In this case any operations are _
    ⍝ suppressed, but the log file will remain open.
    ⍝ See also `fileFlag`.
    :Access Public Instance
        ∇ r←get
          r←_active
        ∇
        ∇ set arg;msg
          '"active" must be a Boolean'⎕SIGNAL 11/⍨~∨/arg.NewValue∊0 1
          _active←arg.NewValue
          :If _active∧_fileFlag
          :AndIf 0=constructorIsRunning  ⍝ is set inside any constructor (locally!) to 1
          :AndIf ⍬≡_fileDescriptor ⍝ means that the log file haven't got opened so far
              (_errorCounter msg)←Create ⍬
              msg ⎕SIGNAL 11/⍨_errorCounter
          :EndIf
        ∇
    :EndProperty

    :Property fileFlag
    ⍝ Use this to suppress any file operations. In any other respect `Logger` behaves as _
    ⍝ usual, in particular the `Log` and the `LogError` methods return their explicit _
    ⍝ results. That is the difference to `active` which switches off everything meaning _
    ⍝ that the `Log` method as well as the `LogError` method return empty vectors.
    ⍝ Note this can be set as part of a command space. If it is zero there is not even a _
    ⍝ log file opened. If `fileFlag` is set later to 1 (and `active` is 1 by then), the _
    ⍝ log file will be opened then.
    ⍝ If an instance is created with `fileFlag←1` and it is set later to 0 the then _
    ⍝ opened logfile will not be closed, however. In this case any file operations are _
    ⍝ suppressed but the log file will remain open.
    ⍝ See also `active`.
    :Access Public
        ∇ r←get
          r←_fileFlag
        ∇
        ∇ set arg;msg
          '"fileFlag" must be a Boolean'⎕SIGNAL 11/⍨~∨/arg.NewValue∊0 1
          _fileFlag←arg.NewValue
          :If _fileFlag∧_active
          :AndIf 0=constructorIsRunning     ⍝ is set inside any constructor (localysed!) to 1
          :AndIf ⍬≡_fileDescriptor          ⍝ means that the log file haven't got opened so far
              (_errorCounter msg)←Create ⍬
              msg ⎕SIGNAL 11/⍨_errorCounter
          :EndIf
        ∇
    :EndProperty


    :Property filenamePrefix
    ⍝ Adds a prefix to the filename. For example, if the defaults for `filenameType` and _
    ⍝ `extension` are in effect, setting `filenamePrefix` to "foo" leads to _
    ⍝ foo_20080601.log on the first of June 2008.
    ⍝ Setting this after having already created an instance is too late for this instance, of _
    ⍝ course, although it will be taken into account when the log file is reopened. To specify _
    ⍝ it in time pass a command space to the constructor.
    :Access Public Instance
        ∇ r←get
          r←_filenamePrefix
        ∇
        ∇ set arg
          '"filenamePrefix" must be a string'⎕SIGNAL 11/⍨~IsChar arg.NewValue
          _filenamePrefix←arg.NewValue
        ∇
    :EndProperty

    :Property filenamePostfix
    ⍝ Adds a postfix to the filename. For example, if the defaults for `filenameType` and _
    ⍝ `extension` are in effect, setting "filenamePostfix" to "foo" leads to _
    ⍝ 20080601_foo.log on the first of June 2008.
    ⍝ Setting this after having already created an instance is too late for this instance, of _
    ⍝ course, although it will be taken into account when the log file is reopened. To specify _
    ⍝ it in time pass a command space to the constructor.
    :Access Public Instance
        ∇ r←get
          r←_filenamePostfix
        ∇
        ∇ set arg
          '"filenamePostfix" must be a string'⎕SIGNAL 11/⍨~IsChar arg.NewValue
          _filenamePostfix←arg.NewValue
        ∇
    :EndProperty

    :Property errorPrefix
    ⍝ Adds a prefix to an error message to be logged by calling `LogError`. Defaults to "*** ERROR"
    ⍝ Setting this after having already created an instance might be too late for this instance, _
    ⍝ although it will be taken into account from then. To specify it in time pass a command _
    ⍝ space to the constructor.
    :Access Public Instance
        ∇ r←get
          r←_errorPrefix
        ∇
        ∇ set arg
          '"errorPrefix" must be a string'⎕SIGNAL 11/⍨~IsChar arg.NewValue
          _errorPrefix←arg.NewValue
        ∇
    :EndProperty

    :Property path
    ⍝ Return the log file's folder. Can only be specified when an instance is created.
    :Access Public Instance
        ∇ r←get
          r←_path
        ∇
    :EndProperty

    :Property filename
    ⍝ Return the log's current filename which is fully qualified.
    ⍝ You can specify this property when calling `⎕NEW` but not later.
    ⍝ Note that `Logger` throws an error when `autoReOpen` is 1 and `filename` is _
    ⍝ not empty.
    :ACcess Public Instance
        ∇ r←get
          r←_filename
        ∇
    :EndProperty

    :Property fileDescriptor
    ⍝ Return the log file's descriptor number.
    :ACcess Public Instance
        ∇ r←get
          r←_fileDescriptor
        ∇
    :EndProperty

    :Property errorCounter
    ⍝ Integer that returns the number of errors that have occured in an instance _
    ⍝ so far - ideally this is 0.
    ⍝ This is maintained only if `debug` is zero.
    :ACcess Public Instance
        ∇ r←get
          r←_errorCounter
        ∇
    :EndProperty

⍝ --------------- Constructors

    ∇ make0;constructorIsRunning;msg
    ⍝ Defaults, defaults, defaults
      :Access Public Instance
      :Implements Constructor
      constructorIsRunning←1
      InitialyzeProperties
      (_errorCounter msg)←Create ⍬
      SetDisplayFormat
      msg ⎕SIGNAL 11/⍨_errorCounter
    ∇

    ∇ make1(pathOrCommandSpace);bool;list;this;constructorIsRunning;msg
    ⍝ `pathOrCommandSpace` can be either a path or a command space:
    ⍝ path: Directory the log file is going to.
    ⍝ Command space: Useful to set all possible parameters. Note that you can ask _
    ⍝ `Logger` to create a command space for you, see method `CreatePropertySpace`. _
    ⍝ Then simply set those where the defaults do not fit your needs.
      :Access Public Instance
      :Implements Constructor
      constructorIsRunning←1
      InitialyzeProperties
      :If 9.1=⎕NC⊂,'pathOrCommandSpace'
      :AndIf 0=≡pathOrCommandSpace
 ⍝ It is a command space
          :If ∨/bool←2≠⎕NC⊃'_',¨list←pathOrCommandSpace.⎕NL-2
              11 ⎕SIGNAL⍨'Invalid keyword(s): ',↑{⍺,',',⍵}/bool/list
          :EndIf
          'Missing: "active"'⎕SIGNAL 1/⍨~(⊂'active')∊list
          :If 9=pathOrCommandSpace.⎕NC'refToUtils'
              _refToUtils←pathOrCommandSpace.refToUtils  ⍝ we need this in some setters/getters
          :EndIf
          :If 0∊⍴⍕refToUtils
              'Missing: "refToUtils"'⎕SIGNAL 6
          :EndIf
          :For this :In {⍵,'←',{' '=1↑0⍴⍵:'''',⍵,'''' ⋄ ⍵≡⍬:'⍬' ⋄ ⍕⍵}pathOrCommandSpace.⍎⍵}¨list~'filename' 'path' 'encoding' 'refToUtils'
              ⍎this ⍝ not eached for easier debugging
          :EndFor
          :If (⊂'filename')∊list
              _filename←pathOrCommandSpace.filename
          :EndIf
          :If (⊂'path')∊list
              _path←ProcessPath pathOrCommandSpace.path
          :EndIf
          :If (⊂'encoding')∊list
              :If 0∊⍴_encoding←ProcessEncoding pathOrCommandSpace.encoding
                  'Invalid value: "encoding"'⎕SIGNAL 11
              :EndIf
          :EndIf
          :If 0∊⍴_filename,_filenamePostfix,_filenamePrefix,_filenameType
              'No "filenameType" specified but no "filename", "filenamePostfix", "filenamePrefix" either'⎕SIGNAL 11
          :EndIf
      :ElseIf ' '≠1↑0⍴∊pathOrCommandSpace
          'Invalid parameters'⎕SIGNAL 11
      :Else
          _path←ProcessPath pathOrCommandSpace
      :EndIf
      (_errorCounter msg)←Create ⍬
      SetDisplayFormat
      msg ⎕SIGNAL 11/⍨_errorCounter
    ∇

    ∇ make2(path_ encoding_);constructorIsRunning;msg
    ⍝ `encoding` is a flag defining the encoding. 0 (the default) is ASCII/ANSI, 1=UTF-8
      :Access Public Instance
      :Implements Constructor
      constructorIsRunning←1
      InitialyzeProperties
      :If 0∊⍴_encoding←ProcessEncoding encoding_
          'Invalid: "encoding"'⎕SIGNAL 11
      :EndIf
      _path←ProcessPath path_
      (_errorCounter msg)←Create ⍬
      SetDisplayFormat
      msg ⎕SIGNAL 11/⍨_errorCounter
    ∇

    ∇ make3(path_ encoding_ filenameType_);constructorIsRunning;msg
    ⍝ `filenameType_` (default: 'DATE') defines when a log files is reopened with a new name. _
    ⍝ The default means that every night at 23:59:59 a new file is opened. _
    ⍝ Can be "MONTH" or "YEAR" instead.
      :Access Public Instance
      :Implements Constructor
      constructorIsRunning←1
      InitialyzeProperties
      _path←ProcessPath path_
      _encoding←ProcessEncoding encoding_
      filenameType←filenameType_
      (_errorCounter msg)←Create ⍬
      SetDisplayFormat
      msg ⎕SIGNAL 11/⍨_errorCounter
    ∇

    ∇ make4(path_ encoding_ filenameType_ debug_);constructorIsRunning;msg
    ⍝ `debug` (default: 0) is a Boolean useful to switch error trapping off
      :Access Public Instance
      :Implements Constructor
      constructorIsRunning←1
      InitialyzeProperties
      _path←ProcessPath path_
      :If 0∊⍴_encoding←ProcessEncoding encoding_
          'Invalid: "encoding"'⎕SIGNAL 11
      :EndIf
      filenameType←filenameType_
      debug←debug_
      (_errorCounter msg)←Create ⍬
      SetDisplayFormat
      msg ⎕SIGNAL 11/⍨_errorCounter
    ∇

    ∇ make5(path_ encoding_ filenameType_ debug_ timestamp_);constructorIsRunning;msg
    ⍝ `timestamp` defaults to `6↑⎕TS`. For testing purposes, for example the _
    ⍝ re-open feature of the `Logging` class, you can specify a particular timestamp.
      :Access Public Instance
      :Implements Constructor
      constructorIsRunning←1
      InitialyzeProperties
      _path←ProcessPath path_
      :If 0∊⍴_encoding←ProcessEncoding encoding_
          'Invalid: "encoding"'⎕SIGNAL 11
      :EndIf
      filenameType←filenameType_
      debug←debug_
      timestamp←timestamp_
      (_errorCounter msg)←Create ⍬
      SetDisplayFormat
      msg ⎕SIGNAL 11/⍨_errorCounter
    ∇

    ∇ make6(path_ encoding_ filenameType_ debug_ timestamp_ refToUtils_);constructorIsRunning;msg
    ⍝ `refToUtils` must be a ref to the namespace which contains `WinFile`.
      :Access Public Instance
      :Implements Constructor
      constructorIsRunning←1
      InitialyzeProperties
      _refToUtils←refToUtils_
      _path←ProcessPath path_
      :If 0∊⍴_encoding←ProcessEncoding encoding_
          'Invalid: "encoding"'⎕SIGNAL 11
      :EndIf
      filenameType←filenameType_
      debug←debug_
      timestamp←timestamp_
      (_errorCounter msg)←Create ⍬
      SetDisplayFormat
      msg ⎕SIGNAL 11/⍨_errorCounter
    ∇

    ∇ InitialyzeProperties
    ⍝ Guess what: initialyzes the properties.
    ⍝ Called very early in the constructors but also by CreateCommandspace
      _active←1
      _fileFlag←1
      _debug←0                  ⍝ Switch of error trapping
      _encoding←'ANSI'          ⍝ One of "ANSI", "ASCII", "UTF". Note that "ANSI" makes a difference to "ASCII" on Classic only.
      _autoReOpen←1             ⍝ re-opens log file with a new name according to the "filenameType"
      _filenameType←'DATE'      ⍝ default filenameType is "yyyymmdd" which is re-opened daily
      _printToSession←0         ⍝ If this is 1, every entry is printed to the session as well
      _refToUtils←FindPathTo'WinFile'
      _path←''                  ⍝ Directory the log file will go into; empty=current dir
      _filename←''              ⍝ the actual name
      _timestamp←⍬              ⍝ To simulate []TS; ignored when debug=0
      _extension←'log'          ⍝ File extension of the log file
      _filenamePrefix←''        ⍝ Prefix added to "filename"; use this only when "filename" is empty
      _filenamePostfix←''       ⍝ Postfix added to "filename"; use this only when "filename" is empty
      _errorPrefix←'*** ERROR'  ⍝ How to prefix error entries in the log file
      _fileDescriptor←⍬         ⍝ May indicate that "active" was 0 from the start!
      _tieNumber←⍬              ⍝ Tie number of the log file or ⍬
    ∇

    ∇ {(r msg)}←Create dummy;rc;hint;newFilename;flag
    ⍝ Is called by the "official" constructors but is private, strictly speaking.
      r←0
      msg←''
      flag←9≠_refToUtils.⎕NC'WinFile'
      :If ~0∊⍴_filename
      :AndIf _autoReOpen
          r←1
          msg←'"filename" MUST NOT be set with autoReOpen=1'
          :Return
      :EndIf
      :If flag
          msg←'Not found: script "WinFile"'
          :If _debug
              msg ⎕SIGNAL 6
          :Else flag
              →0,r←1
          :EndIf
      :EndIf
      (r msg)←Open ⍬
 ⍝Done
    ∇

⍝ --------------- Public Shared Methods


⍝ --------------- Public Instance Methods

    ∇ r←CreatePropertySpace
      :Access Public Shared
      ⍝ Use this to create a command space which can then be modified and finally _
      ⍝ passed to the constructor
      ⍝ Note that the resulting namespace contains a method `List` which prints _
      ⍝ all names and their values to the session.
      r←⎕NS''
      InitialyzeProperties
      r.active←_active
      r.encoding←_encoding
      r.autoReOpen←_autoReOpen
      r.debug←_debug
      r.errorPrefix←_errorPrefix
      r.extension←_extension
      r.fileFlag←_fileFlag
      r.filename←_filename
      r.filenamePostfix←_filenamePostfix
      r.filenamePrefix←_filenamePrefix
      r.filenameType←_filenameType
      r.path←_path
      r.printToSession←_printToSession
      r.refToUtils←_refToUtils
      r.timestamp←_timestamp
      r.⎕FX'r←List' 'r←{⍵,[1.5]⍎¨⍵}⎕nl -2'
    ∇

    ∇ {r}←Log msg;rc;newFilename;flag;buffer;thisTimestamp;⎕TRAP
      :Access Public Instance
    ⍝ Writes `msg` into the Log File.
    ⍝ `r` gets the message written to the log file together with the time stamp and thread no.
    ⍝ `msg` can be one of:
    ⍝ * A vector
    ⍝ * A matrix
    ⍝ * A vector of vectors
      ⎕TRAP←(999 'E' '({⍵↑⍨1⍳⍨''rc=''{⍺⍷⍵}⍵}⎕IO⊃⎕DM)⎕SIGNAL {⍎⍵↑⍨-''=''⍳⍨⌽⍵}⎕IO⊃⎕DM')((0 1000)'N')
      r←''
      :If _active
          :Trap SetTrap 0
              thisTimestamp←Timestamp 1
              msg←Nest{2=⍴⍴⍵:⊂[2]⍵ ⋄ ⍵}msg
              msg←HandleEncoding msg
              :If _fileFlag
                  r←WriteToLogfile msg thisTimestamp
              :Else
                  ⎕←⊃PolishMsg msg
              :EndIf
          :Else
              _errorCounter+←1
          :EndTrap
      :EndIf
    ∇

    ∇ {r}←LogError y;rc;msg;more;⎕TRAP;timestamp
      :Access Public Instance
     ⍝ y is a two- or three-item vector with:
     ⍝ # rc (Return code) 0 means that `LogError` won't do anything at all.
     ⍝ # msg              Either a simple char vector or a vector of char vectors.
     ⍝ # more (optional)  Any array that has a depth of 2 or less and a rank of 2 or less.
     ⍝ Returns an empty vector in case rc←0 otherwise what was printed to the log file.
      r←''
      ⎕TRAP←(999 'E' '({⍵↑⍨1⍳⍨''rc=''{⍺⍷⍵}⍵}⎕IO⊃⎕DM)⎕SIGNAL {⍎⍵↑⍨-''=''⍳⍨⌽⍵}⎕IO⊃⎕DM')((0 1000)'N')
      :If ~2 3∊⍨⍴,y
          :If _debug
              'Length error - right argument'⎕SIGNAL 6
          :Else
              →0,_errorCounter+←1
          :EndIf
      :EndIf
      (rc msg more)←3↑y,(⍴,y)↓0 '' ''
      msg←{2=⍴⍴⍵:↓⍵ ⋄ ,Nest ⍵}msg
      msg←HandleEncoding msg
      more←⍕¨⊃,/{2=⍴⍴⍵:↓⍵ ⋄ ⊂,⍵}¨Nest⊃,/{2=⍴⍴⍵:↓⍵ ⋄ ⊂,⍵}more
      :If 2<≡more
          more←∊¨more
      :EndIf
      more←HandleEncoding more
      :If _active∧0≠rc
          msg←MassageErrorMessage msg
          (msg more)←ApplyMakeUp rc msg more
          →(0∊⍴msg,more)/0
          :Trap 0
              :If _fileFlag
                  timestamp←Timestamp 1
                  r←WriteToLogfile msg timestamp
                  r,←WriteToLogfile more timestamp
              :Else
                  ⎕←⊃PolishMsg msg
              :EndIf
          :EndTrap
      :EndIf
    ∇

⍝ --------------- Private stuff

    ∇ (rc more filename)←MakeNewFilename filename
    ⍝ Compiles a new filename and takes any changes in the timestamp into account.
    ⍝ As a result, the compiled filename might differ from the one used so far.
    ⍝ In that case, obviously the log file needs to be re-opened when autoReOpen←→1
      rc←0 ⋄ more←''
      :Trap SetTrap 0
          :If _autoReOpen
              filename←(8↑Timestamp 0)↑⍨('DATE' 'MONTH' 'YEAR'⍳⊂_filenameType)⊃8 6 4 0
          :ElseIf ~0∊⍴_filename
              filename←_filename
          :EndIf
          filename←_filenamePostfix{0∊⍴⍺:⍵ ⋄ ⍵,'_',⍺}filename
          filename←_filenamePrefix{0∊⍴⍺:⍵ ⋄ ⍺,'_',⍵}filename
      :Else
          :If _debug
              . ⍝ something is wrong here
          :Else
              rc←1
              more←⎕DM
          :EndIf
      :EndTrap
    ∇

    ∇ r←SetTrap events;Flag
 ⍝ R gets 1 if error trapping is appropriate according to the _
 ⍝ global _debug variable
      :Trap 0
          r←(~_debug)/events
      :Else
          r←events
      :EndTrap
    ∇

    ∇ r←Timestamp decoratorFlag;ts
⍝ 1=decoratorFlag ←→ yyyy-mm-dd hh:mm:ss
⍝ 0=decoratorFlag ←→ yyyymmddhhmmss
      :If ~0∊⍴_timestamp
      :AndIf _debug
          ts←6↑_timestamp
      :Else
          ts←6↑⎕TS
      :EndIf
      :If decoratorFlag
          r←,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT,[0.5]ts
      :ElseIf 0=decoratorFlag
          r←,'ZI4,ZI2,ZI2,ZI2,ZI2,ZI2'⎕FMT,[0.5]3↑ts
      :Else
          'Invalid right argument for "Timestamp" rc=11'⎕SIGNAL 999
      :EndIf
    ∇

    ∇ {(r msg)}←Open newFilename;rc;hint;fno;⎕RL
    ⍝ Open the log file. Any directory requested but non-existent is created here as well.
      r←0
      msg←''
      :If _active∧_fileFlag
          :Trap SetTrap 0
              _filenameType←Uppercase _filenameType
              :If 0∊⍴newFilename
                  (rc hint newFilename)←MakeNewFilename''
                  :If 0≠rc
                      msg←'Could not create new filename from "filenameType" and "path"'
                      :If _debug
                          msg ⎕SIGNAL 11
                      :Else
                          →0,r←1
                      :EndIf
                  :EndIf
              :EndIf
              :If '.'≠↑¯4↑newFilename
                  newFilename,←'.',_extension
              :EndIf
              _filename←newFilename
              :If ~0∊⍴_path
                  :If ~'CREATE!'_refToUtils.WinFile.CheckPath _path
                      msg←'Could not open the log file, check the path'
                      :If _debug
                          msg ⎕SIGNAL 11
                      :Else
                          →0,r←1
                      :EndIf
                  :EndIf
              :EndIf
              ⎕RL←+/⎕TS
              fno←-?99999999 ⍝ See "Close" for details why we are doing this!
              :Trap 0
                  _fileDescriptor←FullFilename ⎕NCREATE fno
              :Case 22
                  :Trap SetTrap 0
                      _fileDescriptor←FullFilename ⎕NTIE fno ⍝ 66 ⍝ grant all to all!
                  :Else
                      msg←'Error during open of logfiles: ',1⊃⎕DM
                      :If _debug
                          msg ⎕SIGNAL ⎕EN
                      :Else
                          →0,r←1
                      :EndIf
                  :EndTrap
              :Else
                  ⎕SIGNAL 11
              :EndTrap
              ((Timestamp 1),' ','*** Log File opened',CrLf)⎕NAPPEND _fileDescriptor Encoding
          :Else
              r←1
              msg←'Error during open of logfiles'
              :If _debug
                  msg ⎕SIGNAL ⎕EN
              :EndIf
          :EndTrap
      :EndIf
    ∇

    ∇ (r newFilename)←CheckForReopen;rc;hint;string
     ⍝ r←0   if there is no need to re-open the log file
     ⍝ r←1   if the log file needs to be re-opened
     ⍝ r←¯1  in case of an error
      newFilename←''
      :If r←~0∊⍴,_autoReOpen
          (rc hint newFilename)←MakeNewFilename _filename
          :If 0≠rc
              :If _debug
                  hint ⎕SIGNAL rc
              :Else
                  →0,r←¯1
              :EndIf
          :EndIf
          :If (0∊⍴,newFilename)∨~_autoReOpen
              r←0
          :Else
              string←(⍴_filenamePrefix)↓_filename
              :Select _filenameType
              :Case 'DATE'
                  r←string[7 8]≢((⍴_filenamePrefix)↓newFilename)[7 8]
              :Case 'MONTH'
                  r←string[5 6]≢((⍴_filenamePrefix)↓newFilename)[5 6]
              :Case 'YEAR'
                  r←string[1 2 3 4]≢((⍴_filenamePrefix)↓newFilename)[1 2 3 4]
              :Case ''
                  r←newFilename≢1⊃'.'Split _filename
              :EndSelect
          :EndIf
      :EndIf
    ∇

    ∇ Close;This;was
      :Access Public
    ⍝ Closes the log file
      :Trap 0
          Log'*** Log file closed'
      :EndTrap
      Close2
      ⎕DF'[Logger:]'
    ∇

    ∇ r←FullFilename
      :Access Public Instance
    ⍝ Returns the fully qualified file name of the log file: path+filename
      r←_path,_filename
    ∇

⍝ --------------- Private stuff

    ∇ r←Encoding
      r←{82=⎕DR' ':82
          ('ASCII' 'UTF8'⍳⊂⍵)⊃82 80 82}_encoding
    ∇

    ∇ r←QavPoints
    ⍝ Returns the Unicode points of all chars in the standard ⎕AV:  ⎕UCS ⎕AV
    ⍝ Used to tell in the classic version "real" Unicode chars from any chars in ⎕AV
      r←0 8 10 13 32 12 6 7 27 9 9014 619 37 39 9082 9077 95 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113
      r,←114 115 116 117 118 119 120 121 122 1 2 175 46 9068 48 49 50 51 52 53 54 55 56 57 3 164 165 36 163 162 8710 65 66 67
      r,←68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 4 5 253 183 127 9049 193 194 195 199 200 202 203
      r,←204 205 206 207 208 210 211 212 213 217 218 219 221 254 227 236 240 242 245 123 8364 125 8867 9015 168 192 196 197
      r,←198 9064 201 209 214 216 220 223 224 225 226 228 229 230 231 232 233 234 235 237 238 239 241 91 47 9023 92 9024 60 8804
      r,←61 8805 62 8800 8744 8743 45 43 247 215 63 8714 9076 126 8593 8595 9075 9675 42 8968 8970 8711 8728 40 8834 8835 8745
      r,←8746 8869 8868 124 59 44 9073 9074 9042 9035 9033 9021 8854 9055 9017 33 9045 9038 9067 9066 8801 8802 243 244 246 248
      r,←34 35 30 38 8217 9496 9488 9484 9492 9532 9472 9500 9508 9524 9516 9474 64 249 250 251 94 252 8216 8739 182 58 9079 191
      r,←161 8900 8592 8594 9053 41 93 31 160 167 9109 9054 9059
    ∇

      ProcessPath←{
          0∊⍴⍵:''
          ⍵,(~'\/'∊⍨¯1↑⍵)/'/'  ⍝ append / if appropriate
      }

      ProcessEncoding←{
          0=1↑0⍴∊⍵:'ASCII'
          w←Uppercase ⍵
          (⊂w)∊'ASCII' 'UTF8' 'ANSI':w
          '' ⍝ invalid!
      }

      PolishMsg←{
      ⍝ Called before a message is printed to the session.
      ⍝ Makes sure that ⎕PW is taken into account
      ⍝ ⍵ is a vector of strings
          max←⎕PW-3
          ∧/~bool←max<↑∘⍴¨r←⍵:r
          (bool/r)←max{'..',⍨⍺↑⍵}¨bool/r
          r
      }

    ∇ r←IsUnicodeInterpreter
      r←80=⎕DR' '
    ∇

    ∇ txt←HandleEncoding txt;ascii;nestedFlag
      nestedFlag←0 1∧.<≡txt
      txt←Nest txt
      :If (_encoding≡'UTF8')∧IsUnicodeInterpreter
          txt←⎕UCS¨'UTF-8'∘⎕UCS¨txt
      :Else
          :If IsUnicodeInterpreter
              :If _encoding≡'ASCII'
                  ascii←'1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM!"$%∧&*()-_=+]}[{#~''@;:/?.>,<\| ',⎕UCS 8 13 10
                  txt←ascii∘{0=+/bool←~(w←⍵)∊⍺:w ⋄ (bool/w)←'?' ⋄ w}¨,¨txt
              :Else
                  txt←{~(⎕DR ⍵)∊80 160:⍕⍵ ⋄ 0=+/bool←128<⎕UCS w←⍵:⍵ ⋄ (bool/w)←'¿' ⋄ w}¨,¨txt  ⍝ replace non-ASCII chars by "¿"
              :EndIf
          :Else
                  ⍝ It's a "Classic" interpreter so it's ANSI by definition: we don't need to do anything here.
          :EndIf
      :EndIf
      txt←∊⍣(↑~nestedFlag)⊣txt
    ∇

    ∇ {r}←WriteToLogfile(msg thisTimestamp);rc;newFilename;buffer;flag;⎕TRAP
      ⎕TRAP←(⊂999 'N'),⎕TRAP
      r←''
      msg←msg,¨⊂CrLf
      :If 0∊⍴_fileDescriptor
          :If _debug
              'Log file was already closed rc=11'⎕SIGNAL 999
          :Else
              →0,_errorCounter+←1
          :EndIf
      :EndIf
      (rc newFilename)←CheckForReopen ⍝ Check re-open condition
      :Select rc
      :Case ¯1
          :If _debug
              'Re-Open check failed rc=11'⎕SIGNAL 999
          :Else
              →0,_errorCounter+←1
          :EndIf
      :Case 1
          buffer←thisTimestamp,' (',(⍕⎕TID),') *** Log File is going to be closed and then reopened with a new filename',CrLf
          buffer ⎕NAPPEND _fileDescriptor Encoding
          ⎕NUNTIE _fileDescriptor
          _fileDescriptor←⍬
          Open newFilename
          thisTimestamp←Timestamp 1
      :Case 0
                            ⍝ nothing to do, is still fine
      :Case
          .                 ⍝ must not happen!
      :EndSelect
      flag←0
      :Trap 0
          (∊((Timestamp 1),' (',(⍕⎕TID),') ')∘,¨msg)⎕NAPPEND _fileDescriptor Encoding
          r←msg
      :Else
          _errorCounter+←1
          flag←1
          :Trap 0
              ((Timestamp 1),' (',(⍕⎕TID),')')∘{(⍺,' ',∊⍵,CrLf)⎕NAPPEND _fileDescriptor Encoding}¨buffer←(⊂'Invalid msg passed via:'),1↓(⎕LC{⍵,' [',(⍕⍺),']'}¨⎕XSI)
          :EndTrap
      :EndTrap
      :If _printToSession
          :If flag
              ⎕←⊃PolishMsg buffer
          :Else
              ⎕←⊃PolishMsg ¯2↓¨msg
          :EndIf
      :EndIf
    ∇

    ∇ msg←MassageErrorMessage msg
      msg←{2=⍴⍴⍵:↓⍵ ⋄ ⍵}msg
      :If ~0 1∊⍨≡msg
          :If 2≠≡msg
              :If _debug
                  'Invalid "msg"'⎕SIGNAL 11
              :Else
                  _errorCounter+←1
                  :Return
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ (msg2 more2)←ApplyMakeUp(rc msg more);prefix
      msg2←more2←''
      :Trap 0
          :If 2=≡msg
              prefix←_errorPrefix,' RC=',(⍕rc),'; '
              (↑msg)←prefix,↑msg
              :If 1<⍴msg
                  (1↓msg)←(⍴prefix)∘AddTrailingBlanks¨1↓msg
              :EndIf
          :Else
              msg←_errorPrefix,' RC=',(⍕rc),'; ',msg
          :EndIf
      :Else
          :If _debug
              →0,⍴r'Invalid "msg"' 11
          :Else
              →0,_errorCounter+←1
          :EndIf
      :EndTrap
      :Trap 0
          :If 0∊⍴∊more
              more←''
          :Else
              more←(1+⍴,_errorPrefix)∘AddTrailingBlanks¨more
          :EndIf
      :Else
          :If _debug
              →0,r←'Invalid "more"' 11
          :Else
              →0,_errorCounter+←1
          :EndIf
      :EndTrap
      (msg2 more2)←msg more
    ∇

      AddTrailingBlanks←{
          0∊⍴⍵:⍵
          0 1∊⍨≡⍵:(⍺⍴' '),,⎕FMT ⍵
          2=⍴⍴⍵:↓⍵
          ⍺{(((1⊃⍴⍵),⍺-1)⍴' '),⍵}⎕FMT,[1.5]⍵
      }

⍝ --------------- Destructor

    ∇ Cleanup;List
      :Implements Destructor
      Close2
    ∇

    ∇ Close2
 ⍝ When the destructor (which calls "Close2"!) is finally executed _
 ⍝ the tie number originally used might well have be re-used by something _
 ⍝ else. That's the reason why we use a randomly generated tie number, _
 ⍝ and it also means that we need to check whether the file is still _
 ⍝ associated with the original (or any) file. Only then takes the
 ⍝ destructor action.
      :If 0<⎕NC'_fileDescriptor'
      :AndIf ⍬≢_fileDescriptor
      :AndIf _fileDescriptor∊⎕NNUMS
      :AndIf (_path,_filename)≡⎕NNAMES[⎕NNUMS⍳_fileDescriptor;]
          ⎕NUNTIE _fileDescriptor
          _fileDescriptor←⍬
          _filename←''
      :EndIf
    ∇

    ∇ {r}←SetDisplayFormat
      r←''
      ⎕DF'[Logger:',_path,_filename,'(',(⍕_fileDescriptor),')]'
    ∇

:EndClass