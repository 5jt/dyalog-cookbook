:Class IniFiles
⍝ ## APL-like INI files
⍝ ### Overview
⍝ This class provides a kind of APL-like INI files.
⍝ ~~~
⍝ MyInstance1←⎕NEW IniFiles (⊂,'MyIniFile.ini')
⍝ MyInstance2←⎕NEW IniFiles ('MyIniFile1.ini' 'MyIniFile2.ini')
⍝ AsNamespace←MyInstance2.Convert ⎕NS ''
⍝ ~~~
⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝
⍝ Homepage: http://aplwiki.com/IniFiles

    ⎕IO←1 ⋄ ⎕ML←3
    :Include APLTreeUtils  ⍝∇:require =/apltreeutils

    ∇ r←Version
      :Access Public Shared
      r←(Last⍕⎕THIS)'3.1.0' '2017-05-19'
    ∇

    ∇ History
      :Access Public Shared
      ⍝ * 3.1.0:
      ⍝   * Method `History` introduced.
      ⍝   * `IniFiles` is now managed by acre 3.
      ⍝ * 3.0.0:
      ⍝   * Needs at least Dyalog version 15.0 Unicode
      ⍝   * Does not need either `WinFile` or `FilesAndDirs` anymore.
      ⍝   * Documentation converted to Markdown. Requires at least ADOC 5.0.
    ∇

    ∇ r←GetSections
    ⍝ Returns a vector of strings with sections names.
      :Access Public Instance
      r←Uppercase 1↓¨_Sections
    ∇

    ∇ r←GetIniFiles filename;p;fn;ext;fn2;fn1;f1;f2
      :Access Public Shared
    ⍝ Returns a list of INI files. Assume that "foo.ini" ←→ filename.
    ⍝ Assume also that the current computer's name is "JohnDoe". Assume
    ⍝ further that there are two INI files in the current directory:
    ⍝ * foo.ini
    ⍝ * foo_johndoe.ini
    ⍝
    ⍝ Then `GetIniFiles` returns:
    ⍝
    ⍝ `'foo.ini' 'foo_johndoe,ini' ← #.IniFiles.GetIniFiles`
    ⍝
    ⍝ If there is no file foo_johndoe.ini however then the result is:
    ⍝
    ⍝ `'foo.ini' ← #.IniFiles.GetIniFiles`
      (p fn)←{('\'∊⍵):SplitPath ⍵ ⋄ ''⍵}filename
      (fn ext)←{('.'∊⍵):'.'SplitPath ⍵ ⋄ (⍵,'.')'ini'}fn
      f1←⎕NEXISTS fn1←p,fn,ext
      f2←⎕NEXISTS fn2←p,(¯1↓fn),'_',GetComputerName,'.',ext
      ⍎('Could not find ',fn1)Signal 6/⍨f1=0
      r←(f1/⊂fn1),f2/⊂fn2
    ∇

    ∇ (r data allRemarks)←Import(data allRemarks);il;refToIniFile;fullName;temp;buffer;bool;ilRemarks;i;thisRemark;this;r;lnos;buff
      bool←∨/¨'!Import'∘⍷¨data                  ⍝ Where are the files to be imported?
      lnos←⍳⍴data                               ⍝ Create Line Numbers
      il←bool⌿data                              ⍝ Create it (Import List)
      ilRemarks←bool/allRemarks                 ⍝ Remarks belonging to !Import
      ⍎'!Import statement must not have a remark'Signal 911/⍨0∨.<↑∘⍴¨ilRemarks
      data←(~bool)/data                         ⍝ Remove the "!Import" lines from "data" numbers
      lnos←bool/lnos                            ⍝ Remove the "!Import" lines from the line numbers
      allRemarks←(~bool)/allRemarks             ⍝ Remove the "!Import" lines from "allRemarks"
      il←(+/∧\' '=⊃il)↓¨il                      ⍝ Drop any leading blanks
      il←Lowercase¨(il⍳¨' ')↓¨il                ⍝ Drop method name, leaving the filenames
      refToIniFile←↑1⊃⎕CLASS ⎕THIS              ⍝ Ref to itself
      r←0 3⍴⊂''
      :For this :In il
          :If (~':'∊this)∧~(1⍴this)∊'/\'        ⍝ Does not start with / and has no drive letter?
              fullName←(↑1 ⎕NPARTS''),'\',this  ⍝ Then make it absolute
          :Else
              fullName←this                     ⍝ Is already absolute
          :EndIf
          fullName←↑,/1 ⎕NPARTS fullName
          'Tries to import itself'⎕SIGNAL 11/⍨(⊂Lowercase fullName)∊Lowercase _IniFilename
          temp←(⎕NEW refToIniFile(fullName _debugFlag)).Convert ⎕NS''  ⍝ Create an instance
          buff←temp.List''
          buff[;3]←DoubleCurlies¨buff[;3]
          r⍪←buff
      :EndFor
      _import←0<1⊃⍴r
    ∇

    :Property IniFilename
    :Access Public
        ∇ r←get
          r←{0∊⍴⍵:1⊃⍵ ⋄ ⊃{⍺,';',⍵}/⍵}_IniFilename
        ∇
    :EndProperty

    :Property Default
    :Access Public
    ⍝ This property is **initialised**! If set, indexing an unknown key will
    ⍝ return the value of this property.
        ∇ r←get
          ⍎'No default defined!'Signal 6/⍨0=⎕NC'_default'
          r←_default
        ∇
        ∇ set arg
          _default←arg.NewValue
        ∇
    :EndProperty

    :Property OldStyleFlag
    ⍝ Read-only property that tells you whether the current INI file is old-fashioned or not.
    :Access Public
        ∇ r←get
          r←_oldStyleFlag
        ∇
    :EndProperty

    :Property EstablishedAt
    ⍝ Stores date and time as float (date.time) when the instance was established.
    ⍝
    ⍝ Usefult if you want to find out whether the INI file was changed since it was instanciated.
    ⍝ See `HasInifileChanged`
    :Access Public
        ∇ r←get
          r←_EstablishedAt
        ∇
    :EndProperty


    :Property Changed
    ⍝ Read-only property that tells you that the data from the INI file was changed later on by assignment.
    ⍝
    ⍝ Note that those changes will persist only if the `Save` method is invoked at some point.
    :Access Public
        ∇ r←get
          r←_changed
        ∇
    :EndProperty

    :Property keyed default data
    ⍝ This property allows external access to the INI data via indexing.
        ∇ set val;where;EndHold;keys;section;key;data;where2;i;buffer;buffer2;ref;name;line;KEY;TOC;toc;this;new;newItem;comments;SECTION
          keys←{2=≡⍵:⍵ ⋄ ↑⍵}val.Indexers
          'Length Error'⎕SIGNAL(≠/↑∘⍴¨,¨keys(,val.NewValue))/11
          keys←{~':'∊⍵:⍵ ⋄ ⍵{((⍵-1)↑⍺)(⍵↓⍺)}⍵⍳':'}¨keys
          :For i :In ⍳⍴,keys
              buffer←i⊃,keys
              'Use "Section:key" syntax'⎕SIGNAL 11/⍨2≠⍴buffer
              (section key)←buffer
              SECTION←Uppercase section←'_',section
              :If (⍴_Sections)<where←_SECTIONS⍳⊂SECTION
                       ⍝ Event the section is new!
                  (Uppercase section)⎕NS''
                  _Sections,←⊂section
                  {⍵._Data←0 5⍴'' ⋄ ⍵.generalRemarks←''}⍎Uppercase section
                  _changed←1
                  where←⍴_Sections
              :EndIf
              data←{⍵._Data}ref←⍎where⊃_SECTIONS
              KEY←Uppercase key
              (toc TOC)←↓⍉data[;1 5]
              :If (1⊃⍴data)≥where2←TOC⍳⊂KEY
              ⍝ It is an update!
                  buffer←i⊃,val.NewValue
                  'Invalid depth'⎕SIGNAL 11/⍨~0 1 2∊⍨≡buffer
                  :If 2=≡buffer
                      new←''
                      :For this :In buffer
                          :If IsChar this
                              newItem←⊂ReplaceCurlies TOC this
                              newItem,←⊂'''',(DoubleQuotes this),''''
                              new,←⊂newItem
                          :Else
                              new,←⊂2⍴⊂⍕this
                          :EndIf
                      :EndFor
                      _changed∨←data[where2;2]≢1⊃¨new
                      :If (1+⍴new)≠⍴4⊃data[where2;] ⍝ Add one for initialiation (nested!)
                      :AndIf ~0∊⍴4⊃data[where2;]
                          ⍝ The length has changed, so the comments do not any longer fit!
                          comments←(1,(2⊃data[where2;])∊(1⊃¨new))/4⊃data[where2;]
                          comments←(1,(1⊃¨new)∊2⊃data[where2;])\comments
                          data[where2;4]←⊂comments
                      :EndIf
                      data[where2;2 3]←↓⍉⊃new
                  :Else
                      :If '{'∊buffer
                          data[where2;2]←⊂ReplaceCurlies TOC buffer
                          data[where2;3]←⊂'''',(DoubleQuotes buffer),''''
                      :EndIf
                      _changed∨←data[where2;2]≢⊂buffer
                      data[where2;2]←⊂buffer
                      data[where2;3]←⊂'''',(DoubleQuotes⍕buffer),''''
                  :EndIf
              :Else
              ⍝ key is new in this section
                  buffer←i⊃,val.NewValue
                  'Invalid depth'⎕SIGNAL 11/⍨~0 1 2∊⍨≡buffer
                  :If 2=≡buffer
                      new←''
                      :For this :In buffer
                          :If IsChar this
                              newItem←⊂ReplaceCurlies TOC this
                              newItem,←⊂'''',(DoubleQuotes this),''''
                          :Else
                              newItem←2⍴⊂⍕this
                          :EndIf
                          new,←⊂newItem
                      :EndFor
                      _changed←1
                      data⍪←((⊂key),(↓⍉⊃new),⊂''),⊂''
                  :Else
                      :If 2=+/'{}'∊buffer
                          name←{{⍵↑⍨¯1+'}'⍳⍨⍵}⍵↓⍨⍵⍳'{'}buffer
                          :If (1⊃⍴ref._Data)<line←ref._Data[;5]⍳⊂Uppercase name
                              6 ⎕SIGNAL⍨'Unknown: "',name,'"'
                          :EndIf
                          buffer2←(line⊃ref._Data[;2]){a←¯1+⍵⍳'{' ⋄ w←a⌽⍵ ⋄ (-a)⌽⍺,⍵↓⍨⍵⍳'}'}buffer
                      :Else
                          buffer2←buffer
                      :EndIf
                      :If IsChar buffer
                          buffer←DoubleQuotes buffer
                          buffer←'''',(⍕buffer),''''
                      :Else
                          buffer←{0 1∊⍨≡⍵:⍕⍵ ⋄ ∇¨⍵}buffer
                      :EndIf
                      data⍪←key buffer2 buffer''KEY
                      _changed←1
                  :EndIf
              :EndIf
              data{⍵._Data←⍺}⍎where⊃_SECTIONS
          :EndFor
        ∇

        ∇ r←get arg;keys;bool;where;this;KEYS;THIS;i;noOf
          'Invalid argument'⎕SIGNAL 11/⍨0 1∊⍨≡keys←↑arg.Indexers
          :If 0∊⍴keys←{~':'∊⍵:⍵ ⋄ ⍵{((⍵-1)↑⍺)(⍵↓⍺)}⍵⍳':'}¨keys
              r←''
          :Else
              'Invalid key'⎕SIGNAL 11/⍨0=⍴∊keys
              KEYS←Uppercase¨keys
              :If 0∊bool←('_',¨1⊃¨KEYS)∊Uppercase _Sections
                  11 ⎕SIGNAL⍨'Unknown section: ',⊃{⍺,',',⍵}/∪(~bool)/1⊃¨keys
              :EndIf
              r←''
              :For i :In ⍳⍴,keys
                  THIS←i⊃,KEYS
                  this←i⊃,keys
                  :If 0∊⍴2⊃this
                      r,←⊂{({⍵⌿⍨0<↑∘⍴¨⍵[;1]}⍵._Data)[;2]}⍎'_',1⊃THIS
                  :Else
                      noOf←{1⊃⍴⍵._Data}⍎'_',1⊃THIS
                      :If noOf<where←(2⊃THIS){(⍵._Data[;5])⍳⊂Uppercase ⍺}⍎'_',1⊃THIS
                          :If 0=⎕NC'_default'
                              6 ⎕SIGNAL⍨'Unknown: ',2⊃this
                          :Else
                              r,←⊂_default
                          :EndIf
                      :Else
                          r,←where{⍵._Data[where;2]}⍎'_',1⊃THIS
                      :EndIf
                  :EndIf
              :EndFor
              :If ⍬≡⍴keys
                  :If 1=≡r
                      r←↑r
                  :Else
                      r←r[1]
                  :EndIf
              :EndIf
          :EndIf
        ∇
    :EndProperty

⍝⍝⍝ Constructors

    ∇ make0;parent
      ⍝ No parameter: Creates a new INI file by definition
      :Implements Constructor
      :Access Public
      Init ⍬
      CallCreate''
    ∇

    ∇ make1(IniFilename)
      ⍝ Takes the name of one or more INI files to be processed as parameter.
      :Implements Constructor
      :Access Public
      Init ⍬
      CallCreate IniFilename
    ∇

    ∇ make2(IniFilename debugFlag)
      :Implements Constructor
      :Access Public
      ⍝ Takes the name of the INI file and what originally was supposed
      ⍝ to be a reference to the `UnicodeFile` class as parameters.
      ⍝ However, that property is not needed any longer (since version 1.6),
      ⍝ and for that reason the argument "debugFlag" is ignored when it is
      ⍝ a string. If it is a Boolean then however it is treated as a debug
      ⍝ flag. It default is 0 but one can specify a 1.
      ⍝
      ⍝ Setting it to 1 has two effects:
      ⍝ * All error trapping is deactivated.
      ⍝ * Instead of signalling an error the program stops.
      Init ⍬
      _debugFlag←{((⊂⍵)∊0 1):⍵ ⋄ 0}debugFlag
      'Invalid parameter: "debugFlag"; not a boolean'⎕SIGNAL 11/⍨∨/~_debugFlag∊0 1
      CallCreate IniFilename
    ∇

    ∇ Init dummy
      ⎕ML←3 ⋄ ⎕IO←1
      _import←0
      _debugFlag←0
      _EN←⍬
      _EstablishedAt←Timestamp2Float ⎕TS
    ∇

    ∇ Create IniFilename;data;allRemarks;import;dm;en;invalid;⎕TRAP;sec
     ⍝ Called by the official constructors
      _changed←_oldStyleFlag←0
      _Sections←''
      ⎕TRAP←(1+_debugFlag)⊃((0 'C' '_EN←⎕en ⋄ (⎕IO⊃⎕DM)⎕signal 911'))((0 1000)'S')
      :If ~0∊⍴_IniFilename←IniFilename
          _IniFilename←CheckExtension¨_IniFilename
          (data _oldStyleFlag allRemarks)←EvaluateINIs _IniFilename
          import←''
          :If 0<+/∨/¨'!Import'∘⍷¨data
              :Trap 911
                  (import data allRemarks)←Import data allRemarks
              :Else
                  ⍎911 Signal⍨1⊃⎕DM
              :EndTrap
          :EndIf
          :Trap 911
              (data locals allRemarks)←GetLocals data allRemarks
          :Else
              ⍎911 Signal⍨1⊃⎕DM
          :EndTrap
          data←{(0∊⍴⍵):⍵ ⋄ ↑,/SortSection¨⍵}SplitSections data
          :If ~0∊⍴import
              (data allRemarks)←MergeImport import data allRemarks
          :EndIf
          :If ~0∊⍴data
              (data allRemarks)←(⊂+\'['=↑¨data)⊂¨data allRemarks
              :If ∨/invalid←(' '∊¨~∘'[]'∘↑¨data)∨¯1=↑∘⎕NC¨~∘'[ ]'∘↑¨data
                  ⍎11 Signal⍨'Invalid section name(s): ',↑{⍺,', ',⍵}/invalid/↑¨data
              :EndIf
          :AndIf ~0∊⍴_Sections←'_',¨∪~∘'[ ]'∘↑¨data
              ⎕NS∘''¨sec←Uppercase _Sections
              (⍎¨sec)._Data←⊂0 5⍴''
              ProcessSections data allRemarks
          :EndIf
      :EndIf
      ⎕DF(⍕⎕THIS),' on <',({0∊⍴⍵:⍵ ⋄ ⊃{⍺,';',⍵}/⍵}_IniFilename),'>'
    ∇

    ∇ ProcessSections(data allRemarks);thisSection;sectionRemarks;this;ref;buffer;TOC;toc
      :For thisSection sectionRemarks :In ↓⍉⊃data allRemarks
          this←'_','[ ]'~⍨1⊃thisSection
          ref←⍎Uppercase this
          ref.generalRemarks←⊂{⍵↓⍨+/∧\' '=⍵}1⊃sectionRemarks
          buffer←{i←⍵⍳'=' ⋄ ((i-1)↑⍵)(i↓⍵)}¨1↓thisSection
          :If OldStyleFlag
          :AndIf ∨/(0<↑∘⍴¨∊¨buffer)∧¯1=↑∘⎕NC¨(↑¨buffer)~¨' '
              ⍎11 Signal⍨'Check value names: ',⊃{⍺,',',⍵}/{(↑¨⍵)/⍨(0<↑∘⍴¨∊¨⍵)∧¯1=↑∘⎕NC¨↑¨⍵}buffer
          :EndIf
          :If ∨/' '∊¨dlb dtb','~¨⍨↑¨buffer
              ⍎11 Signal⍨'Invalid value name(s): ',↑{⍺,', ',⍵}/{⍵/⍨' '∊¨⍵}↑¨buffer
          :EndIf
          toc←' '~¨⍨1⊃¨buffer
          TOC←Uppercase toc
          buffer←2⊃¨{2↑⍵,'' ''}¨buffer
          EstablishValuesInSection(TOC toc buffer)
          :If 0∊⍴ref._Data
              ref.Remarks←''
          :Else
              ref.Remarks←sectionRemarks~⊃,/{2=≡⍵:⍵ ⋄ ⊂⍵}¨ref._Data[;4]
          :EndIf
      :EndFor
    ∇

    ∇ EstablishValuesInSection(TOC toc buffer);i;NAME;name;value;remark;value2;where
      :For i :In ⍳⍴,toc
          (NAME name)←i⊃¨TOC toc
          value←i⊃buffer
          remark←{⍵↓⍨+/∧\' '=⍵}(1+i)⊃sectionRemarks ⍝ first one is the section
          :If 0∊⍴name
              ref._Data⍪←'' '' ''remark''
          :Else
              :If 0∊⍴value
              :AndIf 0=_oldStyleFlag
                  ⍎911 Signal⍨'Invalid line: ',i⊃toc
              :ElseIf ∧/'{}'∊value
              :AndIf ~OldStyleFlag
                  :Trap 0
                      value2←⍎ReplaceCurlies(ref._Data[;5],TOC~¨',')value
                  :Else
                      ⍎911 Signal⍨'Invalid value: ',name
                  :EndTrap
              :Else
                  :If _oldStyleFlag
                      :If ''''∧.=2↑¯1⌽value2←value
                          :Trap 2 11
                              value2←⍎value2
                          :Else
                              ⎕EN ⎕SIGNAL⍨'Invalid definition, check: ',value2
                          :EndTrap
                      :EndIf
                  :Else
                      :Trap 2 11
                          value2←⍎value
                      :Else
                          ⎕EN ⎕SIGNAL⍨'Invalid definition, check: ',value
                      :EndTrap
                  :EndIf
                  :If ~0∊⍴value2
                      ⍎('Invalid definition: ',name)Signal 911/⍨~0 1∊⍨≡value2
                  :EndIf
              :EndIf
              where←ref._Data[;5]⍳⊂NAME~','
              :If where>1⊃⍴ref._Data
                  ref._Data⍪←name value2 value remark NAME
              :ElseIf ','∊name
                  :If 0∊⍴2⊃ref._Data[where;] ⍝ Is it the first time?
                      ref._Data[where;4]←⊂¨ref._Data[where;4]
                      ref._Data[where;3]←⊂''
                  :EndIf
                  ref._Data[where;2]←⊂(2⊃ref._Data[where;]),⊂value2
                  ref._Data[where;3]←⊂(3⊃ref._Data[where;]),⊂value
                  ref._Data[where;4]←⊂(4⊃ref._Data[where;]),⊂remark
              :Else
                  ref._Data[where;2 3 4]←value2 value remark
              :EndIf
          :EndIf
      :EndFor
    ∇

    ∇ r←{type}Convert r;data;thisSection;s;noOf;n;v;rf;allValues;this;theseNames;theseValues;code
      :Access Public
    ⍝ Takes a ref to a (typically empty) namespace and populates it with the values
    ⍝ defined by the INI file entries.
    ⍝
    ⍝ If the optional left argument is "flat", sections are ignored and every entry
    ⍝ gets a simple variable.
    ⍝
    ⍝ If it's not "flat" then section names are used as names for sub-namespaces.
    ⍝
    ⍝ Note that `Convert` will fail if the names used for sections and values
    ⍝ are not proper APL names.
    ⍝
    ⍝ `Convert` injects a method `List` into the resulting namespace which
    ⍝ prints a matrix to the session with all names and values.
      type←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'type'
      ⍎'Left argument must be either empty or "flat"'Signal 11/⍨~(0∊⍴type)∨'flat'≡type
      data←Get ⍬ ⍬
      :If 'flat'≡type
          :If ~0∊⍴data←(0<↑∘⍴¨data[;2])⌿data                ⍝ Isolate pure data
              (theseNames theseValues)←↓⍉data[;2 3]         ⍝ All the names and values
              theseNames r.{⍎⍺,'←⍵'}¨theseValues            ⍝ Assign the values to the names
          :EndIf
          r.⎕FX'r←List;⎕IO;⎕ML' '(⎕IO ⎕ML)←0 3' 'r←{⍵,[.5]⍎¨⍵}⎕nl -2'  ⍝ Establish method "List"
      :Else
          allValues←data[;3]
          :For thisSection :In data[;1]~⊂''                 ⍝ Loop over sections
              s←data[;1]⍳⊂thisSection                       ⍝ Where does the section start?
              :If 0<noOf←{+/∧\0=↑¨⍴¨⍵}s↓data[;1]            ⍝ How many entries has the section?
                  rf←⍎'r.',thisSection,'←⎕NS'''''           ⍝ Create a namespace name after the section
                  rf.⎕DF thisSection                        ⍝ Set the display format
                  theseNames←noOf↑s↓data[;2]                ⍝ All the names and ...
                  theseValues←noOf↑s↓allValues              ⍝ ... values of this section
                  :If ¯1∊↑∘⎕NC¨theseNames
                      ⍎11 Signal⍨'Invalid value name(s): ',{↑{⍺,', ',⍵}/⍵/⍨¯1=↑∘⎕NC¨⍵}theseNames
                  :EndIf
                  theseNames rf.{⍎⍺,'←⍵'}¨theseValues       ⍝ Assign values to names inside that namespace
              :EndIf
          :EndFor
          code←''
          code,←⊂' r←List section;toc;section_U;ind'
          code,←⊂'⍝ If "section" is empty or "*", all sections are returned'
          code,←⊂' ⎕IO←1 ⋄ ⎕ML←3'
          code,←⊂' r←'''''
          code,←⊂' :If (0∊⍴section)∨(,''*'')≡,section'
          code,←⊂'     r←⊃⍪/{⍵,⍵.{{⎕IO←0 ⋄ ⎕ML←3 ⋄ ⍵,[0.5]⍎¨⍵}⎕NL-2}⍵}¨⍎¨⎕NL-9'
          code,←⊂' :Else'
          code,←⊂'     ''Invalid right argument''⎕SIGNAL 11/⍨~(≡section)∊0 1'
          code,←⊂'     toc←⎕NL-9'
          code,←⊂'     section_U←#.APLTreeUtils.Uppercase section'
          code,←⊂'     :If (⊂section_U)∊toc'
          code,←⊂'         ind←toc⍳⊂section_U'
          code,←⊂'         r←{⍵.{{⎕IO←0 ⋄ ⎕ML←3 ⋄ ⍵,[0.5]⍎¨⍵}⎕NL-2}⍵}⍎ind⊃toc'
          code,←⊂'     :EndIf'
          code,←⊂' :EndIf'
          r.⎕FX code                                        ⍝ Establish method "List"
      :EndIf
    ∇

    ∇ r←{default}Get_ name;row;this;ref;subRow;where;thisSection;bool;section;key;SECTION
      :Access Public
      :If 0 1∊⍨≡name
          (section key)←{∨/b←':'=⍵:⍵{((¯1+⍵)↑⍺)(⍵↓⍺)}b⍳1 ⋄ ⍵}name
      :Else
          (section key)←name
      :EndIf
      ⍎'Invalid syntax!'Signal 11/⍨∧/2=¨≡¨section key
      section←{0∊⍴⍵:⍵ ⋄ '_',⍵}section
      :If ⍬≡section
          section←''
      :EndIf
      SECTION←Uppercase section
      :If ((⊂section)∊''⍬)∧(⊂key)∊''⍬
          r←0 3⍴''
          :For thisSection :In _SECTIONS
              r⍪←(⊂1↓thisSection),'' ''
              r⍪←(⊂''),thisSection⍎'_Data[;1 2]'
          :EndFor
      :ElseIf (⊂key)∊''⍬
          :If (1⊃⍴_Sections)≥where←_SECTIONS⍳⊂SECTION
              r←(where⊃_SECTIONS)⍎'_Data[;1 2]'
          :Else
              ⍎6 Signal⍨'Unknown: "',(⍕∊section),'"'
          :EndIf
      :Else
          :If 0∊⍴section
              r←↑⍪/{⍵{(⊂⍺),⍵._Data}⍎⍵}¨_Sections
          :Else
              row←_SECTIONS⍳⊂SECTION
              :If (1⊃⍴_Sections)<row
                  ⍎6 Signal⍨'Unknown section'
              :EndIf
          :EndIf
          this←row⊃_Sections
          ref←⍎row⊃_SECTIONS
          :If 0∊⍴key
              r←ref._Data
          :Else
              key←{0 1∊⍨≡⍵:⊂⍵ ⋄ ⍵}key
              subRow←ref._Data[;5]⍳Uppercase key
              :If ∨/bool←(↑⍴ref._Data)<subRow
                  :If 0=⎕NC'default'
                      :If 0=⎕NC'Default'
                          ⍎6 Signal⍨'Value Error: "',(⊃{⍺,',',⍵}/bool/key),'"'
                      :Else
                          :Trap 6
                              r←(ref._Data[;2],⊂Default)[subRow]
                          :Else
                              ⍎(1⊃⎕DM)Signal ⎕EN
                          :EndTrap
                      :EndIf
                  :Else
                      r←(ref._Data[;2],⊂default)[subRow]
                  :EndIf
              :Else
                  r←ref._Data[subRow;2]
              :EndIf
          :EndIf
      :EndIf
      :If 2=⍴⍴r
          :Select 2⊃⍴r
          :Case 2
              r⌿⍨←0<↑∘⍴¨r[;1]
          :Case 3
              r⌿⍨←0∨.≠⍨↑∘⍴¨r
          :EndSelect
      :EndIf
    ∇

    ∇ r←{default}Get name
    ⍝ Returns the (enclosed) value for a single value or a vector of values
    ⍝ if more than one key was provided.
    ⍝
    ⍝ `name` might be one of:
    ⍝ * `('sectionName' 'key')`
    ⍝ * `(('sectionName' 'key1')('sectionName' 'key2'))`
    ⍝ * `'sectionName:key'`
    ⍝ * `('sectionName:key1' 'sectionName:key2')`
    ⍝
    ⍝ Note that mixed syntax is not supported:
    ⍝
    ⍝ ~~~
    ⍝ ('sectionName' ('key1' 'key2')) ⍝  invalid!
    ⍝ ('sectionName' 'key1') 'sectionName:key2' ⍝  invalid!
    ⍝ ~~~
    ⍝ If "key" is empty, **all** values of that sections are returned.
    ⍝
    ⍝ If a requested value is not available, "default" (the left argument)
    ⍝ is returned if specified, otherwise the property "Default" is returned
    ⍝ if specified; otherwise an interrupt is signalled.
      :Access Public
      :If 0=⎕NC'default'
          r←Get_ name
      :Else
          r←default Get_ name
      :EndIf
    ∇

    ∇ {r}←data Put name
    ⍝ Set `name` to `data`.
    ⍝
    ⍝ Note that `name` can be:
    ⍝ * A simple string. Must provide both, a "section" and a `name`,
    ⍝   separated by a colon as in "section:key"
    ⍝ * A nested vector of length 2.
    ⍝
    ⍝ Examples for the latter:
    ⍝ ~~~
    ⍝ `1⊃name ←→ section name`
    ⍝ `2⊃name ←→ key (or entry name)`
    ⍝ ~~~
      :Access Public
      r←⍬
      data Put_ name
    ∇

    ∇ data Put_ name;key;SECTION;where;ref;KEYS;buffer;KEY;toc;section;key
      :If 0 1∊⍨≡name
          ⍎'Must be specified as "sectionName:key"'Signal 11/⍨~':'∊name
          (section key)←{a←⍵⍳':' ⋄ (⍵↑⍨a-1)(a↓⍵)}name
      :Else
          (section key)←name
      :EndIf
      section←'_',section
      (SECTION KEY)←Uppercase(section key)
      :If (⊂SECTION)∊_SECTIONS
          where←_SECTIONS⍳⊂SECTION
      :Else
          _Sections,←⊂section
          _SECTIONS,←⊂Uppercase section
          where←⍴_Sections
      :EndIf
      :If 9=⎕NC where⊃_SECTIONS
          ref←⍎SECTION
      :Else
          ⍎6 Signal⍨'Unkown section; (consider executing "AddSection")'
      :EndIf
      KEYS←ref._Data[;5]
      :If (⎕DR data)∊11 83 645
          buffer←data(⍕data)
      :Else
          :If 2=≡data
              buffer←({ReplaceCurlies KEYS ⍵}¨data)({'''',⍵,''''}¨,data)
          :Else
              buffer←(ReplaceCurlies KEYS data)('''',data,'''')
          :EndIf
      :EndIf
      :If (⊂KEY)∊KEYS
          where←KEYS⍳⊂KEY
          :If ~_changed
              _changed←data≢2⊃ref._Data[where;]
          :EndIf
          ref._Data[where;2 3]←buffer
      :Else
          ref._Data⍪←(⊂key),buffer,(⊂''),⊂Uppercase key
      :EndIf
    ∇

    ∇ {r}←Delete name;section;key;ref;bool;this;TOC
      :Access Public
    ⍝ Delete a key or a section. Returns 1 if there was something to delete.
    ⍝
    ⍝ To delete "myKey" from "MySection":
    ⍝ ~~~
    ⍝ `('MySection' 'MyKey')`
    ⍝ ~~~
    ⍝ "name" can also be a nested vector:
    ⍝ ~~~
    ⍝ `(('SectionA' 'key1') ('SectionA' 'key2'))`
    ⍝ ~~~
    ⍝ or a full name like:
    ⍝ ~~~
    ⍝ `('section:key') or (('section:key1') ('section:key1'))`
    ⍝ ~~~
    ⍝ Note that `('section' ('key1' 'key2'))` is **not** a valid syntax.
    ⍝
    ⍝ To delete an entire section:
    ⍝ ~~~
    ⍝ `Delete 'foo:'`
    ⍝ ~~~
    ⍝ If `name` is a vector of names, `Delete` calls itself recursively.
    ⍝ Mixed syntax is **not** supported, so use one of:
    ⍝ ~~~
    ⍝ Delete ('sectiona' 'key1')('otherSection' 'key2')('thirdSection' '')
    ⍝ Delete ('sectiona:key1' 'otherSection:key2' 'thirdSection:')
    ⍝ ~~~
      r←0
      :If 0 1∊⍨≡name
          ⍎'Invalid right argument'Signal 11/⍨1≠':'+.=name
          (section key)←' '~¨⍨2↑Uppercase{⍵⊂⍨':'≠⍵}name
          section←'_',section
          :If 0∊⍴key
              :If 9=⎕NC section
                  ⎕EX section
                  _Sections←(_SECTIONS≢¨⊂section)/_Sections
                  r←_changed←1
              :EndIf
          :Else
              ⍝key←{⍵∧.=' ':'' ⋄ ⍵}key
              (section key)←Uppercase{⍵⊂⍨':'≠⍵}name
              section←'_',section
              :If (⊂section)∊_SECTIONS
                  TOC←{⍵._Data[;5]}ref←⍎section
              :AndIf r←0<+/bool←(⊂key)≡¨TOC
                  ref._Data⌿⍨←~bool
                  r←_changed←1
              :EndIf
          :EndIf
      :Else
          :If 0 1∊⍨≡2⊃name
              :If 2=≡name
              :AndIf ~':'∊1⊃,name
                  r←Delete⊃{⍺,':',⍵}/name
              :Else
                  r←Delete¨name
              :EndIf
          :Else
              :If 3=≡name
              :AndIf 1 2≡≡¨name
                  r←Delete¨(⊂name[1]),¨⊂¨2⊃name
              :Else
                  r←⍬
                  :For this :In name
                      r,←Delete this
                  :EndFor
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←Exist name;section;key;ref;this
      :Access Public
    ⍝ Returns 1 if `name` exists. `name` can be either a nested vector like
    ⍝ ~~~
    ⍝ ('Section' 'key')
    ⍝ ~~~
    ⍝ or
    ⍝ ~~~
    ⍝ (('Section' 'key1') ('Section' 'key2'))
    ⍝ ~~~
    ⍝ or a full name like
    ⍝ ~~~
    ⍝ ('section:key')
    ⍝ ~~~
    ⍝  or
    ⍝ ~~~
    ⍝ (('section:key1') ('section:key1'))
    ⍝ ~~~
    ⍝ Note that `('section' ('key1' 'key2'))` is **not** a valid syntax.
    ⍝
    ⍝ To check the existence of a section use
    ⍝ ~~~
    ⍝ Exist 'foo:'
    ⍝ ~~~
    ⍝ If `name` is a vector of names, `Exist` calls itself recursively.
    ⍝
    ⍝ Mixed syntax is **not** supported, so use one of:
    ⍝ ~~~
    ⍝ Exist ('section' 'key1')('otherSection' 'key2')('thirdSection' '')
    ⍝ Exist ('section:key1' 'otherSection:key2' 'thirdSection:')
    ⍝ ~~~
      :If 0 1∊⍨≡name
          (section key)←' '~¨⍨Uppercase 2↑{⍵⊂⍨':'≠⍵}name
          section←'_',section
          :If 0∊⍴key
              r←↑9=⎕NC section
          :Else
              key←{⍵∧.=' ':'' ⋄ ⍵}key
              :If 0∊⍴key
                  r←(⊂section)∊_SECTIONS
              :Else
                  :If r←(⊂section)∊_SECTIONS
                      ref←⍎section
                      r←(⊂key)∊ref._Data[;5]
                  :EndIf
              :EndIf
          :EndIf
      :Else
          :If ∧/':'∊¨name
              r←Exist¨name
          :Else
              :If 3=≡name
                  ⍎'Mixed syntax not eligible'Signal 11/⍨(∨/':'∊¨name)∧(∨/2=≡¨name)
                  r←Exist¨name
              :Else
                  r←Exist⊃{⍺,':',⍵}/name
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ {r}←AddSection name;NAME;ref
 ⍝ Adds a new section to the INI file.
 ⍝
 ⍝ Return a 1 if a section was added. A 0 is rerturned in case the section already exists.
      :Access Public
      NAME←Uppercase name←'_',name
      ⍎'Section name must be a valid APL name'Signal 11/⍨¯1=⎕NC NAME
      :If r←0=⎕NC NAME
          NAME ⎕NS''
          ref←⍎NAME
          ref._Data←0 5⍴''
          _Sections,←⊂NAME
          _changed←1
      :EndIf
    ∇

    ∇ boolean←HasInifileChanged;ts
   ⍝ Returns a 1 in case the (any) ini file has changed since the instance was created.
      :Access Public Instance
      ts←{⊃3 ⎕NINFO ⍵}¨_IniFilename
      boolean←_EstablishedAt∨.<Timestamp2Float¨ts
    ∇

    ∇ {oldFilename}←Save filename;thisSection;thisKey;thisData;ref;buffer;origValue;THISSECTION;thisRemark;data;bool;where;i;this;thisKEY
      :Access Public
    ⍝ If `filename` is empty the INI is saved into the same file it originally came from.
    ⍝
    ⍝ Note that `Save` will throw a SYNTAX ERROR in case...
    ⍝ * the instance was defined by more than one INI file.
    ⍝ * another INI file was imported.
      ⍎'An INI file with !Import statement cannot be saved'Signal 11/⍨_import
      :If 1<⍴_IniFilename
          ⍎11 Signal⍨'This INI instance was defined by more than one INI file; it therefore cannot be saved.'
      :EndIf
      oldFilename←_IniFilename
      :If ~0∊⍴filename
          _IniFilename←,⊂filename
      :EndIf
      _IniFilename←CheckExtension¨_IniFilename
      :If 0=⎕NC'locals'
      :OrIf 0∊⍴locals
          data←''
      :Else
          bool←∧\0=↑∘⍴¨locals[;1]
          data←'; '∘,¨{⍵↓¨⍨+/∧\' '=⊃⍵}⊃¨bool⌿locals[;4]
          :For thisKey thisData origValue thisRemark thisKEY :In ↓(~bool)⌿locals
              buffer←(thisKey{0∊⍴⍺:⍺ ⋄ ⍺,⍵}'='),{0=1↑0⍴⍵:⍕⍵ ⋄ '''',(DoubleQuotes ⍵),''''}thisData
              :If ~0∊⍴thisRemark
                  :If ''''''≡buffer
                      buffer←thisKey{⍵,⍨(~0∊⍴⍺)/(⎕UCS 9)}'; ',thisRemark
                  :Else
                      buffer,←thisKey{⍵,⍨(~0∊⍴⍺)/(⎕UCS 9)}'; ',thisRemark
                  :EndIf
              :EndIf
              data,←⊂buffer
          :EndFor
      :EndIf
      :For thisSection :In _Sections
          thisSection←1↓thisSection
          THISSECTION←Uppercase thisSection
          ref←⍎'_',THISSECTION
          :If 0=⎕NC'ref.generalRemarks'  ⍝ might not exist if the original filename was empty
              data,←⊂'[',THISSECTION,']'
          :Else
              data,←⊂'[',(THISSECTION),']',{⍵,⍨(~0∊⍴⍵)/(⎕UCS 9),'; '}1⊃1↑ref.generalRemarks
              data,←{⍵,⍨(~0∊⍴⍵)/'; '}¨1↓ref.generalRemarks
          :EndIf
          :For thisKey thisData origValue thisRemark :In ↓4↑[2]ref._Data
              buffer←''
              :If 0 1∊⍨≡thisData
                  :If '{'∊origValue
                      buffer←thisKey,'=''',(DoubleQuotes⍎origValue),''''
                  :Else
                      :If ''''''≡buffer←(thisKey{0∊⍴⍺:⍺ ⋄ ⍺,⍵}'='),{0=1↑0⍴⍵:⍕⍵ ⋄ '''',(DoubleQuotes ⍵),''''}thisData
                          buffer←''
                      :EndIf
                  :EndIf
                  :If ~0∊⍴thisRemark
                      buffer,←thisKey{⍵,⍨(~0∊⍴⍺)/(⎕UCS 9)}'; ',thisRemark
                  :EndIf
                  data,←⊂buffer
              :Else
                  buffer←(⊂thisKey,'='''''),(⊂thisKey,',='),¨{0=1↑0⍴⍵:⍕⍵ ⋄ '''',(DoubleQuotes ⍵),''''}¨⍎¨origValue
                  :If ~0∊⍴thisRemark
                      buffer,¨←{⍵,⍨(~0∊⍴⍵)/(⎕UCS 9),'; '}¨thisRemark
                  :EndIf
                  data,←buffer
              :EndIf
          :EndFor
      :EndFor
      bool←(';'≠↑¨1⍴¨data)∧(⎕UCS 9)∊¨data
      where←bool\{⍵⍳(⎕UCS 9)}¨bool/data
      buffer←(⎕UCS 9)⍴¨⍨{⍵-⍨⌈/1+⍵}⌊4÷⍨↑∘⍴¨(where-1)↑¨data
      :For i :In ⍳⍴,data
          :If i⊃bool
              this←i⊃data
              this[where[i]]←⊂i⊃buffer
              this←∊this
              (i⊃data)←this
          :EndIf
      :EndFor
      WriteUtf8File(1⊃_IniFilename)data
    ∇

    ∇ {r}←DeleteDefault
    ⍝ As soon as the `Default` property is set, one can get rid of it only be calling
    ⍝ this method. Returns a 1 if there was a default, otherwise 0.
      :Access Public
      r←2=⎕NC'_default'
      ⎕EX'_default'
    ∇

    ∇ r←Help
      :Access Public shared
      r←''
      r,←⊂'To provide a list of methods and properties use'
      r,←⊂'  ]ADOC.List ',⍕⎕THIS
      r,←⊂'To provide a full list of methods and properties use'
      r,←⊂'  ''full'' ]ADOC.List ',⍕⎕THIS
      r,←⊂'To provide more details about methods and properties use'
      r,←⊂'  ]ADOC.Browse ',⍕⎕THIS
      r,←⊂'If the User Command ]ADOC is not available on your system:'
      r,←⊂'http://aplwiki.com/ADOC'
      r,←⊂'To provide a fully-fledged documentation visit:'
      r,←⊂'http://aplwiki.com/IniFiles'
      r←⊃r
    ∇

      fixkeys←{0 1∊⍨≡⍵:,⊂⍵
          ⍵}

    IsChar←{0 2∊⍨10|⎕DR ⍵}

    ∇ r←{extension}CheckExtension r
    ⍝ Add extension if there is no extension. Default is "ini"
      extension←{2=⎕NC ⍵:⍎⍵ ⋄ 'ini'}'extension'
      r←r,(~'.'∊{⍵↑⍨-⌊/'\/'⍳⍨⌽⍵}r)/'.',extension
    ∇

    ∇ r←_SECTIONS
      r←Uppercase _Sections
    ∇

    ∇ value←ReplaceCurlies(toc value);bool;val2;where;name;names;noOf
    ⍝ Replace `{foo}` with real data, if there are any curlies.
      value←ExchangeDoubleCourlies value'{'(⎕UCS 0)
      value←ExchangeDoubleCourlies value'}'(⎕UCS 1)
      :If ∧/'{}'∊value
          bool←{{⍵∨≠\⍵}⍵∊'{}'}value
          names←Uppercase bool/value
          names←'}'~⍨¨'{'Split names
          names←(0<↑∘⍴¨names)/names
          :For name :In names
              :Trap 0
                  where←toc⍳⊂name
                  :If (⍴toc)∨.<where
                      where←(Uppercase locals[;1])⍳⊂name
                      ⍎('Invalid references found in INI file, check "',name,'"')Signal 6/⍨where∨.>1⊃⍴locals
                      val2←DoubleQuotes⊃locals[where;2]
                  :Else
                      val2←DoubleQuotes 2⊃ref._Data[where;]
                  :EndIf
              :Else
                  ⍎6 Signal⍨'Invalid references found in INI file, check "',name,'"'
              :EndTrap
              noOf←¯1+value⍳'{'
              value←(-noOf)⌽(⍕val2),({⍵↓⍨⍵⍳'}'}noOf⌽value)
          :EndFor
          value←'''',(1↓¯1↓value),''''
      :EndIf
      value←RestoreCurlies value
    ∇

      DoubleQuotes←{
          1<≡⍵:∇¨⍵
          ∨/b←''''=⍵:b{w←⍵ ⋄ (b/w)←⊂'''''' ⋄ ∊w}⍵
          ⍵
      }
    ∇ (data locals allRemarks)←GetLocals(data allRemarks);where;toc;i;name;value;remark;data2;allRemarks2;value2;itemNo;ref;NAME
    ⍝ Extract any "local" variabels.
    ⍝ Locals are defined as those assigned above the first section
      locals←0 5⍴''                                     ⍝ Initialize the main result
      :If '['∊↑¨data
          :If 0<where←¯1+'['⍳⍨↑¨data                    ⍝ Where starts the first section
              data2←where↑data                          ⍝ Take eveything above the first section
              data2←(+/∧\' '=⊃data2)↓¨data2             ⍝ Drop any leading blanks
              data2/⍨←'!Import'{((⍴⍺)↑[2]⊃⍵)∨.≠⍺}data2  ⍝ Remove all "!Import" directives
              data2←'='Split¨data2                      ⍝ Split remaining items at "=" (assignment)
              toc←' '~¨⍨1⊃¨data2                        ⍝ First part = names
              data2←2⊃¨{2↑⍵,'' ''}¨data2                ⍝ Second part = data
              allRemarks2←where↑allRemarks              ⍝
              :For i :In ⍳⍴,toc
                  name←i⊃toc
                  value←i⊃data2
                  remark←i⊃allRemarks2
                  :If 0∊⍴name
                      locals⍪←'' '' ''remark''
                  :Else
                      :If ∧/'{}'∊value
                          value2←⍎ReplaceCurlies((Uppercase toc)value)
                      :Else
                          :If _oldStyleFlag
                              value2←value
                              value←'''',value,''''
                          :Else
                              value2←⍎value
                          :EndIf
                      :EndIf
                      itemNo←locals[;5]⍳⊂NAME←Uppercase name~','
                      :If itemNo>1⊃⍴locals
                          locals⍪←name value2 value remark NAME
                      :ElseIf ','∊name
                          ⍎911 Signal⍨'Invalid syntax: nested values are not supported for "local" variables'
                      :Else
                          locals[itemNo;2 3 4]←value2 value remark
                      :EndIf
                  :EndIf
              :EndFor
              locals[;4]←{2=≡⍵:⊃,/⍵ ⋄ ⍵}¨locals[;4]
              data←where↓data
              allRemarks←where↓allRemarks
          :EndIf
      :EndIf
    ∇

    ∇ r←name Process value;depth;buff;thisVal;i
    ⍝ Assign values to names
      depth←≡value
      :If depth∊0 1             ⍝ It's simple
          r←value
      :Else                     ⍝ It's nested!
          buff←''
          :For i :In ⍳⍴,value
              thisVal←i⊃value
              :If 0=1↑0⍴thisVal
                  buff,←',(⊂',(⍕thisVal),')'
              :Else
                  buff,←',(⊂''',(DoubleQuotes thisVal),''')'
              :EndIf
          :EndFor
          r←⍎buff
      :EndIf
    ∇

    ∇ (oldStyleFlag DM EN)←CheckValues(data filename);vals;f;emptyFlag;swq;ewq;iv;in;b;tq;bool;lnos
     ⍝ Returns either ({boolean} '' ⍬) or ({Boolean} 'Error msg' {number}) with
     ⍝ Boolean being OldStyleFlag.
     ⍝
     ⍝ Therefore the result can be used for a ⎕SIGNAL statement.
     ⍝
     ⍝ We don't have to worry about comments and trailing blanks: handled by now.
     ⍝
     ⍝ Side effect: sets global /_oldStyleFlag
      (oldStyleFlag DM EN)←¯1 '' 0      ⍝ ¯1: not decided yet. As soon it is something else the case is settled
      bool←0<↑∘⍴¨dlb data
      lnos←bool/⍳⍴data                  ⍝ Create line numbers
      data←bool/data                    ⍝ Drop empty lines
      bool←';'≠↑¨data                   ⍝ Pure comment lines
      (data lnos)←bool∘/¨data lnos      ⍝ Get rid of all comment lines from data & lnos
      :If ∨/b←'!'=↑¨data
      :AndIf ∨/b←b\'!IMPORT'∘{⍺≡Uppercase(⍴⍺)↑⍵}¨b/data
          oldStyleFlag←0                ⍝ Now we know it's not an old-style file.
          (data lnos)←(⊂~b)/¨data lnos
      :EndIf
      :If ¯1=oldStyleFlag
      :AndIf ~0∊⍴(¯1+(↑¨data)⍳'[')↑data ⍝ Local variables?!
          oldStyleFlag←0                ⍝ Now we know it's not an old-style file.
          bool←~∧\'['≠↑¨data            ⍝ Where does the real stuff starts (first section)?
          (data lnos)←bool∘/¨data lnos  ⍝ Remove the local variables
      :EndIf
      bool←'['≠↑¨data                   ⍝ Which are not sections?
      (data lnos)←bool∘/¨data lnos      ⍝ Get rid of them
      :If ∨/b←~'='∊¨{⍵↑⍨¯1+⍵⍳''''}data
          DM←'Check line',((1≠+/b)/'s'),' ',(↑{⍺,',',⍵}/⍕¨b/lnos),' of ',filename
          EN←11
          :Return
      :EndIf
      vals←dlb{⍵↓⍨⍵⍳'='}¨data           ⍝ Remove the assigment as such.
      swq←''''=↑¨vals                   ⍝ Start With Quote
      ewq←''''=↑¨¯1⌽¨vals               ⍝ Ends with quotes
      in←{∧/{⍵↑⍨1⌈⍴⍵}1⊃⎕VFI ⍵}¨vals     ⍝ "Is Numeric" flag
      emptyFlag←0=↑∘⍴¨vals              ⍝ Empty is allowed only in old-style
      :If ¯1=oldStyleFlag
          :If 2=⍴∪(~in)/swq+ewq
              DM←filename,' is inconsistent - neither old-style nor new-style; check line(s) ',⍕Where bool\in⍱swq∧ewq
              EN←11
              :Return
          :Else
              oldStyleFlag←~(0∊⍴data)∨∧/in∨2=swq+ewq   ⍝ Locals only? All fine?!
          :EndIf
      :EndIf
      :If ¯1=oldStyleFlag
          oldStyleFlag←0                ⍝ We don't know otherwise, so we assume "no"
      :EndIf
      :If oldStyleFlag
          :If ∨/b←~(swq+ewq)∊0 2
              DM←filename,' is invalid: ',↑,/{⍺,',',⍵}/b/data~¨'''' ⋄ EN←11
          :EndIf
      :Else
          :If ∨/b←(~in)∧2≠swq+ewq
              DM←filename,' is inconsistent: ',↑,/{⍺,',',⍵}/b/data ⋄ EN←11
          :ElseIf ∨/emptyFlag
              DM←filename,' is inconsistent: ',↑,/{⍺,',',⍵}/emptyFlag/data ⋄ EN←11
          :EndIf
      :EndIf
    ∇

      RemoveInBetweenBlanks←{
      ⍝ Remove all "in-between" blanks from names.
          s←⍵
          (0=↑∘⍴s):s                            ⍝ Empty? Ignore!
          ((1↑s)∊';!['):s
          (~'='∊⍵):⍵
          where←⍵⍳'='
          name←⍵↑⍨¯1+where
          name←({~(∧\⍵)∨⌽∧\⌽⍵}name=' ')/name
          val←where↓⍵
          name,'=',({~(∧\⍵)∨⌽∧\⌽⍵}val=' ')/val
      }

    ∇ (data remarks)←MergeImport(import data remarks);value;section;secName;secList;ind;name
      data←{(+\'['=↑¨⍵)⊂⍵}data
      secList←↑¨data
      :For section name value :In ↓import
          secName←'[',(⍕section),']'
          :If (⍴secList)<ind←secList⍳⊂secName
              data,←⊂⊂secName
              secList,←⊂secName
              remarks,←⊂''
          :EndIf
          ind←secList⍳⊂secName
          :If 2=≡value
              (ind⊃data),←⊂name,'='''''
              (ind⊃data),←(⊂name,',='),¨Pack¨value
          :Else
              (ind⊃data),←⊂name,'=',Pack value
          :EndIf
      :EndFor
      data←↑,/SortSection¨data
      remarks←(⍴data)↑remarks,(⍴data)⍴⊂''
    ∇

      Pack←{
          (0=1↑0⍴⍵):⍕⍵
          '''',⍵,''''
      }

      SortSection←{
          (0 1∊⍨⍴,⍵):⍵
          (⍵[1]),{⍵[⍋'{'∊¨⍵]}1↓⍵
      }

    SplitSections←{(+\'['=↑¨⍵)⊂⍵}

    ∇ r←ExchangeDoubleCourlies(r what new);b;ind
    ⍝ Typical:
    ⍝ data ← RestoreCurlies ExchangeDoubleCourlies '{{abc}}' '{' (⎕UCS 0)
    ⍝ data ← RestoreCurlies ExchangeDoubleCourlies data '}' (⎕UCS 1)
    ⍝ '{abc}' ←→ RestoreCurlies data
      :While ∨/b←(2⍴what)⍷r
          ind←↑Where b
          r←(-ind-1)⌽new,2↓(ind-1)⌽r
      :EndWhile
    ∇

      RestoreCurlies←{
          r←⍵
          b←r=⎕UCS 0
          (b/r)←'{'
          b←r=⎕UCS 1
          (b/r)←'}'
          r
      }

    ∇ (data oldStyleFlag remarks)←EvaluateINIs filenames;dm;en;this;buffer;buffer2;bool;flag;remarks2
      data←'' ⋄ oldStyleFlag←⍬ ⋄ remarks←''
      :For this :In filenames
          :If 0∊⍴buffer←ReadUtf8File this
              :Return
          :EndIf
          buffer←(,∘⊂⍣(↑1=≡buffer))buffer
          buffer←{(0=+/b←(⎕UCS 9)=w←⍵):w ⋄ (b/w)←' ' ⋄ w}¨buffer    ⍝ Transform TAB into blanks
          buffer~¨←⎕UCS 10                                          ⍝ Remove any LF characters
          buffer←{0 1∊⍨≡⍵:⊂⍵ ⋄ ⍵}buffer
         ⍝buffer←{(0<∊⍴∘,¨⍵)⌿⍵}buffer  ⍝ No: in order to report line numbers we can't do this
          buffer2←⊃,buffer
          bool←{a∨≠\a←⍵=''''}buffer2
          ((,bool)/,buffer2)←' '
          remarks2←(';'⍳⍨¨⊂[2]buffer2)↓¨buffer
          buffer←(¯1+';'⍳⍨¨⊂[2]buffer2)↑¨buffer
          buffer←RemoveInBetweenBlanks¨dlb dtb buffer
          (flag dm en)←CheckValues buffer this
          ⍎dm Signal en
          data,←buffer
          remarks,←remarks2
          oldStyleFlag,←flag
      :EndFor
      oldStyleFlag←∨/oldStyleFlag
    ∇

    ∇ r←GetRefToUtils
      r←⍎⎕IO⊃'.'Split dlb⍕⎕IO⊃⎕CLASS ⎕THIS
    ∇

    ∇ CallCreate IniFilename
      :If 0 1∊⍨≡IniFilename
      :AndIf ~0∊⍴IniFilename
          IniFilename←,⊂IniFilename
      :EndIf
      :Trap (~_debugFlag)/911
          Create IniFilename
      :Else
          ⍎({(911≡⍵)∨⍬≡⍵:11 ⋄ ⍵}_EN)Signal⍨1⊃⎕DM
      :EndTrap
    ∇

      Signal←{
          dm←⍺
          en←⍵
          (0∊⍴en):''
          (0=en):''
          debugFlag←{(0<⎕NC ⍵):⍎⍵ ⋄ 0}'_debugFlag'
          debugFlag:en{⎕←⍵ ⋄ ⎕←⍺ ⋄ '.'}dm
          '''',({⍵↑⍨255⌊⍴,⍵}DoubleQuotes dm),''' ⎕SIGNAL ',⍕en
      }

    ∇ r←GetComputerName
      r←2 ⎕NQ'#' 'GetEnvironment' 'Computername'
    ∇

    ∇ r←Timestamp2Float ts
    ⍝ yyyymmdd.hhmmss←Timestamp2Float ⎕TS
      r←{1E¯9×0 100 100 100 100 100 1000⊥7↑⍵}ts
    ∇

    ∇ r←Float2Timestamp float
    ⍝ yyyy mm dd hh mm ss←Float2Timestamp yyyymmdd.hhmmss
      r←⌊0 100 100 100 100 100 1000⊤float×10*9
    ∇

      DoubleCurlies←{
          (~'{'∊r←⍵):r
          (('{'=r)/r)←⊂'{{'
          r←↑,/r
          (('}'=r)/r)←⊂'}}'
          ↑,/r
      }

:EndClass
