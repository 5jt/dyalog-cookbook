:Namespace Utilities
      map←{
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }      
    toLowercase←0∘(819⌶)
    toUppercase←1∘(819⌶)      
:EndNamespace