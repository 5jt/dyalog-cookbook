:Namespace Tests

    ∇ R←Test_001(stopFlag batchFlag);⎕TRAP
      ⍝ Check the length of the left argument
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
      :Trap 5
          {}(⊂⎕A)#.Utilities.map'APL is great'
          →FailsIf 1
      :Else
          →PassesIf'Left argument is not a two-element vector'≡↑⎕DM
      :EndTrap
      R←∆OK
    ∇

    ∇ R←Test_002(stopFlag batchFlag);⎕TRAP;Config;MyLogger
      ⍝ Check whether `map` works fine with appropriate data
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
      (Config MyLogger)←##.MyApp.Initial ⍬
      →FailsIf'APL IS GREAT'≢Config.Accents ##.Utilities.map ##.APLTreeUtils.Uppercase'APL is great'
      →FailsIf'UßU'≢Config.Accents ##.Utilities.map ##.APLTreeUtils.Uppercase'üßÜ'
      R←∆OK
    ∇

    ∇ R←Test_003(stopFlag batchFlag);⎕TRAP;rc
      ⍝ Test whether `TxtToCsv` handles a non-existing file correctly
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
      #.MyApp.(Config MyLogger)←##.MyApp.Initial ⍬
      rc←#.MyApp.TxtToCsv'This_file_does_not_exist'
      →FailsIf ##.MyApp.EXIT.SOURCE_NOT_FOUND≢rc
      R←∆OK
    ∇

    ∇ {r}←GetHelpers
      r←#.Tester.EstablishHelpersIn ⎕THIS
    ∇

:EndNamespace
