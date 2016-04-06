:Class ADOC
⍝ == Automated Documentation Generation

⍝ === Overview
⍝ This class is useful to analyse one or more scripts or/and, if certain _
⍝ conditions are fulfilled, →[ordinary namespaces] for documentation _
⍝ purposes. Note that the documentation is meant to be useful for the ''user'' _
⍝ of a class, not the designer/programmer of a class.
⍝
⍝ There are three different ways to make use of ADOC in order to extract _
⍝ information from a class or script:
⍝ * Getting a list of methods, properties and fields (`List` method)
⍝ * Getting a list of methods, properties and fields with additional information _
⍝   (`List` method with "full" parameter)
⍝ * Creating a single HTML page with all information available, including any _
⍝   documentation (`Browse` method).
⍝
⍝ The last one is by far the most powerful and popular option since it allows _
⍝ one to include additional information within a script: all "leading comments" _
⍝ are treated as special information. One can use simplified mark-up to format _
⍝ the documentation. When you read this your are looking at ADOC's own _
⍝ documentation created this way.
⍝
⍝ See →[Misc] for a definition of "leading comment".
⍝ See →[Markup syntax] for details of how to do the mark-up.

⍝ === Usage in the workpace

⍝ ==== List
⍝ For a quick glance you can use the shared method `List`, for example:
⍝ ````ADOC.List ADOC````
⍝ For a more detailed report, specify `'full'` as the left argument:
⍝ ````'full' ADOC.List ADOC````
⍝ <index>List;Methods:List

⍝ ==== Full report
⍝ For a full report, use the `Browse` method:
⍝ ````ADOC.Browse ADOC````
⍝ By definition the `Browse` method displays the HTML file with your default browser.

⍝ === ADOC as a User Command
⍝ `ADOC` can be used as a User Command. For details see
⍝ http://aplwiki.com/UserCommands/ADOC

⍝ === Misc
⍝ Note that comments are recognized only if and as long as they are following _
⍝ the "header": the top of a script as well as function and operator header, _
⍝ property or field definitions ''after'' the removal of empty lines and any _
⍝ code lines that carries an ":Access ..." statement.
⍝
⍝ In case you want to exclude a particular line from those leading comments _
⍝ use two lamps (`⍝⍝`) at the beginning of the line. This does ''not'' break _
⍝ the connections with comments further down the line. Example:
⍝````
⍝⍝⍝ This line won't show in the ADOC documentation.
⍝````
⍝
⍝ The `ADOC` class itself uses all mark-up features available and therefore _
⍝ acts as a self-reference.

⍝ === Parameter space
⍝ A parameter space is by definition a named namespace that carries variables _
⍝ recognized by `ADOC`. Such a namespace can be created by `⎕NS` and then _
⍝ populated with variables although this is ''not'' recommended.
⍝
⍝ Instead it is recommended to call `ADOC.CreateBrowseDefaults` which returns _
⍝ such a namespace populated with all the variables ADOC would recognize with _
⍝ reasonable defaults.
⍝ Such a namespace can then be passed as left argument to the `Browse` function.
⍝ For more details see `→[ADOC.Browse with individual settings]`

⍝ === Markup syntax

⍝ ==== Overview
⍝ One can use a kind of simplified markup within the comment section. `ADOC` _
⍝ itself can be used as an example: it makes use of all markups available:
⍝ * Headers
⍝ * Lists
⍝   * Ordered lists
⍝   * Unordered lists
⍝ * APL code
⍝   * Inline APL code
⍝   * APL code blocks
⍝ * Tables
⍝ * Misc

⍝ ==== Headers
⍝ Headers use `=` at the left as indicator of depth. Therefore...
⍝ ````
⍝ `= is a header of level one`
⍝ `== is a header of level two`
⍝ `=== is a header of level three`
⍝ `==== is a header of level four`
⍝ ````

⍝ ==== Lists
⍝ This:
⍝ ````
⍝ ⍝ * Item 1
⍝ ````
⍝ results in a bulleted list item while this
⍝ ````
⍝ ⍝ # Item 1
⍝ ````
⍝ results in a numbered list item.
⍝ Nested lists are allowed but one level only. Note that the number of blanks rule _
⍝ the nesting. If the nesting does not exactly look like this example then it won't _
⍝ work at all:
⍝ ````
⍝ ⍝ * Bullet item 1
⍝ ⍝ * Bullet item 2
⍝ ⍝   # Nested numbered item 1
⍝ ⍝   # Nested numbered item 2
⍝ ⍝ * Bullet item 3
⍝ ⍝   * Bullet sub-item 1
⍝ ⍝   * Bullet sub-item 2
⍝ ⍝ * Bullet item 4
⍝ ````
⍝ This code would generate this:
⍝ * Bullet item 1
⍝ * Bullet item 2
⍝   # Nested numbered item 1
⍝   # Nested numbered item 2
⍝ * Bullet item 3
⍝   * Bullet sub-item 1
⍝   * Bullet sub-item 2
⍝ * Bullet item 4

⍝ ==== Bookmarks
⍝ Links which point to a location within the same document are called bookmarks in _
⍝ HTML speak. Because all headers in an ADOC documentation are automatically named _
⍝ you can link to them from within the document.
⍝
⍝ For example, the ADOC documentation contains a chapter "Friendly classes" to which _
⍝ you can establish a link with this:
⍝````
⍝ This internal link: →[Friendly classes] jumps to the "Friendly classes" chapter.
⍝````
⍝ This internal link: →[Friendly classes] jumps to the "Friendly classes" chapter.
⍝
⍝ Notes:
⍝ * Such links are ''not'' case sensitive.
⍝ * All methods, fields, properties etc all have their own header, so you can jump _
⍝   to them as well as in this example: `→[Browse]`.
⍝ * Limitations:
⍝   * If the same name is used more than once then it will jump just to the first one.
⍝   * Inside a link there cannot be in-line APL code.
⍝ * After following such a link pressing &lt;backspace&gt; brings you back to where you _
⍝   came from.
⍝ * In order to make the link appear as APL code:
⍝````
⍝ `→[LinkText]`
⍝````
⍝ Note that at the time of writing (2015-05) some browsers (namely Chrome and IE) _
⍝ have a problem: they sometimes - but not always - don't use the APL385 Unicode font _
⍝ for such links.
⍝ On inspection the browser's HTML code does have an empty &lt;span&gt; which explains _
⍝ why the link is not showing up as intended. However, the HTML code on file is correct.

⍝ ==== APL Code
⍝ Note that you can embedd APL code into an ordinary paragraph like _
⍝ this `{⍵/⍳⍴,⍵}` piece of code by enclosing the APL code with a _
⍝ tick on both sides:
⍝ `````{⍵/⍳⍴,⍵}`````

⍝ You can also mark APL code up  as a code block with four ticks:
⍝<pre>
⍝ ⍝ ````
⍝ ⍝ {⍵/⍳⍴,⍵}
⍝ ⍝ {⍵/⍳⍴,⍵}
⍝ ⍝ ````
⍝</pre>
⍝ This technique can also be used on a single line:
⍝ <pre>
⍝ ⍝ ````{⍵/⍳⍴,⍵}````
⍝ </pre>
⍝ Finally you can mark up APL code block by enclosing them with the HTML tag _
⍝ &lt;pre&gt;.

⍝ Note that anything marked up as a code block is ''not'' _
⍝ restricted in terms of width; it is up to you to handle this appropriately.
⍝ However, a scroll bar is provided in case the code is too long but _
⍝ that won't help when it comes to printing:
⍝ ````
⍝ 0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
⍝ ````

⍝ You don't have to worry about the APL characters &lt;, &gt; and &amp; _
⍝ within code: ADOC will handle this for you.

⍝ Blanks in code blocks are preserved; this has three leading blanks:
⍝ ````
⍝   {⍵/⍳⍴,⍵}
⍝ ````

⍝ ==== Tables
⍝ Tables use `||` for cell definitions. Note that the first row is not treated _
⍝ differently; therefore you might want to take action yourself, for example by _
⍝ making them bold by putting the column titles between `''` and `''`.
⍝
⍝ The following example also shows APL code and line breaks within a cell; this:
⍝ ````
⍝ ||''Col 1''||''Col 2''||''Column 3''||
⍝ ||Row 1/ Col 1||Row 1/Col2|| ||
⍝ ||  Row 2/ Col 1 ||Row 2/Col2    ||  `{⍵/⍳⍴,⍵}` ||
⍝ ||Row 3/ Col 1   ||Row 3/Col2||  Row 3<br/>Col 3   ||
⍝ ````
⍝ results in this:
⍝ ||''Col 1''||''Col 2''||''Column 3''||
⍝ ||Row 1/ Col 1||Row 1/Col2|| ||
⍝ ||  Row 2/ Col 1 ||Row 2/Col2    ||  `{⍵/⍳⍴,⍵}` ||
⍝ ||Row 3/ Col 1   ||Row 3/Col2||  Row 3<br/>Col 3   ||

⍝ ==== Emphasis (bold, strong)
⍝ Anything between two pairs of two quotes gets marked up as &lt;strong&gt;, _
⍝ for example: `''bold''` leads to ''bold''.

⍝ ==== Misc
⍝ Note that inserting &lt;, &gt; and &amp; as part of the text (rather than _
⍝ as HTML tags) is possible but you have to include them as HTML entities as _
⍝ shown here:
⍝ ````&lt; &gt; &amp;````

⍝ Note that you ''cannot'' show such strings between ticks (&grave;) but that is more _
⍝ than unlikely to ever cause headache.

⍝ <index>Markup,Simplified markup

⍝ === Ordinary namespaces

⍝ ==== Overview
⍝ Originally `ADOC` was designed to process just scripts (class scripts as well as _
⍝ namespace scripts), including :Include(d) namepaces, but it was not designed _
⍝ to process ordinary namespaces as such. However, starting with version 3.0 you _
⍝ can specify the name of a function that follows the same rules as the "leading _
⍝ comments" in a script. Such functions can also act as "containers" when _
⍝ multiple references/names are specified.

⍝ ==== Calling syntax
⍝ For a script one must pass a reference to that script as the right argument, _
⍝ for example:
⍝ ````ADOC.Browse #.MyScript````
⍝ `ADOC` then extracts the documentation from that script.
⍝ This is not possible with an ordinary (non-scripted) namespace. For that _
⍝ reason one needs to provide the name of a function containing the information _
⍝ needed by `ADOC`. As usual all lines must start with a comment lamp.

⍝ === Reserved names
⍝ Since version 3.0, `ADOC` looks for a number of fixed names. If there _
⍝ is a function with such a name to be found, that function is executed and the _
⍝ result returned by that function is taken into account. The syntax rules are _
⍝ fixed: if such a function does not honor the syntax rules it will fail. _
⍝ However, since the call is trapped that won't stop `ADOC` from producing a result.
⍝ If there is accidentically a name with such a "reserved" name but it is not _
⍝ designed to deliver information to `ADOC` for documentation purposes you can _
⍝ prevent `ADOC` from executing that function by setting "ignore{fixedName}" to 1.
⍝ All these functions must be niladic traditional functions marked as:
⍝ ```` :Access Public Shared````
⍝ and they must return a result.
⍝ Underneath the functions are listed which will be honoured in case they exist.
⍝ <index>Reserved names:Copyright,Version,History;History;Version;Copyright

⍝ ==== Copyright
⍝ Must return a vector of strings.

⍝ ==== History
⍝ Must return either a simple string or a vectors of strings.

⍝ ==== Version
⍝ Must return a vector of length three:
⍝ # The name, for example "ADOC"
⍝ # A string with version information, for example "1.2.3"
⍝ # A string representing a date, for example "2009-01-01"
⍝ Exampel: A function returning this:
⍝ ````('1.2.3' '2009-06-01')←1↓#.MyOrdNameSp.Version ⍬````
⍝ let `ADOC` produce this information:
⍝ "Version 1.2.3 from 2009-06-02"

⍝ === Specialties

⍝ ==== :Include
⍝ Since version 1.3, `ADOC` is processessing :Included namespaces.
⍝ This means that included stuff is "imported" in the first place, then the result _
⍝ is analyzed.
⍝ <index>:Include

⍝ ==== Embedded classes
⍝ If you would like to create an HTML report on embedded classes within a host _
⍝ class you can do this by setting `embeddedClassesFlag←1` within a _
⍝ →[parameter space]. Alternatively you can just specify a `1` as left argument to `Browse`.
⍝ Example:
⍝ ````1 ADOC.Browse ADOC````
⍝ would create a single report that contains all classes embedded into `ADOC`.
⍝
⍝ If you want not all but only one or some of the classes embedded into another _
⍝ class then you can either assign the name(s) to `embeddedClassNames` within _
⍝ a parameter space or specify the name(s) as left argument to the `Browse` _
⍝ function as shown in these examples:
⍝ ````1 ADOC.Browse ADOC````
⍝ ````'Registry' ADOC.Browse ADOC````
⍝ ````'Demo' 'Registry' ADOC.Browse ADOC````
⍝ <index>Embedded classes

⍝ ==== CSS Style sheets
⍝ With version 1.4 the way style sheets are used has changed: `ADOC` now _
⍝ creates its own style sheets dynamically.
⍝ <index>CSS style sheets, Style sheets

⍝ === ADOC.Browse with individual settings
⍝ In general, to make use of the many fields and properties available to make _
⍝ `ADOC` suit your needs, you need to create an instance. However, ''some'' _
⍝ of the properties can be set without creating an instance.
⍝ In order to achieve that you must create a so-called parameter space and _
⍝ populate it with variables holding the desired values. For example:
⍝ ````
⍝ p←⎕ns ''
⍝ p.FullDocName←'test.htm'
⍝ p.Caption←'My Main Header'
⍝ p ADOC.Browse ADOC````
⍝ These properties can be set via such a parameter namespace:
⍝ * `BrowserName`
⍝ * `BrowserPath`
⍝ * `Caption`
⍝ * `IgnorePattern`
⍝ * `embeddedClassNames`
⍝ * `Inherit`
⍝ * `RefToUnicodeFile` (deprecated)
⍝ * `ignoreCopyright`
⍝ * `ignoreHistory`
⍝ * `ignoreVersion`
⍝
⍝ After having set the properties to the appropriate values one can call the method _
⍝ `Make` to create the final document:
⍝ ````My.Make scriptname````
⍝
⍝ You can then restart by calling `MyAplDoc.Refresh`, or expunge your instance.
⍝ <index>Browsing:Individual settings

⍝ === Friendly Classes
⍝ Friendly classes are classes who can see each others private members. At the time _
⍝ being they are not available in Dyalog. However, depending on the application _
⍝ friendly classes might be indispensable. As a circumvention one can use naming _
⍝ conventions to deal with this. For example, you could define that all methods, _
⍝ fields and properties with names starting with an underscore are "friendly".
⍝
⍝ You can tell `ADOC` to suppress all members with such a pattern by defining:
⍝ ```` My.IgnorePattern←'_' ````
⍝ Note that for the time being that can only be a string. This restriction may be _
⍝ lifted in a later version, for example by allowing a regular expression.
⍝ <index>Friendly classes

⍝ === Create permanent HTML pages
⍝ "Browse" is perfect for creating and displaying information regarding a _
⍝ particular script or namespace, but sometimes you might want to create _
⍝ permanent HTML files and collect them for other purposes than to look at them.
⍝ <index>Permanent HTML pages

⍝ ==== With defaults
⍝ If you can live with the defaults, use the shared method "ProcessAsHtml" _
⍝ to create a doc file for one or more scripts:
⍝ ````
⍝ ADOC.ProcessAsHtml ADOC '' ⍝ Creates page in current dir
⍝ ADOC.ProcessAsHtml (ADOC APLTreeUtils) 'c:\doc.html' ⍝ 2 scripts!
⍝ ````

⍝ ==== Full control
⍝ One ''can'' gain full control by creating an instance of `ADOC`, setting _
⍝ parameter appropriately and then calling particular methods. However, this _
⍝ is quite a complex task, and normally there is no need to do this.
⍝ Let's look at an example.
⍝ ````
⍝ My←⎕NEW #.ADOC
⍝ My.(FullDocName Caption)←'test.htm' 'My Main Header'
⍝ My.Analyze scriptname       : Writes to the "Meta" property
⍝ My.CreateHtml ⍬             : Writes to the "HTML property
⍝ My.FinaliseHtml ⍬           : Add header+footer+prepare the final HTML
⍝ My.SaveHtml2File ⍬|filename : Write the HTML code to the disk
⍝ ````
⍝ After calling "Analyze" you can look at the result by accessing the read-only _
⍝ property "Meta". You can also create the HMTL code by calling "CreateHtml" _
⍝ and then manipulate the "HTML" property which holds that code.
⍝ <index>Workflow, internal

⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/ADOC

    ⎕IO←1 ⋄ ⎕ML←3

    ∇ r←Version
      :Access Public shared
      r←(⍕⎕THIS)'4.2.6' '2015-10-09'
      ⍝ 4.2.6  * Colours for tables changed.
      ⍝        * Typo in the documentation fixed.
      ⍝        * Documentation for bold was missing.
      ⍝ 4.2.5  Bug fixes: A non-listed list could be mistaken as a nested one if
      ⍝        it carried more than leading blank.
      ⍝ 4.2.4  Bug fixes:
      ⍝        * Non-nested bulleted lists became numbered lists and vice versa.
      ⍝        * The new `''` syntax sometimes did not work as intended.
      ⍝        * Some links did not show as intended.
      ⍝        ≠ CSS improved.
      ⍝ 4.2.3  CSS for "required" improved.
      ⍝ 4.2.2  Bug fixes: mark up for "requires" was invalid
      ⍝ 4.2.1  Bug fixes:
      ⍝        * :Include mark up was faulty.
      ⍝        * Bulleted lists became numbered lists.
      ⍝        * Only the first intended sub list was handled properly.
      ⍝ 4.2.0  * ```` now indicates a code block start/end.
      ⍝        * A `Version` could confuse ADOC under certain circumstances.
      ⍝        * As ususal the documentation has been improved.
    ∇

      MarkupInlineAPL_Code←{
        ⍝ Marks up anything between ` (ticks) as inline APL code for HTML,
        ⍝ meaning that ordinary CSS is used.
          0=+/b←'`'=w←⍵:w                           ⍝ No inline APL code? return ⍵
          0≠2|+/b:11 ⎕SIGNAL⍨'Odd number of ` (ticks) found; see ',w
          ind←{⍵/⍳⍴,⍵}b
          i1←((⍴ind)⍴1 0)/ind
          i2←((⍴ind)⍴0 1)/ind
          w[i1]←⊂'<span class="aplinlinecode">' ⍝ Opening tag
          w[i2]←⊂'</span>'                       ⍝ Closing tags
          ↑,/w                                   ⍝ Simplify
      }

      MarkupBold←{
      ⍝ Mark up anything between '' and '' because that is meant to go ''bold''!
          0=+/b←''''''⍷w←⍵:w
          mask←~'`'{{⍵∨≠\⍵}⍺=⍵}w
          b∧←mask
          w[,({⍵/⍳⍴,⍵}b)∘.+¯1+⍳2]←(2×+/b)⍴'<strong>' '' '</strong>' ''
          ↑,/w
      }

    ∇ (r k l)←CreateBody(formattedScriptName devisor scriptType hasContainer isContainer chapterNo k l);tail;type;name;flag
      tail←devisor{0∊⍴⍺:⍵ ⋄ ' &lt; ',⍺},{⍵/⍨⍵≢' (Container)'}' (',scriptType,')'
      _WithRunningNumbers←{¯1=⍵:1<⍴_META ⋄ ⍵}_WithRunningNumbers
      :If _WithRunningNumbers
          :If isContainer
              name←('. ',⍨⍕l),formattedScriptName
              l←l+1
              k←1
          :ElseIf hasContainer
              name←((⍕l-1),'.',(⍕k),' '),formattedScriptName
              k←k+1
          :Else
              name←('. ',⍨⍕chapterNo),formattedScriptName
          :EndIf
      :Else
          name←formattedScriptName
      :EndIf
      r←(MakeBookmark name),{('h1 id="',GetChapterNo,'"')tag ⍵}name,tail
    ∇

    ∇ SortMeta parms;si
      :If ~0∊⍴parms
          :If parms.sortByNameFlag
              si←SortAlphabet⍋⊃1⊃¨_META           ⍝ Get sort index
          :Else
              si←⍬
          :EndIf
          :If 0≠parms.bigPicture
          :AndIf 1<⍴_META
              :If si≡⍬
                  si←{⍵,(⍳⍴_META)~⍵}parms.bigPicture
              :Else
                  si←{⍵,si~⍵}parms.bigPicture
              :EndIf
              _META←_META[si]            ⍝ Sort by script name
          :EndIf
      :EndIf
    ∇

      Blank2_←{
          w←⍵
          ((' '=w)/w)←'_'
          w
      }

      MakeBookmark←{
          '<a name="',(Blank2_ Lowercase ⍵),'" />',nl
      }

    ∇ {embeddedClassNames}←Fill_META(list embeddedClassesFlag embeddedClassNames);this;isRef;scriptRef
         ⍝ Runs a loop on all items in list. "list" can be a single ref or the fully _
         ⍝ qualified name of a function or a vecor (and mixture) of both.
      isRef←{⍵≢⍕⍵}
      :If 2>≡list
      :AndIf ~isRef list
          list←,⊂list
      :EndIf
      :For this :In list
          :If isRef this
              scriptRef←this
              :If embeddedClassesFlag
              :AndIf 0∊⍴embeddedClassNames
                  embeddedClassNames←ReportEmbeddedClasses scriptRef
              :EndIf
              :If 0∊⍴embeddedClassNames
                  Analyze scriptRef
              :Else
                  embeddedClassNames Analyze scriptRef
              :EndIf
          :ElseIf 1=≡this                       ⍝ is it function call?
          :AndIf 3=⎕NC this                     ⍝ ... delivers the information we need?
              :If AnalyzeFunction this
                  'Invalid right argument'⎕SIGNAL 11
              :EndIf
          :Else
              ⎕←'Huuh?! What''s that: ',this
          :EndIf
      :EndFor
    ∇

⍝ --------------- Fields; defaults of some can be restored by calling shared method `RestoreDefaults`.

    :Field Public Shared nl←⎕UCS 13 10  ⍝ By default CR+LF
    :Field Public Shared InLineCodePadding←5  ⍝ Left & right padding for inline APL code in px. Will be reset by calling `RestoreDefaults`.
    :Field Public Shared InLineCodeColor←'#961c1c' ⍝ The color used for APL inline code. Will be reset by calling `RestoreDefaults`.
    :Field Public Shared MaxWidthInChars←0 ⍝ ''Deprecated'' and not used any more

    :Field Private Shared _BrowserPath←''
    :Field Private Shared _BrowserName←''
    :Field Private Shared _regKeyPath←'Software\APLTeam\ADOC'
    :Field Private Shared _Caption←''   ⍝ Top-level caption; empty=ignored.
    :Field Private Shared _Inherit←1
    :Field Private Shared _IgnorePattern←''
    :Field Private Shared CssScreen←'screen'
    :Field Private Shared CssPrint←'Print'

⍝ --------------- Properties
    :Property Caption
    :Access Public Shared
    ⍝ There is no default (empty)
        ∇ r←get
          r←_Caption
        ∇
        ∇ set arg
          'Must be a string'⎕SIGNAL 11/⍨~IsChar arg.NewValue
          'Must be simple'⎕SIGNAL 11/⍨~0 1∊⍨≡arg.NewValue
          _Caption←arg.NewValue
        ∇
    :EndProperty

    :Property Inherit
    :Access Public Shared
    ⍝ Defaults to 1. To suppress inheritance, set this to 0
        ∇ r←get
          r←_Inherit
        ∇
        ∇ set arg
          'Must be a Boolean'⎕SIGNAL 11/⍨~0 1∊⍨arg.NewValue
          _Inherit←arg.NewValue
        ∇
    :EndProperty

    :Property IgnorePattern
    :Access Public Shared
    ⍝ Defaults to an empty vector. If this is set, all members with names starting _
    ⍝ with {IgnorePattern} will be ignored by ADOC.
        ∇ r←get
          r←_IgnorePattern
        ∇
        ∇ set arg
          'Must be simple'⎕SIGNAL 11/⍨~0 1∊⍨≡arg.NewValue
          'Must be a string'⎕SIGNAL 11/⍨~IsChar arg.NewValue
          _IgnorePattern←arg.NewValue
        ∇
    :EndProperty

    :Property  BrowserName
    ⍝ By definition any HTML file is displayed with the default browser of by the _
    ⍝ browser defined by the "BrowserPath" property, see there for details.
    ⍝ The property "BrowserName" is depricated now.
    :Access Public shared
        ∇ r←get
          r←''
        ∇
        ∇ set arg
        ∇
    :EndProperty

    :Property  BrowserPath
    ⍝ By definition any HTML file is displayed with the default browser. _
    ⍝ If you want to display an HTML page with another browser you must provide the _
    ⍝ full path name including the name of the EXE.
    ⍝ This property was temporarily inactive but was brought back to life with
    ⍝ version 3.4.0
    :Access Public shared
        ∇ r←get
          r←''
        ∇
        ∇ set arg
        ∇
    :EndProperty

    :Property  htmlFinalised
    ⍝ HTML cannot be written to disk if this is not 1.
    ⍝ Calling method "FinaliseHtml" will do this, while method "Reset" set it to 0
    :Access Public Instance
        ∇ r←get
          r←_htmlFinalised
        ∇
    :EndProperty

    :Property WithRunningNumbers
    ⍝ Add a running number to the class caption if true and more then one _
    ⍝ class got processed.
    :Access Public Instance
        ∇ r←get
          r←_WithRunningNumbers
        ∇
        ∇ set args
          _WithRunningNumbers←args.NewValue
        ∇
    :EndProperty

    :Property FullDocName
    ⍝ Can be set by calling the appropriate contructor or by direct setting;
    ⍝ "ProcessAsHtml" will assign the second parameter to FullDocName
    :Access Public instance
        ∇ r←get
          r←_FULL_DOC_NAME
        ∇
        ∇ set args
          _FULL_DOC_NAME←args.NewValue
        ∇
    :EndProperty

    :Property Creator
    ⍝ The "Creator" is put into the footer.
    ⍝ Defaults to `⎕AN`. Is ignored if empty
    :Access Public instance
        ∇ r←get
          r←_Creator
        ∇
        ∇ set args
          _Creator←args.NewValue
        ∇
    :EndProperty

    :Property HTML
    ⍝ You can get the created HTML code by requesting this property.
    ⍝ That might be useful, for example, to modify the HTML code and _
    ⍝ then write it back.
    :Access Public instance
        ∇ r←get
          r←_HTML
        ∇
        ∇ set args
          _HTML←args.NewValue
        ∇
    :EndProperty

    :Property Meta
    ⍝ The "Meta" property holds the result of the "Analyze" method.
    ⍝ Every analyzed script is represented by a single item in "Meta"
    :Access Public instance
        ∇ r←get
          r←_META
        ∇
    :EndProperty

    :Property OutputType
    ⍝ Can be either "Web" or "Doc". "Doc" means that all links like "Goto class|top" _
    ⍝ as well as sub-listings for field, properties and methods are removed. Default="Web"
    :Access Public instance
        ∇ r←get
          r←_OutputType
        ∇
        ∇ set args;buffer
          'OutputType: invalid type; must be either "Web" or "Doc"'⎕SIGNAL 11/⍨~'web' 'doc'∊⍨buffer←⊂Lowercase args.NewValue
          _OutputType←'Web' 'Doc'⊃⍨'web' 'doc'⍳buffer
        ∇
    :EndProperty

    :Property bigPicture
    ⍝ Defaults to 0. This property is ignored by the `Browse` method.
    ⍝ Has no effect when either zero or only a single ref/name is specified.
    ⍝ In case more than ref/name is specified, "bigPicture" may point to one of them. This is _
    ⍝ typically a function returning the, well, big picture of all these classes.
    ⍝ In that case the item "bigPicture" is pointing to will get the first item, regardless _
    ⍝ what the setting of "sortByNameFlag" is. This is, however, <b>not</b> the same as to _
    ⍝ sort the items accordingly as it also has an impact on the level of nesting: The _
    ⍝ big-picure-item is on the same level as the "Classes" topic etc.
    ⍝ When "sortByNameFlag" is 1 the list of refs/names is sorted alphabetically except that the _
    ⍝ item "bigPicture" is pointing to is becoming the very first item anyway.
    :Access Public Shared
        ∇ r←get
          r←_bigPicture
        ∇
        ∇ set arg;newVal
          newVal←arg.NewValue
          _bigPicture←newVal
        ∇
    :EndProperty

    :Property sortByNameFlag
    ⍝ Defaults to 0. If you pass more than ref/name and want to keep that sequence, set this to 0.
    :Access Public Shared
        ∇ r←get
          r←_sortByNameFlag
        ∇
        ∇ set arg;newVal
          newVal←arg.NewValue
          '"sortByNameFlag" must be either 0 or 1'⎕SIGNAL 11/⍨~∨/newVal∊0 1
          _sortByNameFlag←newVal
        ∇
    :EndProperty

    :Property ignoreCopyright
    :Access Public Shared
    ⍝ Defaults to 1: If there is a function "Copyright" (public shared), process the result, _
    ⍝ otherwise ignore that functions, if there is any.
        ∇ r←get
          r←_ignoreCopyright
        ∇
        ∇ set arg
          'Must be a Boolean'⎕SIGNAL 11/⍨~arg.NewValue∊0 1
          _ignoreCopyright←arg.NewValue
        ∇
    :EndProperty

    :Property ignoreHistory
    :Access Public Shared
    ⍝ Defaults to 1: If there is a function "History" (public shared), process the result, _
    ⍝ otherwise ignore that functions, if there is any.
        ∇ r←get
          r←_ignoreHistory
        ∇
        ∇ set arg
          'Must be a Boolean'⎕SIGNAL 11/⍨~arg.NewValue∊0 1
          _ignoreHistory←arg.NewValue
        ∇
    :EndProperty

    :Property ignoreVersion
    :Access Public Shared
    ⍝ Defaults to 1: If there is a function "Version" (public shared), process the result, _
    ⍝ otherwise ignore that functions, if there is any.
        ∇ r←get
          r←_ignoreVersion
        ∇
        ∇ set arg
          'Must be a Boolean'⎕SIGNAL 11/⍨~arg.NewValue∊0 1
          _ignoreVersion←arg.NewValue
        ∇
    :EndProperty

⍝ --------------- Constructors / Destructors

    ∇ make_1(fullDocName)
      :Implements Constructor
      :Access Public instance
      make_0
      _FULL_DOC_NAME←fullDocName
    ∇

    ∇ make_2(fullDocName caption)
      :Implements Constructor
      :Access Public instance
      make_0
      _FULL_DOC_NAME←fullDocName
      Caption←caption
    ∇

    ∇ make_0
      :Implements Constructor
      :Access Public instance
      Init_HTML
    ∇

    ∇ make_all all
      :Implements Constructor
      :Access Public instance
      :If 0 1∊⍨≡all
      :AndIf IsChar all
          Init_HTML
          _FULL_DOC_NAME←all
      :Else
          11 ⎕SIGNAL⍨'Argument is invalid!'
      :EndIf
    ∇

    ∇ Init_HTML
      _HTML←⍬
      _FULL_DOC_NAME←''
      _DOCS←⍬
      _META←⍬
      _htmlFinalised←0
      _WithRunningNumbers←¯1
      _Creator←⎕AN
      _BrowserPath←''
      _OutputType←'Web'
      _IncludeCss←1
      _BrowserName←''
      _CssPath←''
      _sortByNameFlag←{0::1 ⋄ ⍎⍵}'_sortByNameFlag'
      _ignoreCopyright←0
      _ignoreVersion←0
      _ignoreHistory←0
      _bigPicture←0
      _withColor←1
      _embeddedClassNames←''
      _embeddedClassesFlag←0
      ⎕DF⍕⎕THIS
    ∇

⍝----------------------------------------------------
    ∇ RestoreDefaults
      :Access Public Shared
          ⍝ Set shared field/properties back to their defaults.
      _BrowserPath←''
      _BrowserName←'IE'
      _regKeyPath←'Software\APLTeam\ADOC'
      _Inherit←1
      _IgnorePattern←''
      CssScreen←'screen'
      CssPrint←'Print'
      InLineCodePadding←5
      InLineCodeColor←'#961c1c'
    ∇
    ∇ {filename}←SaveHtml2File filename;head;html;wsh;⎕WX
      ⍝ Save the HTML into "filename".
      ⎕WX←1
      'wsh'⎕WC'OLEClient' 'WScript.Shell'
      :Access public instance
      :If _htmlFinalised
          :If 0∊⍴filename←{0∊⍴⍵:_FULL_DOC_NAME ⋄ ⍵}filename
              11 ⎕SIGNAL⍨'Not filename specified'
          :EndIf
          filename,←'.html'/⍨~'.'∊filename
          WriteFile filename _HTML
          _FULL_DOC_NAME←filename
      :Else
          11 ⎕SIGNAL⍨'HTML is not yet prepared'
      :EndIf
      :If ~':'∊filename
      :AndIf 1
          filename←wsh.CurrentDirectory,'\',filename
      :EndIf
      filename←'"',filename,'"'
    ∇

    ∇ r←ReportEmbeddedClasses refToClass;html;source;where;bool;buffer
         ⍝ Looks for classes embedded into "refToClass" and returns a vtv with names.
      :Access Public Shared
      r←''
      source←{↓⍵⌽⍨+/∧\' '=⍵}⊃⎕SRC refToClass
      :If ∨/bool←':include'search source
          buffer←(⍎{⍵↓⍨-'.'⍳⍨⌽⍵}⍕refToClass).{⎕SRC⍎⍵}¨{⍵↑⍨¯1+⌊/⍵⍳' :'}¨dmb¨{(⍴':Include ')↓⍵}¨source[{⍵/⍳⍴,⍵}bool]
          buffer←(~¨':namespace'∘search¨buffer)/¨buffer
          buffer←(~¨':endnamespace'∘search¨buffer)/¨buffer
          source,←⊃,/buffer
      :EndIf
      :If ~0∊⍴where←1↓{⍵/⍳⍴,⍵}':class'search source
          r←{⍵↑⍨¯1+⌊/⍵⍳' :'}¨dmb¨{(⍴':class ')↓⍵}¨source[where],¨' '
      :EndIf
    ∇

    ∇ CreateTopOfBody dummy;html;containers;k;l;chapterNo
         ⍝ Creates the main toc with links to all chapters and adds _
         ⍝ also the main header to the top of the document.
      :Access Public Instance
      html←'<a name="verytop"></a>',nl
      :If 1<⍴_DOCS  ⍝ Then we have a main TOC
          :If ∨/containers←'Container'∘≡¨2⊃¨_META
              k←l←1
              html,←(('h1 ',((0∊⍴_Caption)/'id="topmost"'))tag'Table of Contents'),nl
              :For chapterNo :In ⍳⍴containers
                  :If chapterNo⊃containers
                      html,←'div'tag(⍕l),' ',('a href="#',GetChapterNo,'"')tag chapterNo⊃_DOCS
                      l←l+1
                      k←1
                  :Else
                      html,←'div class="subtoc"'tag(⍕l-1),'.',(⍕k),'. ',('a href="#',GetChapterNo,'"')tag chapterNo⊃_DOCS
                      k←k+1
                  :EndIf
              :EndFor
              html,←'div'tag'&nbsp;'
          :Else
              html,←'<br />','ol id="toc"'tag⊃,/'li'∘tag¨_DOCS{('a href="#',⍵,'"')tag ⍺}¨'ch'∘,¨¯4↑¨'0000'∘,¨⍕¨⍳⍴_DOCS
          :EndIf
          html←'div id="maintoc"'tag html
      :EndIf
      :If ~0∊⍴_Caption
          html←('h1 id="topmost"'tag _Caption),nl,html
      :EndIf
      html←('a id="verytop" style="display:none;"'tag''),html
      _HTML←html,_HTML
    ∇

    ∇ CreateDocFooter dummy;html
         ⍝ Creates the footer of the document. Default for "Creator" _
         ⍝ is the current user (`⎕AN`).
      :Access Public Instance
      html←'<br /><br />'
      html,←'<div id="footer">',nl
      html,←'span id="createdate"'tag'Created ',FormatDateTime ⎕TS
      :If ~0∊⍴{2=⎕NC ⍵:⍎⍵ ⋄ ⎕AN}'Creator'
          html,←'span id="createdby"'tag' by ',_Creator,' with ',{({⍵↑⍨1+-'.'⍳⍨⌽⍵}1⊃Version),' ',(2⊃⍵),' from ',3⊃⍵}3↑Version
      :EndIf
      html,←'</div>',nl
      _HTML,←html
    ∇


    ∇ {embeddedClassNames}Analyze scriptRef;list;embeddedFlag
          ⍝ Analyses one or more particular script(s) and appends the result to the "Meta" property.
      :Access Public Instance
      embeddedFlag←0<⎕NC'embeddedClassNames'
      embeddedClassNames←{0∊⍴⍵:⍵ ⋄ 0<⎕NC ⍵:⍎⍵ ⋄ ''}'embeddedClassNames'
      :If 0∊⍴scriptRef
          list←#.⍎¨⊂[2]#.⎕NL 9.1 9.4 9.5
          list/⍨←{16::0 ⋄ tmp←⎕SRC ⍵ ⋄ 1}¨list
          Analyze_¨list
      :ElseIf 1<⍴,scriptRef
          Analyze_¨scriptRef
      :ElseIf ~0∊⍴embeddedClassNames
          embeddedClassNames←{(,∘⊂∘,⍣(0 1∊⍨≡⍵))⍵}embeddedClassNames
          embeddedClassNames Analyze_¨⊂scriptRef
      :Else
          :If ~0∊⍴embeddedClassNames←Analyze_ scriptRef
          :AndIf embeddedFlag
              embeddedClassNames Analyze_¨⊂scriptRef
          :EndIf
      :EndIf
    ∇

    ∇ CreateHtml parms;runningNo;⎕ML;⎕IO;cmd;txt;commentsStartAt;noof;theSource;buffer;result;bool;type;access;syntax;remarks;firstIncludes;firstConstructor;firstProperty;firstField;firstInterface;firstMethod;firstDestructor;methodType;topRef;topLinks;publicStuff;header;methodTypes;formattedScriptName;require;mask;i;Top;Body;this;thisMeta;types;publicTypes;firstInterfaceMethod;scriptType;devisor;TopMostRefId;hasLeadingComments;thisType;hasContainers;isContainer;Level;k;l;chapterNo
           ⍝ Create _HTML from _META.
      :Access Public Instance
      :If 0<⍴_META
          SortMeta parms
          hasContainers←∨/'Container'∘≡¨2⊃¨_META
          l←1  ⍝ Counter for containers
          k←1  ⍝ Counter for sub-headings in case of containers
          :For chapterNo :In ⍳⍴_META
              thisMeta←chapterNo⊃_META
              (formattedScriptName scriptType devisor header publicStuff require)←thisMeta
              isContainer←'Container'≡2⊃thisMeta
             ⍝⍎(formattedScriptName≡'HelpWindow')/'.'
             ⍝⍎(46=chapterNo)/'.'
              :If 1=chapterNo
                  TopMostRefId←formattedScriptName
              :EndIf
              Top←Body←⍬
              (topRef topLinks)←CreateTop(publicStuff formattedScriptName TopMostRefId(⍴_META)chapterNo)
              :For i :In ⍳⍴header
                  (cmd txt)←i⊃header
                  :If 'Txt'≡cmd
                      Top,←PolishComments txt hasContainers isContainer chapterNo
                  :EndIf
              :EndFor
              hasLeadingComments←~0∊⍴Top
              Top←InsertChapterToc(Top topLinks(formattedScriptName~' '))
              (Body k l)←CreateBody(formattedScriptName devisor scriptType hasContainers isContainer chapterNo k l)
              :If 0 ⍝ ~0∊⍴topLinks
                  Body,←'<div class="sublinks">',(⊃{⍺,' | ',⍵,nl}/topLinks[;2]),'</div>',Top
              :Else
                  Body,←Top
              :EndIf
              :If hasLeadingComments
              :AndIf ~0∊⍴publicStuff
                  Body,←topRef,{(MakeBookmark ⍵),'<h2 id="',GetChapterNo,'_tocref">',⍵,'</h2>',nl}'Reference'
              :EndIf
              :If ~0∊⍴∊require
                  Body,←(MakeBookmark'Requires'),('h3 id="',GetChapterNo,':require"')tag'Requires'
                  Body,←⊃,/{(MakeBookmark ⍵),'h4 class="aplname"'tag ⍵}¨require
              :EndIf
              firstIncludes←firstConstructor←firstDestructor←firstProperty←firstField←firstInterface←firstMethod←firstInterfaceMethod←1
              methodType←'' ⍝ either "Instance" or "Shared"
              :For this :In publicStuff
                  ⍎(1≠≡Body)/'.' ⍝ Internal test case - don't remove!
                  thisType←GetSingle this
                  :Select thisType
                  :Case 'Include'
                      :If firstIncludes
                          Body,←(MakeBookmark'Included'),('h3 id="',GetChapterNo,':incl"')tag'Included'
                          firstIncludes←0
                          buffer←'name'∘GetSingle¨{⍵↑⍨+/∧\{'Include'≡↑⍵[1;2]}¨⍵}publicStuff
                          Body,←nl,('ul'tag 1↓↑,/nl∘,¨'li'∘tag¨buffer),nl
                      :EndIf
                  :Case 'Constructor'
                      :If firstConstructor
                          Body,←{(MakeBookmark ⍵),('h3 id="',GetChapterNo,':ctor"')tag ⍵}'Constructor',(1<+/'Constructor'∘≡¨Get publicStuff/⍨2=↑∘⍴∘⍴¨publicStuff)/'s'
                          firstConstructor←0
                      :EndIf
                      Body,←{((MakeBookmark ⍵)),'h4 class="aplname"'tag ⍵}'name'GetSingle this
                      Body,←SyntaxHelper'syntax'GetSingle this
                      :If ~0∊⍴2⊃this[this[;1]⍳⊂'comments';]
                          Body,←PolishComments('comments'GetSingle this)0 0 chapterNo
                      :EndIf
                  :Case 'Destructor'
                      :If firstDestructor
                          Body,←topRef,((MakeBookmark'Destructor'),('h3 id="',GetChapterNo,':dtor"')tag'Destructor')
                          firstDestructor←0
                      :EndIf
                      Body,←{(MakeBookmark ⍵),'h4 class="aplname"'tag ⍵}GetSingle this
                      Body,←SyntaxHelper'syntax'GetSingle this
                      :If ~0∊⍴'comments'GetSingle this
                          Body,←PolishComments('comments'GetSingle this)0 0 chapterNo
                      :EndIf
                  :Case 'Property'
                      :If firstProperty
                          Body,←((MakeBookmark'Properties'),('h3 id="',GetChapterNo,':props"')tag'Properties')
                          Body,←PrepareSubLinks publicStuff'Property'formattedScriptName
                          firstProperty←0
                      :EndIf
                      Body,←topRef,({(MakeBookmark ⍵),('h4 class="aplname" id="',GetChapterNo,':',('name'GetSingle this),'"')tag ⍵}('name'GetSingle this))
                      Body,←'p class="small"'tag'(',('access'GetSingle this),({0∊⍴⍵:'' ⋄ ',',⊃{⍺,', ',⍵}/⍵}('keywords'GetSingle this),('readonly'GetSingle this)/⊂'readonly'),')'
                      :If ~0∊⍴'more'GetSingle this
                          Body,←PolishMore'more'GetSingle this
                      :EndIf
                      :If ~0∊⍴'comments'GetSingle this
                          Body,←PolishComments('comments'GetSingle this)0 0 chapterNo
                      :EndIf
                  :Case 'Field'
                      :If firstField
                          Body,←((MakeBookmark'Fields'),('h3 id="',GetChapterNo,':fields"')tag'Fields')
                          Body,←PrepareSubLinks publicStuff'Field'formattedScriptName
                          firstField←0
                      :EndIf
                      Body,←topRef,{(MakeBookmark ⍵),('h4 class="aplname" id="',GetChapterNo,':',({⍵↑⍨¯1+⍵⍳'←'}'name'GetSingle this),'"')tag ⍵}{⍵↑⍨¯1+⍵⍳'←'}'name'GetSingle this
                      Body,←'p class="small"'tag(('access'GetSingle this),(('readonly'GetSingle this)/', readonly'))
                      :If ~0∊⍴'more'GetSingle this
                          Body,←PolishMore'more'GetSingle this
                      :EndIf
                      :If ~0∊⍴'comments'GetSingle this
                          Body,←PolishComments('comments'GetSingle this)0 0 chapterNo
                      :EndIf
                      :If ~0∊⍴'syntax'GetSingle this
                          Body,←'p class="aplcode"'tag'Initialised with: ',MarkupInlineAPL_Code{'`',⍵,'`'}dmb'syntax'GetSingle this
                      :EndIf
                  :Case 'Method'
                      :If firstMethod ⍝ this catches the first one. Further group changes are identified by a type change because these are sorted
                          methodType←'access'GetSingle this
                          Body,←{(MakeBookmark ⍵),('h3 id="',GetChapterNo,':',(Lowercase methodType),'methods"')tag ⍵}methodType,' Method',(1<+/'Method'∘≡¨Get publicStuff)/'s'
                          Body,←PrepareSubLinks publicStuff methodType formattedScriptName
                          firstMethod←0
                      :ElseIf methodType≢'access'GetSingle this
                          methodType←'access'GetSingle this
                          :If 'Public'≡'access'GetSingle this ⍝ these are interface methods
                              Body,←({(MakeBookmark ⍵),('h3 id="',GetChapterNo,':',(Lowercase methodType),'methods"')tag ⍵}('Method',(1<+/('Public'∘≡¨'access'Get publicStuff)∧~(Get publicStuff)∊'Constructor' 'Interface Method')/'s'),' from Interface')
                          :Else
                              Body,←({(MakeBookmark ⍵),('h3 id="',GetChapterNo,':',(Lowercase methodType),'methods"')tag ⍵}('access'GetSingle this),(' Method',(1<+/'Method'∘≡¨↑¨Get publicStuff)/'s'))
                          :EndIf
                          Body,←PrepareSubLinks publicStuff methodType formattedScriptName
                      :EndIf
                      Body,←topRef,({(MakeBookmark ⍵),('h4 class="aplname" id="',GetChapterNo,':',('name'GetSingle this),'"')tag ⍵}('name'GetSingle this))
                      Body,←SyntaxHelper'syntax'GetSingle this
                      :If ~0∊⍴'more'GetSingle this
                          Body,←PolishMore'more'GetSingle this
                      :EndIf
                      :If ~0∊⍴'comments'GetSingle this
                          Body,←PolishComments('comments'GetSingle this)0 0 chapterNo
                      :EndIf
                  :Case 'Interface Method' ⍝ implemented ones!
                      :If firstInterfaceMethod
                          Body,←({(MakeBookmark ⍵),('h3 id="',GetChapterNo,':','implementedinterfacemethods"')tag ⍵}('Implemented Interface Method',(1<+/'Method'∘≡¨Get publicStuff)/'s'))
                          methodType←GetSingle this
                          Body,←PrepareSubLinks publicStuff methodType formattedScriptName
                          firstInterfaceMethod←0
                      :EndIf
                      Body,←topRef,({(MakeBookmark ⍵),('h4 class="aplname" id="',GetChapterNo,':',('name'GetSingle this),'"')tag ⍵}('name'GetSingle this))
                      Body,←SyntaxHelper'syntax'GetSingle this
                      :If ~0∊⍴'more'GetSingle this
                          Body,←PolishMore'more'GetSingle this
                      :EndIf
                      :If ~0∊⍴'comments'GetSingle this
                          Body,←PolishComments('comments'GetSingle this)0 0 chapterNo
                      :EndIf
                  :EndSelect
              :EndFor
              _DOCS,←⊂formattedScriptName
              Body←'div class="content"'tag Body
              _HTML,←⊂Body
          :EndFor
      :EndIf
    ∇

    ∇ Reset
         ⍝ Reset all internal data structures. _
         ⍝ After having called this method the instance can be reused. HTML only.
      :Access Public Instance
      Init
    ∇

    ∇ r←Help
         ⍝ Explains just the main methods of `ADOC`.
      :Access Public shared
      r←''
      r,←⊂'--- ADOC ---'
      r,←⊂'The main methods of ADOC are:'
      r,←⊂'ADOC.List {scripts}     ⍝ prints useful overview to the session'
      r,←⊂'ADOC.Browse {scripts}   ⍝ create doc and displays it with IE7 by default'
      r,←⊂'ADOC.ProcessAsHtml {scripts} ''filename'' ⍝ creates a persistent HTML page'
      r,←⊂'(⎕NEW ADOC ''filename'').Make {scripts}'
      r←⊃r
    ∇

    ∇ FinaliseHtml dummy;head;html;path;screenStyles;printStyles;addExt;tmp;fn
      ⍝ Finalise the HTML by adding header, title and meta tags. _
      ⍝ It also changes any http&colon;// as well as mailto&colon;// and file&colon;// references _
      ⍝ into HTML anchors. After having called this method, the HTML is ready for beeing saved _
      ⍝ on disk. The property flag `htmlFinalised` is therefore set to 1.
      :Access Public Instance
      :If ~0∊⍴_HTML
          CreateTopOfBody ⍬
          CreateDocFooter ⍬
          :If ~_htmlFinalised
              _HTML←∊_HTML
              _HTML←MakeAnchor _HTML'http://'
              _HTML←MakeAnchor _HTML'mailto:'
              _HTML←MakeAnchor _HTML'file:///'
              html←'body'tag _HTML
              head←''
              head,←'<meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>',nl
              :If 2=⎕NC'Caption'
                  :If 0∊⍴Caption
                      head,←'title'tag 1⊃1⊃_META
                  :Else
                      head,←'title'tag Caption
                  :EndIf
              :Else
                  head,←'title'tag{1=⍴⍵:'ADOC: ',1 1⊃⍵ ⋄ 'ADOC: ',(⍕⍴⍵),' scripts'}_META
              :EndIf
              :If ~0∊⍴path←_CssPath
                  path,←'/'/⍨~(¯1↑path)∊'/\'
                  ((path='\')/path)←'/'
              :EndIf
              addExt←{'.css'≡¯4↑Lowercase ⍵:⍵ ⋄ ⍵,'.css'}
              :If _IncludeCss
                  :If 0∊⍴path
                      screenStyles←'style type="text/css" media="screen"'tag(⍴nl)↓∊nl∘,¨GetScreenCss
                      printStyles←'style type="text/css" media="print"'tag(⍴nl)↓∊nl∘,¨GetPrintCss
                  :Else
                      :Trap 22
                          screenStyles←'style type="text/css" media="screen"'tag(⍴nl)↓∊nl∘,¨ReadAnsiFile path,addExt CssScreen
                      :Else
                          screenStyles←'style type="text/css" media="screen"'tag(⍴nl)↓∊nl∘,¨GetScreenCss
                      :EndTrap
                      :Trap 22
                          printStyles←'style type="text/css" media="print"'tag(⍴nl)↓∊nl∘,¨ReadAnsiFile path,addExt CssPrint
                      :Else
                          printStyles←'style type="text/css" media="print"'tag(⍴nl)↓∊nl∘,¨GetPrintCss
                      :EndTrap
                  :EndIf
                  head,←screenStyles,printStyles
              :Else
                  fn←({⍵↓⍨1+-⌊/'\/'⍳⍨⌽⍵}GetTempFileName),addExt CssScreen
                  head,←'<link rel="stylesheet" type="text/css" charset="utf-8" media="all" href="file:///',path,fn,'" />',nl
                  fn←({⍵↓⍨1+-⌊/'\/'⍳⍨⌽⍵}GetTempFileName),addExt CssPrint
                  head,←'<link rel="stylesheet" type="text/css" charset="utf-8" media="print" href="file:///',path,fn,'" />',nl
              :EndIf
              head←'head'tag head
              html←'html xmlns="http://www.w3.org/1999/xhtml"'tag head,html
              html,⍨←'<?xml version="1.0" encoding="utf-8"?>',nl,'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',nl
              _HTML←html
              _htmlFinalised←1
          :Else
              11 ⎕SIGNAL⍨'HTML is already finalised'
          :EndIf
      :Else
          11 ⎕SIGNAL⍨'No HTML found to be finalised'
      :EndIf
    ∇

    ∇ {tempFilename}←{x}Browse y;scriptRef;PathToExe;browserPath;bool;allowed;isRef;cs;Note;⎕TRAP
         ⍝ By default, the default browser is used to display the result. _
         ⍝ You can change this by setting "BrowserPath" the the full path to _
         ⍝ an executable. Note that you can set these parameters _
         ⍝ via a parameter space that can be passed as left argument to "Browse":
         ⍝ * BrowserPath
         ⍝ * Caption
         ⍝ * IgnorePattern
         ⍝ * IncludeCss
         ⍝ * Inherit
         ⍝ * embeddedClassesFlag
         ⍝ * ignoreCopyright
         ⍝ * ignoreHistory
         ⍝ * ignoreVersion
         ⍝ Note that specifying a parameter via a parameter space does _
         ⍝ <b>not</b> save the value permanently.
         ⍝ The right argument can be one of:
         ⍝ # A reference pointing to a script, either class of namespace. _
         ⍝   Further references to this are made by "Reference to a script"
         ⍝ # The name of a niladic function inside an ordinary namepace that _
         ⍝   returns a vector of strings with the documentation. The name of _
         ⍝  the namespace is gathered from the path. This feature can be used _
         ⍝ to document ordinary namespace. Note that functions/operators _
         ⍝ marked up as ":Access Public" in such a namespace are honored by _
         ⍝ `ADOC`'. Further references to this are made by "Function".
         ⍝<h2> Reference to a script
         ⍝ If "scriptRef" is empty, the formerly created HTML is displayed.
         ⍝ If it is either the name of a class script or a namespace script, _
         ⍝ HTML with documentation is created and the browser then displays the _
         ⍝ result. Note that in this case any formerly created HTML remains _
         ⍝ untouched. Therefore, it can still be used for other purposes.
         ⍝ You can pass the name of one ore more embedded classes (classes _
         ⍝ locally defined within a class script - see `#.ADOC` itself as an _
         ⍝ example). You get then a document which contains only these embedded _
         ⍝ class(es). Note that this syntax is available only when a single _
         ⍝ script is specified in the right argument.
         ⍝<h2> Function
         ⍝ This syntax can be used to document ordinary namespaces. The rules _
         ⍝ for "leading comments" in a class take place as well.
      :Access Public shared
⍝⍝      ⎕TRAP←(999 'E' '∆EM ⎕signal 11')((0 1000)'N')
      isRef←{⍵≢⍕¨⍵}y
      tempFilename←''
      _Caption←''

      Init_HTML
      :If 0<⎕NC'x'
          :If 9=⎕NC'x' ⍝ is it a parameter space?
              allowed←CreateBrowseDefaults.List
              :If 0∊bool←(x.⎕NL-2)∊allowed
                  11 ⎕SIGNAL⍨'Invalid: ',⊃{⍺,',',⍵}/(~bool)⌿x.⎕NL-2
              :EndIf
              bool←(x.⎕NL-2)∊allowed~⊂'RefToUnicodeFile'
              x.⎕EX(~bool)⌿x.⎕NL 2      ⍝ "RefToUnicodeFile"...
              x.⎕EX x.⎕NL 9             ⍝ ...is now depricated
          :AndIf ~0∊⍴x.⎕NL 2 9
              ⎕SHADOW¨'_',¨x.⎕NL-2     ⍝ Keep them local - we don't want to overwrite the real fields/props
              ⍎¨GetVarsFrom x
          :Else
              :If 0=1↑0⍴∊x
                  _embeddedClassesFlag←x
              :Else
                  _embeddedClassesFlag←1
                  _embeddedClassNames←x
              :EndIf
          :EndIf
      :EndIf

      :If 0∊⍴y
          :If _htmlFinalised
              tempFilename←GetTempFileName
          :Else
              11 ⎕SIGNAL⍨'I''m afraid, there is no HTML ready for being displayed'
          :EndIf
      :Else
          _embeddedClassNames←Fill_META y _embeddedClassesFlag _embeddedClassNames
          :If ~0∊⍴_META
              _WithRunningNumbers←{¯1=⍵:1<⍴_META ⋄ ⍵}_WithRunningNumbers
              cs←⎕NS''
              cs.sortByNameFlag←sortByNameFlag
              cs.bigPicture←bigPicture
              CreateHtml cs
              :If 0∊⍴_HTML
                  ⎕←'Nothing found'
              :Else
                  FinaliseHtml ⍬
                  tempFilename←{'html',⍨¯3↓⍵}GetTempFileName
                  SaveHtml2File tempFilename
              :EndIf
          :EndIf
      :EndIf
      :If ~0∊⍴tempFilename
          View tempFilename
      :EndIf
      _embeddedClassName←''
    ∇

    ∇ r←{verbose}List scriptName;buffer;data;bool;my;nl;keywords
       ⍝ Prints the most important facts about the given script to the session window _
       ⍝ By default, only the names of functions are reported. To get syntax information, _
       ⍝ pass either a 1 or "full" as left argument to `#.ADOC.List`.
      :Access Public Shared
      'Please pass references only!'⎕SIGNAL 11/⍨{⍵≡⍕¨⍵}scriptName
      r←''
      verbose←{2=⎕NC ⍵:⍎⍵ ⋄ 0}'verbose'
      verbose←{IsChar ⍵:'full'≡Lowercase ⍵ ⋄ (,1)≡,⍵}verbose
      nl←,⎕UCS 13
      :If 9.5 9.4 9.1∊⍨(⍎1⊃⎕NSI){⍺.⎕NC ⍵}⊂⍕scriptName
          my←⎕NEW ⎕THIS
          my.Analyze scriptName
          data←5⊃1⊃my.Meta
          r,←nl,⍨'*** ',' ***',⍨⊃{0∊⍴3⊃⍵:{⍺,' (',⍵,')'}/⍵[1 2] ⋄ {⍺,' < ',⍵}/⍵[1 3]}3↑1⊃my.Meta

          :If 1∊bool←'Constructor'∘≡¨Get data
          :AndIf ~0∊⍴buffer←'syntax'Get bool/data
              r,←nl,'Constructors:'
              r,←⊃,/nl,¨'  '∘,¨'syntax'Get bool/data
          :EndIf

          :If ~0∊⍴buffer←('Property'∘≡¨Get data)⌿data
              :If 0<+/bool←'Instance'∘≡¨'access'Get buffer
                  r,←nl,'Instance Properties:'
                  keywords←ProcessKeywords bool/buffer
                  r,←⊃,/nl,¨'  '∘,¨('name'Get bool/buffer),¨keywords
              :EndIf
              :If 0<+/bool←~bool
                  r,←nl,'Shared Properties:'
                  keywords←ProcessKeywords bool/buffer
                  r,←⊃,/nl,¨'  '∘,¨('name'Get bool/buffer),¨keywords
              :EndIf
          :EndIf

          :If ~0∊⍴buffer←data/⍨'Field'∘≡¨Get data
              :If 0<+/bool←'Instance'∘≡¨'access'Get buffer
                  r,←nl,'Instance Fields:'
                  r,←⊃,/nl,¨'  '∘,¨{⍵↓⍨+/∧\' '=⍵}¨'readonly'∘{∨/⍺⍷Lowercase ⍵:(' (',⍺,')'),⍨⍵ ⋄ ⍵}¨'name'Get bool/buffer
              :EndIf
              :If 0<+/bool←~bool
                  r,←nl,'Shared Fields:'
                  r,←⊃,/nl,¨'  '∘,¨'name'Get bool/buffer
              :EndIf
          :EndIf

          :If ~0∊⍴buffer←data/⍨'Method'∘≡¨Get data
              :If 0<+/bool←'Instance'∘≡¨'access'Get buffer
                  r,←nl,'Instance Methods:'
                  r,←⊃,/nl,¨'  '∘,¨((1+verbose)⊃'name' 'syntax')Get bool/buffer
              :EndIf
              :If 0<+/bool←'Shared'∘≡¨'access'Get buffer
                  r,←nl,'Shared Methods:'
                  r,←⊃,/nl,¨'  '∘,¨((1+verbose)⊃'name' 'syntax')Get bool/buffer
              :EndIf
              :If 0<+/bool←'Public'∘≡¨'access'Get buffer ⍝ True if interface
                  r,←nl,'Methods (from Interface):'
                  r,←⊃,/nl,¨'  '∘,¨((1+verbose)⊃'name' 'syntax')Get bool/buffer
              :EndIf
          :EndIf

          :If ~0∊⍴buffer←data/⍨'Interface Method'∘≡¨Get data
              r,←nl,'Implemented Interface(s):'
              r,←⊃,/nl,¨'  '∘,¨((1+verbose)⊃'name' 'syntax')Get buffer
          :EndIf
      :EndIf
    ∇

    ∇ ProcessAsHtml(scripts filename);myDoc;key;newname
      ⍝ Process one or more scripts and write the resulting HTML into "filename" _
      ⍝ which defaults (if empty) to the scrit name (without "#.") in the current directory.
      :Access Public shared
      'Please pass references only!'⎕SIGNAL 11/⍨{⍵≡⍕¨⍵}scripts
      :If 0∊⍴filename
          filename←'.html',⍨{⍵↓⍨2×'#.'≡2↑⍵}⍕scripts
          (key newname)←FileBox''filename('Save ADOC file "',filename,'"')
          →('OK'≢key)/0
          filename←newname
      :ElseIf '/\/'∊⍨¯1↑filename
          filename,←'.html',⍨{⍵↓⍨2×'#.'≡2↑⍵}⍕scripts
      :EndIf
      myDoc←⎕NEW ⎕THIS
      myDoc.FullDocName←filename
      myDoc.Analyze scripts
      myDoc.CreateHtml ⍬
      myDoc.FinaliseHtml ⍬
      myDoc.SaveHtml2File filename
    ∇

    ∇ cs←CreateBrowseDefaults
         ⍝ Creates a namespace and populates it with defaults values for the `Browse` method.
         ⍝ The result namespace can then be passed as left argument to `ADOC.Browse`.
      :Access Public Shared
      cs←⎕NS''
      cs.Caption←_Caption
      cs.IgnorePattern←_IgnorePattern
      cs.embeddedClassesFlag←0
      cs.Inherit←_Inherit
      cs.ignoreCopyright←0
      cs.ignoreHistory←0
      cs.ignoreVersion←0
      cs.BrowserPath←_BrowserPath
      cs.IncludeCss←1
      cs.withColor←1
      cs.⎕FX'r←List' 'r←⎕nl -2'
    ∇

    ∇ {filename}←Make y;scripts;isRef
          ⍝ Instance-aquivalent of "ProcessAsHtml". After having instanciated `ADOC` you _
          ⍝ can set properties/fields to make `ADOC` fit your needs. Then you can call _
          ⍝ "Make" to create the final document without further action.
      :Access Public Instance
      isRef←{⍵≢⍕⍵}y
      :If isRef
          Analyze y
      :ElseIf 3=⎕NC y
          AnalyzeOrdinaryNamespace y
      :Else
          'Invalid right argument'⎕SIGNAL 11
      :EndIf
      CreateHtml ⍬
      FinaliseHtml ⍬
      filename←SaveHtml2File ⍬
    ∇

    ∇ r←Copyright;⎕IO
         ⍝ Returns a copyright notice regarding `ADOC`.
      :Access Public Shared
      ⎕IO←1
      r←''
      r,←⊂'This source code is provided to you "as is" without warranties or '
      r,←⊂'conditions of any kind, whether expressed or implied. Your use of '
      r,←⊂'the source code is entirely at your own risk. Should the software '
      r,←⊂'prove defective, you assume the entire cost of all service, repair '
      r,←⊂'or correction.'
      r←,[1.5]r
    ∇

⍝ --------------- Private

    ∇ r←PrepareSubLinks(data type scriptName);bool;noof;links;list
      ⍝ Prepare a link list if at least 2 items are found for a given type.
      ⍝ Make it a numbered list if more than 4 items are linked to.
      r←⍬
      :If 0=⎕NC'OutputType' ⍝ is it an instance?
      :OrIf OutputType≡'Web'
          :If 'Property'≡type
              noof←+/bool←'Property'∘≡¨Get data
          :ElseIf 'Field'≡type
              noof←+/bool←'Field'∘≡¨Get data
          :ElseIf 'Interface Method'≡type
              noof←+/bool←('Interface Method'∘≡¨Get data)
          :Else
              noof←+/bool←('Method'∘≡¨Get data)∧type∘≡¨'access'Get data
          :EndIf
          :If 2≥noof
              r←''
          :Else
              :If ~0∊⍴list←'name'Get bool/data
              :AndIf ~0∊⍴list←(0<↑∘⍴¨list)/list
                  list←{⍵↑⍨¯1+⍵⍳'←'}¨list
                  list←list[SortAlphabet⍋⊃list]
                  :If 4≥⍴list
                      links←nl,⍨⊃,/{⍺,' | ',⍵}/{('a href="#',(GetChapterNo,':',⍵),'"')tag ⍵}¨list
                      r←'div class="sublinks"'tag links
                  :Else
                      links←'ol'tag⊃,/'li'∘tag¨{('a href="#',(GetChapterNo,':',⍵),'"')tag ⍵}¨list
                      r←'div class="sublinks"'tag links
                  :EndIf
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←type SortMethods data;bool;buffer
      ⍝ Sort the methods in "data" alphabetically. "type" is one of: Instance, Shared or Public (Interface!)
      :If ~0∊⍴r←data
          bool←2=↑∘⍴∘⍴¨data
      :AndIf 1∊bool←bool\'Method'∘≡¨Get bool/data
          :If 0<+/bool←bool\type∘≡¨'access'Get bool/data
              buffer←bool/r
              buffer←{⍵[SortAlphabet⍋⊃'name'Get buffer]}buffer
              (bool/r)←buffer
          :EndIf
      :EndIf
    ∇

    ∇ r←type Sort data;bool;buffer
      ⍝ Sort "type" in "data" alphabetically. "type" is one of: Property, Field
      :If ~0∊⍴r←data
          bool←2=↑∘⍴∘⍴¨r
          bool←bool\type∘≡¨Get bool/r
      :AndIf ~0∊⍴buffer←bool/r
          buffer←{⍵[SortAlphabet⍋⊃'name'Get buffer]}buffer
          (bool/r)←buffer
      :EndIf
    ∇

    ∇ r←MakeAnchor(html pattern);where;i;ref
     ⍝ Look for "pattern" in html and make all occurencies an anchor. _
     ⍝ Typically "pattern" is something like "http://x.y.z" or "mailto:x@y.z" _
     ⍝ of "file:///foo.txt"; You can prevent this from happening with a leading "!"
      :If ~0∊⍴where←⌽{⍵/⍳⍴,⍵}pattern⍷r←html
          :For i :In where
              :If '!'=¯1↑r←(i-1)⌽r
                  r←(-i-2)⌽¯1↓r
              :Else
                  ref←{⍵↑⍨¯1+⌊/⍵⍳'  <'}r
                  r←(-i-1)⌽(('a class="externallink" href="',(ref),'"')tag ref),(⍴ref)↓r
              :EndIf
          :EndFor
      :EndIf
    ∇

    ∇ r←GetRequireInfo txt;bool
      ⍝ Looks for "require"d classes/namespaces
      r←⍬
      :If 0<+/bool←∨/¨'⍝∇:require'∘⍷¨Lowercase txt
          r←' '~¨⍨{⍵↓⍨⍵⍳'='}¨bool/txt
          r←r[SortAlphabet⍋⊃r]
      :EndIf
    ∇

    ∇ (prop remark)←SplitAtLamp data;bool;firstLine
       ⍝ Split "data" not only at the lamp (easy) but takes text into account, too. _
       ⍝ So this   :'foo←''⍝''  ⍝ assign lamp<br>    is handled correctly, too.
      remark←''
      (firstLine data)←{(1⊃⍵)(1↓⍵)}data
      data←(':'≠↑¨data~¨' ')/data ⍝ remove lines like ":Access" and similars
      :If '⍝'∊firstLine/⍨bool←~MaskText firstLine
          (prop remark)←firstLine{((⍵-1)↑⍺)({⍵↓⍨+/∧\' '=⍵}⍵↓⍺)}'⍝'⍳⍨bool\bool/firstLine
          prop←{⍵↓⍨+/∧\' '=⍵}({⍵↓⍨⍵⍳' '}prop)
      :Else
          prop←firstLine
      :EndIf
      :If ~0∊⍴data←({∧\'⍝'=↑⍵~' '}¨data)/data
          remark←{⍵/⍨0<↑∘⍴¨,¨⍵}(⊂remark),data
      :EndIf
      remark←{0 1∊⍨≡⍵:⊂⍵ ⋄ ⍵}remark
      remark←{⍵↓⍨+/∧\⍵∊' ⍝'}¨remark
    ∇

    ∇ R←GetTempFileName;GetTempFileName;GetTempPath;PathName
         ⍝ Returns a fully qualified temporary filename
      'GetTempFileName'⎕NA'I4 KERNEL32.C32|GetTempFileName',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' <0T <0T I4 >0T'
      'GetTempPath'⎕NA'I4 KERNEL32.C32|GetTempPath',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' I4 >T[]'
      :If 0∊⍴PathName←↑↑/GetTempPath 260 260
          'Could not get name of temp path'⎕SIGNAL GetLastError ⍬
      :ElseIf 0∊⍴,R←2⊃GetTempFileName PathName'' 1 260
          'Could not get a temp file name'⎕SIGNAL GetLastError ⍬
      :EndIf
    ∇

    ∇ r←PolishComments(data hasContainers isContainer chapterNo);noof;bool;counter;level;this_;level2;bool2;level3;type;tt;this;ind;buffer;i
         ⍝ Prepare "leading" comments. Treats...
         ⍝ # " _" at the end of a line as "concatenate" command
         ⍝ # "* " at the beginning of a line gets an ordered list
         ⍝ # "# " at the beginning of a line gets an unordered list
         ⍝ # "||" defines cells.
         ⍝ `{⍵/⍳⍴,⍵` as inline APL code
         ⍝ <pre>
         ⍝ ⍝`````  as start/end of a code block
         ⍝</pre>
         ⍝ HTML tags in the comments remain untouched
⍝      ⍎(∨/'Returns a matrix with all fields starting their names with'⍷∊data)/'.'
      r←'<div class="header">'
      suppressTag_P←resetTag_P←0
      counter←1
      data←isContainer↓,data
      :Repeat
          this←dlb 1⊃,data
⍝          ⍎(∨/'ADOC.Browse'⍷∊this)/'.'
          :If '<'=↑this
          :OrIf '````'≡4⍴this
              :If ∨/'<pre>'⍷this
                  noof←1⍳⍨∨/¨'</pre>'∘⍷¨data
                  this←noof↑data
                  data←noof↓data
                  (1⊃this)←(⍴'<pre>')↓dlb 1⊃this        ⍝ remove leading <pre> from first
                  (↑⌽this)←(⌽'</pre>'){⌽⍵↓⍨(⍴⍺)×⍺≡(⍴⍺)↑⍵}dlb⌽↑⌽this ⍝ remove trailing </pre> from last
                  this←(0<↑∘⍴¨dlb¨this)/this
                  this←⊃,/this,¨1⊃nl                    ⍝ Add NewLine chars and simplify
                  this←(nl[1]=1↑this)↓this              ⍝ First line empty? Remove!
                  this←(-0∊⍴' '~⍨{⍵⊃⍨⍴⍵}this)↓this      ⍝ Last line empty? Remove!
                  this←ReplaceHtmlSpecialChars this
                  this←'<pre>',nl[1],this,'</pre>',nl[1]
                  r,←this
              :ElseIf ∨/'````'⍷this
                  noof←1⍳⍨∨/¨'````'∘⍷¨{(⊂4↓1⊃⍵),1↓⍵}data
                  this←noof↑data
                  data←noof↓data
                  (1⊃this)←(⍴'````')↓dlb 1⊃this         ⍝ remove leading ```` from first
                  (↑⌽this)←(-⍴'````')↓dtb↑⌽this         ⍝ remove trailing ```` from last
                  this←(0<↑∘⍴¨dlb¨this)/this
                  this←⊃,/this,¨1⊃nl                    ⍝ Add NewLine chars and simplify
                  this←(nl[1]=1↑this)↓this              ⍝ First line empty? Remove!
                  this←(-0∊⍴' '~⍨{⍵⊃⍨⍴⍵}this)↓this      ⍝ Last line empty? Remove!
                  this←ReplaceHtmlSpecialChars this
                  this←'<pre>',nl[1],this,'</pre>',nl[1]
                  r,←this
              :ElseIf ∨/'<index>'⍷this
                  data←1↓data   ⍝ For HTML pages, there is no index
              :Else
                  this↓⍨←+/∧\' '=this
                  this←ProcessHtag this
                  r,←this,nl
                  data←1↓data
              :EndIf
          :Else
              :Select 2↑this
              :CaseList '* ' '# '                   ⍝ ordered and unordered lists
                  type←'* '≡2↑this                  ⍝ 1=unordered list, 0=ordered
                  noof←CalcNoOfListItems data
                  this←noof↑,data
                  data←noof↓data
                  this←CompressList this
                  this←MarkupBookmarks∘MarkupInlineAPL_Code∘MarkupBold¨this
                  :If 1=⍴∪level2←+/¨∧\¨' '=this
                      this←{⍵↓⍨+/∧\' '=⍵}¨this
                      level2←+/¨∧\¨' '=this
                  :EndIf
                  'Nested lists are supported but one nesting level only'⎕SIGNAL 11/⍨~0∊⍴,level2~0 1 3
                  :If 3∊level2
                      bool2←1,2≠/level2
                      this←bool2{⎕ML←1 ⋄ ⍺⊂⍵}this
                      level3←↑,/bool2⊂level2
                      ind←({⍵/⍳⍴,⍵}3=level3)
                      tt←'ol' 'ul'[1+'*'=↑¨dlb¨↑¨↑¨ind⌷¨⊂this]
                      :For i :In ⍳⍴ind
                          buffer←↑(i⊃ind)⌷this
                          buffer←((i⊃tt),' class="listlevel2"')tag⊃,/{'li'tag 2↓dlb ⍵}¨buffer
                          ((i⊃ind)⌷this)←⊂⊂buffer
                      :EndFor
                      tt←((1+type)⊃'ol' 'ul')
                      ((1=level3)/this)←2↓¨¨(1=level3)/this
                      ((1=level3)/this)←{'li'∘tag¨⍵}¨(1=level3)/this
                      this←tt tag↑,/↑,/this
                  :Else
                      tt←(1+type)⊃'ol' 'ul'
                      this←tt tag⊃,/'li'∘tag¨2↓¨this
                  :EndIf
              :Case '||'
                  noof←+/∧\'||'∘≡¨2↑¨dlb¨data
                  this←dlb¨noof↑data
                  data←noof↓data
                  this←¯1↓[2]2↓[2]⊃'||'∘Split¨this
                  ((,0=↑¨⍴¨this~¨' ')/,this)←⊂'&nbsp;'
                  this←MarkupBookmarks∘MarkupInlineAPL_Code∘MarkupBold∘dlb∘dtb¨this
                  this←'table'tag⊃,/'tr'∘tag¨⊃¨,/¨'td'∘tag¨¨↓this
              :Else
                  :If {0∊⍴⍵:0 ⋄ ∧/⍵}bool←({⍵↑⍨¯1+⍵⍳' '}this)='='
                      :If 1=+/bool  ⍝ Ignore top level
                          this←''
                      :Else
                          this←{(MakeBookmark ⍵),{⍵{'<h',⍵,'>',⍺,'</h',⍵,'>'}⍕(+/bool)+hasContainers-isContainer}⍵}{⍵↓⍨⍵⍳' '}this
                      :EndIf
                      data←1↓data
                  :Else
                      :If ' _'≡¯2↑dmb this
                          noof←1++/∧\' _'∘≡¨¯2↑¨dmb¨data
                          this←⊃,/{(¯1↓¨¯1↓⍵),¯1↑⍵}noof↑{⍵↓⍨-+/∧\' '=⌽⍵}¨data
                          data←noof↓data
                      :Else
                          data←1↓data
                      :EndIf
                      this←MarkupBookmarks MarkupInlineAPL_Code MarkupBold this
                      this←tag this
                  :EndIf
              :EndSelect
              r,←this
          :EndIf
      :Until 0∊⍴data
      r,←'</div>'
    ∇

    ∇ r←PolishMore data
         ⍝ Make the "more" data ready for use - if any
      r←⊃,/{('<p>',⍵,'</p>'),nl}¨data
    ∇

    ∇ r←ProcessHtag r;bm;level
      :If '<h>'≡1 1 0 1/4↑r ⍝ is it an <h{n}>-tag?
          r←dtb r
          bm←MakeBookmark{⍵↑⍨¯1+⍵⍳'<'}{⍵↓⍨⍵⍳'>'}r
      :AndIf '</h>'≢1 1 1 0 1/¯5↑r
          level←{2↓¯1↓r↑⍨r⍳'>'}r
          r,←'</h',level,'>'
      :EndIf
    ∇

      ReplaceHtmlSpecialChars←{
          s←⍵           ⍝ Simple string, typically APL code
          bool1←'&'=s
          bool2←'<'=s
          bool3←'>'=s
          (bool1/s)←⊂'&amp;'
          (bool2/s)←⊂'&lt;'
          (bool3/s)←⊂'&gt;'
          ∊s
      }


    ∇ r←AnalyzeFns(isInterface noof source masked);body;data;bool;type;access;syntax;remarks;buffer;noof;name;keywords;more
⍝      ⍎(∨/'{tempFilename}←{x}Browse y'⍷∊source)/'.'
      r←⍬
      more←''
      buffer←⊃dmb¨masked
      keywords←''
      :If 0<+/bool←∨/¨∨/¨':implements constructor' ':implements destructor' ':implements method '⍷¨⊂buffer
          :Select ↑bool⍳1
          :Case 1
              type←'Constructor'
              access←'Public'
          :Case 2
              type←'Destructor'
              access←'Private'
          :Case 3 ⍝ interface method
              type←'Interface Method'
              access←'Public'
              more,←⊂1↓↑(∨/':implements '⍷⊃masked)/source
          :EndSelect
      :Else
          :If ∨/∨/':access'⍷buffer
              type←'Method'
              buffer⌷[1]⍨←1⍳⍨∨/':access '⍷buffer
              :If ∨/'shared'⍷buffer
                  access←'Shared'
              :Else ⍝ Therefore, it MUST be "instanced"
                  access←'Instance'
               ⍝ Only "instance" methods may be overridable:
                  :If ∨/' overridable'⍷buffer
                      more,←⊂'Overridable'
                  :EndIf
              :EndIf
               ⍝ Only "instance" methods may override:
              :If ∨/' override'⍷buffer
                  more,←⊂'Override'
              :EndIf
          :ElseIf isInterface
              type←'Method'
              access←'Instance'  ⍝ Interface methods are always "Public" and therefore either "Instance" or "Shared"!
              buffer←''
          :Else
              :GoTo 0
          :EndIf
          keywords←({(Uppercase 1↑⍵),Lowercase 1↓⍵}¨{' 'Split ⍵↓⍨⍵⍳' '}buffer)~'Public' 'Instance' 'Shared'
          :If (⊂'private')∊Lowercase keywords
              :Return
          :EndIf
      :EndIf
      syntax←dmb{⍵↑⍨¯1+⍵⍳';'}{⍵↓⍨+/∧\' '=⍵}'∇'~⍨1⊃source
      syntax↑⍨←¯1+syntax⍳'⍝'
      syntax←{~'}'∊⍵:⍵ ⋄ b←'}'=w←⍵ ⋄ (b/w)←⊂'} ' ⋄ ∊w}syntax
      syntax←{~':'∊⍵:⍵ ⋄ ⍵↑⍨¯1+⍵⍳':'}syntax
      syntax←{~'←'∊⍵:⍵ ⋄ b←'←'=w←⍵ ⋄ (b/w)←⊂' ← ' ⋄ ∊w}syntax
      syntax←dmb syntax ⍝ { and ← in the same header results in "  "
      remarks←''
      :If ~0∊⍴{⍵/⍨'⍝'=↑¨⍵}buffer←1↓noof↑source ⍝ remarks
          buffer/⍨←{~∨/∨/¨':access' ':implements'{⍺≡Lowercase(⍴⍺)↑⍵}¨⊂⍵}∘dlb¨buffer
          buffer↓¨⍨←{+/∧\' '=⍵}¨buffer
          buffer↑⍨←+/∧\'⍝'=↑¨buffer
          buffer⌿⍨←'⍝⍝'∘≢¨2⍴¨buffer
      :AndIf ~0∊⍴buffer←1↓¨buffer
          remarks←{⍵,' '/⍨' '≠↑¯1↑⍵}¨buffer
      :EndIf

      name←{'←'∊⍵:⍵↓⍨⍵⍳'←' ⋄ ⍵}syntax
      name←{'('∊⍵:(⍵↑⍨(¯1+⍵⍳'(')),' dummy' ⋄ ⍵}dmb name
      name←dmb{'{'∊⍵:⍵↓⍨⍵⍳'}' ⋄ ⍵}name
      name←dmb name
      :Select +/' '=name
      :Case 0
          ⍝ already fine
      :Case 1
          name↑⍨←¯1+name⍳' '
      :Case 2
          name←{⍵↑⍨¯1+⍵⍳' '}{⍵↓⍨⍵⍳' '}name
      :EndSelect
      name←{'('∊⍵:⍵↑⍨¯1+⍵⍳'(' ⋄ ⍵}name
      name←{⍵⊃⍨1 1 2 3[1 2 3 4⍳⍴⍵]}' 'Split name ⍝ 4 because of the inserted blanks
      :If IgnorePattern{0∊⍴⍺:1 ⋄ ⍺∨.≠(⍴,⍺)↑⍵}name
           ⍝ A method name may appear again: an included namespace may provide a
           ⍝ method with a name also used in the container class. Therefore, any
           ⍝ additional occurance must be ignored!
          :If 0∊⍴publishedStuff
          :OrIf ~(⊂name)∊(⊂'')~⍨{'Method'≢2⊃⍵[⍵[1;]⍳⊂'type';]:'' ⋄ 2⊃⍵[⍵[;1]⍳⊂'name';]}¨publishedStuff
              r←⊃('type'type)('name'name)('access'access)('syntax'syntax)('keywords'keywords)('more'more)('comments'remarks)
          :EndIf
      :EndIf
    ∇

    ∇ r←AnalyzeHeader(ref header);txt;cmd;noof;bool;bool2;flags;last;body
      r←⍬
      :If ~0∊⍴header
          :Repeat
              (cmd txt)←{⍵{a←⍵⍳' ' ⋄ (1↓(a-1)↑⍺)(a↓⍺)}⍵}1⊃header
              :If 0<noof←+/∧\'⍝'=↑¨header
                  txt←1↓¨noof↑header
                  bool←⊃∧/'<pre>' '</pre>'{∨/¨⍺∘⍷¨⍵}¨⊂txt
                  bool∨←∨/¨'````'∘⍷¨txt
                  (bool/txt)←{⍵↓⍨+/∧\' '=⍵}¨bool/txt
                  txt/⍨←~∨/¨(⊂'⍝∇:require')⍷¨txt
                  r,←⊂'Txt'txt
              :Else ⍝ nothing we can do here, really!
                  noof←⍴header
              :EndIf
          :Until 0∊⍴header←noof↓header
          r←r HandleVersionInHeader ref
          r←r HandleCopyRightInHeader ref
          r←r HandleHistoryInHeader ref
      :EndIf
    ∇

    ∇ r←r HandleVersionInHeader ref;txt;body;last
    ⍝ Handle special case: is there a function `Version`, and does it return the right stuff?
      :Trap 0 ⍝ not nice, but these calls may very well fail
          :If ~ignoreVersion
          :AndIf (⊂'Version')∊ref.⎕NL-3 ⍝ Is there a "Version" function?
              txt←''
              :If 9.1≡⎕NC⊂⍕ref  ⍝ Is it an ordinary namespace?!
                  body←ref.⎕NR'Version'
                  :If ∨/(⊃Lowercase dlb¨body){((⍴,⍵)↑[2]⍺)∧.=⍵}':access public shared'
                      txt←ref.{11::'' ⋄ ,⍎⍵}'Version'
                  :EndIf
              :Else
                  txt←ref.Version
              :EndIf
              :If ~0∊⍴txt
                  txt←,/'Version ' ' from ',¨1↓txt
                  txt←(⊂'<h2>Version</h2>'),txt
                  last←⍴r
                  (last⊃r)←txt{⍵[1],(⊂(2⊃⍵),⍺)}last⊃r
              :EndIf
          :EndIf
      :EndTrap
    ∇
    ∇ r←r HandleCopyRightInHeader ref;txt;body;flags;last
    ⍝ Handle special case: is there a function `Copyright`, and does it return the right stuff?
      :Trap ⍬ ⍝ not nice, but these calls may very well fail
          :If ~_ignoreCopyright
          :AndIf (⊂'Copyright')∊ref.⎕NL-3 ⍝ Is there a "Copyright" function?
              txt←''
              :If 9.1≡⎕NC⊂⍕ref  ⍝ Is it an ordinary namespace?!
                  body←ref.⎕NR'Copyright'
                  :If ∨/(⊃Lowercase dlb¨body){((⍴,⍵)↑[2]⍺)∧.=⍵}':access public shared'
                      txt←ref.{11::'' ⋄ ,⍎⍵}'Copyright'
                  :EndIf
              :Else
                  txt←{0 1∊⍨≡⍵:,⊂⍵ ⋄ 2=⍴⍴⍵:↓⍵ ⋄ ⍵},ref.Copyright
              :EndIf
              :If ~0∊⍴txt
                  flags←~{(↑¯1↑⍵)}¨txt∊'?.!' ⍝ All paragraphs that do NOT end with one of ".!?"...
                  flags∧←0<↑∘⍴¨txt           ⍝ ... AND that are not empty...
                  flags∧←↑¨' _'∘≢¨¯2↑¨txt    ⍝ ... AND that do not end with " _" already
                  flags[⍴flags]←0
                  (flags/txt)←(flags/txt),¨⊂' _'
                  txt←Compress txt
                  txt←(⊂'<h2>Copyright</h2>'),txt
                  last←⍴r
                  (last⊃r)←txt{⍵[1],(⊂(2⊃⍵),⍺)}last⊃r
              :EndIf
          :EndIf
      :EndTrap
    ∇
    ∇ r←r HandleHistoryInHeader ref;txt;body;last
    ⍝ Handle special case: is there a function `History`, and does it return the right stuff?
      :Trap 0 ⍝ not nice, but these calls may very well fail
          :If ~_ignoreHistory
          :AndIf (⊂'History')∊ref.⎕NL-3 ⍝ Is there a "History" function?
              txt←''
              :If 9.1≡⎕NC⊂⍕ref  ⍝ Is it an ordinary namespace?!
                  body←ref.⎕NR'History'
                  :If ∨/(⊃Lowercase dlb¨body){((⍴,⍵)↑[2]⍺)∧.=⍵}':access public shared'
                      txt←ref.{11::'' ⋄ ⍎⍵}'History'
                  :EndIf
              :Else
                  txt←ref.History
              :EndIf
              :If ~0∊⍴txt
                  :If 2=⍴⍴txt
                      txt←{'<pre>',⍵,'</pre>'}¨↓⎕FMT txt
                  :EndIf
                  txt←{2=≡⍵:⍵ ⋄ ↓⍵}txt
                  txt←(⊂'<h2>History</h2>'),txt
                  last←⍴r
                  (last⊃r)←txt{⍵[1],(⊂(2⊃⍵),⍺)}last⊃r
              :EndIf
          :EndIf
      :EndTrap
    ∇

    ∇ r←AnalyzeProperty(noof source masked);noof;buffer;bool;result;remarks;keywords;name
      r←⍬
      :If ∨/bool←∨/¨':access public'∘⍷¨dmb¨masked
          result←⊂'type' 'Property'
          (buffer remarks)←SplitAtLamp source
          (name keywords)←{((⍴⍵)⊃⍵)(¯1↓⍵)}' 'Split dmb buffer
      :AndIf IgnorePattern{0∊⍴⍺:1 ⋄ ⍺∨.≠(⍴,⍺)↑⍵}name
          keywords↓⍨←':'=↑↑keywords
          result,←⊂'name'name
          result,←⊂'access'(↑('Instance' 'Shared')[1+∨/∨/⊃'shared'∘⍷¨{(⊂⍵)⊃¨⍨{⍵/⍳⍴,⍵}∨/¨':access'∘⍷¨⍵},¨masked])
          result,←⊂'readonly'(~∨/'∇set'⍷∊source~¨' ')
          :If 0∊⍴remarks
              result,←⊂'comments'((+/∧\'⍝'={↑¨⍵~¨' '}1↓source)↑1↓source)
          :Else
              result,←⊂'comments'({0 1∊⍨≡⍵:⊂⍵ ⋄ ⍵}remarks)
          :EndIf
          result,←⊂'keywords'keywords
          result,←⊂'more' ''
          r←⊃result
      :EndIf
    ∇

    ∇ r←AnalyzeField(source masked);noof;buffer;type;bool;remarks
      r←⍬
      noof←1
      :If ∨/' public '⍷masked
          buffer←' 'Split dmb source
          type←⊃('Instance' 'Shared')[1+'shared'≡Lowercase 3⊃buffer]
          :If ∨/'⍝'∊¨source/⍨bool←~MaskText source
              (buffer remarks)←source{((⍵-1)↑⍺)({⍵↓⍨+/∧\' '=⍵}⍵↓⍺)}'⍝'⍳⍨bool\bool/source
              remarks←{2=≡⍵:⍵ ⋄ ⊂⍵}remarks
              buffer←' 'Split buffer
          :Else
              remarks←''
          :EndIf
          buffer←dlb⊃,/' ',¨buffer/⍨~(Lowercase buffer)∊':field' 'public' 'instance' 'shared' 'readonly'
          :If IgnorePattern{0∊⍴⍺:1 ⋄ ⍺∨.≠(⍴,⍺)↑⍵}buffer
              r←⊃('type' 'Field')('name'(buffer↑⍨¯1+buffer⍳'←'))('syntax'(buffer↓⍨buffer⍳'←'))('access'type)('comments'remarks)('more' '')('readonly'(∨/' readonly '⍷Lowercase' ',source,' '))
          :EndIf
      :EndIf
    ∇

    ∇ {r}←{embeddedClassNames}Analyze_ scriptRef;formattedScriptName;origSource;require;headerDoc;mask;origSource;commentsStartAt;noof;this;currentline;maskedSource;headerLine;isInterface;scriptType;devisor;buffer;bool;namespaceList;InheritsFrom;DevisorMeta;publishedStuff
      ⍝ Analyzes a particular script and appends the result to the "Meta" property.
      ⍝ If the left argument is specified, only that (or these) embedded class(es) gets analyzed.
      ⍝ Returns either an empty vector or a vtv with the name(s) of any embedded classes.
      InheritsFrom←''
      r←DevisorMeta←⍬
      formattedScriptName←{⍵↑⍨1+-'.'⍳⍨⌽⍵}{⍵↓⍨2×'#.'≡2↑⍵}⍕scriptRef
      origSource←{⍵↓⍨+/∧/' '=⍵}¨⎕SRC scriptRef
      embeddedClassNames←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'embeddedClassNames'
      :If ~0∊⍴embeddedClassNames
      ⍝ User asks for a class embedded in another one. So we simply replace "origSource" by the source of the embedded class
          :If 0∊⍴buffer←1↓origSource[{⍵/⍳⍴,⍵}':class'∘{⍺≡Lowercase(⍴⍺)↑⍵}¨dmb¨origSource] ⍝ 1↓ for itself
              :Return
          :EndIf
          bool←origSource∊buffer
          bool∨←origSource∊¯1↓origSource[{⍵/⍳⍴,⍵}':endclass'∘{⍺≡Lowercase(⍴⍺)↑⍵}¨dmb¨origSource] ⍝ ¯1↓ for itself
          buffer←({⍵∨≠\⍵}bool)/origSource
          buffer{(⊂¨⍵/⍺),¨⍺⊂⍨~⍵}←':class'search dmb¨buffer
          origSource←buffer⊃⍨1⍳⍨embeddedClassNames∘≡¨{{⍵↑⍨¯1+⌊/⍵⍳' :'}(⍴':class ')↓dmb ⍵}¨1⊃¨buffer
          formattedScriptName←embeddedClassNames
      :ElseIf ~0∊⍴InheritsFrom←GetDevisor origSource scriptRef
          ('Unknown devisor: ',InheritsFrom)⎕SIGNAL 11/⍨9∨.≠⎕NC⊃InheritsFrom
          Analyze_∘⍎¨InheritsFrom
          DevisorMeta←_META[(⍴InheritsFrom){1+⍵-⌽⍳⍺}⍴_META]
          _META←(-⍴DevisorMeta)↓_META
      :EndIf
      :If 0<+/bool←':include'∘≡¨Lowercase(⍴':include')↑¨dlb¨origSource
          namespaceList←∪dlb¨{(⍴':include ')↓⍵}¨dlb¨origSource[{⍵/⍳⍴,⍵}bool]
          namespaceList←{⍵↑⍨¯1+⍵⍳' '}¨namespaceList
          buffer←scriptRef MakeScriptFromNamespace¨namespaceList
          buffer←(~¨':namespace'∘search¨buffer)/¨buffer
          buffer←(~¨':endnamespace'∘search¨buffer)/¨buffer
          origSource,←,¨⊃,/buffer
      :EndIf
      origSource/⍨←{∧/⍵∨.≠⍉⊃(2⊃⍴⍵)↑¨'⍝ '}⊃origSource
      origSource/⍨←~∧\'⍝'=↑¨origSource
      origSource/⍨←{~(⌽∧\⌽⍵)∨∧\⍵}0=↑∘⍴¨origSource
      :If 0∊⍴embeddedClassNames
          r←':class '{' '~¨⍨(⍴⍺)↓¨dmb¨⍵/⍨⍺{⍵∧.=⍺}Lowercase(⍴⍺)↑[2]⊃dmb¨⍵}1↓origSource
      :EndIf
      isInterface←∨/':interface '⍷Lowercase headerLine←1⊃origSource
      devisor←{0∊⍴⍵:⍵ ⋄ ⊃{⍺,', ',⍵}/⍵}InheritsFrom
      scriptType←'Interface' 'Namespace' 'Class'⊃⍨5 1 4⍳10×2⊃0 1⊤|#.⎕NC⊂⍕scriptRef
      :If ~0∊⍴embeddedClassNames
          scriptType,←' embedded into ',⍕scriptRef
      :EndIf
      origSource←1↓¯1↓origSource
      require←GetRequireInfo origSource
      (origSource headerDoc)←origSource{(⍵↓⍺)(⍵↑⍺)}+/{∧\(∨/(2↑[2]⍵)∧.=⍉⊃'⍝ ' '⍝⍝' '⍝<' '⍝`')∨⍵∧.=' '}⊃origSource
      publishedStuff←⍬
      headerDoc←AnalyzeHeader(scriptRef headerDoc)
      origSource/⍨←0<↑∘⍴¨origSource~¨' '
      origSource↓¨⍨←{+/∧\' '=⍵}¨origSource
      origSource↓¨⍨←{-+/∧\' '=⌽⍵}¨origSource
      mask←MaskText¨origSource
      maskedSource←mask{w←⍵ ⋄ (⍺/w)←' ' ⋄ w}¨origSource
      commentsStartAt←¯1+origSource⍳¨'⍝'
      :If 0∊⍴maskedSource←,¨Lowercase commentsStartAt↑¨maskedSource
          publishedStuff←AnalyzeResult publishedStuff
          _META,←⊂formattedScriptName scriptType devisor headerDoc publishedStuff require
      :Else
          :Repeat
              noof←1
              :If ~0∊⍴currentline←1⊃maskedSource
     ⍝                  ⍎(∨/'data put name'⍷currentline)/'.'
                  this←{⍵/⍨~{⍵∨≠\⍵}⍵∊'{}'}currentline
                  :If '∇'∊this
                      this←{⍵↑⍨¯1+⍵⍳';'}this              ⍝ remove local vars
                      this←{'←'∊⍵:⍵↓⍨⍵⍳'←' ⋄ ⍵}this       ⍝ remove explicit result
                      this←{'('∊⍵:⍵↑⍨¯1+⍵⍳'(' ⋄ ⍵}this    ⍝ remove parenthesized right argument
                      this←{' 'Split dmb ⍵~'∇'}this       ⍝ split by blank, remove any dels first
                      this←'∇',{⍵⊃⍨(1 1 2)[1 2 3⍳⍴⍵]}this ⍝ what is it, actually?
                  :Else
                      this←{⍵↑⍨¯1+⍵⍳' '}this
                  :EndIf
                  :If '∇'∊this   ⍝ Is it a function?
                      noof←⍴(1+'∇'⍳⍨↑¨' '~¨⍨1↓origSource)↑origSource
                      publishedStuff,←{0∊⍴⍵:'' ⋄ ⊂⍵}AnalyzeFns(isInterface,noof,noof↑¨origSource maskedSource)
                  :ElseIf ':'=↑this
                      :Select this
                      :Case ':include'
                          publishedStuff,←⊂⊃('type' 'Include')('access' '')('name'({⍵↑⍨¯1+⍵⍳' '}dlb{⍵↓⍨⍵⍳' '}1⊃origSource))
                      :Case ':field'
                          publishedStuff,←{0∊⍴⍵:'' ⋄ ⊂⍵}AnalyzeField(1⊃origSource)(1⊃maskedSource)
                      :Case ':property'
                          noof←maskedSource⍳⊂':endproperty'
                          publishedStuff,←{0∊⍴⍵:'' ⋄ ⊂⍵}AnalyzeProperty(noof,noof↑¨origSource maskedSource)
                      :Case ':class' ⍝ embedded class? Not of any interest to a user of a class
                          noof←⍴':endclass'{⍵↑⍨1++/∧\((⍴⍺)↑[2]⊃⍵)∨.≠⍺}maskedSource
                      :EndSelect
                  :Else
                      :If '{'=1↑(⍴this)↓1⊃origSource ⍝ is it a dynamic function?
                          noof←FindEndOfDfns origSource
                      :Else
                          noof←1⌈+/∧\'∆:'∊⍨↑¨origSource
                      :EndIf
                  :EndIf
              :EndIf
              (origSource maskedSource)←noof↓¨origSource maskedSource
          :Until 0∊⍴origSource
          publishedStuff←AnalyzeResult publishedStuff
          _META,←⊂formattedScriptName scriptType devisor headerDoc publishedStuff require
      :EndIf
      :If ~0∊⍴DevisorMeta
          MergeWithDevisor¨DevisorMeta
      :EndIf
    ∇

    ∇ data←AnalyzeResult data;bool
      ⍝ Re-order the array
      :If ~0∊⍴data
          data←data[⍋'Include' 'Constructor' 'Destructor' 'Interface' 'Property' 'Field' 'Method'⍳Get data]
          data←'Instance'SortMethods data
          data←'Shared'SortMethods data
          data←'Public'SortMethods data
          data←'Field'Sort data
          data←'Property'Sort data
          :If 0<+/bool←2=↑∘⍴∘⍴¨data
          :AndIf 0<+/bool←bool\'Method'∘≡¨Get bool/data
              (bool/data)←(bool/data)[⍋'Instance' 'Shared'⍳'access'Get bool/data]
          :EndIf
      :EndIf
    ∇

    ∇ (top topLinks)←CreateTop(data name topId noOfClasses chapterNo);types;publicTypes;bool
     ⍝ Create the top part of the HTML page (caption, toc) and the links
      :If 0=⎕NC'OutputType' ⍝ is it an instance?
      :OrIf OutputType≡'Web'
          top←'<a name="topmost"></a>'
          :If 1<noOfClasses
              top,←'Go to: ',('a href="#',GetChapterNo,'"')tag'class'
              top,←'div class="goto"'tag top,' | ',('a href="#verytop"')tag'top'
          :Else
              top,←'div class="goto"'tag'Go to: ',('a href="#verytop"')tag'top'
          :EndIf
          topLinks←0 2⍴''
          :If 5<+/bool←2=↑∘⍴∘⍴¨data
              types←Get bool/data
              :If types∊⍨⊂'Constructor'
                  topLinks⍪←'ctor'(('a href="#',GetChapterNo,':ctor"')tag'Constructors')
              :EndIf
              :If types∊⍨⊂'Destructor'
                  topLinks⍪←'dtor'(('a href="#',GetChapterNo,':dtor"')tag'Destructors')
              :EndIf
              :If types∊⍨⊂'Interface'
                  topLinks⍪←'interface'(('a href="#',GetChapterNo,':infc"')tag'Interfaces')
              :EndIf
              :If types∊⍨⊂'Property'
                  topLinks⍪←'properties'(('a href="#',GetChapterNo,':props"')tag'Properties')
              :EndIf
              :If types∊⍨⊂'Field'
                  topLinks⍪←'fields'(('a href="#',GetChapterNo,':fields"')tag'Fields')
              :EndIf
              :If types∊⍨⊂'Method'
                  publicTypes←'access'Get(bool/publicStuff)/⍨types≡¨⊂'Method'
                  :If publicTypes∊⍨⊂'Instance'
                      topLinks⍪←'instancemethods'(('a href="#',GetChapterNo,':instancemethods"')tag'Instance Methods')
                  :EndIf
                  :If publicTypes∊⍨⊂'Shared'
                      topLinks⍪←'sharedmethods'(('a href="#',GetChapterNo,':sharedmethods"')tag'Shared Methods')
                  :EndIf
                  :If publicTypes∊⍨⊂'Public'
                      topLinks⍪←'publicmethods'(('a href="#',GetChapterNo,':publicmethods"')tag'Interface Methods')
                  :EndIf
              :EndIf
              :If types∊⍨⊂'Interface Method'
                  topLinks⍪←'implementedinterfacemethods'(('a href="#',GetChapterNo,':implementedinterfacemethods"')tag'Implemented Interface(s)')
              :EndIf
              :If types∊⍨⊂'Destructor'
                  topLinks,←⊂'a href="#',GetChapterNo,':dtor"'tag'Destructor'
              :EndIf
          :EndIf
      :Else
          top←topLinks←⍬
      :EndIf
    ∇

      SplitPath←{
          ⍺←'/\'
          l←1+-⌊/⍺⍳⍨⌽⍵
          (l↓⍵)(l↑⍵)
      }

      Split←{
          ⍺←⎕UCS 13 10 ⍝ Default is CR+LF
          ⎕ML←1
          (⍴,⍺)↓¨⍺{⍵⊂⍨⍺⍷⍵}⍺,⍵
      }

      Nest←{
          (,∘⊂∘,⍣(0 1∊⍨≡⍵))⍵
      }

      tag←{
           ⍝ Examples:
           ⍝ tag 'foo'                ←→  '<p>foo</p>'
           ⍝ 'div' tag 'foo'          ←→  '<div>foo</div>'
           ⍝ 'div id="my"' tag 'foo'  ←→  '<div id="my">foo</div>'
           ⍝ 'div id="my"' tag ''  ←→  ''
          ⍺←'p'
          0∊⍴⍵:''
          (tg style)←{⎕ML←1
              ' '∊⍵:⍵{(⍵↑⍺)(⍵↓⍺)}¯1+⍵⍳' '
              ⍵''}⍺
          '<',tg,style,'>',(('<'=1⍴⍵)/nl),⍵,'</',tg,'>',nl
      }


      SyntaxHelper←{
           ⍝ Help preparing proper HTML for the "Syntax:" box
          '<div class="aplcode"><span class="inaplcode">Syntax:</span>',⍵,'</div>',nl
      }

      MaskText←{
           ⍝ Returns a boolean mask useful to mask any text
          ⍺←''''
          {⍵∨≠\⍵}⍵∊⍺
      }

      GetLastError←{
          '∆GetLastError'⎕NA'I4 kernel32.C32∣GetLastError'
          ∆GetLastError
      }

      dmb←{
           ⍝ delete leading, trailing and multiple blanks
          1↓¯1↓{⍵/⍨~'  '⍷⍵}' ',⍵,' '
      }

    dlb←{⍵↓⍨+/∧\' '=⍵}   ⍝ Delete leading blanks

    dtb←{⌽dlb⌽⍵}         ⍝ Delete leading and trailing blanks but no multiples

    search←{⍺∘≡¨Lowercase ↓(⍴⍺)↑[2]⊃⍵}

      Uppercase←{
          dummy←'TOUPP'⎕NA'I4 USER32.C32|CharUpper',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' =0T'
          ~0 1∊⍨≡⍵:∇¨⍵
          2≠⍴⍴⍵:2⊃TOUPP⊂⍵
          (⍴⍵)⍴2⊃TOUPP⊂,⍵
      }

      Lowercase←{
          dummy←'TOLOW'⎕NA'I4 USER32.C32|CharLower',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' =0T'
          ~0 1∊⍨≡⍵:∇¨⍵
          2≠⍴⍴⍵:2⊃TOLOW⊂⍵
          (⍴⍵)⍴2⊃TOLOW⊂,⍵
      }

      FormatDateTime←{
          ,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT,[0.5]6↑⍵
      }

      Get←{
      ⍝ Get all ⍺ of a series of matrices, typyxally 5⊃_META; See also GetSingle
          ⍺←'type'
          ⍺∘{2⊃⍵[⍵[;1]⍳⊂⍺;]}¨⍵
      }

      GetSingle←{
          ⍺←'type'
          2>⍴⍴⍵:↑⍵
          2⊃⍵[⍵[;1]⍳⊂⍺;]
      }


      Set←{
          (mat name newValue)←⍵
          where←mat[;1]⍳⊂name
          (1↑⍴mat)<where:mat,[⎕IO]name newValue
          mat[where;2]←⊂(2⊃mat[where;]),newValue
          mat
      }



    ∇ keywords←ProcessKeywords data
      keywords←'keywords'Get data
      keywords←('readonly'Get data){⍺:(⊂'ReadOnly'),⍵ ⋄ ⍵}¨keywords
      keywords←{⍵/⍨0<↑∘⍴¨⍵}¨keywords
      keywords←{0∊⍴∊⍵:'' ⋄ 1=⍴⍵:' (',(∊⍵),')' ⋄ ' (',(⊃{⍺,',',⍵}/⍵),')'}¨keywords
    ∇

    ∇ regClose HANDLE;RegCloseKey;sink
      ⎕NA'U ADVAPI32.dll.C32|RegCloseKey U'
      sink←RegCloseKey HANDLE
    ∇

    ∇ (key filename)←FileBox y;∆;path;filename;caption;extension;mode;DQ_R;key
      y←{0 1∊⍨≡⍵:⊂⍵ ⋄ ⍵}y
      (path filename caption extension mode)←y,(⍴y)↓'' '' ''(⊂'*.html' 'ADOC HTML')'write'
      :If 0∊⍴path
          path←,⊃⎕CMD'cd'
      :EndIf
      ∆←⊂'FileBox'
      ∆,←⊂'Directory'path
      ∆,←⊂'File'filename
      ∆,←⊂'CAPTION'caption
      ∆,←⊂'EVENT'('FileBoxOK' 'FileBoxCancel')1
      ∆,←⊂'Style' 'Single'
      ∆,←⊂'FileMode'mode
      ∆,←⊂'Filters'extension
      'FileBoxForm'⎕WC ∆
      DQ_R←⎕DQ'FileBoxForm'
      :If 'FileBoxCancel'≡2⊃DQ_R
          key←'CANCEL'
      :Else
          key←'OK'
          filename←3⊃DQ_R
      :EndIf
    ∇

    ∇ r←GetPrintCss
      :Access Public Shared
         ⍝ Returns the CSS for printing purposes.
      r←''
      r,←⊂'html {font-family: "Arial Unicode MS", "Arial"; font-size:10pt; margin:0; padding:0 6pt;}'
      r,←⊂'div.sublinks{margin:1em;}'
      r,←⊂'ul, ol, p {margin-left:12pt; max-width:auto;}'
      r,←⊂'p.aplname {font-family:"APL385 Unicode";}'
      r,←⊂'ol {margin-top:5pt; margin-bottom:5pt}'
      r,←⊂'h2, h3 {margin-top:10pt; margin-bottom:0;}'
      r,←⊂'h4,h5,h6 {margin-top:0; margin-bottom:0; padding-top:0; font-size:10pt;}'
      r,←⊂'.goto, .sublinks {display:none;}'
      r,←⊂'pre {margin-top:0; margin-bottom:0; padding-top:0; padding-bottom:0;}'
      r,←⊂'div.goto {float:right; margin-right:0; padding:0 2em 0 1em;}'
      r,←⊂'span.aplinlinecode {font-family:"APL385 Unicode"; font-weight:bolder;}'
      r,←⊂'text.aplinlinecode {font-family:"APL385 Unicode"; font-weight:bolder;}'
      r,←⊂'span#sep {padding-left:4em;}'
      r,←⊂'pre {font-family:"APL385 Unicode"; margin:0 0 0 2em; padding:0; line-height:1.2; font-weight:bolder;}'
      r,←⊂'div.aplcode {font-family:"APL385 Unicode"; font-size:120%; padding:3pt 0 3pt 7pt; margin:0;}'
      r,←⊂'span.inaplcode {font-family:"Arial Unicode MS", "Arial"; margin:0 1em 0 0; padding:0; float:left; font-size:80%;}'
      r,←⊂'p.aplname {font-family:"APL385 Unicode"; }'
      r,←⊂'p.small {padding:0; margin:0 0 0 2em; font-size:7pt;}'
      r,←⊂'h1, h2, h3, h4, h5, h6 {margin-left: 0pt;}'
      r,←⊂'h1{text-align:center; padding:10pt; margin:1em 5pt 2em 5pt; width:100%; font-Size:16pt;}'
      r,←⊂'h2 {font-size:12pt;}'
      r,←⊂'h3 {font-size:10pt; margin:1.5em 0 0 0;}'
      r,←⊂'h4 {font-size:9pt; padding-top:0.5em; margin:5pt 0 0 0;}'
      r,←⊂'h4.aplname {font-family:"APL385 Unicode"; font-size:120%; padding:3pt 0 3pt 7pt; margin:2em 0 0 0;}'
      r,←⊂'h1#topmost {text-align:center; padding:10pt; margin:1em 5pt 2em 5pt; width:100%; font-Size:16pt;}'
      r,←⊂'ol#toc {line-height:1.5;}'
      r,←⊂'div#toc {line-height:1.3; margin-left:1.5em;}'
      r,←⊂'div#footer {text-align:center; font-size:7pt;}'
      r,←⊂'div#maintoc {margin:1em 1em 1em 4em; page-break-after:always}'
      r,←⊂'div#maintoc ol {margin:0 0 1em 0;}'
      r,←⊂'div#maintoc h1 {font-size:10pt; border:0; width:13em; margin:0; text-align:left;}'
      r,←⊂'div#maintoc div {margin-left:30pt;} '
      r,←⊂'div#maintoc div.subtoc {margin-left:40pt;}'
      r,←⊂'ul {padding-left:1.25em; margin-left:2.75em;}'
      r,←⊂'ol {padding-left:1.5em; margin-left:2.75em;}'
      r,←⊂'ol.listlevel2, ul.listlevel2 {padding-left: 1.5em; margin: 0; margin-left: 0; }'
      r,←⊂'div.toctab {font-size:7pt; line-height:1.4em; border:1pt solid Gray; float:right; margin:2em; padding:0.75em;}'
      r,←⊂'a {text-decoration:none; color:black;}'
      r,←⊂'div.content {page-break-after:always;}'
      r,←⊂'tr:nth-child(odd) {background: #eaeaea}'
      r,←⊂'tr:nth-child(even) {background: #f3f3f3}'
      r,←⊂'td {padding: 4px 6px; border: 1px solid silver;}'
      r,←⊂'table {border-collapse: collapse; margin: 15px;}'
    ∇

    ∇ r←GetScreenCss
      :Access Public Shared
         ⍝ Return the CSS for screen purposes.
      r←''
      r,←⊂'html {font-family: "Arial Unicode MS", "Arial"; background-color: #fffeea; font-size: medium; margin:0; padding:0; color:#4b4b4b;}'
      r,←⊂'body {max-width:920px;}'
      r,←⊂'div.sublinks{margin: 1em; }'
      r,←⊂'div.header h2, h3 {margin-top: 10px; margin-bottom: 0;}'
      r,←⊂'ol {margin-top: 3px;margin-bottom: 3px}'
      r,←⊂'h2 {margin-top: 5px; margin-bottom: 0;}'
      r,←⊂'h3 {margin-top: 5px;margin-bottom: 0;}'
      r,←⊂'h4,h5,h6 {margin-top: 0; margin-bottom: 0; padding-top:0;}'
      r,←⊂'p {margin-top: 8px; margin-bottom: 8px; margin-left: 2em; font-size: medium; line-height: 1.1;}'
      r,←⊂'p.aplname {font-family: "APL385 Unicode"; font-size: small; }'
      r,←⊂'div.goto {float: right; margin:0; padding:0 0 0 1em; }'
      r,←⊂'span.aplinlinecode, span.aplinlinecode a {font-family: "APL385 Unicode"; font-size: medium; font-weight: bolder; color: ',InLineCodeColor,'; padding-left:',(⍕InLineCodePadding),'px;padding-right:',(⍕InLineCodePadding),'px;}'
      r,←⊂'text.aplinlinecode {font-family: "APL385 Unicode"; font-size: medium; font-weight: bolder; color: inherent;}'
      r,←⊂'span#sep {padding-left: 4em; }'
      r,←⊂'pre {font-family: "APL385 Unicode"; margin:0.5em 0 0.5em 2em; font-size:medium; padding:5px 0 5px 5px; line-height: 1.2; ;'
      r,←⊂'     overflow:auto; word-break:normal !important; word-wrap:normal !important; white-space: pre !important;'
      r,←⊂'     border: 2pt dotted silver; background-color: #ebf1fa;}'
      r,←⊂'div.aplcode {font-family: "APL385 Unicode"; font-size: 110%; padding: 5px; color:inherent; border: 1px solid silver; '
      r,←⊂'     background-color:inherent; margin: 1em 0 0 1.8em; }'
      r,←⊂'span.inaplcode {font-family: "Arial Unicode MS", Arial; margin: 0 1em 0 0; padding:0; color:inherent; float:left; font-size: 80%; }'
      r,←⊂'p.aplname {font-family: "APL385 Unicode"; }'
      r,←⊂'p.small {padding:0; margin:0 0 0 2em; }'
      r,←⊂'h1, h2, h3, h4, h5, h6 {color:inherent; margin-left: 10px; }'
      r,←⊂'h1{Background-Color: #dedede; text-align: center; padding: 10px 0; margin: 5px 0; font-Size: very large; border: 1px solid black; }'
      r,←⊂'h2 {font-Size: very large;}'
      r,←⊂'h3 {font-size: large;  padding-top: 0em;}'
      r,←⊂'h4 {font-size: medium;  padding-top: 0em; color: #97721b;}'
      r,←⊂'h4.aplname {font-family: "APL385 Unicode"; font-size: 110%; padding: 0.3em 5px 0 5px; color:inherent; margin: 0.5em 0 0 0; }'
      r,←⊂'h1#topmost {Background-Color: #dedede; text-align: center; padding: 10px 0; margin: 5px 0; font-Size: large; border: 2px solid black; }'
      r,←⊂'ol#toc {font-size: small; line-height: 1.3; }'
      r,←⊂'ol#toc li {margin-top:0; margin-left:1.5em;}'
      r,←⊂'div#toc {font-size: small; line-height: 1.3; margin-left:1em; margin-bottom:1em;}'
      r,←⊂'div#footer {text-align: center; font-size: small; color:inherent; }'
      r,←⊂'div#maintoc {width: 40em; border: 1px solid black; margin: 1em;font-size: small; line-height: 1.15; }'
      r,←⊂'div#maintoc > div {margin-left:1.5em; margin-top:5px;}'
      r,←⊂'div#maintoc ol {margin:0 0 1em 0; }'
      r,←⊂'div#maintoc h1 {font-size:medium; background-color:transparent; border:0; color:inherent; width: 13em; margin: 0; text-align: left;}'
      r,←⊂'div#maintoc div.subtoc {margin-left:3em;}'
      r,←⊂'ul {padding-left: 1.25em; margin: 0; margin-left: 2.75em; }'
      r,←⊂'ol {padding-left: 1.5em; margin: 0; margin-left: 2.75em; }'
      r,←⊂'ol.listlevel2, ul.listlevel2 {padding-left: 1.5em; margin: 0; margin-left: 0; }'
      r,←⊂'li {margin-bottom: 0.25em;}'
      r,←⊂'div.toctab {font-size: small; line-height: 1.4em; border: 1px solid silver; float:right; margin: 0.5em 0 0.5em 0.5em; padding:0.75em; '
      r,←⊂'           background-color:white; line-height:1.6; }'
      r,←⊂'div.level2 {padding-left: 0em;}'
      r,←⊂'div.level3 {padding-left: 1em;}'
      r,←⊂'div.level4 {padding-left: 2.5em;}'
      r,←⊂'div.level5 {padding-left: 3em;}'
      r,←⊂'div.level6 {padding-left: 3.56em;}'
      r,←⊂'tr:nth-child(odd)  {background: #eaeaea;}'
      r,←⊂'tr:nth-child(even) {background: #f5f5f5;}'
      r,←⊂'td {padding: 4px 6px; border: 1px solid silver; vertical-align: top;}'
      r,←⊂'table {border-collapse: collapse; margin: 1em 1.8em 0.5em 1.8em;}'
    ∇

    ∇ script←scriptName MakeScriptFromNamespace name;list;ref
      ⍝ Gain script from a namespace regardless what it is: a script or an ordinary namespace.
      :Access Public Shared
      ref←⍎{⍵↓⍨-'.'⍳⍨⌽⍵}⍕scriptName
      :If 0=ref.⎕NC name
          ∆EM←'Tries to :Include "',name,'" but that does not exist'
          ∆EM ⎕SIGNAL 999
      :EndIf
      :Trap 16
          script←ref.{⎕SRC⍎⍵}name
          :Return
      :EndTrap
      ⍝ If we got to this stage, it is obviously an ordinary namespace
      :If 9≠ref.⎕NC⍕name
          11 ⎕SIGNAL⍨'"',(⍕ref),'.',name,'" is not a namespace'
      :ElseIf ref.{0::0 ⋄ tmp←⎕SRC⍎⍵ ⋄ 1}⍕name
          . ⍝ ???
      :Else
          :With ⍎(⍕ref),'.',⍕name
              :If ~0∊⍴⎕NL 3
                  list←⎕NL-3
                  script←,¨⊃,/{⎕IO←1 ⋄ ⎕ML←3 ⋄ {⍵{3.2=⎕NC⊂⍺:⍵ ⋄ (''('∇',1⊃⍵)),(1↓⍵),'∇' '  '}⎕NR ⍵}⍵}¨list
              :Else
                  script←''
              :EndIf
          :EndWith
      :EndIf
      script←(':Namespace ',{⍵↓⍨2×'#.'≡2↑⍵}⍕name)'⍝',script,⊂':EndNamespace'
    ∇

    ∇ r←FindEndOfDfns source;noOfOpeneded;noOfClosed;this
      r←0
      noOfOpeneded←noOfClosed←0
      :For this :In source
          noOfOpeneded+←+/'{'=this
          noOfClosed+←+/'}'=this
          r+←1
          :If noOfOpeneded=noOfClosed
              :Leave
          :EndIf
      :EndFor
      ⍝ Done
    ∇

    ∇ {r}←View filename;wsh;⎕WX
      :Access public
    ⍝ Fires up the default browser and displays "filename"
      ⎕WX←1
      r←⍬
      'wsh'⎕WC'OLEClient' 'WScript.Shell'
      :If 0∊⍴_BrowserPath
          {}wsh.Run filename
      :Else
          {}wsh.Run('"',(_BrowserPath~'"'),'" ',filename)
      :EndIf
    ∇

    ∇ noof←CalcNoOfListItems data_;bool;i;a;this;flag
     ⍝ Find out how many items belong to a particular list.
     ⍝ More difficult than it looks in the first place because
     ⍝ lines might be put together by _ at the end of a line.
     ⍝ Note that the function returns not (necessarily) the no
     ⍝ of items the list is made up from but also the no of lines
     ⍝ connect via the "_" syntax.
     ⍝ Note that lists may be nested (one level only) which _
     ⍝ means that an ordered list can live inside an unordered _
     ⍝ one and vice versa.
      noof←i←flag←0
      :Repeat
          i+←1
          :If {(⍵[1]∊'*#')∧⍵[2]=' '}2↑dlb this←i⊃data_
              noof+←1
              :If (⊂¯2↑this)∊'_ ' ' _'
                  a←1++/∧\(¯2↑¨i↓data_)∊'_ ' ' _'
                  i+←a
                  noof+←a
              :EndIf
          :Else
              flag←1
          :EndIf
      :Until flag∨i≥⍴data_
    ∇

    ∇ r←CompressList vtv;buffer;sep;flag;noOf
      ⍝ Take a vtv which is supposed to be a list (ordered or not) and
      ⍝ put lines together where the last two items are either " _" or "_ "
      r←''
      flag←0
      :Repeat
          buffer←''
          :If (↑dlb 1⊃vtv)∊'*#'
              buffer←1⊃vtv
              vtv←1↓vtv
          :Else
              flag←1
          :EndIf
          :While (⊂¯2↑buffer)∊'_ ' ' _'
              noOf←1+'_ '≡¯2↑buffer
              buffer←((-noOf)↓buffer),dlb 1⊃vtv
              vtv←1↓vtv
          :EndWhile
          r,←⊂buffer
      :Until flag∨0∊⍴vtv
    ∇

    ∇ r←GetDevisor(headerLine scriptRef);buffer;where;parent
      ⍝ Return the devisor (if any) or an empty vector
      r←''
      :If _Inherit
      :AndIf ~0∊⍴where←{⍵/⍳⍴,⍵}∨/¨':Class '∘⍷¨headerLine
          buffer←(1⊃where)⊃headerLine
          buffer←(⍴':Class ')↓dmb buffer
          buffer←({~⍵∨≠\⍵}buffer='''')/buffer
          buffer↑⍨←¯1+buffer⍳'⍝'
      :AndIf ~0∊⍴buffer←(buffer⍳':')↓buffer
          :If ','∊buffer
              r←dmb¨{⍵⊂⍨','≠⍵}buffer
          :Else
              r←⊂dmb buffer
          :EndIf
          parent←1⊃'.'SplitPath⍕scriptRef
          r←parent∘{'#'=1⍴⍵:⍵ ⋄ ⍺,⍵}¨r
      :EndIf
    ∇

    ∇ {r}←MergeWithDevisor devisor;currentMeta;name;this;scriptName;type;nameList;i;buffer
      ⍝ Implicit argument: _META; is also modified
      currentMeta←(⍴_META)⊃_META
      scriptName←1 1⊃devisor
      type←1 2⊃devisor
      r←''
      :If ~0∊⍴buffer←5⊃currentMeta
          nameList←'name'∘Get 5⊃currentMeta
          :For i :In ⍳⍴1 5⊃devisor
              this←i⊃1 5⊃devisor
              name←'name'GetSingle this
              :If (⊂name)∊nameList
                  this←Set this'more'(⊂'Inherited from "',scriptName,'" but re-defined')
                  (1 5 i⊃devisor)←this
              :Else
                  this←Set this'more'(⊂'Inherited from "',scriptName,'"')
                  (5⊃currentMeta)←(5⊃currentMeta),⊂this
              :EndIf
          :EndFor
          (5⊃currentMeta)←AnalyzeResult 5⊃currentMeta
          ((⍴_META)⊃_META)←currentMeta
      :EndIf
    ∇

    ∇ r←GetVarsFrom spaceRef
      :With spaceRef
          r←{⍵(⍎⍵)}¨⎕NL-2 9
      :EndWith
      r←⊃¨{IsChar ⍵:'_',⍺,'←''',⍵,'''' ⋄ '_',⍺,'←',⍕⍵}/¨r
    ∇

      MarkupBookmarks←{
          0=+/b←'→['⍷s←⍵:s
          i←¯1+b⍳1
          s←i⌽s
          (name s)←{⍵{(2↓¯1↓⍵↑⍺)(⍵↓⍺)}⍵⍳']'}s
          s←({'<a href="#',(Blank2_ Lowercase ⍵),'">',⍵,'</a>'}name),nl,s
          s←∇ s
          (-i)⌽s
      }

    :Class Registry
⍝ Offers methods for reading from and writing to the registry

        ∇ r←{path}Read key;wsh;⎕WX
                 ⍝ Read a registry key. Uses a particular default path which can be overridden _
                 ⍝ via the left argument
          :Access public shared
          ⎕WX←1
          'wsh'⎕WC'OLEClient' 'WScript.Shell'
          path←{2=⎕NC ⍵:⍎⍵ ⋄ 'HKCU\Software\APLTeam\ADOC'}'path'
          :Trap 11
              r←wsh.RegRead path,((0<⍴,path)/'\'),key
          :Else
              r←''
          :EndTrap
        ∇

        ∇ {path}Write(key value);⎕WX;wsh
                ⍝ Write a registry key. Uses a particular default path which can be overridden _
                ⍝ via the left argument
          :Access public shared
          ⎕WX←1
          'wsh'⎕WC'OLEClient' 'WScript.Shell'
          path←{2=⎕NC ⍵:⍎⍵ ⋄ 'HKCU\Software\APLTeam\ADOC'}'path'
          wsh.RegWrite(path,'\',key)value
        ∇

        ∇ bool←DoesKeyExist path;HKEY;KEY_READ;handle;subKey;∆RegOpenKeyEx;RegCloseKey;trash
          :Access Public Shared
                 ⍝ Checks if a Registry key "path" exists as a subkey of (by default) _
                 ⍝ HKEY_CURRENT_USER or the HKEY specified in "path".
          path←CheckPath path
          (HKEY subKey)←{a←⍵⍳'\' ⋄ ((a-1)↑⍵)(a↓⍵)}path
          HKEY←Get_HKEY_From HKEY
          KEY_READ←25           ⍝ HEX 0x00000019
          '∆RegOpenKeyEx'⎕NA'I ADVAPI32.dll.C32|RegOpenKeyEx',('*A'⊃⍨1+12>{⍎⍵↑⍨¯1+⍵⍳'.'}2⊃'.'⎕WG'APLVersion'),' U <0T I I >U'
          (bool handle)←∆RegOpenKeyEx HKEY subKey 0 KEY_READ 0
          :If bool←bool=0
              ⎕NA'I ADVAPI32.dll.C32|RegCloseKey U'
              trash←RegCloseKey handle
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
                      11 ⎕SIGNAL⍨'Invalid Registry key: "',HKEY,'"'
                  :EndSelect
              :EndIf
          :Else
              path←'HKEY_CURRENT_USER\',path
          :EndIf
        ∇

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
                  HKEY←2147483653             ⍝ HEX 0x80000005
              :Case 'HKEY_DYN_DATA'
                  HKEY←2147483654             ⍝ HEX 0x80000006
              :Else
                  'Invalid Keyword'⎕SIGNAL 11
              :EndSelect
          :Else
              HKEY←Type
          :EndIf
        ∇

    :EndClass

    ∇ Top←InsertChapterToc(Top Other TopName);bool;First;this;no;Toc;i;anchor;buffer;level1Flag
     ⍝ Inserts anchors to all "leading" <h{n}> tags and prepares a table-of-contents _
     ⍝ although this might be visible only if a certain number of entries is found.
      Toc←⊂'<div class="toctab">'
      level1Flag←∨/'<h1'⍷Top
      :If 0<+/bool←'<h'⍷Top
          bool∧←bool\'>'=Top[3+{⍵/⍳⍴,⍵}bool]
          Top←(1,1↓bool){⎕ML←0 ⋄ ⍺⊂⍵}Top
          (First Top)←{(1⊃⍵)(1↓⍵)}Top
          :For i :In ⍳⍴Top
              this←i⊃Top
              no←⍎this[3]
              anchor←'toc_',GetChapterNo,':',¯4↑'0000',⍕i
              this[4]←⊂' id="',anchor,'">'
              this←∊this
              (i⊃Top)←this
              buffer←'<div class="level',(⍕1⌈6⌊no),'">',nl
              buffer,←'<a href="#',anchor,'">',({⍵↑⍨¯1+⍵⍳'<'}{⍵↓⍨⍵⍳'>'}this),'</a>',nl,'</div>'
              Toc,←⊂buffer,nl
          :EndFor
          :If ~0∊⍴topLinks
              Toc,←'<div class="level2"><a href="#',GetChapterNo,'_tocref">Reference</a></div>'
              Toc,←{'<div class="level3">',⍵,'</div>'}¨topLinks[;2]
          :EndIf
          Toc←{0∊⍴⍵:'' ⋄ ⊃,/⍵}Toc
          Top←(1⊃Top),{0∊⍴⍵:'' ⋄ ⊃,/⍵}1↓Top
          :If level1Flag
              Top←First,Toc,'</div>',Top
          :Else
              Top←{⍵,Toc,'</div>',(⍴⍵)↓First,Top}'<div class="header">'
          :EndIf
      :ElseIf ~0∊⍴topLinks
          Toc,←{'<div class="level2">',⍵,'</div>'}¨topLinks[;2]
          Toc,←'</div>'
          Top,←'<div id="',GetChapterNo,'_toc">',(⊃{0∊⍴⍵:'' ⋄ ⊃,/⍵}Toc),'</div>'
      :EndIf
      ⍝⍎(≢/⎕←+/¨'<div' '</div'⍷¨⊂Top)/'.'
    ∇

    IsChar←{⎕ml←1  ⋄ ' '=1↑0⍴∊⍵}

    ∇ {append}WriteFile(filename data);fno;fullname;flag
         ⍝ Write UTF-8 "data" to "filename".
      :Access Public Shared
      append←{2=⎕NC ⍵:⍎⍵ ⋄ 0}'append'
      flag←0
      :Repeat
          :Trap 19 22
              fno←filename ⎕NTIE 0 17 ⍝ Open exclusively
              filename ⎕NERASE fno
              flag←1
          :CaseList 19
              ⎕DL 0.2
          :Case 22
              flag←1 ⍝ That's just fine
          :Else
              ⎕DM ⎕SIGNAL ⎕EN
          :EndTrap
      :Until flag
      fno←filename ⎕NCREATE 0
      :If 160≤⎕DR data
          ⍝ Make it UTF-8
          data←⎕UCS'UTF-8'⎕UCS data
      :EndIf
      data ⎕NAPPEND fno
      ⎕NUNTIE fno
    ∇

    ∇ {R}←{wait}Run cmd;∆WAIT;windowStyle;wsh
             ⍝ Starts an application
             ⍝ By default, Run doesn't wait for the app to quit.
      R←0 ''
      wait←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'wait'
      'Invalid left argument: must be a Boolean'⎕SIGNAL 11/⍨~wait∊0 1
      windowStyle←8 ⍝ is WINDOWSTYLE.NORMAL
      'wsh'⎕WC'OLEClient' 'WScript.Shell'
      :Trap 0
          {}wsh.Run cmd windowStyle wait
      :Else
          R←1('.'⎕WG'LastError')
      :EndTrap
    ∇

    ∇ R←{noSplit}ReadAnsiFile filename;No;Size
         ⍝ Read contents as chars. File is tied in shared mode.
      :Access Public Shared
      noSplit←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'noSplit'
      No←filename ⎕NTIE 0,66
      Size←⎕NSIZE No
      R←⎕NREAD No,80,Size,0
      ⎕NUNTIE No
      :If ~noSplit
          :If 0<+/⎕UCS 13 10⍷R
              R←Split R
          :ElseIf 0<+/R=⎕UCS 10
              R←(⎕UCS 10)Split R
          :EndIf
      :EndIf
    ∇

    ∇ {ok}←AnalyzeOrdinaryNamespace y;headerDoc;publishedStuff;name;ref;type
      headerDoc←1↓⎕NR y                          ⍝ Execute that function
      :If ~ok←{2≠≡⍵:1 ⋄ ~∧/↑¨' '=¨1↑¨0⍴¨⍵}headerDoc ⍝ ... returns a vector of string?
          headerDoc←{⍵↓⍨+/∧\' '=⍵}¨headerDoc     ⍝ remove leading blanks, if any
          headerDoc←('⍝'=↑¨headerDoc)/headerDoc  ⍝ Only lines starting with "⍝" do survive
          ref←⍎{⍵↓⍨-'.'⍳⍨⌽⍵}y
          headerDoc←AnalyzeHeader(ref headerDoc)
          name←dlb{⍵↓⍨+/∧\'='=⍵}1 2 1⊃headerDoc
          publishedStuff←''  ⍝TODO⍝ Here we need to get hold of :Access Public stuff!
          type←()e←()()()()()()'Container'
          _META,←,⊂name type''headerDoc publishedStuff''
      :EndIf
    ∇

    ∇ {ok}←AnalyzeFunction fnsName;headerDoc;publishedStuff;name;ref
      headerDoc←1↓⎕NR fnsName                    ⍝ Execute that function
      :If ~ok←{2≠≡⍵:1 ⋄ ~∧/↑¨' '=¨1↑¨0⍴¨⍵}headerDoc ⍝ ... returns a vector of string?
          headerDoc←{⍵↓⍨+/∧\' '=⍵}¨headerDoc     ⍝ remove leading blanks, if any
          headerDoc←('⍝'=↑¨headerDoc)/headerDoc  ⍝ Only lines starting with "⍝" do survive
          ref←⍎{⍵↓⍨-'.'⍳⍨⌽⍵}fnsName
          headerDoc←AnalyzeHeader(ref headerDoc)
          name←dlb{⍵↓⍨+/∧\'='=⍵}1 2 1⊃headerDoc
          publishedStuff←''
          _META,←,⊂name'Container' ''headerDoc publishedStuff''
      :EndIf
    ∇

      BasePath←{
          {⍎⍵↓⍨-'.'⍳⍨⌽⍵}⍕↑⎕CLASS ⍵  ⍝ where is the class script based?
      }

    ∇ r←SortAlphabet
      r←(⊃(⎕A,⎕D)('abcdefghijklmnopqrstuvwxyz',⎕D))
    ∇

    ∇ r←Compress vtv;b;noOf;buffer
    ⍝ Put together those items in vtv which end with a " _"
      r←''
      :While ~0∊⍴vtv
          b←'_'=↑¨¯1↑¨vtv
          noOf←1++/∧\b
          buffer←noOf↑vtv
          vtv←noOf↓vtv
          r,←⊂{↑,/(¯1↓¨⍵↑⍨¯1+⍴⍵),⍵[⍴⍵]}buffer
      :EndWhile
    ∇

    ∇ r←GetChapterNo
    ⍝ Relies on the existence of a semi-global "chapterNo"
      r←'ch',¯4↑'0000',⍕chapterNo
    ∇

    ColoredOrNot←{_withColor:⍵ ⋄ 'inherent'}      ⍝ Returns ⍵ if "withColor_" is true or 'inherent' otherwise

    :Class Demo
    ⍝ This class is embedded into ADOC just as an example.

        ∇ r←Hello
          :Access Public Shared
          r←'world'
        ∇

    :endclass

:EndClass