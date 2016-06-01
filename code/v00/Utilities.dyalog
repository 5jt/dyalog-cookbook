:Namespace Utilities
⍝ Dyalog Cookbook, MyApp v00
⍝ Vern: sjt01jun16


      map←{
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }
      
    toLowercase←0∘(819⌶)
    toUppercase←1∘(819⌶)

:EndNamespace
