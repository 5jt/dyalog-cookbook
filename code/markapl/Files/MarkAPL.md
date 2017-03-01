[parm]:toc            = 2 3
[parm]:numberHeaders  = 2 3 4 5 6
[parm]:bookmarkLink   = 6
[parm]:collapsibleTOC = 1
[PARM]:title          = 'MarkAPL Reference'
[parm]:width          = 1000
[parm]:reportLinks    = 1

MarkAPL Reference
================

Overview
--------

### This document is too long for me!

Okay, got it. There is also a [cheat sheet][cheatsheet] available. You can also call `MarkAPL.Help 0` in order to view the cheat sheet.

### What is Markdown?

Markdown --- which is much better readable and therefore much better maintainable than HTML --- can be transformed into HTML. 

Because of its advantages over HTML and because the rules are easy to learn, Markdown became ubiquitous: many of the big names are using it now. Examples are StackFlow, Git, SourceForge and Trello. Wiki engines have also started to adopt the concept.

### Is there a Markdown standard?

Yes and no. The original implementation by John Gruber had no specification at all, just a Perl script and test cases. Unfortunately it was also quite buggy. Gruber has not put work into developing his brain child. Some consider the original Markdown therefore abandonware[^abandon].

Because of the bugs, some ambiguities and the lack of much needed features several flavours of an enhanced Markdown evolved, the most important ones being [Git-flavoured Markdown][git], [Markdown Extra][markdown_extra] and [PanDoc's Markdown][pandoc].

### What is MarkAPL?

**_MarkAPL_** is an APL program that converts (extended) Markdown into valid HTML5.

### MarkAPL, Markdown, Markdown Extra and CommonMark

 
CommonMark [^commonmark] is an attempt to establish a standard for Markdown.

**_MarkAPL_** aims to implement the original Markdown specification with very few exceptions. It also aims to implement most --- but not all --- of the Markdown Extra enhancements. Finally it also aims to follow the CommonMark specification as far as it seems to be reasonable.

In addition **_MarkAPL_** offers several enhancements that might be particularly useful to APLers and don't hurt otherwise.

For example, any lines that start with an APL lamp symbol (`⍝`) --- except in a code block of course --- are considered comment lines which won't contribute to the output at all.

For a full list see the next chapter.

### Preconditions 

**_MarkAPL_** needs Dyalog APL Unicode version 15.0 or better.

Compatibility, features, bugs
----------------------------------

### Standard compliance

#### Intentional differences

* Code blocks are identified as such **just by fencing**. Any lines indented
  by 4 characters **do not** define a code block in **_MarkAPL_**.
  
* In front of the fencing characters there might be zero or up to three white
  space character. However, when a code block is part of a list item than those white space characters have special meaning, and there might also be more than just three of them.

* HTML blocks that must end with an end tag should **not have** anything after 
  the end tag on that very line: it would be ignored.

* Note that `\` is considered an escape character **only** when there is 
  something to escape to the right of the backslash character, otherwise the `\` will survive untouched. 

  However, escaping is a more complex issue than you might expect; see [Escaping](#) for details

* For defining any attributes a pair of double quotes must be used. Single 
  quotes have no effect. (This contradicts the original Markdown documentation but due to a bug it did not work with the original Markdown implementation either)

* **_MarkAPL_** does not have the concept of "loose list items". In 
  CommonMark, the contents of any list item that is followed by a blank line is called a "loose" list item and wrapped into an additional `<p>` tag. 

  This is of little value and complicates matters enormously. Therefore **_MarkAPL_** simply ignores a single empty line between list items. 

  You still get a `<p>` tag around something that actually belongs to the list item but only **after** the initial text. This is called a sub-paragraph. See [Lists](#) for details.

* According to the Markdown specification a list following a paragraph must be 
  separated from the paragraph by a blank line. The reason for this rule is probably that in very rare circumstances one might start a list accidentally.
  
  Experience has shown however that users are way more likely to wonder why a list they intended to start straight after the end of a paragraph doesn't. For that reason **_MarkAPL_** does **not** require a blank line between the end of a paragraph and the first list item of a list.

* According to the original Markdown standard two spaces at the end of a line 
  are converted into a line break by replacing the two blanks by `<br />`. This was actually implemented in version 1.0 of **_MarkAPL_**. 

  However, more than once a bug was reported regarding unintentional line breaks which were accidentally caused by adding two spaces at the end of a paragraph or a list item. Therefore with version 1.3 this ill-designed feature was removed from **_MarkAPL_**.

  Note that there are other --- and better --- ways to achieve the same goal: see [Line breaks](#) for details.
 

#### Not implemented

* Markdown in-line mark-up inside an HTML block is ignored. This restriction 
  might be lifted depending on demand.

* All types of HTML blocks but one can, according to the CommonMark 
  specification, interrupt a paragraph. There are no plans to implement this.

* According to the CommonMark specification a tag like `<div>` can have a line 
  break in between and will still be recognized as a tag. Not only seems this to have very little value, it decreases readability. Therefore this is not implemented in **_MarkAPL_**.

* A list item can contain paragraphs, code blocks and sub-lists but nothing 
  else.

### Enhancements

* For every header an anchor is created automatically by default. See [Headers 
  and bookmarks](#) for details. In short every header gets an anchor with both ID and HREF set. That allows the automated generation of a table-of-contents as well as making any header the first line by simply clicking at it.

* Bookmark links have a special simplified syntax; see [Internal links (
  bookmarks)](#) for details.

* **_MarkAPL_** can optionally insert a table of contents from the headers 
  into a document. See [toc (table of contents)](#) for details.

* With `<<SubTOC>>` one can insert sub-tables of contents anywhere in the 
  document. See [Sub topics](#) for details.

* Headers can be numbered. By setting `numberHeaders` (which defaults to 0) to 
  1 one can force **_MarkAPL_** to number all or some headers. See [numberHeaders](#) for details. 

  This was implemented because numbering with CSS does not really work yet.

* Calling APL functions: something like `⍎⍎FnsName⍎⍎` calls an APL method 
  `FnsName` which gets the `ns` namespace as right argument. See [Function calls](# "Calls to embedded APL functions") for details.

* Typographical sugar. This can be switched off by setting `markdownStrict` to 1; for details see [markdownStrict](#).
   
    * Pairs of double-quotes (`"`) are exchanged against their typographically
      correct aquivalents "like here" while the [`lang`](#) parameter decides what's going to be the opening and what's the closing one: Germany/Austria/Switzerland have different ideas in this respect from the rest of the world.	 
    
      Note also that this means that mentioning a single double-quote requires it to be put between back-ticks or escaped with a `\` character when there are also pairs of double-quotes in the same paragraph, cell, list item, blockquote or header because otherwise **_MarkAPL_** has no idea what to do with it.		  

      A single double quote (") however is simply shown as is.

    * Three dots (`...`) are exchanged against an ellipses: ...
    * Three hyphens (`---`) are exchanged against ---.
	
	    This is called an em dash: a dash with the length of the character <<m>>.

    * Two hyphens (`--`) are exchanged against --.
	
	    This is called an en dash: a dash with the length of the character <<n>>.
	  
    * `(c)` is exchanged against (c).
    * `(tm)` is exchanged against (tm).
	* `<<` and `>>` are converted into <<Guillemets>>. 
	
	  Note that because of the special meaning of [`<<br>>`](#line breaks) and [`<<SubTOC>>`](#subTocs) you cannot have those strings between Guillemets defined by `<<` and `>>`. You can still enter the appropriate characters via special keyboard shortcuts around «br» and «SUBTOC» as shown here. See <http://typefacts.com/keyboard-shortcuts> for details of how to produce those characters via the keyboard.

* Assigning ID names, class names and attributes to certain elements as in:\
  `{#foo .my_class .another_class style="display:none;" target="_blank"}`\
  is implemented for most but not all elements. This idea was taken from Markdown Extra.
  
  See [Special attributes](#) for details.

* [Abbreviations](#). This was introduced by Markdown Extra.

* A `<br/>` tag can be inserted into paragraphs, lists and table cells with 
  `<<br>>`.

* Comments: any line that starts with a `⍝` (the APL symbol used to indicate a 
  comment) and is **not** situated within a code block will be ignored, no matter what else is found on that line.

  ~~~
  ⍝ This demonstrates a comment. Useful to leave stuff in a Markdown file 
  ⍝ but prevent it from making it into any resulting HTML document.
  ~~~

* Defining data: any line that starts with `[data]:` defines a key-value pair 
  of data. See [Data](#) for details. This has all sorts of applications; for example, this can be used to specify meta tags (name, content).
  
* Embedd **_MarkAPL_** parameters with `[parm]` into a document.  See [
  Embedding parameters with `[parm]:`](#) for details.
  
* [Helpers](#): There are helpers available that convert APL arrays into 
  Markdown.

* **_MarkAPL_** parameters can be embedded into a document - see [embedded 
  parameters](#Embedding parameters with `[parm]:`) for details.

### Known bugs

See <http://aplwiki.com/MarkAPL/ProjectPage>

Reference
------------

### Mark-up

<<SubTOC>>

#### Overview

The following table categorizes the different mark-ups into "Standard", "Extra", "Pandoc" and "MarkAPL". A single line might carry more than on X in case it got enhanced. 

| Name                		| Standard  | Extra   | Pandoc    | MarkAPL |
|:--------------------------|:---------:|:-------:|:---------:|:-------:|
| Abbreviations          	|			|		  |	X 	      |	X	|
| Automated links      		|   X		|	X     |	X	      |	X	|
| Blockquotes         		|	X		| 	X	  |	X		  |	X 	|
| Calling functions			|			|	      |		 	  |	X	|
| Code blocks (indented)	|   X		|	X	  |	X		  |		|
| Code blocks (fenced) 		|			|	X	  |	X		  |	X	|
| Definition lists			|	X		|	X	  |	X		  |	X	|
| Footnotes 				|	X		|	X	  |	X	      |	X	|
| Headers 			    	|	X		|	X	  |	X		  |	X	|
| HTML blocks				|	X		|	X	  |	X		  |	X	|
| HR 				    	|	X		|	X	  |	X	      |	X	|
| Images 		    		|	X		|	X     |	X		  |	X	|
| Inline markup 			|	X		|	X	  |	X		  |	X	|
| Line breaks (two spaces)  |	X		|	X	  |	X		  |		|
| Line breaks	(`\`)		|			|		  |	X		  |	X	|
| Line breaks (`<<br>>`)	|			|		  |			  |	X	|
| Links 					|	X		|	X	  |	X		  |	X	|
| Link references 			|	X		|	X	  |	X		  |	X	|
| Lists 					|	X		|	X	  |	X		  |	X	|
| Loose/tight lists         |   X     	|	X	  |	X		  |		|
| Markdown inside HTML   	|			|	X	  |	X		  |		|
| Paragraphs 				|	X		|	X	  |	X	      |	X	|
| Tables 					|	X		|	X	  |	X		  |	X	|
| Table of contents (TOC)	|			|		  |	X		  |	X	|
| Sub TOC			    	|			|		  |			  |	X	|
| Smart typography		    |			|	      |	X		  |	X	|
| Special attributes		|			|	X     |	X		  |	X	|

Note that "Code blocks (indented)" don't carry an X in the "MarkAPL" column because marking up a code block by indenting is deliberately not implemented in **_MarkAPL_**.

The implementation of [Definition lists](#) comes with some restrictions; see there. 

#### Comments

Any line that starts with an APL lamp symbol (`⍝`) is ignored. That means that the line won't make it into the resulting HTML at all.

This is true for any line that is not part of a code block, including lines that are part of a paragraph. 

Example:

~~~
Start of a para that contains
⍝ Ignored
a commented line.
~~~

This is the result:

Start of a para that contains
⍝ Ignored
a commented line.


#### Abbreviations

Abbreviations can be defined anywhere in the document. This is the syntax:

~~~
*[HTML] Hyper Text Markup Language
~~~

All occurrences of "HTML" within the Markdown document --- except those marked as code --- are then marked up like this:

`<abbr title="Hyper Text Markup Language">HTML</abbr>`

Therefore this:

~~~
*[Abbreviations]: Text is marked up with the <abbr> tag
~~~

should show the string "Text is marked up with the <abbr> tag" when you hover over the word "Abbreviations".

Notes:

* You may have more than just one word between the `[` and the `]` bracket. 
  However, any leading and trailing blanks will be removed.
* Any leading and trailing blanks in the title will be removed.
* What is within the square brackets is case sensitive.
* You may use any Unicode characters belonging to the Unicode "letter" 
  category plus `+-_= /&` (plus, minus, underscore, equal, space, slash and ampersand).


#### Blockquotes 

Markdown --- and therefore **_MarkAPL_** --- uses the `>` character for block quoting. If you’re familiar with quoting parts of text in an email message then you know how to create a block quote in Markdown. It looks best if you hard wrap the text and put a `>` before every line:

~~~
> This is a blockquote with one paragraph. Lorem ipsum dolor sit amet,
> consec tetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
> Vestibulum enim wisi, _viverra_ nec, fringilla **in** risus.
> 
> Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.
> 
> > Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.
~~~

Note that the third --- and last --- paragraph has two leading `>`, making it a blockquote within a blockquote.

This is the result:

> This is a blockquote with one paragraph. Lorem ipsum dolor sit amet,
> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
> Vestibulum enim wisi, viverra nec, fringilla **in** risus.
> 
> Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.
> 
> > Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.

However, **_MarkAPL_** allows you to be lazy and only put the > before the first line of a paragraph:

~~~
> This is a **lazy** blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.

> Second para.
~~~

This is the result:

> This is a **lazy** blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla **in**.

> Second para.

Note that blockquotes are not restricted in any respect: they may contain anything like paragraphs, tables, lists, headers, definition lists and blockquotes. However, headers are not numbered and do not have anchors attached, and any `<<SubTOC>>` directives are removed from a blockquote.


#### Code blocks

According to the original Markdown specification any lines indented by 4 characters were considered a code block. Apart from not being particularly readable this caused problems with nested lists and code blocks within such lists. Therefore later a convention called "fencing" was introduced. 

**_MarkAPL_** goes a step further: to avoid confusion indenting is **not** supported for marking up code blocks.

Code blocks can be marked up in two different ways:


##### Fencing

You can use the "Git" style with three --- or more --- back-ticks as shown here:

<pre>
```
This is a block ...
of code!
```
</pre>

You can use the Markdown Extra specification with three --- or more --- tildes:

<pre>
~~~
This is a another block ...
of code!
~~~
</pre> 

You don't have to have empty lines around fenced code blocks but you might find that such lines help to improve readability.

Notes:

* The fencing lines may have up to three leading white space characters. These 
  will just be ignored.

  Note that this rule does **not** apply when a code block is part of a list item since the number of spaces is then used to
  determine the level of nesting.
* Code blocks may also have [Special attributes](#); see there for details.

##### Code: the `<pre>` tag

You can also mark a block of text with the HTML `<pre>` tag. This is particularly useful in order to show the fencing characters as part of the code, for example.

If you need to assign an ID or a class or any styling stuff to the `<pre>` tag of a code block you can do this

~~~
<pre id="foo" class="my">
...
</pre>
~~~

There is no other way since assigning a [special attribute](#special-attributes) to a fenced block as shown here:

<pre>
~~~{#foo}
...
~~~
</pre>

does assign the attributes not to the `<pre>` tag but to the inner `<code>` element:

~~~
<pre><code id="foo">
...
</code></pre>
~~~

Notes:

* **_MarkAPL_** requires a `<code>` tag within any `<pre>` tag. Even if you do 
  not specify the `<code>` tag **_MarkAPL_** will insert it for you anyway.
* **_MarkAPL_** will remove any line breaks between `<pre><code>` and the 
  first line of your code block and also between `</code></pre>` and the last line of your code block. If you need an initial (empty) line or an empty line as the last one you must add it as shown here:

~~~
<pre><code>

Second line
Last but one line

</code></pre>
~~~

#### Definition lists

Definition lists are made of terms and definitions of these terms, much like in a dictionary. If there is a blank line between the term and the definition then the definition is enclosed between a <p> tag. However, if there are sub-definitions (see below) then all definitions are enclosed between <p> tags.

A definition can span more than one paragraph, but they must be indented by as many spaces as there are in front of the ":" (maximum of three) plus two for the colon itself and the following space to be recognized as being a definition. Such sub-definitions are always enclosed between <p> tags.

Definition lists break at two consecutive empty lines or anything that is neither a term and not indented according to the rules that define a definition. Having the two empty lines in place to break a definition list is recommended because it's faster.

Between the left margin and the colon there may be up to 3 spaces. After the colon there must be exactly one space. 

Simple example:

~~~
Term
: The definition
~~~

This is the result:

Term
: The definition


The resulting HTML:
~~~
<dl>
<dt>Term</dt>
<dd>The definition</dd>
</dl>
~~~

No <p> tags here because there is no blank line between the term and its definition.

More complex example:
~~~
Term 1

   : The definition

   : More information
	 that spans over
	 three lines

Term 2
	: Another definition

    : Additional information
~~~

This is the result:

Term 1

   : The definition

   : More information
	 that spans over
	 three lines

Term 2
   : Another definition

   : Additional information


The resulting HTML:
~~~
<dl>
<dt>Term 1</dt>
<dd><p>The definition</p></dd>
<dd><p>More information that spans over three lines</p></dd>
<dt>Term 2</dt>
<dd>Another definition</dd>
<dd><p>Additional information</p></dd>
</dl>
~~~

Restrictions:
* A term must be exactly one line.
* A definition may not contain anything but paragraphs.

#### Footnotes

Footnotes can be created by `[^1]` or `[^foo]`. The footnote `1` and `foo` can be defined anywhere in the document. Footnotes cannot contain anything but paragraphs: no code blocks, lists, blockquotes or tables. In-line mark-up is of course available.

The format of the definition `[^footnote]`:

~~~
[^single]: The definition of a single-line footnote.

[^footnote]: A multi-line definition.
  As long as the following paras are indented by two spaces they are considered part of the footnote.
  
  Even empty lines don't interrupt the definition, although two do. In-line formatting **is** of course supported. 
~~~

Notes:

* Two empty lines end a footnote. 
* As soon as something is not indented by two blanks a footnote definition 
  ends.
* The footnote identifiers must start with an upper case or lower case ASCII 
  character and may contain any upper case and lower case characters, digits and the underscore (`_`) but nothing else.
* The footnotes (= the ordered list) are wrapped in a 
  `<div id="footnotes_div">` tag to make them easily style-able with CSS. 
* Footnotes always go to the very end of the document.

#### Headers

There are two ways to mark up headers, and both are part of the original Markdown specification:

##### The "=" and "-" syntax (SeText)

With this syntax you can only define headers of level 1 and 2.

A line that looks like this:

~~~
Main caption
============
~~~

is converted into a header of level 1.

Note that it does not matter how many `=` chars are used. 

As long as the first character on a line is a `=` and there are no other characters or they are all spaces it will be recognized as a level-1 header.

Similarly a line that looks like this:

~~~
Header of level 2
-------------------
~~~

is converted into a header of level 2.

Again it does not matter how many hyphens are used. As long as the first character on a line is a hyphen and there are no other characters or they are all spaces it will be recognized as a level-2 header.

However, since a single `-` can also start a bulleted list it is **strongly** recommended to use at least two (`--`) characters.

Note that the definition of a header might well span several lines like this:

~~~
This is a 
level 1
header
=====
~~~

Generally no blank line is required either before or after such a header but because a SeText header cannot interrupt a paragraph it is necessary to have a blank line between the end of a paragraph and a SeText header. 

##### The "pound" syntax (ATX)

A line that looks like this:

~~~
# My caption
~~~

is converted into a header of level 1 while a line that looks like this:

~~~
###### My caption
~~~

is converted into a header of level 6. You cannot have headers of level 7 or higher (HTML does not allow this), and it is probably not a good idea to use levels beyond 4 anyway, except perhaps in technical documentation.

Many Markdown implementations do not require a space between the last `#` on the left and the content (= the header as such). However, the space was required even by the original Markdown specification. The CommonMark specification points out that this was actually a good idea because with the blank these two lines would be rendered as headers:

~~~
#5 bolt
~~~

~~~
#hashtag
~~~

Note that you may have trailing `#` characters as well; however, they are simply ignored. That's the reason why the number of characters does not even have to match the leading number of `#`.

##### ATX versus SeText syntax

* The SeText syntax is contributing to the readability of a document.
* The ATX syntax makes it easier for an author to search for a specific header.

##### Headers and bookmarks 

By default **_MarkAPL_** automatically embraces headers (<h\{number\}>) by bookmark anchors. Use `parms.bookmarkLink` (default: 6 = all levels) to change this: setting this to 0 suppresses this. You can also assign a number lesser than 6. For example, assigning 3 means that all headers of level 1, 2 and 3 are embraced by bookmark anchors but any headers of level 4, 5 and 6 are not.

You are advised however to not change the default value because the only reason why this feature exists is that for blockquotes we don't want any headers to have anchors because there names might intefere with the names in the document that contains the blockquote.

Note that both ID and HREF are assigned the same value. That allows the user to make any header the first line by just clicking at it.

The names of the bookmarks are constructed automatically according to this set of rules:

* Remove all formatting, links, etc.
* Remove everything between <>, () and [], including the brackets.
* Remove all punctuation, except underscores, hyphens, and periods.
* Remove the back-ticks around code.
* Remove HTML entities (recursive calls to **_MarkAPL_**!)
* Replace all spaces and newlines with hyphens.
* Convert all alphabetic characters to lower case.
* Remove everything from the left until the first digit or ASCII letter or `∆` 
  or `⍙` is found (identifiers may not begin with a hyphen).
* If nothing is left by then, use the identifier `section`.

If you need to link to such headers from within the document it is probably best to assign an ID (via [Special attributes](#)) and to use that ID in the link.

Example:

The caption "`Second level-2 "Header!"`" becomes "`second-level-2-header`".

This is the result with `parms.bookmarkLink←1`:

~~~
<a id="second-level-2-header" class="autoheader_anchor" 
<h1>Second level-2 "Header!"</h1> 
</a>
~~~

Note that the class `autoheader_anchor` is automatically assigned to all bookmark links. This is needed because you probably want to make them invisible via CSS.

With `parms.bookmarkLink←0` however it is just this:

~~~
<h1>Second level-2 "Header!"</h1>
~~~

##### Headers and special attributes

Note that assigning [Special Attributes](#) has special rules:

* If an ID is defined then it is assigned to the anchor (`<a>`) rather than the <h{number}> tag.
* All other special attributes are assigned to the <h{number}> tag.
* If however automated bookmarks are suppressed (see [bookmarkLink](#)) then all special attributes go onto the <h{number}> tag - there is no anchor in those cases.

##### Headers and links/images

Note that a Markdown header can only be simple text and/or code. In particular you cannot make an image or a link part of a header.

Although it would be possible to implement this it would defeat the purpose of Markdown: keep the syntax simple, much simpler than HTML, because nesting those elements in Markdown would result in a different but still very complex syntax. 

If you a link or an image in a header specify an HTML block for it - see [HTML blocks](#).

Note that **_MarkAPL_**'s ability to inject a table-of-contents is not harmed by an HTML block injecting a header. However, its ability to number headers **is** harmed.

#### HTML blocks

Please note that there are three different HTML blocks:

* `<script>` and `<style>`
  
  They are special because they cannot be nested.

* `<pre>`
  
  This one preserves white space. The special features of `<pre>` blocks are discussed in detail at [Code: the `<pre>` tag](#).

* Everything else. 

Note that all HTML blocks but `<pre>`, `<script>` and `<style>` **must** be surrounded by blank lines.

It is perfectly legal to have HTML blocks in a Markdown document but be aware that this is way more complex a topic than it seemed to be at first glance. 

For details refer to [][commonmark_on_html_blocks].

The most important syntax is when you want to have an opening tag like a `<div>` and a corresponding `</div>` around some Markdown stuff. For simplicity let's assume that it is just a paragraph with a single word: "foo" in bold.

An HTML block must always start with either `<` or `</`:

~~~
# Example demonstrating HTML blocks

<div id="123" class="myClass">

**foo**

</div>

Another paragraph.
~~~

Notes:

1. This example comprises **two** (!) HTML blocks.

1. The beginning of a block is defined by an empty line followed by a line 
  that starts with either  `<` or `</` followed by a tag name. That means that leading white space is important because it prevents a line from being recognized as an HTML block.

1. The end of each HTML block (except `<pre>`, `<script>`, `<style>`) is 
  defined by an empty line which therefore is essential.

1. Sometimes you want to avoid something being processed as HTML block. 
  Imagine you want to actually write about the <p> tag. Starting a line with 

   ~~~
   <p id="My">My para</p>
   ~~~

   does not work because it is recognized and therefore processed as an HTML block! 
   
   This can be solved be injecting a space character to the left; then it's not treated as an HTML block anymore.

1. Because `**foo**` is an ordinary paragraph located **between** two HTML 
   blocks it will be converted into `<strong>foo</strong>`.

Without the two empty lines around the paragraph it would be just **one** HTML block. As a side effect the paragraph would show `**foo**` rather than **foo** because within an HTML block no in-line Markdown is recognized.

The `<pre>` blocks are different in so far as there is no Markdown styling done to anything between `<pre>` and `</pre>` anyway; therefore you can have just one block without any disadvantages. 

#### Horizontal rulers

You can create a horizontal ruler by following these rules:

1. After an empty line there must be a line with either a hyphen (`-`) or an 
   asterisk (`*`) or an underscore (`_`).
1. There must be at least three such characters on the line.
1. There might be zero to a maximum of three white space characters to the 
   left of the characters defining the ruler.
1. There are no other characters but spaces allowed, with the exception of [
   Special Attributes](#).

So these lines will all create a ruler:

~~~
---
* * * * * *
_ _    _
   ***
~~~

The result:

---
* * * * * *
_ _    _
   ***

A common mistake is to forget the empty line required **before** the definition of a ruler which might well define a [SeText header](#The “=” and “-” syntax (SeText)).  

#### Images

Images are implemented so that an image can be included into a paragraph, a list or a table cell. If you want an image outside such an element then you are advised to insert it as [HTML block](#html-blocks) with an `<img>` tag.

The original syntax of Markdown-images was of limited use because you cannot specify either height or width. However, with [Special attributes](#) one can get around this limitation.

The full syntax:

~~~
![Alt Text](/url "My title")
~~~

Because the title is optional this is a valid specification as well:

~~~
![Alt Text](/url)
~~~

Finally the "alt" text is optional as well, so this would do:

~~~
![](/url)
~~~

Note that if you specify "alt" but not "title" or "title" but not "alt" then the undefined bit will show the same contents as the defined one.

In order to add [Special attributes](#) use this syntax:

~~~
![Alt Text](/url "My title"){#foo .myclass style="color:red;"}
~~~

There must not be any white-space between the opening `{` and the closing `}`.

Example:

~~~
![Dots](http://download.aplteam.com/APL_Team_Dots.png "APL Team dots"){height="70" width="70"}
~~~

![Dots](http://download.aplteam.com/APL_Team_Dots.png "APL Team dots"){height="70" width="70"}

Note that you can use `<<br>>` between an image and some text and assign [Special attributes](#) to both, the image and the text. For example, this:

~~~
![](MyPic.png){.Picture15em} <<br>> Figure 3. Random {.caption .right}
~~~

results in this HTML:

~~~
<p class="caption right"><img src="MyPic.png" class="Picture15em"/><br/> Figure 3. Random</p>
~~~

Be aware that this is a special case: normally you can have special attributes only at the end of a line.

#### In-line mark up

First of all, all in-line mark up does **not** touch code (in-line code as well as code blocks) and to some extend links: they can be marked as code.

<<SubTOC>>

##### Emphasize with `<em>`

To mark some text as `<em>` you can enclose that text either with `**` or with `__`.

Therefore the following two lines are equivalent:

~~~
This is an **ordinary** paragraph.
This is an __ordinary__ paragraph.
~~~

This is the result in any case:

This is an **ordinary** paragraph.

Note that underscores within words are not considered mark-up directives.

##### Emphasize with `<strong>`

To mark some text as `<strong>` you can enclose that text either with `*` or with `_`.

Therefore the following two lines are equivalent:

~~~
This is an *ordinary* paragraph.
This is an _ordinary_ paragraph.
~~~

This is the result in any case:

This is an *ordinary* paragraph.

Note that underscores within words are not considered mark-up directives.

If you need a leading underscore as part of a name then you must escape the underscore with a backslash. This:

~~~
\_VarsName
~~~

leads to this:

\_VarsName

##### Strike-through with `<del>`

To mark some text with `<del>` you can enclose that text with `~~`:

~~~
This ~~is~~ was an ordinary paragraph.
~~~

This is the result:

This ~~is~~ was an ordinary paragraph.

Note that to the right of any opening `~~` and to the left of any closing `~~` there must be a non-white-space character.

##### Line breaks

There are two different ways to enforce a line break (= inserting a `<br/>` tag) into paragraphs, lists, footnotes and table cells:

* Have a backslash character (`\`) at the end of a line. However, this has the disadvantage that you cannot use it in table cells - there is no "end of line" in those.
* Insert `<<br>>` and it will become a `<br/>` tag. This is the recommended way: it is readable and can be used in table cells as well. However, it is a **_MarkAPL_**-only feature.
 
Having two blanks at the end of a paragraph or list item is according to the Markdown implementation --- and also the early versions of **_MarkAPL_** --- designed to inject a line break. This caused bug reports by people who accidentally added two spaces to the end of a line without realizing and then started to wonder where exactly the line break was coming from. It seemed to be a bad idea from the start; therefore this feature was removed from **_MarkAPL_** in version 1.3.0.

##### In-line code (verbatim)

You can insert code samples into paragraphs, blockquotes, lists, cells and footnotes by putting back-ticks around them:

~~~
This: `is code`
~~~

Note that in order to show a back-tick within code you need to double it:

~~~
Enclose in-line code with a back-tick character (````).
~~~

Note also that the number of back-ticks in a paragraph (list, cell,...) should be even. If that's not the case then a closing back-tick is added to the end automatically. That's why this seems to work:

~~~
This is a back-tick: ` ``
~~~

This is a back-tick: ` ``

However, adding a dot emphasizes what is really going on here:

~~~
This is back-tick: ` ``.
~~~

This is back-tick: ` ``.

Since the missing back-tick is added to the **end** of the **paragraph** the dot becomes part of the code. That's probably **not** what you want to happen. 

#### Links

<<SubToc>>

##### External links

Generally an external link looks like this:

~~~
[The APL wiki](http://aplwiki.com "Link to the APL wiki")
~~~

The result is a link like this one: [The APL wiki](http://aplwiki.com "Link to the APL wiki") which brings you to the APL wiki.

When you hover with the mouse over the link the title (that's the stuff within the double-quotes) is displayed.

Notes

* The way the title is used differs for external links and bookmark links.
* You cannot use in-line markup (bold, italic, del,...) in the URL.

The title is optional, therefore the link can also be written as:

~~~
[The APL wiki](http://aplwiki.com)
~~~

If you want the URL to become the link text then this would suffice:

~~~
[](http://aplwiki.com)
~~~

That would result in [](http://aplwiki.com).

However, see the next topic (AutoLinks) as well. 

##### Automated links (Autolinks)

Because external links are often injected "as is" --- meaning that they actually have no link text and no link title --- you can also specify a link as:

~~~
<http://aplwiki.com>
~~~

That results is this link: <http://aplwiki.com>: the link text and the URL are identical.

Note that you **must** specify a protocol (http://, https://, ftp://...), here, otherwise it is **not** treated as an automated link. Do **not** use this for `mailto:` links.

##### Internal links (bookmarks)

Bookmark links are defined by a leading `#`. This character tells that the link points to somewhere in the same document.

The text of a bookmark link must be compiled of one or more of `⎕D,'∆⍙',⎕A,Lowercase ⎕A`: All digits, all letters of the ASCII characters set, lowercase or uppercase, and the two APL characters `∆` and `⍙`.

Note that in HTML5 an ID may start with a digit. This is the default in **_MarkAPL_** as well. However, you can change this by setting [bookmarkMayStartWithDigit](#) accordingly.

An example of a bookmark link:

~~~
[Link text](#Anchor)
~~~

The most common internal (or bookmark) link is a link to a header. Since **_MarkAPL_** establishes anchors automatically for all headers by default you might expect an easy way to link to them, and you would be right.

Given this header:
~~~
## This is (really) chapter 5-2
~~~

**_MarkAPL_** transforms this automatically into

~~~ 
this-is-really-chapter-5-2
~~~

according to the set of rules explained at [Headers and bookmarks](#).

To link to this header you can therefore say:

~~~
[Link to chapter 5-2](#this-is-really-chapter-5-2)
~~~

and that would work indeed.

However, instead you could use just the chapter title and specify a `#` in order to let **_MarkAPL_** know that this is an internal link:

~~~
[This is (really) chapter 5-2](#)
~~~

That will result in a bookmark link as well.

Note that this is a **_MarkAPL_**-only feature.

There are times when the actual title of the header you are linking to does not fit as a link text. In that case you specify an alternative link text:

~~~
[This is (really) chapter 5-2](#"Alt text")
~~~

This would create a link to the header _This is (really) chapter 5-2_ but it would show "Alt text" as link text. 

Note that external and internal links differ in how they make use of any string between double quotes.

##### Link references

Link references are defined by `[ID]: url "alt text"`. Note that "alt text" is optional and therefore may be empty or even absend. You may also add [special attributes](#): `[ID]: url "alt text"{target:"_blank"}`. There might be a space between the colon and the URL or not. 

Such definitions can appear anywhere in the document. 

IDs must consist of one or more characters of:

* The US ASCII character set, lower case as well as upper case.
* Digits.
* The underscore (`_`) character.
* The hyphen (`-`) character. 

Other characters are not permitted.

If the alt text is specified and not empty then any link that makes use of this reference and has no link text on its own will use the alt text as link text while in the abscence of both an alt text and a link text the URL as such would become the link text.

First example:

~~~
[aplwiki]: http://aplwiki.com
~~~

In the document you can refer to this link reference with:

~~~
[The APL wiki][aplwiki]
~~~

The text between the first pair of square brackets is the link text, the text between the second pair of square brackets is the ID of the link reference.

This would suffice however:

~~~
[][aplwiki]
~~~

In the former case "The APL wiki" would become the link text while in the latter case it would be "http://aplwiki.com" because the link reference has no alt text.

Second example:

~~~
[fire]: http://aplwiki.com/Fire "Fire's home page on the APL wiki"
~~~

If we refer to this definition with:

~~~
[][fire]
~~~

then "Fire's home page on the APL wiki" would become the link text.

Notes: 

* In case of a typo in the link definition --- meaning that **_MarkAPL_** 
  cannot find a corresponding link reference --- the text will appear "as is" in the final document but the failing reference will also be reported on [`ns.report`](#report).
* [Special attributes](#) can be assigned in the link reference definition but 
  not in the link itself.

##### Links containing code

Note that this works:

~~~
[`FunctionName`](#)
~~~

This on the other hand does **not** work:

~~~
`[FunctionName](#)`
~~~

The reason is simple:

* In the first expression the \` are removed before the contents between `[` 
  and `]` is converted into a link but it is still marked up with <pre> and <code>.
* The second statement is treated like code. No links then: it is taken 
  verbatim.

##### Links and special attributes

[Special Attributes](#) can be assigned to all links but references to link references:

* `<http://aplwiki.com{#foo1}>`    `⍝` Note: **no** white-space allowed here!
* `[BookMark Link](# {#foo2})`
* `[APL wiki](http://aplwiki.com {#foo3})`
* `[](http://aplwiki.com {target="_blank"})`

#### Lists

<<SubTOC>>

Lists look simple, but when they are nested and/or contain sub-paragraphs and code blocks then things can get quite complicated. 

If your lists comprise just short single sentences then you will find lists easy and intuitive to use; otherwise you are advised to read the list of rules carefully. 

##### General rules

1. Lists start with a blank line, followed by a line were the first 
  non-white-space character is either one of `-+*` for a bulleted list or a digit followed either by a dot (`.`) or a parenthesis (`)`) for an ordered list. This is called the list marker.
   
1. If a list follows a paragraph no blank line is needed between the paragraph 
   and the list.

   Note that this makes life often easier because pretty much everybody assumes that one can start a list straight away after
   a paragraph. Watch out, this can backfire: if a line within a paragraph happens to start with a number then this **starts a list**!
   
   In real life however this a) happens rarely and b) people are way more likely to want to start a list when it doesn't. That's why **_MarkAPL_** is taking this approach.
 
1. A list definition --- including all sub lists --- breaks at two consecutive 
   empty lines.
 
1. A list definition --- including all sub lists --- also breaks when after an 
   empty line something is detected that does not carry a list marker **and** is not indented at all.

1. A change of the list marker for bulleted lists (from `+` to `*` for 
   example) starts a new list.

1. Lists can be nested.

1. The number of leading white-space characters between the left margin and 
   the list marker (in case of a list item itself) or content (in case of a sub-paragraph or a code block) defines the level of nesting.
 
   That means that any content that is supposed to belong to a particular list item must be indented by the number of 
   characters of the list marker plus the number of white-space characters to the left and to the right of the list marker.   

1. Between a list marker and the content there might be any number of white 
   space characters.

1. A list item can contain nothing but:
   * text (sometimes called initial list item content)
   * paragraphs 
   * code blocks
   * sub-lists
   
   Note that this is a **_MarkAPL_** restriction.

1. If a list item contains a code block or a paragraph then there **must** be 
   an empty line before the code block or paragraph respectively. 

1. A stand-alone code block may have zero or up to three leading spaces. This 
   rule **does not apply** for code blocks that are part
   of a list item since spaces are used as the means to work out which list level the code block belongs to. That means that if for the
   non-fenced lines the indentation is not right it does not qualify as a code block at all.
 
1. Single empty lines between list items and sub-paragraphs / code blocks 
  belonging to a list item are ignored.
 
1. There is no concept of "loose" or "tight" lists. As a consequence the 
   initial contents of a list item is never wrapped in a `<p>` tag.

   Note that this is a **_MarkAPL_** restriction.

1. Neither a code block nor a sub-paragraph can reduce the nesting level. This 
   is only possible with a line carrying a list marker.

1. Closing LI tags (`</li>`) are optional according to the W3C HTML5 
   specification. However, **_MarkAPL_** adds **always** a closing `</li>` tag starting with version 2.0.
 
Note that these rules differ from those from the original Markdown (which are inconsistent) and also CommanMark (which are consistent but very complex). 

Originally **_MarkAPL_** attempted to implement the CommanMark rules. However, the first bug reports all referred to list problems, and only one was a true bug. Everything else was caused by misunderstanding those very complex rules. Therefore, starting with version 1.3.0, **_MarkAPL_** now has its own ---  simpler and still consistent --- set of rules. With these easier to understand rules everything can be achieved but wrapping the content of a list item into a `<p>` tag.  

**A word of warning:** getting the number of white-space characters wrong --- in particular for sub-paragraphs or code blocks --- is the most common reason for unwanted results. You are advised to use a monospace font since this makes it much easier to spot such problems, or to avoid them in the first place. 



##### Bulleted lists

Bulleted --- or unordered --- lists can be marked by an asterisk (`*`), a plus (`+`) or a minus (`-`). There might by zero to three white-space characters between the left margin and the list marker. There might be any number of white-space characters between the list marker and the beginning of the contents.

Note that for nesting you need to have at least one more space to the left of the list marker per additional level. Although you can choose the number of spaces freely items that are supposed to end up on the same level must have the same number of leading spaces, otherwise results become unpredictable.

It is recommended to indent with readability in mind.

Example:

~~~
* First line
* Second line
  * Yellow
  * Brown 
    * Light brown
    * Medium brown
  * Magenta
* Third line              

~~~

This results in this:

* First line
* Second line
  * Yellow
  * Brown 
    * Light brown
    * Medium brown
  * Magenta
* Third line                

##### Ordered lists

An ordered list must start with a digit followed by a dot (`.`) or a parentheses (`)`) and one or more white-space characters. The digit(s) in the first row define the starting point. For the remaining rows any digit will do. Note that some browsers cannot deal with more than 9 digits, so that's the limit. 

There might by zero to three white-space characters between the left margin and the list marker. There might be any number of white-space characters between the list marker and the beginning of the contents.

Example:

~~~
5. First line
5. Second line
   1) Yellow
   2) Brown 
   3) Magenta
1. Third line                          
~~~

This results in this:

5. First line
5. Second line
   1) Yellow
   1) Brown 
   1) Magenta
1. Third line 

##### List item contents

You may want to inject line breaks for readability, or you may not and be lazy, and you may add blanks or not; all has the same effect. 

An example for the lazy approach:
~~~
* This is a list item with plenty of words.  Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus. Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
* ...
~~~

The same with some line breaks:

~~~
* This is a list item with plenty of words.  Lorem ipsum dolor sit amet, consectetuer
adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra
nec, fringilla in, laoreet vitae, risus. Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` 
semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
* ...
~~~

The same nicely formatted:

~~~
* This is a list item with plenty of words.  Lorem ipsum dolor sit amet,
  consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. 
  Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
  Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` semper ipsum sit amet
  velit. Suspendisse id sem consectetuer libero luctus adipiscing.
* ...
~~~

However, this would work as well:

~~~
* This is a list item with plenty of words.  Lorem ipsum dolor sit amet,
 consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
     Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae,risus.
  Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` semper ipsum sit amet
  velit. Suspendisse id sem
            consectetuer libero luctus adipiscing.
* ...
~~~

In all cases this would be the result:

---
* This is a list item with plenty of words.  Lorem ipsum dolor sit amet,
 consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
     Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae,risus.
  Donec sit amet nisl. Aliquam `(+/⍵)÷⍴,⍵` semper ipsum sit amet
  velit. Suspendisse id sem
            consectetuer libero luctus adipiscing.
* ...

---

Notes:
* Line breaks can be injected anywhere, even within links, but not in code (
  anything between two back-ticks).
* Indentation matters only in the first line of any list item and 
  sub-paragraph as well as for the fencing lines of any code blocks.
* The end of the contents of a list item (not a list!) is defined by one of:
  * An empty line (including lines that comprise nothing but spaces)  
  * A line (with or without any leading white-space) that starts with a list 
    marker.

##### Paragraphs and code blocks in list items

The fencing lines of code blocks as well as the first line of paragraphs that belong to a list item need to be indented by the same number of spaces as the list item they belong to. They **must** be separated from the initial list item contents or any earlier sub-paragraph or code block by a blank line.  

Note that the number of leading white-space characters (indentations) of any paragraphs must match the number of white-space characters from the left margin to the beginning of the content (the list marker characters count as white space here!) of the list item the paragraph or code block is supposed to belong to.

~~~
1. First line
1. Second line
   * Yellow
     This is **not** a paragraph.

     This **is** a paragraph.

     ~~~
       {+/⍳⍴⍵}
     ~~~

   This is a paragraph that belongs to "Second line".
   * Brown 
   * Magenta
1. Third line                          
~~~

This results in this:

1. First line
1. Second line
   * Yellow
     This is **not** a paragraph.

     This **is** a paragraph.

     ~~~
       {+/⍳⍴⍵}
     ~~~

   This is a paragraph that belongs to "Second line".
   * Brown 
   * Magenta
1. Third line                                   

Note that the code block has two leading spaces **within the fence**. These make it into the output while the leading spaces defining just the indentation don't.

##### Lists and special attributes

When [Special attributes](#) are assigned to the very first item on any list then that definition is assigned to the **list** (<ul> or <ol>) rather than the list item itself.

When special attributes are assigned to other items than the first one then they are simply removed from that list item.

#### Paragraphs

Any text between two lines that are either empty or are considered special Markdown syntax and that do not have any leading character(s) recognized as Markdown directives will result in a single paragraph. The only exception is a definition list: Although the term part looks like any ordinary paragraph, the `: ` on the next non-empty line makes it rather a definition.

Within a paragraph you can use in-line mark-up; see there.

You may insert NewLine characters (by pressing the <return> key) into a long paragraph in order to improve readability. These NewLine characters won't make it into the output. You don't have to worry about space characters at the end of a line (or at the beginning of the next line) because **_MarkAPL_** is taking care of this for you.

If you want to have a line break at the end of a line add a backslash to that line. 

Alternatively you can insert `<<br>>` **anywhere** into a paragraph in order to enforce a line break; see [Line breaks](#) for details.

Note that the original Markdown syntax for line breaks (having two spaces at the end of a line) is **not** supported by **_MarkAPL_**, and for good reasons: hard to spot (if at all), likely to be inserted by accident and therefore likely to cause confusion. 

You can assign [Special attributes](#) to a paragraph. With a multi-line paragraph, the special attribute must go into the **last line** as shown in this example:

~~~

 Simple and not multi-line
 paragraph {#author}

~~~

This results in this HTML:

~~~
<p id="author">Simple and not multi-line paragraph</p>
~~~

There is of course a small chance that something is interpreted as special attribute that actually is just part of the paragraph. In that case you need to escape the curly brackets with `\{` and `\}`. 

#### Tables

##### Overview{#ov2}

A table must be separated from other stuff by empty lines.

Note that table rows are defined by having at least one un-escaped pipe symbol. You may however add a leading as well as a trailing pipe symbol if you wish so. Many consider this to be more readable. 

However, a one-column table can only be constructed with either a leading or a trailing un-escape pipe symbol, or both.

In one respect **_MarkAPL_** goes beyond the standard: according to the Markdown specification you **must** have a second row with a hyphen ("`-`") and the appropriate number of pipe symbols and zero, one or two colons (`:`) per column but **_MarkAPL_** doesn't require this: if there is no such row it assumes that the first row is not a row with column headers but an ordinary row.

Notes:
* Leading and trailing spaces are removed from all cells.
* Automated alignment detection based on the data type of a column can be slow 
  with very large tables (several thousands of lines). You are advised to specify the alignment yourself for such tables to avoid a penalty.

##### Constructing tables

So valid table definitions look like this: 

~~~
Name | Meaning  {style="margin-left:auto;margin-right:auto;"}
-|-
 APL  | Great
 Cobol| Old
 PHP| Oh dear
~~~

resulting in this:

Name | Meaning   {style="margin-left:auto;margin-right:auto;"}
-|-
 APL  | Great 
 Cobol| Old   
 PHP| Oh dear

If you wonder about `{style="margin-left:auto;margin-right:auto;"}`: this is a simplified syntax for assigning IDs, class name(s) and attributes. This is discussed under [Special attributes](#).

Here it is used to style the table with CSS so that it will be centered.  

Another example which you might find more readable:

~~~
| Name  | Meaning |
|-------|---------|
| APL   | Great   |
| Cobol | Old     |
| PHP   | Oh dear |
~~~

resulting in this:

|Name | Meaning|
|-----|--------|
| APL  | Great |
| Cobol| Old   |
| PHP| Oh dear |

Without the `|-----|--------|` row:

~~~
|Name | Meaning|
| APL  | Great |
| Cobol| Old   |
| PHP| Oh dear |
~~~

we get this: 

|Name | Meaning|
| APL  | Great |
| Cobol| Old   |
| PHP| Oh dear |

##### Column alignment

Note the colons in row two of the following example: they define the alignment of all cells in that column.

~~~~
|Name | Meaning| Numbers |
|:-   |:------:|--------:|
| Left| Center | Right |
| A   | B      |  1.00 |
| C   | D      | -99.12 | 
~~~~

This results in:


|Name | Meaning| Numbers |
|:-   |:------:|--------:|
| Left| Center |   Right |
| A   | B      |  1.00 |
| C   | D      | -99.12 | 	

If you want a table without column titles but alignment:

~~~
|:-   |:------:|--------:|
| Left| Center |   Right |
| A   | B      |  1.00 |
| C   | D      | -99.12 | 	
~~~

|:-   |:------:|--------:|
| Left| Center |   Right |
| A   | B      |  1.00 |
| C   | D      | -99.12 | 	

##### In-line mark-up in cells

Cells can use in-line mark-up as shown here:

~~~
|First name            |Last Name   |No.        |Code                 |
|:---------------------|:-----------|-------:|:----------------------:|
|Kai                   | Jaeger     | 1      |`{{⍵/⍨2=+⌿0=⍵∘.|⍵}⍳⍵}` |
| Johann-Wolfgang      | von Goethe | 1923   |`{(⍴,⍵)÷+/,⍵}`         |
| <http://aplwiki.com> | **bold**   | 123.23 |  `fns ⍣a=b⊣123`       |
| _Italic_             | ~~Strike~~ |        |   \|                  |
| line<<br>>break             | |        |          |
| Last line |
~~~

This is the result:

|First name            |Last Name   |No.        |Code       |
|:---------------------|:-----------|-------:|:------------:|
|Kai                   | Jaeger     | 1      |`{{⍵/⍨2=+⌿0=⍵∘.|⍵}⍳⍵}` |
| Johann-Wolfgang      | von Goethe | 1923   |`{(⍴,⍵)÷+/,⍵}`|
| <http://aplwiki.com> | **bold**   | 123.23 |  `fns ⍣a=b⊣123` |
| _Italic_             | ~~Strike~~ |        |  \|            |
| line<<br>>break             | |        |          |
| Last line |

Note that one cell contains a pipe symbol (`|`); normally that would confuse the parser but not in this case because it is escaped with a backslash character: `\|`.

You can have a table with just column headers:

~~~
|First name |Last Name|
|-|-|
~~~

This is the result:

|First name |Last Name|
|-|-|

### Misc

<<SubTOC>>

#### Escaping

These characters have a special meaning in Markdown: `"_*|<~{}(``&`. They can be escaped with a `\` character which takes the special meaning away from that character. Note that escaping the `&` characters allows one to enter HTML entities. Without escaping the HTML entity would just show, without it being converted.

It means that these characters can be escaped but at the same time `C:\Temp\MyFoo.txt` becomes just C:\Temp\MyFoo.txt: there is no need to double the backslashes.
  
Note that there is an exception to the rule: if `\"` has a preceeding (opening) `"` then it is **not** considered an escape character.

This has two effects:
  
  1. `"C:\Temp\"` results in `“C:\Temp\”` which will almost certainly be 
     appreciated.
  1. `"This: \" is an escaped double quote"` will result in "This: \" is an 
     escaped double quote" which is certainly not appreciated.
  
However, the first case is something you will come across frequently while the second one is unlikely to ever cause headache.

#### Reserved names (CSS)

There are a few HTML elements that get a class name assigned by **_MarkAPL_** in order to tell them apart from other HML elements:

* All footnote links in the document are assigned the class "footnote_link". 
  These are the links somewhere in the document pointing to the footnotes at the very end of the document.
* All footnote anchors are assigned the class "footnote_anchor". 
  These are the footnotes positioned at the very end of the document.
* All anchors generated automatically for headers get the class name 
  "autoheader_anchor" assigned.
* All bookmark links created by the user via the `[header](#)` syntax get a 
  class name "bookmark_link" assigned.
* All external links get the class name "external_link" assigned.
* All "mailto" links get the class name "mailto_link" assigned.
* If `reportLinks` is 1 all links are listed at the very end of the document 
  (but before any footnotes) with their URLs and link text. 
  These are embraced by a <div> with the ID "external_link_collection". 
* The default screen CSS comes with a class `.print_only` that defines just 
  "display:none;". This is used to make the link report invisible on the screen for example. 
  You may use it for similar tasks.

Naturally you must not use these class names when assigning class names via [special attributes](#).

#### Function calls

It is possible to embed APL function calls in your Markdown document. The simplest way to call a function `#.foo` is:

~~~
This: ⍎⍎#.foo⍎⍎ is the result.
~~~

Given a function `#.foo←{'FOO'}` this will be the result:

~~~
This: FOO is the result.
~~~

The purpose of this features is to either inject simple text or one or more HTML blocks.

Notes:

* You cannot inject Markdown: it won't be processed any more when the function 
  is called. However, in-line mark-up (`**`, `_`, `~~` etc) **is** recognized and processed, and typographical sugar is available, too.
* The function name must always be fully qualified; that means the function 
  cannot live in either a class instance or an unnamed namespace.
* The "ns" namespace is **always** provided as right argument to the function. 

You may specify something to the right as in this example:

~~~
This: ⍎⍎#.foo 1 2 'hello'⍎⍎ is the result.
~~~

The array `1 2 'hello'` is however passed as **left** argument since `ns` is always passed as the right argument.

The result of such an embedded function must be one of:

* An empty vector.
* Markdown (simple string or nested vector of text vectors).
* An HTML block (nested vector of text vectors).

However, mixing Markdown and HTML blocks is **not permitted**. 

In case the function returns an HTML block the function call must stand on its own on a line.

If an HTML block is returned then the function is responsible for the correct formatting. In particular a `<pre>` block **must** look like this otherwise you might not get the desired result:

~~~
<pre><code>Line 1
Line 2
Last line
</code></pre>
~~~

Notes:

* If the function returns something that starts with a < and ends with a 
  corresponding tag then it it is recognized as an HTML block. You can prevent that by adding leading white space.
* The `<pre><code>` must go onto the same line as the first line of the code; 
  otherwise you end up with a starting empty line.
* If the embedded function returns something with a depth different from 0, 1 
  and 2 an error is thrown.

#### Special attributes

One can add special attributes --- that is an ID, class name(s) and other attributes --- to many elements

* Code blocks
* Definition lists
* Headers
* Horizontal rulers
* Images
* Links (but not references to link references)
* Lists
* Paragraphs
* Tables

Notes:

* Special attributes can only be defined at the end of a line with the notable 
  exceptions of links and images. See [Images](#) for an example.
* If you assign an ID to a header the ID is not actually assigned to the 
  header itself but the associated anchor (bookmark link). Since such an anchor embraces the header tag the header can be styled via the anchor (child selector). 
* If an attempted definition of a special attribute fails due to an error like 
  missing `=` or an odd number of `"` etc then it's not going to become a special attribute definition but ordinary data; that means it will show in the document.
* Although for ordinary links special attributes can be assigned, for links 
  that uses a link reference this is not supported. However, for the link reference definition as such special attributes **can** be defined.

##### Assigning a class name

The name of a class can be assigned by just mentioning the name:

~~~
{.classname}
~~~

The leading dot tells **_MarkAPL_** that it is a class name. 

Of course you can specify more than just one class name:

~~~
{.foo .goo}
~~~

##### Assigning an ID

An ID can be assigned by just mentioning the name:

~~~
{#id}
~~~

The leading `#` tells **_MarkAPL_** that it is an ID.

##### Styling

CSS styling directives are possible as well:

~~~
{style="color:red;line-height:1.4;"}
~~~

##### Quotes and special attributes

It is of course possible to put it all together:

~~~
* list item {#myid style="font-family:'APL385 Unicode'" .class1 .class2 target="_blank"}'
~~~

Note that you cannot put double-quotes around the name of the font family here because double-quotes are already used to determine the definition of the "style" attribute. Therefore you **must** use single quotes in this instance.  

##### Paragraphs and special attributes

Naturally a multi-line paragraph must define any special attributes at the very end of the paragraph rather than the end of the first line.

Note that there is a chance for content being mistaken as a special attribute, but this chance is very small indeed. If that happens just escape the curlies with a backslash character:

~~~

This is a paragraph with curlies at the end: \{\}.

~~~

#### Data

You can inject key-value pairs of data into a Markdown document.

**_MarkAPL_** itself does not make use of such variables. It is up to other applications to take advantage of these pieces of data. 

See <http://aplwiki.com/PresentAPL> for an example: This is software that generates a slide show from a single Markdown document.

It uses this feature to allow the author to set variables like "author", "company" and "title" which are then used to populate slides and meta tags.  
  
Example:  

~~~
[Data]:author='Kai Jaeger'
[DATA]:copies=2
[data]:sequence=1 2 3
[data]:company=Dyalog Ltd
~~~

This establishes the key-value pairs as ordinary variables in the namespace 
`ns.data`. See [The "ns" namespace](#) for details.

The statements shown will create this:

~~~
      Display ⊃ns.data
┌→────────────────────────┐
↓ ┌→─────┐   ┌→─────────┐ │
│ │author│   │Kai Jaeger│ │
│ └──────┘   └──────────┘ │
│ ┌→─────┐                │
│ │copies│   2            │
│ └──────┘                │
│ ┌→───────┐ ┌→────┐      │
│ │sequence│ │1 2 3│      │
│ └────────┘ └~────┘      │
│ ┌→──────┐  ┌→─────────┐ │
│ │company│  │Dyalog Ltd│ │
│ └───────┘  └──────────┘ │
└∊────────────────────────┘
~~~

Notes:

* The keyword ("data") is case insensitive.
* '[data]:` can appear anywhere in the document.
* There may be any number of white-space characters between "[data]:" and the 
  name.
* The name must consist of nothing but US ASCII or digits.
* If the value is not enclosed by quotes **_MarkAPL_** attempts to establish 
  it as numeric value. If that fails however it attempts to establish it as text.
* If an entry is invalid the value is empty. For example, in 
  `[data]:invalid='text 1 2 3` the closing quote is missing, therefore the expression is invalid. 
* Problems are reported on [`ns.report`](#report).
* MarkAPL does **not** support a key to be defined more than once. In case 
  there are several definitions for the same name the last one wins.

#### Sub topics

By inserting `<<SubTopic>>` (case insensitive) one can insert a table of contents for a sub topic. This can be useful in order to avoid overloading the main table of contents. This document has several such SubTOCs embedded, for example [The "ns" namespace in detail](#).

#### Embedding parameters with `[parm]:`

With version 2.6 a mechanism was introduced to embed parameters within a markdown document: by using `[parms]:` you can tell **_MarkAPL_** that this defines a key/value pair as a **_MarkAPL_** parameter. Naturally this is a **_MarkAPL_**-only feature.

For example, this document carries the following lines:

~~~
[parm]:toc            = 2 3
[parm]:numberHeaders  = 2 3 4 5 6
[parm]:bookmarkLink   = 6
[parm]:collapsibleTOC = 1
[parm]:title          = 'MarkAPL Reference'
[parm]:width          = 1000
[parm]:reportLinks    = 1
~~~

These define parameters specific to this document.

Notes:
* Such definitions must be the very first ones in a document.
* Those definitions take precedence over standard (or default) parameters; 
  therefore they cannot be overwritten unless you set the [ignoreEmbeddedParms](#"`ignoreEmbeddedParms`") parameter to 1.
* The `[parms]` part is case insensitive.
* All embedded parameters are collected on `ns.embeddedParms`.

This can be useful to create an HTML file from a Markdown file with **_MarkAPL_** without setting any parameters because the document itself "knows" what parameters are best for it.

### Methods

<<SubTOC>>

#### ConvertMarkdownFile

Takes a filename as right argument. The file is expected to hold Markdown. By default a fully-fledged HTML page is created from that Markdown file with exactly the same filename except that the file extension is `.html` rather than `.md`.

However, instead of accepting the defaults one can create a parameter namespace with:

~~~
parms←#.MarkAPL.CreateParms
~~~

and then specify different parameters within `parms`. That parameter space `parms` then needs to be passed as left argument to the `ConvertMarkdownFile` method.

Note that `inputFilename` **must not** be specified, otherwise an error is signalled. This is because the input file is already defined by the right argument.

#### CreateParms

Niladic function that returns a namespace populated with parameters carrying their default values. `CreateParms` tries to find for every parameter a value from the command line or environment variables. If it cannot find them it will establish a default value.

#### CreateHelpParms

Niladic function that returns a namespace populated with parameters carrying their default values. Internally it calls `CreateParms` and then adds some parameters that are needed by the [`Help`](#) and [`Reference`](#ref_method) methods.
      
#### Execute

This function is used exclusively by test cases.
          
#### Help

The function takes a Boolean right argument: 
* A 0 just views "MarkAPL_CheatSheet.html" with your default browser.
* A 1 forces `Help` to recompile the file "MarkAPL_CheatSheet.md" into 
  "MarkAPL_CheatSheet.html" and then put it on display.

You might specify an optional left argument: a parameter space, typically created by calling the `CreateHelpParms` method. This allows creating a document with non-default parameters. Of course this has only an effect when the right argument is a 1. 

Note that the file "MarkAPL_CheatSheet.html" carries several [embedded parameters](#Embedding parameters with `[parm]:`) --- those cannot be overidden by a parameter namespace unless you assign a 1 to [`ignoreEmbeddedParms`](#).

In order to enable `Help` to find the file "Markdown_CheatSheet.html" (in case the defaults don't work) you must create a parameter space and then set [`homeFolder`](#) accordingly.
             
#### Init

Takes a two-item-vector as right argument:

1. A parameter namespace, typically created by calling `CreateParms`.
2. A vector of character vectors: the Markdown.

Returns [the "ns" namespace](#).  
             
#### MakeHTML_Doc

Takes HTML, typically created by calling `Process`, and makes it a fully fledged HTML document by adding <body>, <head> --- with <title> --- and <html> with the DocType.
     
#### MarkDown2HTML

This ambivalent function requires some Markdown as right argument.

It returns (since version 1.7.0) a two-item vector (shy):

* The HTML.
* The `ns` namespace. This allows you to check `ns.report` for any problems.

Without an --- optional --- left argument it creates just the HTML from the Markdown.

However, you can also create a parameter space by calling `CreateParms` and set `outputFilename`. In that case it will create a fully-fledged HTML page from the Markdown and write it to that file. The generated page is also returned as result.

Finally one can also set the `inputFilesName` parameter. This trumps the right argument: it reads the input file, expecting it to be Markdown, creates HTML5 from it and write it to the output file. Again the HTML is also returned as result.

Internally it calls `Init` & `Process` & `MakHTML_Doc`. 

#### Matrix2MarkdownList

This is a helper method that converts an APL matrix into a Markdown list definition; see [Helpers](#) for details.

#### Matrix2MarkdownTable

This is a helper method that converts an APL matrix into a Markdown table definition; see [Helpers](#) for details.

#### Process          

This function takes --- and returns --- an `ns` namespace which was typically created by calling `Init`. 

#### Reference{#ref_method}

The function takes a Boolean right argument: 
* A 0 just views "MarkAPL.html" with your default browser.
* A 1 forces it to recompile the file "MarkAPL.md" into "MarkAPL.html" and th
  then put it on display.

You might specify an optional left argument: a parameter space, typically created by calling the `CreateHelpParms` method. This allows creating a help file with non-default parameters. Of course this has only an effect when the right argument is a 1. 

Note that the file "MarkAPL.html" carries several
[embedded parameters](#Embedding parameters with `[parm]:`) --- those cannot be overidden by a parameter namespace unless you assign a 1 to `ignoreEmbeddedParms`.

In order to enable `Reference` to find the file "MarkAPL.html" (in case the defaults don't work) you must create a parameter space and then set 
[`homeFolder`](#) accordingly.
 
#### Version

Returns the name, the version number and the version date of **_MarkAPL_**.

### Parameters

#### Overview{#OV3}

In order to specify parameters follow these steps:

~~~
      parms←#.MarkAPL.CreateParms''
      parms.∆List   ⍝ lists all parameters with their defaults
 bookmarkLink                                        6 
 bookmarkMayStartWithDigit                           1
 charset                                         utf-8 
 checkFootnotes                  ⍝ defaults to "debug"
 checkLinks                      ⍝ defaults to "debug"
 collapsibleTOC                                      0
 compileFunctions                                    1 
 compressCSS                                         1
 createFullHtmlPage                                  0
 cssURL                                             ¯1
 debug                      ⍝ 0 in Runtime, 1 otherwise
 enforceEdge                                         1
 footnotesCaption                          'Footnotes'
 head                                               '' 
 homefolder                                         ¯1
 inputFilename                                         
 lang                                             "en"
 linkToCSS                                           0 
 markdownStrict                                      0 
 noCSS                                               0
 numberHeaders                                       0 
 outputFilename                                        
 printCSS                            MarkAPL_print.css 
 reportLinks                                         0
 reportLinksCaption                      'Link report'
 screenCSS                          MarkAPL_screen.css
 showHide                                  'Show;Hide' 
 subTocs                                             1 
 title                                         MarkAPL 
 toc                                                 0 
 verbose                                             1 
 width                                           900px
~~~

The function `∆List` lists all the variables in the parameter space with their corresponding values.

After making amendments the parameter space can be passed as the first argument to the `MarkAPL.Init` function. See [How-to](#) for details. 

#### The parameters in detail

<<SubTOC>>
 
##### bookmarkLink

Defaults to 6. That means that all headers of level 1 to 6 are going to be embraced by anchors (bookmarks). See [Headers and bookmarks](#) for details.

Set this to 0 to suppress the insertion of automated bookmark links altogether.

There is not really a good reason for suppressing this except things like **_MarkAPL_** calling itself recursively for blockquotes. Those blockquotes might contain headers, but you don't want them anchored - they might interfere with your real headers. 

##### bookmarkMayStartWithDigit

Boolean that defaults to 1: in HTML5 an ID (= bookmark) may indeed start with a digit.

However, sometimes it might be appropriate to avoid this, for example when **_MarkAPL_** creates a Sub-Topic. In such --- quite special --- circumstances it may well be appropriate to set this to 0.

##### charset

Defaults to "utf-8".

##### checkFootnotes

Boolean. The default depends on `debug`. If this is 1 the `Process` method checks all footnotes and reports any problems on `ns.report`.

##### checkLinks 

Boolean. The default depends on `debug`. If this is 1 the `Process` method checks the internal (bookmark) links and reports any problems on `ns.report`.

##### collapsibleTOC

This is a Boolean that defaults to 0. If you set this to 1 it has two effects:

1. Initially the TOC is collapsed: it shows just the line "Table of contents (
   show)". When the user clicks on this the TOC is fully expanded (screen estate permitted) to the levels defined by the [`toc`](#) parameter while the header line changes to "Table of contents (hide)". That way a TOC is not obtrusive.
1. The TOC is positioned at the top-right corner of the view port, and there 
   it remains even if the user chooses to scroll.

This feature does not require any JavaScript: it's a pure CSS solution.

**However, it has drawbacks:**

* If the TOC is long the user might not be able to see all of the TOC, in 
  particular on small monitors. Note that technically it is not possible to allow the user to scroll within the TOC.

* When the user searches for something the browser will **not scan any part of 
  the TOC** that is invisible due to the lack of screen estate.

One might be able to overcome these obstacles by restricting the level of headlines that go into the main TOC and introduce sub-TOCs where appropriate. This document uses this technique.

##### compileFunctions

Boolean that defaults to 1. There is just one reason to prevent any function from being compiled: performance measurements.

However, with version 1.8.3 MarkAPL does not compile its functions anymore because this caused trouble under some circumstances while the performance gains are little: **_MarkAPL_** spends most of its time in `⎕S` and `⎕R`, and compiling does not help.

##### compressCSS

Boolean that defaults to 1. This does the following things:

* Remove all comments
* Remove all multiple blanks
* Convert the CSS into a single line.

This saves a significant amount of space. You are advised to set this to 0 only for making it possible to change the CSS on the fly in order to check out certain things, otherwise this should always be 1.

Note that this parameter has an effect only when the CSS is injected.

##### createFullHtmlPage

This parameter is `¯1` by default (undefined). That means that the default behaviour of [`Markdown2HTML`](#) is defined by the setting of [`outputFilename`](#): if it is not empty it will default to 1, otherwise to 0.

It can be set to either 0 or 1:

* A 0 means that the given Markdown is converted into an HTML snippet, no 
  matter whether `outputFilename` is empty or not.
* A 1 means that the given Markdown is converted into a fully fledged HTML 
  page, no matter whether `outputFilename` is empty or not.

##### cssURL

Holds the web address or folder that is expected to host the two CSS files needed for screen and print.

Defaults to `homeFolder`.

##### debug

Boolean that defaults to 1 in development and 0 otherwise.

Note that this parameter influences the defaults of a number of other parameters: `checkLinks` and `checkFootnotes` are examples.

##### enforceEdge

This defaults to:

~~~
      <meta http-equiv="X-UA-Compatible" content="IE=edge" />
~~~

This will become the very first <meta> tag in the header.

This should only have an effect when the page created by **_MarkAPL_** is displayed by Microsoft's Webbrowser COM (or ActiveX) control. This control uses the oldest version of IE 8 on any given machine by default. Instead one can specify any IE or even Edge, Microsoft's latest browser at the time of writing, and that's exactly what the above statement achieves.

##### footnotesCaption

String that defaults to "Footnotes". This is placed above the footnotes section.

##### head

If you want to add additional meta tags to the `<head>` part of a document (just an example) you can assign them to `head`. They will then be added to the `<head>` section. This can be a simple string (representing <title> for example) or a vector of simple text vectors (several meta tags for example).

##### homeFolder

This points to the folder where Markdown.html and MarkAPL_CheatSheet.html and the default CSS files live. If this is not set then **_MarkAPL_** tries to find it:

1. First it tries to find the two HTML files in the current directory. 
2. Next it tries to find them in a sub-folder `Files\` within the current 
   directory.
3. Next it investigates whether **_MarkAPL_** was loaded with SALT. If so it 
   tries to find those files in that folder.
4. Finally it tries to find them in a sub-folder `Files\` within the SALT 
   source folder.
5. If that fails `homefolder` is set to the current directory, but it means 
   that the help commands in the menu won't be able to work properly, and other things may fail as well. The user should set `homeFolder` in such cases.

##### ignoreEmbeddedParms

Boolean that defaults to 0. If you want to overrule any embedded parameters then you must set this to 1. See [Embedding parameters with `[parm]:`](#) for details.

##### inputFilename

If the Markdown you want to process lives in a file rather than the workspace then you can pass an empty vector as right argument to the `Process` method and specify `parms.inputFilename` instead. 

##### lang

This defaults to <<en>> for <<English>>. <<lang>> is added to the <html> tag if it is not empty. If you wish so you can specify a different language.

Specifying the correct language may have benefits you cannot possibly think of when writing the page; that's why it is now considered important, and the W3C HTML validator will issue a warning if it is missing.

An example for this information being essential: it allows screen readers to choose the correct pronounciation when reading out.

This parameter makes also a difference when it comes to deciding what is an opening and what is a closing double quote: Germany, Austria and Switzerland differ in this respect from other countries.

##### linkToCSS

Boolean that defaults to 0. This means that CSS for screen and print is injected into the resulting HTML page. If this is 1 a <link> tag for the CSS file(s) is added to the header. Naturally `cssURL` must be set accordingly then.

Note that certain parameters have no effect when `linkToCSS` is 1.

##### markdownStrict

Boolean that defaults to 0. Settings this to 1 prevents **_MarkAPL_** from executing certain operations:

* It does **not** attempt to create typographically correct output by 
  exchanging:
  * `...` by ellipses.
  * `---` by em-dashes. You may or you may not have blanks around them. 
  * `--` by en-dashes. You may or you may not have blanks around them.
  * straight quotes against curly quotes.
* It does not replace `(c)` by the copyright symbol.
* It does not replace `(tm)` by the trade-mark symbol. 
* It does not replace `<<` and `>>` by Guillemets.

##### noCSS

Boolean that defaults to 0. If you don't want to have any CSS at all the set this to 1. Useful for test cases, for example.

##### numberHeaders

An integer or integer vector that defaults to 0, meaning that headers are not numbered.

* Setting this to 3 means that all headers of level 1 to 3 will be numbered.
* Setting this to 2 3 4 will number all headers of level 2, 3 and 4.
  
##### outputFilename

Defaults to an empty vector. If specified the HTML will be written to this file by the [`Markdown2HTML`](#) method.

Note then in case [`createFullHtmlPage`](#) is not a Boolean but `¯1` (that's the default value which stands for "undefined") then the setting of `outputFilename` defines what is created from the Markdown:

* In case `outputFilename` is empty an HTML snipped is created.
* In case `outputFilename` is not empty a fully fledged HTML page is created.

##### printCSS

The name of the CSS file for printing. Defaults to `MarkAPL_print.css`. If this is empty no CSS for printing purposes is included or linked to.

##### reportLinks

Boolean that defaults to 0. If this is set to 1 then a list of all links together with the associated link text is added to the end of the document but before the footnotes (if any).

Note however that this list is not available on the screen, it's only available for print. This list is the only way for a user to actually see any links that have a link text when a document is printed.

When printed, links are not exactly useful. The only thing we can do is to make sure that the user can at least recognize them as links. With the default CSS, internal links are marked up with a leading arrow while external links show a symbol of the earth, and the text of both types of links is shown in italic. 

However, the user does not have the means to see the URL of any external link. `reportLinks` tries to ease the problem: all links are printed at the very end of the document together with their link text. 

##### reportLinksCaption

String that defaults to "Link report:". This is placed above the list of all links (see `reportLinks`).

##### screenCSS

The name of the CSS file for the screen. Defaults to `MarkAPL_screen.css`. If this is empty no CSS for viewing purposes is included or linked to.

##### showHide

This is ignored in case `collapsibleTOC` is 0. It defaults to "Show;Hide". The `;` acts as a seperator. If `collapsibleTOC` is 1 then the header of the TOC is compiled initially from `tocHeader` followed by ` (` and "Show". After that `)` is added.

When the user clicks on this "Show" (left to the `;`) is replaced by "Hide" (right to `;`) in the TOC header.

Note that this parameter has an effect only when the CSS is injected. Linked-to CSS must be prepared properly.

##### subTocs

Boolean that defaults to 1. If you want to suppress sub TOCs no matter whether there are any included in the Markdown or not then set this to 0. 

When set to 0 then any strings `<<SubTOC>>` are removed from the Markdown before processing it. This is mainly needed in order to suppress SubTOCs in blockquotes: those are processed by **_MarkAPL_** recursively, and you don't want to have any SubTocs injected into a blockquote.

Notes: a `<<SUBTOC>>` definition must ...
* stand in its own.
* start at the left edge

##### title

In case the document has exactly one level-1 header then `title` defaults to this header. Otherwise it defaults to "MarkAPL". 

Defines the `<title>` tag in the `<head>` section of the resulting HTML page.

##### toc (table of contents)

An integer or integer vector that defaults to 0, meaning that no table of contents is injected into a document created by **_MarkAPL_**.

You can change this by setting the parameter `toc` to ...

* a single integer like 3. That is interpreted as "up to 3": a TOC is compiled from the headers of level 1, 2 and 3 and injected into the HTML document. 
* a vector of integers. For example, 2 3 4 5 would mean that just these levels are used for creating the TOC.

Note that `bookmarkLink`must have at least the same value as `toc`.

You can influence the toc in several ways; see the parameters [collapsibleTOC](#), [tocCaption](#), [showHide](#)

##### tocCaption

Defaults to "Table of contents". Set this to any character vector you want to appear as header of the TOC. `tocCaption` will be ignored in case `toc` is 0.

Note that this parameter has an effect only when the CSS is injected. Linked CSS must be prepared accordingly.

##### verbose

Boolean that defaults to `debug`. If this is 1 then the `Process` method will print the contents off `ns.report` to the session.  

##### width

This defaults to `900px`. You can specify this either as a character vector or a numeric value. However, a numeric value always becomes `px` while a character value allows you to specify a different value, for example `80em`.

Notes:

* This is injected into the screen CSS only. The print CSS uses "auto" for this, allowing to take full advantage of the size of the paper.
* The parameter has an effect only when the CSS is injected. Linked CSS must be prepared accordingly.

### The "ns" namespace.

#### Overview{#OV4}

The `ns` namespace is returned (created) by the `Init` method and modified by the `Process` method. It contains both input and output variables.

Before `Process` is run the variables `emptyLines`, `leadingChars`, `markdown`, `markdownLC `and `withoutBlanks` hold data the is extracted from the Markdown. When `Process` is running block by block is processed and removed from these variables. At the same time the variable `parms.html` is collecting the resulting html. Other variables (`abbreviations`, `data`, `footnoteDefs`, `headers`, `linkRefs`, `parms`, `subToc` and `toc`) may or may not collect data in the process as well.

The two variables `report` and `lineNumber` are special, see there.

#### The "ns" namespace in detail

<<SubTOC>>

The namespace contains the following variables:

##### abbreviations

A (possibly empty) vector of two-item-vectors. The first item holds the abbreviation, the second item the explanation or comment. 
         
##### emptyLines

A vector of Booleans indicating which lines in `markdown` are empty. Lines consisting of white-space characters only are considered to be empty.

##### embeddedParms

A matrix with two columns and as many rows as there are [embedded parameters](#Embedding parameters with `[parm]:`).

This document for example carries these embedded parameters:

~~~
      ns.embeddedParms
 toc                            2 3 
 numberHeaders            2 3 4 5 6 
 bookmarkLink                     6 
 viewInBrowser                    1 
 collapsibleTOC                   1 
 title            MarkAPL Reference 
 width                         1100 
 reportLinks                      1 
 compressCSS          
~~~

##### footnoteDefs

A matrix that carries all footnote definition found in `markdown`. The matrix has these columns:

1. Running number, starting from 1. 
1. Bookmark name.
1. Caption.

##### headers

A matrix that carries all headers defined in `markdown`.

  The matrix has three or four columns:

1. The level of the header, starting with 0.
1. The anchor-ready version of the caption.
1. The caption.
1. The tiered number of the header. 

Naturally the last column does not exist in case `numberHeaders` is 0.
       
##### html

After having created the `ns` namespace by calling `Init` this variable is empty. By running the `Process` method this variable will be filled up.

##### leadingChars

After having created the `ns` namespace by calling `Init` this variable contains a limited number of characters from `markdown`. Leading white-space is removed. This increases performance for many of the checks to be carried out by `Process`.  

##### lineNumbers

After having created the `ns` namespace by calling `Init` this variable contains a vector of integers representing line numbers in `markdown`. This allows the line number to be reported. Also, [Function calls](# "Embedded APL functin calls") can access the line number as well.

Note that line numbers refer to the MarkDown, **not** the HTML.  
  
##### linkRefs

A vector of vectors holding information regarding all [link references](#):

1. id
1. url
1. alt text (possibly empty)
1. special attributes or empty

##### markdown

This variable holds the Markdown to be processed by `Process`.
     
##### markdownLC

Same as `markdown` but all in lower case. That speeds things up at the expense of memory.
   
##### noOf

The number of lines processed in the next (or current) step.
       
##### parms

The parameters that were passed to `Init`.
        
##### report

After having created the `ns` namespace by calling `CreateParms` this variable is empty. The `Process` method might add remarks to this variable in case it finds something to complain about or comment on.

Some methods print what they assign to `report` also to the session in case [verbose](#) is 1.

##### subToc

This is a vector of two-item vectors:

1. The level of the header, starting with 1.
2. The caption of the header as displayed.

##### toc

This is a vector of ~~three~~ four-item vectors (since version 1.3.3):

1. The level of the header, starting with 1.
2. The caption of the header as displayed.
3. The internal link name.

Not that previous to version 2.8 there was a forth column (4. The type of the header: 1 = SeText, 2 = ATX.) which was removed then.
       
##### withoutBlanks

Same as `markdown` but without any blanks. This speeds things up at the expense of memory.

How to
------

First of all, you can bring the document you are reading right now into view by executing `#.MarkAPL.Reference 0`. Viewing the file "MarkAPL.html" has the same effect.

You can view the cheat sheet by calling `#.MarkAPL.Reference 0`. Viewing the file "MarkAPL_CheatSheet.html" has the same effect.

One way to study how to make use of **_MarkAPL_** is to trace through the method `MarkAPL.Help`. This should clarify the principles.

Another way is to look at the test cases named `Test_Examples_01` etc in `#.TestCases` in the workspace MarkAPL.DWS. You can execute them with:

~~~
#.TestCases.RunThese 'Examples'
~~~

You can trace through them with

~~~
#.TestCases.RunThese 'Examples' (-⍳1000)
~~~

The numbers select the test cases of the given group (here "Examples") to be executed. `⍳1000` is just a fancy way to make sure that you catch all of them.

Negative numbers tell the test framework to stop right before a particular test function is going to be executed. That gives you the opportunity to trace through that function without tracing through the actual test framework. 

Helpers
-------

This chapter comprises all methods that help converting APL arrays into Markown.

<<SubTOC>>

### Matrix2MarkdownList

This helper method takes an APL matrix and converts it to a list definition in Markdown.

Note that the table must have three columns:

1. List type. A 0 defines a bulleted list. Any positive integer starts an ordered list, and defines at the same time the starting point.
2. Nesting level. The first row must start with nesting level 0 or 1.
3. Either a text vector or a vector of text vectors.

Example; this:

~~~
 m←''
 m,←⊂0 1 'Level 1 a bull'
 m,←⊂2 2 'Level 2 a num'
 m,←⊂2 2('Level 2 b num' '' 'Another para' '' '~~~' '{+⌿⍵}' '~~~')
 m,←⊂2 2 'Level 2 c num'
 md←#.MarkAPL.Matrix2MarkdownList⊃m
 ns←#.MarkAPL.Init''md
 ns←#.MarkAPL.Process ns
~~~

leads to this list:

* Level 1 a bull  
  2. Level 2 a num 
  2. Level 2 b num 
                   
     Another para  
                   
     ~~~
     {+⌿⍵}         
     ~~~

  2. Level 2 c num 

### Matrix2MarkdownTable

This helper method takes an APL matrix and converts it to a table definition in Markdown.

Without a left argument there are no column headers, and alignment is ruled by data type: strictly numeric columns are right-aligned, everything else is left-aligned:

~~~
      M←('APL' 99 'Really great')('Python' 70 'Nice')('Cobol' 1 'Oh dear')
      ⎕←#.MarkAPL.Matrix2MarkdownTable M
|-|-:|-|
| APL | 99 | Really great |
| Python | 70 | Nice |
| Cobol | 1 | Oh dear |
~~~

This results in this:

| :- | -: | :- |            
| APL | 99 | Really great | 
| Python | 70 | Nice |      
| Cobol | 1 | Oh dear |     

You can specify column headers via the left argument. Naturally the length of the left argument must match the number of columns in the matrix. You can use leading and trailing `:` in order to define column alignment.

Note that any `|` in the matrix is automatically escaped except when it appears in code:

~~~
      ch←'Lang' 'Prod:Rank' ':Comment:'
      M←('APL' 99 'Really great')('Python' 70 'Nice')('Cobol' 1 'Oh|dear')
      ⎕←#.MarkAPL.Matrix2MarkdownTable M
| Lang | Prod:Rank | Comment |
|-|-:|:-:|
| APL | 99 | Really great |
| Python | 70 | Nice `|`|
| Cobol | 1 | Oh\|dear |
~~~

This results in this:

| Lang | Prod:Rank | Comment |
|-|-:|:-:|
| APL | 99 | Really great |
| Python | 70 | Nice `|`|
| Cobol | 1 | Oh\|dear |

Notes:
* The first column is aligned to the left because the column title did not 
  define anything and the data is not strictly numeric, therefore the default takes place which is left-aligned.
* The second column is aligned to the right because the column title did not 
  define anything and the data is numeric.
* The third column is centered because that's what the column header defined.

Problems
-------

### Crashes

When **_MarkAPL_** crashes the most likely reason is an invalid definition. Check the variable `ns.markdown`: that tells you how far **_MarkAPL_** got in processing the Markdown. 

However, since **_MarkAPL_** should not crash and always produce a document it is appreciated when you report any crashes. See the next topic for how to report a crash.

### Bugs

Please report any bugs to <mailto:kai@aplteam.com>. I appreciate:

* The input (Markdown)
* Any non-default settings of parameters
* A short description of the problem (not as short as "It did not work!")

  This is particularly important because I have received a number of bug reports where **_MarkAPL_** did **exactly** what it was supposed to do, so without knowing what the user expected I cannot explain why it did not work, because it **did** work! One gentleman even insisted that there was nothing to explain because it was a no-brainer. Well, it wasn't.
  
  So please tell me what you expected to see.
  
* The version number of **_MarkAPL_**.

### Unexpected results

Before reporting a bug please check carefully your Markdown. More often than not mistakes in the Markdown are causing the problem.

If you cannot work out why it goes wrong report it to me -- see the previous topic for how to report a problem.

This document refers to version 2.8 of **_MarkAPL_**.<<br>>
Kai Jaeger ⋄ APL Team Ltd ⋄ 2017-02-10

[^abandon]: Wikipedia definition of abandonware: <https://www.wikiwand.com/en/Abandonware>
[^commonmark]: The CommonMark specification: <http://spec.commonmark.org/> 

*[Abbreviations]: Text is marked up with the <abbr> tag

[cheatsheet]: http://download.aplteam.com/MarkAPL_CheatSheet.htm "The MarkAPL cheatsheet"{target="_blank"}
[commonmark_on_html_blocks]: http://spec.commonmark.org/0.24/#html-blocks "Common mark on HTML blocks"{target="_blank"}
[git]: https://help.github.com/articles/working-with-advanced-formatting/ "GIT's formatting rules"{target="_blank"}
[markdown_extra]: https://www.wikiwand.com/en/Markdown_Extra{target="_blank"}
[pandoc]: http://pandoc.org/README.html{target="_blank"}