﻿:Namespace Utilities
      map←{
          (,2)≢⍴⍺:'Left argument is not a two-element vector'⎕SIGNAL 5
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }
      Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⎕ML←3 ⋄ ⍺ ⎕SIGNAL 1↓(↑∊⍵),11}
:EndNamespace
