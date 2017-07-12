:Namespace DevHelpers
⍝ This namespace contains helpers that might be useful during the development process.
⍝ It has no place in the final application.

    ∇ flag←YesOrNo question;isOkay;answer
      isOkay←0
      ⎕←(⎕PW-1)⍴'-'
      :Repeat
          ⍞←question,' (y/n) '
          answer←¯1↑⍞
          :If answer∊'YyNn'
              isOkay←1
              flag←answer∊'Yy'
          :EndIf
      :Until isOkay
    ∇

    ∇ {r}←RunTests forceFlag
 ⍝ Runs the test cases in debug mode, either in case the user wants to or if `forceFlag` is 1.
      r←''
      :If forceFlag
      :OrIf YesOrNo'Would you like to execute all test cases in debug mode?'
          r←#.Tests.RunDebug 0
      :EndIf
    ∇

:EndNamespace
