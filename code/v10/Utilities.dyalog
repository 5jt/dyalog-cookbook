:Namespace Utilities
      map←{
          (,2)≢⍴⍺:'Left argument is not a two-element vector'⎕SIGNAL 5
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }
    Assert←{⍺←'' ⋄ (success errorNo)←2↑⍵,11 ⋄ (,1)≡,success:r←1 ⋄ ⍺ ⎕SIGNAL errorNo}
:EndNamespace
