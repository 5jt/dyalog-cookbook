:Class MarkAPL
⍝ ## Overview
⍝ MarkAPL is a parser that converts Markdown to valid HTML5.\\
⍝ The Markdown can be specified in two ways:
⍝ * As a vector of text vectors.
⍝ * As a filename.
⍝
⍝ ## How to get help
⍝ In order to view MarkAPL's cheat sheet execute this:\\
⍝ ~~~
⍝ #.MarkAPL.Help 0
⍝ ~~~
⍝ This will work if MarkAPL's `Files/` folder lives in the current directory.
⍝ If it doesn't then either make sure that it does or create a parameter
⍝ space by calling `CreateHelpParms` and then specify the folder that hosts
⍝ MarkAPL's `Files/` folder on  `homeFolder`. It will show the cheat sheet
⍝ in your default browser.\\
⍝ If you need comprehensive information call:
⍝ ~~~
⍝ #.MarkAPL.Reference 0
⍝ ~~~
⍝ ## Examples
⍝ ### Creating an HTML file from a Markdown file
⍝ ~~~
⍝ report←#.MarkAPL.ConvertMarkdownFile 'C:\MyMarkdown.md'
⍝ ~~~
⍝ This converts the Markdown in the file `C:\MyMarkdown.md` into fully-fledged
⍝ HTML and writes it to a file `C:\MyMarkdown.html`.\\
⍝ `report` is ideally empty but might be a vector of text vectors with warnings
⍝ or even error messages.a
⍝ The example uses just defaults. Instead you can specify parameters via a
⍝ namespace passed as the optional left argument. See further down an example how
⍝ to do this with the `Markdown2HTML` method.
⍝ ### Creating HTML from Markdown
⍝ Of course you can also convert Markdown from a variable in the workspace:
⍝ ~~~
⍝ MyMarkdown←'# MarkAPL' 'All about **_MarkAPL_**'
⍝ ~~~
⍝ ~~~
⍝ (html ns)←#.MarkAPL.Markdown2HTML MyMarkdown
⍝ ~~~
⍝ This converts `MyMarkdown` into HTML. By default the HTML is just a snippet, not
⍝ a fully-fledged HTML page. You can change that by:
⍝ ~~~
⍝ parms←#.MarkAPL.CreateParms
⍝ parms.inputFilename←'in.md'
⍝ parms.outputFilename←'out.md'
⍝ (html ns)←parms #.MarkAPL.Markdown2HTML ''
⍝ ~~~
⍝ If you want to create a full-blown HTML page without any files being involved you
⍝ can also set the `createFullHtmlPage` parameter to 1.
⍝ ## Misc
⍝ |Homepage:    | <http://aplwiki.com/MarkAPL> |
⍝ |Cheat sheet: | <http://download.aplteam.com/MarkAPL_CheatSheet.html> |
⍝ |Reference:   | <http://download.aplteam.com/MarkAPL.html> |
⍝ Kai Jaeger ⋄ APL Team Ltd
    ⎕IO←1 ⋄ ⎕ML←1

    :Include APLTreeUtils

    ∇ r←Version
      :Access Public Shared
      ⍝ ##### 2.8.6
      ⍝ * Bug fix:
      ⍝   * Comment lines within a code block disappeared under some circumstances.
      ⍝ ##### 2.8.6
      ⍝ * Bug fixes:
      ⍝   * Under some circumstances a footnote ref was not recognized as such.
      ⍝   * MarkAPL called one of its own methods with a fully qualified name.
      ⍝ ##### 2.8.5
      ⍝ * Bug fix
      ⍝   * A header (`#`) without **any** caption crashed MarkAPL.
      ⍝ ##### 2.8.4
      ⍝ * Bug fixes
      ⍝   * A link that contained \_ or \* within code was not displayed correctly.
      ⍝ ##### 2.8.3
      ⍝ * Bug fixes
      ⍝   * URLs in links got reported in the session by accident.
      ⍝ ##### 2.8.2
      ⍝ * Bug fixes:
      ⍝   * Problems are not reported to the session if it is not...
      ⍝     * ... a development version
      ⍝     * ... there is nothing to report (in the past an empty vector was printed).
      ⍝
      ⍝ ##### 2.8.1
      ⍝ * Bug fixes:
      ⍝ * A code block carrying `<` or `<` and is part os a list item went wrong.
      ⍝
      ⍝ ##### 2.8.0
      ⍝ * HTML entities can be injected now (in the sense of them being converted) by escaping the
      ⍝   `&` character. So far `&` has not been an escapable character.
      ⍝ * A URL in a link that does not specify the protocol now defaults to `http://`. This is not
      ⍝   true for autolinks!
      ⍝ * Bug fixes:
      ⍝   * The lists created inside <nav> (TOC) were wrongly structured (although they work fine).
      ⍝   * Documentation failed to mention the affect of `markdownStrict←1` regarding Guillemets.
      ⍝   * A URL in a link that carried a `_` caused havoc.
      ⍝   * `CorrectSlashes` turned any `\` into `/`. Should honour the OS. It does now.
      r←(Last⍕⎕THIS)'2.8.7' '2017-02-10'
    ∇

    :Field Public Shared ReadOnly PartOfNames←⎕A,⎕D,'_∆⍙','qwertyuiopasdfghjklzxcvbnm'
    :Field Public Shared ReadOnly AllWhiteSpaceChars←⎕ucs 32 9 10 11 13

    ⎕IO←1 ⋄ ⎕ML←1

    ∇ {(html ns)}←{parms}Markdown2HTML markdown
    ⍝ `⍵` is one of:
    ⍝   * Vector of character vectors representing a Markdown document.
    ⍝   * Empty vector. In this case the parameter "inputFilename" must be specified.
    ⍝ `⍺` Is a namespace with parameters, typically create by calling `CreateParms`.\\
    ⍝ `←` Is a two-element vector starting from version 1.7.0:
    ⍝ 1. Is always the HTML created. As a side effect this HTML will also be written
    ⍝    to the file specified by `outputFilename` - if that is not empty that is.
    ⍝ 2. The `ns` namespace created by `Init` and needed / processed by `Process. This contains `ns.report`,
    ⍝    something you might want to check.
      :Access Public Shared
      parms←{0<⎕NC ⍵:⍎⍵ ⋄ CreateParms}'parms'
      :If 0∊⍴markdown
          :If 0∊⍴parms.inputFilename
              'Neither "markdown" nor "inputFilename" defined'⎕SIGNAL 6
          :Else
              markdown←ReadUtf8File parms.inputFilename
          :EndIf
      :EndIf
      ns←Init parms markdown
      ns←Process ns
      html←ns.html
      :If (~0∊⍴ns.parms.outputFilename)∧0≠ns.parms.createFullHtmlPage
      :OrIf 1=ns.parms.createFullHtmlPage
          html←ns.parms MakeHTML_Doc html
      :EndIf
      {}WriteUtf8File⍣(~0∊⍴ns.parms.outputFilename)⊣ns.parms.outputFilename html
    ∇

    ∇ r←parms MakeHTML_Doc html;css;bool;lines;sh;ind
    ⍝ Takes HTML, typically created by calling `Process`, and makes it a fully fledged document by adding
    ⍝ <body>, <head> -- with <title> -- and <html> including the DocType. By default CSS is injected as well.
      :Access Public Shared
      r←⊂'<!DOCTYPE html>'
      r,←⊂'<html',((~0∊⍴parms.lang)/' lang="',(parms.lang~'"'),'"'),'>'
      r,←⊂'<head>'
      :If parms.enforceEdge
          ⍝ ↓↓↓ https://blogs.msdn.microsoft.com/askie/2009/03/23/understanding-compatibility-modes-in-internet-explorer-8/
          r,←⊂'<meta http-equiv="X-UA-Compatible" content="IE=edge" />'
          ⍝ This MUST be the first <meta> tag!
      :EndIf
      r,←⊂'<meta charset="',parms.charset,'">'
      :If ~0∊⍴parms.head
          r,←Nest parms.head
      :EndIf
      :If ¯1≡parms.title
          :If 1=+/ind←∨/¨⊃∨/'<h1 ' '<h1>'{⍺∘⍷¨⍵}¨⊂html
              parms.title←{⍵↑⍨¯1+⍵⍳'<'}{⍵↓⍨⍵⍳'>'}{⍵↓⍨¯1+1⍳⍨'<h1'⍷⍵}(ind⍳1)⊃html
          :Else
              parms.title←'MarkAPL'
          :EndIf
      :EndIf
      r,←⊂'<title>',parms.title,'</title>'
      parms←EstablishDefaultHomeFolder parms
      :If 0=parms.noCSS
          :If ¯1≡parms.cssURL
              parms.cssURL←parms.homeFolder
          :EndIf
          :If parms.linkToCSS
              r,←⊂'<link rel="stylesheet" media="screen" href="',parms.(cssURL,screenCSS),'">'
              :If ~0∊⍴parms.printCSS
                  r,←⊂'<link rel="stylesheet" media="print" href="',parms.(cssURL,printCSS),'">'
              :EndIf
          :Else
              :If ~0∊⍴parms.screenCSS
                  css←ReadUtf8File MassageFilename parms.(cssURL,'/',screenCSS)
                  css←'<<maxwidth>>'⎕R({' '=1↑0⍴⍵:⍵,(0∊⍴⍵~⎕D)/'px' ⋄ (⍕⍵),'px'}parms.width)⊣css
                  css←2 InsertTocCaption parms css
                  css←{⊂CompressCSS 2↓⊃,/(⎕UCS 13 10)∘,¨⍵}⍣parms.compressCSS⊣css
                  r,←(⊂'<style media="screen">'),css,(⊂'</style>')
              :EndIf
              :If ~0∊⍴parms.printCSS
                  css←ReadUtf8File MassageFilename parms.(cssURL,'/',printCSS)
                  css←1 InsertTocCaption parms css
                  css←{⊂CompressCSS 2↓⊃,/(⎕UCS 13 10)∘,¨⍵}⍣parms.compressCSS⊣css
                  r,←(⊂'<style media="print">'),css,(⊂'</style>')
              :EndIf
          :EndIf
      :EndIf
      r,←'</head>' '<body>',html,'</body>' '</html>'
    ∇

      InsertTocCaption←{
      ⍝ Replace the two occurences of "<<tocCaption>><<showHide>>" in the css against parms.tocCaption and parms.showHide
      ⍝ ⍺ is 1 for print CSS and 2 for screen CSS.
          (parms css)←⍵
          lines←Where∨/¨bool←'<<tocCaption>><<showHide>>'∘⍷¨css
          0∊⍴lines:css
          bool←bool[lines]
          sh←';'Split parms.showHide
          css[lines[1]]←'<<tocCaption>><<showHide>>'⎕R(parms.tocCaption,' (',(1⊃sh),')')⊣css[lines[1]]
          (1=⍺)∨1=⍴,lines:css
          css[lines[2]]←'<<tocCaption>><<showHide>>'⎕R(parms.tocCaption,' (',(2⊃sh),')')⊣css[lines[2]]
          css
      }

    ∇ {report}←{parms}ConvertMarkdownFile filename;ns
    ⍝ Converts the contents of `filename` to HTML5. The output filename equals `filename` except that
    ⍝ the extension changes from `.md` to `.html`.\\
    ⍝ This can be overwritten by specifying a parameter space as left argument (typically created
    ⍝ by calling `CreateParms`) and setting `outputFilename`.\\
    ⍝ Note however that when you specify `inputFilename` to anything but '' or `filename an error is
    ⍝ generated. Other settings in parms are honoured.\\
    ⍝ If no left argument is passed then defaults take place, in particular regarding the CSS.\\
    ⍝ Note that by default `ConvertMarkdownFile` creates a fully-fledged HTML page.\\
    ⍝ The result is either an empty text vector or a vector of text vectors. It may contain warnings or error
    ⍝ messages. It's what is returned by `Init` on `ns.report`.
      :Access Public Shared
      parms←{0=⎕NC ⍵:CreateParms ⋄ ⍎⍵}'parms'
      :If ~0∊⍴parms.inputFilename
      :AndIf parms.inputFilename≢filename
          '"inputFilename" must not be specified'⎕SIGNAL 11
      :EndIf
      parms.inputFilename←##.FilesAndDirs.NormalizePath filename
      parms.createFullHtmlPage←(1+¯1≡parms.createFullHtmlPage)⊃parms.createFullHtmlPage 1
      :If 0∊⍴parms.outputFilename
          parms.outputFilename←##.FilesAndDirs.NormalizePath∊(¯1↓⎕NPARTS filename),'.html'
      :EndIf
      ns←Init parms''
      ns←Process ns
      :If parms.createFullHtmlPage
          ns.html←ns.parms MakeHTML_Doc ns.html
      :EndIf
      WriteUtf8File parms.outputFilename ns.html
      report←ns.report
    ∇

    ∇ r←CreateParms;clp;SetTo
    ⍝ Returns a parameter namespace with default values.
    ⍝ Use method `∆List` to list all names and their values.
      :Access Public Shared
      r←⎕NS''
      clp←GetCommandLineParms''
      SetTo←{0=clp.⎕NC ⍺:⍎'r.',⍺,'←⍵' ⋄ ⍎'r.',⍺,'←clp.⍎⍺'}  ⍝ Take command line parms or default
      'bookmarkLink'SetTo 6
      'bookmarkMayStartWithDigit'SetTo 1
      r.debug←IsDevelopment
      'charset'SetTo'utf-8'
      'checkFootnotes'SetTo r.debug
      'checkLinks'SetTo r.debug
      'collapsibleTOC'SetTo 0
      'compileFunctions'SetTo 1
      'compressCSS'SetTo 1
      'createFullHtmlPage'SetTo ¯1
      'cssURL'SetTo ¯1
      'enforceEdge'SetTo 1
      'footnotesCaption'SetTo'Footnotes'
      'head'SetTo''
      'homeFolder'SetTo ¯1
      'showHide'SetTo'Show;Hide'
      'ignoreEmbeddedParms'SetTo 0
      'inputFilename'SetTo''
      'lang'SetTo'en'
      'linkToCSS'SetTo 0
      'markdownStrict'SetTo 0
      'numberHeaders'SetTo 0
      'noCSS'SetTo 0
      'outputFilename'SetTo''
      'printCSS'SetTo'MarkAPL_print.css'
      'reportLinks'SetTo 0
      'reportLinksCaption'SetTo'Link report'
      'screenCSS'SetTo'MarkAPL_screen.css'
      'subTocs'SetTo 1
      'title'SetTo ¯1
      'toc'SetTo 0
      'tocCaption'SetTo'Table of contents'
      'verbose'SetTo r.debug
      'width'SetTo 900
      r.⎕FX'r←∆List;⎕IO' '⍝ List all variables and possible references in this namespace' '⎕IO←1' 'r←{⍵,[1.5]⍎¨⍵}⎕NL-2 9'
    ∇

    ∇ parms←CreateHelpParms
      :Access Public Shared
      parms←CreateParms
      parms.linkToCSS←0
      parms.toc←2 3
      parms.numberHeaders←2 3 4 5 6
      parms.bookmarkLink←6
      parms.compileFunctions←0
      parms.viewInBrowser←1
      parms.collapsibleTOC←1
      parms.compressCSS←1
      parms.title←'MarkAPL Reference'
      parms.width←1100
      parms.reportLinks←1
    ∇

    ∇ ns←Process ns
    ⍝ Takes a namespace, typically created by calling `Init`, and then processes `ns.markdown`,
    ⍝ creating ns.html along the way.
    ⍝
    ⍝ The result is all MarkDown converted to HTML but not a fully-fledged HTML document. In order to
    ⍝ achieve that call `MakeHTML_Doc` in the next step.
      :Access Public Shared
      ns.noOf←1               ⍝ Minimum number of lines to be removed from ns.(markdown leadingChars emptyLines) per cycle.
      ns←ScanMarkdown ns
      ns.toc←CollectToc ns
      ns←SetTitle ns
      ns←NumberHeaders ns
      ns←InjectTOC ns
      ns←InjectSubTOCs ns
      ns←ReplaceLinkIDs ns
      ns←ReportLinks ns
      ns←InjectFootNotes ns
      ns←HandleAbbreviations ns
      ns←CheckInternalLinks ns
      ns←CheckForInvalidFootnotes ns
      :If IsDevelopment
      :AndIf ns.parms.verbose
      :AndIf ~0∊⍴ns.report
          ⎕←⍪ns.report
      :EndIf
      ns.html←{1=≡⍵:⍵ ⋄ ⊃,/⊃⍵}¨ns.html
    ∇

    ∇ ns←Init(parms markdown);buffer
    ⍝ Creates a namespace "ns" that contains important stuff needed to process `markdown`.
    ⍝ See "MarkAPL.html" for details.
      :Access Public Shared
      :If 0∊⍴parms
          parms←CreateParms
      :EndIf
      parms←EstablishDefaultHomeFolder parms
      :If ¯1≡parms.cssURL
          parms.cssURL←parms.homeFolder
      :EndIf
      {}CompileMarkAPL parms
      :If 0∊⍴markdown
          'Neither "markdown" nor "inputFilename" are set?!'⎕SIGNAL 6/⍨0∊⍴parms.inputFilename
          markdown←ReadUtf8File parms.inputFilename
      :EndIf
      'Invalid Markdown (depth)'⎕SIGNAL 11/⍨2≠|≡markdown
      markdown←,¨markdown
      'Invalid Markdown (depth)'⎕SIGNAL 11/⍨(,1)≢∪≡¨markdown
      markdown←'\t'⎕R(4⍴' ')⍠('Mode' 'M')⊣markdown  ⍝ Replace all <TAB> chars by 4 spaces
      parms.(inputFilename outputFilename cssURL screenCSS printCSS)←CorrectSlash¨parms.(inputFilename outputFilename cssURL screenCSS printCSS)
      ns←Create_NS ⍬
      markdown←RemoveAllComments markdown
      ns.markdown←(Nest markdown),⊂''
      ns.markdown←{0=+/b←(⎕UCS 0)=w←⍵:w ⋄ (b/w)←⎕UCS 65533}¨ns.markdown ⍝ Replace U+0000 by U+FFFD for secutity reasons
      ns.markdownLC←Lowercase ns.markdown           ⍝ We need this often, so we do this ONCE
      buffer←dlb ns.markdown
      ns.emptyLines←WhatAreEmptyLines buffer
      ns.leadingChars←(16⌊⍴∘,¨ns.markdown)↑¨buffer
      ns.lineNumbers←⍳⍴ns.leadingChars              ⍝ Useful for reporting problems
      ns.withoutBlanks←ns.markdown~¨' '
      ns.abbreviations←0 2⍴''
      ns.linkRefs←⍬
      ns.data←⍬
      ns.(subToc toc)←⊂''
      ns.parms←parms
      ns←ProcessAllDataDefsDefiningMarkAPLParms⍣(~parms.ignoreEmbeddedParms)⊣ns
      :If (,0)≢,parms.toc
          parms.bookmarkLink⌈←⌈/parms.toc
      :EndIf
      parms.head←Nest parms.head
    ∇

    ∇ r←Execute y
    ⍝ This is used for test purposes only.
      :Access Public Shared
      'Invalid call'⎕SIGNAL 11/⍨~IsDevelopment
      :If 0=⎕NC'ns'
          ⎕SHADOW'ns'
          ns←Create_NS ⍬
      :EndIf
      r←⍎y
    ∇

    ∇ {ns}←{parms}Reference recompileFlag
    ⍝ Displays the file MarkAPL.html with your default browser.
    ⍝
    ⍝ `recompileFlag`:
    ⍝ - A zero shows the file as it stands.
    ⍝ - A 1 lets MarkAPL recompile it from MarkAPL.md first.
    ⍝ Returns either `⍬` or the `ns` namespace created by `Init` and modified by `Process`.
      :Access Public Shared
      parms←{0<⎕NC ⍵:⍎⍵ ⋄ CreateHelpParms}'parms'
      ns←CompileHelp'MarkAPL.html'recompileFlag parms
      :If ¯1≠×recompileFlag  ⍝ This syntax is used only by the `Make` workspace and test cases, therefore it is not documented.
      :AndIf parms.viewInBrowser
          GoToWebPage'file://',ns.parms.outputFilename
      :EndIf
    ∇

    ∇ {ns}←{parms}Help recompileFlag
    ⍝ Displays the file MarkAPL_CheatSheet.html with your default browser.
    ⍝
    ⍝ `recompileFlag`:
    ⍝ - A zero shows the file as it stands.
    ⍝ - A 1 lets MarkAPL recompile it from MarkAPL_CheatSheet.md first.
    ⍝ Returns either `⍬` or the `ns` namespace created by `Init` and modified by `Process`.
      :Access Public Shared
      parms←{0<⎕NC ⍵:⍎⍵ ⋄ CreateHelpParms}'parms'
      ns←CompileHelp'MarkAPL_CheatSheet.html'recompileFlag parms
      :If ¯1≠×recompileFlag  ⍝ This syntax is used only by the `Make` workspace and test cases, therefore it is not documented.
      :AndIf parms.viewInBrowser
          GoToWebPage'file://',ns.parms.outputFilename
      :EndIf
    ∇

    ∇ r←{colHeader}Matrix2MarkdownTable mat;b;⎕IO;dt;mask;noOfColumns
      :Access Public Shared
    ⍝ Converts an APL matrix into Markdown.\\
    ⍝ Since the Markdown is created automatically we value space & performance more than readability.\\
    ⍝ Without a left argument the right argument transforms into a matrix without
    ⍝ column headers. If a column is strictly numeric it is right-aligned.\\
    ⍝ If a left argument is provided then it is expected to be a vector of text vectors
    ⍝ defining column headers.\\
    ⍝ Such column headers may define column alignment via a leading and/or a trailing `:`; that means
    ⍝ that when using this method you cannot have a trailing `:` in a column header.\\
    ⍝ In case no column headers are specified or the column headers don't define alignment then columns
    ⍝ that contain nothing but numeric data are by default right-aligned while all other columns
    ⍝ are left-aligned.\\
    ⍝ This method does not allow special attributes, although they may be added in a seperate
    ⍝ step of course.
      'Invalid right argument - not a matrix'⎕SIGNAL 11/⍨2≠⍴⍴r←mat
      :If 0<=/b←,∨/¨'|'∊¨r                          ⍝ Any "|" anywhere?!
          (b/,r)←EscapePipeSymbolInCell¨b/,r
      :EndIf
      dt←0=⊃¨0⍴¨r                                   ⍝ Data type
      :If 0=⎕NC'colHeader'                          ⍝ If no left argument...
          colHeader←,[0.5](':-' '-:')[1+∧⌿dt]       ⍝ ... then we right-align numeric cols.
      :Else
          'Left argument: length error'⎕SIGNAL 6/⍨(⍴colHeader)≠2⊃⍴mat
          'Left argument: depth error'⎕SIGNAL 11/⍨2≠≡colHeader
          colHeader←⍉↑(∧⌿dt)BuildColumnHeader¨colHeader
      :EndIf
      r←colHeader⍪r
      dt←((⍴colHeader)⍴0)⍪dt
      ((,dt)/,r)←⍕¨(,dt)/,r                         ⍝ Format numeric cells only
      r←'|',¨r                                      ⍝ Insert the "|" for cell recognition
      noOfColumns←2⊃⍴r
      r←↓r
      r←noOfColumns{⎕ML←3 ⋄ (1<⍺)↓¨∊¨⍵}r
    ∇

    ∇ md←Matrix2MarkdownList mat;i;type
      :Access Public Shared
    ⍝ Converts an APL matrix in to list definition(s).\\
    ⍝ The matrix must have three columns:\\
    ⍝ 1. List type. 0=bulleted list, 1 etc numeric list **and** starting point.
    ⍝ 2. Nesting level. May start with either 0 or 1.
    ⍝ 3. Text vector of vector of text vector.
      'Invalid right argument - not a matrix'⎕SIGNAL 11/⍨2≠⍴⍴mat
      'Invalid right argument - must have 2 columns'⎕SIGNAL 11/⍨3≠2⊃⍴mat
      'First line''s level must be either 0 or 1'⎕SIGNAL 11/⍨~(⊃mat)∊0 1
      'Invalid right argument - must have 2 columns'⎕SIGNAL 11/⍨~∧/mat[;1]∊0,⍳999
      mat[;2]←{⍵-1}⍣(1=⊃mat[;2])⊣mat[;2]        ⍝ Ensure 0 is first level
      md←mat[;2]⍴¨' '
      type←0=mat[;1]
      (type/md)←(type/md),¨⊂'* '
      type←~type
      (type/md)←(type/md),¨(⍕¨type/mat[;1]),¨⊂'. '
      md←⊃,/md{(≡⍵)∊0 1:⊂⍺,⍵ ⋄ (⊂⍺,⊃⍵),(⊂(⍴⍺)⍴' '),¨1↓⍵}¨mat[;3]
      md←'' '',md,'' ''
     ⍝Done
    ∇

    ∇ css←CompressCSS css;start;end;mask;bool;flag;b1;b2;b
      :Access Public Shared
     ⍝ Takes CSS and compresses it to a single line.
     ⍝ Along the way it...
     ⍝ * removes all comments
     ⍝ * removes any spaces around `;:{}`
     ⍝ * replaces <TAB> chars by spaces
     ⍝ * removes multiple spaces
     ⍝
     ⍝ Note that this method can have desastrous results when performed on non-valid CSS!\\
     ⍝ Throws an error in case something is not right with the CSS.
      css←{(1↓⊃,/(⎕UCS 13),¨⍵)}⍣(1≠≡css)⊣css
      start←'/*'⍷css
      end←'*/'⍷css
      mask←~{⍵∨≠\⍵}css='"'
      'Cannot compress CSS: number of occurrences of /* and */ are different'⎕SIGNAL 11/⍨0=≡/+/¨mask∘/¨start end
      'Cannot compress CSS: Invalid nested comments'⎕SIGNAL 11/⍨~0∊⍴(∪⊃-/+\¨start end)~0 1
      start∧←mask
      end∧←mask
      bool←~{⍵∨≠\⍵}start∨end
      bool[1+Where end]←0
      css←bool/css
      css←dmb css~⎕TC
      ((css=⎕UCS 9)/css)←' '
      mask←~{⍵∨≠\⍵}css='"'
      b1←mask\mask/⊃∨/' :' ' ;' ' {' ' }'⍷¨⊂css
      b2←mask\mask/⊃∨/': ' '; ' '{ ' '} '⍷¨⊂css
      b←~b1∨0,¯1↓b2
      css←b/css
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝                                                                                                           ⍝
⍝                                                   Private stuff                                           ⍝
⍝                                                                                                           ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

      EscapePipeSymbolInCell←{
    ⍝ ⍵ is a cell from any APL matrix.
    ⍝ We convert any | to \| (escaping) except when it lives within code
          c←⍵
          mask←~GetMaskForCode c     ⍝ We must ignore code
          0=+/mask:c                 ⍝ Everything is code? Done!
          b←'|'=mask/c               ⍝ Where are the | when we ignore the code?
          0=+/b:c                    ⍝ None?! Done!
          buff←mask/c                ⍝ Get what's not code
          (b/buff)←⊂'\|'             ⍝ Replace all | by \|
          (mask/c)←buff              ⍝ Put stuff back
          ⊃,/c                       ⍝ Simplify
      }

      BuildColumnHeader←{
          ⍺←0 ⍝ Default data type is 0 (Char)
          dt←⍺
          ~':'∊(1↑⍵),¯1↑⍵:⍵((-dt)⌽':','-')
          '::'≡2↑¯1⌽⍵:(1↓¯1↓⍵)':-:'
          ':'=⊃¯1⌽⍵:(¯1↓⍵)'-:'
          ':'=⊃⍵:(1↓⍵)'-:'
          ':-'
      }

    ∇ r←ProcessLists ns;noOf
      r←0
      :If 3 IsHtmlList⊃ns.markdown
          r←ProcessList ns
      :EndIf
    ∇

    ∇ r←ProcessDefinitionLists ns;noOf;bool;bl;html;nop;not2;buff;bl2;total;el;not;sa;colons
      r←0
      :If 1<⍴ns.markdown                                ⍝ A definitions has at least two lines
      :AndIf 1≤ScanForPara ns                           ⍝ Exactly one line for a term but there might be no empty line after it.
      :AndIf ~0∊⍴'^\s{0,3}:\s'⎕S 0⊣⊃(+/∧\1↓ns.emptyLines)↓1↓ns.markdown  ⍝ Is there ": " in the first non-empty line?
          noOf←(1 1⍷ns.emptyLines)⍳1                    ⍝ Maximum number of lines until the last `:` of this definition list
          colons←': '∘≡¨2↑¨noOf↑ns.leadingChars         ⍝ Where are any leading colons followed by a space?
          total←0
      :AndIf 0<+/colons                                 ⍝ Any at all? If not it's not a definition list!
          bl←noOf↑ns.markdown                           ⍝ The whole lot
          sa←GetSpecialAttributes⊃bl
          (⊃bl)←sa DropSpecialAttributes⊃bl
          html←⊂'<dl',({0∊⍴⍵:'>' ⋄ sa,'>'}sa)
          el←{0=⊃¨⍴¨⍵}bl~¨' '                           ⍝ Empty lines
          :Repeat
              :If 1<⍴bl
              :AndIf ~0∊⍴∊1↓bl
              :AndIf ~0∊⍴'^\s{0,3}:\s'⎕S 0⊣{⍵⊃⍨1⍳⍨0<⊃¨⍴¨⍵}1↓bl
                  buff←'dt'∘Tag¨ns ProcessInlineMarkUp¨1↑bl
                  not←1++/∧\1↓el
                  (bl colons el)←not↓¨bl colons el
              :AndIf 0∊el
              ⍝ Now we pick up everything that fulfills one of the following conditions:
              ⍝ * Starts with a ": "
              ⍝ * Starts with two spaces (plus any leading spaces before the ":")
              ⍝ * Is an empty line
                  nop←+/∧\el∨colons∨{⊃(' '=¯1↓⍵)∧' '≠¯1↑⍵}¨(3++/∧\' '=⊃bl)↑¨bl
              :AndIf 0<⍴bl2←nop↑bl
                  (bl colons el)←(⍴bl2)↓¨bl colons el
              :AndIf ~0∊⍴bl2←(0<⊃¨⍴¨bl2~¨' ')/bl2
                  bl2{v←⍺ ⋄ 0∊⍴⍵:v ⋄ ((¯1+⊃⍵)⊃v)←dmb((¯1+⊃⍵)⊃v),' ',(⊃⍵)⊃v ⋄ ((⊃⍵)⊃v)←'' ⋄ v ∇ 1↓⍵}←⌽Where':'≠⊃¨dlb¨bl2
                  bl2←(0<⊃∘⍴¨bl2)/bl2
                  bl2←{⍵↓⍨1+⍵⍳':'}¨bl2
                  bl2←ns ProcessInlineMarkUp¨bl2
                  :If 1=not
                  :AndIf 1=⍴bl2
                      bl2←⊂'dd'Tag⊃bl2
                  :Else
                      bl2←'dd'∘Tag¨Tag¨bl2
                  :EndIf
                  html,←buff,bl2
                  total+←not+nop
              :Else
                  bl←''
              :EndIf
          :Until 0∊⍴bl
          ns.noOf←total
          html,←⊂'</dl>'
          r←1
          ns.html,←html
          ns←Drop ns
      :EndIf
    ∇

    ∇ r←ProcessBlockQuotes ns;parms;md;ns2
    ⍝ Processes any blockquotes recursively. That way they dan contain **everything**, including blockquotes.
      r←0
      :If '> '≡2↑⊃ns.leadingChars
          ns.noOf←ScanForBlockQuotes ns
          parms←CreateParms
          parms.bookmarkLink←0
          parms.markdownStrict←ns.parms.markdownStrict
          parms.verbose←0
          parms.checkLinks←0
          parms.checkFootnotes←0
          parms.subTocs←0
          md←ns.noOf↑ns.markdown
          (1⊃md)←2↓1⊃md
          (1↓md)←(2×'> '∘≡¨2↑¨1↓md)↓¨1↓md
          ns2←Init parms md
          ns2←Process ns2
          ns.html,←(⊂'<blockquote>'),ns2.html,⊂'</blockquote>'
          ns.report,←(⊃ns.lineNumbers)PolishLineNumbersInReport ns2.report
          ns←Drop ns
          r←1
      :EndIf
    ∇

    ∇ r←ProcessList ns;bl;type;i;startAt;item;pFlag;noOfBlanks;levels;levelChange;buff;sa;lastType;lastItem;toBeAdded;indentations;html;lastWasEmpty;indendations;cb;drop;para;Max;buff2
    ⍝ Processing lists is more complex than one would think at first glance for several reasons:
    ⍝ * Lists can be nested at any level.
    ⍝ * A nested list can have a different type.
    ⍝ * Changing the bullet char for bulleted lists (+-*) starts a new list!
    ⍝ * Lists may contain independent paragrahs; their level is defined by indenting.
    ⍝ * MarkAPL allows lazy indenting: if a list items spans over several lines only the first
    ⍝   line must be indented properly. All other lines may or may not be indented.
    ⍝ * A single backslash at the end of an item are interpreted as "inject <br/> here". So is
    ⍝   the insertion of `<<br>>` anywhere in the code but `<<br>>` is actually handled at a later stage.
    ⍝      {0=#.⎕NC ⍵: ⋄ #.STOP:.}'STOP'
      :If 0=ns.noOf←IdentifyListItems ns
          r←0
      :Else
          type←,(1+(⊃⊃ns.leadingChars)∊'*+-')⌷'ou'
          bl←dtb GetListBlock ns.noOf↑ns.markdown
          :If type='u'
              html←,⊂'<ul>'
          :Else
              startAt←{⍵↑⍨¯1+⌊/⍵⍳'.)'}dlb⊃bl
              html←,⊂'<ol start="',startAt,'">'
          :EndIf
          i←lastWasEmpty←levelChange←0
    ⍝ `levels` and `indentation` record almost the same thing:
    ⍝ * `level` counts white-space until the first non-white-space character.
    ⍝ * `indentation` does the same but then adds the length of the list-marker.
    ⍝ The latter is needed in order to identify the level of paragraphs and code blocks within a list.
          levels←+/∧\' '=⊃bl
          indendations←GetLengthOfLeadingWhitespacePlusListMarker⊃bl
          lastType←⊃dlb⊃bl
          :Repeat
              drop←1
              i←i+1
              :If IsHtmlList dlb⊃bl
                  noOfBlanks←+/∧\' '=⊃bl
                  :If noOfBlanks≠¯1↑levels
                      :If noOfBlanks>¯1↑levels
                          type,←(1+(⊃i⊃ns.leadingChars)∊'*+-')⌷'ou'
                          ((⍴html)⊃html)←'</li>'{⍵↓⍨(-⍴⍺)×⍺≡(-⍴⍺)↑⍵}(⍴html)⊃html
                          :If 'u'=¯1↑type
                              html,←⊂'<ul>'
                          :Else
                              startAt←{⍵↑⍨¯1+⌊/⍵⍳'.)'}dlb⊃bl
                              html,←⊂'<ol start="',startAt,'">'
                          :EndIf
                          levels,←noOfBlanks
                          indendations,←GetLengthOfLeadingWhitespacePlusListMarker⊃bl
                          lastType,←⊃dlb⊃bl
                      :Else
                          levelChange←+/∧\(⌽levels)>noOfBlanks
                          html,←({'</',(¯1↑⍵),'l>'}¨⌽(-levelChange)↑type),¨⊂'</li>'
                          (levels indendations lastType type)←(-levelChange)↓¨levels indendations lastType type
                      :EndIf
                  :ElseIf ~0∊⍴⊃bl
                  :AndIf (¯1↑lastType){~⍺∊'+-*':~⍵∊⎕D ⋄ ⍺≠⍵}⊃dlb⊃bl
                      html,←⊂'</',(¯1↑type),'l>'
                      ((⍴type)⊃type)←(1+(⊃i⊃ns.leadingChars)∊'*+-')⌷'ou'
                      lastType,←⊃dlb⊃bl
                      :If 'u'=¯1↑type
                          html,←⊂'<ul>'
                      :Else
                          startAt←{⍵↑⍨¯1+⍵⍳'.'}dlb⊃bl
                          html,←⊂'<ol start="',startAt,'">'
                      :EndIf
                  :EndIf
              :EndIf
              :If 0∊⍴' '~⍨⊃bl
                  lastWasEmpty←1
              :Else
                  :If IsHtmlList dlb⊃bl
                      (drop item)←CollectItem bl
                      :If ~0∊⍴sa←GetSpecialAttributes⊃bl
                          item←dlb dtb sa DropSpecialAttributes item
                          :If (⊂3↑(⍴html)⊃html)∊'<ul' '<ol'
                              ((⍴html)⊃html)←(¯1↓((⍴html)⊃html)),sa,'>'
                          :EndIf
                      :Else
                          item←dlb dtb item
                      :EndIf
                      i←i+drop-1
                      item←ns CheckOddNumberOfDoubleQuotes item'list item'
                      :If '\'=¯1↑item
                          item,←'<br/>'
                      :EndIf
                      buff←⊃¯1↑html
                      :If ~(⊂{' '~⍨{⍵↑⍨⌊/⍵⍳' >'}{⌽⍵↑⍨⍵⍳'<'}⌽⍵}buff)∊'</ul>' '</ol>' '</li>' '<ul' '<ol' '<ul>' '<ol>'
                          (¯1↑html)←⊂buff,'</li>'
                      :EndIf
                      html,←⊂'<li>',(dlb ns ProcessInlineMarkUp{dlb ⍵↓⍨⍵⍳' '},item),'</li>'
                      lastWasEmpty←0
                  :Else
                      noOfBlanks←+/∧\' '=⊃bl
                      :If (¯1↑indendations){0=⍵:0 ⋄ ⍵≠⍺}noOfBlanks          ⍝ The level has changed
                          :If noOfBlanks∊indendations                       ⍝ Did the user get the indentation right?
                              levelChange←¯1+(⌽indendations)⍳noOfBlanks
                          :Else                                             ⍝ No he did not.
                              levelChange←0⌈¯1++/indendations<noOfBlanks    ⍝ Let's get as close as possible
                          :EndIf
                          :If 0≠levelChange
                              :If '>'=¯1↑buff←⊃¯1↑html
                              :AndIf ~(⊂{⌽⍵↑⍨⍵⍳'<'}⌽buff)∊'</ul>' '</ol>' '<ul>' '<ol>'
⍝                                  (¯1↑html)←⊂buff,'</li>'
                              :EndIf
                              html,←({'</',⍵,'l>'}¨(-levelChange)↑type),¨⊂'</li>'
                              (type levels indendations lastType)←(-levelChange)↓¨type levels indendations lastType
                          :EndIf
                      :EndIf
                      :If lastWasEmpty
                          buff←⊃bl
                          :If {((⊂3↑⍵~' ')∊'~~~' '```')∧∨/(⊂∪⍵)≡¨,¨'~`'}{⍵↑⍨¯1+⍵⍳'{'}' '~⍨⊃bl ⍝ Is it a code block?!
                              cb←(2⍳⍨+\({⍵↑⍨3⌊⍴⍵}¨bl~¨' ')∊'~~~' '```')↑bl  ⍝ Seems to be a code block
                              sa←GetSpecialAttributes⊃cb
                          :AndIf (+/∧\' '=⊃cb)≥⊃noOfBlanks                  ⍝ Max number of spaces is the indentation
                              cb←MassageCodeBlock cb noOfBlanks
                              cb←¯1↓1↓cb
                              :If 0<+/⊃¨⍴¨cb~¨' '
                                  buff2←⊃¯1↑html
                                  :If '</li>'{⍺≡(-⍴⍺)↑⍵}buff2
                                      buff2←(-⍴'</li>')↓buff2
                                      (¯1↑html)←⊂buff2
                                  :EndIf
                                  html,←(MarkUpAsCode(2 EscapeSpecialChars¨cb)sa)
                                  (¯1↑html)←⊂(⊃¯1↑html),'</li>'
                              :EndIf
                              drop←2+⍴cb
                              i+←1+⍴cb
                          :Else
                              (drop para)←CollectItemPara bl
                              i←i+drop-1
                              sa←GetSpecialAttributes para
                              para←dtb sa DropSpecialAttributes para
                              buff←⊃¯1↑html
                              :If '</li>'≡({{⌽⍵↑⍨⍵⍳'<'}⌽⍵}buff)
                                  buff←(-⍴'</li>')↓buff
                                  (¯1↑html)←⊂buff
                              :EndIf
                              html,←⊂'<p',sa,'>',(dlb ns ProcessInlineMarkUp para),'</p></li>'
                          :EndIf
                      :EndIf
                      lastWasEmpty←0
                  :EndIf
              :EndIf
              bl←drop↓bl
          :Until 0∊⍴bl
          html,←({'</',(¯1↑⍵),'l>'}¨⌽type),¨((¯1+⍴type)⍴⊂'</li>'),⊂''
          html←InjectBR¨html
          ns.html,←html
          ns←Drop ns
          r←1
      :EndIf
    ∇

      GetLengthOfLeadingWhitespacePlusListMarker←{
        ⍝ 9 ← ∇ '  123)   List item'
        ⍝ 0 ← ∇ 'List item'
          ⊃'^\s*?\b\d{1,9}\b[.)]\s+' '^\s*?[-*+]{1}\s+'⎕S 1⊢⍵
      }

      ProcessHorizontalRulers←{
          ns←⍵
          3<+/∧\' '=⊃ns.markdown:0              ⍝ Zero to a maximum of three leading white space characters are allowed.
          sa←GetSpecialAttributes⊃ns.markdown
          0=+/∧/¨(⊂sa DropSpecialAttributes' '~⍨⊃ns.leadingChars)='*-_':0
          line←dlb⊃ns.markdown
          line←sa DropSpecialAttributes line
          3>line+.=⊃line:0
          ~0∊⍴line~' ',⊃line:0
          ns.html,←⊂'<hr',sa,'>'
          ns←Drop ns
          1
      }

    ∇ r←ProcessTable ns;b;max
      r←0
      :If IsTableRow⊃ns.markdown
          max←+/∧\∨/'|'=↑ns.withoutBlanks
          ns.noOf←+/∧\IsTableRow¨max↑ns.markdown
          :If 1<ns.noOf
          :AndIf ∨/{∧/'-'='|: '~⍨⍵}¨2↑ns.markdown
              r←ProcessTable_ ns
          :Else
              r←ProcessTableWithoutColTitles ns
          :EndIf
      :EndIf
    ∇

    ∇ r←ProcessTable_ ns;specialAttrs;ind;align;drop;cells;rows;b;head;noOfCols
      :Trap (~ns.parms.debug)/0
          specialAttrs←GetSpecialAttributes⊃ns.markdown
          ns.html,←⊂{0∊⍴⍵:'<table>' ⋄ '<table',⍵,'>'}specialAttrs
          :If {∧/'-'='|: '~⍨⍵}2⊃ns.markdown
              ns.html,←⊂'<thead>'
              ns.html,←⊂'<tr>'
              ind←{~':'∊⍵:1 ⋄ '::'≡2⍴¯1⌽⍵:3 ⋄ ':'=1⍴⍵:2 ⋄ 4}¨' '~¨⍨SplitTableRowButMaskCode 2⊃ns.markdown
              align←↑¨ind⌷¨⊂'?' 'left' 'center' 'right'
              head←SplitTableRowButMaskCode specialAttrs DropSpecialAttributes 1⊃ns.markdown
              head←ns{⍺ CheckOddNumberOfDoubleQuotes ⍵'header'}¨head
              head←ns ProcessInlineMarkUp¨head
              :If ~ns.parms.markdownStrict
                  head←ns.parms.lang∘SmartQuotes¨head
              :EndIf
              drop←2
          :Else
              ind←{~':'∊⍵:1 ⋄ '::'≡2⍴¯1⌽⍵:3 ⋄ ':'=1⍴⍵:2 ⋄ 4}¨' '~¨⍨SplitTableRowButMaskCode 1⊃ns.markdown
              align←↑¨ind⌷¨⊂'?' 'left' 'center' 'right'
              drop←1
          :EndIf
          :If ~0∊⍴cells←drop↓ns.noOf↑ns.markdown
              cells←SplitTableRowButMaskCode¨drop↓ns.noOf↑ns.markdown
              cells←{dlb∘dtb ⍵}¨¨cells
              cells←ns{⍺ CheckOddNumberOfDoubleQuotes ⍵'header'}¨¨cells
              cells←ns ProcessInlineMarkUp¨¨cells
              :If ∨/b←∨/¨'?'=align
                  noOfCols←⌈/(⍴align),⊃∘⍴¨cells
                  b←noOfCols↑b
                  :If (⍴align)>noOfCols
                      cells←cells,¨((⍴align)-noOfCols)⍴(⊃⌈/⍴¨cells)⍴⊂,' '
                  :ElseIf (⍴align)<noOfCols
                      align←noOfCols↑align,noOfCols⍴⊂'left'
                  :EndIf
                  :If noOfCols∨.≠⊃∘⍴¨cells
                      cells←noOfCols↑¨cells,¨noOfCols⍴¨⊂,' '
                  :EndIf
                  (b/align)←('left' 'right')[{{0∊⍴⍵~' ':1 ⋄ 1+⊃∧\⊃⎕VFI ⍵}⊃,/' ',¨⍵}¨↓⍉↑b∘/¨cells]
              :EndIf
          :Else
              :If ∨/b←∨/¨'?'=align
                  (b/align)←⊂'left'
              :EndIf
          :EndIf

          :If 2=drop
              ns.html,←('th'∘{⍺,⍵}¨1 AddAlignStyle¨align)Tag¨(⍴align)↑head,(⍴align)⍴⊂''
              ns.html,←⊂'</tr>'
              ns.html,←⊂'</thead>'
          :EndIf
          ns.html,←⊂'<tbody>'

          rows←{('td'∘{⍺,⍵}¨2 AddAlignStyle¨align)Tag¨⍵}¨(⍴align)↑¨cells
          ns.html,←⊃,/{(⊂'<tr>'),⍵,⊂'</tr>'}¨rows
          ns.html,←⊂'</tbody>'
          ns.html,←⊂'</table>'
          ns←Drop ns
          r←1
      :Else
          r←1
          ns←Drop ns
      :EndTrap
    ∇

      ProcessTableWithoutColTitles←{
          ns←⍵
          specialAttrs←GetSpecialAttributes⊃ns.markdown
          ns.html,←⊂{0∊⍴⍵:'<table>' ⋄ '<table',⍵,'>'}specialAttrs
          ns.html,←⊂'<tbody>'
          cells←SplitTableRowButMaskCode¨{(⊂specialAttrs DropSpecialAttributes⊃⍵),1↓⍵}ns.noOf↑ns.markdown
          cells←{dlb∘dtb ⍵}¨¨cells
          cells←ns{⍺ CheckOddNumberOfDoubleQuotes ⍵'header'}¨¨cells
          cells←ns ProcessInlineMarkUp¨¨cells
          align←('left' 'right')[1+{∧/⊃⎕VFI∊' ',¨⍵}¨↓⍉↑cells]
          rows←{('td'∘{⍺,⍵}¨AddAlignStyle¨align)Tag¨⍵}¨(⊃⌈/⍴¨cells)↑¨cells
          ns.html,←⊃,/{(⊂'<tr>'),⍵,⊂'</tr>'}¨rows
          ns.html,←⊂'</tbody>'
          ns.html,←⊂'</table>'
          ns←Drop ns
          1
      }

      ProcessHeaders←{
          ns←⍵
          '#'=1⍴⊃ns.markdown:ProcessATX_Header ns
          ~0∊⍴' {0,3}\[#{1,6} [~_*a-zA-Z0-9].*] *\(.+\)'⎕S 0⍠('Greedy' 0)⊣1⍴ns.markdown:ProcessATX_HeaderLink ns
          ProcessSetextHeader ns
      }

    ∇ flag←ProcessATX_Header ns;l;txt;sa;c;c2;bookmarkName;anchor
      flag←0
      l←+/∧\'#'=1⊃ns.leadingChars                   ⍝ Level
      'Invalid header level'⎕SIGNAL 11/⍨~l∊⍳6
      txt←1⊃ns.markdown
      :If 4>+/∧\' '=txt                             ⍝ A maximum of three spaces is allowed
      :AndIf ' '=⊃txt~'#'                           ⍝ The first char after the # must be a blank
          sa←GetSpecialAttributes⊃ns.markdown
          txt←sa DropSpecialAttributes txt
          c←{⍵↓⍨-+/∧\(⌽⍵)∊'# '}{⍵↓⍨+/∧\⍵∊'# '}txt   ⍝ Caption. Delete leading and trailing blanks in the process
          c←ns CheckOddNumberOfDoubleQuotes c'header'
          c2←ns ProcessInlineMarkUp c
          bookmarkName←ns GetBookMarkNameFromCaption txt((l≤ns.parms.bookmarkLink)/sa)
          anchor←AddBookmarkLink l ns bookmarkName
          ns.html,←{⊂⍣(~0∊⍴⍵)⊣⍵}anchor
          ns.html,←⊂'<h',(⍕l),(RemoveIdFromSpecialAttributes⍣(~0∊⍴anchor)⊣sa),'>',c2,'</h',(⍕l),'>'
          ns.html,←((,0)≢,ns.parms.bookmarkLink)/⊂'</a>'
          ns.headers⍪←l bookmarkName c2
          ns.noOf←1
          ns←Drop ns
          flag←1
      :EndIf
    ∇

    ∇ flag←ProcessATX_HeaderLink ns;row;sa;header
      ⍝ This should only happen when an HTML document that was created by MarkAPL is converted back into Markdown.
      ⍝ We try to limit the damage here but we don't create a link, and such headers are going into a TOC.
      flag←0
      row←⊃ns.markdown
      sa←GetSpecialAttributes ¯1↓dtb row
      :If ∨/' class="autoheader_anchor" '⍷' ',sa,' '
          header←{⍵↑⍨¯1+⍵⍳']'}↑{⍵↓⍨⍵⍳'['}row
          sa←'class="autoheader_anchor"'⎕R''⊣sa
          sa←dmb'id=".*"'⎕R''⊣sa
          header←dlb dtb header,sa
          (1⊃ns.markdown)←header
          (1⊃ns.markdownLC)←Lowercase header
          (1⊃ns.leadingChars)←(16⌊⍴header)↑header
          (1⊃ns.withoutBlanks)←' '~⍨1⊃ns.withoutBlanks
          flag←ProcessATX_Header ns
      :EndIf
    ∇

    ∇ flag←ProcessSetextHeader ns;noOf;ind;sa;l;c;c2;anchor;bookmarkName
      flag←0
      noOf←ScanForPara ns                           ⍝ Because only what qualifies as paragraph can be an ATX header
      :If noOf≠0
          ind←noOf+Where∊'-='IotaSetextHeader¨⊂(1+noOf)⌷¨ns.(withoutBlanks markdown emptyLines)
      :AndIf ~0∊⍴ind                             ⍝ It's not a Setext header
          ind←⊃ind
          sa←GetSpecialAttributes⊃ns.markdown
          l←1+'-'=⊃ind⊃ns.leadingChars
          c←CompilePara noOf↑ns.markdown
          c←sa DropSpecialAttributes c
          ns.noOf←1+noOf
          c2←ns ProcessInlineMarkUp c
          c←ns CheckOddNumberOfDoubleQuotes c'header'
          bookmarkName←ns GetBookMarkNameFromCaption c2((l≤ns.parms.bookmarkLink)/sa)
          anchor←AddBookmarkLink l ns bookmarkName
          ns.html,←{⊂⍣(~0∊⍴⍵)⊣⍵}anchor
          ns.html,←⊂'<h',(⍕l),(RemoveIdFromSpecialAttributes⍣(~0∊⍴anchor)⊣sa),'>',c2,'</h',(⍕l),'>'
          ns.html,←((,0)≢,ns.parms.bookmarkLink)/⊂'</a>'
          ns.headers⍪←l bookmarkName c2
          ns←Drop ns
          flag←1
      :EndIf
    ∇

    ∇ r←RemoveLampLines ns
      r←0
      :If '⍝'=⊃⊃ns.markdown
          ns←Drop ns
          r←1
      :EndIf
    ∇

    ∇ r←ProcessCodeBlock ns;bl;buff;sa;pattern
    ⍝ Handles code block, either "~~~" (Markdown2 Extra) or "```" (Git).
      r←0
      :If 1=⍴'^\s{0,3}[~|`]{3,}\s{0,}({.*?})?\s{0,}$'⎕S 0⊣⊃ns.markdown
          pattern←('`~'[1+'~'∊⊃ns.markdown]),'{3,}'
      :AndIf ¯1≢ns.noOf←pattern FindFenceEnd 1↓ns.markdown
          :If 2<ns.noOf
              bl←1↓¯1↓ns.noOf↑ns.markdown
              sa←GetSpecialAttributes⊃ns.markdown
              :If 0<+/⊃¨⍴¨bl~¨' '
                  bl←((+/∧\' '=⊃ns.markdown)⌊+/∧\' '=↑bl)↓¨bl   ⍝ Drop as many blanks as there are indendet blanks
                  ns.html,←MarkUpAsCode(2 EscapeSpecialChars¨bl)sa
              :EndIf
              ns.noOf←2+⍴bl
          :ElseIf 2≠ns.noOf
          :OrIf ~0∊⍴(⊃ns.markdown)~'~` '
              ns.noOf←0
              :Return
          :EndIf
          r←1
          ns←Drop ns
      :EndIf
    ∇

      Drop←{
          ns←⍵
          ns.(markdown markdownLC leadingChars emptyLines withoutBlanks lineNumbers)←ns.noOf↓¨ns.(markdown markdownLC leadingChars emptyLines withoutBlanks lineNumbers)
          ns.noOf←1
          ns
      }

    ∇ html←ns ProcessFunctionCalls html;mask;ind;noOf;call;result;flag1;flag2
      mask←~GetMaskForCodeTags html
      :If ~0∊⍴ind←'[^⍎]⍎⍎[^⍎]'⎕S 0⊣' ',(mask/html),' '  ⍝ Two blanks for the ≠ to fit start and end. The first one also fixes ⎕io
      :AndIf ~0∊⍴ind←(2×⌊0.5×⍴ind)↑ind
          :Repeat
              html←(⊃ind)⌽html
              noOf←-/ind[2 1]
              call←dlb dtb 1↓(noOf-1)↑1↓html
              html←(2+noOf)↓html
              :If 0∊⍴result←ns ExecExternalFns call
                  :Return
              :EndIf
              flag1←⊃~ns.parms.markdownStrict
              flag2←FunctionCallResultIsHtmlBlock result
              :If 1=≡result
                  result←,ns ProcessInlineMarkUp⍣(flag1∧~flag2)⊣result
              :Else
                  'Embeded function returned invalid result'⎕SIGNAL 11/⍨(,1)≢∪≡¨,¨result
                  :If flag1∧~flag2
                      result←Nest result
                      result←,ns ProcessInlineMarkUp¨result
                  :EndIf
              :EndIf
              'Called function returned an HTML block but does not stand on its own'⎕SIGNAL 11/⍨flag2∧0≠⍴html
              :If 0∊⍴html
                  html←(-ind[1])⌽result,html
              :Else
                  html←(-ind[1])⌽(⊃⍣(1<≡html)⊣result),html
              :EndIf
          :Until 0∊⍴ind←2↓ind
      :EndIf
    ∇

    ∇ r←FunctionCallResultIsHtmlBlock result
      :If ~0∊⍴'<pre\b[^>]*>'⎕S 0⊣⊃result
      :AndIf '</pre>'{⍺≡(-⍴⍺)↑⍵}⊃¯1↑result
          r←1
      :Else
          :If r←0=+/⊃¨⍴¨2↑¯1⌽result
              r←'<>'≡⊃¨1 ¯1↑¨result[2,¯1+⍴result]
          :EndIf
      :EndIf
    ∇

    ∇ {r}←ProcessParagraph ns;sa;para;hits;tag
      r←⍬
      ns.noOf←ScanForPara ns
      ns.noOf←1⌈ns.noOf
      para←CompilePara ns.noOf↑ns.markdown
      para←ns CheckOddNumberOfDoubleQuotes para'paragraph'
      sa←GetSpecialAttributes para
      para←sa DropSpecialAttributes⍣(0<⊃⍴sa)⊣para
      para←ns ProcessInlineMarkUp para
      :If ~0∊⍴para
          :If '<'=⊃⊃para                                ⍝ Is this...
          :AndIf ~0∊⍴hits←'<[^>].*?>'⎕S 0 1⊣dlb para    ⍝ ... an HTML block?
              hits←⊃hits
          :AndIf 0=⊃hits
              tag←(¯2+hits[2])↑1↓⊃para
          :AndIf ('</',tag,'>')≡(-3+⍴tag)↑(⍴para)⊃para
              ns.html,←Nest para
          :Else
              ns.html,←Nest sa{2=≡⍵:⍺∘∇¨⍵ ⋄ '<p',({0∊⍴⍵:'>' ⋄ ⍵,'>'}⍺),⍵,'</p>'}para
          :EndIf
      :EndIf
      ns←Drop ns
    ∇

    ∇ r←ScanForBlockQuotes ns;ns2;lc;b;max
      r←0
      ns2←⎕NS''
      lc←↑2↑¨ns.leadingChars        ⍝ Leading two chars
      max←¯1+ns.emptyLines⍳1        ⍝ An empty line marks the end
      ns2.(markdown markdownLC leadingChars emptyLines withoutBlanks lineNumbers)←max↑¨ns.(markdown markdownLC leadingChars emptyLines withoutBlanks lineNumbers)
      lc←max↑lc                     ⍝ Leading chars
      :While 0<ns2.noOf←1 ScanForPara ns2
          lc←ns2.noOf↓lc            ⍝ Leading chars
          :If 0∊⍴lc                 ⍝ No blockquotes...
          :OrIf '> '≢lc[1;]         ⍝ any more?
              r+←ns2.noOf
              :Leave                ⍝ No - we are done
          :EndIf
          ns2.noOf+←+/∧\lc∧.='> '   ⍝ Add them
          r+←ns2.noOf
          ns2←Drop ns2
      :EndWhile
    ∇

    ∇ noOf←{dontCheckForBlockQuote}ScanForPara ns;buff;bool
    ⍝ `noOf` : Number of lines, if any), the next paragraph will comprise.
      dontCheckForBlockQuote←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'dontCheckForBlockQuote'
      :If 1≠noOf←+/∧\0=ns.emptyLines                                                          ⍝ How many lines until next empty line?
      :AndIf 1≠noOf←noOf⌊¯1+⊃'='IotaSetextHeader noOf↑¨ns.(withoutBlanks markdown emptyLines) ⍝ Header (= syntax)
      :AndIf 1≠noOf←noOf⌊¯1+⊃'-'IotaSetextHeader noOf↑¨ns.(withoutBlanks markdown emptyLines) ⍝ Header (- syntax)
      :AndIf 1≠noOf←+/∧\~(noOf↑⊃¨ns.leadingChars)∊'|#='                                       ⍝ HTML, header, tables?
      :AndIf 1≠noOf←+/∧\~{⊃⍴'^\s{0,3}[-+\*]\s'⎕S 0⊣⍵}¨noOf↑ns.markdown                        ⍝ bulleted list
      :AndIf 1≠noOf←+/∧\~{⊃⍴'^\s{0,3}[0-9]{1,9}[.)]'⎕S 0⊣⍵}¨noOf↑ns.markdown                  ⍝ Ordered lists?
      :AndIf 1≠noOf←+/∧\~{∨/({⍵⍴⍨3⌊⍴⍵}⍵~' ')∘≡¨'***' '---' '___'}¨noOf↑ns.markdown            ⍝ Horizontal rulers?
      :AndIf 1≠noOf←+/∧\~'```'∘{⍺≡(⍴⍺)↑⍵}¨noOf↑ns.markdown                                    ⍝ Code block (``` syntax)
      :AndIf 1≠noOf←+/∧\~'~~~'∘{⍺≡(⍴⍺)↑⍵}¨noOf↑ns.markdown                                    ⍝ Code block (~~~ syntax)
      :AndIf 1≠noOf←+/∧\'<<subtoc>>'∘≢¨Lowercase noOf↑ns.markdown                             ⍝ Sub TOCs
      :AndIf 1≠noOf←+/∧\{0∊⍴'<pre\b[^>]*>' '<style\b[^>]*>' '<script\b[^>]*>'⎕S 0⊣⍵}¨noOf↑ns.leadingChars               ⍝
      :AndIf ~dontCheckForBlockQuote
          noOf←+/∧\~(noOf↑⊃¨ns.leadingChars)∊'|>#='                                           ⍝ Blockquote (>) MUST be the last check!
      :EndIf
    ∇

    ∇ anchor←AddBookmarkLink(level ns bookmarkName)
      ⍝ Add ID and HREF if that is okay with ns.parms.bookmarkLink
      anchor←''
      :If 0<ns.parms.bookmarkLink
      :AndIf ns.parms.bookmarkLink≥level
          anchor,←' href="#',bookmarkName,'" id="',bookmarkName,'"'
        ⍝ Make sure the class is assigned after ID/Href, otherwise you'll break `CheckInternalLinks`
          anchor,←' class="autoheader_anchor"'
          anchor←'<a',anchor,'>'
      :EndIf
    ∇

      MarkUpAsCode←{
          (code specialAttrs)←⍵
          code←Nest code
          st←'<pre><code',({0∊⍴⍵:⍵ ⋄ ' ',⍵}dmb specialAttrs),'>'    ⍝ Start tag
          (1⊃code)←st,1⊃code
          ((⍴code)⊃code),←'</code></pre>'
          code
      }

    ∇ tx←MarkUpInlineCode tx_;b;s;e;tx2;tx1;tx;ind;even;ind2
      :If 0<+/b←'`'=tx←tx_                  ⍝ We are done if there are no back-ticks
          ind←Where b                       ⍝ All indices
          :If ∨/b←∧\'\'=(' ',tx)[ind]
              ind2←b/ind
              ind←(~b)/ind
          :Else
              ind2←⍬
          :EndIf
      :AndIf 0<⍴ind
          s←⊃ind                            ⍝ First one
          even←(0 1⍴⍨⍴ind)/ind              ⍝ Only these can be closing ones,
          :If 0=e←⊃('`'≠(tx,' ')[even+1])/even   ⍝ Only odd ` with no ` to their right can be a closing back-tick
              e←1+⍴tx
          :EndIf
          tx1←(s-1)⍴tx
          tx2←(e-s-1)↑(⍴tx1)↓tx
          :If ~0∊⍴ind2
              tx1←tx1[(⍳⍴tx1)~ind2-1]
          :EndIf
          tx←e↓tx
          tx2←'<code>',(1↓¯1↓tx2),'</code>'
          tx2←(~'``'⍷tx2)/tx2
          tx←MarkUpInlineCode tx
          tx←tx1,tx2,tx
      :EndIf
    ∇

      Tag←{
          ⍺←'p'
          '<',⍺,'>',⍵,'</',({⍵↑⍨¯1+⍵⍳' '},⍺),'>'
      }

      EscapeSpecialChars←{
      ⍝ ⍵ is typically a line of a Markdown document.
      ⍝ Code is **not** masked here: we need to exchange "<>&" even in code.
      ⍝ See `EscapeSpecialCharsOutsideCode` if you don't want this to happen.
      ⍝ However, don't touch anything between "" inside <> (attribute definitions).
      ⍝ ⍺ may be 1 or 2 and defaults to 1; that means that "<<" remains untouched.
      ⍝ If ⍺ is 2 (typically ⍵ is code then) "<<" is converted, and so is <.
          ⍺←1
          0∊⍴⍵:⍵
          ⍺=1:'(?<!\<)<\<(?!<)' '(?<!\>)>\>(?!>)' '<' '>' '(?<!\\)&'⎕R'&' '&' '\&lt;' '\&gt;' '\&amp;'⊣⍵
          ⍺=2:'<'⎕R'\&lt;'⊣'>'⎕R'\&gt;'⊣'\&'⎕R'&amp;'⊣⍵
          . ⍝ Huuh?! Invalid left argument
      }

      EscapeSpecialCharsOutsideCode←{
      ⍝ ⍵ is typically a line of a Markdown document.
      ⍝ Code is masked here. If you don't want this see `EscapeSpecialChars`
          0∊⍴⍵:⍵
          ((⊂'`.*?`'),,¨'<>&')⎕R'\0' '\&lt;' '\&gt;' '&amp;'⊢⍵
      }

      BringBackSpecialHtmlEntities←{
     ⍝ Bring back the three special HTML entities: &lt; and &gt; and &amp;
     ⍝ Needed in cases processed stuff must be processed again (TOC for example)
          0∊⍴⍵:⍵
          '&amp;'⎕R'\&'⊣'&gt;'⎕R'>'⊣'&lt;'⎕R'<'⊣⍵
      }

    ∇ r←ProcessSubTOC ns;header;level
      r←0
      :If '<<subtoc>>'{⍺≡(⍴⍺)↑⍵}⊃ns.markdownLC
          :If ns.parms.subTocs
              (level header)←{'<h'{⍺≡(⍴⍺)↑⍵}⊃⍵:{({⍎⍵↑⍨¯1+⍵⍳'>'}2↓⍵)({⍵↑⍨¯1+⍵⍳'<'}⍵↓⍨⍵⍳'>')}⊃⍵ ⋄ ∇ 1↓⍵}⌽ns.html
              ns.subToc,←⊂level header
              ns.html,←Lowercase 1↑ns.markdown
          :EndIf
          ns←Drop ns
          r←1
      :EndIf
    ∇

    ∇ ns←InjectSubTOCs ns;where;i;header;level;ind;from;noOf;levels;toc;drop;md;ns2;subToc;parms
      :If ~0∊⍴ns.subToc
          where←Where∨/¨'<<subtoc>>'∘⍷¨Lowercase ns.html
          :For i :In ⍳⍴ns.subToc
              (level header)←i⊃ns.subToc
              ind←i⊃where
              from←1⍳⍨(ns.headers[;1]=level)∧(ns.headers[;3]≡¨⊂header)
              noOf←+/∧\level<from↓ns.headers[;1]
              levels←noOf↑from↓ns.headers[;1]
              toc←↑3↑¨noOf↑from↓ns.toc
              :If (⊃⍴toc)∊0 1
                  ns.html[i⊃where]←⊂''
                  ns.report,←⊂'No SubTOC injected for "',header,'": no items found'
                  :Leave
              :Else
                  :If (,0)≢,ns.parms.numberHeaders
                      toc,←toc{⍵[;4]⌿⍨⍵[;2]∊⍺[;3]}ns.headers
                  :EndIf
                  drop←⌊/toc[;1]
                  :If (,0)≢,ns.parms.numberHeaders
                      md←{(' '⍴⍨(1⊃⍵)-drop),'* [',(4⊃⍵),' ',(2⊃⍵),'](#',(3⊃⍵),')'}¨↓toc
                  :Else
                      md←{(' '⍴⍨(1⊃⍵)-drop),'* [',(2⊃⍵),'](#',(3⊃⍵),')'}¨↓toc
                  :EndIf
                  parms←CreateParms
                  parms.markdownStrict←ns.parms.markdownStrict
                  parms.verbose←0
                  parms.checkLinks←0
                  parms.checkFootnotes←0
                  parms.markdownStrict←1
                  ns2←Init parms md
                  {}ProcessLists ns2
                  :If (,0)≢,ns.parms.numberHeaders
                      ns2.html←'href="#\d{0,}-'⎕R'href="#'⍠('Greedy' 0)⊣ns2.html
                  :EndIf
                  subToc←'<nav>'('<p>Topics:</p>'),ns2.html,⊂'</nav>'
                  ns.html[i⊃where]←⊂subToc
              :EndIf
          :EndFor
          ns.html←⊃,/{1=≡⍵:⊂⍵ ⋄ ⍵}¨ns.html
      :EndIf
    ∇

    ∇ r←ProcessReferenceLinks ns;line;id;url;alt;sa
      r←0
      :If '['=⊃⊃ns.leadingChars
      :AndIf ~0∊⍴'\[[A-Za-z0-9_-]*\]:'⎕S 0⊣⊃ns.markdown      ⍝ Find identifiers
          id←{1↓⍵↑⍨¯2+⍵⍳':'}⊃ns.markdown
          url←dlb dtb{⍵↓⍨⍵⍳':'}⊃ns.markdown
      :AndIf {~'='∊⍵↑⍨⌊/⍵⍳'?{'}url   ⍝ `?` parts URL parameter, `{` parts special attributes. Both may carry `=`!
          sa←GetSpecialAttributes url
          url←dtb sa DropSpecialAttributes url
          :If 2=+/'"'=url
              alt←{¯1↓⍵↓⍨⍵⍳'"'}url
              url←dtb{⍵↑⍨¯1+⍵⍳'"'}url
          :Else
              alt←''
          :EndIf
          ns.linkRefs,←⊂id url alt sa
          ns←Drop ns
          r←1
      :EndIf
    ∇

    ∇ ns←ProcessAllDataDefsDefiningMarkAPLParms ns;mask;buff;bool;noOf;def;i;id;value;b;v
      :If 0<noOf←+/∧\'['=⊃¨ns.leadingChars
          buff←noOf↑ns.markdown
          noOf←'[parm]:'{+/∧\⍺∘≡¨{(Lowercase 5↑¨⍵),¨5↓¨⍵}(⍴⍺)↑¨⍵}buff
          ns.noOf←noOf
          buff←noOf↑buff
          ns←Drop ns
          :For i def :InEach (⍳noOf)buff
              :If '='∊def
                  (id value)←¯1 0↓¨7 0↓¨{i←⍵⍳'=' ⋄ (i↑⍵)(i↓⍵)}def
                  id~←' '
                  value←dlb dtb value
                  :If ''''∊value
                      :If ''''''≡2⍴¯1⌽value
                          value←¯1↓1↓value
                      :Else
                          value←''
                          ns.report,←⊂'Data value definition for line ',(⍕⊃ns.lineNumbers),' is invalid'
                      :EndIf
                  :Else
                      (b v)←⎕VFI value
                      :If ∧/b
                          value←{1=⍴⍵:⍬⍴⍵ ⋄ ⍵}v
                      :EndIf
                  :EndIf
                  ns.embeddedParms⍪←id value
                  ⍎'ns.parms.',id,'←value'
              :Else
                  ns.report,←⊂'Data definition on line ',(⍕i),' is invalid'
              :EndIf
          :EndFor
          :If ∨/b←~ns.embeddedParms[;1]∊CreateHelpParms.∆List[;1]
              11 ⎕SIGNAL⍨'Invalid embbed parameter',((1<+/b)/'s'),': ',⊃{⍺,',',⍵}/'"',¨'"',⍨¨b/ns.embeddedParms[;1]
          :EndIf
      :EndIf
    ∇

    ∇ r←ProcessDataDefs ns;def;value;id;b;v
      r←0
      :If '['=⊃⊃ns.leadingChars
          :If ~0∊⍴Where'[data]:'≡Lowercase 7↑⊃ns.leadingChars      ⍝ Find identifiers
              def←⊃ns.markdown
              :If '='∊def
                  (id value)←¯1 0↓¨7 0↓¨{i←⍵⍳'=' ⋄ (i↑⍵)(i↓⍵)}def
                  value←dlb dtb value
                  :If ''''∊value
                      :If ''''''≡2⍴¯1⌽value
                          value←¯1↓1↓value
                      :Else
                          value←''
                          ns.report,←⊂'Data value definition for line ',(⍕⊃ns.lineNumbers),' is invalid'
                      :EndIf
                  :Else
                      (b v)←⎕VFI value
                      :If ∧/b
                          value←{1=⍴⍵:⍬⍴⍵ ⋄ ⍵}v
                      :EndIf
                  :EndIf
                  ns.data,←⊂id value
              :Else
                  ns.report,←⊂'Data definition on line ',(⍕⊃ns.lineNumbers),' is invalid'
              :EndIf
              ns←Drop ns
              r←1
          :EndIf
      :EndIf
    ∇

    ∇ r←ProcessAbbreviationDefs ns;def;abbr;comment
      r←0
      :If '*['≡2⍴⊃ns.leadingChars
          r←1
          :If ~0∊⍴'\*\[[\p{L} \/\+-_=&]*\]:'⎕S 0⊣⊃ns.markdown      ⍝ Find identifiers
              (abbr comment)←¯1 0↓¨':'Split 2↓⊃ns.markdown
              (abbr comment)←dlb∘dtb¨abbr comment
              ns.abbreviations⍪←abbr comment
          :Else
              ns.report,←⊂'Invalid abbreviation in line ',⍕⊃ns.lineNumbers
          :EndIf
          ns←Drop ns
      :EndIf
    ∇

    ∇ r←ProcessFootnoteDefs ns;b1;noOf;b2;def;id
      r←0
      :If ~0∊⍴'^\[\^[A-Za-z0-9_⍙∆]*\]:'⎕S 0⊣⊃ns.markdown       ⍝ Find identifiers
          noOf←ScanForPara ns
          noOf←1⍳⍨'[^'∘≡¨2↑¨(noOf-1)↑1↓ns.markdown
          b1←'  '∘≡¨2↑¨noOf↓ns.markdown
          b2←noOf↓ns.emptyLines
          ns.noOf←noOf+(+/∧\b1)⌊1⍳⍨1 1⍷b2
          def←dlb{(⊂{'  ',dlb ⍵↓⍨⍵⍳':'}⊃⍵),1↓⍵}ns.noOf↑ns.markdown
      :AndIf ':'=1↑{⍵↓⍨⍵⍳']'}⊃ns.markdown
          id←{⍵↑⍨¯1+⍵⍳']'}2↓⊃ns.markdown
      :AndIf ∧/~AllWhiteSpaceChars∊id
      :AndIf ~0∊⍴def←(-+/∧\0=⌽⊃¨⍴¨def)↓def
      :AndIf ~0∊⍴def←{1↓¨(' '=⊃¨⍵)⊂⍵}' ',def
      :AndIf ~0∊⍴def←CompilePara¨def
      :AndIf ~0∊⍴def←ns ProcessInlineMarkUp¨def
          ns.footnoteDefs⍪←id def
          ns←Drop ns
          r←1
      :EndIf
    ∇

    ∇ r←ProcessEmeddedHTML ns;tags;buff;b;flag
      r←1
      :If '<'=1⍴⊃ns.leadingChars                        ⍝ <pre>, <script>, <style> don't require empty lines around them.
      :OrIf (⊃ns.emptyLines)∧'<'=⊃⊃1↓ns.leadingChars    ⍝ But it MAY have a blank leading line anyway!
          :If {('>'∊⍵)∧∨/'://'⍷⍵↑⍨⍵⍳'>'}⊃(+/∧\ns.emptyLines)↓ns.markdown
              :Return
          :Else
              r←ProcessHtmlBlockType_1 ns
          :EndIf
      :EndIf
      :If r
          :If (⊃ns.emptyLines)∧'<'=⊃⊃1↑1↓ns.leadingChars     ⍝ First char after an empty line must be "<" and ...
          :AndIf 1∊1↓ns.emptyLines                           ⍝ ... an empty line later on.
          ⍝ Okay, it seems to be an HTML block, so let's check.
          ⍝ For details see http://spec.commonmark.org/0.24/#html-blocks
          ⍝ There's more to it then meets the eye at first glance.
              :If r←ProcessHtmlBlockType_2 ns
              :AndIf r←ProcessHtmlBlockType_3 ns
              :AndIf r←ProcessHtmlBlockType_5 ns   ⍝ 5 must be executed ...
              :AndIf r←ProcessHtmlBlockType_4 ns   ⍝ ... before 4!
              :AndIf r←ProcessHtmlBlockType_6 ns
              :AndIf r←ProcessHtmlBlockType_7 ns
              :AndIf ⊃ns.emptyLines
                  ns.noOf←1
                  ns←Drop ns
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←ProcessHtmlBlockType_1 ns;start
    ⍝ <script>, <style> or <pre>.
    ⍝ These are special because the first two can never be nested while the last one
    ⍝ preserves white space by definition.
    ⍝ ← is 0 when found and processed, otherwise 0.
      r←0
      :If '<script\b[^>]*>'DetectOpeningTag(⊃ns.emptyLines)↓ns.markdown
          ns←Drop⍣(⊃ns.emptyLines)⊣ns
          ns.noOf←DetectClosingTag ns.markdownLC'</script>'
          ns.html,←'</script>'DropTailAfterClosingTag ns.noOf↑ns.markdown
          ns←Drop ns
      :ElseIf '<pre\b[^>]*>'DetectOpeningTag(⊃ns.emptyLines)↓ns.markdown
          ns←Drop⍣(⊃ns.emptyLines)⊣ns
          ns.noOf←DetectClosingTag ns.markdownLC'</pre>'
          ns.html,←Process_PRE ns.noOf↑ns.markdown
          ns←Drop ns
      :ElseIf '<style>'DetectOpeningTag(⊃ns.emptyLines)↓ns.markdown
          ns←Drop⍣(⊃ns.emptyLines)⊣ns
          ns.noOf←DetectClosingTag ns.markdownLC'</style>'
          ns.html,←'</style>'DropTailAfterClosingTag ns.noOf↑ns.markdown
          ns←Drop ns
      :Else
          r←1
      :EndIf
    ∇

    ∇ r←ProcessHtmlBlockType_2 ns;start;e;md
    ⍝ <!-- and -->
    ⍝ ← is 0 when found and processed, otherwise 0.
      r←1
      :If 2<⍴ns.markdown
      :AndIf 1∊e←1↓ns.emptyLines
          md←(1+(1↓ns.emptyLines)⍳1)↑ns.markdown
          :If ∨/'<!--'⍷⊃1↓md
              :If ∨/'-->'⍷⊃¯1↑¯1↓md
                  ns.noOf←¯1+⍴md
                  ns.html,←'-->'DropTailAfterClosingTag 1↓ns.noOf↑ns.markdown
                  ns←Drop ns
                  r←0
              :Else
                  ns.noOf←⊃ns.emptyLines
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←ProcessHtmlBlockType_3 ns;start;b;md
    ⍝ <? and ?>
    ⍝ ← is 0 when found and processed, otherwise 0.
      r←1
      :If 2<⍴ns.markdown
      :AndIf ⊃ns.emptyLines
      :AndIf '<?'{⍺≡(⍴⍺)↑⍵}2⊃ns.leadingChars
          :If 0<+/b←1↓ns.emptyLines
              md←(b⍳1)↑ns.markdown
          :AndIf 0<ns.noOf←DetectClosingTagBeforeEmptyLine ns.markdown'?>'
              ns.html,←'?>'DropTailAfterClosingTag 1↓ns.noOf↑ns.markdown
              ns←Drop ns
              r←0
          :EndIf
      :EndIf
    ∇

    ∇ r←ProcessHtmlBlockType_4 ns;start
    ⍝ "<!",⎕A
    ⍝ ← is 0 when found and processed, otherwise 0.
      r←1
      :If 2<⍴ns.markdown
      :AndIf 0∊⍴⊃ns.markdown
      :AndIf '<!'{⍺≡(⍴⍺)↑⍵}2⊃ns.leadingChars
      :AndIf 0<ns.noOf←DetectClosingTagBeforeEmptyLine ns.markdown'!>'
          ns.html,←'!>'DropTailAfterClosingTag 1↓ns.noOf↑ns.markdown
          ns←Drop ns
          r←0
      :EndIf
    ∇

    ∇ r←ProcessHtmlBlockType_5 ns;start
    ⍝ <![CDATA[ and ]]
    ⍝ ← is 0 when found and processed, otherwise 0.
      r←1
      :If 2<⍴ns.markdown
      :AndIf 0∊⍴⊃ns.markdown
      :AndIf '<![CDATA['{⍺≡(⍴⍺)↑⍵}2⊃ns.leadingChars
      :AndIf 0<ns.noOf←DetectClosingTagBeforeEmptyLine ns.markdown']]>'
          ns.html,←']]>'DropTailAfterClosingTag 1↓ns.noOf↑ns.markdown
          ns←Drop ns
          r←0
      :EndIf
    ∇

    ∇ r←ProcessHtmlBlockType_6 ns;start;t;f1;f2;buff;tag
    ⍝ Check for all possible (allowed and block) HTML5 tags.
    ⍝ This is different from others because it may start with a closing tag.
    ⍝ ← is 0 when found and processed, otherwise 0.
      r←1
      :If 1<⍴ns.markdown
      :AndIf ⊃ns.emptyLines
          :If f1←'</'≡2↑2⊃ns.leadingChars
          :OrIf '<'=⊃2⊃ns.leadingChars
              :If 1∊2↓ns.emptyLines             ⍝ Without a closing empty line it cannot be an HTML block
                  buff←dlb(f1+1)↓2⊃ns.markdownLC
                  buff←(buff⍳'>')↑buff          ⍝ Drop all behind the closing ">"
                  :If '/'∊buff
                      tag←⊂buff←buff~'<>/'
                  :Else
                      tag←⊂,(¯1+⌊/buff⍳AllWhiteSpaceChars,'/>')↑buff
                  :EndIf
                ⍝ Most frequently used tags first:
                  :If tag∊,¨'div' 'h1' 'h2' 'h3' 'h4' 'h5' 'h6' 'li' 'ol' 'p' 'table' 'tbody' 'td' 'tfoot' 'th' 'thead' 'tr' 'ul'
                  :OrIf tag∊,¨'address' 'article' 'aside' 'basefont' 'blockquote' 'caption' 'center' 'colgroup' 'col'
                  :OrIf tag∊,¨'dd' 'details' 'dialog' 'dir' 'dl' 'dt' 'fieldset' 'figcaption' 'figure' 'footer' 'form' 'frame'
                  :OrIf tag∊,¨'frameset' 'head' 'header' 'hr' 'html' 'iframe' 'legend' 'link' 'main' 'menu' 'menuitem' 'meta' 'nav'
                  :OrIf tag∊,¨'noframes' 'optgroup' 'option' 'param' 'section' 'source' 'summary' 'title' 'track' 'pre'
                      buff←(⍴↑tag)↓buff
                      :If 0∊⍴buff
                      :OrIf '>'=1⍴buff
                      :OrIf '/>'≡2⍴buff
                      :OrIf (1⍴buff)∊AllWhiteSpaceChars
                          ns.noOf←(1↓ns.emptyLines)⍳1
                          ns.html,←1↓ns.noOf↑ns.markdown        ⍝ Drop first because it is empty
                          ns←Drop ns
                          r←0
                      :EndIf
                  :EndIf
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←ProcessHtmlBlockType_7 ns;start;cl
    ⍝ Free-style (= user defined) tags.
    ⍝ ← is 0 when found and processed, otherwise 0.
      r←1
      :If 1<⍴ns.markdown
      :AndIf ⊃ns.emptyLines
          cl←2⊃ns.markdownLC
          :If ~0∊⍴'<[a-z]*\b[^>]*>' '</[a-z][^>]*>'⎕S 0⊣cl     ⍝ Look for any tag
          :AndIf 0∊⍴'<script\b[^>]*>' '<style\b[^>]*>' '<pre\b[^>]*>'⎕S 0⊣cl
          :AndIf 0∊⍴{⍵↓⍨⍵⍳'>'}(2⊃ns.markdown)~AllWhiteSpaceChars
              ns.noOf←(1↓ns.emptyLines)⍳1
          :AndIf '>'=¯1↑dtb⊃¯1↑1↓ns.noOf↑ns.markdown
              ns.html,←1↓ns.noOf↑ns.markdown
              ns←Drop ns
              r←0
          :EndIf
      :EndIf
    ∇

    ∇ md←Process_PRE md;first;last
      md←,md
      :If 1=⍴,md
          :If 0=⍴'<code\b[^>]*>'⎕S 0⊣⊃md   ⍝ <code> missing?!
              (⊃md)←'(<pre\b[^>]*>)'⎕R'\1<code>'⊣⊃md
          :EndIf
          :If 0=⍴'</code>'⎕S 0⊣⊃md   ⍝ </code> missing?!
              ((⍴md)⊃md)←'(</pre>)'⎕R'</code>\1'⊣(⍴md)⊃md
          :EndIf
      :Else
          (first last)←md[1,⍴md]
          :If 0∊⍴'<code\b[^>]*>'⎕S 0⊣first
          :AndIf 0∊⍴'<code\b[^>]*>'⎕S 0⊣⊃1↓md ⍝ '<cod'{⍺≢(⍴,⍺)↑⍵}⊃1↓md
              first,←'<code>'
          :EndIf
          :If 0=+/'</code'⍷last
          :AndIf '</cod'{⍺≢(⍴,⍺)↑⍵}⊃¯2↑md
              :If 0∊⍴{⍵↓⍨⍵⍳'>'}last
                  last,⍨←'</code>'
              :Else
                  last←'</code>',last
              :EndIf
          :EndIf
          md[1]←⊂first
          md[⍴md]←⊂last
          :If {(⍴⍵)=+/∧\2≥+\⍵='>'}1⊃md  ⍝ Do <pre> and <code> stand on their own?
              md←(,/2↑md),2↓md
          :EndIf
          :If {(⍴⍵)=+/∧\2≥+\⍵='>'}(⍴md)⊃md  ⍝ Do </pre> and </code> stand on their own?
              md←(¯2↓md),,/¯2↑md
          :EndIf
      :EndIf
      md←'</pre>'DropTailAfterClosingTag md
    ∇

      DeleteTrailingWhiteSpace←{
     ⍝ Blanks, Tabs, you name it.
     ⍝ See https://www.wikiwand.com/en/Whitespace_character for details.
          ⎕IO←1 ⋄ ⎕ML←1
          (2=|≡⍵):∇¨⍵
          ws←⎕UCS 9 10 11 12 13 32 133 160
          (1=⍴⍴⍵):⌽{(+/∧\⍵∊ws)↓⍵}⌽⍵
      }

      IsHtmlList←{
    ⍝ Returns a 1 in case ⍵ qualifies as an LI element of a list.
    ⍝ That is the case if one of the following conditions holds true:
          tx←⍵
          ⍺←99                          ⍝ Number of leading blanks allowed.
          ⍺ IsBulletedHtmlList tx:1
          ⍺ IsOrderedHtmlList tx
      }

      IsOrderedHtmlList←{
    ⍝ Returns a 1 in case ⍵ qualifies as an LI element of an ordered list.
    ⍝ ⍺ is the number of leading blanks allowed (for a starting list item this would be 3).
    ⍝ [1] Zero to many white spaces
    ⍝ [2] 1 to 9 digits ...
    ⍝ [3] ... but not more than 9 of them
    ⍝ [4] Either a `.` or a `)`
    ⍝ [5] One or more white spaces
    ⍝ Then it's an ordered list item
          tx←⍵
          0∊⍴'^\s*?\b\d{1,9}\b[.)]\s+?'⎕S 0⊣tx:0
          ⍺>3:1
          3≥+/∧\' '=tx
      }

      IsBulletedHtmlList←{
    ⍝ Returns a 1 in case ⍵ qualifies as an LI element of a bulleted list.
          tx←,⍵
          ~{(⊃dlb ⍵)∊'*+-'}tx:0
          pattern←'^\s{0,',(⍕⍺),'}[-+\*]\s'
          ~0∊⍴pattern ⎕S 0⊣tx
      }

    ∇ r←IdentifyListItems ns;max;buff;ind;b1;b2;b
    ⍝ Takes "ns" as right argument and figures out how many items belong to the current list.
    ⍝ Things are complicated by ...
    ⍝ * the fact that lazyness is allowed.
    ⍝ * lines might be glued together with a trailing `\` or divided by <<br>>.
    ⍝ * Laziness and indentation might be mixed together.
    ⍝ * Lists might be nested.
    ⍝ Note that a single blank line between items is okay; only more than one empty line breaks a list definition.
    ⍝ We know already where two blank lines occur (max).
      r←max←{0=+/⍵:⍴⍵ ⋄ ⍵⍳1}⍨1 1⍷ns.emptyLines      ⍝ Two empty lines stop a list dead in any case
      buff←max↑ns.markdown
      :If ~0∊⍴ind←(Where max↑ns.emptyLines)~max     ⍝ We are interested in the lines after any empty line
          b1←0=+/∧\' '=↑buff[ind+1]                 ⍝ If those are not indented they potentially break the list
          b2←~IsHtmlList¨buff[ind+1]                ⍝ Which ones are not list items as such at all?
          :If 0<+/b←b1∧b2
              r←⊃b/ind
          :EndIf
      :EndIf
    ∇

      IsGlued←{
    ⍝ Takes a vector of vectors and returns a 1 for those lines
    ⍝ that end either with \ of with <<br>>
          b←'\'=⊃¨¯1↑¨⍵
          0,¯1↓b∨'<<br>>'∘{⍺≡(-⍴⍺)↑⍵}¨⍵
      }

      IdentifyBulletedList←{
      ⍝ This uses ns.leadingChars, meaning that it ignores indentation
          ns←⍵
          max←⍺
          IdentifyList__ ns max'*'
      }

      IdentifyOrderedList←{
          ns←⍵
          max←⍺
          IdentifyList__ ns max'1'
      }


      IdentifyList__←{
          (ns max type)←⍵
          nl←0,¯1↓'\'=⊃¨¯1↑¨max↑ns.markdown                                 ⍝ nl flags all lines that...
          nl∨←0,¯1↓(~max↑ns.emptyLines)∧'  '∘≡¨¯2↑¨max↑ns.markdown          ⍝ ... belong to the predecessor...
          nl∨←0,¯1↓'<<br>>'{⍺∘≡¨(-⍴⍺)↑¨⍵}max↑ns.markdown                    ⍝ ... due to line breaks.
          markers←(1+'*'=type)⊃'0123456789 ' '+-* '                         ⍝ "markers" depends on list type.
          max←+/∧\nl∨(⊃¨max↑ns.leadingChars)∊markers                        ⍝
          '*'≡type:+/∧\{(' '=⍵)∨~⊃∘IsOrderedHtmlList¨⍵}⊃¨max↑ns.markdown    ⍝ No mistake: we check for the ...
          '1'≡type:+/∧\{(' '=⍵)∨~⊃∘IsBulletedHtmlList¨⍵}⊃¨max↑ns.leadingChars  ⍝ OTHER list type here!
          .                                                                 ⍝ Huuh?!
      }


    ∇ r←ns ProcessInlineMarkUp tx
      ⍝ Note: sequence matters! Think thrice before changing, and run test cases immediately if you do anyway.
      r←tx
      r←Process_BR r
      r←ProcessAutomaticLinks r
      r←ProcessSpecialHTML_Chars r
      r←ns SmartStuff⍣(⊃~ns.parms.markdownStrict)⊣r
      r←(,¨'<>')⎕R'\&lt;' '\&gt;'⊣r
      r←ProcessImages r
      r←ns.parms.bookmarkMayStartWithDigit ProcessLinks r
      r←ProcessDoubleAsterisks r
      r←ProcessAsterisks r
      r←ProcessDoubleUnderscores r
      r←ProcessUnderscores r
      r←ProcessDoubleTildes r
      r←MarkUpInlineCode r
      r←RemoveEscapeChars r
      r←InjectBR r
      r←InjectPointyBrackets r
      r←ns ProcessFunctionCalls r
    ∇

    ∇ txt←{mask}ProcessAsterisks txt_;noOf;bool;ind;start;end;txt2
    ⍝ Takes a string and marks up everything between * and * as <em>
    ⍝ except when it...
    ⍝ * occurs within a word
    ⍝ * occurs within APL code
    ⍝ * has a white-space char to the right of any opening marker
    ⍝ * has a white-space char to the left of any closing marker
    ⍝ Call this **after** having called ProcessDoubleAsterisks
      txt2←txt←'  ',txt_,'  '
      txt2←'\\\*'⎕R'⌹⌹'⍠('Mode' 'D')⊣txt2
      :If 0<+/bool←(⍳⍴txt)∊2+∊'\s\*[^*|\s]' '[^\s|*]\*[^*]'{⍺ ⎕S 0⍠('Mode' 'D')⊣⍵}¨⊂txt2
      :AndIf 0<+/bool←bool\'\'≠txt[¯1+Where bool]
          mask←GetMaskForCode txt
          bool∧←~mask
      :AndIf ~0∊⍴ind←Where bool
          start←((⍴ind)⍴1 0)/ind
          end←((⍴ind)⍴0 1)/ind
          txt[start]←⊂'<em>'
          txt[end]←⊂'</em>'
          txt←⊃,/txt
      :EndIf
      txt←2↓¯2↓txt
    ∇

    ∇ txt←{mask}ProcessDoubleAsterisks txt_;noOf;bool;ind;start;end
    ⍝ Takes a string and marks up everything between ** and ** as <strong>
    ⍝ except when it occurs within a word or within APL code.
    ⍝ Call this **before** calling ProcessAsterisks.
      txt←'  ',txt_,'  '
      :If 0<+/bool←(⍳⍴txt)∊2+'[^*]\*\*'⎕S 0⍠('Mode' 'D')⊣txt
      :AndIf 0<+/bool←bool∧bool\'*'≠txt[2+Where bool]
      :AndIf 0<+/bool←bool\'\'≠txt[¯1+Where bool]
          mask←GetMaskForCode txt
          bool∧←~mask
      :AndIf ~0∊⍴ind←Where bool
          start←((⍴ind)⍴1 0)/ind
          end←((⍴ind)⍴0 1)/ind
          txt[start]←⊂'<strong>'
          txt[end]←⊂'</strong>'
          txt[1+start,end]←⊂''
          txt←⊃,/txt
      :EndIf
      txt←2↓¯2↓txt
    ∇

    ∇ txt←{mask}ProcessDoubleUnderscores txt_;noOf;bool;ind;start;end
    ⍝ Takes a string and marks up everything between __ and __ as <strong>
    ⍝ except when it occurs within a word or within APL code.
      txt←'  ',txt_,'  '
      :If 0<+/bool←(⍳⍴txt)∊2+'[^_]__[^_]'⎕S 0⊣txt
      :AndIf 0<+/bool←bool\'\'≠txt[¯1+Where bool]
          mask←GetMaskForCode txt
          bool∧←~mask
      :AndIf ~0∊⍴ind←Where bool
      :AndIf ~0∊⍴ind←((txt 2∘NotWithinWord¨ind))/ind
          start←((⍴ind)⍴1 0)/ind
          end←((⍴ind)⍴0 1)/ind
          txt[start]←⊂'<strong>'
          txt[end]←⊂'</strong>'
          txt[1+start,end]←⊂''
          txt←⊃,/txt
      :EndIf
      txt←2↓¯2↓txt
    ∇

    ∇ txt←{mask}ProcessUnderscores txt_;noOf;bool;ind;start;end;txt2;b
    ⍝ Takes a string and marks up everything between _ and _ as <strong>
    ⍝ except when it occurs ...
    ⍝ * within a word.
    ⍝ * within APL code.
    ⍝ * between &amp;pointybracket_open; and &amp;pointybracket_close;
      txt2←txt←'  ',txt_,'  '
      txt2←'\\_'⎕R'⌹⌹'⍠('Mode' 'D')⊣txt2
      :If 0<+/bool←(⍳⍴txt)∊2+'\s_[^_\s]' '[^\s_]_[^_]'⎕S 0⍠('Mode' 'D')⊣txt2
      :AndIf 0<+/bool←bool\'\'≠txt[¯1+Where bool]
          bool∧←~GetMaskForCode txt
          bool∧←~MaskPointyBrackets txt
          bool∧←~MaskTagAttrs txt
      :AndIf ~0∊⍴ind←Where bool
      :AndIf ~0∊⍴ind←((txt 1∘NotWithinWord¨ind))/ind
          start←((⍴ind)⍴1 0)/ind
          end←((⍴ind)⍴0 1)/ind
          txt[start]←⊂'<em>'
          txt[end]←⊂'</em>'
          txt←⊃,/txt
      :EndIf
      txt←2↓¯2↓txt
    ∇

    ∇ txt←ProcessDoubleTildes txt_;noOf;bool;ind;start;end;mask;bool1;bool2
    ⍝ Takes a string and marks up everything between ~~ and ~~ as <del>
    ⍝ except when it occurs within a word or within APL code.
    ⍝ "~~" might also appear as "~~~", and it might be escaped.
      txt←'  ',txt_,'  '
      :If 0<+/bool←'~~'⍷txt
          ind←Where bool
      :AndIf 0<+/bool1←bool∧bool\~txt[¯1+ind]∊'\~'
      :AndIf 0<+/bool2←bool∧bool\~txt[ind+⍴'~~']∊'~\'
      :AndIf 0<+/bool←bool1∧bool2
          mask←GetMaskForCode txt
          bool∧←~mask
      :AndIf ~0∊⍴ind←Where bool
      :AndIf ~0∊⍴ind←((txt 2∘NotWithinWord¨ind))/ind
          start←((⍴ind)⍴1 0)/ind
          end←((⍴ind)⍴0 1)/ind
          txt[start]←⊂'<del>'
          txt[end]←⊂'</del>'
          txt[1+start,end]←⊂''
          txt←⊃,/txt
      :EndIf
      txt←2↓¯2↓txt
    ∇

      ProcessImages←{
          txt←⍵
          mask←~GetMaskForCode txt
          0∊⍴i1←¯1+Where mask∧'!['⍷txt:txt
          i1←⊃i1
          '![CDATA['{⍺≡(⍴⍺)↑⍵}i1↓txt:txt        ⍝ Invalid <![CDATA[ section (probably missing empty lines)
          txt←i1⌽txt
          alt←2↓¯1↓{⍵↑⍨⍵⍳']'}txt
          txt←{⍵↓⍨⍵⍳']'}txt
          buff←1↓¯1↓txt↑⍨0⍳⍨(+\'('=txt)>+\')'=txt
          specialAttributes←GetSpecialAttributes{'{'≠⊃⍵:'' ⋄ {⍵↑⍨⍵⍳'}'}⍵}(2+⍴buff)↓txt
          txt←specialAttributes DropSpecialImageAttributes txt
          title←{dlb ¯1↓dtb{⍵↑⍨⍵⍳'"'}⍵↓⍨⍵⍳'"'}buff
          url←{dlb dtb ⍵↑⍨¯1+⌊/⍵⍳'"{'}buff
          ((url='\')/url)←'/'
          insert←'<img src="',url,'"'
          insert,←specialAttributes
          (title alt)←title{0∊⍴⍺:⊂⍵ ⋄ 0∊⍴⍵:⊂⍺ ⋄ ⍺ ⍵}alt
          insert,←' alt="',alt,'" '
          insert,←(~0∊⍴title)/'title="',title,'" '
          insert,←'/>'
          txt←(-i1)⌽insert,(2+⍴buff)↓txt
          ∇ txt
      }

      Process_BR←{
      ⍝ The extended syntax of MarkAPL allows `<<br>>` in the code which will be
      ⍝ converted to <br/> in two stages: here we replace this by a ⎕UCS 13 (CR).
          txt←⍵
          '`<<br>>`' '<<br>>'⎕R'\0' '\r'⍠('IC' 1)⊣txt
      }

      ProcessAutomaticLinks←{
      ⍝ This must be done early because later any "<" and ">" will be replaced by there HTML entities.
      ⍝ (It was a very bad idea to use this syntax! [](url} is so obvious!)
      ⍝ Therefore we replace "<" and ">" by made-up HTML entities which we replace later by "<" & ">".
      ⍝ Note that this function escapes any of `_`, `__`, `*`, `**`, `~~`.
          txt←⍵
          mask←~GetMaskForCode txt
          0∊⍴i1←¯1+Where'<'=mask\mask/txt:txt
          txt←i1[1]⌽txt
          (⍴txt)<l←txt⍳'>':(-i1[1])⌽txt
          link←¯1↓1↓l↑txt
          sa←GetSpecialAttributes{'{'∊⍵:{⍵↑⍨⍵⍳'}'}{⍵↓⍨¯1+⍵⍳'{'}⍵ ⋄ ⍵}link
          link←{⍵/⍨~Between ⍵∊'{}'}link
          ∨/link∊AllWhiteSpaceChars:⍵                       ⍝ The link text must not contain any white space
          0={(∨/'://'⍷⍵)∨'@'∊⍵}link:⍵                       ⍝ We need to catch URLs and email addresses
          link,⍨←(0={(∨/'://'⍷⍵)∨'@'∊⍵}link)/'http://'
          link←'\_' '\*' '\~\~'⎕R'\\_' '\\*' '\\~\\~'⍠('Greedy' 0)⊣link
          pbo←'&pointybracket_open;'                        ⍝ Later converted ...
          pbc←'&pointybracket_close;'                       ⍝ ... back to < and >.
          class←' class="',((1+'mailto'{⍺≡(⍴⍺)↑⍵}link)⊃'external_link' 'mailto_link'),'"'
          linkText←sa DropSpecialAttributes'mailto:'{⍵↓⍨(⍴⍺)×⍺≡(⍴⍺)↑⍵}1↓¯1↓l↑txt
          linkText←'\_' '\*' '\~\~'⎕R'\\_' '\\*' '\\~\\~'⍠('Greedy' 0)⊣linkText
          txt←(pbo,'a href="',link,'"',class,sa,pbc,linkText,pbo,'/a',pbc),l↓txt
          txt←(-i1[1])⌽txt
          ∇ txt
      }

      ProcessLinks←{
          ⍺←1
          bookmarkMayStartWithDigit←⍺
          txt←⍵
          mask←~GetMaskForCode txt
          0=+/b←']('⍷mask\mask/txt:txt
          i←b⍳1
          on←i-'['⍳⍨⌽i↑mask\mask/txt
          txt←on⌽txt
          mask←on⌽mask
          closeBracket←(mask\mask/txt)⍳']'
          mask←(closeBracket⍴1),{(+\⍵='(')-+\⍵=')'}closeBracket↓txt  ⍝ Careful: a caption might contain ")" when just ⍳')' would not suffice
          off←1++/∧\1=(∧\0=mask)∨mask>0
          linkDef←off↑txt
          linkDef←dmb ReplaceQTC_byBlank linkDef
          sa←GetSpecialAttributes⌽{'{'∊⍵:{⍵↑⍨⍵⍳'{'}{⍵↓⍨¯1+⍵⍳'}'}⍵ ⋄ ''}⌽linkDef
          txt←off↓txt
          linkDef←⌽{'{'∊⍵:')',(⍵↓⍨⍵⍳'{') ⋄ ⍵}⌽linkDef  ⍝ Drop the special attribute
          (url title)←GetUrlAndTitleFromLink linkDef
          poundFlag←⊃'#'=1⍴url
          mask←~GetMaskForCode linkDef
          linkText←dtb(1↓mask){⍵↑⍨¯1+(⍺\⍺/⍵)⍳']'}1↓linkDef
          url←linkText(bookmarkMayStartWithDigit∘CompileBookMarkName{(1<⍴⍵)∧'#'=1↑⍵:'#',⍺⍺ ⍵'' ⋄ (,'#')≡,⍵:'#',⍺⍺ ⍺'' ⋄ ⍵})url
          linkText{0∊⍴⍵:⍺ ⋄ ⍵}←(1+poundFlag)⊃linkText title
          linkText{0∊⍴⍺:⍵ ⋄ ⍺}←url
          linkText←'`.*`' '\_' '\*' '\~\~'⎕R'&' '\\_' '\\*' '\\~\\~'⍠('Greedy' 0)⊣linkText
          tag←'a href="',url,'"'
          tag,←(~poundFlag)/' class="',((1+'mailto'{⍺≡(⍴⍺)↑⍵}url)⊃'external_link' 'mailto_link'),'"'
          tag,←AddBookmarkClassName⍣poundFlag⊣sa
          tag,←((~poundFlag)∧~0∊⍴title)/' title="',title,'"'
          insert←tag Tag linkText
          txt←(-on)⌽insert,txt
          ∇ txt
      }

      AddBookmarkClassName←{
          sa←⍵  ⍝ Special attributes - they MAY contain a user-defined class name
          0=+/'class="'⍷sa:sa,' class="bookmark_link"'
          'class="'⎕R'&bookmark_link '⊣sa
      }

    ∇ r←GetMaskForCode txt;noOf
    ⍝ Returns a mask (vector of Booleans with zeros for all APL code in ⍵.
    ⍝ Does not fall over odd number of ticks.
      :If 0<+/r←'`'=' ',txt
          r[Where r]←'\'≠txt[¯1+Where r]
      :AndIf 0<+/r
          :If 0<noOf←+/r
          :AndIf {⍵≠⌊⍵}noOf÷2
              (¯1↑r)←1
          :EndIf
          r←1↓r∨≠\r
      :Else
          r←(⍴txt)⍴0
      :EndIf
    ∇

      GetMaskForCodeTags←{
    ⍝ Returns a mask for everything between <code*> and </code>.
    ⍝ We can savely assume valid HTML5 here.
          txt←⍵
          r←(⍴txt)⍴0=1
          0=+/b←'</code>'⍷txt:r         ⍝ No closing tag? Done!
          r[(¯1+⍴'</code>')+Where b]←1
          ind←Where'<code'⍷txt
          ind←(txt[ind+⍴'<code']∊'> ')/ind
          r[ind]←1
          Between r
      }

      SplitTableRowButMaskCode←{
      ⍝  'First' 'Second' ←→ SplitTableRowButMaskCode 'First',(⎕UCS 13 10),'Second'
      ⍝ (,¨'1' '2' '3') ←→ '.' SplitTableRowButMaskCode '1.2.3'
      ⍝ But:
      ⍝ 'Code' '`{{⍵/⍨2=+⌿0=⍵∘.|⍵}⍳⍵}`' '' ←→ '|' SplitTableRowButMaskCode '|Code | `{{⍵/⍨2=+⌿0=⍵∘.|⍵}⍳⍵}` |
          ⎕ML←⎕IO←1
          txt←dlb dtb ⍵
          txt←(('|'≠⊃txt)/'|'),txt
          txt,←{'|'/⍨('|'≠2⊃⍵)∧'\|'≢⊃⍵}¯2⌽txt
          mask←~GetMaskForCode txt
          bool←mask\'|'=mask/txt
          bool[1~⍨Where bool]←'\'≠txt[¯1+1~⍨Where bool]
          r←1↓¨¯1↓bool⊂txt
          {0=+/b←'\|'⍷w←⍵:w ⋄ (~b)/w}¨r
      }

      NotWithinWord←{
    ⍝ ⍵ is a vector of hits for, say, `_`
    ⍝ ⍺ is a two-element vector:
    ⍝   [1] Something like a paragraph
    ⍝   [2] Length of markup (_, *, **, __, ~~, ...); 1∨2
    ⍝ Does not recoginze compound names, but they should be between `` anyway!
          (txt length)←⍺
          hit←⍵
          boundaries1←(⊂hit+¯1,length)⌷txt      ⍝ What's to the left and right of the hit
          boundaries2←(⊂hit+¯2,length+1)⌷txt    ⍝ What's to the left and right of boundary1 (for recognizing compound names)
          1 1≢boundaries1∊PartOfNames
      }

    ∇ name←{ns}GetBookMarkNameFromCaption(txt specialAttrs)
    ⍝ Remove all formatting, links, etc.
    ⍝ Remove everything between <>, () and [].
    ⍝ Remove all punctuation except underscores, hyphens, and periods.
    ⍝ Remove all HTML &{word}: entities
    ⍝ Remove all code.
    ⍝ Remove HTML.
    ⍝ Remove leading and trailing spaces.
    ⍝ Replace all remaining spaces with hyphens.
    ⍝ Convert all alphabetic characters to lowercase.
    ⍝ Remove everything up to the first letter or `∆⍙`.
    ⍝ If nothing is left after this, use `section` as identifier.
      ns←{0<⎕NC ⍵:⍎⍵ ⋄ r←⎕NS'' ⋄ r.headers←0 2⍴'' ⋄ r.lineNumbers←0 ⋄ r.report←'' ⋄ r.parms←⎕NS'' ⋄ r.parms.bookmarkMayStartWithDigit←1 ⋄ r}'ns'
      :If 0={0=⍵.⎕NC'parms.bookmarkLink':1 ⋄ ⍵.parms.bookmarkLink}ns
          name←''
      :Else
          name←ns.parms.bookmarkMayStartWithDigit CompileBookMarkName txt specialAttrs
          :If 0∊⍴name                              ⍝ Nothing left?
              name←'section'                       ⍝ Go for the name section
              ns.report,←⊂'Warning: header on line ',(⍕⊃ns.lineNumbers),': no bookmark name left; name assigned'
          :EndIf
          :If (⊂name)∊ns.headers[;2]               ⍝ Does this bookmark already exist?
              name←1{n←⍵,'-',⍕⍺ ⋄ ~(⊂n)∊ns.headers[;2]:n ⋄ (1+⍺)∇ ⍵}name  ⍝ Append a number
              ns.report,←⊂'Warning: header on line ',(⍕⊃ns.lineNumbers),': ambiguous name; number added'
          :EndIf
      :EndIf
    ∇

    ∇ ns←InjectTOC ns;param;levels;b;h;ns2;html;r;tocHtml;drop;parms;links;noOf;buff
    ⍝ Inject a TOC in case the user has specified this
      :If (,0)≢,ns.parms.toc
          :If 1=⍴,ns.parms.toc
              levels←⍳ns.parms.toc
          :Else
              levels←ns.parms.toc
          :EndIf
          :If ~0∊⍴toc←↑((⊃¨ns.toc)∊levels)/ns.toc
              drop←⌊/toc[;1]
              :If (,0)≢,ns.parms.numberHeaders
                  toc,←toc{⍵[;4]⌿⍨⍵[;2]∊⍺[;3]}ns.headers
                  links←ns.parms.bookmarkMayStartWithDigit{⍺ CompileBookMarkName ⍵''}¨toc[;3]
                  tocHtml←ns CreateTOC toc[;1 2 4],links
              :Else
                  links←{(3⊃⍵)≡GetBookMarkNameFromCaption(2⊃⍵)'':3⊃⍵ ⋄ 3⊃⍵}¨↓toc
                  tocHtml←ns CreateTOC(toc[;1 2],(⊂'')),links
              :EndIf
              :If '<a' '<h'≡2↑¨2↑ns.html                        ⍝ First two lines define a header?!
                  noOf←1⍳⍨'</a>'{⍺∘≡¨(⍴⍺)↑¨⍵}ns.html
                  ns.html←(noOf↑ns.html),tocHtml,noOf↓ns.html   ⍝ Insert after the first header
              :Else
                  ns.html←tocHtml,ns.html                       ⍝ Put TOC before anything else
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ ns←ScanMarkdown ns
      :Repeat
          :If ProcessEmeddedHTML ns
              :If ⊃ns.emptyLines
                  ⍝ ns.noOf←+/∧\ns.emptyLines  ⍝ No! Don't do this: it breaks the logic
                  ns←Drop ns
              :Else
                  :If 0=ProcessSubTOC ns
                  :AndIf 0=ProcessFootnoteDefs ns
                  :AndIf 0=ProcessAbbreviationDefs ns
                  :AndIf 0=ProcessDataDefs ns
                  :AndIf 0=ProcessReferenceLinks ns
                  :AndIf 0=ProcessCodeBlock ns
                  :AndIf 0=ProcessHeaders ns
                  :AndIf 0=RemoveLampLines ns
                  :AndIf 0=ProcessBlockQuotes ns
                  :AndIf 0=ProcessTable ns
                  :AndIf 0=ProcessHorizontalRulers ns
                  :AndIf 0=ProcessLists ns
                  :AndIf 0=ProcessDefinitionLists ns
                      ProcessParagraph ns             ⍝ This must be the last one!
                  :EndIf
              :EndIf
          :Else
              :If ⊃ns.emptyLines
              :AndIf '<'≠⊃⊃1↑1↓ns.leadingChars
                  ns.noOf←1
                  ns←Drop ns
              :EndIf
          :EndIf
          ⍎(((⊂2 'footnotes'))∊↓ns.headers[;1 2])/'.'
      :Until 0∊⍴ns.leadingChars
      ns.html←{'&#96;'⎕R'`'⊣⍵}⊣ns.html
    ∇

      IotaSetextHeader←{
      ⍝ Returns indices a vector of Booleans for any line in ns.markdown that in itself would qualify as an setext header.
      ⍝ "In itself" means that it does not check whether what above it is a para. That need to be checked independently.
          type←⍺
          (withoutBlanks markdown emptyLines)←⍵
          0=+/b←(~emptyLines)∧withoutBlanks∧.=¨type:1+⍴markdown
          Where b\{4>+/∧\' '=⍵}¨b/markdown          ⍝ Max 4 leading blanks
      }

      CompilePara←{
          para←⍵
         ⍝0∊⍴para←{'  '≢¯2↑⍵:⍵ ⋄ (¯2↓⍵),⎕UCS 13}¨para:para  ⍝ Since version 1.3 we don't do this anymore
          para←('⍝'≠⊃¨para)/para  ⍝ Get rid of lines that start with a lamp symbol.
          para←{'\'≠¯1↑⍵:⍵ ⋄ (¯1↓⍵),⎕UCS 13}¨para
          dmb(1↓⊃,/' ',¨para)
      }

      IsTableRow←{
      ⍝ ⍵ qualifies as a table row it it contains at least 2 un-escaped pipes (`|`).
          row←,⍵
          mask←~GetMaskForCode row
          0=+/b←'|'=mask/row:0
          ∨/'\'≠(' ',row)[Where b]
      }

      IsFenceStart←{
      ⍝ The start of a code block fence may have an info string after the fence as such. We currently ignore this.
          row←⍵
          fence←⍺
          row2←dlb row
          3≤+/∧\fence=row2
      }

      FindFenceEnd←{
      ⍝ The end of a fence must have at last three ⍺ characters and may have leading and trailing blanks as well
      ⍝ but nothing else, in particular no special attributes.
      ⍝ ⍵ is a vector of mMarkdown vectors.
          ⍺←'[~|`]{3,}' ⍝ The default
          pattern←⍺
          ~0∊⍴noOf←1+('^\s{0,3}',pattern,'\s{0,}$')⎕S 2⍠('Mode' 'L')⊣⍵:1+⊃noOf ⍝ Add the leading one which is not in ⍵
          ¯1
      }

      IsStyleBlockStart←{
          start←⍵
          '<style'{⍺≢(⍴⍺)↑⍵}start:0
          later←(⍴'<style')↓start
          '>'=⊃later:1
          0=⍴later:1
      }

      DetectOpeningTag←{
    ⍝ When this is called we know that the first char of the current line is a `<` character.
    ⍝ ⍺ is something like "<style" (Yes, without the closing >!)
    ⍝ We now need to find out whether it is really an HTML tag.
          md←⍵                                  ⍝ Nested vector with all the Markdown
          tag←⍺
          ~0∊⍴tag ⎕S 0⍠('IC' 1)⊣⊃md
      }

      DetectClosingTag←{
      ⍝ Find the tag
          (md tag)←⍵
          (∨/¨tag∘⍷¨md)⍳1
      }

      DetectClosingTagBeforeEmptyLine←{
      ⍝ Find the tag followed by a blank line
          (md tag)←⍵
          b←(∨/¨tag∘⍷¨md)∧((1↓0=⊃¨⍴¨md)),0
          0=+/b:0
          b⍳1
      }


      DropTailAfterClosingTag←{
          html←⍵
          tag←⍺
          buff←(⍴html)⊃html
          buff←((¯1+⍴tag)+1⍳⍨tag⍷Lowercase buff)↑buff
          ((⍴html)⊃html)←buff
          html
      }

      RemoveHTML←{
      ⍝ 'This contains a tag'←∇ 'This contains a <span>tag'</span>
          txt←⍵
          '<>'{⍵/⍨~Between ⍵∊⍺}txt
      }

      ProcessSpecialHTML_Chars←{
          tx←⍵
          0=+/b←tx∊'&<>':tx
          EscapeSpecialChars tx
      }

      RemoveEscapeChars←{
    ⍝ Remove the "\" (Escape character) from ⍵ except when ...
    ⍝ * there are two of them in a row (one survives)
    ⍝ * they are part of code (survives untouched)
    ⍝ * it appears with an attribute definition like <div attr="\3">
    ⍝ * any character to the right of the `\` is not one of `_*|<~{}(&`
    ⍝ This does not work on, say, "\\\\\\\\\\\\\\\; that why this is no legal.
          tx←⍵
          mask←~GetMaskForCodeTags tx
          mask←mask\{~Between ⍵∊'<>'}mask/tx
          b←'\'=(mask/tx),' '
          ⍝ We try to be smart: only those are to be escaped anyway, so nothing else is touched
          specialChars←'_*|<~`{}(&'
          b∧←b\((mask/tx),' ')[1+Where b]∊specialChars
          b←¯1↓b∧b\'\'≠((mask/tx),' ')[1+Where b]
          b∨←'\\'⍷mask/tx
          ((~mask)∨mask\~b)/tx
      }

    ∇ ns←HandleAbbreviations ns;html;abbr;comment;match2;match1;tag1;tag2;b
      :If ~0∊⍴ns.abbreviations
          html←ns.html
          :For abbr comment :In ↓ns.abbreviations
              :If 0=ns.parms.markdownStrict
                  comment←EscapeSpecialChars comment
                  comment←ns SmartStuff comment
                  comment←'&'⎕R'\\&'⊣comment         ⍝ & is a reserved character (Dyalog, not PCRE!)
              :EndIf
              tag1←'<abbr title="',comment,'">\&ldquo;',abbr,'\&rdquo;</abbr>'
              tag2←'<abbr title="',comment,'">',abbr,'</abbr>'
              match2←{0=+/b←'&'=w←⍵:w ⋄ (b/w)←⊂'&amp;' ⋄ ⊃,/w}abbr
              match1←'"',match2,'"'
              html←'<code>.*?</code>'match1 match2 ⎕R'\0'tag1 tag2⍠('Mode' 'D')('DotAll' 1)⊣html
          :EndFor
          ns.html←html
      :EndIf
    ∇

      InjectFootNotes←{
          ns←⍵
          0∊⍴hits←GatherFootNoteReferences ns:ns
          ns←ReplaceFootnoteReferences ns hits
          AppendFootnoteDefinitions ns
      }

    ∇ ns←ReplaceLinkIDs ns;mask;linkRefs
    ⍝ Replace the [{any link text}][link id] references in the HTML against the real thing: <a href="...
      :If ~0∊⍴ns.linkRefs
      :AndIf 0<+/mask←∨/¨~GetMaskForCodeTags¨ns.html
      :AndIf ~0∊⍴∊linkRefs←GetAllLinkRefs mask/ns.html
          ns ReplaceLinkID¨linkRefs
      :EndIf
    ∇

      ReportLinks←{
      ⍝ Injects a list with all external references together with a remark.
      ⍝ The resulting table is assigned the class "print_only" for obvious reasons.
          ns←⍵
          1≠ns.parms.reportLinks:ns
          html←FlattenHTML ns.html
          hits←'<a[^>]+class="external_link".*</a>'⎕S 0 1⍠('Greedy' 0)('Mode' 'D')⊣html
          0∊⍴hits:ns
          anchors←(-⍴'</a>')↓¨hits{⍺[2]↑⍺[1]⌽⍵}¨⊂html
          urls←'href="'∘{{⍵↑⍨¯1+⍵⍳'"'}⍵↓⍨(¯1+⍴⍺)+1⍳⍨⍺⍷⍵}¨anchors
          b←(urls⍳urls)=⍳⍴urls  ⍝ For dropping doubles
          (anchors urls)←b∘/¨anchors urls
          linkTexts←{1↓⊃⍵⊂⍨'>'=⍵}¨anchors
          md←urls{⍺≡⍵:'* ',⍺ ⋄ '* ',⍺,':<<br>>',⍵}¨linkTexts
          md←'' '---' ''('**',ns.parms.reportLinksCaption,'**')'',md,''
          ns2←Init''md
          ns2←Process ns2
          ns.html,←(⊂'<div id="external_link_report" class="print_only">'),ns2.html,(⊂'</div>')
          ns
      }

    ∇ hits←GatherFootNoteReferences ns;i;id;footnote;mask;bool;row;ind
    ⍝ Finds all the references to footnotes in the HTML
    ⍝ `hits` is a matrix with 4 columns:
    ⍝ [;1] Number
    ⍝ [;2] Original name
    ⍝ [;3] Row in ns.html where a hit was found
    ⍝ [;4] Index of the hit in that row.
      hits←0 4⍴⍬
      :For i id footnote :In ↓(⍳⊃⍴ns.footnoteDefs),ns.footnoteDefs
          mask←{~Between⊃∨/'<code>' '</code>'⍷¨⊂⍵}¨ns.html
          :If 0<+/∊bool←('[^',id,']')∘⍷¨mask/¨ns.html
              :For row :In Where∨/¨bool
                  ind←1⍳⍨('[^',id,']')⍷row⊃ns.html                                      ⍝ Only the first one is taken into account
                  :If ~0∊⍴ind←(~ind∊Where GetMaskForCodeTags row⊃ns.html)/ind  ⍝ Remove those between <code tags
                      hits⍪←i,(⊂id),row,ind
                  :EndIf
              :EndFor
          :EndIf
      :EndFor
      hits←{⍵[⍒⍵[;3];]}{⍵[⍒⍵[;4];]}hits   ⍝ It's essential to turn them around!
    ∇

    ∇ ns←ReplaceFootnoteReferences(ns hits);i;ind;row;id;newID
    ⍝ Replaces the original footnote references (which have arbitrary names)
    ⍝ against ones which are strictly numbered from 1 to whatever.
      :For i :In ⍳⊃⍴hits
          (id row ind)←hits[i;1 3 4]
          newID←'<a id="fnref',(⍕id),'" href="#fn',(⍕id),'" class="footnote_link"><sup>',(⍕id),'</sup></a>]'
          (row⊃ns.html)←(-ind)⌽newID,{⍵↓⍨⍵⍳']'}ind⌽row⊃ns.html
      :EndFor
    ∇

    ∇ ns←AppendFootnoteDefinitions ns;i;footnote;html
      html←''
      html,←⊂'<div id="footnotes_div">'
      html,←⊂'<hr>'
      html,←⊂'<p><strong>',ns.parms.footnotesCaption,'</strong></p>'
      html,←⊂'<ol>'
      :For i footnote :InEach {(⍳⍴⍵)⍵}ns.footnoteDefs[;2]
          footnote←': '⎕R':<br />'⊣footnote
          html,←⊂'<li id="fn',(⍕i),'">',(⊃,/Tag¨footnote),'<a href="#fnref',(⍕i),'" class="footnote_anchor"></a>'
      :EndFor
      html,←'</ol>' '</div>'
      ns.html,←html
    ∇

      InjectBR←{
    ⍝ In the original Markdown spec two blanks at the end of a line translate into a <br/>
    ⍝ which is bad because the two blanks are invisible to the user. However, we still support this.
    ⍝ Earlier on those two blank have been translated into a `⎕UCS 13` (CR), and now its time to
    ⍝ replace every CR against a "<br/>" tag:
          tx←⍵
          0=+/b←tx=⎕UCS 13:tx
          '\r'⎕R'<br/>'⍠'Mode' 'D'⊣tx
      }

      HandleEscapedNewLines←{
          items←⍵
          0=+/b←'\'=⊃¨¯1↑¨items:items
          ind←Where b
          items[ind]←{(¯1↓⍵),⎕UCS 13}¨items[ind]
          items
      }

      SmartStuff←{
          ns←⍺
          buff←SmartTypography ⍵
          ns.parms.lang SmartQuotes buff
      }

      SmartTypography←{
    ⍝ Does all the smart stuff except double + single quote handling; see SmartQuotes for that.
    ⍝ This function does not check ns.markdownStrict: that's up to the caller.
          html←⍵
          cb←'(^ {0,3}[~`]{3,}).*\1'                                ⍝ Code blocks (anything between `~~~` and three back ticks.
          bbt←'`[^`].*?`'       ⍝ Between back-ticks (= code)
          html←cb bbt'---'⎕R'\0' '\0' '—'⍠('Mode' 'D')('DotAll' 1)⊣html     ⍝ em dash
          html←cb bbt'--'⎕R'\0' '\0' '–'⍠('Mode' 'D')('DotAll' 1)⊣html      ⍝ en dash
          html←cb bbt'\.\.\.'⎕R'\0' '\0' '…'⍠('Mode' 'D')('DotAll' 1)⊣html  ⍝ Ellipses
          html←cb bbt'<<'⎕R'\0' '\0' '«'⍠('Mode' 'D')('DotAll' 1)⊣html      ⍝ Chevron
          html←cb bbt'>>'⎕R'\0' '\0' '»'⍠('Mode' 'D')('DotAll' 1)⊣html      ⍝ Chevron
          cb bbt'\B\(c\)\B' '\B\(tm\)\B'⎕R'\0' '\0' '©' '™'⊣html            ⍝ Copyright and Trademark
      }

      SmartQuotes←{
    ⍝ Exchange pairs of double quotes ←→ “„ but in DE, AT and CH ←→ „“.
    ⍝ See also SmartTypography for similar stuff.
    ⍝ This function does not check ns.markdownStrict: that's up to the caller.
          ⍺←'en'                            ⍝ Default language is English.
          lang←⍺
          html←⍵
          bbt←'`[^`].*?`'                   ⍝ Between back-ticks (= code)
          cdq←'"".+?""'                     ⍝ Catch what is enclosed between two pairs (that is four of them!) of double quotes
          cim←'!\[[^\)].*?\){.*?}'          ⍝ Catch image with special attributes
          cl1←'\[\]\([^)]*.?\)'             ⍝ Catch simple link
          cl2←'\[[^]]*.?\]\([^)]*.?\)'      ⍝ Catch simple link
          ced←'\\"'                         ⍝ Catch escaped double quote
          cpb←'&amp;pointybracket_open([^&]*.?)&amp;pointybracket_close' ⍝ Catch pointy brackets
          me←'\0'
          quotes1←'"(.*?)"'
          quotes2←(1+(⊂lang)∊'de' 'at' 'ch')⊃'“\1”' '„\1“'
          cpb cl1 cl2 cim bbt cdq ced quotes1 ⎕R((6⍴⊂me),'"'quotes2)⍠('Mode' 'D')('DotAll' 1)⊣html
      }

      NumberHeaders←{
          ns←⍵
          (,0)≡,ns.parms.numberHeaders:ns
          ns←CalculateHeaderNumbers ns
          InjectNumberedHeaders ns
      }

      SetTitle←{
          ns←⍵
          ¯1≢ns.parms.title:ns
          1≠ns.headers[;1]+.=1:ns⊣ns.parms.title←'MarkAPL'
          ns.parms.title←{⊃⍵[⍵[;1]⍳1;3]}ns.headers
          ns
      }

      Create_NS←{
          ns←⎕NS''
          ns.markdown←''
          ns.emptyLines←⍬
          ns.leadingChars←''
          ns.lineNumbers←⍬                              ⍝ Useful for reporting problems
          ns.report←''                                  ⍝ That's how MarkAPL tells about potential problem.
          ns.withoutBlanks←⍬
          ns.footnoteDefs←0 2⍴''
          ns.headers←0 3⍴''                             ⍝ Level, bookmark, caption
          ns.html←''                                    ⍝ Our result
          ns.embeddedParms←0 2⍴''
          ns
      }

    ∇ {ns}←InjectNumberedHeaders ns;html;no;header;new;level;searchFor;ind;length;levelsToBeNumbered
      :If ~0∊⍴ns.headers  ⍝ Are their any headers at all?
          levelsToBeNumbered←{1≠⍴,⍵:⍵ ⋄ ⍳⍵}ns.parms.numberHeaders
      :AndIf ∨/levelsToBeNumbered∊ns.headers[;1] ⍝ Right levels?!
          html←FlattenHTML ns.html
          :For level header no :In ↓ns.headers[;1 3 4]
              :If level∊levelsToBeNumbered
                  searchFor←'>',header,'</h',(⍕level),'>'
                  ind←1⍳⍨searchFor⍷html
                  length←{¯1+⍵⍳'<'}{m←~GetMaskForCodeTags ⍵ ⋄ m\m/⍵}ind↓html
                  new←no,' ',header
                  html←(-ind)⌽new,length↓ind⌽html
              :EndIf
          :EndFor
          ns.html←(⎕UCS 13)Split html
      :EndIf
    ∇

    ∇ ns←CalculateHeaderNumbers ns;nos;current;level;lastLevel;i;bool;headers
      current←6⍴0
      bool←ns.headers[;1]∊{1=⍴,⍵:⍳⍵ ⋄ ⍵}ns.parms.numberHeaders
      :If ~0∊⍴headers←bool⌿ns.headers
          headers[;1]-←(⊃headers)-1
          nos←(⊃⍴headers)⍴0
          lastLevel←1
          :For i :In ⍳⊃⍴headers
              level←headers[i;1]
              :If lastLevel>level
                  (level↓current)←0
              :EndIf
              current[level]+←1
              nos[i]←⊂level↑current
              lastLevel←level
          :EndFor
          ns.headers,←⊂''
          (bool⌿ns.headers)[;4]←{⊃,/(⍕¨⍵),¨'.'}¨nos
      :EndIf
    ∇

      GetSpecialAttributes←{
      ⍝ Checks whether ⍵ (a single line of Markdown) carries a "special attributes" definition.
      ⍝ If so it returns a vector of definitions.
      ⍝ Example:
      ⍝ 'id="foo" class="cl1 cl2" attr1="A B C" attr2=123' ←→ ∇ '{#foo .cl1 .cl2 attr1="A B C" attr2=123}'
      ⍝  'style="color=red;font-family='APL385 Unicode'"' ←→ ∇ 'style="color:red;font-family:'APL385 Unicode'"
          md←dtb ⍵
          ('!['≡2⍴md)∧0=+/'<<br>>'⍷md:''  ⍝ Might be a stand-alone image!
          '}'≠¯1↑md:''
          '\'=1↑¯2↑md:'' ⍝ Escaped?
          ~'{'∊md:''
          0∊⍴def←dmb{¯1↓1↓⌽⍵↑⍨⍵⍳'{'}⌽md:''
          mask←~Between'"'=def
          defs←1↓¨(1,mask\' '=mask/def)⊂' ',def
          0∊'='∊¨{⍵/⍨~(⊃¨⍵)∊'.#'}defs:''
          0∨.≠2|'"'+.=¨defs:''
          sp←⎕NS''          ⍝ Result space
          sp.r←''           ⍝ Collects the result(s)
          b←'.'=⊃¨defs      ⍝ All class definitions (if any)
          sp{0∊⍴⍵:⍺ ⋄ ⍺ CompileClassNames ⍵}←b/defs
          b←'#'=⊃¨defs      ⍝ An id definitions (if any)
          1<+/b:'Invalid special attribute: more than one "id"'⎕SIGNAL 11
          sp{0∊⍴⍵:⍺ ⋄ ⍺ CompileID_Names ⍵}←(b⍳1)⊃defs,⊂''
          b←~(⊃¨defs)∊'#.'  ⍝ Any attribute defs
          sp{0∊⍴⍵:⍺ ⋄ ⍺ CompileAttributes ⍵}←b/defs
          sp.r/⍨←~''''''⍷sp.r  ⍝ APLers might specify double-quotes, so we remove them.
          {⍵/⍨~'  '⍷⍵}sp.r
      }

      CompileClassNames←{
          sp←⍺
          sp.r,←' class="',(⊃{⍺,' ',⍵}/1↓¨⍵),'"'
          sp
      }

      CompileID_Names←{
          sp←⍺
          sp.r,←' id="',(1↓⍵),'"'
          sp
      }

      CompileAttributes←{
          sp←⍺
          attrs←dmb ⍵
          attrs←CompileAttribute¨attrs
          1=⍴attrs:sp⊣sp.r,←' ',⊃attrs
          sp.r,←⊃{⍺,' ',⍵}/attrs
          sp
      }

      CompileAttribute←{
          attr←⍵
          0≠2|'"'+.=attr:'Special attributes: invalid nunmber of "'⎕SIGNAL 11
          mask←Between'"'=attr
          0<+/mask:' ',attr
          ⊃{⍺,'="',⍵,'"'}/'='Split attr
      }

      CompileBookMarkName←{
    ⍝ Returns the bookmark name
          ⍺←1
          bookmarkMayStartWithDigit←⍺
          (txt specialAttrs)←⍵
          txt←BringBackSpecialHtmlEntities txt
          r←GetIdFromSpecialAttributes specialAttrs
          ~0∊⍴r:{{⍵↑⍨¯1+⍵⍳'"'}⍵↓⍨⍵⍳'"'}r
          r←Lowercase txt
          r←'&[a-z]*;'⎕R''⊢r                    ⍝ Remove HTML entities (&{word}; only)
          r←'<.+?>'⎕R''⊣r                       ⍝ Remove everything between <>
          r←RemoveHTML r
          r←'\[.*\]'⎕R''⊣r                      ⍝ Remove everything between []
          r←'\(.*\)'⎕R''⊣r                      ⍝ Remove everything between ()
          allowed←' ∆⍙_-',⎕D,⎕A,Lowercase ⎕A
          r←(r∊allowed)/r                       ⍝ Remove invalid characters.
          r←allowed{⍵↓⍨+/∧\~⍵∊⍺~⎕D}⍣(~bookmarkMayStartWithDigit)⊣r ⍝ Remove all leading digits if ~bookmarkMayStartWithDigit
          r←dlb dtb r                           ⍝ Remove leading and trailing blanks
          r←{0∊⍴⍵:⍵ ⋄ (⊃⍵)∊'∆⍙_',⎕D,⎕A,Lowercase ⎕A:⍵ ⋄ ∇ 1↓⍵}r
          ((' '=r)/r)←'-'                       ⍝ Replace remaining blanks by hyphens.
          r
      }

      DropSpecialAttributes←{
          specialAttrs←⍺
          0∊⍴specialAttrs:⍵
          '\'=1↑¯2↑⍵:⍵
          buff←(⎕UCS 13)Split ⍵     ⍝ In case of <<BR>>!
          tx←dtb⊃buff
          '}'≠¯1↑tx:1↓⊃,/(⎕UCS 13),¨(⊂tx),1↓buff
          ~'{'∊tx:1↓⊃,/(⎕UCS 13),¨(⊂tx),1↓buff
          tx←dtb{⌽⍵↓⍨⍵⍳'{'}1↓⌽tx
          1↓⊃,/(⎕UCS 13),¨(⊂tx),1↓buff
      }

      DropSpecialImageAttributes←{
      ⍝ In general special attributes are always located at the end of an object
      ⍝ while an image might might well be inside something else like a para or a cell etc.
          specialAttrs←⍺
          0∊⍴specialAttrs:⍵
          '\'=1↑¯2↑⍵:⍵
          buff←(⎕UCS 13)Split ⍵     ⍝ In case of <<BR>>!
          tx←dtb⊃buff
          b←('){')⍷tx
          0=+/b:⍵
          tx←(b⍳1)⌽⍵
          (-b⍳1)⌽{⍵↓⍨⍵⍳'}'}tx
      }

      ExecExternalFns←{
          ns←⍺
          (fns __arg)←{∨/' '''∊⍵:(¯1+⌊/⍵⍳' '''){(⍺↑⍵)(dlb ⍺↓⍵)}⍵ ⋄ ⍵ ⍬}⍵
          3≠⎕NC fns:6 ⎕SIGNAL⍨'Cannot find APL function "',fns,'"'
          1=2⊃1 ⎕AT fns:⍎fns,' ns'
          ⍎'__arg ',fns,' ns'
      }

      GetCommandLineParms←{
          r←⎕NS''
          clp←{⍵/⍨'-'≠⊃¨⍵}1↓2 ⎕NQ #'GetCommandLineArgs'
          0∊⍴clp:r
          0∊⍴clp←{⍵/⍨'='∊¨⍵}clp:r
          clp←'='Split¨clp
          _←r.{⍎⍺,'←',{'''',⍵,''''}⍣(~⊃⊃⎕VFI ⍵)⊢⍵}/¨clp
          r
      }

    ∇ r←GetCurrentDir
      r←¯1↓⊃1 ⎕NPARTS''
    ∇

      CorrectSlash←{t←⍵
          ##.FilesAndDirs.NormalizePath ⍵
      }

      InjectPointyBrackets←{
          tx←⍵
          tx←'&amp;pointybracket_open;'⎕R'<'⊣tx
          '&amp;pointybracket_close;'⎕R'>'⊣tx
      }

      GetAllLinkRefs←{
    ⍝ This combs through the html and finds all link references ([][]-syntax).
    ⍝ Ignores in-line code.
    ⍝ Returns a three-item-vector for each hit.
    ⍝ [1] The link text - that can by anything.
    ⍝ [2] The ref id. That's what we hope to find in ns.linkRefs later on.
    ⍝     This must be US ASCII letters and digits and nothing else, not even white space.
    ⍝ [3] The match - -everything between the opening [ and the closing ], including [].
          html←⍵
          mask←GetMaskForCodeTags¨html
          maskedHtml←mask{⎕ML←3 ⋄ 0=+/⍺:⍵ ⋄ w←⍵ ⋄ (⍺/w)←' ' ⋄ w}¨html
          hits←↓⍉↑'\[[^\]]*\]\[[^\]][A-Za-z0-9-_]*\]'⎕S(0 1 2)⊣maskedHtml
          0∊⍴∊hits:hits
          html∘GetLinkRef¨↓⍉↑hits
      }

      GetLinkRef←{
          html←⍺
          (start length row)←⍵
          row+←⎕IO
          buff←row⊃html
          match←(⊂start+⍳length)⌷buff
          '[]['≡3↑match:''(¯1↓3↓match)match
          (linkText id)←{⎕ML←3 ⋄ 0 2↓¨(1++\']['⍷⍵)⊂⍵}¯1↓1↓match
          linkText id match
      }

    ∇ {r}←ns ReplaceLinkID(linkText id searchFor);ind;url;title;sa;new
      r←⍬
      ind←(⊃¨ns.linkRefs)⍳⊂id
      :If ind≤⍴ns.linkRefs
          (url title sa)←1↓ind⊃ns.linkRefs
          :If 0∊⍴title
              :If 0∊⍴linkText
                  linkText←((ind,3)⊃ns.linkRefs)←url
              :Else
                  ((ind,3)⊃ns.linkRefs)←linkText
              :EndIf
          :EndIf
          :If 0∊⍴linkText
              linkText←title
          :EndIf
          new←'<a href="',url,'" class="external_link"',((~0∊⍴title)/' title="',title,'"'),sa,'>',linkText,'</a>'
          ns.html←'<code>.*?</code>'(MakeLiteralForRegex searchFor)⎕R'\0'new⍠('Mode' 'D')('DotAll' 1)⊣ns.html
      :EndIf
    ∇

      MakeLiteralForRegex←{
      ⍝ Escapes all reserved chars in ⍵ which is a RegEx search pattern that needs to be interpreted literal.
          literal←⍵
          reservedChars←'^.\$|?+()['
          b←literal∊reservedChars
          0=+/b:literal
          (b/literal)←('\',¨reservedChars)[reservedChars⍳b/literal]
          ⊃,/literal
      }

      FlattenHTML←{
      ⍝ Typically used to flatten ns.html
      ⍝ Bring back with :
      ⍝ ns.html ←→ (⎕Ucs 13) Split FlattenHTML ns.html
          1↓⊃,/(⎕UCS 13),¨⍵
      }

    ∇ r←ns CheckOddNumberOfDoubleQuotes(txt type);mask;ind;escape;openFlag;i;msg
    ⍝ Check "txt". That can be anything: paragraph, cell, list item, header, blockquote ...
    ⍝ * If it contains no " or an even number nothing changes.
    ⍝ * A single one is escaped.
    ⍝ * When an odd number is found the last one is escaped and a warning is issued, because
    ⍝   that might well not be what the user intended to do.
      r←' ',txt
      msg←''
      mask←~GetMaskForCode r
      :If 0∊⍴ind←Where mask\'"'=mask/r                      ⍝ No double quotes at all? Done!
          r←txt
      :ElseIf 1=⍴ind                                        ⍝ Just one double quote? Done!
          r←'`(.*?)`' '"'⎕R'&' '\\"'⊣txt                    ⍝ Escapes the " but ignores `code`
          msg←'Warning: single double quotes found in ',type
          ns.report,←⊂msg,' (line ',(⍕⊃ns.lineNumbers),')'
      :Else
          :If '\'∧.≠r[ind-1]                                ⍝ Nothing escaped?
              :If 0=2|⍴ind                                  ⍝ Even number of "?
                  r←txt
              :Else                                         ⍝ No, number is odd
                  (txt[¯1+¯1↑ind])←⊂'\"'                    ⍝ Escape the last one.
                  r←⊃,/txt
                  msg←'Warning: odd number of double quotes found in ',type
                  ns.report,←⊂msg,' (line ',(⍕⊃ns.lineNumbers),')'
              :EndIf
          :Else                                             ⍝ We have some `\"` so we need a loop
              openFlag←1
              txt←' ',txt
              :For i :In ind
                  :If '\"'≢txt[i-1 0]
                      :If openFlag
                          openFlag←0
                      :Else
                          openFlag←1
                      :EndIf
                  :EndIf
              :EndFor
              r←1↓⊃,/txt
          :EndIf
      :EndIf
    ∇

      PolishLineNumbersInReport←{
      ⍝ When MarkAPL call itself recursively (blockquotes, TOC) then ns.report cannot simply be appended
      ⍝ to the one from the called because the line number ar wrong. This functions fixes this problem.
          report←⍵
          0∊⍴report:report
          ln←⍺                                                  ⍝ linenumber to be added
          oln←{⊃⊃(//)⎕VFI ⍵/⍨⍵∊⎕D}¨{⍵/⍨Between ⍵∊'()'}¨report    ⍝ Original line numbers
          ({⍵↓⍨-'('⍳⍨⌽⍵}¨report),¨{'(line ',(⍕⍵),')'}¨ln+oln    ⍝ Put them back
      }

    ∇ ns←CheckForInvalidFootnotes ns;ind;ids;mask;html
    ⍝ At this point if we find any footnote refs they must be invalid, otherwise we wouldn't find them.
      :If ns.parms.checkFootnotes
      :AndIf ~0∊⍴ns.html
          html←FlattenHTML ns.html
          mask←~GetMaskForCodeTags html
      :AndIf ~0∊⍴html←mask/html
      :AndIf ~0∊⍴ind←Where'[^'⍷html
          ids←ind{{⍵↑⍨¯1+⍵⍳']'}(⍺+1)↓⍵}¨⊂html
          ns.report,←'Warning: invalid footnote: '∘,¨ids
      :EndIf
    ∇

    ∇ ns←CheckInternalLinks ns;html;anchors;isfootnoteLink;isAutoHeaderAnchor;isFootnoteAnchor;links;hrefs;b;buff;b2;isExternalLink
    ⍝ Checks all internal links for being correct (not pointing into nowhere land).
    ⍝ Those must be found in ns.headers[;2]
      :If ns.parms.checkLinks
      :AndIf ~0∊⍴ns.html
          html←⊃,/ns.html
      :AndIf ~0∊⍴html←(~GetMaskForCodeTags html)/html
          anchors←{{⍵↑⍨¯1+1⍳⍨'</a>'⍷⍵}¨('<a '⍷⍵)⊂⍵}html
          isfootnoteLink←∨/¨'footnote_link'∘⍷¨anchors
          isAutoHeaderAnchor←∨/¨'autoheader_anchor'∘⍷¨anchors
          isFootnoteAnchor←∨/¨'footnote_anchor'∘⍷¨anchors
          isExternalLink←∨/¨'external_link'∘⍷¨anchors
          links←(~isfootnoteLink∨isAutoHeaderAnchor∨isFootnoteAnchor∨isExternalLink)/anchors
          links←(~∨/¨'://'∘⍷¨links)/links                       ⍝ Ignore external links
          links←(~∨/¨'href="mailto:'∘⍷¨links)/links             ⍝ Ignore mailto:
          :If ~0∊⍴hrefs←GetHrefs¨links
          :AndIf 1∊b←~(1↓¨hrefs)∊{0∊⍴⍵:⍵ ⋄ 3⊃¨⍵}ns.toc          ⍝ We expect to find those in ns.toc
              buff←{'>'∊⍵:⍵↓⍨⍵⍳'>' ⋄ ⍵}¨b/links
              :If ∨/b2←0∊⊃¨⍴¨buff
                  (b2/buff)←b2/b/links
              :EndIf
              ns.report,←'Invalid internal link: ['∘,¨buff,¨']'
          :EndIf
      :EndIf
    ∇

      GetHrefs←{
    ⍝ ⍵ is an anchor: <a href="..."
    ⍝ Returns what's between the "" after `href=`
          start←'href=".*"'⎕S 0⍠('Greedy' 0)⊣⍵
          start{{⍵↑⍨¯1+⍵⍳'"'}(⍺+⍴'href="')↓⍵}⍵
      }

      CompileMarkAPL←{
          parms←⍵
          0=parms.compileFunctions:0    ⍝ Don't?!
          1(400⌶)'Between':0            ⍝ already compiled
          ⍬ ⍝{2(400⌶)⍵}¨↓⎕NL 3
      }

    Between←{⍵∨≠\⍵}

      MaskPointyBrackets←{
      ⍝ Some stuff is marked up internally as "&pointybracket_open;" and "&pointybracket_close;".
      ⍝ In some instances we need to mask whatever is between. This fns returns the mask.
      ⍝ Note that when called the "&" will be converted into "&amp;".
          txt←⍵
          r←(⍴txt)⍴0
          0=+/b←'&amp;pointybracket_open;'⍷txt:r
          start←¯1+Where b
          end←('&amp;pointybracket_close;'{(⍴⍺)+Where ⍺⍷⍵}txt)-start+1
          ((,/start+¨⍳¨end)⌷r)←1
          r
      }

      MaskTagAttrs←{
          txt←⍵
          r←(⍴txt)⍴0
          ~'<'∊txt:r
          ind←∊{(⊃⍵)+⍳1↓⍵}¨'<[a-z]*\b[^>]*>'⎕S(0 1)⊣txt
          r[ind]←1
          r
      }

      ReplaceQTC_byBlank←{
          tx←⍵
          0=+/b←tx∊⎕TC:tx
          (b/tx)←' '
          tx
      }

    ∇ (noOf item)←CollectItem bl
    ⍝ Collects as many lines from `bl` as belong to what's a single list item.
    ⍝ bl:    All the lines a list may be compiled from.
    ⍝ The end is defined by one of:
    ⍝ * Empty line
    ⍝ * Line consisting of nothing but spaces
    ⍝ * The next list item (either numbered or bulleted, no matter what the indentation is)
    ⍝ Whatever comes first.
      noOf←+/∧\0≠⊃¨⍴¨bl~¨' '
      noOf←1++/∧\~IsHtmlList¨1↓noOf↑bl
      item←FlattenNestedItem noOf↑bl
    ∇

    ∇ (noOf para)←CollectItemPara bl;options;buff
       ⍝ Collects as many lines from `bl` as belong to what's a paragraph.
       ⍝ bl:    All the lines a list may be compiled from.
       ⍝ indentation:   Number of blanks defining the indentation. May be zero.
       ⍝ ←:     [1]=Number of lines in bl the para is made of; [2]=the para as such
       ⍝ Note: this function must be called only when at least ⊃bl is a para indeed.
      :If 1=noOf←+/∧\0≠⊃¨⍴¨bl
          para←⊃bl
      :Else
          noOf←1++/∧\0=IsHtmlList¨1↓noOf↑bl
          options←('Mode' 'M')('EOL' 'CR')('DotAll' 1)
          :If ~0∊⍴buff←{⍵↑⍨⊃'[~|`]{3,}\s{0,}'⎕S 0⍠options⊣⍵}1↓⊃,/(⎕UCS 13),¨dlb¨noOf↑bl
              noOf←⊃((⎕UCS 13)+.={⍵↑⍨⊃'[~|`]{3,}\s{0,}'⎕S 0⍠options⊣⍵}1↓⊃,/(⎕UCS 13),¨dlb¨noOf↑bl),noOf
              noOf-←0∊⍴' '~⍨noOf⊃bl
          :EndIf
          para←dlb⊃,/' ',¨noOf↑bl
      :EndIf
    ∇

      GetListBlock←{
          bl←⍵
          bl←(⌊/(~(⍴bl)⍴ns.emptyLines)⌿+/∧\' '=↑bl)↓¨bl
          mask←~Between{⊃3>⍴⍵:0 ⋄ (⊂3⍴⍵)∊'```' '~~~'}¨bl~¨' '
          (mask/bl)←('⍝'≠⊃¨mask/bl)/mask/bl
          (mask/bl)←HandleEscapedNewLines mask/bl
          leadingBlanks←+/∧\' '=↑bl
          drop←{⍵⌊⊃⍵}leadingBlanks
          drop↓¨bl
      }

      FlattenNestedItem←{
          item←⍵
          1=⍴,item:⊃item
          1↓⊃,/' ',¨dlb item
      }

    ∇ (url title)←GetUrlAndTitleFromLink link;noOf
    ⍝ Takes something like [Link Text](#A BookMark Link "The Title") and returns
    ⍝ '#a-bookmark-link` `The Title`
    ⍝ or [APL wiki](http://aplwiki.com "foo")
    ⍝ 'http://aplwiki.com' 'foo'
      url←(link⍳']')↓link
      url←(url⍳'(')↓url
      url↓⍨←-{⍵⍳')'}⌽url
      url←dtb url
      :If '"'=¯1↑url           ⍝ Has it a title?!
      :AndIf 2≤'"'+.=url
          noOf←1+{+/∧\1=+\⍵='"'}⌽url
          title←¯1↓1↓(-noOf)↑url
          url←dtb dlb(-noOf)↓url
      :Else
          title←''
      :EndIf
      :If 0=+/'://'⍷url
      :AndIf '#'≠1⍴url
          url←'http://',url
      :EndIf
    ∇

      GetIdFromSpecialAttributes←{
      ⍝ 'id="foo"' ←→ GetIdFromSpecialAttributes 'class="qwe" id="foo" style="color:red;"'
          0∊⍴buff←⊃'\sid="[^"]*."'⎕S(0 1)⊣⍵:''
          (ind length)←buff
          length↑(ind+1)↓⍵
      }

      RemoveIdFromSpecialAttributes←{
      ⍝ 'class="qwe" style="color:red;"' ←→ RemoveIdFromSpecialAttributes 'class="qwe" id="foo" style="color:red;"'
          '\sid="[^"]*."'⎕R''⊣⍵
      }


    ∇ r←ns CreateTOC def;lastLevel;level;caption;id;no;bf;nf;co;ff
    ⍝ def:
    ⍝ [;1] level
    ⍝ [;2] caption
    ⍝ [;3] running no
    ⍝ [;4] id
      :If ns.parms.collapsibleTOC
          r←⊂'<nav id="main_nav">'
          r,←⊂'<input type="checkbox" id="hide_toc">'
          r,←⊂'<label id="hide_toc_label" for="hide_toc"></label>'
          r,←⊂'<div class="toc-container">'
      :Else
          r←⊂'<nav>'
      :EndIf
      r,←⊂'<ul>'
      lastLevel←⊃⊃def
      bf←(,0)≢,ns.parms.bookmarkLink        ⍝ Bookmark flag
      nf←(,0)≢,ns.parms.numberHeaders       ⍝ Numbered flag
      co←1                                  ⍝ Count opened lists
      ff←1                                  ⍝ "First" flag
      :For (level caption no id) :In ↓def
          :If lastLevel<level
              r,←⊂'<ul>'
              co+←1
          :ElseIf lastLevel>level
              ((⍴r)⊃r),←'</li>'
              r,←(lastLevel-level)⍴⊂'</ul>',(co>1)/'</li>'
              co-←lastLevel-level
          :ElseIf lastLevel=level
          :AndIf ~ff
              ((⍴r)⊃r),←'</li>'
          :EndIf
          caption←ns ProcessInlineMarkUp caption
          r,←⊂'<li><a href="#',id,'">',(nf/no,' '),caption,'</a>'
          lastLevel←level
          ff←0
      :EndFor
      r,←(co-1)⍴⊂'</li></ul></li>'
      r,←⊂'</ul>'
      r,←(ns.parms.collapsibleTOC)/⊂'</div>'
      r,←⊂'</nav>'
    ∇

    RemoveDoubleSlashes←{'//'{⍵/⍨~⍺⍷⍵}'\\'{⍵/⍨~⍺⍷⍵}⍵}

      EstablishDefaultHomeFolder←{
          p←⍵
          ¯1≢p.homeFolder:p
          this←⍕⎕THIS
          p.homeFolder←GetCurrentDir
          f←∨/##.FilesAndDirs.Exists¨p.homeFolder∘,¨'/MarkAPL.html' '/MarkAPL_CheatSheet.html'
          f:p
          p.homeFolder←GetCurrentDir,'/Files'
          f←∨/##.FilesAndDirs.Exists¨p.homeFolder∘,¨'/MarkAPL.html' '/MarkAPL_CheatSheet.html'
          f:p
          home←(⊃¯1↑'.'SplitPath this){6::(⊃⎕RSI)⍎⍺ ⋄ ⍎⍵}¯1↓⊃'.'SplitPath this
          f←9≠home.⎕NC this,'.SALT_Data'
          f:p⊣p.homeFolder←GetCurrentDir,'/'
          sourceFolder←⊃SplitPath home.⍎'MarkAPL.SALT_Data.SourceFile'
          f←∨/##.FilesAndDirs.Exists¨sourceFolder∘,¨'/MarkAPL.html' '/MarkAPL_CheatSheet.html'
          f:p⊣p.homeFolder←sourceFolder
          p.homeFolder←CorrectSlash sourceFolder,'/Files/'
          p
      }

      RemoveAllComments←{
          markdown←⍵
          markdown←1↓∊(⎕UCS 10),¨markdown
          ind←1+'^\s{0,3}[~|`]{3,}\s{0,}({.*?})?\s{0,}$'⎕S 0⍠('Mode' 'M')('DotAll' 1)('EOL' 'LF')⊣markdown
          0∊⍴ind:⍵
          b←(⍴markdown)⍴0
          b[ind]←1
          b←Between b
          b∧←markdown≠⎕UCS 10
          markdown[Where b]←' '
          ('⍝'≠⊃¨(⎕UCS 10)Split markdown)/⍵
      }
      WhatAreEmptyLines←{
      ⍝ ⍵ is Markdown. Returns vector of Booleans with 1 where there are empty lines
      ⍝ Note that empty lines within code block are ignore!
          b←0=⊃∘⍴∘,¨⍵
          buff←{'}'≠⊃w←dlb⌽⍵:⍵ ⋄ ~'{'∊w:⍵ ⋄ ⌽w↓⍨w⍳'{'}¨⍵            ⍝ Drop special attributes, if there are any
          b∧~{⍵∨≠\⍵}1=⊃¨⍴¨{'^\s{0,3}[~|`]{3,}\s{0,}$'⎕S 0⊣⍵}¨buff   ⍝ Mask any code blocks
      }

    ∇ cb←MassageCodeBlock(cb noOfBlanks);pc
      pc←¯1↓1↓cb                            ⍝ Pure code: without the fences.
      :If ' '∧.=⊃,/noOfBlanks↑¨pc           ⍝ We take this as indicator that the pure code has it's own ideas regarding indentation; nothing needs to be done
          (¯1↓1↓cb)←noOfBlanks↓¨pc
      :EndIf
    ∇

    ∇ ns←CompileHelp(filename recompileFlag parms);ps;fn;b
    ⍝ Called by `Help` and `Reference`.
      ns←⍬
      parms←EstablishDefaultHomeFolder parms
      :If ¯1≡parms.cssURL
          parms.cssURL←parms.homeFolder
      :EndIf
      fn←CorrectSlash parms.homeFolder,'/',filename
      :If 0∊⍴parms.inputFilename
          parms.inputFilename←(¯4↓fn),'md'
      :EndIf
      :If 0∊⍴parms.outputFilename
          parms.outputFilename←fn
      :EndIf
      :If 0=##.FilesAndDirs.Exists parms.inputFilename
          6 ⎕SIGNAL⍨'File "',parms.inputFilename,'" not found; set "homeFolder"'
      :EndIf
      :If |recompileFlag
          :If 0∊⍴parms.outputFilename
              parms.outputFilename←fn
          :Else
              fn←parms.outputFilename
          :EndIf
          ns←2⊃parms Markdown2HTML''
      :EndIf
      :If 0=parms.⎕NC'viewInBrowser'
          parms.viewInBrowser←1
      :EndIf
    ∇

    ∇ to←from CopyTo to;id;value;flag
    ⍝ ⍺ is typically something like embedded parms while ⍵ are THE parms
      :For id :In ' '~¨⍨↓from.⎕NL 2
          :If flag←0=to.⎕NC id
              value←from.⍎id
          :Else
              :If flag←¯1≢value←to.⍎id
                  flag←~0∊⍴value
              :EndIf
          :EndIf
          :If flag
              id to.{⍎⍺,'←⍵'}value
          :EndIf
      :EndFor
    ∇

      MassageFilename←{
          fn←CorrectSlash ⍵
          'file://'{⍺≢Lowercase(⍴⍺)↑⍵}fn:fn
          (⍴'file://')↓fn
      }

      AddAlignStyle←{
          ⍺←2
          (⍺=2)∧'left'≡⍵:''                 ⍝ For <th> ⍺←→1: headers default to center rather than left!
          ' style="text-align: ',⍵,';"'     ⍝ For "center" and "right"
      }

    ∇ toc←CollectToc ns;ind;buff;level;caption;IDs
      toc←⍬
      :If ~0∊⍴ind←'<a .*href=".*" class="autoheader_anchor".*>'⎕S 2⍠('Greedy' 0)⊣ns.html
          level←{⍎1↑2↓⊃⍵∘GetHitsFromRegExSearch¨'<h[1-6].*>'⎕S 0 1⍠('Greedy' 0)⊣⍵}¨ns.html[2+ind]
          caption←{1↓¨(-1+⍴'<hx>')↓¨⍵ GetHitsFromRegExSearch¨{⊃'\>.*\</h[1-6]>'⎕S 0 1⍠('Greedy' 0)⊣⍵}¨⍵}ns.html[2+ind]
          caption←{0∊⍴⍵:⍵ ⋄ '&lt;' '&gt;' '&amp;' '<code>' '</code>'⎕R(,¨'<>&``')⍠('Greedy' 0)('Mode' 'L')⊣⍵}¨caption
          IDs←{⍵{{⍵↑⍨¯1+⍵⍳'"'}((⍴'id="')+⍵)↓⍺}¨'id="(.*)"'⎕S 0⍠('Greedy' 0)⊣⍵}ns.html[1+ind]
          (level caption IDs)←(0<⊃¨⍴¨caption)∘/¨level caption IDs
          toc←↓(level,[1.5]caption),IDs
      :EndIf
    ∇

      GetHitsFromRegExSearch←{
      ⍝ ⍺ is a text string to be indexed.
      ⍝ ⍵ is a two-element vector as returned by `⎕S 0 1`: start and length
          ⍵[2]↑⍵[1]↓⍺
      }

:EndClass
