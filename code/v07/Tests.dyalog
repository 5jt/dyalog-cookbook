:Namespace Tests
⍝ Dyalog Cookbook, Version 07
⍝ Tests
⍝ Vern: sjt28sep16

    (A C M U)←#.(APLTreeUtils Constants MyApp Utilities)
    EN_lower←'abcdefghijklmnopqrstuvwxyz'
    ⍝ accented Latin and Greek characters
    AccentedUpper←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝΆΈΉΊΌΎΏ'
    AccentedLower←'áâãàäåçðèêëéìíîïñòóôõöøùúûüýάέήίόύώ'

    TEST_FLDR←'./tests/'

    ∇ Initial;file
      :If ⎕NEXISTS TEST_FLDR
          EraseFilesIn TEST_FLDR
      :Else
          ⎕MKDIR TEST_FLDR
      :EndIf
    ∇

    ∇ EraseFilesIn folder
      :For file :In ⊃C.NINFO.NAME(⎕NINFO⍠'Wildcard' 1)folder,'*.*'
          ⎕NDELETE file
      :EndFor
    ∇

    ⍝ #.Utilities.push

    ∇ failed←Test_push_001(debugFlag batchFlag)
     ⍝ string and string
      failed←'abc' 'def'≢'abc'U.push'def'
    ∇

    ∇ failed←Test_push_002(debugFlag batchFlag)
     ⍝ string and strings
      failed←'abc' 'def' 'ghi'≢'abc'U.push'def' 'ghi'
    ∇

    ∇ failed←Test_push_003(debugFlag batchFlag)
     ⍝ string and strings
      failed←'abc' 'def' 'ghi'≢'abc' 'def'U.push'ghi'
    ∇

    ∇ failed←Test_push_004(debugFlag batchFlag)
     ⍝ string and strings
      failed←'abc' 'def' 'ghi' 'jkl'≢'abc' 'def'U.push'ghi' 'jkl'
    ∇

    ∇ failed←Test_push_005(debugFlag batchFlag)
     ⍝ scalar and strings
      failed←'a' 'def' 'ghi'≢'a'U.push'def' 'ghi'
    ∇

    ∇ failed←Test_push_006(debugFlag batchFlag)
     ⍝ scalar and scalar
      failed←'ab'≢'a'U.push'b'
    ∇


    ⍝ #.Utilities.toLowercase

    ∇ failed←Test_toLowercase_001(debugFlag batchFlag)
     ⍝ boundary case
      failed←''≢U.toLowercase''
    ∇

    ∇ failed←Test_toLowercase_002(debugFlag batchFlag);∆
     ⍝ no case
      failed←∆≢U.toLowercase ∆←' .,/'
    ∇

    ∇ failed←Test_toLowercase_003(debugFlag batchFlag)
     ⍝ base case
      failed←EN_lower≢U.toLowercase ⎕A
    ∇

    ∇ failed←Test_toLowercase_004(debugFlag batchFlag)
     ⍝ accented Latin and Greek characters
      failed←AccentedLower≢U.toLowercase AccentedUpper
    ∇


    ⍝ #.Utilities.toUppercase

    ∇ failed←Test_toUppercase_001(debugFlag batchFlag)
     ⍝ boundary case
      failed←''≢U.toLowercase''
    ∇

    ∇ failed←Test_toUppercase_002(debugFlag batchFlag);∆
     ⍝ no case
      failed←∆≢U.toUppercase ∆←' .,/'
    ∇

    ∇ failed←Test_toUppercase_003(debugFlag batchFlag)
     ⍝ base case
      failed←⎕A≢U.toUppercase EN_lower
    ∇

    ∇ failed←Test_toUppercase_004(debugFlag batchFlag)
     ⍝ accented Latin and Greek characters
      failed←AccentedUpper≢U.toUppercase AccentedLower
    ∇

    ⍝ #.Utilities.toTitlecase

    ∇ failed←Test_toTitlecase_001(debugFlag batchFlag)
     ⍝ base case
      failed←'The Quick Brown Fox'≢U.toTitlecase'THE quick BROWN fox'
    ∇

    ∇ failed←Test_toTitlecase_002(debugFlag batchFlag)
     ⍝ Greek script
      failed←'Όι Πολλοί'≢U.toTitlecase'όι ΠΟΛΛΟΊ'
    ∇

    ∇ failed←Test_within_001(debugFlag batchFlag)
     ⍝ empty strings
      failed←''≢''M.within''
    ∇

    ∇ failed←Test_within_002(debugFlag batchFlag)
     ⍝ scalars
      failed←'b\a'≢'a'M.within'b'
    ∇

    ∇ failed←Test_within_003(debugFlag batchFlag)
     ⍝ plain strings
      failed←'foo\bar'≢'bar'M.within'foo'
    ∇

    ∇ failed←Test_within_004(debugFlag batchFlag)
     ⍝ folder has trailing \
      failed←'foo\bar'≢'bar'M.within'foo\'
    ∇

    ⍝ #.MyApp.CountLetters

    ∇ failed←Test_CountLetters_001(debugFlag batchFlag);a;r
     ⍝ base case
      a←M.PARAMETERS.ALPHABETS.English
      r←a,[1.5]0 1 1 0 1 1 0 1 1 0 1 0 0 1 2 0 1 1 0 1 1 0 1 1 0 0
      failed←r≢a M.CountLetters'The Quick Brown Fox'
    ∇

    ⍝ #.MyApp.CountLettersIn

    ∇ failed←Test_CountLettersIn_001(debugFlag batchFlag)
     ⍝ across multiple files
      failed←testOnFiles'APL' 5 'English'
    ∇

    ∇ failed←testOnFiles(testmode nfiles alphabet);cd;cf;xxx;job;result;∆;cmd;characters
      characters←M.ALPHABETS⍎alphabet
     
      EraseFilesIn TEST_FLDR
      cf←?1000⍴⍨nfiles,≢characters                      ⍝ random freqs for nfiles files
      result←characters,[1.5]+⌿cf                       ⍝ correct result
      ∆←{TEST_FLDR,'test',⍵,'.txt'}∘⍕¨⍳nfiles           ⍝ full filenames
      ({⍵[?⍨≢⍵]}¨(↓cf)/¨⊂characters)⎕NPUT¨∆             ⍝ write test files
     
      job←M.CreateJob
      job.(alphabet out source)←alphabet '' TEST_FLDR
      job←M.CheckAgenda job
     
      :If ~failed←job.characters≢characters             ⍝ CHARACTER SET MISMATCH
      :AndIf ~failed←job.status≢'VALIDATED'
          :Select testmode
          :Case 'APL'                                   ⍝ do the work here
              job←M.CountLettersIn job
              :If ~failed←job.status≢'OK'               ⍝ PROCESSING ERROR
                  failed←result≢job.table               ⍝ RESULT TABLE MISMATCH
              :EndIf
          :Case 'EXE'                                   ⍝ call the EXE to do the work
              xxx←⎕CMD,U.ScriptFollowing
              ⍝.\myapp.exe source="{TEST_FLDR}" alphabet={alph}
              failed←~⎕NEXISTS job.out                  ⍝ RESULT FILE MISSING
          :EndSelect
          :If ~failed
              ∆←⎕NGET job.out C.NGET.LINES
              failed←result≢↑{(⊃⍵),⊃⊣//⎕VFI 2↓⍵}¨⊃∆     ⍝ RESULT FILE CONTENT MISMATCH
          :EndIf
      :EndIf
    ∇

    ⍝ EXE

    ∇ failed←Test_Exe_001(debugFlag batchFlag)
   ⍝ using EXE
      failed←testOnFiles'EXE' 10 'English'
    ∇

:EndNamespace
