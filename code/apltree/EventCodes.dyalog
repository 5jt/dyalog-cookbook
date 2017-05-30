:Class EventCodes
⍝ This class carries all trappable event codes in Dyalog APL up to -- and including -- version 15.0.\\
⍝ For transforming a number to the symbolic name see function `GetName`.

    ⎕IO←1 ⋄ ⎕ML←1

    :Field Public Shared ReadOnly  WS_FULL                             ←1
    :Field Public Shared ReadOnly  SYNTAX_ERROR                        ←2
    :Field Public Shared ReadOnly  INDEX_ERROR                         ←3
    :Field Public Shared ReadOnly  RANK_ERROR                          ←4
    :Field Public Shared ReadOnly  LENGTH_ERROR                        ←5
    :Field Public Shared ReadOnly  VALUE_ERROR                         ←6
    :Field Public Shared ReadOnly  FORMAT_ERROR                        ←7
    :Field Public Shared ReadOnly  LIMIT_ERROR                         ←10
    :Field Public Shared ReadOnly  DOMAIN_ERROR                        ←11
    :Field Public Shared ReadOnly  HOLD_ERROR                          ←12
    :Field Public Shared ReadOnly  NONCE_ERROR                         ←16
    :Field Public Shared ReadOnly  FILE_TIE_ERROR                      ←18
    :Field Public Shared ReadOnly  FILE_ACCESS_ERROR                   ←19
    :Field Public Shared ReadOnly  FILE_INDEX_ERROR                    ←20
    :Field Public Shared ReadOnly  FILE_FULL                           ←21
    :Field Public Shared ReadOnly  FILE_NAME_ERROR                     ←22
    :Field Public Shared ReadOnly  FILE_DAMAGED                        ←23
    :Field Public Shared ReadOnly  FILE_TIED                           ←24
    :Field Public Shared ReadOnly  FILE_TIED_REMOTELY                  ←25
    :Field Public Shared ReadOnly  FILE_SYSTEM_ERROR                   ←26
    :Field Public Shared ReadOnly  FILE_SYSTEM_NOT_AVAILABLE           ←28
    :Field Public Shared ReadOnly  FILE_SYSTEM_TIES_USED_UP            ←30
    :Field Public Shared ReadOnly  FILE_TIE_QUOTA_USED_UP              ←31
    :Field Public Shared ReadOnly  FILE_NAME_QUOTA_USED_UP             ←32
    :Field Public Shared ReadOnly  FILE_SYSTEM_NO_SPACE                ←34
    :Field Public Shared ReadOnly  FILE_ACCESS_ERROR_CONVERTING_FILE   ←35
    :Field Public Shared ReadOnly  FILE_COMPONENT_DAMAGED              ←38
    :Field Public Shared ReadOnly  FIELD_CONTENTS_RANK_ERROR           ←52
    :Field Public Shared ReadOnly  FIELD_CONTENTS_TOO_MANY_COLUMNS     ←53
    :Field Public Shared ReadOnly  FIELD_POSITION_ERROR                ←54
    :Field Public Shared ReadOnly  FIELD_SIZE_ERROR                    ←55
    :Field Public Shared ReadOnly  FIELD_CONTENTS_TYPE_MISMATCH        ←56
    :Field Public Shared ReadOnly  FIELD_TYPE_BEHAVIOUR_UNRECOGNISED   ←57
    :Field Public Shared ReadOnly  FIELD_ATTRIBUTES_RANK_ERROR         ←58
    :Field Public Shared ReadOnly  FIELD_ATTRIBUTES_LENGTH_ERROR       ←59
    :Field Public Shared ReadOnly  FULL_SCREEN_ERROR                   ←60
    :Field Public Shared ReadOnly  KEY_CODE_UNRECOGNISED               ←61
    :Field Public Shared ReadOnly  KEY_CODE_RANK_ERROR                 ←62
    :Field Public Shared ReadOnly  KEY_CODE_TYPE_ERROR                 ←63
    :Field Public Shared ReadOnly  FORMAT_FILE_ACCESS_ERROR            ←70
    :Field Public Shared ReadOnly  FORMAT_FILE_ERROR                   ←71
    :Field Public Shared ReadOnly  NO_PIPES                            ←72
    :Field Public Shared ReadOnly  PROCESSOR_TABLE_FULL                ←76
    :Field Public Shared ReadOnly  TRAP_ERROR                          ←84
    :Field Public Shared ReadOnly  EXCEPTION                           ←90
    :Field Public Shared ReadOnly  TRANSLATION_ERROR                   ←92
    :Field Public Shared ReadOnly  STOP_VECTOR                         ←1001
    :Field Public Shared ReadOnly  WEAK_INTERRUPT                      ←1002
    :Field Public Shared ReadOnly  INTERRUPT                           ←1003
    :Field Public Shared ReadOnly  EOF_INTERRUPT                       ←1005
    :Field Public Shared ReadOnly  TIMEOUT                             ←1006
    :Field Public Shared ReadOnly  RESIZE                              ←1007
    :Field Public Shared ReadOnly  DEADLOCK                            ←1008

    ∇ r←Version
      :Access Public Shared
      r←({⍵}⍕⎕THIS)'1.1.0' '2017-05-18'
    ∇

    ∇ History
      :Access Public Shared
      ⍝ * 1.1.0 ⋄ 2017-04-25
      ⍝   * `GetName` can now process vectors as well.
      ⍝   * Method `History` added
      ⍝   * Now managed by acre 3
      ⍝ * 1.0.0 ⋄ 2017-04-07
    ∇

    ∇ __name←GetName __eventCode;__allNumbers;__ind
    ⍝ Returns the symbolic names for one or more event codes.
    ⍝ * If the right argument is a scalar or a one-element vector then a text vector is returned.
    ⍝ * If the right argument is a vector then a vector of text vectors is returned.
      :Access Public Shared
      :If 0∊⍴__eventCode
          __name←''
      :Else
          __allNumbers←⎕NL-2
          __allNumbers←⍎¨('__'∘≢¨2↑¨__allNumbers)/__allNumbers
          __ind←__allNumbers⍳__eventCode
          'Unknown event number'⎕SIGNAL 6/⍨__ind∨.>⍴__allNumbers
          __name←(⎕NL-2)[__ind]
          __name←⊃∘,⍣(⊃1=⍴,__ind)⊣__name
      :EndIf
    ∇

    ∇ __allNumbers←List __start
    ⍝ Returns a matrix with all symbolic names and their numbers in case `__start` is empty.\\
    ⍝ In case `__start` is not empty only the symbolic names that start with `__start` are listed.\\
    ⍝ `start` is **not** case sensitive.
      :Access Public Shared
      __allNumbers←⎕NL-2
      __allNumbers←('__'∘≢¨2↑¨__allNumbers)/__allNumbers
      __allNumbers←__allNumbers,[1.5]⍎¨__allNumbers
      :If ~0∊⍴__start←{1(819⌶)⍵}__start~'*'
          __allNumbers←(((⍴,__start)↑[2]↑__allNumbers[;1])∧.=__start)⌿__allNumbers
      :EndIf
    ∇

:EndClass
