:Class Compare: CompareSimple
⍝ <h2>Overview</h2>

⍝ <h3>Comparing
⍝ `Compare` offers a bunch of shared methods helpful to compare functions, _
⍝ operators and scripts. Sources of those objects may by in the current _
⍝ workspace or on file (SALT/script files or acre component files).
⍝ It also comes with a method to process an array as it is returned by _
⍝ acre's `Versions` method.

⍝ <h2>Restrictions</h2>
⍝ The `Merge` method worries about ordinary namespaces only. If you have ×
⍝ one of these in your workspace:
⍝ * Class instances
⍝ * Refs pointing to unnames namespaces
⍝ * Attached namespaces
⍝ then any code in these is ignored. They will however be reported. This is _
⍝ because it is assumed that this kind of stuff should not lay around at at, _
⍝ therefore a warning is issued.
⍝ Note that you may have different views on whether references pointing to _
⍝ unnamed namespaces should be considered temporary (used during runtime only). _
⍝ If you do then the report won't fit your taste, and you won't be happy that _
⍝ `Compare` ignores all code found in such namespaces. You can however _
⍝ change this by setting the `refsAreRubbish` flag to 0; this is the second _
⍝ flag in the left argument of `Merge`.

⍝ <h3>Merging
⍝ The class also offers methods to compare and even merge ordinary _
⍝ namespaces. Since namespaces can hold everything, even a whole workspace, _
⍝ this can effectively be used to compare and merge workpaces by copying _
⍝ those workspaces into two namespaces and then compare the two of them.

⍝ <h3>Size
⍝ If you are looking for a simple comparison tool then check CompareSimple _
⍝ first. `Compare` inherits from `CompareSimple`.

⍝ <h2>Comparison</h2>
⍝ The actual comparison can be done by one of the commercial products _
⍝ "CompareIt!" (for details see http://aplwiki.com/CompareIt) or _
⍝ "Beyond Compare".


⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/Compare

    ⎕io←1 ⋄ ⎕ml←3

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public shared
      r←({⍵↓⍨⍵⍳'.'}⍕⎕THIS)'3.6.1' '2015-04-04'
      ⍝ 3.6.1 Bug fix in `Merge`.
      ⍝ 3.6.0 Version now returns just Compare (no path).
    ∇

    ∇ r←History
      :Access Public Shared
      r←'See: //http://aplwiki.com/Compare/ProjectPage'
    ∇

    ∇ r←Get_UUID
      :Access Public Shared
      ⍝ Useful in order to tell this particular "Compare" class from _
      ⍝ any other classes with the same name
      r←'{7B647151-E9A3-B54C-BAF7-7311E69DC8CC}'
    ∇

    :Property refToUtils
    :Access Public Shared
        ∇ r←get
          r←{0::## ⋄ _refToUtils}⍬
        ∇
        ∇ set arg
          _refToUtils←arg.NewValue
        ∇
    :EndProperty

    ∇ {r}←{flags}Merge y;report;rubbishObjects1;rubbishObjects2;readOnly;refsAreRubbish;rubbishReport1;rubbishReport2;obj;rubbishReport;ref1;ref2;dropFromRubbish;reftoGui
      :Access Public Shared
    ⍝ Useful to compare namespaces with each other.
    ⍝ Flags:
    ⍝ "readOnly" can be:
    ⍝ 0  = Allow user changes
    ⍝ 1  = Don't allow changes
    ⍝ ¯1 = Don't show anything, just return data structures
    ⍝ ¯2 = Show the GUI but don't execute ⎕DQ
    ⍝ "flags" is optional and may carry one or two Booleans:
    ⍝ [1] readOnly flag: controls the user's ability to change what's displayed. _
    ⍝     Might be a scalar or a vector of length two, one Boolean for each side. _
    ⍝     Defaults to 0, meaning the user can change everything
    ⍝ [2] refsAreRubbish flag: 1 means that refs are considered to be temporary _
    ⍝     and therefore they need to be reported as "rubbish". This is a highly _
    ⍝     philosphical thing to decide, so we leave this to the user. Default is 1.
    ⍝ Result:
    ⍝ Always a two-item vector with the differences report in [1] and the rubbish
    ⍝ report in [2].
      (⎕ML ⎕IO)←3 1
      flags←{0<⎕NC ⍵:⍎⍵ ⋄ 0 1}'flags'
      (readOnly refsAreRubbish)←2↑flags,(⍴,flags)↓0 1
      readOnly←{(1=⍴,⍵):2⍴⍵ ⋄ (2=⍴⍵):⍵ ⋄ 'Invalid: "readOnly'⎕SIGNAL 11}readOnly
      'Check left argument'⎕SIGNAL 6/⍨~(⍴,y)∊2 3
      (ref1 ref2 dropFromRubbish)←3↑y,(⍴,y)↓⍬ ⍬ 0
      'Invalid: "refsAreRubbish'⎕SIGNAL 11/⍨{∧/(,¨⍵)≢¨,¨1 0}refsAreRubbish
      'Invalid left argument: must be one of ¯1, ¯2, 0, 1'⎕SIGNAL 11/⍨∨/~readOnly∊¯1 0 1 ¯2
      'ref1 is not pointing to a namespace'⎕SIGNAL 11/⍨~{0::0 ⋄ 'Namespace'≡⍵.⎕WG'Type'}ref1
      'ref2 is not pointing to a namespace'⎕SIGNAL 11/⍨~{0::0 ⋄ 'Namespace'≡⍵.⎕WG'Type'}ref2
      (ref1 ref2).⎕DF ⎕NULL
      (ref1 ref2)←{(0∊⍴⍵):⍵ ⋄ ⍎⍕⍵}¨ref1 ref2
      'ref1 is not a reference to a namespace'⎕SIGNAL 11/⍨0=IsNotScript ref1
      'ref2 is not a reference to a namespace'⎕SIGNAL 11/⍨0=IsNotScript ref2
      report←rubbishReport1←rubbishReport2←rubbishObjects1←rubbishObjects2←⍬
      ns_ ref1 ref2 refsAreRubbish
      rubbishReport←PolishRubbishReport ref1 ref2 rubbishReport1 rubbishReport2 refsAreRubbish dropFromRubbish
      :If 0∊⍴report←⊃report
          r←''rubbishReport
      :Else
          obj←⎕NEW CompareData(ref1 ref2 report)
          :If ∧/readOnly∊0 1 ¯2
              reftoGui←DisplayDiff obj readOnly(2⊃Version)rubbishReport
          :EndIf
          :If ¯2∊readOnly
              r←report rubbishReport reftoGui
          :Else
              r←report rubbishReport
          :EndIf
      :EndIf
    ∇

    ∇ {reftoGui}←DisplayDiff(diff readOnly versionNo rubbish)
    ⍝ Designed to display the result of "Merge".
    ⍝ "readOnly" supresses everything that enables a user to change anything
    ⍝ "compareTool" must be "CompareIt!" or "Beyond Compare"
      (⎕IO ⎕ML)←1 3
      reftoGui←Display.Diff diff readOnly versionNo rubbish
    ∇

 ⍝⍝⍝⍝⍝ Private stuff

    ∇ r←FormatTS ts
      r←{
          0∊⍴⍵:''
          0=+/⍵:''
          ,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT,[0.5]6↑,⍵
      }ts
    ∇

    ∇ r←{version}GetBodyFromAcreDcf filename;fno;versions;name;fnsVersion;body;ln
    ⍝ Returns latest version (by default) from an acre component file
      fno←filename ⎕FTIE 0
      versions←-/⌽2↑⎕FSIZE fno
      :If 0=⎕NC'version'
          version←versions
      :Else
          :If ¯1=×version
              version←versions+version
          :EndIf
      :EndIf
      'Invalid version number'⎕SIGNAL 11/⍨~version∊⍳versions
      :Trap 0
          (name fnsVersion body)←⎕FREAD fno version
      :Else
          ⎕FUNTIE fno
          11 ⎕SIGNAL⍨'File is not an acre'
      :EndTrap
      body←{⍵⊂⍨⎕TC[2]≠⍵}body
      :If ' '≠1↑0⍴ln←(⍎{⍵↓⍨-'.'⍳⍨⌽⍵}name).⎕FX body
          ⎕←'Could not fix "',name,'", see line(s) ',⍕ln
      :Else
          ⎕←'Successfull fixed: "',name,'"'
      :EndIf
      ⎕FUNTIE fno
    ∇

    ∇ {R}←{wait}Run cmd;∆WAIT;windowStyle;wsh
        ⍝ Starts an application
        ⍝ By default, Run waits for the app to quit.
      R←0 ''
      wait←{0<⎕NC ⍵:⍎⍵ ⋄ 1}'wait'
      'Invalid left argument: must be a Boolean'⎕SIGNAL 11/⍨~wait∊0 1
      windowStyle←8 ⍝ is WINDOWSTYLE.NORMAL
      'wsh'⎕WC'OLEClient' 'WScript.Shell'
      :Trap 0
          {}wsh.Run cmd windowStyle wait
      :Else
          R←1('.'⎕WG'LastError')
      :EndTrap
    ∇

    ∇ flag←{caption}YesOrNo question;∆;ms
      caption←{0<⎕NC ⍵:'Compare: ',⍎⍵ ⋄ 'Compare'}'caption'
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
      caption←{0<⎕NC ⍵:'Compare: ',⍎⍵ ⋄ 'Compare'}'caption'
      ∆←⊂'MsgBox'
      ∆,←⊂caption
      ∆,←⊂'Text'question
      ∆,←⊂'Style' 'Info'
      ∆,←⊂'Event'('MsgBtn1')1
      'ms'⎕WC ∆
      {}⎕DQ'ms'
    ∇

    ∇ {recursionFlag}ns_(ref1 ref2 refsAreRubbish);list1;list2
⍝ Doing the hard work of the comparison of namespaces:
⍝ 1. compare fns
⍝ 2. compare opr
⍝ 3. compare classes and interfaces
⍝ 4. compare scripted namespaces
⍝ 5. Call recursively if there are non-scripted sub-namespaces
⍝ Adds rows to semi-global "report" (the "result" of the investigation)
 ⍝⍎(∨/'Server_Code'⍷⍕ref1)/'.'
      recursionFlag←{(0<⎕NC ⍵):⍎⍵ ⋄ 0}'recursionFlag'
      (list1 list2)←{0::'' ⋄ ' '~¨⍨↓⍵.⎕NL 3 4 9.1 9.4 9.5}¨ref1 ref2
      :If '['∊(⍕ref1),⍕ref2
          ⎕←'Cannot not compare ',(⍕ref1),'/',(⍕ref2) ⋄ :Return
      :EndIf
      list1←(ref1 __Get list1)/list1
      list2←(ref2 __Get list2)/list2
      report,←ProcessCode ref1 list1 list2 1    ⍝ Everything in [1] only
      report,←ProcessCode ref2 list2 list1 2    ⍝ Everything in [2] only
      report,←ScanCodeFoundInBothRefs(list1∩list2)ref1 ref2
      :If 0=recursionFlag
          (rubbishReport1 rubbishObjects1)←ReportRubbishIn ref1 rubbishReport1 rubbishObjects1 recursionFlag refsAreRubbish
          (rubbishReport2 rubbishObjects2)←ReportRubbishIn ref2 rubbishReport2 rubbishObjects2 recursionFlag refsAreRubbish
      :EndIf
      (list1 list2)←{(0∊⍴⍵):'' ⋄ List ⍵}¨ref1 ref2
      :If 1∨recursionFlag∧refsAreRubbish ProcessUniqueObjects(ref1 ref2 list1 list2 1)
          (rubbishReport1 rubbishObjects1)←ReportRubbishIn ref1 rubbishReport1 rubbishObjects1 1 refsAreRubbish
      :EndIf
      :If 1∨recursionFlag∧refsAreRubbish ProcessUniqueObjects(ref2 ref1 list2 list1 2)
          (rubbishReport2 rubbishObjects2)←ReportRubbishIn ref2 rubbishReport2 rubbishObjects2 1 refsAreRubbish
      :EndIf
      ScanOrdinaryNamespacesInBothRefs ref1 ref2
    ∇

    ∇ {r}←refsAreRubbish ProcessUniqueObjects(ref1 ref2 list1 list2 ind);list;this
    ⍝ Loop over all ordinary (non-scripted) namespaces that exist in `ref1` only
      r←1
⍝      :If ~0∊↑∘⍴¨,¨list1 list2
      :If ~0∊⍴list1
          :If 0∊⍴list2
              list←list1
          :Else
              list←(~((1+⍴⍕ref1)↓¨⍕¨list1)∊((1+⍴⍕ref2)↓¨⍕¨list2))/list1
          :EndIf
      :AndIf ~0∊⍴list
      :AndIf ~0∊⍴list←{(0=↑∘⍴∘Display.GetBody¨⍕¨⍵)/⍵}list
          :For this :In list
              r←0
              1 ns_(ind⊃(this ⍬)(⍬ this)),refsAreRubbish
          :EndFor
      :EndIf
    ∇


    ∇ buffer←ProcessCode(ref list1 list2 no);bool;list;buffer
    ⍝ Any stuff that is "code" (fns, opr, script)
      buffer←''
      :If 1∊bool←~list1∊list2
          list←bool/list1
          buffer←(+/bool)⍴⍕no       ⍝ indicator
          buffer,¨←⊂¨bool/list1     ⍝ name1
          buffer,¨←⊂⊂''             ⍝ path1
          buffer,¨←⊂⊂''             ⍝ path2
          ((2+no)⊃¨buffer)←⊂⍕ref    ⍝ The actual assignment
          buffer,¨←GetNameClass∘{⍵[3 2]}¨buffer ⍝ type of 1
          buffer,¨←GetNameClass∘{⍵[4 2]}¨buffer ⍝ type of 2
          buffer,¨←⊂¨FormatTS¨{0::⍬ ⋄ 2 ⎕AT ⍵}¨{{⍺,'.',⍵}/⍵[3 2]}¨buffer ⍝ Last change of 1
          buffer,¨←⊂¨FormatTS¨{0::⍬ ⋄ 2 ⎕AT ⍵}¨{{⍺,'.',⍵}/⍵[4 2]}¨buffer ⍝ Last change of 2
          buffer,¨←⊂¨{0::'' ⋄ 4⊃⎕AT ⍵}¨{{⍺,'.',⍵}/⍵[3 2]}¨buffer ⍝ author of 1
          buffer,¨←⊂¨{0::'' ⋄ 4⊃⎕AT ⍵}¨{{⍺,'.',⍵}/⍵[4 2]}¨buffer ⍝ author of 2
      :EndIf
    ∇

      __Get←{0∊⍴⍵:0
          0<↑∘⍴¨Display.GetBody¨⍺∘{(⍕⍺),'.',⍵}¨⍵
      }

      IsNotScript←{
⍝ Takes a name (⍵) and returns a 1 in case it's not a script, otherwise 0
⍝ The check is performed in ⍺ (ref to a namespace)
          ⍺←#
          0::1
          ¯1≡⍺:⎕SIGNAL 11
          {0}⍺.⎕SRC ⍺.⍎⍕⍵
      }

    ∇ r←ScanCodeFoundInBothRefs(list ref1 ref2);this;body1;body2;name1;name2;buffer
    ⍝ Any stuff that is code (fns, opr, script) and exists in both, [1] and [2]
      r←''
      :For this :In list
     ⍝⍎(this≡'Server')/'.'
          body1←Display.GetBody name1←(⍕ref1),'.',this
          body2←Display.GetBody name2←(⍕ref2),'.',this
          buffer←'=≠'[1+body1 Differ body2]
          buffer,←⊂{⍵↑⍨1+-'.'⍳⍨⌽⍵}name1
          buffer,←⊂{⍵↓⍨-'.'⍳⍨⌽⍵}name1
          buffer,←⊂{⍵↓⍨-'.'⍳⍨⌽⍵}name2
          buffer,←⊂ref1.⎕NC⊂this
          buffer,←⊂ref2.⎕NC⊂this
          buffer←buffer,FormatTS¨↓2 ⎕AT name1 name2
          buffer←buffer,{⍵[;4]}⎕AT name1 name2
          :If ≠/buffer[5 6] ⍝ Even the type differs!!
              buffer[1]←'≢'
          :EndIf
          r,←⊂buffer
      :EndFor
    ∇

    ∇ {r}←ScanOrdinaryNamespacesInBothRefs(ref1 ref2);list1;list2;lista;listb;this;list
    ⍝ Loop over all ordinary (non-scripted) namespaces that exist in both, [1] and [2]
      r←⍬
      (list1 list2)←ListOrdinaryNamespaces¨ref1 ref2
      list1~←rubbishObjects1
      list2~←rubbishObjects2
      :If ~0∊↑∘⍴¨list1 list2
      :AndIf 0∧.<↑∘⍴¨⍕¨ref1 ref2 ⍝ both must be alive for that
          lista←((1+⍴⍕ref2)↓¨⍕¨list2){⍺/⍨⍺∊⍵}((1+⍴⍕ref1)↓¨⍕¨list1)
          listb←((1+⍴⍕ref1)↓¨⍕¨list1){⍺/⍨⍺∊⍵}((1+⍴⍕ref2)↓¨⍕¨list2)
          list←lista∩listb
      :AndIf ~0∊⍴list←lista∩listb
⍝          ⍎(0<+/∊'onBadValue '∘⍷¨⊂,⎕FMT report)/'.'
          :For this :In list
⍝         ⍎(∨/'Server_Code'⍷this)/'.'
              :If 9.1=⎕NC⊂(⍕ref2),'.',this
              :AndIf {11 16::1 ⋄ 0⊣⎕SRC ⍵}⍎(⍕ref2),'.',this        ⍝ pass if it is an ordinary namespace
              :AndIf ref1 ref2≢{6::⍬ ⋄ ⍎⍵}¨this∘{(⍕⍵),'.',⍺}¨ref1 ref2
                  1 ns_({6::⍬ ⋄ ⍎⍵}¨this∘{(⍕⍵),'.',⍺}¨ref1 ref2),refsAreRubbish
              :EndIf
          :EndFor
      :EndIf
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    :Class CompareData
⍝ An instance of this class holds all the data needed to compare two namespaces.
⍝ The default property is used by the GUI

        ⎕ml←0 ⋄ ⎕io←1

        ∇ r←Version
          :Access Public
          r←'1.1.0' '2013-06-05'
        ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ Start Indices ⍝⍝⍝
        :Field Public ReadOnly ∆key←1           ⍝ Unique key
        :Field Public ReadOnly ∆status←2        ⍝ =≠≡≢12...
        :Field Public ReadOnly ∆name←3
        :Field Public ReadOnly ∆path1←4         ⍝ within ref2/ref2
        :Field Public ReadOnly ∆path2←5
        :Field Public ReadOnly ∆type1←6         ⍝ 3.4, 9.1...
        :Field Public ReadOnly ∆type2←7
        :Field Public ReadOnly ∆timestamp1←8    ⍝ ⎕TS
        :Field Public ReadOnly ∆timestamp2←9
        :Field Public ReadOnly ∆author1←10      ⍝ for fns/opr only
        :Field Public ReadOnly ∆author2←11
        :Field Public ReadOnly ∆type←12         ⍝ 1 = not equal, 0 = others
        :Field Public ReadOnly ∆typeAsText1←13  ⍝ 3.1 ←→ TradFns
        :Field Public ReadOnly ∆typeAsText2←14
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ End Indices ⍝⍝⍝⍝⍝

        :Property refToContainer1
        :Access Public
            ∇ r←get
              r←refToContainer1_
            ∇
        :EndProperty

        :Property refToContainer2
        :Access Public
            ∇ r←get
              r←refToContainer2_
            ∇
        :EndProperty

        :Property default data
        :Access Public
            ∇ r←get
              r←data_
            ∇
        :EndProperty

        :Field private journal_←0 2⍴⍬

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

        ∇ make(refToContainer1 refToContainer2 data)
          :Access Public
          :Implements Constructor
          refToContainer1_←refToContainer1
          refToContainer2_←refToContainer2
          data_←data
          data_←(⍳1⊃⍴data_),data_
          data_[;4]←(1+⍴⍕refToContainer1)↓¨data_[;4]
          data_[;5]←(1+⍴⍕refToContainer2)↓¨data_[;5]
          data_,←data_[;2]≠'='
          data_,←TranslateNameclass data_[;6]
          data_,←TranslateNameclass data_[;7]
         ⍝Done
        ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

        ∇ flag←{caption}YesOrNo question;∆;ms
          caption←∆Caption{0<⎕NC ⍵:⍺,': ',⍎⍵ ⋄ ⍺}'caption'
          ∆←⊂'MsgBox'
          ∆,←⊂caption
          ∆,←⊂'Text'question
          ∆,←⊂'Style' 'Query'
          ∆,←⊂'Event'('MsgBtn1' 'MsgBtn2')1
          'ms'⎕WC ∆
          flag←'MsgBtn1'≡2⊃⎕DQ'ms'
        ∇

        ∇ r←∆equals
          :Access Public
          r←{⍵/⍳⍴,⍵}data_[;∆type]
        ∇

        ∇ r←∆nonequals
          :Access Public
          r←{⍵/⍳⍴,⍵}~data_[;∆type]
        ∇

        ∇ r←GetRowById id
          :Access Public
          r←data_[data_[;∆key]⍳id;]
        ∇

        ∇ {where}←SaveRow row
          :Access Public
          row←(¯2↑1 1,⍴row)⍴row
          where←data_[;∆key]⍳row[;1]
          data_[where;]←row
        ∇

        ∇ RemoveRow id;bool
          :Access Public
          bool←data_[;∆key]≠id
          data_←bool⌿data_
        ∇

        ∇ r←GetObjNames id;where;path
          :Access Public
      ⍝ Return both names fully qualified
          :If ⍬≡⍴where←data_[;∆key]⍳id
              path←{
                  0=+/l←⊃∘⍴¨⍵:''
                  ⊃⍵/⍨0<l}data_[where;∆path1 ∆path2]
              r←(⍕¨refToContainer1_ refToContainer2_),¨⊂((~0∊⍴path)/'.'),path,'.',∆name⊃data_[where;]
              ⍝ The following gymnastics is needed in order to overcome stupid mistakes like setting
              ⍝ the ⎕DF of a class or a namespace or the like to, say, #.Foo. That won't work here
              ⍝ because we may have copied the objects in question somewhere else, for example into
              ⍝ ⎕SE.HoldWorkspaces.
              r←{(9≠⎕NC ⍵):⍵ ⋄ ⍵{_←⍵.⎕DF ⎕NULL ⋄ ⍕⍵}⍎⍵}¨r
          :Else
              r←↓⍉↑GetObjNames¨id
          :EndIf
        ∇

        ∇ Remove id;where
          :Access Public
      ⍝ Remove an entry from the data structur
          data_←(~data_[;∆key]∊id)⌿data_
          AddRemark id'Removed from the comparison data alltogether'
        ∇

        ∇ AddRemark(id remark)
          :Access Public
      ⍝ Add a vector of lenght two (id, remark) to "journal_"
          journal_⍪←↑(⊂¨id),¨⊂¨(⍴id)⍴⊂remark
 ⍝Done
        ∇

        ∇ r←GetRemark id
          :Access Public
        ⍝ Get all remarks of "id". If "id" is empty, all remarks are returned
          r←journal_
          :If ~0∊⍴id
              r←(r[;1]∊id)⌿r
          :EndIf
        ∇

        ∇ r←GetScreenData lines;where
          :Access Public
        ⍝ Get the data.
        ⍝ Copy path2 to path1 where path1 is empty, then get rid of path2
          r←data_[lines;]
          where←{⍵/⍳⍴,⍵}('2'=r[;∆status])∧0=⊃∘⍴¨r[;∆path1]
          r[where;∆path1]←r[where;∆path2]
          r←r[;∆key,∆status ∆name ∆path1 ∆typeAsText1 ∆typeAsText2 ∆author1 ∆author2]
        ∇

        ∇ r←TranslateNameclass numbers;nos;names
          nos←0 2.1 2.2 2.3 2.6 3.1 3.2 3.3 3.6 4.1 4.2 8.6 9.1 9.2 9.4 9.5 9.6 9.7
          names←'' 'Vars' 'Field' 'Property' 'External/shared vars' 'TradFns' 'DynFns' 'Idiom' 'External Fns' 'TradOpr' 'DynOpr' 'External Event' 'namespace (⎕NS)' 'Instance' 'Class' 'Interface' 'External Class' 'External Interface'
          r←names[nos⍳|numbers]
        ∇

        ∇ r←typeAsText no
          r←TranslateNameclass data
        ∇

    :EndClass

    ∇ r←fno DisplayList(caption data info lastItemWas preSelect);∆;res;f;bool
      r←⍬
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
      ∆,←⊂'Items'({2=⍴⍴⍵:↓⎕FMT ⍵ ⋄ ⍕¨⍵}data)
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

      OnDelChangeFile←{
          0=YesOrNo'Sure you want delete the change file?':⍬
          _←(⎕FNAMES[⍬⍴⎕FNUMS⍳fno;])⎕FERASE fno
          f.Close
      }

    ∇ bool←a Differ b;between;b1;b2
⍝ Ignore <tab> characters and blanks which are not enclosed by qoutes
⍝ before doing the comparison
      bool←1 ⍝ yes they differ
      a←1↓⊃,/⎕TC[2],¨a
      b←1↓⊃,/⎕TC[2],¨b
      between←{⍺←'''' ⋄ {⍵∨≠\⍵}⍺=⍵}
      b1←between a
      b2←between b
      :If (+/b1)=+/b2
      :AndIf (b1/a)≡b2/b
          a←(~b1)/a
          b←(~b2)/b
          a←a~' ',⎕AV[10]
          b←b~' ',⎕AV[10]
          bool←a≢b
      :EndIf
    ∇

    ∇ r←OnContextMenu msg;m;res;i2;filename1;i3;no1;no2;title1;body1;body2;title2;filename2;question;no;body;title;mm;cs
      r←0
      m←⎕NEW⊂'Menu'
      m.(i1←⎕NEW'MenuItem'(⊂'Caption' 'Compare selected'))
      m.i1.onSelect←1
      m.i1.no←1
      m.(i2←⎕NEW'MenuItem'(⊂'Caption' 'Compare with workspace'))
      m.i2.onSelect←1
      m.i2.no←2
⍝ m.(i3←⎕NEW'MenuItem'(⊂'Caption' 'Get version into workspace'))
⍝ m.i3.onSelect←1
⍝ m.i3.no←3
      m.(i4←⎕NEW'MenuItem'(⊂'Caption' 'Edit workspace version'))
      m.i4.onSelect←1
      m.i4.no←4

      :If ~0∊⍴res←m.Wait
          :Select ↑{⍵.no}1⊃res
          :Case 1
              :If 0∊+/¨f.sfTop.(right left).SelItems
                  mm←⎕NEW'MsgBox'(('Caption' 'Compare')('Text' 'Please select one item on each side'))
                  mm.Wait
              :Else
                  no1←f.sfTop.left.SelItems⍳1
                  no2←f.sfTop.right.SelItems⍳1
                  body1←4⊃no1⊃versions
                  title1←{'Version ',(⍕1⊃⍵),' from ',(2⊃⍵),' ',(3⊃⍵),' by ',4⊃⍵}meta[no1;]
                  body2←4⊃no2⊃versions
                  title2←{'Version ',(⍕1⊃⍵),' from ',(2⊃⍵),' ',(3⊃⍵),' by ',4⊃⍵}meta[no2;]
                  filename1←refToUtils.WinFile.GetTempPath,(' '~⍨⍕⎕TS),(⍕?1000),'_',⎕AN,'.txt'
                  WriteUtf8File filename1 body1
                  filename2←refToUtils.WinFile.GetTempPath,(' '~⍨⍕⎕TS),(⍕?1000),'_',⎕AN,'.txt'
                  WriteUtf8File filename2 body2
                  RunCompareIt filename1 filename2 1 title1 title2
              :EndIf
          :Case 2
              wanted←(⍎' f.sfTop.',({⍵.name}1⊃msg),'.SelItems')⍳1
              wanted←⍎wanted⊃⍎' f.sfTop.',({⍵.name}1⊃msg),'.Items'
              no1←meta[;1]⍳wanted
              body1←4⊃no1⊃versions
              title1←{'Version ',(⍕1⊃⍵),' from ',(2⊃⍵),' ',(3⊃⍵),' by ',4⊃⍵}meta[no1;]
              filename1←refToUtils.WinFile.GetTempPath,(' '~⍨⍕⎕TS),(⍕?1000),'_',⎕AN,'.txt'
              WriteUtf8File filename1 body1
              cs←CreateParmsFor_These
              cs.alias1←title1
              cs.alias2←name
              cs These name filename1
          :Case 3
              . ⍝ This code is experimental and not ready anyway!!
              no←(⍎' f.sfTop.',({⍵.name}1⊃msg),'.SelItems')⍳1
              wanted←⍎no⊃⍎' f.sfTop.',({⍵.name}1⊃msg),'.Items'
              no←({⍎⍵↑⍨¯1+⍵⍳' '}¨{⍵↓⍨+/∧\' '=⍵}¨versions)⍳wanted
              (body title)←(⎕UCS 13){⌽¨⍺ SplitPath⌽⍵}no⊃versions
              question←'Copy ',title,' to workspace?'
              :If 'Get version into workspace'YesOrNo question
                  .
              :EndIf
          :Case 4
              ⎕ED name
          :Else
              . ⍝ Huuh?!
          :EndSelect
      :EndIf
    ∇

    :Class Display
    ⍝ This namespace exists only to circumvent a Dyalog bug which currently
    ⍝ prevents us from doing TabControls from within class instances.
    ⍝ For that reason, all stuff associated with the GUI front-end of the
    ⍝ class "Compare" was moved into the scripted namespace "Display" which
    ⍝ is used from within "Compare" when the method Compare.DisplayDiff is
    ⍝ called.
        (⎕IO ⎕ML ⎕DIV)←1 0 1
        :Include ##.APLTreeUtils
        ∆Caption←'Merge'
        ∆Hits←⍬
        ∆SearchFor←''

          OnReport←{
              Report
        ⍝Done
          }

        ∇ Report;fn1;fn2;rf;rep;thisContainer;i;thisObj;body;thisFile;_;buf;title1;title2;A;W
        ⍝ Produces a report regarding the differnces with CompareIt!
          A←##.refToUtils.APLTreeUtils
          W←##.refToUtils.WinFile
          fn1←W.GetTempFileName''
          fn2←W.GetTempFileName''
          rep←FF.f.tc.sf2.list.ReportInfo
          rep←rep[⍋'≠12'⍳rep[;1];]                                  ⍝ Change sort sequence to make it more convinient
          rep←↑{(⍵[1])((3⊃⍵),((~0∊⍴3⊃⍵)/'.'),2⊃⍵)}¨↓rep[;1 2 3]     ⍝ We nedd just type and full path
          :For thisFile thisContainer :InEach (fn1 fn2)(ref1 ref2)
              :For i :In ⍳rep[;1]+.='≠'
                  thisObj←2⊃rep[i;]
                  :Select ⊃thisContainer.⎕NC thisObj
                  :CaseList 3 4
                      body←thisContainer.⎕NR thisObj
                  :Case 9
                      body←thisContainer.⎕SRC thisContainer.⍎thisObj
                  :Case 0
                      body←⊂' ... '
                  :Else
                      . ⍝ Huuh?!
                  :EndSelect
                  body←(⊂(10⍴'*'),' ',thisObj),body
                  :Trap 11
                      'append'A.WriteUtf8File thisFile body
                  :Else
                      'append'A.WriteUtf8File thisFile(⊂'Could not write ',thisObj)
                  :EndTrap
              :EndFor
          :EndFor
          title1←2⊃'.'A.SplitPath⍕ref1
          title2←2⊃'.'A.SplitPath⍕ref2
          :If 0<'1'+.=rep[;1]
              buf←⊂(10⍴'*'),' Found only in ',title1
              buf,←'#.'∘,¨('1'=rep[;1])⌿rep[;2]
              'append'A.WriteUtf8File fn1 buf
          :EndIf
          :If 0<'2'+.=rep[;1]
              buf←⊂(10⍴'*'),' Found only in ',title2
              buf,←'#.'∘,¨('2'=rep[;1])⌿rep[;2]
              'append'A.WriteUtf8File fn2 buf
          :EndIf
          ##.RunCompareIt fn1 fn2 1 1 title1 title2
        ∇

        ∇ Compare(row ref readOnly);parms;name1;name2;id;rc
          :If 1=1⊃⍴row
              '.'⎕WS'Cursor' 1
              id←1⊃row←row[1;]
              (name1 name2)←refToDiff.GetObjNames id
              :If 0∧.<⎕NC↑name1 name2
                  parms←##.CreateParmsFor_These
                  parms.readOnly1←readOnly[1]
                  parms.readOnly2←readOnly[2]
                  parms.alias1←name1
                  parms.alias2←name2
                  :If 1⊃parms ##.These name1 name2
                      refToDiff.AddRemark id'[1] changed'
                  :EndIf
              :EndIf
              '.'⎕WS'Cursor' 0
          :EndIf
        ∇

        ∇ flag←{caption}YesOrNo question;∆;ms
          caption←∆Caption{0<⎕NC ⍵:⍺,': ',⍎⍵ ⋄ ⍺}'caption'
          ∆←⊂'MsgBox'
          ∆,←⊂caption
          ∆,←⊂'Text'question
          ∆,←⊂'Style' 'Query'
          ∆,←⊂'Event'('MsgBtn1' 'MsgBtn2')1
          'ms'⎕WC ∆
          flag←'MsgBtn1'≡2⊃⎕DQ'ms'
        ∇

        ∇ Copy(from to row objName);fromName;body;ref;tabNo;toName;parentPath;id;mm;i;thisFromName;thisToName;LastLine;refToList;rc;flag;msg;res;line;objRef
     ⍝ Copy everything (including classes, scripted namespace and interfaces) _
     ⍝ from "from" toName "toName"
          tabNo←GetTabNo objName
          id←row[;I.∆key]
          fromName←from⊃refToDiff.GetObjNames id
          toName←to⊃refToDiff.GetObjNames id
          flag←¯1
          :If 0∊⊃∘⎕NC¨fromName
              'mm'⎕WC'MsgBox'(∆Caption,': Copy')'I am sorry, but there is nothing we could copy!'('Style' 'Info')
              ⎕DQ'mm'
          :Else
              msg←'Sure that you want copy:'('  ',⊃fromName)('from ',(⍕from),' to ',(⍕to),'?')
              :If 0='Copy:'YesOrNo msg
                  :Return
              :EndIf
              ref←⍎objName
              :For i :In ⍳⍴fromName
                  thisFromName←i⊃fromName
                  thisToName←i⊃toName
                  :If 3 4∊⍨⎕NC thisFromName ⍝ fns or opr?
                      :If 0=⎕NC parentPath←{⍵↓⍨-'.'⍳⍨⌽⍵}thisToName
                          parentPath ⎕NS''
                      :EndIf
                      parentPath ⎕NS thisFromName
                  :ElseIf {0::0 ⋄ 0<⍴⎕SRC⍎⍵}thisFromName ⍝ Scripted?
                      body←⎕SRC⍎thisFromName
                      :If 0=⎕NC parentPath←{⍵↓⍨-'.'⍳⍨⌽⍵}thisToName
                          parentPath ⎕NS''
                      :EndIf
                      :Trap 0
                          (⍎parentPath).⎕FIX body
                      :Else
                          '[]FIX failed'ShowMsg'Couldn''t []FIX the script - the status window is likely to display information about the reason why' '' 'Try to fix the problem and then try again'
                          :Return
                      :EndTrap
                  :EndIf
                  :If flag≡¯1 ⍝ ask only once
                      flag←'Copied'YesOrNo'Remove from list?'
                  :EndIf
                  :If flag
                      refToDiff.RemoveRow i⊃id
                  :Else
                      row←refToDiff.GetRowById i⊃id
                      row[to⊃I.(∆type1 ∆typeAsText1)I.(∆type2 ∆typeAsText2)]←row[from⊃I.(∆type1 ∆typeAsText1)I.(∆type2 ∆typeAsText2)]
                      row[to⊃I.∆author1 I.∆author2]←row[from⊃I.∆author1 I.∆author2]
                      row[2]←'='
                      row[4 5]←2⍴row[4 5]~''⍬
                      refToDiff.SaveRow row
                  :EndIf
              :EndFor
              refToList←⍎(1+⍴⍕⎕THIS)↓⍕FF.f.tc.T2.TabObj
              LastLine←1⌈1⊃{⍵/⍳⍴,⍵}{⍵.list.SelItems}refToList
              Write ref refToDiff((GetTabNo objName)⊃I.∆nonequals I.∆equals)
              EnsureVisibleLine refToList.list LastLine
              :If LastLine>1
                  refToList.list.SelItems[LastLine⌊⍴refToList.list.SelItems]←1
              :EndIf
              refToDiff.AddRemark id('Copied from ',(⍕from),'→',⍕to)
          :EndIf
        ∇

        ∇ CorrectColSize ref
     ⍝ Enlarge colsize comfortably
          ref{2 ⎕NQ ⍺'SetColSize'⍵ ¯3}¨⍳1+2⊃⍴ref.ReportInfo
        ∇

        ∇ r←{giveFocusTo}DQ name
          :If 0=⎕NC'giveFocusTo'
              r←⎕DQ name
          :Else
              2 ⎕NQ(⍕giveFocusTo)'GotFocus' ⋄ r←⎕DQ name
          :EndIf
     ⍝
        ∇

        ∇ Delete(id objName);∆;Del_F;caption;ref;first;objName1;objName2
        ⍝ This dialog allows the user to specify from which source he wants to delete items, if at all
          (objName1 objName2)←refToDiff.GetObjNames id

          ∆←⊂'Form'
          ∆,←⊂'Coord' 'Pixel'
          ∆,←⊂'Size'(200 300)
          ⍝∆,←⊂'Icon'AppIcon
          ∆,←⊂'Caption' 'Delete'
          ∆,←⊂'MaxButton' 0
          ∆,←⊂'MinButton' 0
          ∆,←⊂'Sizeable' 0
          ∆,←⊂'Event' 9999 1
          'Del_F'⎕WC ∆

          ref←⍎objName  ⍝ Ref to the ListView
          :If 1=+/ref.SelItems
              caption←'Delete ',({0∊⍴1⊃⍵~' ':2⊃⍵ ⋄ (1⊃⍵),'.',2⊃⍵}ref.ReportInfo[↑ref.SelItems⍳1;3 2]),' from...'
          :Else
              caption←'Delete ',(⍕+/ref.SelItems),' items from...'
          :EndIf
          ∆←⊂'Label'
          ∆,←⊂'Caption'caption
          ∆,←⊂'Posn'(15 15)
          'Del_F.label'⎕WC ∆

          ∆←⊂'Button'
          ∆,←⊂'Caption' '&1'
          ∆,←⊂'Posn'(60 15)
          ∆,←⊂'Style' 'Radio'
          ∆,←⊂'Active'(0∨.<⎕NC objName1)
          'Del_F.from1'⎕WC ∆

          ∆←⊂'Button'
          ∆,←⊂'Caption' '&2'
          ∆,←⊂'Posn'(85 15)
          ∆,←⊂'Style' 'Radio'
          ∆,←⊂'Active'(0∨.<⎕NC objName2)
          'Del_F.from2'⎕WC ∆

          ∆←⊂'Button'
          ∆,←⊂'Caption' '&both, 1 and 2'
          ∆,←⊂'Posn'(110 15)
          ∆,←⊂'Style' 'Radio'
          ∆,←⊂'Active'(0∧.≠⎕NC↑⍕¨objName1 objName2)
          'Del_F.fromBoth'⎕WC ∆

          ∆←⊂'Button'
          ∆,←⊂'Caption' 'OK'
          ∆,←⊂'Posn'((Del_F.Size[1]-35),5)
          ∆,←⊂'Size'(30 100)
          ∆,←⊂'Default' 1
          'Del_F.ok'⎕WC ∆
          Del_F.ok.onSelect←'OnDeleteOkay'

          ∆←⊂'Button'
          ∆,←⊂'Caption' 'Cancel'
          ∆,←⊂'Posn'(Del_F.Size-35 105)
          ∆,←⊂'Size'(30 100)
          ∆,←⊂'Cancel' 1
          ∆,←⊂'Event' 'Select' 1
          'Del_F.cancel'⎕WC ∆

          first←{1⊃⍵/⍨⍵.Active}Del_F.from1 Del_F.from2 Del_F.fromBoth ⍝ first active control?
          first.State←1
          ⎕NQ Del_F'GotFocus'first ⋄ ⎕DQ'Del_F'
          ⍝Done
        ∇

        ∇ OnDeleteOkay msg;type;refs
          refs←⍎¨'Del_F.from1' 'Del_F.from2' 'Del_F.fromBoth'
          type←refs.State⍳1
          :If 3=type ⍝ That's both
              DeleteFromWorkspace id objName
          :Else
              DeleteSingle type id objName
          :EndIf
          ⎕NQ Del_F 9999
        ∇

        ∇ DeleteFromWorkspace(id objName);ref;tabNo;row;name1;name2;name;∆;rc
    ⍝ Delete all selected objects from both sources
          ref←⍎objName
          tabNo←GetTabNo objName
          row←refToDiff.GetRowById id
          (name1 name2)←refToDiff.GetObjNames id
          name←row[;I.∆name]
          ⎕EX¨name1
          ⎕EX¨name2
          refToDiff.Remove id
          {Write ref refToDiff ⍵}¨I.∆nonequals I.∆equals
          refToDiff.AddRemark id'Deleted from workspace'
          :If 1=⍴name
              FF.f.sb.Info.Text←'Deleted: ',name
          :Else
              FF.f.sb.Info.Text←(⍕⍴name),' objects deleted'
          :EndIf
        ∇

        ∇ DeleteSingle(from id objName);data;ref;name1;name2;row;list;where;buffer;tabNo
     ⍝ Delete one or more objects from "from" (= a single source)
          ref←⍎objName
          tabNo←GetTabNo objName
          row←refToDiff.GetRowById id
          (name1 name2)←refToDiff.GetObjNames id
          ⎕EX↑from⊃name1 name2
          :If 0=+/⎕NC↑name1,name2
              refToDiff.Remove id
          :Else
              row[;from⊃I.(∆type1 ∆typeAsText1)I.(∆type2 ∆typeAsText2)]←⊂''
              row[;I.∆status]←⊃¨({0<⊃∘⎕NC¨⍵}¨↓name1,[1.5]name2)/¨⊂'12'
              refToDiff.SaveRow row
          :EndIf
          Write ref refToDiff(tabNo⊃I.∆nonequals I.∆equals)
          refToDiff.AddRemark¨id,¨⊂⊂('Deleted from [',(⍕from),']')
          :If 1=1⊃⍴row
              FF.f.sb.Info.Text←'Deleted from [',(⍕from),']: ',I.∆name⊃row[1;]
          :Else
              FF.f.sb.Info.Text←(⍕1⊃⍴row),' deleted from [',(⍕from),']'
          :EndIf
        ∇

        ∇ {FF}←Diff(refToDiff readOnly versioNo rubbish);ref1;ref2;I;FF;res
     ⍝ refToDiff is a data structure created by "Merge"
     ⍝ Note that this gets changed by "Display": all actions are logged on the "Journal".
     ⍝ ref1 and ref2: what got compared (for building an appropriate caption).
          :Access Public Shared
          Init readOnly
          (ref1 ref2)←refToDiff.(refToContainer1 refToContainer2)
          I←refToDiff ⍝ for indexing only
          FF←CreateDiffGui ref1 ref2 I versioNo readOnly refToDiff
          :If ∧/~¯2∊readOnly
              ShowRubbishWarning rubbish FF.f.Posn
          :EndIf
          :If ∧/~¯2∊readOnly
              res←'FF.f.tc.sf2.list'DQ'FF.f'
          :EndIf
      ⍝Done
        ∇

        ∇ FF←CreateDiffGui(ref1 ref2 I versioNo readOnly refToDiff);caption;colTitles;parms
          'FF'⎕NS''
          caption←∆Caption,' ',(⍕versioNo),': ',(⍕ref1),' [1] :: ',(⍕ref2),' [2]'
          colTitles←'ID' '?' 'Name' 'Path' 'Type 1' 'Type 2' 'Author 1' 'Author 2'

          'FF.aplFnt'⎕WC'Font' 'APL385 Unicode'
          parms←⊂'Form'
          parms,←⊂'Coord' 'Pixel'
          parms,←⊂'Posn'(65 35)
          parms,←⊂'Size'(660 1000)
          parms,←⊂'Caption'caption
          parms,←⊂'Icon' 'AppIcon'
          'FF.f'⎕WC parms

          'FF.f.tc'⎕WC'TabControl'('Attach'('Top' 'Left' 'Bottom' 'Right'))('TabFocus' 'Never')
          FF.f.tc.Size-←30 0

          'FF.f.tc.T1'⎕WC'TabButton' '='
          'FF.f.tc.T2'⎕WC'TabButton' '≠'

          'FF.f.tc.sf1'⎕WC'SubForm'('TabObj' 'FF.f.tc.T1')
          'FF.f.tc.sf2'⎕WC'SubForm'('TabObj' 'FF.f.tc.T2')

          'FF.f.mb'⎕WC'Menubar'

          'FF.f.mb.file'⎕WC'Menu' '&File'
          'FF.f.mb.file.quit'⎕WC'MenuItem' 'Quit'('Event' 'Select' 1)('Accelerator'(115 4))

          'FF.f.mb.edit'⎕WC'Menu' '&Edit'
          'FF.f.mb.edit.search'⎕WC'MenuItem' 'Search'('Event' 'Select' 'OnSearch')('Accelerator'(70 2))
          :If ∨/~readOnly∊1 ¯1 ¯2
              'FF.f.mb.edit.show'⎕WC'MenuItem' 'Show journal'('Event' 'Select' 'Show')
          :EndIf
          'FF.f.mb.edit.report'⎕WC'MenuItem' 'Report different code'('Event' 'Select' 'OnReport')

          'FF.f.mb.help'⎕WC'Menu' '&Help'
          'FF.f.mb.help.help'⎕WC'MenuItem' 'Help'('Event' 'Select' 'OnHelp')('Accelerator'(112 0))
          'FF.f.mb.help.sep1'⎕WC'Separator'
          'FF.f.mb.help.about'⎕WC'MenuItem' 'About'('Event' 'Select' 'OnAbout')

          parms←⊂'ListView'
          parms,←⊂'Coord' 'Prop'
          parms,←⊂'Posn'(0 0)
          parms,←⊂'Size'(100 100)
          parms,←⊂'View' 'Report'
          parms,←⊂'FullRowSelect' 1
          parms,←⊂'Style' 'Multi'
          parms,←⊂'DragItems' 0
          parms,←⊂'3D' 'Recess'
          parms,←⊂'GridLines' 1
          parms,←⊂'Event' 'ItemDown' 'OnItemDown' 1
          parms,←⊂'Event' 9999 'OnItemDown' 1
          :If ~readOnly[1]∊1 ¯1 ¯2
              parms,←⊂'Event' 'ItemDblclick' 'OnItemDblClick' 1
          :EndIf
          parms,←⊂'Event' 'ContextMenu' 'OnContextMenu' 1
          parms,←⊂'Event' 'KeyPress' 'OnKeyPress'
          parms,←⊂'Event' 'ColumnClick' 'OnColSort'
          parms,←⊂'ColTitles'colTitles
          parms,←⊂'FontObj' 'FF.aplFnt'
          'FF.f.tc.sf1.list'⎕WC parms
          Write FF.f.tc.sf1.list refToDiff I.∆nonequals
          CorrectColSize FF.f.tc.sf1.list

          parms←⊂'ListView'
          parms,←⊂'Coord' 'Prop'
          parms,←⊂'Posn'(0 0)
          parms,←⊂'Size'(100 100)
          parms,←⊂'View' 'Report'
          parms,←⊂'FullRowSelect' 1
          parms,←⊂'Style' 'Multi'
          parms,←⊂'DragItems' 0
          parms,←⊂'3D' 'Recess'
          parms,←⊂'GridLines' 1
          parms,←⊂'Event' 'ItemDown' 'OnItemDown' 2
          :If ~readOnly[2]∊1 ¯2 ¯1
              parms,←⊂'Event' 'ItemDblclick' 'OnItemDblClick' 2
          :EndIf
          parms,←⊂'Event' 'ContextMenu' 'OnContextMenu' 2
          parms,←⊂'Event' 9999 'OnItemDown' 2
          parms,←⊂'Event' 'KeyPress' 'OnKeyPress'
          parms,←⊂'Event' 'ColumnClick' 'OnColSort'
          parms,←⊂'ColTitles'colTitles
          parms,←⊂'FontObj' 'FF.aplFnt'
          'FF.f.tc.sf2.list'⎕WC parms
          Write FF.f.tc.sf2.list refToDiff I.∆equals
          CorrectColSize FF.f.tc.sf2.list

          'FF.f.sb'⎕WC'StatusBar'('Attach'('Bottom' 'Left' 'Bottom' 'Right'))
          'FF.f.sb.ts1'⎕WC'StatusField'('Size'(⍬)140)('Caption' 'TS1: ')
          'FF.f.sb.ts2'⎕WC'StatusField'('Size'(⍬)140)('Caption' 'TS2: ')
          'FF.f.sb.name'⎕WC'StatusField'('Size'(⍬)180)('Caption' 'Name: ')
          'FF.f.sb.Info'⎕WC'StatusField'('Size'((⊂⍬),FF.f.Size[2]-10+2⊃⊃+/FF.f.sb.name.(Posn Size)))('Attach'('Bottom' 'Left' 'Bottom' 'Right'))

          'FF.f.close'⎕WC'Button' 'Close'('Cancel' 1)('Size'(5 5))('Attach'(4⍴'Top' 'Left'))('Event' 'Select' 1)('Posn'(¯10 ¯10))
          FF.f.tc.Size+←1 ⋄ ⎕DL 0.01 ⋄ FF.f.tc.Size-←1  ⍝ To circumvent the ugly display of the ColTitles
        ∇

        ∇ {r}←ShowRubbishWarning(rubbish mainFormPosn);∆;n
    ⍝ If "rubbish" is not empty a warning is shown.
    ⍝ This is about references to unnamed namespaces, instances & attached namespaces.
          r←⍬
          :If ~0∊⍴rubbish
              n←⎕NS''
              ∆←''
              ∆,←⊂'Caption' 'Rubbish Report'
              ∆,←⊂'Coord' 'Pixel'
              ∆,←⊂'Posn'(30 30+mainFormPosn)
              ∆,←⊂'Size'(400 500)
              ∆,←⊂'Event'(9999 1)
              n.Form←⎕NEW'Form'∆

              n.MB←n.Form.⎕NEW(,⊂'Menubar')
              n.CmdMenu←n.MB.⎕NEW'Menu'(,⊂'Caption' 'Commands')
              n.PrintMenuCmd←n.CmdMenu.⎕NEW'MenuItem'(,⊂'Caption' 'Print )Erase to session')
              n.PrintMenuCmd.onSelect←'OnPrintMenuCmd'
              n.Font←⎕NEW'Font'(('Pname' 'APL385 Unicode')('Size' 16))

              ∆←''
              ∆,←⊂'Coord' 'Prop'
              ∆,←⊂'Posn'(0 0)
              ∆,←⊂'Size'(100 100)
              ∆,←⊂'Attach'('Top' 'Left' 'Bottom' 'Right')
              ∆,←⊂'ReadOnly' 1
              ∆,←⊂'Font'n.Font
              ∆,←⊂'Style' 'Multi'
              ∆,←⊂'Text'(dtb rubbish)
              ∆,←⊂'Event'(9999 1)
              ∆,←⊂'VScroll' ¯1
              n.Show←n.Form.⎕NEW'Edit'∆

              ∆←''
              ∆,←⊂'Caption' 'Close'
              ∆,←⊂'Size'(⍬ 110)
              ∆,←⊂'Default' 1
              ∆,←⊂'Cancel' 1
              ∆,←⊂'Event'('Select' 1)
              ∆,←⊂'Attach'(4⍴'Bottom' 'Left')
              n.Close←n.Form.⎕NEW'Button'∆
              n.Close.Posn←(n.Form.Size[1]-n.Close.Size[1]+5),5

              n.Show.Coord←'Pixel'
              n.Show.Size[1]-←10+n.Close.Size[1]

              ⎕NQ n.Show'GotFocus' ⋄ ⎕DQ n.Form

          :EndIf
        ∇

        ∇ Edit(row objName);nameList;oldBody2;oldBody1;id;i;newBodies;objRef;tabNo;line;flag
          :If 1=1⊃⍴row
              objRef←GetCurrentTab'list'
              tabNo←GetCurrentTabno
              id←1⊃row←row[1;]
              line←(⍎¨objRef.Items)⍳id
              nameList←refToDiff.GetObjNames id
              (oldBody1 oldBody2)←0 GetBody¨nameList
              nameList←(0<⎕NC nameList)⌿nameList
              ⎕ED↑nameList
              ⎕NQ({~(1⍴⍵)∊'#⎕':⍵ ⋄ (1+⍴⍕⎕THIS)↓⍵}objName)'GotFocus'
              newBodies←0 GetBody¨nameList
              :If oldBody1≢1⊃newBodies
                  :If 0∊⍴oldBody1
                      refToDiff.AddRemark id'Added to [2]'
                  :Else
                      refToDiff.AddRemark id'Changed in [2]'
                  :EndIf
              :EndIf
              :If 2=⍴nameList
                  :If oldBody2≢2⊃newBodies
                      :If 0∊⍴oldBody2
                          refToDiff.AddRemark id'Added to [2]'
                      :Else
                          refToDiff.AddRemark id'Changed in [2]'
                      :EndIf
                  :EndIf
                  :If (0<⍴1⊃newBodies)∧flag←≡/newBodies
                      objRef.ReportInfo[line;1]←'=' ⍝ Now they match; (we don't move them)
                  :ElseIf flag
                      :Select 0<⎕NC↑nameList
                      :Case 0 0
                          objRef.ReportInfo[line;1]←'-'
                      :Case 1 0
                          objRef.ReportInfo[line;1]←'1'
                      :Case 0 1
                          objRef.ReportInfo[line;1]←'2'
                      :Else
                          . ⍝ Huuh?!
                      :EndSelect
                  :EndIf
              :EndIf
          :EndIf
        ∇

        ∇ ref←GetCurrentTab postfix;name
     ⍝ Returns a reference to the currently selected tab
          name←'FF.f.tc.sf',¯1↑⍕FF.f.tc.TabObj
          :If ~0∊⍴postfix
              name,←'.',postfix
          :EndIf
          ref←⍎name
     ⍝Done
        ∇

        ∇ no←GetCurrentTabno;name
     ⍝ Returns the number (1 or 2) of the currently selected tab
          no←¯1↑⍕FF.f.tc.TabObj
        ∇

        ∇ r←GetId objRef
     ⍝ Return id(s) of currently selected line(s) or 0
          :If 0∊⍴r←objRef.(SelItems/Items)
              r←0
          :Else
              r←⍎¨r,¨⊂' +0'
          :EndIf
        ∇

        ∇ r←GetTabNo objName
     ⍝ Returns the tab number from the objName
     ⍝ The rule is: any object name looke like:
     ⍝ either f.tc.sf1.list or f.tc.sf2.list
     ⍝ But watch for full refences!!
          r←{⍵⊂⍨'.'=⍵}⍕objName
          r⊃⍨←1⍳⍨∨/¨'.sf'∘⍷¨r
          r←⍎¯1↑r
        ∇

        ∇ Init readOnly
          ∆Caption←(1+∨/readOnly∊1 ¯1 ¯2)⊃'Merge' 'Compare'
          ∆Hits←⍬
          ∆SearchFor←''
        ∇

        ∇ r←{trapFlag}GetBody name
          :Access Public Shared
       ⍝ Returns fns- or opr-body or script- or interface body or ⍬ (namespace)
          trapFlag←{0<⎕NC ⍵:⍎⍵ ⋄ 1}'trapFlag'
          r←⍬
          :If 9=⎕NC name
              :Trap 0
                  r←⎕SRC⍎name
                  r←{⍵↓⍨-+/∧\' '=⌽⍵}¨r
              :Else
                  r←⍬ ⍝ it is a namespace, but not a scripted one
              :EndTrap
          :ElseIf 0<⎕NC name
              r←⎕NR name
          :Else
              r←⍬   ⍝ It's presumably a ref pointing into nowhere land...
          :EndIf
          :If 2<|≡r         ⍝ That would be a composition of a left argument, the ∘ ops and a fns
              r←↓⎕FMT r
          :EndIf
        ∇

        ∇ OnAbout;ff;txt;myFnt
          'myFnt'⎕WC'Font' 'APL385 Unicode'('Size' 20)
          'ff'⎕WC'Form'(∆Caption,': About')('Coord' 'Pixel')('Posn'(75 45))('Size'(140 500))
          'ff.e'⎕WC'Edit'('Coord' 'Prop')('Posn'(0 0))('Size'(100 100))('Style' 'Multi')('Event' 'GotFocus' 'OnGotFocus')('FontObj' 'myFnt')
          txt←''
          txt,←⊂∆Caption,' application'
          txt,←⊂''
          txt,←⊂'Version ',⊃{⍺,' from ',⍵}/##.Version
          txt,←⊂'Written by Kai Jaeger'
          txt,←⊂''
          txt,←⊂'See http://aplwiki.com/Compare'
          ff.e.Text←txt
          'ff.close'⎕WC'Button' 'Close'('Posn'(¯10 ¯10))('Size'(2 2))('Cancel' 1)('Event' 'Select' 1)('Attach'(4⍴'Top' 'Left'))
          ⎕DQ'ff'
      ⍝Done
        ∇

        ∇ OnColSort msg;objName;Event;ColNo;Btn;ShiftState;ref;sortIndex
          (objName Event ColNo Btn ShiftState)←5↑msg
          ref←⍎objName
          :If ShiftState=0 ⍝ ascent
              sortIndex←⎕AV⍋{∧/∧/⍵∊⎕D,' ':⍵⌽⍨+/∧\' '≠⍵ ⋄ ⍵}↑ref.(Items,ReportInfo)[;ColNo]
              ref.Items←ref.Items[sortIndex]
              ref.ReportInfo←ref.ReportInfo[sortIndex;]
          :ElseIf 2=ShiftState ⍝ descent
              sortIndex←⎕AV⍒{∧/∧/⍵∊⎕D,' ':⍵⌽⍨+/∧\' '≠⍵ ⋄ ⍵}↑ref.(Items,ReportInfo)[;ColNo]
              ref.Items←ref.Items[sortIndex]
              ref.ReportInfo←ref.ReportInfo[sortIndex;]
          :EndIf
        ∇

        ∇ r←data OnContextMenu msg;objName;ref;mm;res;row;objName1;objName2;ms;tab;tabNo;id
          r←0
          tab←⎕UCS 9
          ref←⍎objName←1⊃msg
          tabNo←GetTabNo objName
          :If (⊂objName)∊'FF.f.tc.sf1.list' 'FF.f.tc.sf2.list'
          :AndIf 0<+/ref.SelItems
              id←GetId ref
              row←refToDiff.GetRowById id
              (objName1 objName2)←refToDiff.GetObjNames id
              'mm'⎕WC'Menu'
              'mm.cancel'⎕WC'MenuItem' 'Cancel'
              'mm.sep1'⎕WC'Separator'
              :If ~∨/readOnly∊1 ¯1 ¯2
                  'mm.edit'⎕WC'MenuItem'('Edit',tab,'Ctrl+Enter')('Active'((1=⍴,objName1)∧0∨.<⊃¨⎕NC¨objName1 objName2))
              :EndIf
              'mm.compare'⎕WC'MenuItem'('Compare',tab,'=')('Active'((1=⍴,⍴objName1)∧0∧.<⊃¨⎕NC¨objName1 objName2))
              :If ~∨/readOnly∊1 ¯1 ¯2
                  'mm.copyTo_2'⎕WC'MenuItem'('Copy [1] to [2]',tab,'Ctrl+{CursorRight}')('Active'(0∨.<⎕NC objName1))
                  'mm.copyTo_1'⎕WC'MenuItem'('Copy [2] to [1]',tab,'Ctrl+{CursorLeft}')('Active'(0∨.<⎕NC objName2))
                  'mm.show'⎕WC'MenuItem' 'Show journal for this ID'('Active'(0<⍴,refToDiff.GetRemark id))
                  'mm.sep2'⎕WC'Separator'
                  'mm.remove'⎕WC'MenuItem'('Remove from list',tab,'Del')
                  'mm.delete'⎕WC'MenuItem'('Delete...',tab,'Ctrl+Del')('Active'(0∨.≠⎕NC↑⍕¨objName1 objName2))
              :EndIf
              {⍵ ⎕WS'Event' 'Select' 1}¨'mm.'∘,¨mm.⎕WN''
              res←⎕DQ'mm'
              :If ~0∊⍴res
                  :Select {⍵↓⍨⍵⍳'.'}1⊃res
                  :Case 'edit'
                      Edit row objName
                  :Case 'compare'
                      Compare row ref readOnly
                      ⎕NQ ref'GotFocus'
                  :Case 'copyTo_1'
                      Copy 2 1 row objName
                  :Case 'copyTo_2'
                      Copy 1 2 row objName
                  :Case 'delete'
                      Delete id objName
                  :Case 'show'
                      id Show objName
                  :Case 'remove'
                      RemoveFromList tabNo objName id
                  :Case 'acr'
                      MarkAsChanged tabNo objName id
                  :Else
                 ⍝ Cancelled
                  :EndSelect
              :EndIf
          :EndIf
        ∇

        ∇ r←OnGotFocus
          r←0
        ∇

        ∇ OnPrintMenuCmd msg;data
        ⍝ Prints ")erase " coomands for allo objects reported to the session
          ⎕←(⎕PW-1)⍴'-'
          data←↑n.Show.Text
          data⌿⍨←data[;1]=' '           ⍝ Drop titles
          data←(data∨.='#')⌿data
          ⎕←↑')ERASE '∘,¨↓dlb data
        ∇

        ∇ OnHelp;ff;txt;myFnt
          'myFnt'⎕WC'Font' 'APL385 Unicode'('Size' 20)
          'ff'⎕WC'Form'(∆Caption,': Help')('Coord' 'Pixel')('Posn'(75 45))('Size'(500 550))
          'ff.e'⎕WC'Edit'('Coord' 'Prop')('Posn'(0 0))('Size'(100 100))('Style' 'Multi')('Event' 'GotFocus' 'OnGotFocus')('FontObj' 'myFnt')('VScroll' ¯1)
          txt←''
          txt,←⊂'Designed to help merging two namespaces.'
          txt,←⊂'In fact you can merge even workspaces by making sure that a particular namespace holds one workspace and another one the second workspace.'
          txt,←⊂''
          txt,←⊂'1 Available in [1] only'
          txt,←⊂'2 Available in [2] only'
          txt,←⊂'= The APL objects do equal'
          txt,←⊂'≠ Same type but they differ'
          txt,←⊂'≢ Objects have different types'
          txt,←⊂''
          txt,←⊂'- To sort the list by a column, click the column title'
          txt,←⊂'- To reverse the sort direction, hold the Ctrl while clicking the col title'
          txt,←⊂''
          txt,←⊂'- Press <Ctrl+Enter> on a line to edit'
          txt,←⊂'- Press = on a line to compare'
          txt,←⊂'- Press <Del> to delete an object from the list'
          txt,←⊂'- Press <Ctrl+Del> to delete an object from the workspace'
          txt,←⊂'- Press <Ctrl+{CursorRight}> to copy [1] to [2]'
          txt,←⊂'- Press <Ctrl+{CursorLeft}> to copy [2] to [1]'
          ff.e.Text←txt
          'ff.close'⎕WC'Button' 'Close'('Posn'(¯10 ¯10))('Size'(2 2))('Cancel' 1)('Event' 'Select' 1)('Attach'(4⍴'Top' 'Left'))
          ⎕DQ'ff'
      ⍝Done
        ∇

        ∇ data OnItemDblClick msg;objName;line;ref;id;row
          (objName line)←msg[1 3]
          ref←⍎objName
          id←⍎line⊃ref.Items
          row←refToDiff.GetRowById id
          Edit row objName
        ∇

        ∇ status OnItemDown msg;objName;line;dates;id;row
          objName←1⊃msg
          id←GetId⍎objName
          :If 1=1⊃⍴row←refToDiff.GetRowById id
              dates←FormatTS¨{0::⍬ ⋄ 2 ⎕AT ⍵}¨refToDiff.GetObjNames id
              FF.f.sb.(ts1 ts2).Text←dates
              dates←{{0∊⍴⍵:⍬ ⋄ ⍎⍵}⍵~'- :'}¨dates
              :If 0∊⊃∘⍴¨,¨dates
              :OrIf {⎕CT←1E¯17 ⋄ =/⍵}dates
                  FF.f.sb.(ts1 ts2).BCol←0
              :ElseIf </dates
                  FF.f.sb.(ts1 ts2).BCol←0(0 255 0)
              :Else
                  FF.f.sb.(ts1 ts2).BCol←(0 255 0)0
              :EndIf
              FF.f.sb.name.Text←⊃row[1;I.∆name]
          :Else
              FF.f.sb.name.Text←''
          :EndIf
        ∇

        ∇ r←OnKeyPress msg;objRef;row;code;tabNo;flag;id;objName
          r←1
          code←msg[4 5 6]
          objName←1⊃msg
          objRef←GetCurrentTab'list'
          tabNo←GetCurrentTabno
          :If flag←(,0)≢,id←GetId objRef
              r←0
              row←refToDiff.GetRowById id ⍝ (tabNo⊃data1 data2)[line;]
              :Select code
              :Case 10 13 2 ⍝ Enter
                  :If flag
                  :AndIf ~∨/readOnly∊1 ¯1 ¯2
                      Edit row(⍕objRef)
                  :EndIf
              :Case 61 187 0 ⍝ = for "Compare"
                  :If flag
                      Compare row objRef(readOnly∊1 ¯1 ¯2)
                      ⎕NQ objRef'GotFocus'
                  :EndIf
              :Case 0 46 2 ⍝ Ctrl+Del (delete from workspace)
                  :If ~∨/readOnly∊1 ¯1 ¯2
                      Delete id objName
                  :EndIf
              :Case 0 39 2 ⍝ Ctrl+CursorRight
                  :If ~∨/readOnly∊1 ¯1 ¯2
                      Copy 1 2 row objName
                  :EndIf
              :Case 0 37 2 ⍝ Ctrl+CursorLeft
                  :If ~∨/readOnly∊1 ¯1 ¯2
                      Copy 2 1 row objName
                  :EndIf
              :Case 0 46 0 ⍝ Del: delete from list, NOT from the workspace
                  :If ~∨/readOnly∊1 ¯1 ¯2
                      RemoveFromList tabNo objName id
                  :EndIf
              :Else
                  r←1
                  ⎕NQ objName 9999
              :EndSelect
          :EndIf
        ∇

        ∇ r←FormatTS ts
          r←{
              0∊⍴⍵:''
              0=+/⍵:''
              ,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT,[0.5]6↑,⍵
          }ts
        ∇

        ∇ OnSearch msg;∆;ff;res;ref;bool;searchIn;listObj;ms
          ∆←⊂'Form'
          ∆,←⊂'Coord' 'Pixel'
          ∆,←⊂'Caption'(∆Caption,': Search')
          ∆,←⊂'Size'(260 300)
          ∆,←⊂'Sizeable' 0
          ∆,←⊂'MinButton' 0
          ∆,←⊂'MaxButton' 0
          ∆,←⊂'SysMenu' 0
          'ff'⎕WC ∆

          'DefaultFnt'⎕WC'Font' 'MS Sans Serif'
          ff.FontObj←DefaultFnt

          ∆←⊂'Label'
          ∆,←⊂'Posn'(5 5)
          ∆,←⊂'Caption' 'String to be searched (case is ignored):'
          'ff.l'⎕WC ∆

          ∆←⊂'Edit'
          ∆,←⊂'Posn'(35 5)
          ∆,←⊂'Size'(⍬(ff.Size[2]-10))
          ∆,←⊂'Text'∆SearchFor
          ∆,←⊂'SelText'(1,1+⍴,∆SearchFor)
          'ff.e'⎕WC ∆
          ff.e.Size[1]-←4

          ∆←⊂'Label'
          ∆,←⊂'Posn'(70 5)
          ∆,←⊂'Caption' 'The search will be performed on these columns:'
          'ff.info1'⎕WC ∆

          ∆←⊂'Label'
          ∆,←⊂'Posn'(90 5)
          ∆,←⊂'Caption' '"Name", "Path" and maybe "author names"'
          'ff.info2'⎕WC ∆

          ∆←⊂'Label'
          ∆,←⊂'Posn'(115 5)
          ∆,←⊂'Caption' 'Result (IDs) is displayed in the status bar.'
          'ff.info3'⎕WC ∆

          ∆←⊂'Button'
          ∆,←⊂'Style' 'Check'
          ∆,←⊂'Caption' 'Not in "Author" names'
          ∆,←⊂'State' 1
          ∆,←⊂'Posn'((ff.Size[1]-60),7)
          'ff.names'⎕WC ∆

          ∆←⊂'Button'
          ∆,←⊂'Caption' 'OK'
          ∆,←⊂'Default' 1
          ∆,←⊂'Posn'((ff.Size[1]-30),5)
          ∆,←⊂'Size'(⍬ 120)
          ∆,←⊂'Event' 'Select' 1
          'ff.ok'⎕WC ∆

          ∆←⊂'Button'
          ∆,←⊂'Caption' 'Cancel'
          ∆,←⊂'Cancel' 1
          ∆,←⊂'Posn'(ff.Size-30 125)
          ∆,←⊂'Size'(⍬ 120)
          ∆,←⊂'Event' 'Select' 1
          'ff.cancel'⎕WC ∆

          ⎕NQ'ff.e' 'GotFocus' ⋄ res←⎕DQ'ff'
          :If ~0∊⍴res
          :AndIf 'ff.ok'≡1⊃res
              ∆SearchFor←ff.e.Text
              listObj←{⍵.list}⍎{'FF.f.tc.sf',⍕⍵}⍎¯1↑⍕FF.f.tc.TabObj
              searchIn←{⍵.ReportInfo[;2 3 6 7]}listObj
              searchIn←(-2×ff.names.State)↓[2]searchIn
              bool←∨/(Lowercase ∆SearchFor)⍷⎕FMT Lowercase searchIn
              :If 0∊⍴∆Hits←bool/listObj.Items
                  ⎕EX'ff'
                  'ms'⎕WC'MsgBox' 'Compare: not hits'('Search string "',∆SearchFor,'" not found')
                  ⎕DQ'ms'
              :Else
                  FF.f.sb.Info.Text←'Hits in:',⍕∆Hits
              :EndIf
          :EndIf
        ∇

        ∇ {r}←RemoveFromList(tabNo objName id);ref;row;name;LastLine;refToList;ms;question
     ⍝ Remove "line" from list if user confirms
          r←0
          ref←⍎objName
          row←refToDiff.GetRowById id
          name←row[;I.∆name]
          question←(1↓⊃,/⎕TC[2],¨(⊂'Sure you want remove:'),((⊂'  '),¨name),⊂'from the list?')'' '(This action won''t change the workspace!)'
          :If 'Remove from list'YesOrNo question
              refToDiff.Remove id
              LastLine←1⌈1⊃{⍵/⍳⍴,⍵}{⍵.list.SelItems}⍎(1+⍴⍕⎕THIS)↓⍕FF.f.tc.T2.TabObj
              Write ref refToDiff((GetTabNo ref)⊃I.∆nonequals I.∆equals)
              CorrectColSize ref
              FF.f.sb.Info.Text←'Removed: ',(⍕⍴name),' item',(1<⍴name)/'s'
              refToList←(⍎(1+⍴⍕⎕THIS)↓⍕FF.f.tc.T2.TabObj).list
              :If 0<LastLine←LastLine⌊⍴refToList.Items
                  LastLine{⍵.SelItems[⍺]←1}refToList
                  EnsureVisibleLine refToList LastLine
              :EndIf
          :EndIf
        ∇

        ∇ {id}Show dummy;res;txt;journal;_;ff
  ⍝ Show the journal, either all entries or only those belonging to "id"
          id←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'id'
          journal←refToDiff.GetRemark id
          'ff'⎕WC'Form'(∆Caption,': Journal')('Coord' 'Prop')
          'ff.fnt'⎕WC'Font' 'APL385 Unicode'
          ff.FontObj←ff.fnt
⍝          ff.IconObj←AppIcon
          _←⊂'ListView'
          _,←⊂'Posn'(0 0)
          _,←⊂'Size'(100 100)
          _,←⊂'View' 'Report'
          _,←⊂'Items'(⍕¨journal[;1])
          _,←⊂'ReportInfo'(journal[;,2])
          _,←⊂'GridLines' 1
          _,←⊂'ColTitles'('ID' 'Remark')
          'ff.lv'⎕WC _
          _←⊂'Button'
          _,←⊂'Coord' 'Pixel'
          _,←⊂'Posn'(¯4 ¯4)
          _,←⊂'Size'(1 1)
          _,←⊂'Cancel' 1
          _,←⊂'Event' 'Select' 1
          'ff.close'⎕WC _
          CorrectColSize ff.lv
          {⍵.Size+←1 ⋄ _←⎕DL 0.01 ⋄ ⍵.Size-←1}ff ⍝ To circumvent the ugly display of the ColTitles
          ⎕NQ'ff' 'GotFocus' ⋄ ⎕DQ'ff'
⍝Done
        ∇

        ∇ Write(objRef dataRef lines);buffer;selected;id
     ⍝ Write data to the screen
          buffer←refToDiff.GetScreenData lines
          :If 0≠selected←⊃{⍵/⍳⍴,⍵}objRef.SelItems
              id←⍎selected⊃objRef.Items
          :EndIf
          objRef.Items←⍕¨buffer[;1]
          objRef.ReportInfo←1↓[2]buffer
          :If selected≠0
          :AndIf id∊buffer[;1]
              objRef.SelItems←(⍳1⊃⍴buffer)=buffer[;1]⍳id
          :EndIf
     ⍝Done
        ∇

        ∇ EnsureVisibleLine(refToList lineNo);sendmsg;LVM_ENSUREVISIBLE;_
⍝ Make sure that a particular line gets visible even if this needs scrolling
          'sendmsg'⎕NA'I4 USER32|SendMessageW P U4 U4 U4'
          LVM_ENSUREVISIBLE←4115
          _←sendmsg refToList.Handle LVM_ENSUREVISIBLE(lineNo-⎕IO)1
        ∇

        ∇ {r}←MarkAsChanged(tabNo objName id);ref;row;name;LastLine;refToList;ms;question;list
     ⍝ Tell acre that the item has changed
          r←0
          ref←⍎objName
          row←refToDiff.GetRowById id
          name←row[;I.∆name]
          question←(1↓⊃,/⎕TC[2],¨(⊂'Sure you want mark as changed:'),((⊂'  '),¨name),⊂'?')
        ∇

        ∇ {r}←{caption}ShowMsg question;∆;ms
          r←⍬
          caption←{0<⎕NC ⍵:'Compare: ',⍎⍵ ⋄ 'Compare'}'caption'
          ∆←⊂'MsgBox'
          ∆,←⊂caption
          ∆,←⊂'Text'question
          ∆,←⊂'Style' 'Info'
          ∆,←⊂'Event'('MsgBtn1')1
          'ms'⎕WC ∆
          {}⎕DQ'ms'
        ∇

    :EndClass


    ∇ r←OnCompare msg;bool;no1;no2;body1;title1;body2;title2;filename1;filename2
      r←0
      →(0=+/bool←f.table.Values[;4])/0  ⍝ no radio is on, so what we are supposed to do?!
      no1←bool⍳1                    ⍝ which row?
      no2←1⊃f.table.CurCell         ⍝ in which row was "Compare" pressed?
      body1←4⊃no1⊃versions
      title1←{'Version ',(⍕1⊃⍵),' from ',(2⊃⍵),' ',(3⊃⍵),' by ',4⊃⍵}meta[no1;]
      body2←4⊃no2⊃versions
      title2←{'Version ',(⍕1⊃⍵),' from ',(2⊃⍵),' ',(3⊃⍵),' by ',4⊃⍵}meta[no2;]
      filename1←refToUtils.WinFile.GetTempPath,(' '~⍨⍕⎕TS),(⍕?1000),'_',⎕AN,'.txt'
      WriteUtf8File filename1 body1
      filename2←refToUtils.WinFile.GetTempPath,(' '~⍨⍕⎕TS),(⍕?1000),'_',⎕AN,'.txt'
      WriteUtf8File filename2 body2
      RunCompareIt filename1 filename2 1 title1 title2
    ∇

      GetRefToSaltNS←{
          9=⎕NC(⍕⍵),'.∆':⍵⍎'∆'
          9=⎕NC(⍕⍵),'.SALT_Data':⍵⍎'SALT_Data'
          ⍬
      ⍝ Returns a ref to ⍵.∆ if that is a namespace or
      ⍝ a ref to ⍵.SALT_Data if that is a namespace or
      ⍝ an empty vector.
      }

    ∇ r←ReadUtf8File filename;fno;noOfBytes;bytes;⎕IO;⎕ML
      ⎕IO←⎕ML←1
      r←''
      :Trap 22
          fno←filename ⎕NTIE 0
      :Else
          ('Could not read file: ',filename)⎕SIGNAL ⎕EN
      :EndTrap
      noOfBytes←⎕NSIZE fno
      bytes←⎕NREAD fno 83,noOfBytes
      ⎕NUNTIE fno
      ⍝ Make sure it is unsigned, and drop the UTF-8 marker bytes if present
      bytes+←256×bytes<0
      bytes↓⍨←3×239 187 191≡3↑bytes ⍝ drop a potential UTF-8 marker
      r←'UTF-8'⎕UCS bytes
      :If ∨/(⎕UCS 13 10)⍷r
          r←Split r
      :ElseIf ∨/r=⎕UCS 10
          r←(⎕UCS 10)Split r
      :EndIf
    ∇

    ∇ {append}WriteUtf8File(filename data);fno;fullname;flag;⎕ML;⎕IO
     ⍝ Write UTF-8 "data" to "filename" (WITHOUT a BOM!)
      ⎕IO←⎕ML←1
      append←{2=⎕NC ⍵:⍎⍵ ⋄ 0}'append'
      flag←0
      :If ~0 1∊⍨≡data
          data←⊃{⍺,(⎕UCS 13 10),⍵}/data
      :EndIf
      :Repeat
          :Trap 19 22
              fno←filename ⎕NTIE 0 17 ⍝ Open exclusively
              filename ⎕NERASE fno
              flag←1
          :CaseList 19
              ⎕DL 0.2
          :Case 22
              flag←1 ⍝ That's just fine
          :Else
              ⎕DM ⎕SIGNAL ⎕EN
          :EndTrap
      :Until flag
      fno←filename ⎕NCREATE 0
     ⍝ Enforce UTF-8
      data←⎕UCS'UTF-8'⎕UCS data
      data ⎕NAPPEND fno
      ⎕NUNTIE fno
    ∇

    ∇ r←FindAcreInstance;list;bool
     ⍝ Finds one single acre instance in #, if any
      r←⍬
      :If ~0∊⍴list←(' '~¨⍨↓#.⎕NL 9.1)~⊂'#.acre'
      :AndIf 0<+/bool←{(⊂'[acre]')≡¨⍵}⍕¨#.⍎¨list
          r←⍎'#.',(bool⍳1)⊃list
      :EndIf
    ∇

      MakeRelative←{
          path←⍕⍵
          ~(1⍴path)∊'⎕#':path
          (1+⍴⍕⎕THIS)↓path
      }

    IsRef←{(0=≡⍵)∧⍵≢⍕⍵}                             ⍝ Used to identify references
    IsFile←{(∨/':/\'∊⍵)∨'file://'{⍺≡(⍴⍺)↑⍵}⍵}       ⍝ Used to identify filename

      List←{
          ⍝r←⍵{ ⊃∇/⍺.(⍺{(0,⍵)/⍨0,(⍺≠⍵)∧⍺=⍵.##}⍎⍕'⍺',⌽⎕NL-9.1),⊂⍵,⍺}⍬
          r←⍵{⍺.(⍺{(0,⍵)/⍨0,(⍺≠⍵)∧⍺=⍵.##}⍎⍕'⍺',⌽⎕NL-9.1),⊂⍵,⍺}⍬
          (0∊⍴r←(⍬∘≡¨⍴¨r)/r):⍬
          _←{⍵.⎕DF ⎕NULL}¨r
          ⍵~⍨∪r/⍨~'['∊¨⍕¨r
      }

      GetNameClass←{
          (0∊⍴1⊃⍵):0
          ⎕NC{⍺,'.',⍵}/⍵
      }

    ∇ (rubbishReport rubbishObjects)←ReportRubbishIn(ref rubbishReport rubbishObjects recursionFlag refsAreRubbish);buf
    ⍝ Reports :
    ⍝ * Refs pointing to namespaces
    ⍝ * Empty ordinary namespaces
    ⍝ * Instances
      :If ~0∊⍴ref
          (buf rubbishObjects)←InvestigateNamespaces(ref rubbishObjects''refsAreRubbish)
          (buf rubbishObjects)←InvestigateInstances(ref rubbishObjects buf)
          (buf rubbishObjects)←InvestigateClasses(ref rubbishObjects buf)
          (buf rubbishObjects)←InvestigateInterfaces(ref rubbishObjects buf)
          rubbishReport,←buf
      :EndIf
    ∇

    InvestigateClasses←{InvestigateClassesAndInterfaces ⍵, 9.4}
    InvestigateInterfaces←{InvestigateClassesAndInterfaces ⍵, 9.5}

    ∇ (report rubbishObjects)←InvestigateInstances(ref rubbishObjects report);list;fn;msg;types;bool
    ⍝ Finally we deal with instances of all sorts.
      :If ~0∊⍴list←ref.⎕NL-9.2                  ⍝ Any instances at all?
          fn←(⊂(⍕ref),'.'),¨list                ⍝ Fully qualified names
          bool←{0::0 ⋄ ⍵ ⎕WG'KeepOnClose'}¨fn
          :If 1∊bool
              report,←⊂'GUI Instances with KeepOnClose=1:'(bool/fn)
              rubbishObjects,←bool/fn
              :If 0∊⍴fn←(~bool)/fn
                  :Return
              :EndIf
          :EndIf
      ⍝ Instances may have code in their attached namespaces:
          :If 1∊bool←{~0∊⍴⍵.⎕NL⍳16}¨⍎¨fn
              msg←'Instances with code in attached namespace:'
              report,←⊂(msg)(bool/fn) ⍝ Indeed!
              rubbishObjects,←bool/fn
              :If 0∊⍴fn←(~bool)/fn
                  :Return
              :EndIf
          :EndIf
          types←{⍵ ⎕WG'Type'}¨fn
          :If 1∊bool←'Instance'∘≡¨types
              report,←⊂'Class Instances:'(bool/fn)
              rubbishObjects,←bool/fn
              :If 0=+/bool
                  :Return
              :EndIf
          :EndIf
          :If 0∊bool
              report,←⊂'Other Instances:'((~bool)/fn)
              rubbishObjects,←(~bool)/fn
          :EndIf
      :EndIf
    ∇

    ∇ (report rubbishObjects)←InvestigateNamespaces(ref rubbishObjects report refsAreRubbish);list;fn;refs;bool;nn;bool2
    ⍝ First we deal with references pointing to namespaces, unnamed or otherwise
      :If ~0∊⍴list←ref.⎕NL-9.1                  ⍝ All namespaces
          fn←(⊂(⍕ref),'.'),¨list                ⍝ Same but full name
          bool←fn≢¨⍕¨GetDisplayFormat¨⍎¨fn      ⍝ 1=refs, 0=named namespaces
          :If ~0∊⍴refs←bool/fn                  ⍝ Are there any pure refrences?
              :If refsAreRubbish
                  report,←⊂'Namespace references:'refs
                  rubbishObjects,←refs
              :EndIf
          :EndIf
          nn←(~bool)/fn                         ⍝ Named namespaces
          :If ~0∊⍴nn                            ⍝ Any?
          :AndIf 1∊bool2←{0∊⍴⍵.⎕NL⍳16}¨⍎¨nn     ⍝ Are they empty?
              report,←⊂('Empty Namespaces:')(bool2/nn)
              rubbishObjects,←bool2/nn
          :EndIf
      :EndIf
    ∇

    ∇ (report rubbishObjects)←InvestigateClassesAndInterfaces(ref rubbishObjects report nc);list;fn;bool;msg
    ⍝ Now we deal with classes or interfaces: they may have code in their attached namespace
    ⍝ "nc" is either 9.4 (classes) or 9.5 (interfaces)
      :If ~0∊⍴list←ref.⎕NL-nc                   ⍝ Any at all?
          fn←(⊂(⍕ref),'.'),¨list                ⍝ Full names
      :AndIf 1∊bool←{~0∊⍴⍵.⎕NL⍳16}¨⍎¨fn         ⍝ Is the attached namespace not empty?!
          msg←(9.4 9.5⍳nc)⊃'Classes' 'Interfaces'
          msg,←' with code in attached namespace:'
          report,←⊂(msg)(bool/fn)               ⍝ Indeed!
      :EndIf
    ∇

    ∇ r←PolishRubbishReport(ref1 ref2 report1 report2 refsAreRubbish dropFromRubbish);thisReport;data;type;buffer;ind;thisTitle
      ⍝ Is a vector that contains all data for both, ref1 and ref2.
      ⍝ The lines starting with "* " tell the starting points for ref1/ref2.
      ⍝ Each has a vector of two-item-vector:
      ⍝ [1] Is the type ("Ref", or "Instance" or "Empty"...)
      ⍝ [2] Is the data found
      ⍝ Each type can occur zero, once or many times. This function makes sure _
      ⍝ that they occure either zero or exactly one time
      r←''
      :For thisReport thisTitle :InEach (report1 report2)(⍕¨ref1 ref2)
          :If ~0∊⍴thisReport
              r,←⊂dropFromRubbish↓thisTitle
              buffer←0 2⍴''
              :For type data :In thisReport
                  :If (⊂type)∊buffer[;1]
                      ind←buffer[;1]⍳⊂type
                      buffer[ind;2]←⊂∪(ind⊃buffer[;2]),(dropFromRubbish↓¨data)
                  :Else
                      buffer⍪←type(dropFromRubbish↓¨data)
                  :EndIf
              :EndFor
              :If ~0∊⍴buffer
                  r,←↑,/{(⊂'  ',1⊃⍵),'     '∘,¨2⊃⍵}¨↓buffer
              :EndIf
          :EndIf
      :EndFor
    ∇

    GetDisplayFormat←{⍵{(⍺.⎕DF ⍵)⊢⍕⍺}⍵.⎕DF ⎕NULL}     ⍝ Thanks to Phil Last

      ListOrdinaryNamespaces←{
      ⍝ Corrects any ⎕DF related issues
          (0∊⍴⍵):''
          (0∊⍴l←' '~¨⍨↓⍵.⎕NL 9.1):''
          _←⍵{0::⍬ ⋄ ⍺.⍎⍵,'.⎕DF ⎕NULL'}¨l
          (0∊⍴l←(⍬∘≢¨⍵{0::⍬ ⋄ ⍺.⍎⍵}¨l)/l):''
          ⍵.⍎¨l
      }

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ acre's Helpers start

      OnChangeRadio←{
          (btn status row col)←⍵[⎕IO+4 5 6 7]
          (btn≠1)∨0≠status:0
          col=5:1
          col≠4:⍬
          f.table.Values[;col]←0
          f.table.Values[row;col]←1
          0
      }

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ acre Helpers End

:EndClass