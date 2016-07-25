:Namespace DevTools
⍝ Developer tools 
⍝ Vern: sjt25jul16

    fc←{⍺(≢⍵)}⌸ ⍝ frequency count
    same←{⍵≡¨⊂⊃⍵}∘,
    type←{type←{'CN'[⎕IO+0=⊃0⍴⊃⍣≡⍵]}}
    wi←{(≡⍵)(type ⍵)(⍴⍵)} ⍝ what is this array?

:EndNamespace
