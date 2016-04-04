:Class Tester
⍝ This class establishes a test framework for APL applications. This help _
⍝ is ''not'' an introduction into how the test framework works, and _
⍝ how you should organzie your test cases. More information is available _
⍝ from the Tester's home page on the APL Wiki: http://aplwiki.com/Tester.
⍝
⍝ These are the `Run*` functions you may call:
⍝ * `Run`
⍝ * `RunBatchTests`
⍝ * `RunDebug`
⍝ * `RunTheseIn`

⍝ == Details
⍝ All methods take a right argument which is a ref pointing to an ordinary _
⍝ namespace hosting the test functions. What is a test function and what is _
⍝ not is determined by naming convention: they must start with the string _
⍝ "Test_" (case sensitive!) followed by digits. Therefore these _
⍝ are all valid names for test functions:
⍝ * `Test_1`
⍝ * `Test_001`
⍝ * `TEST_9999`
⍝
⍝ In order to allow grouping when complex test cases need to be constructed _
⍝ the following names are valid as well:
⍝ * `Test_GroupA_001`
⍝ * `Test_GroupB_002`
⍝
⍝ Note that there must be a second "_" character (but no more!) to define _
⍝ the group. ''After'' the second underscore only digits are allowed.
⍝
⍝ All test functions must accept a right argument of length two:
⍝
⍝ === [1] Batch flag
⍝ Tells the test function that the test is running in batch mode. Use _
⍝ this to avoid running test cases that need a human beeing in front _
⍝ of the monitor!
⍝
⍝ If a test function does not execute because of this flag it should _
⍝ return `¯1` rather than `0` or `1`.
⍝
⍝ === [2] Stop flag
⍝ Setting this to 1 prevents errors from being trapped, so you can _
⍝ investigate failing test cases straight away.
⍝
⍝ === Misc
⍝ Test functions must ''always'' return a `0` or a `1` for working or failing _
⍝ test cases and a `¯1` when they did not execute because of the batch flag.
⍝ Note that it is strongly recommended to check conditions in a certain way _
⍝ because only then can `RunDebug` work properly. More information on this _
⍝ is available on the APL wiki, see above.

⍝ == "Initial" function
⍝ If a function `Initial` exists in the namespace containing the test cases _
⍝ it is executed automatically before any test case is executed.
⍝ Note that such a function must be either niladic or monadic. If it is _
⍝ monadic a reference pointing to the parameter space will be passed as _
⍝ right argument. That allows you to, say, check the parameter _
⍝ `batchFlag`.
⍝ Use this to initialise an environment all your test cases need.

⍝ == "Shutdown" function
⍝ If a function `Shutdown` exists in the namespace containing the test cases _
⍝ it is executed automatically after the test cases have been executed.
⍝ Use this to clean up any leftovers.

⍝ == INI files
⍝ When running the `RunBatchTests` method it checks for INI files:
⍝ # First it tries to find "testcase_{computername}.ini"
⍝ # If no such file exists it tries to find "testcase.ini"
⍝ If one of those files exist a namespace `Ini` is created within the _
⍝ namespace where your test cases live. This namespace is populated by the _
⍝ contents of the INI file(s) found.
⍝ After executing the test cases this namespace is deleted.

⍝ == Helpers
⍝ There are a couple of helpers you might find useful when creating test _
⍝ cases. The method `EstablishHelpersIn` takes a ref pointing to the namespace _
⍝ hosting the test cases (defaults to `↑⎕RSI` when empty). It copies those helpers_
⍝ into the hosting namespace. The explicit result is a list of all helpers.
⍝ Home page: http://aplwiki.com/Tester
⍝ This class is part of the APLTree Open Source project.
⍝ For more information see http://aplwiki.com/apltree

    ⎕IO←1 ⋄ ⎕ml←3

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public shared
      r←(Last⍕⎕THIS)'2.3.0' '2015-11-07'
      ⍝ 2.3.0 * Now sub-groups are supported as in Test_Grp1_Grp2_Grp3_001
      ⍝       * RunThese now accepts a wild card as in "Test_Grp*".
      ⍝ 2.2.0 * Documentation improved.
      ⍝ 2.1.1 * Right argument passed on to any "Initial" function was inconsistent.
      ⍝ 2.1.0 * APL inline code is marked up now with ticks.
      ⍝ 2.0.0 * Refactored with plenty of structural improvements.
      ⍝       * `EditAll` now gives control immediately back to the user.
    ∇

    ∇ {log}←Run refToTestNamespace;flags;rc
    ⍝ Runs all test cases in `refToTestNamespace` with error trapping. Broken _
    ⍝ as well as failing tests are reported in the session as such but they _
    ⍝ don't stop the program from carrying on.
      :Access Public Shared
      flags←1 0 0 0
      (rc log)←refToTestNamespace Run__ flags,⊂⍬
    ∇

    ∇ {(rc log)}←{trapAndDebugFlag}RunBatchTests refToTestNamespace;flags
    ⍝ Runs all test cases in `refToTestNamespace` but tells the test functions _
    ⍝ that this is a batch run meaning that test cases in need for any human  _
    ⍝ being for interaction should quit silently.
    ⍝ Returns 0 for okay or a 1 in case one or more test cases are broken or failed.
    ⍝ This method can run in a runtime as well as in an automated test environment.
    ⍝ The left argument defaults to 0 but can be set to 1. It sets both, stopFlag
    ⍝ and trapFlag when specified. It can be a scalar or a two-item vector.
      :Access Public Shared
      trapAndDebugFlag←{(0<⎕NC ⍵):⍎⍵ ⋄ 1 0}'trapAndDebugFlag'
      flags←(1↑trapAndDebugFlag),(¯1↑trapAndDebugFlag),1 0
      (rc log)←refToTestNamespace Run__ flags,⊂⍬
    ∇

    ∇ {log}←{x}RunDebug refToTestNamespace;flags;rc;stopAt;stop
    ⍝ Runs all test cases in `refToTestNamespace` ''without'' error trapping. _
    ⍝ If a test case encounters an invalid result it stops. Use this function _
    ⍝ to investigate the details after `Run` detected a problem.
    ⍝ This will work only if you use a particualar strategy when checking results _
    ⍝ in a test case; see       r←'See: http://aplwiki.com/Tester for details.
      :Access Public Shared
      stop←0 ⋄ stopAt←⊂⍬
      :If 0<⎕NC'x'
          :If 0>x
              stopAt←|x
              stop←1
          :Else
              stop←x
          :EndIf
      :EndIf
      flags←0 1 0,stop,stopAt
      (rc log)←refToTestNamespace Run__ flags
    ∇

    ∇ {log}←testCaseNos RunTheseIn refToTestNamespace;flags;rc
    ⍝ Like RunDebug but it runs just `testCaseNos` in `refToTestNamespace`.
    ⍝ Example that executes 'Test_special_02' and 'Test_999':
    ⍝ 'Special_02' 999 RunTheseIn ⎕THIS
    ⍝ [2] Numeric Vector
    ⍝ [3] Vector of length with:
    ⍝     a) A string specifying a group
    ⍝     b) A vector with numbers (empty=all of that group)
    ⍝ Example that executes test cases 2 & 3 of group "Special":
    ⍝  'Special' (2 3) RunTheseIn ⎕THIS
      :Access Public Shared
      flags←0 1 0 0
      (rc log)←refToTestNamespace Run__ flags,⊂testCaseNos
    ∇

    ∇ EditAll refToTestNamespace;list
     ⍝ :Access Public Shared
     ⍝ Opens all test functions in the editor
      {⎕ED ⍵}&¨GetAllTestFns refToTestNamespace
    ∇

    ∇ r←GetAllTestFns refToTestNamespace;buff
      :Access Public Shared
     ⍝ Returns the names of all test functions found in namespace `refToTestNamespace`
      r←''
      :If ~0∊⍴buff←'T'refToTestNamespace.⎕NL 3
          r←' '~¨⍨↓({∧/(↑¯1↑'_'Split ⍵~' ')∊⎕D}¨↓buff)⌿buff
      :EndIf
    ∇

    ∇ r←{searchString}ListTestCases y;refToTestNamespace;list;b;full
      :Access Public Shared
     ⍝ Returns the comment expected in line 1 of all test cases found in refToTestNamespace.
     ⍝ You can specify a string as optional secomd parameter of the right argument: _
     ⍝ then only test cases that do contain that string in either their names or in _
     ⍝ line 1 will be reported.
     ⍝ The optional left argument defaults to 1 which stands for "full", meaning that _
     ⍝ the name and the comment in line 1 are returned. If it is 0 insetad, _
     ⍝ only the names of the functions are returned.
     ⍝ Note that the search will be case insensitive in any case.
      r←''
      (refToTestNamespace full)←2↑y,(⍴,y)↓'' 1
      searchString←##.APLTreeUtils.Lowercase{0<⎕NC ⍵:⍎⍵ ⋄ ''}'searchString'
      :If ~0∊⍴list←'Test_'{⍵⌿⍨⍺∧.=⍨⍵↑[2]⍨⍴⍺}'T'refToTestNamespace.⎕NL 3
      :AndIf ~0∊⍴list←' '~¨⍨↓('Test_'{∧/((⍴⍺)↓[2]⍵)∊' ',⎕D,⎕A,'_',##.APLTreeUtils.Lowercase ⎕A}list)⌿list
          r←2⊃¨refToTestNamespace.⎕NR¨list
          r←{⍵↓⍨+/∧\⍵∊' ⍝'}¨{⍵↓⍨⍵⍳'⍝'}¨r
          :If ~0∊⍴searchString
              b←∨/searchString⍷##.APLTreeUtils.Lowercase⊃r          ⍝ Either in comment...
              b∨←∨/searchString⍷⊃##.APLTreeUtils.Lowercase list     ⍝ ... or in the name.
              r←b⌿r
              list←b⌿list
          :EndIf
          :If full
              r←list,[1.5]r
          :Else
              r←,[1.5]list
          :EndIf
      :EndIf
    ∇

    ∇ {r}←{forceTestTemplate}EstablishHelpersIn refToTestNamespace;∆
    ⍝ Takes a ref to a namespace hosting test cases and establishes some functions, _
    ⍝ among them `ListHelpers` which lists all those functions with their leading _
    ⍝ comment line.
    ⍝ `forceTestTemplate` defaults to 0. If it is a 1 then `Test_0000` is established _
    ⍝ no matter whether it -or any other test case- already exists or not.
      :Access Public Shared
      forceTestTemplate←{(0=⎕NC ⍵):0 ⋄ ⍎⍵}'forceTestTemplate'
      'Invalid right argument'⎕SIGNAL 11/⍨~{((,1)≡,⍵)∨((,0)≡,⍵)}forceTestTemplate
      refToTestNamespace←⎕RSI{(0∊⍴⍵):⎕IO⊃⍺ ⋄ ⍵}refToTestNamespace
      'Invalid right argument'⎕SIGNAL 11/⍨#≡refToTestNamespace
     
      ∆←⊂'FailsIf←{'
      ∆,←⊂'⍝ Usage : →FailsIf x, where x is a boolean scalar'
      ∆,←⊂'⎕TRAP←(999 ''E'' ''(⎕IO⊃⎕DM)⎕SIGNAL 999'')(0 ''N'')'
      ∆,←⊂'PassesIf~⍵                   ⍝ Just PassesIf on negation'
      ∆,←⊂' }'
      refToTestNamespace.⎕FX ∆
     
      ∆←⊂'PassesIf←{'
      ∆,←⊂'⍝ Usage : →PassesIf x, where x is a boolean scalar'
      ∆,←⊂'     ⍵:⍬                     ⍝ Passes test, so →PassesIf x just continues'
      ∆,←⊂'     0=⎕NC''stopFlag'':0     ⍝ Stop not defined, continue with test suite'
      ∆,←⊂'     ~stopFlag:0             ⍝ Do not stop, continue with test suite'
      ∆,←⊂'     ⎕SIGNAL 999             ⍝ Otherwise stop for investigation'
      ∆,←⊂' }'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'r←{label}GoToTidyUp flag'
      ∆,←⊂'⍝ Returns either an empty vector or "Label" which defaults to ∆TidyUp'
      ∆,←⊂'⍝ but signals 999 when flag=1 and "stopFlag" exists and is 1.'
      ∆,←⊂':If 1=flag'
      ∆,←⊂':AndIf 0<⎕NC''stopFlag'''
      ∆,←⊂':AndIf stopFlag'
      ∆,←⊂'⎕SIGNAL 999'
      ∆,←⊂':EndIf'
      ∆,←⊂'label←{(0<⎕nc ⍵):⍎⍵ ⋄ r←⍎''∆TidyUp''}''label'''
      ∆,←⊂'r←flag/label'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'{r}←Run'
      ∆,←⊂'⍝ Run all test cases'
      ∆,←⊂'r←#.Tester.Run ⎕THIS'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'{r}←RunDebug debugFlag'
      ∆,←⊂'⍝ Run all test cases with DEBUG flag on'
      ∆,←⊂'⍝ If `debugFlag` is 1 then `RunDebug` stops just before executing the test case'
      ∆,←⊂'r←debugFlag #.Tester.RunDebug ⎕THIS'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'{r}←RunBatchTestsInDebugMode'
      ∆,←⊂'⍝ Run all batch tests in debug mode (no error trapping) and with stopFlag←1'
      ∆,←⊂'r←0 1 #.Tester.RunBatchTests ⎕THIS'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'{r}←RunBatchTests'
      ∆,←⊂'⍝ Run all batch tests'
      ∆,←⊂'r←#.Tester.RunBatchTests ⎕THIS'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'{r}←RunThese ids'
      ∆,←⊂'⍝ Run just the specified tests'
      ∆,←⊂'r←ids #.Tester.RunTheseIn ⎕THIS'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'{r}←ids RunTheseIn ref'
      ∆,←⊂'⍝ Run just the specified tests in specified namespace'
      ∆,←⊂'r←ids #.Tester.RunTheseIn ref'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂' E'
      ∆,←⊂'⍝ Get all functions starting their names with "Test_" into the editor.'
      ∆,←⊂' {(0∊⍴⍵): ⋄ ⎕ED ⍵}¨&↓''Test_''{⍵⌿⍨⍺∧.=⍨(⍴,⍺)↑[1+⎕IO]⍵}''T''⎕NL 3'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'r←{numbers}L group'
      ∆,←⊂'⍝ Prints a list with all test cases and the first comment line to the session.'
      ∆,←⊂'⍝ If "group" is not empty then it will print only that group (case independent).'
      ∆,←⊂'⍝ May or may not start with "Test_"'
      ∆,←⊂'⍝ If "numbers" is defined only those number are printed.'
      ∆,←⊂'numbers←{(0<⎕NC ⍵):⍎⍵ ⋄ ⍬}''numbers'''
      ∆,←⊂'r←↓''Test_''{⍵⌿⍨((⍴⍺)↑[1+⎕IO]⍵)∧.=⍺}''T''⎕NL 3'
      ∆,←⊂':If ~0∊⍴group'
      ∆,←⊂'group←##.APLTreeUtils.Lowercase''test_''{((⍺≢(⍴⍺)↑⍵)/⍺),⍵}group'
      ∆,←⊂'r←(({⎕ML←1 ⋄ ↑⍵}##.APLTreeUtils.Lowercase(⍴group)↑¨r)∧.=group)⌿r'
      ∆,←⊂':EndIf'
      ∆,←⊂':If ~0∊⍴r'
      ∆,←⊂':AndIf ~0∊⍴numbers'
      ∆,←⊂'r←(({⍎⍵↑⍨-(-⎕IO)+''_''⍳⍨⌽⍵}¨r)∊numbers)⌿r'
      ∆,←⊂':EndIf'
      ∆,←⊂'r←r,⍪{⎕ML←3 ⋄ {⍵↓⍨+/∧\'' ''=⍵}{⎕IO←1 ⋄ ⍵↓⍨⍵⍳''⍝''}∊1↑1↓⎕NR ⍵}¨r'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂'r←G;⎕IO'
      ∆,←⊂'⍝ Prints all groups to the session.'
      ∆,←⊂'⎕IO←0'
      ∆,←⊂'r←↓''Test_''{⍵⌿⍨((⍴⍺)↑[1]⍵)∧.=⍺}''T''⎕NL 3'
      ∆,←⊂':If ~0∊⍴r←(2=''_''+.=⍉{⎕ML←1 ⋄ ↑⍵}r)⌿r'
      ∆,←⊂':AndIf ~0∊⍴r←{⎕ML←1 ⋄ ↑⍵}∪{⍵↑⍨⍵⍳''_''}¨{⍵↓⍨1+⍵⍳''_''}¨r'
      ∆,←⊂'r←r[⍋##.APLTreeUtils.Lowercase r;]'
      ∆,←⊂':EndIf'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      ∆←⊂' r←ListHelpers;list;this'
      ∆,←⊂' r←0 2⍴'' '''
      ∆,←⊂' list←''Run'' ''RunDebug'' ''RunThese'' ''RunBatchTests'' ''E'' ''L'' ''G'' ''FailsIf'' ''PassesIf'' ''GoToTidyUp'''
      ∆,←⊂' :For this :In list'
      ∆,←⊂'     r⍪←this(#.APLTreeUtils.dlb{⍺⍺{⍵↓⍨(~⎕IO)+⍵⍳''⍝''}⍺⍺ ⍵}⎕IO⊃1↓⎕NR this)'
      ∆,←⊂' :EndFor'
      ⍎(' '≠1↑0⍴refToTestNamespace.⎕FX ∆)/'.'
     
      :If forceTestTemplate∨0∊⍴refToTestNamespace.L''
          ∆←⊂' R←Test_0000(stopFlag batchFlag);⎕TRAP'
          ∆,←⊂'⍝ Model for a test function'
          ∆,←⊂'⍝ R gets one of: 0=Okay, 1=test case failed, ¯1=test case was not executed due tothe "batchFlag"'
          ∆,←⊂' ⎕TRAP←(999 ''C'' ''. ⍝ Deliberate error'')(0 ''N'')'
          ∆,←⊂' R←1           ⍝ Not OK'
          ∆,←⊂''
          ∆,←⊂'⍝ Preconditions...'
          ∆,←⊂'⍝ ...'
          ∆,←⊂''
          ∆,←⊂' →PassesIf 1≡1'
          ∆,←⊂' →∆TidyUp/⍨0=FailsIf 1≡1'
          ∆,←⊂''
          ∆,←⊂'∆TidyUp: ⍝ Clean up after this label'
          ∆,←⊂'⍝ ...'
          ∆,←⊂''
          ∆,←⊂' R←0           ⍝ OK'
          refToTestNamespace.⎕FX ∆
      :EndIf
      r←refToTestNamespace.ListHelpers
    ⍝Done
    ∇

⍝⍝⍝ Private stuff

    ∇ {(rc log)}←ref Run__(trapFlag debugFlag batchFlag stopAt testCaseNos);ps
    ⍝ Run all test cases to be found in "ref"
    ⍝ The right argument:
    ⍝ [1] trapFlag; controls error trapping:
    ⍝     1 = failing test cases are reported, then the next one is executed.
    ⍝     0 = program halts in case of an error - use this for investigation.
    ⍝ [2] "debugFlag". If it is 1 failing tests stop for investigation (stop on error)
    ⍝ [3] batchFlag; a 1 would mean that the test should quit itself if it prints
    ⍝     to the session or needs a human being in front of the monitor. Such test
    ⍝     cases are supposed to do nothing but return a ¯1 when this is on.
    ⍝ [4] Integer. Is treated as "stop just before the test case number "stopAt" is _
    ⍝     going to be executed.
    ⍝ The explicit result (shy):
    ⍝ r ←→  0  when all tests got executed succesfully
    ⍝ r ←→  1  when at least one test failed
    ⍝ r ←→ ¯1  when at least one test wasn't exeuted because it's not appropriate _
    ⍝          for batch execution, although none of the tests executed did fail.
      ps←⎕NS''
      ref.Stop←debugFlag         ⍝ "Stop" is honored by "FailsIf" & "PassesIf"
      ref.⎕EX'INI'               ⍝ Get rid of any leftovers
      ps.batchTests←0
      ps.(log trapFlag debugFlag batchFlag stopAt testCaseNos errCounter counter)←''trapFlag debugFlag batchFlag stopAt testCaseNos 0 0
      :If ##.WinFile.DoesExistFile'testcases_',(2 ⎕NQ'#' 'GetEnvironment' 'Computername'),'.ini'
          ref.INI←'flat'(⎕NEW #.IniFiles(,⊂'testcases_',(2 ⎕NQ'#' 'GetEnvironment' 'Computername'),'.ini')).Convert ⎕NS''
      :ElseIf #.WinFile.DoesExistFile'Testcases.ini'
          ref.INI←'flat'(⎕NEW #.IniFiles(,⊂'Testcases.ini')).Convert ⎕NS''
      :EndIf
      ExecuteInitial ref ps
      :If 0∊⍴ps.list←GetAllTestFns ref
          →∆GetOutOfHere,rc←0
      :EndIf
      ProcessGroupAndTestCaseNumbers(ref ps)
      →(0∊⍴ps.list)/∆GetOutOfHere
      ps.log,←⊂(⎕PW-1)↑(,'G<--- Tests started at 9999-99-99 99:99:99 >'⎕FMT 100⊥6↑⎕TS),' on ',(⍕ref),' ',(⎕PW-1)⍴'-'
      :If ~batchFlag ⋄ ⎕←⊃¯1↑ps.log ⋄ :EndIf
      ps.stopAt∨←¯1∊×ps.testCaseNos
      ProcessTestCases ref ps
     ∆GetOutOfHere:
      ExecuteCleanup ref
      ref.⎕EX'INI'               ⍝ Get rid of any leftovers
      (rc log)←ReportTestResults ps
      ref.TestCasesExecutedAt←##.APLTreeUtils.FormatDateTime ⎕TS
    ∇

      GetTestNo←{
      ⍝ Take a string like "Test_001" or "Test_MyGroup_002" and return just the number
          {⍎⌽⍵↑⍨¯1+⍨⍵⍳'_'}⌽⍵
      }

    ∇ ExecuteInitial(ref parms)
      :If 3=ref.⎕NC'Initial'
          :Select ↑(⎕IO+1)⊃1 ref.⎕AT'Initial'
          :Case 0
              ref.Initial
          :Case 1
              ref.Initial parms
          :Else
              11 ⎕SIGNAL⍨'The "Initial" function in ',(⍕ref),' has an invalid signature: it''s neither monadic nor niladic'
          :EndSelect
      :EndIf
    ∇

    ∇ ProcessGroupAndTestCaseNumbers(ref ps);rc;lookFor
      ps.group←''
      :If ~0∊⍴ps.testCaseNos
          :If ' '=1↑0⍴∊ps.testCaseNos
              :If 0 1∊⍨≡ps.testCaseNos
                  ps.group←ps.testCaseNos
                  ps.testCaseNos←⍬
              :Else
                  ps.group←1⊃ps.testCaseNos
                  ps.testCaseNos←∊1↓ps.testCaseNos
              :EndIf
          :Else
              ps.group←''
          :EndIf
          :If ~0∊⍴ps.group
              :If 3=ref.⎕NC ps.group
                  ps.list←,⊂ps.group
                  ps.group←''
              :Else
                  lookFor←(('Test_'{⍵≡(⍴⍺)↑⍵}ps.group)/'_'),ps.group
                  :If '*'=¯1↑lookFor
                      lookFor←¯1↓lookFor
                  :Else
                      lookFor,←'_'
                  :EndIf
                  ps.list←(∨/¨(⊂lookFor)⍷¨ps.list)/ps.list  ⍝ First restrict to group
              :EndIf
          :EndIf
          :If 0∊⍴ps.list ⋄ →rc←0 ⋄ :EndIf
          :If (,0)≡,ps.testCaseNos
              ps.testCaseNos←¯1
          :Else
              :If ~0∊⍴ps.testCaseNos
                  :If 0∊⍴ps.group
                      :If 0∊⍴ps.list←(1={'_'+.=⍵}¨ps.list)/ps.list
                          →rc←0
                      :EndIf
                  :EndIf
              :AndIf 0∊⍴ps.list←((GetTestNo¨ps.list)∊|ps.testCaseNos)/ps.list   ⍝ Now select the numbers
                  →rc←0
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ ProcessTestCases(ref ps);width;i;noOf;this;testNo;rc;msg
      width←⌈/⍴¨ps.list
      :For i :In ⍳noOf←⍴ps.list
          this←i⊃ps.list
          testNo←GetTestNo this
          :Trap ps.trapFlag/0
              rc←ExecuteTestFunction ref ps testNo this
              :If ¯1=rc
                  ps.batchTests+←1
              :Else
                  ps.counter+←rc
              :EndIf
              msg←{⍵↓⍨+/∧\' '=⍵}{⍵↓⍨⍵⍳'⍝'}2⊃ref.⎕NR this
              ps.log,←⊂('* '[1+rc∊0 ¯1]),' ',this,' (',(⍕i),' of ',(⍕noOf),') : ',msg
              :If ps.batchFlag
                  :If 0<ps.errCounter
                      rc←1
                      :Continue
                  :EndIf
              :Else
                  ⎕←⊃¯1↑ps.log
              :EndIf
          :Else
              ps.errCounter+←1
              msg←{⍵↓⍨+/∧\' '=⍵}{⍵↓⍨⍵⍳'⍝'}2⊃ref.⎕NR this
              ps.log,←⊂'# ',this,,' (',(⍕i),' of ',(⍕noOf),') : ',msg
              :If ~ps.batchFlag
                  ⎕←⊃¯1↑ps.log
              :EndIf
          :EndTrap
      :EndFor
⍝Done
    ∇

    ∇ HandleStops(fns ps StopHere testNo)
      :If 0<ps.stopAt
      :AndIf testNo≥ps.stopAt
          (∪(⎕STOP fns),StopHere)⎕STOP fns
      :Else
          ((⎕STOP fns)~StopHere)⎕STOP fns
      :EndIf
    ∇

    ∇ (rc log)←ReportTestResults ps
      log←ps.log
      log,←⊂(⎕PW-1)⍴'-'
      log,←⊂'  ',(⍕1⊃⍴ps.list),' test case',((1≠1⊃⍴ps.list)/'s'),' executed'
      log,←⊂'  ',(⍕ps.counter),' test case',((1≠+/ps.counter)/'s'),' failed'
      log,←⊂'  ',(⍕ps.errCounter),' test case',((1≠+/ps.errCounter)/'s'),' broken'
      :If ps.batchTests>0
          log,←⊂'  ',(⍕ps.batchTests),' test cases not executed because they are not "batchable"'
      :EndIf
      :If ~ps.batchFlag
          ⎕←,[1.5](-4+ps.batchTests>0)↑log
      :EndIf
      :If 0<ps.counter+ps.errCounter
          rc←1
      :Else
          rc←2×0<ps.batchTests
      :EndIf
    ∇

    ∇ ExecuteCleanup ref
      :If 3=ref.⎕NC'Cleanup'
          ref.Cleanup
      :EndIf
    ∇

    ∇ rc←ExecuteTestFunction(ref ps testNo fnsName)
      HandleStops(1⊃⎕SI)ps ∆StopHere testNo
     ∆StopHere:rc←ref.⍎fnsName,' ',(⍕ps.debugFlag),' ',(⍕ps.batchFlag)
    ∇

:EndClass