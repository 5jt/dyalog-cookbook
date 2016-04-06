:Namespace Utilities
⍝ Dyalog Cookbook, Chapter 02
⍝ Vern: sjt29mar16

    ⍝ Ubiquitous functions that for local purposes
    ⍝  effectively extend the language
    ⍝ Treat as reserved words: do not shadow

    caseDn←{0(819⌶)⍵}
    caseUp←{1(819⌶)⍵}

      map←{
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }

:EndNamespace
