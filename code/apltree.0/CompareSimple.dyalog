:Class CompareSimple
⍝ <h2>Overview</h2>

⍝ <h3>Comparing
⍝ "CompareSimple" offers a bunch of shared methods helpful to compare _
⍝ functions, operators and scripts. Sources of those objects may by in _
⍝ the current workspace or on file (SALT/script files).

⍝ <h2>Preconditions</h2>
⍝ "CompareSimple" needs the scripted namespace `APLTreeUtils`.
⍝ It expects `APLTreeUtils` at the same level "Compare" itself is situated.

⍝ <h2>Comparing</h2>
⍝ The actual comparison can be done by one of:
⍝ * "CompareIt!" (commercially available: http://aplwiki.com/CompareIt)
⍝ * "Beyond Compare" (commercially available: www.scootersoftware.com)
⍝ In order to find the compare utility you must specify one or both of:
⍝ * `pathToCompareIt`
⍝ * `pathToBeyondCompare`
⍝ If only one of them is set it is obvious which tool to use. If you set _
⍝ both you <b>must</b> also set "CompareTool" to either "CompareIt!" _
⍝ or "BeyondCompare", otherwise an error is thrown.

⍝ <h2>Features</h2>
⍝ `CompareSimple` offers just methods to...
⍝ * compare an APL object with a file.
⍝ * compare two files.
⍝ * create a DIFF report with CompareIt!.

⍝ <h2>Compare versus CompareSimple
⍝ `Compare` is a superset of `CompareSimple`. _
⍝ Compare offers much more features but is also much bigger and more _
⍝ complicated. If CompareSimple suits your needs, take it. If _
⍝ not then have a look at `Compare`.
⍝ Refer to http://aplwiki.com/Compare for details

⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/CompareSimple

    ⎕IO←1 ⋄ ⎕ML←3

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public shared
      r←('.'Last⍕⎕THIS)'1.7.0' '2015-01-09'
      ⍝ 1.7.0  * Uses ticks (`) now for marking up ADOCable APL inline code.
      ⍝        * `Version` just returns "CompareSimple" now (not path).
    ∇

    :Field Public Shared regPathToCompareIt←'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Compare It!_is1\InstallLocation' ⍝ Where to start "CompareIt!" from
    :Field Public Shared regPathToBeyondCompare←'HKEY_LOCAL_MACHINE\SOFTWARE\Classes\BeyondCompare.SettingsPackage\shell\open\command'
    :Field Public Shared regPath←'HKEY_CURRENT_USER\Software\APLTree\Compare\'

    :Property compareTool
    :Access Public Shared
        ∇ r←get
          r←{6::'' ⋄ ⍎⍵}'_compareTool'
        ∇
        ∇ set arg
          ⎕SIGNAL 11/⍨~(⊂arg.NewValue)∊'CompareIt!' 'BeyondCompare' ''
          _compareTool←arg.NewValue
        ∇
    :EndProperty

    :Property pathToCompareIt
    :Access Public Shared
        ∇ r←get
          r←{6::'' ⋄ ⍎⍵}'_pathToCompareIt'
        ∇
        ∇ set arg
          _pathToCompareIt←arg.NewValue
          refToUtils.WinReg.PutString(regPath,'\PathToCompareIt!')_pathToCompareIt
        ∇
    :EndProperty

    :Property pathToBeyondCompare
    :Access Public Shared
        ∇ r←get
          r←{6::'' ⋄ ⍎⍵}'_pathToBeyondCompare'
        ∇
        ∇ set arg
          _pathToBeyondCompare←arg.NewValue
          refToUtils.WinReg.PutString(regPath,'\PathToBeyondCompare')_pathToBeyondCompare
        ∇
    :EndProperty

    :Property refToUtils
    :Access Public Shared
        ∇ r←get
          r←{0::## ⋄ _refToUtils}⍬
        ∇
        ∇ set arg
          _refToUtils←arg.NewValue
        ∇
    :EndProperty

    ∇ filename←WriteAplObjToFile aplObjName;errMsg;body
      :Access Public Shared
    ⍝ "aplObjName" is written to a temp file. "aplObjName" may be one of:
    ⍝ * Function name (trad or direct)
    ⍝ * Operator name (trad or direct)
    ⍝ * Script (class, interface, namespace) by name or by reference.
      aplObjName←⍕aplObjName ⍝ just in case it is a ref
      errMsg←'Right argument seems not to be one of: APL fns/opr/class/interface/scripted namespace'
      errMsg ⎕SIGNAL 11/⍨~((2=⎕NC'body')∧0=⎕NC aplObjName)∨(⎕NC⊂aplObjName)∊3.1 3.2 3.3 4.1 4.2 9.4 9.5 9.1
      errMsg ⎕SIGNAL 11/⍨~3 4 9∊⍨⎕NC⍕aplObjName
      body←{9=⎕NC ⍵:⎕SRC⍎⍵ ⋄ ⎕NR ⍵}aplObjName
      filename←WriteToFile⍕¨body  ⍝ The "⍕" is needed for idioms/assigned fns/opr
    ∇

    ∇ filename←WriteToFile text;errMsg
      :Access Public Shared
    ⍝ "text" is written to a temp file.
    ⍝ The name of the temp file is returned as the result and is build _
    ⍝ up from the current time, the current user and the extension ".txt". _
    ⍝ It's situated in the Windows temp dir.
    ⍝ Use this to write APL code to a file.
      filename←refToUtils.WinFile.GetTempPath,(' '~⍨⍕⎕TS),(⍕?1000),'_',⎕AN,'.dyalog'
      WriteUtf8File filename text
    ∇

    ∇ r←CreateParmsFor_These
      :Access Public Shared
      ⍝ Create a command space with the default settings of "These"
      r←⎕NS''
      r.readOnly1←0
      r.readOnly2←0
      r.refToAcreInstance←FindAcreInstance
      r.alias1←''
      r.alias2←''
      r.refToUtils←{0::## ⋄ _refToUtils}⍬
      r.reportFile←''
      r.converter←''
      r.componentNo←⍬
      r.acreFlag←0
      r.⎕FX'r←List;⎕io' '⎕IO←⎕ML←0' 'r←{(⍵,[.5]⎕nc¨⊂¨⍵),⍎¨⍵}(⊂''List'')~⍨⎕NL-2 9 3' ⍝ Vars, refs and niladic functions
    ∇

    ∇ {changeFlag}←{parms}These y;ref1;ref2;b;l;compNo2;ref1IsRef;ref2IsRef;ref2Is_FN;ref1Is_FN;temp_FN1;compNo1;isSalt1;isSalt2;FN_1;fno1;range1;dates1;temp_FN2;buffer;ref1IsDcf;FN_2;fno2;range2;dates2;ref2IsDcf;file1;file2;saveDel1;saveDel2;body;bodies;lineNo;res;rc;G;cmd;f
      :Access Public Shared
          ⍝ Compare two "things" with each other.
          ⍝ Syntax I.: (ref1 [ref2])←y
          ⍝ Syntax II.: (name1 [name2])←y
          ⍝ Syntax III.: (name ["file://",filename])←y
          ⍝ Syntax IV.: Just one name or one ref ([2] is then SALT_Data or acre file)
          ⍝ Note that any references must point to scripts. "These" cannot deal with _
          ⍝ ordinary namespaces (refs or names, it doesn't matter); see `Compare.Merge` _
          ⍝ for this.
          ⍝ Compares y[1] with y[2].
          ⍝ If y[2] is omitted, y[1] is compared with y[1].(∆|SALT_Data).SourceFile. _
          ⍝ That means that in this special case y[1] <b>must</b> be a ref to _
          ⍝ a script, and that "∆" (or SALT_Data) <b>must</b> be available in y[1], _
          ⍝ of course.
          ⍝ C)

          ⍝ y[1] as well as y[2] can be any of:
          ⍝ # Reference to a script in the workspace
          ⍝ # Name of a function, operator or script in the workspace
          ⍝ # Name of a script file (*.dyalog)

          ⍝ The left argument can be a command space with all sorts of parameters.

          ⍝ By default, any changes made in CompareIt! are taken into account.

          ⍝ By default, the names (APL ones or filenames) are used in CompareIt! _
          ⍝ as alias names but you can overwrite the, see next paragraph.

          ⍝ The following parameters can by specified from outside by passing a command space _
          ⍝ as a left argument:
          ⍝ readOnly1, readOnly2, alias1, alias2, reportChanges, converter, componentNo
          ⍝ Example:
          ⍝ <pre>
          ⍝ parms←⎕ns ''
          ⍝ parms.readOnly1←0
          ⍝ parms.alias1←'foo'
          ⍝ parms.alias2←'blah
          ⍝ parms.converter←'word'   ⍝ extract text from RTF rather than comparing RTF code.
          ⍝ parms.componentNo←1      ⍝ positive: pre-select this component; negative: read that component without user interaction; can also be a two-element vector
          ⍝
          ⍝ parms #.Compare.These #.Compare
          ⍝ </pre>

          ⍝ <h2>The "converter" parameter.
          ⍝ If you want compare Microsoft Office documents (*.doc, *.docx, *.rtf, *.xls... _
          ⍝ then you need to define a converter. Empty by default, "converter" can be _
          ⍝ either "word" or "excel". Note that this must stay empty for versions of _
          ⍝ CompareIt prior to version 4.0 when Office documents got converted _
          ⍝ automatically, preventing you in particular to compare RTF code rather _
          ⍝ than text.

          ⍝ <h2>Explict Result
          ⍝ If y[1] and/or y[2] are <b>not</b> read-only, any changes made by  the user _
          ⍝ are automatically taken into account, meaning that either the object in the _
          ⍝ workspace or the underlying file is updated by "These". Now under some _
          ⍝ circumstances the caller might want to be notified about such changes, for _
          ⍝ examples if she has created the file itself. This is what the explicit result _
          ⍝ is reporting back: If nothing at all has changed, it's (0 0), if both got _
          ⍝ changed, it is (1 1).

      (⎕IO ⎕ML)←1 3
      :If 1=≡y
      :AndIf 2=+/⊃∨/' ⎕SE.' ' #.'⍷¨⊂' ',⍕y
          (ref1 ref2)←y
      :Else
          y←,{0 1∊⍨≡⍵:⊂⍵ ⋄ y}y
          (ref1 ref2)←2↑y,⊂''
      :EndIf
      G←CreateParmsFor_These
      :If 9=⎕NC'parms'
      :AndIf ~0∊⍴l←parms.⎕NL-2
          :If ∨/b←~l∊G.⎕NL-2
              11 ⎕SIGNAL⍨'Invalid left argument: ',{1↓∊','∘,¨⍵}b/l
          :EndIf
          'G'⎕NS(⊂'parms.'),¨parms.⎕NL-2
      :EndIf
      changeFlag←0 0
      compNo2←⍬

      (ref1 ref2)←{IsRef ⍵:⍵ ⋄ 9.5 9.4∊⍨|⎕NC⊂⍵:⍎⍵ ⋄ {⍵/⍨~(∧\' '=⍵)∨⌽∧\' '=⌽⍵}⍵}¨ref1 ref2
      (ref1 ref2)←{⍬≡⍴⍵:⍵
          (1⍴⍵)∊'#⎕':⍵
          (':'∊⍵):⍵
          ('\\'≡(2⌊⍴,⍵)↑⍵):⍵
          0∊⍴⍵:⍵
          (2⊃⎕NSI),'.',⍵}¨ref1 ref2
      f←9 9=↑∘⎕NC¨⍕¨ref1 ref2                   ⍝ If they are both name class 9 but...
      f∧←IsNotScript¨ref1 ref2                  ⍝ ... not a script then they are ordinary namespaces
      :If ∨/f
          :If ∧/f
              11 ⎕SIGNAL⍨'"These" cannot process ordinary namespaces; see Compare.Merge'
          :Else
              11 ⎕SIGNAL⍨'"These" cannot process any ordinary namespace: ',⍕↑f/ref1 ref2
          :EndIf
      :Else
          :If 0∊⍴⍕ref2 ⍝ Special case: only y[1] was specified, so let's look for (∆|SALT_Data).SourceFile
              :If 0=f[1] ⍝ Is it a script?
                  :If 0<(|⎕NC(⍕ref1),'.SALT_Data.SourceFile')
                      ref2←'file://',⍕(GetRefToSaltNS⍎⍕ref1).SourceFile
                      readOnly2←1 ⍝ only this makes sense!
                  :Else
                      :If 0<#.⎕NC'acre'
                          ref2←{0∊⍴⍵:⍵ ⋄ 1⊃⍵}#.acre.acre.GetChangeFileName⍕ref1
                          :If G.refToUtils.WinFile.DoesExistFile ref2
                              ref2←'file://',dlb dtb ref2
                          :Else
                              11 ⎕SIGNAL⍨'Nothing to compare with: "',(⍕ref1),'"'
                          :EndIf
                      :Else
                          'Invalid right argument'⎕SIGNAL 11
                      :EndIf
                  :EndIf
              :ElseIf (|⎕NC⍕ref1)∊3 4 ⍝ either fns or opr?
                  ref2←#.acre.acre.GetChangeFileName ref1
                  :If G.refToUtils.WinFile.DoesExistFile ref2
                      ref2←'file://',ref2
                  :Else
                      11 ⎕SIGNAL⍨'File not found: ',⍕ref2
                  :EndIf
              :Else
                  'Invalid right argument'⎕SIGNAL 11
              :EndIf
          :EndIf

          (ref1IsRef ref2IsRef)←IsRef¨ref1 ref2
          (ref1 ref2)←ref1IsRef ref2IsRef{⍺:GetRealHome ⍵ ⋄ ⍵}¨ref1 ref2
          (ref1Is_FN ref2Is_FN)←IsFile¨ref1 ref2
          temp_FN1←temp_FN2←⍬                                           ⍝ Temp filenames
          compNo1←compNo2←⍬
          isSalt1←{~(|⎕NC⊂⍵)∊9.1 9.4 9.5:0 ⋄ 1=0<|⎕NC ⍵,'.∆':1 ⋄ 0<|⎕NC ⍵,'.SALT_Data'}ref1
          isSalt2←{~(|⎕NC⊂⍵)∊9.1 9.4 9.5:0 ⋄ 1=0<|⎕NC ⍵,'.∆':1 ⋄ 0<|⎕NC ⍵,'.SALT_Data'}ref2
          G.againFlag←1 1 ⍝ Default is: repetition is a potential option

     ∆Again:
          :If ref1Is_FN
              FN_1←ref1
              ref2IsDcf←0
              :Trap 0
                  FN_1↓⍨←'file://'{(⍴⍺)×⍺≡(⍴⍺)↑⍵}FN_1
                  fno1←TieComponentFile FN_1
                  range1←{¯1+⍵[1]+⍳|-/⍵}2↑⎕FSIZE fno1
                  dates1←fno1{⎕FRDCI ⍺,⍵}¨range1
                  dates1←FormatDateTime¨{date compidn 3⊃⍵}¨dates1
                  :If ¯1=×1↑G.componentNo
                      compNo1←|↑G.componentNo
                      G.againFlag[1]←0
                  :Else
                      :If 0∊⍴,compNo1←fno1 DisplayList ref1 range'Select component for comparison'compNo1 dates1
                          ⎕FUNTIE fno1
                          :Return
                      :EndIf
                  :EndIf
                  buffer←⎕FREAD fno1,compNo1
                  ⎕FUNTIE fno1
                  G.acreFlag←1
                  ref1IsDcf←1
                  :If 0∊⍴temp_FN2
                      temp_FN1←G.refToUtils.WinFile.GetTempPath,(' '~⍨⍕⎕TS),(⍕?1000),'_',⎕AN,'.txt'
                  :EndIf
                  WriteUtf8File temp_FN1(3⊃buffer)
              :Else
                  compNo1←¯1
                  ref1IsDcf←0
                  temp_FN1←''
              :EndTrap
          :Else
              :If 0∊⍴temp_FN1 ⍝ then we are coming back again
                  temp_FN1←WriteAplObjToFile ref1
                  FN_1←''
                  ref1IsDcf←0
                  compNo1←¯1
                  G.againFlag[1]←0
              :EndIf
          :EndIf

          :If ref2Is_FN
              FN_2←ref2
              ref2IsDcf←0
              :Trap 0
                  FN_2↓⍨←'file://'{(⍴⍺)×⍺≡(⍴⍺)↑⍵}FN_2
                  fno2←TieComponentFile FN_2
                  range2←{¯1+⍵[1]+⍳|-/⍵}2↑⎕FSIZE fno2
                  dates2←fno2{⎕FRDCI ⍺,⍵}¨range2
                  dates2←FormatDateTime¨{date compidn 3⊃⍵}¨dates2
                  :If 0∊⍴3⊃⎕FREAD fno2 1 ⍝ than it's new!
                      (range2 dates2)←1↓¨range2 dates2
                  :EndIf
                  :If ¯1=×¯1↑G.componentNo
                      compNo2←|¯1↑G.componentNo
                      G.againFlag[2]←0
                  :Else
                      :If 0∊⍴,compNo2←fno2 DisplayList ref2 range2'Select component for comparison'compNo2({2=|⎕NC ⍵:⍎⍵ ⋄ ⍬}'G.componentNo')dates2
                          ⎕FUNTIE fno2
                          :Return
                      :EndIf
                  :EndIf
                  buffer←⎕FREAD fno2,compNo2
                  ⎕FUNTIE fno2
                  G.acreFlag←1
                  ref2IsDcf←1
                  :If 0∊⍴temp_FN2
                      temp_FN2←G.refToUtils.WinFile.GetTempPath,(' '~⍨⍕⎕TS),(⍕?1000),'_',⎕AN,'.txt'
                  :EndIf
                  WriteUtf8File temp_FN2(3⊃buffer)
              :Case 24
                  . ⍝ File tied????!
              :Else
                  :If 0∊⍴temp_FN2 ⍝ then we are coming back again
                      compNo2←¯1
                      ref2IsDcf←0
                      temp_FN2←''
                  :EndIf
              :EndTrap
          :Else
              FN_2←WriteAplObjToFile ref2
              ref2IsDcf←0
              compNo2←¯1
              temp_FN2←''
              G.againFlag[2]←0
          :EndIf

          :If ref1IsDcf
              file1←temp_FN1
          :Else
              file1←(1+0∊⍴temp_FN1)⊃temp_FN1 FN_1
          :EndIf
          :If ref2IsDcf
              file2←temp_FN2
          :Else
              file2←(1+0∊⍴temp_FN2)⊃temp_FN2 FN_2
          :EndIf

          :If isSalt1
              saveDel1←{' '=1↑0⍴∊⍵:'''',⍵,'''' ⋄ ⍕⍵}{(⊂l~¨' '),⍺⍺¨⍵.⍎¨l←↓⍵.⎕NL 2}(GetRefToSaltNS⍎⍕ref1)
          :EndIf
          :If isSalt2
              saveDel2←{' '=1↑0⍴∊⍵:'''',⍵,'''' ⋄ ⍕⍵}{(⊂l~¨' '),⍺⍺¨⍵.⍎¨l←↓⍵.⎕NL 2}(GetRefToSaltNS⍎⍕ref2)
          :EndIf
          :If 0∊⍴G.alias1
              G.alias1←ref1
          :EndIf
          :If ¯1≢compNo1
              G.alias1,←~' ',compNo1⊃dates1
          :EndIf
          :If 0∊⍴G.alias2
              G.alias2←ref2
          :EndIf
          :If ¯1≢compNo2
              G.alias2,←' ',compNo2⊃dates2
          :EndIf
     ∆EditAgain:
          ('File not found: ',file1)⎕SIGNAL 11/⍨~refToUtils.WinFile.DoesExistFile file1
          ('File not found: ',file2)⎕SIGNAL 11/⍨~refToUtils.WinFile.DoesExistFile file2
          :Select WhichTool ⍬
          :Case 'CompareIt!'
              :If 0∊⍴G.reportFile
                  cmd←''
                  cmd,←⊂file1
                  cmd,←⊂file2
                  cmd,←⊂G.readOnly1∨(Is33 ref1)∨ref1IsDcf
                  cmd,←⊂G.readOnly2∨(Is33 ref2)∨ref2IsDcf
                  cmd,←⊂G.alias1,{~⍵:'' ⋄ ', component ',⍕compNo1}ref1IsDcf
                  cmd,←⊂G.alias2,{~⍵:'' ⋄ ', component ',⍕compNo2}ref2IsDcf
                  cmd,←⊂G.converter
                  changeFlag←~0∊¨↑∘⍴¨bodies←RunCompareIt cmd
              :Else
                  cmd←''
                  cmd,←⊂file1
                  cmd,←⊂file2
                  cmd,←⊂G.reportFile
                  G.converter RunCompareItReport cmd
              :EndIf
          :Case 'BeyondCompare'
              'Path to Beyond Compare is unknown'⎕SIGNAL 6/⍨0∊⍴pathToBeyondCompare
              cmd←''
              cmd,←⊂file1
              cmd,←⊂file2
              cmd,←⊂G.readOnly1∨(Is33 ref1)∨ref1IsDcf
              cmd,←⊂G.readOnly2∨(Is33 ref2)∨ref2IsDcf
              cmd,←⊂G.alias1,{~⍵:'' ⋄ ', component ',⍕compNo1}ref1IsDcf
              cmd,←⊂G.alias2,{~⍵:'' ⋄ ', component ',⍕compNo2}ref2IsDcf
              cmd,←⊂G.converter
              :If 0∊⍴G.reportFile
                  changeFlag←~0∊¨↑∘⍴¨bodies←RunBeyondCompare cmd
              :Else
                  changeFlag←~0∊¨↑∘⍴¨bodies←G.reportFile RunBeyondCompare cmd
              :EndIf
          :EndSelect

          :If ∨/changeFlag
              :If 1⊃changeFlag
                  body←1⊃bodies
                  :If ref1Is_FN
                      WriteUtf8File FN_1 body
                  :Else
                      :If (|⎕NC ref1)∊3 4
                          lineNo←body{⍵.⎕FX ⍺}⍎{⍵↓⍨-'.'⍳⍨⌽⍵}ref1
                          ⍎(' '≠1↑0⍴lineNo)/'. ⍝ ⎕FX has failed, check "lineNo"'
                          :If G.acreFlag
                              {}#.acre.SetChanged ref1
                          :EndIf
                      :Else
                          :Trap 0
                              res←body{⍵.⎕FIX ⍺}⍎{⍵↓⍨-'.'⍳⍨⌽⍵}ref1
                              :If (⍕res)≢ref1
                                  . ⍝ Something is not quite right!
                              :EndIf
                              :If G.acreFlag
                                  {}#.acre.SetChanged ref1
                              :EndIf
                          :Else
                              ShowMsg'Fixing your changes failed, please check'
                              →∆EditAgain
                          :EndTrap
                          :If isSalt1
                              :If 9=|⎕NC(⍕ref1),'.∆'
                                  ⍎ref1,'.∆←⎕ns'''''
                                  (⍎ref1).∆.{⍎¨(1⊃⍵),¨'←',¨1↓⍵}saveDel1
                              :Else
                                  ⍎ref1,'.SALT_Data←⎕ns'''''
                                  (⍎ref1).SALT_Data.{⍎¨(1⊃⍵),¨'←',¨1↓⍵}saveDel1
                              :EndIf
                          :EndIf
                      :EndIf
                      changeFlag[1]←1
                  :EndIf
              :EndIf
              :If 2⊃changeFlag
                  body←2⊃bodies
                  :If ref2Is_FN
                      WriteUtf8File FN_2 body
                  :Else
                      :If (|⎕NC ref2)∊3 4
                          lineNo←body{⍵.⎕FX ⍺}⍎{⍵↓⍨-'.'⍳⍨⌽⍵}ref2
                          ⍎(' '≠1↑0⍴lineNo)/'. ⍝ ⎕FX has failed, check "lineNo"'
                          :If G.acreFlag
                              {}#.acre.SetChanged ref2
                          :EndIf
                      :Else
                          res←body{⍵.⎕FIX ⍺}⍎{⍵↓⍨-'.'⍳⍨⌽⍵}ref2
                          :If (⍕res)≢ref2
                              . ⍝ Something is not quite right!
                          :EndIf
                          :If G.acreFlag
                              {}#.acre.SetChanged ref2
                          :EndIf
                      :EndIf
                      changeFlag[2]←1
                  :EndIf
              :EndIf
          :EndIf
          →(G.acreFlag∧(∨/G.againFlag)∧0<ref1IsDcf+ref2IsDcf)/∆Again
          refToUtils.WinFile.Delete temp_FN1 temp_FN2
      :EndIf
    ∇


    ∇ bool←{x}Match y;body_x;fileNo;body_y;SaltNS
      :Access Public Shared
      ⍝ x and y might be:
      ⍝ * a name of a fns/opr or a script, either from a namespace or a class.
      ⍝ * a reference to a script
      ⍝ * a native file holding either a classs or a namespace script
      ⍝ bool ←→ 1 if x and y are equal. Note that before actually comparing the two _
      ⍝ of them, all leading and all trailing blanks are removed from the code.
      ⍝ Note that filenames <b>must</b> start with `file://` if they do not contain _
      ⍝ one of these: "\" & "/" & ":".
      ⍝ Note that the left argument is optional. However, you can omit the left _
      ⍝ argument only when you specify a reference to a script as right argument. _
      ⍝ If it's omitted, the vars SALT_Data.SourceFilename is taken for the match.
      (⎕IO ⎕ML)←1 3
      :If 0=|⎕NC'x'
          'Right argument is not a reference'⎕SIGNAL 11/⍨⍬≢⍴y
          'Right argument must be a ref to a class or an interface or a scripted namespace'⎕SIGNAL 11/⍨~(|⎕NC⊂⍕y)∊9.1 9.4 9.5
          ('Could not find "(∆|Salt_Data).SourceFile" in ',⍕y)⎕SIGNAL 11/⍨~2∊(|y.⎕NC'∆.SourceFile'),(|y.⎕NC'SALT_Data.SourceFile')
          SaltNS←⍎((↑∘|y.⎕NC¨'∆' 'SALT_Data')⍳9)⊃'y.∆' 'y.SALT_Data'
          ('"SourceFile" in ',(⍕SaltNS),' is empty')⎕SIGNAL 11/⍨0∊⍴x←'file://',SaltNS.SourceFile
      :EndIf
      :If 'file://'{⍺≡(⍴⍺)↑⍵}Lowercase⍕x
      :OrIf ∨/':/\'∊⍕x ⍝ these chars cannot be part of an APL name, so they indicate a file
          x←'file://'{⍵↓⍨(⍴⍺)×⍺≡(⍴,⍺)↑⍵}⍕x
          body_x←ReadUtf8File x
          body_x←RemoveLeadingAndTrailingBlanks body_x
      :Else
          body_x←⍬
          :Trap 0
              :If (|⎕NC⊂⍕x)∊9.1 9.4 9.5
                  body_x←RemoveLeadingAndTrailingBlanks ⎕SRC⍎⍕x
              :EndIf
          :EndTrap
          :If ⍬≡body_x
              body_x←RemoveLeadingAndTrailingBlanks ⎕NR x ⍝ fns/opr?!
          :EndIf
      :EndIf
      :If 'file://'{⍺≡(⍴⍺)↑⍵}Lowercase⍕y
      :OrIf ∨/':/\'∊⍕y ⍝ these chars cannot be part of an APL name, so they indicate a file
          x←'file://'{⍵↓⍨(⍴⍺)×⍺≡(⍴,⍺)↑⍵}⍕x
          body_y←ReadUtf8File y
          body_y←RemoveLeadingAndTrailingBlanks body_y
      :Else
          body_y←⍬
          :Trap 0
              :If (|⎕NC⊂⍕y)∊9.1 9.4 9.5
                  body_y←RemoveLeadingAndTrailingBlanks ⎕SRC⍎⍕y
              :EndIf
          :EndTrap
          :If ⍬≡body_y
              body_y←RemoveLeadingAndTrailingBlanks ⎕NR y ⍝ fns/opr?!
          :EndIf
      :EndIf
      bool←body_x≡body_y
    ∇

    ∇ {r}←{reportFile}RunCompareIt y;path;readonlyFlag;compNo;oldBodyLeft;newBody;ask;oldBodyRight;cmd;more;rc;ps
      :Access Public Shared
    ⍝ Runs CompareIt! against filename1 and filename2.
    ⍝ The right argument:
    ⍝ * [1] filename1
    ⍝ * [2] filename2
    ⍝ * [3] (optional) read-only flag 1 (default=1)
    ⍝ * [4] (optional) read-only flag 2 (default=0)
    ⍝ * [5] (optional) source1
    ⍝ * [6] (optional) source2
    ⍝ * [7] (optional) converter
    ⍝ * [8] (optional) Wait flag.
    ⍝ Always returns a two-element-vector:
    ⍝ * [1] contents of filename1 or empty
    ⍝ * [2] contents of filename2 or empty
    ⍝ If the contents wasn't changed or read-only was 1 the _
    ⍝ corresponding item is empty.
    ⍝ -------------------
    ⍝ The result can be used to establish any changes in the _
    ⍝ workspace if appropriate.
      reportFile←{(0<⎕NC ⍵):⍎⍵ ⋄ ''}'reportFile'
      r←'' ''
      ps←⎕NS''
      ps.(filename1 filename2 readonlyFlag1 readonlyFlag2 source1 source2 converter waitFlag)←8↑y,(⍴,y)↓'' '' 1 0 '' '' '' 1
      :If 2=≡ps.source2
          (ps.source2 compNo)←ps.source2
      :EndIf
      'Filename(s) must not be empty!'⎕SIGNAL 11/⍨∨/0∊⊃∘⍴¨ps.filename1 ps.filename2
      '"readonlyFlag1" is not a Boolean'⎕SIGNAL 11/⍨~∧/ps.readonlyFlag1∊0 1
      '"readonlyFlag2" is not a Boolean'⎕SIGNAL 11/⍨~∧/ps.readonlyFlag2∊0 1
      (ps.readonlyFlag1 ps.readonlyFlag2)←↑¨ps.readonlyFlag1,ps.readonlyFlag2
      :If 0∊⍴ps.source1
          ps.source1←ps.filename1
      :EndIf
      :If 0∊⍴ps.source2
          ps.source2←ps.filename2
      :EndIf
      :If ~ps.readonlyFlag1
          oldBodyLeft←ReadAnyFile ps.filename1
      :EndIf
      :If ~ps.readonlyFlag2
          oldBodyRight←ReadAnyFile ps.filename2
      :EndIf
      ((ps.source1=' ')/ps.source1)←'_'
      ((ps.source2=' ')/ps.source2)←'_'
      :If 0∊⍴pathToCompareIt
          {}FindCompareIt 0
      :EndIf
      cmd←pathToCompareIt,' '
      cmd,←'"',(ps.filename1~'"'),'" /=',ps.source1,' '
      cmd,←'"',(ps.filename2~'"'),'" /=',ps.source2
      cmd,←' /N'
      :If ~0∊⍴reportFile
          cmd,←' /G:UW0 "',(reportFile~'¨'),'" '
      :EndIf
      :If ps.readonlyFlag1∧ps.readonlyFlag2
          cmd,←' /R'
      :Else
          cmd,←(ps.readonlyFlag1/' /R1'),((ps.readonlyFlag2/' /R2 '))
      :EndIf
      :If ~0∊⍴ps.converter
          :If ps.converter≡'word'
              cmd,←' /doc '
          :ElseIf ps.converter≡'excel'
              cmd,←' /xls '
          :Else
              'Invalid converter specified'⎕SIGNAL 11
          :EndIf
      :EndIf
      (rc more)←ps.waitFlag Run cmd
      ({0 1∊⍨≡⍵:⍵ ⋄ 1⊃⍵}more)⎕SIGNAL 11/⍨rc>99
      :If ~ps.readonlyFlag1
          :If oldBodyLeft≢newBody←ReadAnyFile ps.filename1
              r[1]←⊂newBody
          :EndIf
      :EndIf
      :If ~ps.readonlyFlag2
          :If oldBodyRight≢newBody←ReadAnyFile ps.filename2
              r[2]←⊂newBody
          :EndIf
      :EndIf
    ∇

    ∇ {r}←{reportFile}RunBeyondCompare y;path;source2;source1;filename1;filename2;readonlyFlag;compNo;oldBodyLeft;newBody;ask;readonlyFlag2;readonlyFlag1;oldBodyRight;cmd;more;rc
      :Access Public Shared
    ⍝ Runs BeyondCompare against filename1 and filename2.
    ⍝ The right argument:
    ⍝ * [1] filename1
    ⍝ * [2] filename2
    ⍝ * [3] (optional) read-only flag 1 (default=1)
    ⍝ * [4] (optional) read-only flag 2 (default=0)
    ⍝ * [5] (optional) source1
    ⍝ * [6] (optional) source2
    ⍝ Always returns a two-element-vector:
    ⍝ * [1] contents of filename1 or empty
    ⍝ * [2] contents of filename2 or empty
    ⍝ If the contents wasn't changed or read-only was 1 the _
    ⍝ corresponding item is empty.
    ⍝ -------------------
    ⍝ The result can be used to establish any changes in the _
    ⍝ workspace if appropriate.
      r←'' ''
      reportFile←{(0<⎕NC ⍵):⍎⍵ ⋄ ''}'reportFile'
      (filename1 filename2 readonlyFlag1 readonlyFlag2 source1 source2)←6↑y,(⍴,y)↓'' '' 1 0 '' ''
      :If 2=≡source2
          (source2 compNo)←source2
      :EndIf
      'Filename(s) must not be empty!'⎕SIGNAL 11/⍨∨/0∊⊃∘⍴¨filename1 filename2
      '"readonlyFlag1" is not a Boolean'⎕SIGNAL 11/⍨~∧/readonlyFlag1∊0 1
      '"readonlyFlag2" is not a Boolean'⎕SIGNAL 11/⍨~∧/readonlyFlag2∊0 1
      (readonlyFlag1 readonlyFlag2)←↑¨readonlyFlag1,readonlyFlag2
      :If 0∊⍴source1
          source1←filename1
      :EndIf
      :If 0∊⍴source2
          source2←filename2
      :EndIf
      :If ~readonlyFlag1
          :If refToUtils.WinFile.DoesExistFile filename1
              oldBodyLeft←ReadUtf8File filename1
          :Else
              oldBodyLeft←''
          :EndIf
      :EndIf
      :If ~readonlyFlag2
          :If refToUtils.WinFile.DoesExistFile filename2
              oldBodyRight←ReadUtf8File filename2
          :Else
              oldBodyRight←''
          :EndIf
      :EndIf
      ((source1=' ')/source1)←'_'
      ((source2=' ')/source2)←'_'
      cmd←'"',pathToBeyondCompare,'" '
      cmd,←'"',(filename1~'"'),'" /=',source1,' '
      cmd,←'"',(filename2~'"'),'" /=',source2
      cmd,←' /N'
      cmd,←' /fv="Text Compare"'
      cmd,←' /solo'
      :If readonlyFlag1∧readonlyFlag2
          cmd,←' /ro'
      :Else
          cmd,←(readonlyFlag1/' /ro1'),((readonlyFlag2/' /ro2 '))
      :EndIf
      :If ~0∊⍴reportFile
          cmd,←' /automerge /silent /closescript /force /output-options=HTML /output-to="',(reportFile~'"'),'"'
      :EndIf
      (rc more)←1 Run cmd
      ({0 1∊⍨≡⍵:⍵ ⋄ 1⊃⍵}more)⎕SIGNAL 11/⍨rc>99
      :If ~readonlyFlag1
          :If oldBodyLeft≢newBody←ReadUtf8File filename1
              r[1]←⊂newBody
          :EndIf
      :EndIf
      :If ~readonlyFlag2
          :If oldBodyRight≢newBody←ReadUtf8File filename2
              r[2]←⊂newBody
          :EndIf
      :EndIf
    ∇

    ∇ {converter}RunCompareItReport(filename1 filename2 reportFile);cmd;rc;more
      :Access Public Shared
    ⍝ Runs CompareIt! against filename1 and filename2.
    ⍝ The right argument:
    ⍝ * [1] filename1
    ⍝ * [2] filename2
    ⍝ * [3] The name of a file that takes a report.
    ⍝ "converter" can be empty or "word" or "excel'"
      'Filename(s) must not be empty!'⎕SIGNAL 11/⍨∨/0∊⊃∘⍴¨filename1 filename2
      {}FindCompareIt 1
      converter←{0=⎕NC ⍵:'' ⋄ ⍎⍵}'converter'
      'Invalid converter'⎕SIGNAL 11/⍨~(⊂converter)∊'' 'word' 'excel'
      cmd←pathToCompareIt,' '
      cmd,←'"',(filename1~'"'),'" '
      cmd,←'"',(filename2~'"'),'" '
      cmd,←' /G:UW0 "',(reportFile~'¨'),'" '
      :If ~0∊⍴converter
          :If converter≡'word'
              cmd,←'/doc '
          :ElseIf converter≡'excel'
              cmd,←'/xls '
          :Else
              . ⍝ Huuuh?!
          :EndIf
      :EndIf
      (rc more)←1 Run cmd
      more ⎕SIGNAL 11/⍨rc≠0
      ⍝Done
    ∇

    ∇ {r}←FindCompareIt askUserFlag;parms;ourRegKey
      :Access Public Shared
      parms←''
      parms,←⊂regPath,'\PathToCompareIt!'       ⍝ Our own Registry key (if any)
      ourRegKey←'Computer\HKEY_CLASSES_ROOT\Applications\wincmp3.exe\shell\open\command' ⍝ The tool's Registry key (if any)
      parms,←⊂ourRegKey
      parms,←⊂pathToCompareIt                   ⍝ Path
      parms,←⊂'Compare It!'                     ⍝ The default location
      parms,←⊂'wincmp3.exe'                     ⍝ The EXEs name
      parms,←⊂askUserFlag                       ⍝ Flag: shall be bother the user if we cannot work it out ourselves?
      parms,←⊂'Select CompareIt!''s EXE:'       ⍝ Caption of the "File Select" dialog box
      pathToCompareIt←r←FindCompareTool parms
    ∇

    ∇ {r}←FindBeyondCompare askUserFlag;parms;ourRegKey
      :Access Public Shared
      parms←''
      parms,←⊂regPath,'\PathToBeyondCompare'    ⍝ Our own Registry key (if any)
      ourRegKey←'HKEY_CURRENT_USER\Software\Scooter Software\Beyond Compare 3\ExePath' ⍝ The tool's Registry key (if any)
      parms,←⊂ourRegKey
      parms,←⊂pathToBeyondCompare               ⍝ Path
      parms,←⊂'Beyond Compare 3'                ⍝ The default location
      parms,←⊂'bcompare.exe'                    ⍝ The EXEs name
      parms,←⊂askUserFlag                       ⍝ Flag: shall be bother the user if we cannot work it out ourselves?
      parms,←⊂'Select BeyondCompare''s EXE:'    ⍝ Caption of the "File Select" dialog box
      pathToBeyondCompare←r←FindCompareTool parms
    ∇

    ∇ {r}←FindCompareTool(ourRegKey vendorRegKey path defaultLocation exeName askUserFlag caption);rk;flag
    ⍝ Tries to find out somehow where the compare tool is located.
    ⍝ The function returns its findings as result.
    ⍝ In case the function can't work it out AND the right argument is 1 then _
    ⍝ the user is asked. This is always the case when `CompareSimple` itself calls _
    ⍝ this functions but when you call it yourself you can prevent that from _
    ⍝ happening - your choice
    ⍝ When the functions fails to find the compare tool it throws an exception.
      :If 0∊path                                                ⍝ Do we already know? (path is either pathToCompareIt or pathToBeyondCompare)
      :OrIf ~refToUtils.WinFile.DoesExistFile path              ⍝ Or did we believe we know but we don't?!
          :If 0∊⍴path←refToUtils.WinReg.GetString ourRegKey     ⍝ Have we saved something ourselves?
              path←refToUtils.WinReg.GetString vendorRegKey     ⍝ The vendor might have saved the path in the Registry
              :If 0∊⍴path                                       ⍝ No he didn't!
              :OrIf ~refToUtils.WinFile.DoesExistFile path          ⍝ Yes he did but the path is incorrect anyway
                  :If 0<|⎕NC'refToAcreInstance'                     ⍝ Is acre around?!
                  :AndIf ~0∊⍴refToAcreInstance                      ⍝ Check...
                  :AndIf 2=|refToAcreInstance.⎕NC'comparewith'      ⍝ ...whether acre...
                  :AndIf ~0∊⍴refToAcreInstance.comparewith          ⍝ ...is smarter than we are.
                      path←refToAcreInstance.comparewith            ⍝ Take the path from acre
                  :Else
                      path←(ExpandEnv'%ProgramFiles(x86)%'),'\',defaultLocation,'\',exeName ⍝ Standard location on a 64bit Windows
                      :If refToUtils.WinFile.DoesExistFile path     ⍝ Is it available there?!
                          path←'"',(path~'"'),'"'                   ⍝ Prepare proper path
                      :Else
                          path←(ExpandEnv'%ProgramFiles%'),'\',defaultLocation,'\',exeName  ⍝ Standard location on a 32bit Windows
                          :If refToUtils.WinFile.DoesExistFile path
                              path←'"',(path~'"'),'"'               ⍝ Prepare proper path
                          :ElseIf askUserFlag
                              path←SelectFile caption exeName       ⍝ We are running out of options - ask user
                          :EndIf
                      :EndIf
                      flag←0∊⍴path                                  ⍝ The moron doesn't...
                      flag∨←~refToUtils.WinFile.DoesExistFile path  ⍝ ...know either?!
                      'Cannot find BeyondCompare'⎕SIGNAL flag/6
                      path←'"',(path~'"'),'"'                       ⍝ Prepare proper path
                  :EndIf
              :EndIf
          :EndIf
      :EndIf
      r←path
    ∇

 ⍝⍝⍝⍝⍝ Private stuff

    ∇ r←FormatTS ts
      r←{
          0∊⍴⍵:''
          0=+/⍵:''
          ,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT,[0.5]6↑⍵
      }ts
    ∇

    ∇ {R}←{wait}Run cmd;∆WAIT;windowStyle;wsh;rc
        ⍝ Starts an application
        ⍝ By default, Run waits for the app to quit.
      R←0 ''
      wait←{0<|⎕NC ⍵:⍎⍵ ⋄ 1}'wait'
      'Invalid left argument: must be a Boolean'⎕SIGNAL 11/⍨~wait∊0 1
      windowStyle←8 ⍝ is WINDOWSTYLE.NORMAL
      'wsh'⎕WC'OLEClient' 'WScript.Shell'
      :Trap 0
          rc←wsh.Run cmd windowStyle wait
      :Else
          R←1('.'⎕WG'LastError')
          :Return
      :EndTrap
      R←rc''
    ∇

    ∇ flag←{caption}YesOrNo question;∆;ms
      caption←{0<|⎕NC ⍵:'Compare: ',⍎⍵ ⋄ 'Compare'}'caption'
      ∆←⊂'MsgBox'
      ∆,←⊂caption
      ∆,←⊂'Text'question
      ∆,←⊂'Style' 'Query'
      ∆,←⊂'Event'('MsgBtn1' 'MsgBtn2')1
      'ms'⎕WC ∆
      flag←'MsgBtn1'≡2⊃⎕DQ'ms'
    ∇

    ∇ {r}←{caption}ShowMsg question;∆;ms
      r←⍬
      caption←{0<|⎕NC ⍵:'Compare: ',⍎⍵ ⋄ 'Compare'}'caption'
      ∆←⊂'MsgBox'
      ∆,←⊂caption
      ∆,←⊂'Text'question
      ∆,←⊂'Style' 'Info'
      ∆,←⊂'Event'('MsgBtn1')1
      'ms'⎕WC ∆
      {}⎕DQ'ms'
    ∇

      IsNotScript←{
⍝ Takes a name (⍵) and returns a 1 in case it's not a script, otherwise 0
⍝ The check is performed in ⍺ (ref to a namespace)
          ⍺←#
          (0∊⍴,⍵):1
          (9≠|⍺.⎕NC⍕⍵):1
          0::1
          ¯1≡⍺:⎕SIGNAL 11
          {0}⍺.⎕SRC ⍺.⍎⍕⍵
      }

      GetRefToSaltNS←{
          9=|⎕NC(⍕⍵),'.∆':⍵⍎'∆'
          9=|⎕NC(⍕⍵),'.SALT_Data':⍵⍎'SALT_Data'
          ⍬
      ⍝ Returns a ref to ⍵.∆ if that is a namespace or
      ⍝ a ref to ⍵.SALT_Data if that is a namespace or
      ⍝ an empty vector.
      }

    IsRef←{(0=≡⍵)∧⍵≢⍕⍵}                             ⍝ Used to identify references
    IsFile←{(∨/':/\'∊⍵)∨'file://'{⍺≡(⍴⍺)↑⍵}⍵}       ⍝ Used to identify filename

    ∇ r←FindAcreInstance;list;bool
     ⍝ Finds one single acre instance in #, if any
      r←⍬
      :If ~0∊⍴list←(' '~¨⍨↓#.⎕NL 9.1)~⊂'#.acre'
      :AndIf 0<+/bool←{(⊂'[acre]')≡¨⍵}⍕¨#.⍎¨list
          r←⍎'#.',(bool⍳1)⊃list
      :EndIf
    ∇


    ∇ r←fno DisplayList(caption data info lastItemWas preSelect ts);∆;res;f;bool;⎕WX
      r←⍬
      ⎕WX←3
      'f'⎕WC'Form'('Coord' 'Pixel')('Size'(240 650))('Posn'(45 35))
      'f.mm'⎕WC'Menubar'
      'f.mm.cmds'⎕WC'Menu' 'Commands'
      'f.mm.cmds.del'⎕WC'MenuItem' 'Delete change file'('Event' 'Select' 'OnDelChangeFile')
      'f.sb'⎕WC'Statusbar'
      'f.sb.f'⎕WC'StatusField'('Coord' 'Prop')('Size'(⍬ 98))
      'f.sb.f'⎕WS'Text'('No of components: ',⍕⍴data)
      f.Caption←'Compare: ',caption
      'f.l'⎕WC'Label'info(5 5)('Attach'(4⍴'Top' 'Left'))
      ∆←⊂'Combo'
⍝    ∆,←⊂'Items'({2=⍴⍴⍵:↓⎕FMT ⍵ ⋄ ⍕¨⍵}data)
      ∆,←⊂'Items'((⍴⍕⌈/data)∘{'component no ',((-⍺)↑(⍺⍴'0'),⍕⍵[1]),' from ',2⊃⍵}¨data,¨⊂¨ts)
      ∆,←⊂'Posn'(35 5)
      ∆,←⊂'Size'(⍬(f.Size[2]-5×2))
      ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Right')
      :If ⍬≡lastItemWas
          :If 0∊⍴preSelect
              ∆,←⊂'Selitems'((-1⊃⍴data)↑1)
          :Else
              bool←(⍴data)⍴0
              bool[preSelect]←1
              ∆,←⊂'Selitems'bool
          :EndIf
      :Else
          ∆,←⊂'Selitems'(lastItemWas=data)
      :EndIf
      'f.c'⎕WC ∆
      'f.ok'⎕WC'Button' 'OK'((f.Size[1]-55),5)(⍬ 80)('Default' 1)('Event' 'Select' 1)('Attach'(4⍴'Bottom' 'Left'))
      'f.cancel'⎕WC'Button' 'Cancel'(f.Size-55 85)(⍬ 80)('Cancel' 1)('Event' 'Select' 1)('Attach'(4⍴'Bottom' 'Right'))
      ⎕NQ'f.c' 'GotFocus' ⋄ res←⎕DQ'f'
      :If ~0∊⍴res
      :AndIf 'f.ok'≡1⊃res
          r←(f.c.SelItems⍳1)⊃{2=⍴⍴⍵:⍵[;1] ⋄ ⍵}data
      :EndIf
    ∇

    ∇ r←RemoveLeadingAndTrailingBlanks r
      :If 0 1∊⍨≡r
          r/⍨←~(∧\' '=r)∧⌽∧\' '=⌽r
      :Else
          r←{⍵/⍨~(∧\' '=⍵)∨⌽∧\' '=⌽⍵}¨r
      :EndIf
    ∇

    ∇ R←ExpandEnv Y;ExpandEnvironmentStrings;f;⎕ML;⎕IO
    ⍝ If Y does not contain any "%", Y is passed untouched.
    ⍝ In case Y is empty R is empty as well.
    ⍝ Example:
    ⍝ <pre>'C:\Windows\MyDir' ←→ #.WinSys.ExpandEnv '%WinDir%\MyDir'</pre>
      ⎕IO←0 ⋄ ⎕ML←3
      :If '%'∊R←Y
          'ExpandEnvironmentStrings'⎕NA'I4 KERNEL32.C32|ExpandEnvironmentStrings',('*A'⊃⍨12>{⍎⍵↑⍨⍵⍳'.'}1⊃'.'⎕WG'APLVersion'),' <0T >0T I4'
          f←80=⎕DR' '           ⍝ Unicode version? (used to double the buffer size)
          R←1⊃ExpandEnvironmentStrings(Y(f×1024)(f×1024))
      :EndIf
    ∇

    ∇ R←SelectFile(caption exeName);∆;res;flag;directory
    ⍝ Let the user select a certain EXE for comparison
      flag←0
      directory←SelectProperStartDir ⍬
      :Repeat
          R←''
          ∆←⊂'FileBox'
          ∆,←⊂'Caption'caption
          ∆,←⊂'FileMode' 'Read'
          ∆,←⊂'Filters'(⊂'*.exe' 'Executables')
          ∆,←⊂'Event'('FileBoxOk' 'FileBoxCancel')1
          ∆,←⊂'Directory'directory
          'ff'⎕WC ∆
          res←⎕DQ ff
          :If 'FileBoxOK'≡2⊃res
              :If ~0∊⍴ff.File
              :AndIf ≡/Lowercase exeName ff.File
                  R←3⊃res
                  flag←1
              :EndIf
              directory←ff.Directory
          :Else
              flag←1
          :EndIf
      :Until flag
    ∇

      WhichTool←{
          (~0∊⍴compareTool):compareTool             ⍝ That take precedence
          (~0∊⍴pathToCompareIt):'CompareIt!'        ⍝ The defaullt if we know where it is
          (~0∊⍴pathToBeyondCompare):'BeyondCompare' ⍝ Fine as well if we know where it is
          _←FindCompareIt 1
          (~0∊⍴pathToCompareIt):'CompareIt!'        ⍝ The defaullt if we know where it is
          _←FindBeyondCompare 1
          (~0∊⍴pathToBeyondCompare):'BeyondCompare' ⍝ Fine as well if we know where it is
          'Comparison tool is undefined or location is uknknown'⎕SIGNAL 6
      }

      SelectProperStartDir←{
          (~0∊⍴b←2 ⎕NQ'.' 'GetEnvironment' 'ProgramFiles(x86)'):b
          (~0∊⍴b←2 ⎕NQ'.' 'GetEnvironment' 'ProgramFiles'):b
          refToUtils.WinFile.PWD
      }

      GetRealHome←{
          ⍵{(⍺.⎕DF ⍵)⊢⍕⍺}⍵.⎕DF ⎕NULL
    ⍝ format ref - sans ⎕DF
    ⍝ ⍵ ns-ref
    ⍝ ← format of ns-ref - full path name
    ⍝   ignoring ⎕DF by using it twice!
    ⍝ Phil Last ⍝ 2008-03-13 23:14
      }

      Is33←{
    ⍝ Returns 1 in case ⍵ is pointing to an idiom or assign fns/opr (name class 3.3)
    ⍝ ⍵ can be one of:
    ⍝ #.MyNamespace.foo
    ⍝ #.MyClass.foo
    ⍝ file://c:temp.dyalog
          ('file://'{⍺≡(⍴⍺)↑⍵}Lowercase ⍵):0
          3.3=⊃{(⍎⍺).⎕NC⊂⍵}/¯1 0↓¨'.'SplitPath ⍵
      }

    ∇ r←ReadAnyFile filename
  ⍝ Reads filename, no matter whether it's a UTF-8 file or not.
  ⍝ Returns '' in case the file does not eixst.
      r←''
      :If refToUtils.WinFile.DoesExistFile filename
          :Trap 11
              r←ReadUtf8File filename
          :Else
              r←refToUtils.WinFile.ReadAnsiFile filename
          :EndTrap
      :EndIf
    ∇

      compidn←{                 ⍝ Component timestamp in IDN format.
          base←days 1970 1 1      ⍝ component file epoch.
          stamp←⍬⍴⍵               ⍝ 60th of a second since epoch.
          base+stamp÷×/1 3/24 60  ⍝ (fractional) day number.
      }

      date←{⎕ML←0                             ⍝ ⎕TS format from day number (Meeus).
          ⍺←¯53799                            ⍝ start of Gregorian calendar (GB).
          qr←{⊂[1+⍳⍴⍴⍵](0,⍺)⊤⍵}               ⍝ quotient and remainder.
          Z F←1 qr ⍵+2415020                  ⍝
          a←⌊(Z-1867216.25)÷36524.25          ⍝
          A←Z+(Z≥⍺+2415021)×1+a-⌊a÷4          ⍝
          B←A+1524                            ⍝
          C←⌊(B-122.1)÷365.25                 ⍝
          D←⌊C×365.25                         ⍝
          E←⌊(B-D)÷30.6001                    ⍝
          dd df←1 qr(B-D)+F-⌊30.6001×E        ⍝
          mm←E-1+12×E≥14                      ⍝
          yyyy←C-4715+mm>2                    ⍝
          part←60 60 1000 qr⌊0.5+df×86400000  ⍝
          ↑[⎕IO-0.5]yyyy mm dd,part           ⍝
      }

      days←{                                      ⍝ Days since 1899-12-31 (Meeus).
          ⍺←17520902                              ⍝ start of Gregorian calendar.
          yy mm dd h m s ms←7↑⊂[⍳¯1+⍴⍴⍵]⍵         ⍝ ⎕ts-style 7-item date-time.
          D←dd+(0 60 60 1000⊥↑h m s ms)÷86400000  ⍝ day with fractional part.
          Y M←yy mm+¯1 12×⊂mm≤2                   ⍝ Jan, Feb → month 13 14.
          A←⌊Y÷100                                ⍝ century number.
          B←(⍺<0 100 100⊥↑yy mm dd)×(2-A)+⌊A÷4    ⍝ Gregorian calendar correction.
          ¯2416544+D+B+⊃+/⌊365.25 30.6×Y M+4716 1 ⍝ (fractional) days.
      }

    ∇ r←TieComponentFile filename;list
    ⍝ When CompareSimple.These is used alongside with acre then
    ⍝ the file might well be tied by acre already, so we need
    ⍝ to take care of that here and now:
      :Trap 24
          r←filename ⎕FTIE 0
      :Case 24
          list←Lowercase{dlb dtb ⍵}¨↓⎕FNAMES
          r←(list⍳⊂Lowercase filename)⊃⎕FNUMS
      :EndTrap
    ∇

:EndClass