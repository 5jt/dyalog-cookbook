:Namespace Tests
⍝ Dyalog Cookbook, Version 06
⍝ Tests
⍝ Vern: sjt26jul16

    C←#.Constants
    EN_lower←'abcdefghijklmnopqrstuvwxyz'
    ⍝ accented Latin and Greek characters
    AccentedUpper←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝΆΈΉΊΌΎΏ'
    AccentedLower←'áâãàäåçðèêëéìíîïñòóôõöøùúûüýάέήίόύώ'

    TEST_FLDR←'./tests/'

    ∇ Initial;file
      :If ⎕NEXISTS TEST_FLDR
          :For file :In ⊃C.NINFO.NAME(⎕NINFO⍠'Wildcard' 1)TEST_FLDR,'*.*'
              ⎕NDELETE file
          :EndFor
      :Else
          ⎕MKDIR TEST_FLDR
      :EndIf
    ∇

    ⍝ #.Utilities.toLowercase

    ∇ Z←Test_toLowercase_001(debugFlag batchFlag)
     ⍝ boundary case
      Z←''≢#.Utilities.toLowercase''
    ∇

    ∇ Z←Test_toLowercase_002(debugFlag batchFlag)
     ⍝ no case
      Z←∆≢#.Utilities.toLowercase ∆←' .,/'
    ∇

    ∇ Z←Test_toLowercase_003(debugFlag batchFlag)
     ⍝ base case
      Z←EN_lower≢#.Utilities.toLowercase ⎕A
    ∇

    ∇ Z←Test_toLowercase_004(debugFlag batchFlag)
     ⍝ accented Latin and Greek characters
      Z←AccentedLower≢#.Utilities.toLowercase AccentedUpper
    ∇


    ⍝ #.Utilities.toUppercase

    ∇ Z←Test_toUppercase_001(debugFlag batchFlag)
     ⍝ boundary case
      Z←''≢#.Utilities.toLowercase''
    ∇

    ∇ Z←Test_toUppercase_002(debugFlag batchFlag)
     ⍝ no case
      Z←∆≢#.Utilities.toUppercase ∆←' .,/'
    ∇

    ∇ Z←Test_toUppercase_003(debugFlag batchFlag)
     ⍝ base case
      Z←⎕A≢#.Utilities.toUppercase EN_lower
    ∇

    ∇ Z←Test_toUppercase_004(debugFlag batchFlag)
     ⍝ accented Latin and Greek characters
      Z←AccentedUpper≢#.Utilities.toUppercase AccentedLower
    ∇

    ⍝ #.Utilities.toTitlecase

    ∇ Z←Test_toTitlecase_001(debugFlag batchFlag)
     ⍝ base case
      Z←'The Quick Brown Fox'≢#.Utilities.toTitlecase'THE quick BROWN fox'
    ∇

    ∇ Z←Test_toTitlecase_002(debugFlag batchFlag)
     ⍝ Greek script
      Z←'Όι Πολλοί'≢#.Utilities.toTitlecase'όι ΠΟΛΛΟΊ'
    ∇

    ⍝ #.MyApp.CountLetters

    ∇ Z←Test_CountLetters_001(debugFlag batchFlag);a;r
     ⍝ base case
      a←#.MyApp.Params.ALPHABETS.English
      r←('BCEFHIKNOQRTUWX')(1 1 1 1 1 1 1 1 2 1 1 1 1 1 1)
      Z←r≢↓[1]a #.MyApp.CountLetters'The Quick Brown Fox'
    ∇

    ⍝ #.MyApp.CountLettersIn

    ∇ Z←Test_CountLettersIn_001(debugFlag batchFlag);a;files;cf;cc2n;sas;res
     ⍝ across multiple files
      a←#.MyApp.Params.ALPHABETS.English
      cc2n←{2 1∘⊃¨⎕VFI¨2↓¨⍵}                    ⍝ CSV col 2 as numbers
      res←TEST_FLDR,'count.csv'                 ⍝ results file
      sas←{⍵[?⍨≢⍵]}                             ⍝ scramble a string
      cf←?1000⍴⍨5,≢a                            ⍝ random freqs for 5 files
      files←{TEST_FLDR,'test',⍵,'.txt'}∘⍕¨⍳≢cf
      (sas¨(↓cf)/¨⊂a)⎕NPUT¨files
      :If Z←#.MyApp.EXIT.OK≢a #.MyApp.CountLettersIn files res
      :OrIf Z←(+⌿cf)≢cc2n⊃⎕NGET res 1
      :EndIf
    ∇

:EndNamespace
