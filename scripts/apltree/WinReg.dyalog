:Class WinReg
⍝ Offers shared methods useful to deal with the Windows Registry.
⍝ Note that the Window Registry contains data saved under a kind _
⍝ of "path". Such a path consists of:
⍝ * A so-called "Main Key" like HKEY_CURRENT_USER (or short HKCU)
⍝ * A so called sub key (which is displayed by RegEdt32 as a folder) _
⍝ like "HKEY_CURRENT_USER\Software\Dyalog\Dyalog APL/W 12.0"
⍝ * A so-called value like "maxws"
⍝ These terms might look strange but they are used by this class for _
⍝ the sake of consistency with the Microsoft documentation.
⍝ This class is also able to read and write default values of a _
⍝ sub-key. For that you have to add a "\" to the end of the sub-key.
⍝ Note that the class as such does not come with any limitations _
⍝ regarding the amount of data (REG_SZ, REG_MULTI, REG_EXPAND_SZ, _
⍝ REG_BINARY) you can write. However, Microsoft suggest not to save _
⍝ anything bigger than 2048 bytes (Unicode 4096?!) to avoid performance _
⍝ penalties. One should save larger amounts of data in a file and _
⍝ save the filename rather then the data in the Registry.
⍝ Note that this class supports only a limited number of data types ×
⍝ for writing:
⍝ * REG_SZ (Strings)
⍝ * REG_EXPAND_SZ (STRINGS where variables between % get expanded on read)
⍝ * REG_MULTI_SZ (Vectors of strings)
⍝ * REG_BINARY (Binary data)
⍝ * REG_DWORD (32-bit signed integer)
⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/WinReg
    ⎕ML←3
    ⎕IO←1

    :Include APLTreeUtils

    ∇ R←Version
      :Access Public Shared
      R←(Last⍕⎕THIS)'2.5.1' '2015-06-03'
      ⍝ 2.5.1  Wrong comment correected.
      ⍝ 2.5.0: APL inline code is now marked up with ticks.
      ⍝        `Version` now returns just the name, no path.
      ⍝        `History` removed.
    ∇

  ⍝ All data types, including those not supported yet
    :Field Public Shared ReadOnly REG_NONE←0                        ⍝ None
    :Field Public Shared ReadOnly REG_SZ←1                          ⍝ String
    :Field Public Shared ReadOnly REG_EXPAND_SZ←2                   ⍝ String, but somethign like "%WinDir%" is expanded
    :Field Public Shared ReadOnly REG_BINARY←3                      ⍝ Free form binary
    :Field Public Shared ReadOnly REG_DWORD←4                       ⍝ 32-bit number
    :Field Public Shared ReadOnly REG_DWORD_LITTLE_ENDIAN← 4        ⍝ 32-bit number (same as REG_DWORD)
    :Field Public Shared ReadOnly REG_DWORD_BIG_ENDIAN← 5           ⍝ 32-bit number
    :Field Public Shared ReadOnly REG_LINK←6                        ⍝ Symbolic Link (unicode)
    :Field Public Shared ReadOnly REG_MULTI_SZ←7                    ⍝ Multiple Unicode strings
    :Field Public Shared ReadOnly REG_RESOURCE_LIST←8               ⍝ Resource list in the resource map
    :Field Public Shared ReadOnly REG_FULL_RESOURCE_DESCRIPTOR←9    ⍝ Resource list in the hardware description
    :Field Public Shared ReadOnly REG_RESOURCE_REQUIREMENTS_LIST←10
    :Field Public Shared ReadOnly REG_QWORD←11                      ⍝ 64-bit number
    :Field Public Shared ReadOnly REG_QWORD_LITTLE_ENDIAN←11        ⍝ 64-bit number (same as REG_QWORD)
  ⍝ Error codes
    :Field Public Shared ReadOnly ERROR_SUCCESS←0                   ⍝ Return code for success
    :Field Public Shared ReadOnly ERROR_FILE_NOT_FOUND←2            ⍝ Registry path does not exist
    :Field Public Shared ReadOnly ERROR_PATH_NOT_FOUND←3            ⍝ Key not found
    :Field Public Shared ReadOnly ERROR_ACCESS_DENIED←5             ⍝ Requested permissions not available
    :Field Public Shared ReadOnly ERROR_INVALID_HANDLE←6            ⍝ Invalid handle or top-level key
    :Field Public Shared ReadOnly ERROR_NOT_ENOUGH_MEMORY←8         ⍝ Not enough memory
    :Field Public Shared ReadOnly ERROR_BAD_NETPATH←53              ⍝  Network path not found
    :Field Public Shared ReadOnly ERROR_INVALID_PARAMETER←87        ⍝ Bad parameter to a Win32 API function
    :Field Public Shared ReadOnly ERROR_CALL_NOT_IMPLEMENTED←120    ⍝ Function valid only in WinNT/2000?XP
    :Field Public Shared ReadOnly ERROR_INSUFFICIENT_BUFFER←122     ⍝ Buffer too small to hold data
    :Field Public Shared ReadOnly ERROR_BAD_PATHNAME←161            ⍝ Registry path does not exist
    :Field Public Shared ReadOnly ERROR_MORE_DATA←234               ⍝ Buffer was too small
    :Field Public Shared ReadOnly ERROR_NO_MORE_ITEMS←259           ⍝ Invalid enumerated value
    :Field Public Shared ReadOnly ERROR_BADDB←1009                  ⍝ Corrupted registry
    :Field Public Shared ReadOnly ERROR_BADKEY←1010                 ⍝ Invalid registry key
    :Field Public Shared ReadOnly ERROR_CANTOPEN←1011               ⍝ Cannot open registry key
    :Field Public Shared ReadOnly ERROR_CANTREAD←1012               ⍝ Cannot read from registry key
    :Field Public Shared ReadOnly ERROR_CANTWRITE←1013              ⍝ Cannot write to registry key
    :Field Public Shared ReadOnly ERROR_REGISTRY_RECOVERED←1014     ⍝ Recovery of part of registry successful
    :Field Public Shared ReadOnly ERROR_REGISTRY_CORRUPT←1015       ⍝ Corrupted registry
    :Field Public Shared ReadOnly ERROR_REGISTRY_IO_FAILED←1016     ⍝ Input/output operation failed
    :Field Public Shared ReadOnly ERROR_NOT_REGISTRY_FILE←1017      ⍝ Input file not in registry file format
    :Field Public Shared ReadOnly ERROR_KEY_DELETED←1018            ⍝ Key already deleted
    :Field Public Shared ReadOnly ERROR_KEY_HAS_CHILDREN←1020       ⍝ Key has subkeys & cannot be deleted
    :Field Public Shared ReadOnly ERROR_UNSUPPORTED_TYPE←1630       ⍝ Caution: this is sometimes returned when everything is just fine!
  ⍝ Defines the Access Rights constants
    :Field Public Shared ReadOnly KEY_READ←25
    :Field Public Shared ReadOnly KEY_ALL_ACCESS←983103
    :Field Public Shared ReadOnly KEY_KEY_WRITE←131078
    :Field Public Shared ReadOnly KEY_CREATE_LINK←32
    :Field Public Shared ReadOnly KEY_CREATE_SUB_KEY←4
    :Field Public Shared ReadOnly KEY_ENUMERATE_SUB_KEYS←8
    :Field Public Shared ReadOnly KEY_EXECUTE←131097
    :Field Public Shared ReadOnly KEY_NOTIFE←16
    :Field Public Shared ReadOnly KEY_QUERY_VALUE←1
    :Field Public Shared ReadOnly KEY_SET_VALUE←2
  ⍝ Other stuff
    :Field Public Shared ReadOnly NULL←⎕UCS 0

    ∇ r←{default}GetString y;multiByte;yIsHandle;handle;value;subKey;path;bufSize;∆RegQueryValueEx;rc;type;data;errMsg
      :Access Public Shared
    ⍝ Use this function in order to read a value of type REG_SZ or REG_EXPAND_SZ or REG_MULTI_SZ
    ⍝ y can be one of:
    ⍝ # A simple string which is supposed to be a full path then (sub-key plus value name).
    ⍝ # A vector of length 2 with a handle to the sub-key in [1] and a value name in [2].
      default←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'default'
      r←default
      multiByte←1+80=⎕DR'A' ⍝ 2 in Unicode System
      'WinReg error: invalid right argument'⎕SIGNAL 11/⍨(~0 1∊⍨≡y)∧2≠⍴,y
      'WinReg error: right argument must not be empty'⎕SIGNAL 11/⍨0∊⍴y
      'WinReg error: invalid right argument'⎕SIGNAL 11/⍨(~(⎕DR y)∊80 82)∧2≠⍴,y
      :If (2=⍴y)∧(0=1↑0⍴1⊃,y)∧(' '=1↑0⍴2⊃,y)
          yIsHandle←1
          (handle value)←y
      :ElseIf 1=≡y
          yIsHandle←0
          path←y
          (subKey value)←{⍵{((-⍵)↓⍺)((-⍵-1)↑⍺)}'\'⍳⍨⌽⍵}path
          subKey←CheckPath subKey
          :If '\'≠¯1↑path
          :AndIf ~DoesKeyExist subKey
              r←default
              :Return
          :EndIf
          handle←OpenKey subKey
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      :If 0=handle
          r←default
          :Return
      :EndIf
      value←((,'\')≢,value)/value        ⍝ For access to the default value
      '∆RegQueryValueEx'⎕NA'I ADVAPI32.dll.C32|RegQueryValueEx',AnsiOrWide,' U <0T I =I >0T =I4'
      bufSize←1024
      :Repeat
          (rc type data bufSize)←∆RegQueryValueEx handle value 0 REG_SZ,bufSize bufSize
          :If type=REG_MULTI_SZ ⋄ :Leave ⋄ :EndIf
      :Until rc≠ERROR_MORE_DATA
      :If type=REG_EXPAND_SZ
          data←ExpandEnv data
      :ElseIf type=REG_MULTI_SZ
          '∆RegQueryValueEx'⎕NA'I ADVAPI32.dll.C32|RegQueryValueEx',AnsiOrWide,' U <0T I =I >T[] =I4'
          :Repeat
              (rc type data bufSize)←∆RegQueryValueEx handle value 0 REG_SZ,bufSize bufSize
              :If type=REG_MULTI_SZ ⋄ :Leave ⋄ :EndIf
          :Until rc≠ERROR_MORE_DATA
          data←Partition(bufSize÷multiByte)↑data
      :EndIf
      errMsg←''
      :If rc=ERROR_FILE_NOT_FOUND
          r←default
      :ElseIf rc=0
          r←data
      :Else
          errMsg←'WinReg error: ',ConvertErrorCode rc
      :EndIf
      Close(~yIsHandle)/handle
      errMsg ⎕SIGNAL 11/⍨~0∊⍴errMsg
    ∇

    ∇ r←ListError
      :Access Public Shared
      ⍝ List all vars starting with "ERROR"
      r←List'ERROR_'
      r←r,[1.5]⍎¨r
    ∇

    ∇ r←ListReg
      :Access Public Shared
      ⍝ List all vars starting with "REG_"
      r←List'REG_'
      r←r,[1.5]⍎¨r
    ∇

    ∇ r←{default}GetValue y;yIsHandle;handle;value;subKey;∆RegQueryValueEx;type;rc;errMsg;bufSize;length;data
      :Access Public Shared
    ⍝ y can be either a vector of length one or two:
    ⍝ If length 1:
    ⍝   [1] path (subkey + value name)
    ⍝ If length 2:
    ⍝   [1] handle to the sub key
    ⍝   [2] value name
    ⍝ Returns the data saved as "path" in the Registry, or "Default". The data type is _
    ⍝ determined from the Registry.
      default←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'default'
      r←default
      yIsHandle←0
      'WinReg error: invalid right argument'⎕SIGNAL 11/⍨(~0 1∊⍨≡y)∧2≠⍴,y
      'WinReg error: right argument must not be empty'⎕SIGNAL 11/⍨0∊⍴y
      'WinReg error: invalid right argument'⎕SIGNAL 11/⍨(~(⎕DR y)∊80 82)∧2≠⍴,y
      :If 2=⍴,y
      :AndIf yIsHandle←0=1↑0⍴1⊃y          ⍝ Is the first item possibly a handle?
          (handle value)←y
      :Else
          (subKey value)←SplitPath y
          :If ~DoesKeyExist subKey ⋄ :Return ⋄ :EndIf
          handle←OpenKey subKey
      :EndIf
      '∆RegQueryValueEx'⎕NA'I ADVAPI32.dll.C32|RegQueryValueEx',AnsiOrWide,' U <0T I >I >I4 =I4'
      :If (,'\')≡,value
          value←''       ⍝ Default value has no value name
      :EndIf
      (rc type)←2↑∆RegQueryValueEx handle value 0 0 0 0
      :If rc=ERROR_FILE_NOT_FOUND
          r←default
          :Return
      :ElseIf ~rc∊ERROR_SUCCESS,ERROR_MORE_DATA,ERROR_UNSUPPORTED_TYPE  ⍝ Yes, I know - but this sometimes happens although everything is fine!!
          errMsg←'Error, rc=',⍕rc
      :EndIf
      errMsg←''
      bufSize←1024
      :Select type
      :Case REG_BINARY
          '∆RegQueryValueEx'⎕NA'I ADVAPI32.dll.C32|RegQueryValueEx',AnsiOrWide,' U <0T I >I4 >I1[] =I4 '
      :Case REG_DWORD
          '∆RegQueryValueEx'⎕NA'I ADVAPI32.dll.C32|RegQueryValueEx',AnsiOrWide,' U <0T I >I4 >I4 =I4'
      :CaseList REG_SZ,REG_EXPAND_SZ,REG_MULTI_SZ
          '∆RegQueryValueEx'⎕NA'I ADVAPI32.dll.C32|RegQueryValueEx',AnsiOrWide,' U <0T I =I >T[] =I4'
      :Else
          ('WinReg error: unsupported data type: ',GetTypeAsString type)⎕SIGNAL 11
      :EndSelect
      :Repeat
          (rc type data length)←∆RegQueryValueEx handle value 0 bufSize bufSize bufSize
          bufSize+←1024
      :Until (ERROR_MORE_DATA≠rc)
      errMsg←''
      :If rc=ERROR_FILE_NOT_FOUND
          r←default
      :ElseIf ~rc∊ERROR_SUCCESS,ERROR_UNSUPPORTED_TYPE  ⍝ Yes, I know - but this sometimes happens although everything is fine!!
          errMsg←'WinReg error: ',ConvertErrorCode rc
      :Else
          r←HandleDataType type length data
      :EndIf
      Close(~yIsHandle)/handle
      errMsg ⎕SIGNAL 11/⍨~0∊⍴errMsg
    ∇

    ∇ {r}←{type}PutString y;yIsHandle;path;data;value;subKey;handle;multiByte;rc
      :Access Public Shared
    ⍝ y can be either a vector of length two or three:
    ⍝ If length 2:
    ⍝   [1] path (subkey + value name)
    ⍝   [2] data to be saved
    ⍝ If length 3:
    ⍝   [1] handle to the sub key
    ⍝   [2] value name
    ⍝   [3] data to be saved
    ⍝ Stores "data" under `¯1↓y`. If "path" ends with a "\" char, "data" _
    ⍝ is saved as the default value of "path"; data type is always "REG_SZ" then.
    ⍝ Note that type defaults to "REG_SZ" except when "data" is nested, then _
    ⍝ the default is "REG_MULTI_SZ.
    ⍝ You can set "type" to one of: REG_SZ, REG_EXPAND_SZ, REG_MULTI_SZ.
      :Select ↑⍴,y
      :Case 2
          yIsHandle←0
          (path data)←y
          (subKey value)←{⍵{((-⍵)↓⍺)((-⍵-1)↑⍺)}'\'⍳⍨⌽⍵}path
          subKey←CheckPath subKey
          handle←OpenAndCreateKey subKey
      :Case 3
          yIsHandle←1
          (handle value data)←y
          'WinReg error: invalid right argument'⎕SIGNAL 11/⍨0≠1↑0⍴handle
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndSelect
      data←,data
      multiByte←1+80=⎕DR'A' ⍝ 2 in Unicode System
      'WinReg error: invalid "value"'⎕SIGNAL 11/⍨' '≠1↑0⍴value
      type←data{2=⎕NC ⍵:⍎⍵ ⋄ (1+0 1∊⍨≡⍺)⊃REG_MULTI_SZ REG_SZ}'type'
      :If type=REG_MULTI_SZ
          'WinReg error: invalid "data"'⎕SIGNAL 11/⍨0∊{↑' '=1↑0⍴⍵}¨data
      :Else
          'WinReg error: invalid "data"'⎕SIGNAL 11/⍨' '≠1↑0⍴data
      :EndIf
      :If type=REG_MULTI_SZ
          data←{0 1∊⍨≡⍵:⍵ ⋄ 0∊⍴⍵:'' ⋄ (↑,/⍵,¨NULL),NULL}data
      :Else
          data←data,{NULL=⍵:'' ⋄ NULL}¯1↑data
      :EndIf
      'WinReg error: invalid data type - must be one of REG_SZ,REG_MULTI_SZ,REG_EXPAND_SZ'⎕SIGNAL 11/⍨~type∊REG_SZ,REG_MULTI_SZ,REG_EXPAND_SZ
      '∆RegSetValueEx'⎕NA'I ADVAPI32.dll.C32|RegSetValueEx',AnsiOrWide,' I <0T I I <T[] I'
      :If yIsHandle
      :AndIf (,'\')≡,value
          rc←∆RegSetValueEx handle'' 0 type data(multiByte×↑⍴data)
      :Else
          rc←∆RegSetValueEx handle value 0 type data(multiByte×↑⍴data)
      :EndIf
      ('WinReg error! ',ConvertErrorCode rc)⎕SIGNAL 11/⍨ERROR_SUCCESS≠rc
      Close(~yIsHandle)/handle
      r←⍬
    ∇

    ∇ {r}←PutValue y;yIsHandle;data;path;subKey;value;handle;multiByte;∆RegSetValueEx
      :Access Public Shared
    ⍝ Stores "data" under "path". Note that you cannot save a default value _
    ⍝ with "PutValue" (=path ends with a backslash) because default values _
    ⍝ MUST be of type REG_SZ. Therefore use "PutString" in order to set a _
    ⍝ default value. If path ends with a backslash, an exception is thrown.
    ⍝ Note that you can only save REG_DWORDs with PutVales, that is 32-bit _
    ⍝ integers.
      :Select ↑⍴,y
      :Case 2
          yIsHandle←0
          (path data)←y
          'WinReg error: default values must be of type REG_SZ (string)'⎕SIGNAL 11/⍨'\'=¯1↑path
          (subKey value)←SplitPath path
          subKey←CheckPath subKey
          handle←OpenAndCreateKey subKey
      :Case 3
          yIsHandle←1
          (handle value data)←y
          'WinReg error: invalid right argument'⎕SIGNAL 11/⍨0≠1↑0⍴handle
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndSelect
      data←,data
     ⍝ multiByte←1+80=⎕DR'A' ⍝ 2 in Unicode System
      '∆RegSetValueEx'⎕NA'I ADVAPI32.dll.C32|RegSetValueEx',AnsiOrWide,' I <0T I I <I4 I'
      :If (1≠≡data)∨1≠⍴data←,data
          Close(~yIsHandle)/handle
          'WinReg error: data has invalid depth/shape'⎕SIGNAL 11
      :EndIf
      :If data>2147483647
          Close(~yIsHandle)/handle
          'WinReg error: data too large; max is 2,147,483,647'⎕SIGNAL 11
      :EndIf
      :If data<¯2147483647
          Close(~yIsHandle)/handle
          'WinReg error: data too small; min is -2,147,483,647'⎕SIGNAL 11
      :EndIf
      _←∆RegSetValueEx handle value 0 REG_DWORD data 4
      Close(~yIsHandle)/handle
      r←⍬
    ∇

    ∇ {r}←PutBinary y;yIsHandle;path;data;value;subKey;handle;multiByte;∆RegSetValueEx
      :Access Public Shared
    ⍝ Stores binary "data".
    ⍝ y may be one of:
    ⍝ # A vector of length 2 with the full path (sub-key + value name) in _
    ⍝   the first item and the data in the second item.
    ⍝ # A vector of length 3 with a handle in [1], the value name in [2] _
    ⍝   and the data in [3].
    ⍝ Note that you cannot save a default _
    ⍝ value with "PutBinary" (=path ends with a backslash) because default _
    ⍝ values MUST be of type REG_SZ. Therefore use "PutString" in order to _
    ⍝ set a default value. If path ends with a backslash, an exception is thrown.
    ⍝ Note that for binary you must specify Integer (¯128 to 128).
      :Select ↑⍴,y
      :Case 2
          yIsHandle←0
          (path data)←y
          'WinReg error: default values must be of type REG_SZ (string)'⎕SIGNAL 11/⍨'\'=¯1↑path
          (subKey value)←SplitPath path
          subKey←CheckPath subKey
          handle←OpenAndCreateKey subKey
      :Case 3
          yIsHandle←1
          (handle value data)←y
          'WinReg error: default values must be of type REG_SZ (string)'⎕SIGNAL 11/⍨(,'\')≡,value
          'WinReg error: invalid right argument'⎕SIGNAL 11/⍨0≠1↑0⍴handle
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndSelect
      data←,data
      'WinReg error: invalid data for "Binary"'⎕SIGNAL 11/⍨∨/~data∊¯129+⍳256
      '∆RegSetValueEx'⎕NA'I ADVAPI32.dll.C32|RegSetValueEx',AnsiOrWide,' I <0T I I <I1[] I'
      _←∆RegSetValueEx handle value 0 REG_BINARY data(↑⍴data)
      Close(~yIsHandle)/handle
      r←⍬
    ∇

    ∇ r←KeyInfo y;yIsHandle;handle;∆RegQueryInfoKey;buffer;rc;noofValues;noofSubKeys;maxNameLength;maxValueLength
    ⍝ Returns a vector with information about the Key (not Value!) in question
    ⍝ # No. of values
    ⍝ # No. of subkeys
    ⍝ # Largest length of all value names (without \n)
    ⍝ # Largest length of value data (without \n)
    ⍝ y can be one of:
    ⍝ # A handle
    ⍝ # A path (sub key)
      :Access Public Shared
      :If (0=1↑0⍴y)∧1=⍴,y       ⍝ Is it a handle?
          yIsHandle←1
          handle←y
      :ElseIf (' '=1↑0⍴y)∧1=≡y  ⍝ Is it a path
          handle←OpenKey y
          yIsHandle←0
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      '∆RegQueryInfoKey'⎕NA'I ADVAPI32|RegQueryInfoKey',AnsiOrWide,' I >T[] =I I >I >I >I >I >I >I >I >{U U}'
      buffer←∆RegQueryInfoKey handle 0 0 0 1 1 1 1 0 0 0 0
      rc←1⊃buffer
      :If 0=rc
          noofValues←7⊃buffer
          noofSubKeys←4⊃buffer
          maxNameLength←8⊃buffer
          maxValueLength←9⊃buffer
          r←noofValues noofSubKeys maxNameLength maxValueLength
      :Else
          Close(~yIsHandle)/handle
          ('WinReg error: ',ConvertErrorCode rc)⎕SIGNAL 11
      :EndIf
      Close(~yIsHandle)/handle
    ∇

    ∇ r←GetAllValues y
      :Access Public Shared
      ⍝ DEPRECATED
      ⍝ This was a misnomer from the start.
      ⍝ Expect this method to disappear in the next major release.
      r←GetAllNamesAndValues y
    ∇

    ∇ r←GetAllNamesAndValues y;names;handle;noof;i;yIsHandle
    ⍝ This method gets all values for a given subkey
    ⍝ r is a matrix with:
    ⍝ [;1] Value name
    ⍝ [;2] The data
    ⍝ y can be one of:
    ⍝ # A string representing a path (sub key)
    ⍝ # A handle
      :Access Public Shared
      :If (0=1↑0⍴y)∧1=⍴,y       ⍝ Is it a handle?
          yIsHandle←1
          handle←y
      :ElseIf (' '=1↑0⍴y)∧1=≡y  ⍝ Is it a path
          handle←OpenKey y
          yIsHandle←0
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      :If 0=handle
          r←0 2⍴⍬
          :Return
      :EndIf
      noof←⍴names←GetAllValueNames handle
      r←(noof,2)⍴⍬
      :If ~0∊⍴r
          r[;1]←names
          :For i :In ⍳⍴names
              r[i;2]←⊂GetValue handle(i⊃names)
          :EndFor
      :EndIf
      Close(~yIsHandle)/handle
    ∇

    ∇ r←{verbose}GetAllValueNames y;yIsHandle;handle;noofValues;noofSubkeys;For;∆RegEnumValue;i;rc;data;length;type;keyLength;dataLength
    ⍝ This method gets all value names for a given subkey.
    ⍝ r is a vector with value names or, if the left argument is the string _
    ⍝ "verbose" (default is `''`), a matrix with 2 columns:
    ⍝ [;1] names
    ⍝ [;2] data types
    ⍝ y can be one of:
    ⍝ # A string which is treated as a path (sub key)
    ⍝ # An integer which is treated as a handle
    ⍝ Note that for a default value a "\" is returned as value name.
      :Access Public Shared
      verbose←{2=⎕NC ⍵:'verbose'≡⍎⍵ ⋄ 0}'verbose'
      :If (0=1↑0⍴y)∧1=⍴,y       ⍝ Is it a handle?
          yIsHandle←1
          handle←y
      :ElseIf (' '=1↑0⍴y)∧1=≡y  ⍝ Is it a path
          handle←OpenKey y
          'Could not access Windows Registry key'⎕SIGNAL 11/⍨0=handle
          yIsHandle←0
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      '∆RegEnumValue'⎕NA'I ADVAPI32|RegEnumValue',AnsiOrWide,' I I >T[] =I I >I >T[] =I'
      (noofValues noofSubkeys keyLength dataLength)←4↑KeyInfo handle  ⍝ No. of values, no. of SubKeys, max name length, data length
      r←(noofValues,2)⍴' '
      :For i :In (⍳noofValues)-1
          (rc data length type)←4↑∆RegEnumValue handle,i,(keyLength+1),(keyLength+1),0 1,(dataLength+1),(dataLength+1)
          :If rc∊ERROR_SUCCESS,ERROR_MORE_DATA
              :If 0=length      ⍝ Then it is the default value
                  r[i+1;]←'\'
              :Else
                  r[i+1;]←(⊃↑/length data)type
              :EndIf
          :Else
              Close(~yIsHandle)/handle
              ('WinReg error! ',ConvertErrorCode rc)⎕SIGNAL 11
          :EndIf
      :EndFor
      Close(~yIsHandle)/handle
      :If ~verbose
          r←r[;1]
      :EndIf
    ∇

    ∇ r←GetAllSubKeyNames y;yIsHandle;handle;∆RegEnumKey;flag;rc;i;bufSize;name;length
    ⍝ This method returns a vector of strings with the namesof all sub keys for a given key.
      :Access Public Shared
      :If (0=1↑0⍴y)∧1=⍴,y       ⍝ Is it a handle?
          yIsHandle←1
          handle←y
      :ElseIf (' '=1↑0⍴y)∧1=≡y  ⍝ Is it a path
          handle←OpenKey y
          yIsHandle←0
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      '∆RegEnumKey'⎕NA'I ADVAPI32|RegEnumKeyEx',AnsiOrWide,' I4 I4 >T[] =P P P P P'
      flag←i←0
      bufSize←1024×1+80=⎕DR''
      r←''
      :Repeat
          (rc name length)←∆RegEnumKey handle,i,bufSize,bufSize,0 0 0 0
          :If rc=ERROR_SUCCESS
              r,←⊂length↑name
              i+←1
          :ElseIf rc=ERROR_NO_MORE_ITEMS
              flag←1
              Close(~yIsHandle)/handle
          :ElseIf rc=ERROR_INVALID_HANDLE
              r←''
              flag←1
          :Else
              Close(~yIsHandle)/handle
              ('WinReg error! ',ConvertErrorCode rc)⎕SIGNAL 11
          :EndIf
      :Until flag
      Close(~yIsHandle)/handle
    ∇

    ∇ r←{depth}GetTree key;handle;depth;allValues;AllSubKeys;thisSubKey;buffer;allSubKeys
    ⍝ Takes the name of a key (but no handle!) and returns a (possibly empty) matrix with:
    ⍝ [;1] depth
    ⍝ [;2] fully qualified name
    ⍝ Note that sub-keys end with a backslash.
    ⍝ See "GetTreeWithValues" if you need the data of the values, too.
      :Access Public Shared
      depth←{0=⎕NC ⍵:0 ⋄ ⍎⍵}'depth'
      :If (0=1↑0⍴key)∧1=⍴,key                   ⍝ Is it a valid handle?
          11 ⎕SIGNAL⍨'WinReg error: right argument is not a key name'
      :ElseIf (' '=1↑0⍴key)∧1=≡key              ⍝ Is it a path?
          handle←OpenKey key
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      :If handle=0
          11 ⎕SIGNAL⍨'WinReg error: key does not exist'
      :Else
          r←1 2⍴depth(key,('\'≠¯1↑key)/'\')
          :If ~0∊⍴allValues←GetAllValueNames handle
              r⍪←(1+depth),[1.5](⊂key,('\'≠¯1↑key)/'\'),¨allValues
          :EndIf
          :If ~0∊⍴allSubKeys←GetAllSubKeyNames key
              :For thisSubKey :In allSubKeys
                  :If ~0∊⍴buffer←(depth+1)GetTree key,(('\'≠¯1↑key)/'\'),thisSubKey
                      r⍪←buffer
                  :EndIf
              :EndFor
          :EndIf
          Close handle
      :EndIf
    ∇

    ∇ r←{depth}GetTreeWithValues key;handle;depth;allValues;AllSubKeys;thisSubKey;buffer;allSubKeys
    ⍝ Takes the name of a key (but no handle!) and returns a (possibly empty) matrix with:
    ⍝ [;1] depth
    ⍝ [;2] fully qualified name
    ⍝ [;3] value data (empty for sub-keys)
    ⍝ Note that sub-keys end with a backslash.
    ⍝ See "GetTree" if you don't need the data of the values.
      :Access Public Shared
      depth←{0=⎕NC ⍵:0 ⋄ ⍎⍵}'depth'
      :If (0=1↑0⍴key)∧1=⍴,key                   ⍝ Is it a valid handle?
          11/⍨⎕SIGNAL'WinReg error: invalid right argument'
      :ElseIf (' '=1↑0⍴key)∧1=≡key              ⍝ Is it a path?
          handle←OpenKey key
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      :If handle=0
          11 ⎕SIGNAL⍨'WinReg error: key does not exist'
      :Else
          r←1 3⍴depth(key,('\'≠¯1↑key)/'\')''
          :If ~0∊⍴allValues←GetAllNamesAndValues handle
              allValues[;1]←(⊂key,('\'≠¯1↑key)/'\'),¨allValues[;1]
              r⍪←(1+depth),allValues
          :EndIf
          :If ~0∊⍴allSubKeys←GetAllSubKeyNames key
              :For thisSubKey :In allSubKeys
                  :If ~0∊⍴buffer←(depth+1)GetTreeWithValues key,(('\'≠¯1↑key)/'\'),thisSubKey
                      r⍪←buffer
                  :EndIf
              :EndFor
          :EndIf
          Close handle
      :EndIf
    ∇

    ∇ {r}←CopyTree(source destination);sourceHandle;destinationHandle;wv;sourceIsHandle;destinationIsHandle;∆RegCopyTree
      :Access Public Shared
     ⍝ Use this to copy a Registry Key from "source" to "destination".
     ⍝ Note that this method needs at least Vista.
     ⍝ Both, "source" as well as "destination" can be one of:
     ⍝ # A path (sub key)
     ⍝ # A handle
      :If (0=1↑0⍴source)∧1=⍴,source       ⍝ Is it a handle?
          sourceIsHandle←1
          sourceHandle←source
      :ElseIf (' '=1↑0⍴source)∧1=≡source  ⍝ Is it a path
          sourceHandle←OpenKey source
          sourceIsHandle←0
      :Else
          'WinReg error: invalid right argument ("source")'⎕SIGNAL 11
      :EndIf
      :If (0=1↑0⍴destination)∧1=⍴,destination       ⍝ Is it a handle?
          destinationIsHandle←1
          destinationHandle←destination
      :ElseIf (' '=1↑0⍴destination)∧1=≡destination  ⍝ Is it a path
          destinationHandle←OpenAndCreateKey destination
          destinationIsHandle←0
      :Else
          'WinReg error: invalid right argument ("source")'⎕SIGNAL 11
      :EndIf
      :If ~destinationIsHandle
          'WinReg error: destination must not be a Registry value'⎕SIGNAL 11/⍨0≠#.WinReg.DoesValueExist destination
      :EndIf
      wv←GetVersion                 ⍝ Get the Windows version
      'WinReg error: "CopyTree" is not supported in this version of Windows'⎕SIGNAL 11/⍨6>1⊃wv
      'WinReg error: recursive copy failed'⎕SIGNAL 11/⍨source≡(⍴source)↑destination
      '∆RegCopyTree'⎕NA'I ADVAPI32.dll.C32|RegCopyTree',AnsiOrWide,' U <0T[] U'
      r←∆RegCopyTree sourceHandle''destinationHandle
      Close(~sourceIsHandle)/sourceHandle
      Close(~destinationIsHandle)/destinationHandle
    ∇

    ∇ {r}←DeleteSubKey y;handle;HKEY;subKey;∆RegDeleteKey;wv;yIsHandle;path
      :Access Public Shared
     ⍝ Deletes a subkey "path", even if this subkeys holds values.
     ⍝ The subkey to be deleted must not have subkeys. (You can achieve _
     ⍝ this with the "DeleteSubKeyTree" function, see there)
     ⍝ y can be one of:
     ⍝ # A string which is treated as a path (sub key)
     ⍝ # An integer which is treated as a handle
     ⍝ Note that for a default value a "\" is returned as value name.
      :Access Public Shared
      :If (0=1↑0⍴y)∧1=⍴,y       ⍝ Is it a handle?
          handle←y
          subKey←''
          yIsHandle←1
      :ElseIf (' '=1↑0⍴y)∧1=≡y  ⍝ Is it a path
          y←CheckPath y
          (path subKey)←SplitPath y
          handle←OpenKey path
          yIsHandle←0
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      :If 0=handle ⋄ r←0 ⋄ :Return ⋄ :EndIf  ⍝ handle is 0? Nothing to delete then.
      wv←GetVersion                 ⍝ Get the Windows version
      'WinReg error: "DeleteSubKey" is not supported in this version of Windows'⎕SIGNAL 11/⍨6>1⊃wv
      '∆RegDeleteKey'⎕NA'I ADVAPI32.dll.C32|RegDeleteKey',AnsiOrWide,' U <0T[]'
      r←∆RegDeleteKey handle subKey
      Close(~yIsHandle)/handle
    ∇

    ∇ {r}←DeleteSubKeyTree y;handle;∆RegDeleteTree;yIsHandle;subKey;path
      :Access Public Shared
     ⍝ Deletes a subkey "path", even if this subkeys holds values.
     ⍝ Any subkeys in "path" will be deleted as well.
     ⍝ Note that this methods needs at least Vista.
     ⍝ y can be one of:
     ⍝ # A path (sub key)
     ⍝ # A handle to a sub key
      'WinReg error: right argument must not be empty'⎕SIGNAL 11/⍨0∊⍴y
      :If 1≠≡y
      :AndIf (0=1↑0⍴1⊃,y)∧1=⍴,1⊃,y       ⍝ Is it a handle?
          yIsHandle←1
          handle←y
          subKey←''
      :ElseIf (' '=1↑0⍴y)∧1=≡y           ⍝ Is it a path?
          y←CheckPath y
          (path subKey)←SplitPath{⍵↓⍨-'\'=¯1↑⍵}y
          handle←OpenKey path
          yIsHandle←0
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      '∆RegDeleteTree'⎕NA'I ADVAPI32.dll.C32|RegDeleteTree',AnsiOrWide,' U <0T[]'
      r←∆RegDeleteTree handle subKey
      Close(~yIsHandle)/handle
    ∇

    ∇ {r}←DeleteValue y;path;RegDeleteValueA;handle;∆RegDeleteValue;value;subKey;yIsHandle
      :Access Public Shared
     ⍝ Delete a value from the Windows Registry.
     ⍝ y can be one of:
     ⍝ [1] A full path (sub key + value name)
     ⍝ [2] A vector of length 2 with a handle in [1] and a value name in [2]
     ⍝ This method normally returns either ERROR_SUCCESS or ERROR_FILE_NOT_FOUND ×
     ⍝ in case the value did not exist from the start.
      :If 1≠≡y
      :AndIf (0=1↑0⍴1⊃,y)∧1=⍴,1⊃,y       ⍝ Is it a handle?
          yIsHandle←1
          (handle value)←y
      :ElseIf (' '=1↑0⍴y)∧1=≡y  ⍝ Is it a path
          (subKey value)←SplitPath y
          subKey←CheckPath subKey
          handle←OpenKey subKey
          yIsHandle←0
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      '∆RegDeleteValue'⎕NA'I ADVAPI32.dll.C32|RegDeleteValue',AnsiOrWide,' U <0T[]'
      r←∆RegDeleteValue handle value
      Close(~yIsHandle)/handle
    ∇

    ∇ bool←DoesKeyExist path;handle
      :Access Public Shared
    ⍝ Checks if a given Registry key exists
    ⍝ Note that you cannot pass a handle as right argument because _
    ⍝ that makes no sense: if there is a handle the sub key MUST exist.
      'WinReg error: right argument must not be empty'⎕SIGNAL 11/⍨0∊⍴path
      handle←OpenKey path
      bool←handle≠0
      Close handle
    ∇

    ∇ r←GetTypeAsStringFrom value;l;values;mask
    ⍝ Use this to convert a value like 3 to REG_BINARY or 'REG_BINARY' _
    ⍝ into 3. Specify an empty argument to get a matrix with all possible _
    ⍝ names and their values.
      :Access Public Shared
      'WinReg error: invalid right argument'⎕SIGNAL 11/⍨~0 1∊⍨≡value
      l←GetAllTypes ⍬            ⍝ Get list with all REG fields
      r←l GetAsString value
    ∇

    ∇ r←GetErrorAsStringFrom value;l;values;mask
    ⍝ Use this to convert a value like 8 to "ERROR_NOT_ENOUGH_MEMORY".
    ⍝ Specify an empty argument to get a matrix with all possible _
    ⍝ names and their values.
      :Access Public Shared
      'WinReg error: invalid right argument'⎕SIGNAL 11/⍨~0 1∊⍨≡value
      l←GetAll'ERROR'               ⍝ Get list with all errors
      r←l GetAsString value
    ∇

    ∇ bool←DoesValueExist y;names;yIsHandle;value;handle;subKey
      :Access Public Shared
    ⍝ Checks if a value exists in the Registry.
    ⍝ y can be one of:
    ⍝ # Path (sub key)
    ⍝ # A handle to a sub key
      :If 1≠≡y
      :AndIf (0=1↑0⍴1⊃,y)∧1=⍴,1⊃,y       ⍝ Is it a handle?
          yIsHandle←1
          (handle value)←y
      :ElseIf (' '=1↑0⍴y)∧1=≡y  ⍝ Is it a path
          (subKey value)←SplitPath y
          subKey←CheckPath subKey
          handle←OpenKey subKey
          yIsHandle←0
      :Else
          'WinReg error: invalid right argument'⎕SIGNAL 11
      :EndIf
      :If 0=handle ⍝ Then the sub key does not exist, let alone the value
          bool←0
      :Else
          names←GetAllValueNames handle
          bool←(⊂Lowercase value)∊Lowercase names
          Close(~yIsHandle)/handle
      :EndIf
    ∇

    ∇ {r}←Close handle;RegCloseKey;_
      :Access Public Shared
      r←⍬
      :If ~0∊⍴handle
          ⎕NA'U ADVAPI32.dll.C32|RegCloseKey U'
          _←RegCloseKey¨handle
      :EndIf
    ∇

    ∇ handle←{accessRights}OpenKey path;HKEY;subKey;∆RegCreateKeyEx;rc
    ⍝ Opens a key. This will fail if the key does not already exist.
    ⍝ See also: OpenKeyAndCreate
    ⍝ The optional left argument defaults to KEY_ALL_ACCESS which includes "Create"). _
    ⍝ Instead you can specify KEY_READ in case of lacking the rights to create anything.
      :Access Public Shared
      accessRights←{2=⎕NC ⍵:⍎⍵ ⋄ KEY_ALL_ACCESS}'accessRights'
      path←CheckPath path
      :If 'HKEY_'≡5↑path
          (HKEY subKey)←{a←⍵⍳'\' ⋄ ((a-1)↑⍵)(a↓⍵)}path
          HKEY←Get_HKEY_From HKEY
      :Else
          HKEY←Get_HKEY_From'HKEY_CURRENT_USER'  ⍝ Default
      :EndIf
      '∆RegCreateKeyEx'⎕NA'I ADVAPI32.dll.C32|RegOpenKeyEx',AnsiOrWide,' U <0T I I >I'
      (rc handle)←∆RegCreateKeyEx HKEY subKey 0 accessRights 1
      ('WinReg error: opening Registry key failed with ',ConvertErrorCode rc)⎕SIGNAL 11/⍨~rc∊ERROR_SUCCESS,ERROR_FILE_NOT_FOUND
    ∇

    ∇ handle←OpenAndCreateKey path;HKEY;subKey;∆RegCreateKeyEx;rc;newFlag
    ⍝ Opens a key. If the key does not already exist it is going to be created.
    ⍝ See also: OpenKey
    ⍝ Note that this method needs KEY_ALL_ACCESS otherwise it cannot work properly.
      :Access Public Shared
      path←CheckPath path
      :If 'HKEY_'≡5↑path
          (HKEY subKey)←{a←⍵⍳'\' ⋄ ((a-1)↑⍵)(a↓⍵)}path
          HKEY←Get_HKEY_From HKEY
      :Else
          HKEY←Get_HKEY_From'HKEY_CURRENT_USER'  ⍝ Default
      :EndIf
      '∆RegCreateKeyEx'⎕NA'I ADVAPI32.dll.C32|RegCreateKeyEx',AnsiOrWide,' U <0T I <0T I I I >U >U'
      (rc handle newFlag)←∆RegCreateKeyEx HKEY subKey 0 '' 0 KEY_ALL_ACCESS 0 1 1
      ('WinReg error: opening/creating Registry key failed with ',ConvertErrorCode rc)⎕SIGNAL 11/⍨ERROR_SUCCESS≠rc
    ∇

    ∇ r←GetDyalogRegPath aplVersion;v
    ⍝ Returns the full Registry key for `aplVersion` which defaults to '#'⎕WG'APLVersion' when empty.
      :Access Public Shared
      r←'HKEY_CURRENT_USER\Software\Dyalog\Dyalog APL/W'
      v←{0∊⍴⍵:'#'⎕WG'APLVersion' ⋄ ⍵}aplVersion
      r,←(0<+/'-64'⍷↑v)/'-64'
      r,←' ',⊃{⍺,'.',⍵}/2↑'.'Split 2⊃v
      r,←(80=⎕DR' ')/' Unicode'
     ⍝Done
    ∇

    ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝ Private stuff ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝,
    ∇ HKEY←Get_HKEY_From Type
      Type←{0∊⍴⍵:'HKEY_CURRENT_USER' ⋄ ⍵}Type
      :If ' '=1↑0⍴Type
          :Select Type
          :Case 'HKEY_CLASSES_ROOT'
              HKEY←2147483648             ⍝ HEX 0x80000000
          :Case 'HKEY_CURRENT_USER'
              HKEY←2147483649             ⍝ HEX 0x80000001
          :Case 'HKEY_LOCAL_MACHINE'
              HKEY←2147483650             ⍝ HEX 0x80000002
          :Case 'HKEY_USERS'
              HKEY←2147483651             ⍝ HEX 0x80000003
          :Case 'HKEY_PERFORMANCE_DATA'
              HKEY←2147483652             ⍝ HEX 0x80000004
          :Case 'HKEY_CURRENT_CONFIG'
              HKEY←2147483653             ⍝ HEX 0x80000050
          :Case 'HKEY_DYN_DATA'
              HKEY←2147483654             ⍝ HEX 0x80000060
          :Else
              'WinReg error: invalid Keyword'⎕SIGNAL 11
          :EndSelect
      :Else
          HKEY←Type
      :EndIf
    ∇

    ∇ path←CheckPath path;buffer;path2;HKEY
   ⍝ Check the path, replace shortcuts by proper names and establish default if needed
      :If 'HK'≡2↑path
          (HKEY path2)←{⍵{((¯1+⍵)↑⍺)(⍵↓⍺)}⍵⍳'\'}path
          :If 'HKEY_'{⍺≢⍵↑⍨⍴⍺}HKEY
              :Select HKEY
              :Case 'HKCU'
                  path←'HKEY_CURRENT_USER\',path2
              :Case 'HKCR'
                  path←'HKEY_CLASSES_ROOT\',path2
              :Case 'HKLM'
                  path←'HKEY_LOCAL_MACHINE\',path2
              :Case 'HKU'
                  path←'HKEY_USERS\',path2
              :Else
                  11 ⎕SIGNAL⍨'WinReg error: invalid Registry key'
              :EndSelect
          :EndIf
      :Else
          path←'HKEY_CURRENT_USER\',path
      :EndIf
    ∇

      Make←{
          0=⎕NC ⍵:⍺
          ⍎⍵}

      GetAll←{
      ⍝ Examples:
      ⍝ GetAll 'REG'
      ⍝ GetAll 'ERROR'
          l←⎕NL 2                           ⍝ All variables
          l←(l[;⍳⍴,⍵]∧.=⍵)⌿l                ⍝ Only those which start with ⍵
          (↓l)~¨' '                         ⍝ Transform into vectors of vectors
      }

    Partition←{⍵⊂⍨⍵≠⎕ucs 0}

    ∇ r←GetVersion;rc;OSVERSIONINFO
   ⍝ Gets the OS version.
   ⍝ r[0] = Major version
   ⍝ r[1] = Minor version
   ⍝ r[2] = BuildNumber
      '∆GetVersion'⎕NA'I KERNEL32|GetVersionExA ={I I I I I T[128]}' ⍝ Don't convert this to Unicode - no point!
      OSVERSIONINFO←148 0 0 0 0(128⍴NULL)
      (rc r)←∆GetVersion⊂OSVERSIONINFO
      r←3↑1↓r
    ∇

    ∇ R←ExpandEnv Y;ExpandEnvironmentStrings;multiByte
    ⍝ If Y does not contain any "%", Y is passed untouched.
    ⍝ In case Y is empty R is empty as well.
    ⍝ Example:
    ⍝ <pre>'C:\Windows\MyDir' ←→ ExpandEnv '%WinDir%\MyDir'</pre>
      :If '%'∊R←Y
          'ExpandEnvironmentStrings'⎕NA'I4 KERNEL32.C32|ExpandEnvironmentStrings',AnsiOrWide,' <0T >0T I4'
          multiByte←1+80=⎕DR' '       ⍝ Unicode version? (used to double the buffer size)
          R←2⊃ExpandEnvironmentStrings(Y(multiByte×1024)(multiByte×1024))
      :EndIf
    ∇

    ∇ r←HandleDataType(type length data);multiByte
      multiByte←80=⎕DR' '
      :Select type
      :Case REG_SZ
          r←(¯1+length÷1+multiByte)↑data
      :Case REG_DWORD
          r←data
      :Case REG_BINARY
          r←length↑data
      :Case REG_EXPAND_SZ
          r←ExpandEnv(¯1+length÷1+multiByte)↑data
      :Case REG_MULTI_SZ
          r←Partition(¯1+length÷1+multiByte)↑data
      :EndSelect
    ∇

    ∇ r←AnsiOrWide;⎕IO
      ⎕IO←0
      r←'*A'⊃⍨12>{⍎⍵↑⍨⍵⍳'.'}1⊃'.'⎕WG'APLVersion'
    ∇

    ∇ r←mat GetAsString value;values
    ⍝ Sub fns of GetErrorAsStringFrom and GetTypeAsStringFrom
      :If 0∊⍴value
          r←⍉mat,[0.5]⍎¨mat             ⍝ Build matrix with cols "Name" and "Value"
      :Else
          values←⍎¨l                ⍝ Get the values
          r←{1=⍴,⍵:↑⍵ ⋄ ⍵}(mat,⊂'?')[values⍳value]
      :EndIf
    ∇

    ∇ r←ConvertErrorCode rc;all
    ⍝ rc is a number representing an error code.
    ⍝ Returns either the name of the constant and/or the number as text.
    ⍝ Examples:
    ⍝ 'ERROR_ACCESS_DENIED (RC=5)' ←→ 'E' ConvertErrorCode 5
    ⍝ '(RC=123)' ←→ 'E' ConvertErrorCode ¯123
      :If 0=rc
          r←''
      :Else
          all←ListError
          :If rc∊all[;2]
              r←1⊃all[all[;2]⍳rc;]
          :Else
              r←'RC=',⍕rc
          :EndIf
      :EndIf
    ∇

    ∇ r←List string
      ⍝ List all vars starting with "string"
      r←(↑string)⎕NL-2
      r←string{⍵⌿⍨((⍴⍺)↑[2]⊃⍵)∧.=⍺}r
    ∇

:EndClass