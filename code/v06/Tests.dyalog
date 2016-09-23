:Namespace Tests
⍝ Dyalog Cookbook, Version 06
⍝ Tests
⍝ Vern: sjt03aug16

    (C U)←#.Constants #.Utilities
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
      failed←''≢#.Utilities.toLowercase''
    ∇

    ∇ failed←Test_toLowercase_002(debugFlag batchFlag);∆
     ⍝ no case
      failed←∆≢#.Utilities.toLowercase ∆←' .,/'
    ∇

    ∇ failed←Test_toLowercase_003(debugFlag batchFlag)
     ⍝ base case
      failed←EN_lower≢#.Utilities.toLowercase ⎕A
    ∇

    ∇ failed←Test_toLowercase_004(debugFlag batchFlag)
     ⍝ accented Latin and Greek characters
      failed←AccentedLower≢#.Utilities.toLowercase AccentedUpper
    ∇


    ⍝ #.Utilities.toUppercase

    ∇ failed←Test_toUppercase_001(debugFlag batchFlag)
     ⍝ boundary case
      failed←''≢#.Utilities.toLowercase''
    ∇

    ∇ failed←Test_toUppercase_002(debugFlag batchFlag);∆
     ⍝ no case
      failed←∆≢#.Utilities.toUppercase ∆←' .,/'
    ∇

    ∇ failed←Test_toUppercase_003(debugFlag batchFlag)
     ⍝ base case
      failed←⎕A≢#.Utilities.toUppercase EN_lower
    ∇

    ∇ failed←Test_toUppercase_004(debugFlag batchFlag)
     ⍝ accented Latin and Greek characters
      failed←AccentedUpper≢#.Utilities.toUppercase AccentedLower
    ∇

    ⍝ #.Utilities.toTitlecase

    ∇ failed←Test_toTitlecase_001(debugFlag batchFlag)
     ⍝ base case
      failed←'The Quick Brown Fox'≢#.Utilities.toTitlecase'THE quick BROWN fox'
    ∇

    ∇ failed←Test_toTitlecase_002(debugFlag batchFlag)
     ⍝ Greek script
      failed←'Όι Πολλοί'≢#.Utilities.toTitlecase'όι ΠΟΛΛΟΊ'
    ∇

    ∇ failed←Test_within_001(debugFlag batchFlag)
     ⍝ empty strings
      failed←''≢''#.MyApp.within''
    ∇

    ∇ failed←Test_within_002(debugFlag batchFlag)
     ⍝ scalars
      failed←'b\a'≢'a'#.MyApp.within'b'
    ∇

    ∇ failed←Test_within_003(debugFlag batchFlag)
     ⍝ plain strings
      failed←'foo\bar'≢'bar'#.MyApp.within'foo'
    ∇

    ∇ failed←Test_within_004(debugFlag batchFlag)
     ⍝ folder has trailing \
      failed←'foo\bar'≢'bar'#.MyApp.within'foo\'
    ∇

    ⍝ #.MyApp.CountLetters

    ∇ failed←Test_CountLetters_001(debugFlag batchFlag);a;r
     ⍝ base case
      a←#.MyApp.PARAMETERS.ALPHABETS.English
      r←a,[1.5] 0 1 1 0 1 1 0 1 1 0 1 0 0 1 2 0 1 1 0 1 1 0 1 1 0 0
      failed←r≢a #.MyApp.CountLetters'The Quick Brown Fox'
    ∇

    ⍝ #.MyApp.CountLettersIn

    ∇ failed←Test_CountLettersIn_001(debugFlag batchFlag)
     ⍝ across multiple files
      failed←testOnFiles'APL' 5 'English'
    ∇

    ∇ failed←testOnFiles(testmode nfiles alph);cd;files;res;cc2n;cf;xxx;alphabet;cmd
      EraseFilesIn TEST_FLDR
      alphabet←#.MyApp.PARAMETERS.ALPHABETS⍎alph
      cf←?1000⍴⍨nfiles,≢alphabet                            ⍝ random freqs for nfiles files
      files←{TEST_FLDR,'test',⍵,'.txt'}∘⍕¨⍳nfiles           ⍝ full filenames
      ({⍵[?⍨≢⍵]}¨(↓cf)/¨⊂alphabet)⎕NPUT¨files
      res←(¯1↓TEST_FLDR),'.csv'                             ⍝ result file
      :If ~failed←{~⎕NEXISTS ⍵:0 ⋄ ~⎕NDELETE ⍵}res
          :Select testmode
          :Case 'APL'
              failed←#.MyApp.EXIT.OK≢alphabet #.MyApp.CountLettersIn files res
          :Case 'EXE'
              cmd←'.\myapp.exe source="',TEST_FLDR,'" alphabet=',alph
              xxx←⎕CMD cmd
              failed←~⎕NEXISTS res
          :EndSelect
          :If ~failed
              cc2n←{2 1∘⊃¨⎕VFI¨2↓¨⍵}                        ⍝ CSV col 2 as numbers
              failed←(+⌿cf)≢cc2n⊃⎕NGET res C.NGET.LINES
          :EndIf
      :EndIf
    ∇

    ⍝ EXE

  ∇ failed←Test_Exe_001(debugFlag batchFlag)
   ⍝ using EXE
    failed←testOnFiles'EXE' 10 'English'
  ∇

:EndNamespace
