:Namespace Utilities
⍝ Dyalog Cookbook, MyApp v04
⍝ Vern: sjt01jun16

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

      map←{
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }
      
      trim←{⍵/⍨(∨\b)∧⌽∨\⌽b←⍵≠' '}

    toLowercase←0∘(819⌶)
    toUppercase←1∘(819⌶)

:EndNamespace
