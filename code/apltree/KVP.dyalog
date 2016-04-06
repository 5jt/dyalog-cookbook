:Class KVP
⍝ <h2>Overview</h2>
⍝ This class manages key-value-pairs (KVP). Values can be accessed by specifying _
⍝ a name or some names. In most cases you should be able to use this class as it is. _
⍝ If you need something this class is not offering, consider to take it as a base _
⍝ class. By setting appropriate properties this class may or may not act case _
⍝ sensitive and may or may not return a default value for undefined keys.
⍝ <h2>Examples</h2>
⍝ <pre>myKVP←⎕NEW #.KVP</pre>
⍝ <pre>myKVP[⊂'key']←⊂'new'                ⍝ create a new key</pre>
⍝ <pre>myKVP[⊂'key']←⊂'not new any longer' ⍝ overwrite a key</pre>
⍝ <pre>myKVP.Merge ('APL' 'Powerful') ('Cobol' 'Mouthy') ('Assembler' 'Fast')</pre>
⍝ <pre>scd←⎕new #.KVP ⋄ scd[⊂'APL']←⊂'Very powerful' ⋄ myKVP.Merge scd</pre>
⍝ <pre>(⊂'Very powerful') ←→ myKVP[⊂'APL']</pre>
⍝ <pre>('Very powerful' 'Fast') ←→ myKVP['APL' 'Assembler']</pre>
⍝ <pre>'Very powerful' ←→ myKVP.GetItem 'APL'</pre>
⍝ <pre>myKVP.SetItem ('APL' 'Powerful')</pre>
⍝ <h2>Threads</h2>
⍝ Every method is using :Hold internally, so the class is supposed to be thread-save.
⍝ <h2>Specialities</h2>
⍝ Apart from the methods for every-day-tasks (get, merge, delete, ...) _
⍝ there are also build-in methods available for:
⍝ # Searching keys or data
⍝ # Get all keys or all data
⍝ # Sort by key
⍝ # Get keys and data as a nested matrix
⍝ # Get keys and data as a vector of (name/values) pairs
⍝ <h2>Locking</h2>
⍝ Note that you can prevent the user from adding or deleting keys by setting _
⍝ "updateOnly"  to 1. The user can still change the value of particular keys then.
⍝ You can lock it completely by setting "freeze" to 1. The user might _
⍝ still request data from the instance but cannot change anything.
⍝ <h2>To do</h2>
⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/KVP
    ⎕io←    ⎕ml←1

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public shared
      r←(Last⍕⎕THIS)'1.7.0' '2015-01-10'
      ⍝ 1.7.0: `History` removed.
      ⍝        `Version fixed.
    ∇

    uuidFlag←1

    :Property UUID
    ⍝ Unique name (UUID) used for thread savening.
    :Access Public
        ∇ r←get
          r←_UUID
        ∇
    :EndProperty

    :Property freeze
    ⍝ Defaults to 0. If 1 you can't add/delete/change any data
    :Access Public
        ∇ r←get
          r←_freeze
        ∇
        ∇ set val
          'Invalid value for "freeze"'⎕SIGNAL 11/⍨~val.NewValue∊0 1
          _freeze←val.NewValue
        ∇
    :EndProperty

    :Property updateOnly
    ⍝ Defaults to 1. If 0 you can change values but neither add nor delete keys
    :Access Public
        ∇ r←get
          r←_updateOnly
        ∇
        ∇ set val
          'Invalid value for "updateOnly"'⎕SIGNAL 11/⍨~val.NewValue∊0 1
          _updateOnly←val.NewValue
        ∇
    :EndProperty

    :Property case
    ⍝ String that defines how to perform comparisons. Appropriate values _
    ⍝ are "sensitive" and "ignore". Any other value will cause an excption.
    ⍝ Note that the setting does *not* affect the way keys are saved or _
    ⍝ even returned: it affects just comparisons.
    ⍝ You can change this property at any time.
    :Access Public
        ∇ r←get
          r←_case
        ∇
        ∇ set val;new
          :Hold uuidFlag/_UUID
              new←Lowercase val.NewValue
              :If (⊂new)∊'sensitive' 'ignore'
                  _case←val.NewValue
              :Else
                  11 ⎕SIGNAL⍨'Invalid value; must be either "sensitive" or "ignore"'
              :EndIf
          :EndHold
        ∇
    :EndProperty

    :Property Default Keyed data
    ⍝ This property holds the key-value-pair. Internally, keys and data are kept separate from each other.
        ∇ set val;where;key;bool;EndHold
          'The KVP is locked ("freeze"←→1)'⎕SIGNAL _freeze/11
          :Hold uuidFlag/_UUID
              key←⊃val.Indexers
              'Length Error'⎕SIGNAL(≠/⊃∘⍴¨,¨key(,val.NewValue))/11
              where←(HandleCase _keys)⍳HandleCase key
              :If ∨/bool←(⍴_data)≥where
                  _data[bool/where]←bool/val.NewValue
              :EndIf
              bool←~bool
              :If ∨/bool
                  'You may change existing keys, but you cannot add new ones: ("updateonly"←→1)'⎕SIGNAL _updateOnly/11
                  _keys,←,¨bool/key
                  _data,←bool/val.NewValue
                  _remarks,←(+/bool)⍴⊂''
              :EndIf
          :EndHold
        ∇

        ∇ r←get arg;where;keys;bool
          :Hold uuidFlag/_UUID
              keys←HandleCase fixkeys⊃arg.Indexers
              where←(HandleCase _keys)⍳keys
              :If ∧/bool←(⍴_data)≥where
                  :If 2=≡arg.Indexers
                      r←where⊃_data
                  :Else
                      r←_data[where]
                  :EndIf
              :Else
                  :If _hasDefault
                      r←(⍴,keys)⍴⊂_default
                      r[{⍵/⍳⍴⍵}bool]←_data[bool/where]
                  :Else
                      6 ⎕SIGNAL⍨'Value Error, don''t know: ',1⊃,{⍺,',',⍵}/(~bool)/keys
                  :EndIf
              :EndIf
          :EndHold
        ∇
    :EndProperty

⍝ --------- Constructors

    ∇ make
    ⍝ Create a new, empty KVP with default settings.
      :Access Public
      :Implements Constructor
      Init ⍬
    ∇

    ∇ make1(default)
     ⍝ Create a new, empty KVP with default settings. The right argument is used _
     ⍝ to define a "default value". If the getter gets passed a non-existing key, _
     ⍝ the default value is returned for such a key. Without a default value, a _
     ⍝ "Value Error" is thrown.
      :Access Public
      :Implements Constructor
      _default←default
      Init ⍬
    ∇

    ∇ Init dummy
      _keys←0/⊂''
      _data←0/⊂''
      _remarks←0/⊂''
      _updateOnly←0
      _freeze←0
      _case←'ignore'
      _hasDefault←2=⎕NC'_default'
      _UUID←CreateUUID
    ∇

⍝ --------- Methods

    ∇ r←Type
      :Access Public Shared
      r←'KVP'
    ∇

    ∇ r←GetItem name;where;bool
    ⍝ Alternative to the []-syntax. This methods accepts a single name only _
    ⍝ and returns the data disclosed.
    ⍝ The method throws an exception in case the key is unknown and no default is defined.
      :Access Public
      :Hold uuidFlag/_UUID
          'Right argument must be a string (single name)'⎕SIGNAL 11/⍨~0 1∊⍨≡name
          :If (1⊃⍴_keys)≥where←(HandleCase _keys)⍳⊂HandleCase name
              r←where⊃_data
          :Else
              :If _hasDefault
                  r←_default
              :Else
                  6 ⎕SIGNAL⍨'Value Error, don''t know: ',name
              :EndIf
          :EndIf
      :EndHold
    ∇

    ∇ {bool}←{remark}SetItem(name value);where
    ⍝ Alternative to the "[]←"-syntax. You can set only exactly one item _
    ⍝ with this method. Return 1 in case the item was new, otherwise 0.
      :Access Public
      'Specify single name/value pair only!'⎕SIGNAL(~IsChar name)/11
      'The KVP is locked ("freeze"←→1)'⎕SIGNAL _freeze/11
      remark←{(0<⎕NC ⍵):⍎⍵ ⋄ ''}'remark'
      :Hold uuidFlag/_UUID
          :If bool←(1⊃⍴_keys)≥where←(HandleCase _keys)⍳HandleCase⊂name
              (where⊃_data)←value
              (where⊃_remarks)←remark
          :Else
              'You may change existing keys, but you cannot add new ones: ("updateonly"←→1)'⎕SIGNAL updateOnly/11
              _keys,←⊂name
              _data,←⊂value
              _remarks,←⊂remark
          :EndIf
      :EndHold
    ∇

    ∇ {bool}←SetRemark(name value);where
    ⍝ This method offers the only way to set a remark.
    ⍝ Return 1 in case the item was new, otherwise 0.
    ⍝ Note that this method cannot be used to add new keys.
      :Access Public
      'Specify single name/value pair only!'⎕SIGNAL(~IsChar name)/11
      'The KVP is locked ("freeze"←→1)'⎕SIGNAL _freeze/11
      :Hold uuidFlag/_UUID
          :If bool←(1⊃⍴_keys)≥where←(HandleCase _keys)⍳HandleCase⊂name
              (where⊃_remarks)←value
          :Else
              'Key does not exist'⎕SIGNAL 11
          :EndIf
      :EndHold
    ∇

    ∇ r←GetData
    ⍝ Returns a vector with all the data.
    ⍝ Note that there is no particular sequence guaranteed.
      :Access Public
      :Hold uuidFlag/_UUID
          r←_data
      :EndHold
    ∇

    ∇ r←GetRemarks
    ⍝ Returns a vector with all remarks.
    ⍝ Note that there is no particular sequence guaranteed.
      :Access Public
      :Hold uuidFlag/_UUID
          r←_remarks
      :EndHold
    ∇

    ∇ r←GetKeys pattern
    ⍝ Returns a vector of text vectors with all keys.
    ⍝ Note that the <b>result</b> is <b>not</b> affected by the "case" parameter.
    ⍝ If pattern is not empty, only keys matching the pattern are returned
      :Access Public
      :Hold uuidFlag/_UUID
          :If 0∊⍴pattern
              r←_keys
          :Else
              r←(,HandleCase pattern){⍵/⍨⍺∧.=⍨(⍴⍺)↑[2]↑HandleCase ⍵}_keys
          :EndIf
      :EndHold
    ∇

    ∇ r←Length
    ⍝ Returns the number of elements (=number of keys)
      :Access Public
      :Hold uuidFlag/_UUID
          r←⍴,_keys
      :EndHold
    ∇

    ∇ r←FindInKeys what;buffer;Access;what2;bool
    ⍝ Find the string "what" in all keys.
      :Access Public Overridable
      :Hold uuidFlag/_UUID
          buffer←HandleCase _keys
          what2←HandleCase what
          bool←∨/¨(⊂what2)⍷¨buffer
          r←bool/_keys
      :EndHold
    ∇

    ∇ r←FindInData what;Access;bool;buffer;what2
    ⍝ Find the string "what" in the data BUT return keys.
    ⍝ Note that this search is ALWAYS case sensitive.
    ⍝ Note also that "ello" finds "Hello".
    ⍝ Data like icons or instances is simply ignored.
      :Access Public Overridable
      what←,what
      'Invalid search string'⎕SIGNAL 11/⍨(1≠≡what)∨~IsChar what
      :Hold uuidFlag/_UUID
          buffer←HandleCase _data
          what2←HandleCase what
          bool←what2∘{0::0 ⋄ ∨/⍺⍷⍵}¨buffer
          r←bool/_keys
      :EndHold
    ∇

    ∇ r←Sort collation
    ⍝ Sort the keys before returning (the internal key sequence remains unchanged).
    ⍝ "collation" might be empty. In this case a standard collation is used.
      :Access Public Overridable
      :Hold uuidFlag/_UUID
          :If 0∊⍴,collation
              collation←⎕UCS 0 8 10 13 32 12 6 7 27 9 9014 619 37 39 9082 9077 95 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113
              collation,←⎕UCS 114 115 116 117 118 119 120 121 122 1 2 175 46 9068 48 49 50 51 52 53 54 55 56 57 3 164 165 36 163 162 8710 65 66 67
              collation,←⎕UCS 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 4 5 253 183 127 9049 193 194 195 199 200 202 203
              collation,←⎕UCS 204 205 206 207 208 210 211 212 213 217 218 219 221 254 227 236 240 242 245 123 8364 125 8867 9015 168 192 196 197
              collation,←⎕UCS 198 9064 201 209 214 216 220 223 224 225 226 228 229 230 231 232 233 234 235 237 238 239 241 91 47 9023 92 9024 60
              collation,←⎕UCS 8804 61 8805 62 8800 8744 8743 45 43 247 215 63 8714 9076 126 8593 8595 9075 9675 42 8968 8970 8711 8728 40 8834 8835
              collation,←⎕UCS 8745 8746 8869 8868 124 59 44 9073 9074 9042 9035 9033 9021 8854 9055 9017 33 9045 9038 9067 9066 8801 8802 243 244
              collation,←⎕UCS 246 248 34 35 30 38 8217 9496 9488 9484 9492 9532 9472 9500 9508 9524 9516 9474 64 249 250 251 94 252 8216 8739 182
              collation,←⎕UCS 58 9079 191 161 8900 8592 8594 9053 41 93 31 160 167 9109 9054 9059
          :EndIf
          r←_keys[collation⍋↑HandleCase _keys]
      :EndHold
    ∇

    ∇ r←GetAsMatrix
    ⍝ Returns all key-value-pairs as a nested matrix.
      :Access Public
      :Hold uuidFlag/_UUID
          :If 0∊⍴_keys
              r←0 2⍴''
          :Else
              r←_keys,[1.5]_data
          :EndIf
      :EndHold
    ∇

    ∇ r←GetKeysAndRemarks
    ⍝ Returns all keys and their corresponding remarks as a nested matrix.
      :Access Public
      :Hold uuidFlag/_UUID
          :If 0∊⍴_keys
              r←0 2⍴''
          :Else
              r←_keys,[1.5]_remarks
          :EndIf
      :EndHold
    ∇

    ∇ r←GetAll
    ⍝ Returns keys, values and remarks as a nested matrix.
      :Access Public
      :Hold uuidFlag/_UUID
          :If 0∊⍴_keys
              r←0 3⍴''
          :Else
              r←_keys,_data,[1.5]_remarks
          :EndIf
      :EndHold
    ∇

    ∇ r←GetAsPairs
    ⍝ Returns the data (keys and data) as a vector where each item contains a key-value-pair
      :Access Public
      :Hold uuidFlag/_UUID
          :If 0∊⍴_keys
              r←''
          :Else
              r←↓_keys,[1.5]_data
          :EndIf
      :EndHold
    ∇

    ∇ {bool}←Delete names;where;ind
    ⍝ bool tells whether the "delete" was successful or not. _
    ⍝ Note that trying to delete a non-existing key is considered _
    ⍝ as unsuccessful.
      :Access Public
      :Hold uuidFlag/_UUID
          'The KVP is locked ("freeze"←→1)'⎕SIGNAL _freeze/11
          'You cannot add/delete keys ("updateOnly"←→1)'⎕SIGNAL _updateOnly/11
          bool←(⍴_keys)≥where←(HandleCase _keys)⍳HandleCase fixkeys names
          ind←(⍳⍴_keys)~where
          (_keys _data _remarks)←(⊂ind)∘⌷¨_keys _data _remarks
      :EndHold
    ∇

    ∇ bool←HasKeys names
    ⍝ Useful to check one or more names for being contained.
      :Access Public
      :Hold uuidFlag/_UUID
          bool←(HandleCase fixkeys names)∊HandleCase _keys
      :EndHold
    ∇

    ∇ keys←HasValue data
    ⍝ Useful to check a particular (single) value. All keys found are returned.
      :Access Public
      :Hold uuidFlag/_UUID
          keys←_keys/⍨_data≡¨⊂data
      :EndHold
    ∇

    ∇ {this}←Reset
    ⍝ Will destroy any data, but do not touch anything else (case, hasDefault).
    ⍝ Returnes a reference to the current instance
      :Access Public
      'The KVP is locked ("freeze"←→1)'⎕SIGNAL _freeze/11
      'You cannot reset the KVP ("updateOnly"←→1)'⎕SIGNAL _updateOnly/11
      this←⎕THIS
      :Hold uuidFlag/_UUID
          _keys←0/⊂''
          _data←0/⊂''
          _remarks←0/⊂''
      :EndHold
    ∇

    ∇ {this}←Merge array;newKeys;newData;bool;where;KVPRef;newRemarks
    ⍝ Merge the contents of "array" into the current KVP. Note that _
    ⍝ "array" can be either a vector of (name,value) pairs or another KVP. _
    ⍝ A single pair must be enclosed:
    ⍝ <pre>MyKVP.Merge (⊂'APL' 'is great')</pre>
    ⍝ Data of existing keys is overwritten, of course. _
    ⍝ If "array" is a KVP the "case" settings of both KVPs must match. _
    ⍝ Returnes a reference to the current instance.
      :Access Public
      'The KVP is locked ("freeze"←→1)'⎕SIGNAL _freeze/11
      :Hold uuidFlag/_UUID
          ⎕SHADOW'uuidFlag'
          uuidFlag←0
          :If (1≢≡array)∨(,0)≢⍴array ⍝ If it's empty nothing's gonna happen
              :If 2.1=⎕NC⊂'array' ⍝ is it a name/value-pair vector?
                  'Invalid right agument'⎕SIGNAL 11/⍨∨/~(⊃∘⍴¨array)∊2 3
                  newKeys←1⊃¨array
                  newData←2⊃¨array
                  :Select ∪⊃∘⍴¨array
                  :Case ,2
                      newRemarks←(⍴newData)⍴⊂''
                  :Case ,3
                      newRemarks←3⊃¨array
                  :Else
                      'Right argument: invalid length'⎕SIGNAL 11
                  :EndSelect
              :Else
                  this←⎕THIS
                  KVPRef←array
                  '"case" must be the same in both KVPs!'⎕SIGNAL 11/⍨case≢KVPRef.case
                  newKeys←KVPRef.GetKeys ⍬
                  newData←KVPRef.GetData
                  :If 3=⌊|KVPRef.⎕NC⊂'GetRemarks'
                      newRemarks←KVPRef.GetRemarks
                  :Else
                      newRemarks←(⍴newData)⍴⊂''
                  :EndIf
              :EndIf
              bool←(HandleCase newKeys)∊HandleCase _keys
              :If 0∊bool
                  'You cannot add keys ("freeze"←→1)'⎕SIGNAL _freeze/11
                  'You cannot add keys ("updateOnly"←→1)'⎕SIGNAL _updateOnly/11
              :EndIf
              :If 1∊bool
          ⍝ Perform changes
                  where←(HandleCase _keys)⍳HandleCase bool/newKeys
                  _data[where]←bool/newData
                  _remarks[where]←bool/newRemarks
              :EndIf
              bool←~bool
          ⍝ add new ones
              _keys,←bool/newKeys
              _data,←bool/newData
              _remarks,←bool/newRemarks
          :EndIf
      :EndHold
    ∇

⍝ --------- Private
    fixkeys←{(0 1)∊⍨≡⍵:,⊂⍵ ⋄ ⍵}
    HandleCase←{('ignore'≡_case):Lowercase ⍵ ⋄ ⍵}

:EndClass