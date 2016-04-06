:Class ShowChmHelp
⍝ This class allows you to show up CHM help files from APL.
⍝ You can also display particular topics, but for this you must know the topic name.
⍝ Note that for technical reasons erasing the instance let the help file disappear _
⍝ immediately. The reason is that the DLL *must* be unloaded properly, otherwise _
⍝ chances are that APL will crash. So make sure that the instance lives as long as _
⍝ as you want the help file to have a visual appearance. As soon as the instance _
⍝ is deleted, regardless how, the destructor might get called - and will get _
⍝ called, although the precise schedule is for principle reasons unkown.
⍝ This class does not support the depricated "DisplayContext" method.
⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/ShowChmHelp

    ⎕IO←1 ⋄ ⎕ml←3

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public shared
      r←(Last⍕⎕THIS)'1.2.0' '2015-01-10'
    ∇

⍝⍝⍝ Constructor

    ∇ make
      :Access Public Instance
      :Implements Constructor
      InitExternalFns ⍬
      Init ⍬
    ∇

    ∇ Quit
⍝⍝⍝ Destructor
      :Implements Destructor
      :If 0<⎕NC'∆Quit'
          {}∆Quit 0 0 18 0
          {}∆Quit 0 0 29 cookie
      :EndIf
      ⎕EX'_'⎕NL 3
      ⎕EX'HH_'
      ⎕EX'∆'⎕NL 2
    ∇

    ∇ InitExternalFns dummy
      'ToLower'⎕NA'I4 USER32.C32|CharLower',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' =0T'
      'ToUpper'⎕NA'I4 USER32.C32|CharUpper',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' =0T'
      'GetDesktopWindow'⎕NA'I4 user32.C32∣GetDesktopWindow'
      '∆FindFirstFile'⎕NA'I4 kernel32.C32|FindFirstFile',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T >{I4 {I4 I4} {I4 I4} {I4 I4} {I4 I4} {I4 I4} T[260] T[14]}'
      '∆FindClose'⎕NA'kernel32.C32|FindClose I4'
      '∆DisplayTopic'⎕NA'I4 hhctrl.ocx.C32∣HtmlHelp',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I <0T[] I I'
      '∆DisplayHelpfile'⎕NA'I4 hhctrl.ocx.C32|HtmlHelp',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I <0T[] I I'
      '∆Quit'⎕NA'I4 hhctrl.ocx.C32|HtmlHelp',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I I I I'
      '∆Init'⎕NA'I4 hhctrl.ocx.C32|HtmlHelp',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I I I >I'
      '∆GetLastError'⎕NA'I4 kernel32.C32|GetLastError'
    ∇

    ∇ Init Parms;Allowed
      _WindowsDefault←''
      :If IsChar _WindowsDefault
          _WindowsDefault←Uppercase _WindowsDefault
          :If ~0∊⍴,_WindowsDefault
          :AndIf (⊂_WindowsDefault)∊'DEVELOPMENT' 'DESKTOP'
              6 ⎕SIGNAL⍨'Check parameter "WindowsDefault"!'
          :EndIf
      :EndIf
      cookie←2⊃∆Init 0 0 28 0
      ⎕EX'HH_'
      h
    ∇

    ∇ CheckInit Dummy
      :If 0=⎕NC'∆WINDOWDEFAULT'
          Init''
      :ElseIf 0=⎕NC'HH_'
      :OrIf 0∊⍴HH_.⎕NL 2
          h
      :EndIf
    ∇

⍝⍝⍝ Public

    ∇ {R}←DisplayHelpfile Filename;handle
      :Access Public Instance
      handle←GetDefaultHandle''
      :If '.CHM'≢Uppercase ¯4↑Filename
          Filename,←'.chm'
      :EndIf
      :If DoesFileExist Filename
          R←(∆DisplayHelpfile handle Filename HH_.DISPLAY_TOPIC 0)''
      :Else
          R←¯1 'File not found'
      :EndIf
    ∇

    ∇ {r}←{cs}DisplayTopic(filename topicName);appHandle;helpWindowName;allowed
 ⍝ Displays a particular topic identified by name within a particular help file.
 ⍝ Optional parameters: HelpWindowName, appHandle
      :Access Public Instance
      appHandle←GetDefaultHandle''
      helpWindowName←'Main'
      :If 0<⎕NC'cs'
      :AndIf ~0∊⍴,cs
          allowed←'helpWindowName' 'appHandle'
          'Invalid optional parameters'⎕SIGNAL 11/⍨~∧/(cs.⎕NL-2)∊allowed
          ⍎cs.{l←⊃,/' ',¨⎕NL-2 ⋄
              ('(',l,')←cs.⍎''',l,'''')}⍬
      :EndIf
      :If DoesFileExist filename
          :If '.HTM'≢¯4↑filename←filename,'::/',topicName
              filename,←'.htm'
          :EndIf
          :If ~'>'∊filename
          :AndIf ~0∊⍴helpWindowName
              filename,←'>',helpWindowName
          :EndIf
          r←(∆DisplayTopic appHandle filename HH_.DISPLAY_TOPIC 0)''
      :Else
          r←¯1 'File not found'
      :EndIf
    ∇

⍝⍝⍝ Private stuff

    ∇ R←DoesFileExist Filename;Handle;Trash
      Filename↓⍨←{(-+/∧\(⌽⍵)∊'/\')}Filename
      :If R←0≠Handle←1⊃FindFirstFile Filename''
          Trash←∆FindClose Handle
      :EndIf
    ∇

      FindFirstFile←{
          ⎕IO←0
          ¯1=↑rslt←∆FindFirstFile ⍵:0 ∆GetLastError
          (1 6⊃rslt)←FindTrim(1 6⊃rslt)        ⍝ shorten the file name at the null delimiter
          (1 7⊃rslt)←FindTrim(1 7⊃rslt)        ⍝ and for the alternate name
          rslt
      }

    ∇ R←GetDefaultHandle Type
    ⍝ Type may be "Development" or "Desktop" or empty.
    ⍝ If it is empty, _WindowsDefault is taken as a default.
    ⍝ If _WindowsDefault is empty, "Development" is taken as default.
      :If 0∊⍴,Type
          :If ~0∊⍴,_WindowsDefault ⍝ can be specified by "Init"
              Type←_WindowsDefault
          :Else
              Type←'Development'
          :EndIf
      :EndIf
      :If 'Development'≡4⊃'.'⎕WG'aplVersion'
      :AndIf 'DEVELOPMENT'≡Type
          R←'⎕se'⎕WG'Handle'
      :Else
          R←GetDesktopWindow
      :EndIf
    ∇

    ∇ h
      ⎕EX'HH_'
      'HH_'⎕NS''
      :With 'HH_'
          DISPLAY_TOPIC←0
          HELP_FINDER←0
          DISPLAY_TOC←1
          DISPLAY_INDEX←2
          DISPLAY_SEARCH←3
          SET_WIN_TYPE←4
          GET_WIN_TYPE←5
          GET_WIN_HANDLE←6
          ENUM_INFO_TYPE←7
          SET_INFO_TYPE←8
          SYNC←9
          RESERVED1←10
          RESERVED2←11
          RESERVED3←12
          KEYWORD_LOOKUP←13
          DISPLAY_TEXT_POPUP←14
          HELP_CONTEXT←15
          TP_HELP_CONTEXTMENU←16
          TP_HELP_WM_HELP←17
          CLOSE_ALL←18
      :End
    ∇

    IsChar←{' '=1↑0⍴∊⍵}

      FindTrim←{
          ⍵↑⍨(⍵⍳↑AV)-⎕IO
      }

    ∇ r←AV
    ⍝ Holding this in a global variable would be faster indeed but
    ⍝ also not compatible with the Classic version
      r←⎕UCS 0 8 10 13 32 12 6 7 27 9 9014 619 37 39 9082 9077 95 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112
      r,←⎕UCS 113 114 115 116 117 118 119 120 121 122 1 2 175 46 9068 48 49 50 51 52 53 54 55 56 57 3 164 165 36 163 162 8710 65
      r,←⎕UCS 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 4 5 253 183 127 9049 193 194 195 199 200
      r,←⎕UCS 202 203 204 205 206 207 208 210 211 212 213 217 218 219 221 254 227 236 240 242 245 123 8364 125 8867 9015 168 192
      r,←⎕UCS 196 197 198 9064 201 209 214 216 220 223 224 225 226 228 229 230 231 232 233 234 235 237 238 239 241 91 47 9023 92
      r,←⎕UCS 9024 60 8804 61 8805 62 8800 8744 8743 45 43 247 215 63 8714 9076 126 8593 8595 9075 9675 42 8968 8970 8711 8728 40
      r,←⎕UCS 8834 8835 8745 8746 8869 8868 124 59 44 9073 9074 9042 9035 9033 9021 8854 9055 9017 33 9045 9038 9067 9066 8801 8802
      r,←⎕UCS 243 244 246 248 34 35 30 38 8217 9496 9488 9484 9492 9532 9472 9500 9508 9524 9516 9474 64 249 250 251 94 252 8216
      r,←⎕UCS 8739 182 58 9079 191 161 8900 8592 8594 9053 41 93 31 160 167 9109 9054 9059
    ∇

:EndClass