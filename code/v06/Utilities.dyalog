:Namespace Utilities
⍝ Dyalog Cookbook, MyApp v06
⍝ Vern: sjt25jul16

    ∇ env←GetEnv;addr;copy;getenv;this;⎕IO;⎕ML;isUnicode;incr;mult;k;v          ⍝ Get environment strings
     ⍝ Adapted from Dyalog workspace QUADNA to return a namespace
      ⎕IO←1
      ⎕ML←1
      isUnicode←80=⎕DR'a'
      'getenv'⎕NA'P kernel32∣GetEnvironmentStrings*'
     
      :If isUnicode
          'copy'⎕NA'msvcrt∣wcsncpy >0T P U4'
          incr←2
          mult←2
      :Else
          'copy'⎕NA'msvcrt∣strncpy >0T P U4'
          incr←1
          mult←1
      :EndIf
     
      env←⎕NS''
      addr←getenv                               ⍝ address of array of strings
      :While ×⍴this←,copy 256 addr 256          ⍝ copy in string
          (k v)←{i←⍵⍳'=' ⋄ (⍵↑⍨i-1)(⍵↓⍨i)}this
          :If ¯1≠⎕NC k                          ⍝ valid name
              env.⍎k,'←''',v,''''               ⍝ add it to the ones we already have
          :EndIf
          addr+←incr+mult×⍴this                 ⍝ increment our pointer
      :End
    ∇

     ⍝ element of ⍵ that matches (case-independently) ⍺
      ciFindin←{
          ⍵⊃⍨(toUppercase¨⍵)⍳⊂toUppercase ⍺
      }

    m2n←{trim¨↓⍵}                               ⍝ matrix to nest

      map←{
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }

    ∇ Z←ScriptFollowing;∆;∆∆lines;∆∆i;∆∆ln;∆∆lf;∆∆c1;∆∆c2;∆∆exps;∆∆resolve;∆∆2;∆∆ns
     ⍝ Contiguous following comment lines as a char matrix
     ⍝ and referenced expressions replaced with strings of their values
     ⍝ Expressions are referenced by braces, eg '{foo+bar}' is replaced with ,⍕foo+bar
     ⍝ Expressions may not span comment lines, nor be nested, nor refer to names with ∆∆ prefix
     ⍝ eg xxx←⎕FIX ScriptFollowing
     ⍝⍝ Z←X PLUS Y
     ⍝⍝⍝ Leading comment within embedded function (not returned)
     ⍝⍝ Z←X+Y
      ∆∆2←⎕IO+1
      ∆∆ln←∆∆2⊃⎕LC                              ⍝ suspended line of calling function
      ∆∆ns←{⍵↓⍨1-'.'⍳⍨⌽⍵}∆∆2⊃⎕XSI               ⍝ namespace of calling function
      ∆∆lf←(2↑∆∆ln+1)↓⎕CR ∆∆2⊃⎕XSI              ⍝ lines following
      ∆∆lf←(+/∧\' '=∆∆lf)⌽∆∆lf                  ⍝ left justified
      (∆∆c1 ∆∆c2)←↓'⍝'=⍉∆∆lf[;⍳2]               ⍝ flag comments in first two cols
      Z←1↓[∆∆2]((∧\∆∆c1)∧~∆∆c2)⌿∆∆lf            ⍝ script as matrix
     
      ∆∆resolve←∆∆ns∘{
          '{}'≢⊃,/1 ¯1↑¨⊂⍵:⍵    ⍝ ignore unembraced string
          '∆'∊⍵:⍵               ⍝ ignore expressions with ∆
          0::⍵
          ⍕⍎⍺,1↓¯1↓⍵
      }
     
      :If ∨/∆∆exps←(0=2|∆)∧×∆←+/Z∊'{}'              ⍝ any expns to resolve?
          ∆∆lines←↓Z
          :For ∆∆i :In {⍵/⍳≢⍵}∆∆exps
              (∆∆i⊃∆∆lines)←⊃,/∆∆resolve¨((∆='{')∨1,¯1↓∆='}')⊂∆←∆∆i⊃∆∆lines
          :EndFor
          Z←↑∆∆lines
      :EndIf
    ∇

    trim←{⍵/⍨(∨\b)∧⌽∨\⌽b←⍵≠' '}

    toLowercase←0∘(819⌶)
    toUppercase←1∘(819⌶)
      toTitlecase←{
          l←~u←1,¯1↓' '=z←⍵
          (u/z)←toUppercase u/z
          (l/z)←toLowercase l/z
          z
      }

:EndNamespace
