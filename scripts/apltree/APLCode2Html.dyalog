:Class APLCode2Html
⍝ Takes APL code and creates either HTML snippets or a fully-fledged HTML page.

⍝ There are two ways to use this clase. Try the shared method _
⍝ "PrepareCodeForHtml" first. It does what it's supposed to do without _
⍝ any further ado. Naturally it makes quite a lot of assumptions and _
⍝ takes them as defaults. If you cannot live with these defaults you _
⍝ must create an instance and then change the defaults accordingly before _
⍝ finally executing the "WriteHtml2File" method with a filename as right _
⍝ argument. For more help and examples call:
⍝ APLCode2Html.Help

⍝ The right argument of `⎕NEW` might be one of:
⍝ # Simple string: treated as the name of a function or operator or script.
⍝ # Nested vector of strings: treated as APL code.
⍝ # Empty vector:, the contents of the clipboard is taken.

⍝ For -1- and -3-, a fully fledged HTML page is created, including proper _
⍝ encoding information and some CSS.
⍝ For -2- an HTML snippet with a PRE tag around the code is created.
⍝ Makes nested stuff simple by inserting CR between items and then replace _
⍝ all "&" and "<" and "<" with it's HTML entities.
⍝ If y is empty, the contents of the clipboard is taken. In that case the _
⍝ result is written back to the clipboard as well. If the left argument is _
⍝ specified, however, the clipboard is NOT overwritten, even if the right _
⍝ argument was empty.
⍝ Instead, a fully-fledged HTML-page with utf-8 encoding is created and _
⍝ written under that filename.
⍝ If "filename" does not come with an extension, it defaults to "html"
⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/APLCode2HTML

    :Include APLTreeUtils
    ⎕IO←1 ⋄ ⎕ML←1
    :Field Public Shared Readonly cr←⎕UCS 13 10

    ∇ R←Version
      :Access Public Shared
      R←(Last⍕⎕THIS)'1.3.1' '2015-01-31'
      ⍝ 1.3.0 :
      ⍝ * New test case 999 added.
      ⍝ * Inline APL code in ADOC-able comments is now marked with ` (tick).
    ∇

    :Property title
    ⍝ The title of the HTML page
    :Access Public
        ∇ r←get
          r←_title
        ∇
        ∇ set arg
          _title←arg.NewValue
        ∇
    :EndProperty

    :Property textFonts
    ⍝ The font(s) to be used in the HTML page for non-APL code
    :Access Public
        ∇ r←get
          r←_textFonts
        ∇
        ∇ set arg
          _textFonts←arg.NewValue
        ∇
    :EndProperty

    :Property textFontSize
    ⍝ The size of the font(s) to be used in the HTML page for non-APL code
    :Access Public
        ∇ r←get
          r←_textFontSize
        ∇
        ∇ set arg
          _textFontSize←arg.NewValue
        ∇
    :EndProperty

    :Property printTextFontSize
    ⍝ The size of the font(s) to be used in the HTML page for printing non-APL code
    :Access Public
        ∇ r←get
          r←_printTextFontSize
        ∇
        ∇ set arg
          _printTextFontSize←arg.NewValue
        ∇
    :EndProperty

    :Property aplFonts
    ⍝ The font(s) to be used in the HTML page for APL code
    :Access Public
        ∇ r←get
          r←_aplFonts
        ∇
        ∇ set arg
          _aplFonts←arg.NewValue
        ∇
    :EndProperty

    :Property aplFontSize
    ⍝ The size of the font(s) to be used in the HTML page for APL code
    :Access Public
        ∇ r←get
          r←_aplFontSize
        ∇
        ∇ set arg
          _aplFontSize←arg.NewValue
        ∇
    :EndProperty

    :Property aplPrintFontSize
    ⍝ The size of the font(s) to be used in the HTML page for printing APL code
    :Access Public
        ∇ r←get
          r←_aplPrintFontSize
        ∇
        ∇ set arg
          _aplPrintFontSize←arg.NewValue
        ∇
    :EndProperty


    :Property backgroundColor
    ⍝ The backhround color of the HTML page
    :Access Public
        ∇ r←get
          r←_backgroundColor
        ∇
        ∇ set arg
          _backgroundColor←arg.NewValue
        ∇
    :EndProperty


    ∇ make
      :Implements Constructor
      :Access Public Instance
      EstablishDefaults ⍬
    ∇

    ∇ make1(title)
      :Implements Constructor
      :Access Public Instance
      EstablishDefaults ⍬
      _title←title
    ∇

    ∇ make2(title filename)
      :Implements Constructor
      :Access Public Instance
      EstablishDefaults ⍬
      _filename←filename
    ∇

    ∇ EstablishDefaults dummy
      _title←''
      _aplFonts←'"APL385 Unicode", "APLX Upright", "APL2 Unicode"'
      _aplFontSize←'medium'
      _aplPrintFontSize←'x-small'
      _textFonts←'Arial'
      _textFontSize←'medium'
      _textPrintFontSize←'x-small'
      _backgroundColor←'#F3F5F7'
      _html←''
      _filename←''
    ∇

    ∇ AddHeader(level text)
      :Access Public Instance
    ⍝ Add a header of "level" (1 to 6)
      'Invalid level (1-6)'⎕SIGNAL 11/⍨~level∊⍳6
      _html,←cr,'<h',(⍕level),'>',text,'</h',(⍕level),'>'
    ∇

    ∇ AddClipboard;⎕WX;code
      :Access Public Instance
      ⎕WX←1
      'cl'⎕WC'Clipboard'
      code←Prepare cl.Text
      AddCode code
    ∇

    ∇ AddText y;⎕IO;⎕ML
      :Access Public Instance
      ⎕IO←1 ⋄ ⎕ML←3
      'Invalid right argument: must be either simple of depth 2'⎕SIGNAL 11/⍨~2 0 1∊⍨≡y
      :If 0 1∊⍨≡y
          y←Prepare y
          _html,←'<p>',y,cr,'</p>'
      :Else
          AddText¨y
      :EndIf
    ∇

    ∇ AddCode y;⎕IO;⎕ML;string
      :Access Public Instance
      ⎕IO←1 ⋄ ⎕ML←3
      'Invalid right argument: must be either simple of depth 2'⎕SIGNAL 11/⍨~2 0 1∊⍨≡y
      string←MakeSimple y
      _html,←cr,'<pre class="apl">',cr,string,cr,'</pre>'
    ∇

    ∇ AddBody name;⎕IO;⎕ML;string
      :Access Public Instance
      ⎕IO←1 ⋄ ⎕ML←3
      :If '#'≠1⍴name
          name←(1⊃⎕NSI),'.',name
      :EndIf
      'Invalid right argument: must be name of either function or operator'⎕SIGNAL 11/⍨~3 4∊⍨⎕NC name
      string←MakeSimple ⎕VR name
      _html,←cr,'<pre class="apl">',cr,string,cr,'</pre>'
    ∇

    ∇ AddScript ref;⎕IO;⎕ML;string
      :Access Public Instance
      ⎕IO←1 ⋄ ⎕ML←3
      'Invalid right argument: must be reference to a script'⎕SIGNAL 11/⍨(~⍬≡⍴ref)∨0≠≡ref
      string←⎕SRC ref
      string←string,⍨¨{⍵↑¨⍨⌈/⍴¨⍵}{'[',(⍕⍵),'] '}¨¯1+⍳⍴string
      string←MakeSimple string
      _html,←cr,'<pre class="apl">',cr,string,cr,'</pre>'
    ∇

    ∇ r←GetHtml
      :Access Public Instance
    ⍝ Prepare the full HTML page and return it
      r←'<html>',cr,MakeHeader,cr,'<body>',cr,_html,cr,'</body>',cr,'</html>'
    ∇

    ∇ PutHtml2Clipboard;⎕WX;cl
      :Access Public Instance
    ⍝ Prepare the full HTML page and put it into the clipboard
      ⎕WX←1
      'cl'⎕WC'Clipboard'
      cl.Text←GetHtml
    ∇

    ∇ WriteHtml2File filename;html
      :Access Public Instance
    ⍝ Prepare the full HTML page and write it to "filename"
      filename←(1+0∊⍴filename)⊃filename _filename
      html←GetHtml
      WriteUtf8File filename html
    ∇

    ∇ WriteUtf8File(filename data);⎕IO;⎕ML;fno
      :Access Public Shared
     ⍝ Write UTF-8 "data" to "filename"
      ⎕IO←⎕ML←1
      data←{~0 1∊⍨≡⍵:⊃{⍺,cr,⍵}/⍵ ⋄ ⍵}data        ⍝ Make nested simple with CR between items
      data←⎕UCS'UTF-8'⎕UCS data                  ⍝ Enforce UTF-8
      fno←{
          19 22::filename ⎕NCREATE 0             ⍝ In case ⎕NTIE fails
          fno←filename ⎕NTIE 0 17                ⍝ Open exclusively
          _←filename ⎕NERASE fno                 ⍝ Erase the file...
          _←filename ⎕NCREATE 0
          fno
      }filename                                  ⍝ ...and create a new one
      data ⎕NAPPEND fno                          ⍝ Write...
      ⎕NUNTIE fno                                ⍝...and close
    ∇


    ∇ {r}←{x}PrepareCodeForHtml y;⎕IO;⎕ML;Replace;sep;ref;flag;cl;head;path;title;filename
      :Access Public Shared
⍝ Takes APL code and creates either HTML snippets or a fully-fledged HTML page.
⍝ The right argument might be one of:
⍝ -1- Simple string: treated as the name of a function or operator or script.
⍝ -2- Nested vector of strings: treated as APL code.
⍝ -3- Empty vector:, the contents of the clipboard is taken.
⍝ For -1- and -3-, a fully fledged HTML page is created, including proper _
⍝ encoding information and some CSS.
⍝ For -2- an HTML snippet with &lt;pre&gt; around the code is created.
⍝ Makes nested stuff simple by inserting CR between items and then replace all _
⍝ of "&<> with their HTML entities.
⍝ If y is empty, the contents of the clipboard is taken. In that case the result _
⍝ is written back to the clipboard as well.
⍝ If the left argument is specified, however, the clipboard is NOT overwritten, _
⍝ even if the right argument was empty. Instead, a fully-fledged HTML-page with _
⍝ utf-8 encoding is created and written under that filename.
⍝ The left argument may be either a simple string or a nested vector of length 2:
⍝ A simple string is treated as a filename. With a nested vector, [1] is treated _
⍝ as a filename while [2] is treated as a title for the HTML page.
⍝ If "filename" does not come with an extension, it defaults to "html"
⍝ Kai Jaeger ⋄ APL Team Ltd ⋄ 2010-10-25 ⋄ Version 1.3
      ⎕IO←1 ⋄ ⎕ML←3
      sep←⎕UCS 13
      :If 0=⎕NC'x'                           ⍝ If there is no left argument...
          (filename title)←'' ''             ⍝ ...we establish defaults.
      :Else                                  ⍝ Otherwise...
          :If 0 1∊⍨≡x                        ⍝ ...if not nested...
              filename←x                     ⍝ ...we just got a filename...
              title←''                       ⍝ but no title, so it's empty
          :Else
              (filename title)←x             ⍝ we got both, filename and title
          :EndIf
      :EndIf
      :If flag←0∊⍴y                          ⍝ It it's empty...
          'cl'⎕WC'Clipboard'                 ⍝ ...we create a Clipbaord object...
          r←cl.Text                          ⍝ ...and take the text from the clipboard
      :Else
          :If 0 1∊⍨≡y
              :Select ↑⎕NC y
              :CaseList 3 4
                  r←⎕VR y
              :Case 9
                  r←⎕SRC⍎y
                  r←r,⍨¨{⍵↑¨⍨⌈/⍴¨⍵}{'[',(⍕⍵),'] '}¨¯1+⍳⍴r
              :Else
                  'Invalid right argument: neither script not function nor operator'⎕SIGNAL 11
              :EndSelect
              title←y{0∊⍴⍵:⍺ ⋄ ⍵}title
          :Else
              r←y
          :EndIf
      :EndIf
      r←sep{0 1∊⍨≡⍵:⍵ ⋄ 1↓∊⍺,¨⍵}r            ⍝ Enforce simplicity and inject CR if nested
      Replace←{                              ⍝ Local utility: replace a char by its entity
          (char entity string)←⍵
          0=+/bool←string=char:string
          (bool/string)←⊂entity
          ∊string
      }
      r←Replace'&' '&amp;'r
      r←Replace'<' '&lt;'r
      r←Replace'>' '&gt;'r
 ⍝⍝⍝ We are done so far, so let's start creating the HTML
      :If flag∧0∊⍴filename                   ⍝ we got no filename, so we create a <pre> snippet only
          r←'<pre style="font-family:''APL385 Unicode'', ''APLX Upright'', ''APL2 Unicode''; font-size: medium; margin:10px; padding:0;">',sep,r,sep,'</pre>'
          cl.Text←r
      :EndIf
      :If 0∊⍴filename
          r←'<pre id="apl" style="font-family:''APL385 Unicode'', ''APLX Upright'', ''APL2 Unicode''; font-size: medium;"',sep,r,sep,'</pre>'
      :Else
          r←'<pre id="apl">',sep,r,sep,'</pre>'
          (path filename)←{~∨/'/\'∊⍵:''⍵ ⋄ ⍵{(⍺↓⍨-⍵)(⍺↑⍨-⍵)}¯1+⌊/'/\'⍳⍨⌽⍵}filename
          filename,←(~'.'∊filename)/'.html'
          r←'<body>',sep,({0∊⍴⍵:'' ⋄ '<h1>',⍵,'</h1>',sep}title),r,sep,'</body>'
          head←'<head>',sep
          head,←{0∊⍴⍵:⍵ ⋄ '<title>',⍵,'</title>'}title
          head,←'<meta http-equiv="Content-Type" content="text/html;charset=utf-8">',sep
          head,←'<style type="text/css" media="screen">'
          head,←'html {font-family: "Arial"; background-color: #F3F5F7; font-size: medium; margin:0; padding:0; }'
          head,←'pre#apl {font-family: "APL385 Unicode", "APLX Upright", "APL2 Unicode"; font-size: medium; margin:0; padding:0; }'
          head,←'</style>'
          head,←'<style type="text/css" media="print">'
          head,←'html {font-family: "Arial"; font-size: x-small; margin:0; padding:0;}'
          head,←'pre#apl {font-family: "APL385 Unicode", "APLX Upright", "APL2 Unicode"; font-size: small; margin:0; padding:0; }'
          head,←'</style>'
          head,←'</head>'
          r←'<html>',sep,head,sep,r,sep,'</html>'
          WriteUtf8File←{
      ⍝ Write UTF-8 "data" to "filename"
              (filename data)←⍵
              ⎕IO←⎕ML←1
              cr←⎕UCS 13 10
              data←{~0 1∊⍨≡⍵:⊃{⍺,cr,⍵}/⍵ ⋄ ⍵}data  ⍝ Make nested simple with CR between items
              data←⎕UCS'UTF-8'⎕UCS data                ⍝ Enforce UTF-8
              fno←{19 22::filename ⎕NCREATE 0          ⍝ In case ⎕NTIE fails
                  fno←filename ⎕NTIE 0 17                ⍝ Open exclusively
                  _←filename ⎕NERASE fno                 ⍝ Erase the file...
                  filename ⎕NCREATE 0}filename           ⍝ ...and create a new one
              _←data ⎕NAPPEND fno                      ⍝ Write...
              ⎕NUNTIE fno                              ⍝...and close
          }
          WriteUtf8File(path,filename)r              ⍝ Off we go
      :EndIf
    ∇

⍝⍝⍝ Private stuff

    ∇ r←Prepare string;⎕IO;⎕ML
      :Access Public Instance
      ⎕IO←1 ⋄ ⎕ML←3
      r←cr{0 1∊⍨≡⍵:⍵ ⋄ 1↓∊⍺,¨⍵}string ⍝ Enforce simplicity and inject CR if nested
      r←Replace'&' '&amp;'r
      r←Replace'<' '&lt;'r
      r←Replace'>' '&gt;'r
    ∇

      Replace←{
        ⍝ Replace a char by its entity
          (char entity string)←⍵
          0=+/bool←string=char:string
          (bool/string)←⊂entity
          ∊string
      }

    ∇ head←MakeHeader
      head←'<head>',cr
      head,←{0∊⍴⍵:⍵ ⋄ '<title>',⍵,'</title>'}_title
      head,←'<meta http-equiv="Content-Type" content="text/html;charset=utf-8">',cr
      head,←'<style type="text/css" media="screen">',cr
      head,←'html {font-family: ',_textFonts,'; background-color: ',_backgroundColor,'; font-size: ',(⍕_textFontSize),'; margin:0; padding:0; }',cr
      head,←'#apl {font-family: ',_aplFonts,'; font-size: ',(⍕_aplFontSize),'; margin:0.75em 0 0.5em 0; padding:0; }',cr
      head,←'</style>',cr
      head,←'<style type="text/css" media="print">',cr
      head,←'html {font-family: ',_textFonts,'; font-size: ',(⍕_aplPrintFontSize),'; margin:0; padding:0;}',cr
      head,←'#apl {font-family: ',_aplFonts,'; font-size: ',(⍕_textPrintFontSize),'; margin:15pt 0 10pt 0; padding:0; }',cr
      head,←'</style>',cr
      head,←'</head>'
    ∇

      MakeSimple←{⍝ Enforce simplicity and inject CR if nested
          0 1∊⍨≡⍵:⍵ ⋄ 1↓∊cr∘,¨⍵}

:EndClass