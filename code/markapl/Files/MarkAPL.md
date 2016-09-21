 MarkAPL
=====

Overview
-----------

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

In addition **_MarkAPL_** offers several enhancements that might be particularly useful to APLers and don't hurt otherwise. However, if compatibility is paramount then you must not use them. 

For example, any lines that start with an APL lamp symbol (`⍝`) --- except in a code block of course --- are considered comment lines which won't contribute to the output at all.

For a full list see the next chapter.

### Preconditions 

**_MarkAPL_** needs Dyalog APL version 14.0 or better.

Compatibility, features, bugs
----------------------------------

### Standard compliance

#### Intentional differences

* Code blocks are identified as such **just by fencing**. Any lines indented by 4 characters **do not**
  define a code block in **_MarkAPL_**.
  
* In front of the fencing characters there might be zero or up to three white space character. However, when a code block is part of a list item than those white space characters have special meaning, and there might also be more than just three of some.

* HTML blocks that must end with an end tag should **not have** anything after the end tag on that very line:
  it would be ignored.

* Although `\` is used as the escape character, and although `\\` results correctly in a single 
  backslash character, multiple backslashes as in `\\\` are not supported and must not be used.

  However, note that `\` at the end of a line in a paragraph inserts a page break - see [Line breaks](#) for details. 

* For defining any attributes a pair of double quotes must be used. Single quotes have no effect. (This
  contradicts the original Markdown documentation but due to a bug it did not work with the original Markdown implementation either)

* **_MarkAPL_** does not have the concept of "loose list items". In CommonMark, the contents of any list item that is followed by a blank line is called a "loose" list item and wrapped into an additional `<p>` tag. 

  This is of little value and complicates matters enormously. Therefore **_MarkAPL_** simply ignores a single empty line between list items. 

  You still get a `<p>` tag around something that actually belongs to the list item but only **after** the initial text. This is called a sub-paragraph. See [Lists](#) for details.

* According to the Markdown specification a list item following a paragraph must be separated from the
  paragraph by a blank line. The reason for this rule is probably that in very rare circumstances one might start a list accidentally.
  
  Experience shows however that users are way more likely to wonder why a list they intended to start straight after the end of a paragraph doesn't. For that reason **_MarkAPL_** does **not** require a blank line between the end of a paragraph and the first list item of a list.

* According to the original Markdown standard two spaces at the end of a line are converted into a line break
  by replacing the two blanks by `<br />`. This was actually implemented in version 1.0 of **_MarkAPL_**. 

  However, more than once a bug was reported regarding unintentional line breaks which were accidentally caused by adding two spaces at the end of a paragraph or a list item. Therefore with version 1.3 this ill-designed feature was removed from **_MarkAPL_**.

  Note that there are other --- and better --- ways to achieve the same goal: see [Line breaks](#) for details.
 

#### Not implemented

* Markdown in-line mark-up inside an HTML block is ignored. This restriction might be lifted depending on demand.

* All types of HTML blocks but one can, according to the CommonMark specification, interrupt a paragraph. There
  are no plans to implement this.

* According to the CommonMark specification a tag like `<div>` can have a line break in between and will still
  be recognized as a tag. Not only seems this to have very little value, it decreases readability. Therefore this is not implemented in **_MarkAPL_**.

* A list item can contain paragraphs, code blocks and sub-lists but nothing else.

### Enhancements

* For every header an anchor is created automatically by default. See [Headers and bookmarks](#) for details.

* Bookmark links have a special simplified syntax; see [Internal links (bookmarks)](#) for details.

* **_MarkAPL_** can optionally insert a table of contents from the headers into a document. See [toc (table of 
  contents)](#) for details.

* With `<<SubTOC>>` one can insert sub-tables of contents anywhere in the document. See [Sub topics](#) for details.

* Headers can be numbered. By setting `numberHeaders` (which defaults to 0) to 1 one can force **_MarkAPL_** to number all or some headers. See [numberHeaders](#) for details. 

  This was implemented because numbering with CSS does not really work yet.

* Calling APL functions: something like `⍎⍎FnsName⍎⍎` calls an APL method `FnsName` which gets the `ns`
  namespace as right argument. See "[Function calls](#)" for details.

* Typographical sugar. This can be switched off by setting `markdownStrict` to 1; for details see
  [markdownStrict](#).
   
    * Pairs of double-quotes (`"`) are exchanged against their typographically correct equivalents "like here".
    
      Note that this means that mentioning a single double-quote requires it to be put between back-ticks or escaped with a `\` character when there are also pairs of double-quotes in the same paragraph, cell, list item, blockquote or header, because otherwise **_MarkAPL_** has no idea what to do with it.

      A single double quote (") however is simply shown as is.
    * Three dots (`...`) are exchanged against an ellipses: ...
    * Three hyphens (`---`) are exchanged against ---.
    * Two hyphens (`--`) are exchanged against --.
    * `(c)` is exchanged against (c).
    * `(tm)` is exchanged against (tm).

* Assigning ID names, class names and attributes to certain elements as in:\
  `{#foo .my_class .another_class style="display:none;" target="_blank"}`\
  is implemented for most but not all elements. This idea was taken from Markdown Extra.
  
  See [Special attributes](#) for details.
 
  In this document the horizontal ruler that separates the footnotes from the remaining document is styled with special attributes.

* [Abbreviations](#). This was introduced by Markdown Extra.

* A `<br/>` tag can be inserted into paragraphs, lists and table cells with `<<br>>`.

* Comments: any line that starts with a `⍝` (the APL symbol used to indicate a comment) and is **not** situated within a code block will be ignored, no matter what else is found on that line.

  ~~~
  ⍝ This demonstrates a comment. Useful to leave stuff in a Markdown file 
  ⍝ but prevent it from making it into any resulting HTML document.
  ~~~

* Defining data: any line that starts with `[data]:` defines a key-value pair of data. See [Data](#) 
  for details. This has all sorts of applications; for example, this can be used to specify meta tags (name, content).

### Known bugs

See <http://aplwiki.com/MarkAPL/ProjectPage>

Reference
------------

### Mark-up

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

* You may have more than just one word between the `[` and the `]` bracket. However, any leading and trailing blanks will be removed.
* Any leading and trailing blanks regarding the comment will be removed.
* What is within the square brackets is case sensitive.
* You may use any Unicode characters belonging to the Unicode "letter" category plus `+-_= /&` (plus, minus, underscore, equal, space, slash and ampersand).


#### Blockquotes 

Markdown --- and therefore **_MarkAPL_** --- uses the `>` characters for block quoting. If you’re familiar with quoting passages of text in an email message then you know how to create a block quote in Markdown. It looks best if you hard wrap the text and put a `>` before every line:

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

Note that blockquotes are not restricted in any respect: they may contain paragraphs, tables, lists, headers and blockquotes. However, headers are not numbered and do not have anchors attached, and any `<<SubTOC>>` directives are removed from a blockquote.


#### Code blocks

According to the original Markdown specification any lines indented by 4 characters were considered a code block. Apart from not being particularly readable this caused problems with nested lists and code blocks within lists. Therefore later a convention called "fencing" was introduced. 

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

* The fencing lines may have up to three leading white space characters. These will just be ignored.

  Note that this rule does **not** apply when a code block is part of a list item since the number of spaces is then used to
  determine the level of nesting.
* Code blocks may also have [Special attributes](#); see there for details.

##### Code: the `<pre>` tag

You can also mark a block of text with the HTML `<pre>` tag. For example, this can be useful in order to show the fencing characters as part of the code.

If you must assign an ID or a class or any styling stuff to the `<pre>` tag of a code block you must do this:

~~~
<pre id="foo" class="my">
...
</pre>
~~~

There is no other way since assigning a [special attribute](#special-attributes) to a fenced block as shown here:

<pre>
~~~ {#foo}
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

* **_MarkAPL_** requires a `<code>` tag within any `<pre>` tag. Even if you do not specify the `<code>` tag **_MarkAPL_** will insert it for you anyway.
* Assigning an ID or a class to a `<pre>` tag might not have the intended effect because the default CSS styles the code block via the `<code>`, not the `<pre>` tag.
* **_MarkAPL_** will remove any line breaks between `<pre><code>` and the first line of your code block and also between `</code></pre>` and the last line of your code block. If you need an initial (empty) line or an empty line as the last one you must add it as shown here:

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
* As soon as something is not indented a footnote definition ends.
* The footnote identifiers must start with an upper case or lower case ASCII character and may contain any upper case and lower case characters, digits and the underscore (`_`) but nothing else.
* The footnotes are wrapped in a `<div id="footnotes_div">` tag to make them easily style-able with CSS. 

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

The names of the bookmarks are constructed automatically according to this set of rules:

* Remove all formatting, links, etc.
* Remove everything between <>, () and [], including the brackets.
* Remove all punctuation, except underscores, hyphens, and periods.
* Remove all code.
* Remove HTML entities (recursive calls to **_MarkAPL_**!)
* Replace all spaces and newlines with hyphens.
* Convert all alphabetic characters to lower case.
* Remove everything from the left until the first digit or ASCII letter or `∆` or `⍙` is found (identifiers may not begin with a hyphen).
* If nothing is left by then, use the identifier `section`.

Example:

The caption "`Second level-2 "Header!"`" becomes "`header-second-level-2-header`".

This is the result with `parms.bookmarkLink←1`:

~~~
<a id="header-second-level-2-header" class="autoheaderlink" 
<h1>Second level-2 "Header!"</h1> 
</a>
~~~ 

Note that the class `autoheaderlink` is automatically assigned to all bookmark links. This is needed because you probably want to make them invisible via CSS.

With `parms.bookmarkLink←0` however it is just this:

~~~
<h1>Second level-2 "Header!"</h1>
~~~

##### Headers and special attributes

Note that assigning [Special Attributes](#) has special rules:

* If an ID is defined then it is assigned to the anchor (`<a>`) rather than the <h\{number\}> tag.
* All other special attributes are assigned to the <h\{number\}> tag.
* If however automated bookmarks are suppressed (see [bookmarkLink](#)) then all special attributes go onto the <h\{number}\} tag - there is no anchor in those cases.

#### HTML blocks

Please note that there are three different HTML blocks:

* `<script>` and `<style>`
  
  They are special because they cannot be nested.

* `<pre>`
  
  This one preserves white space. The special features of `<pre>` blocks are discussed in detail at [Code: the <pre> tag](#).

* Everything else. 

Note that all HTML blocks but `<pre>`, `<script>` and `<style>` **must** be surrounded by blank lines.

It is perfectly legal to have HTML blocks in a Markdown document but be aware that this is way more complex a topic than it seemed to be at first glance. 

For details refer to <http://spec.commonmark.org/0.24/#html-blocks{target="_blank"}>.

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

1. The beginning of a block is defined by an empty line followed by a line that starts with either 
   `<` or `</` followed by a tag name. That means that leading white space is important because it prevents a line from being recognized as an HTML block.

1. The end of each HTML block (except `<pre>`, `<script>`, `<style>`) is defined by an empty line 
    which therefore is essential.

2. Because `**foo**` is an ordinary paragraph located **between** two HTML blocks it will be converted 
    into `<strong>foo</strong>`.

Without the two empty lines around the paragraph it would be just **one** HTML block. As a side effect the paragraph would show `**foo**` rather than **foo** because within an HTML block no in-line Markdown is recognized.

The `<pre>` blocks are different in so far as there is no Markdown styling done to anything between `<pre>` and `</pre>` anyway; therefore you can have just one block without any disadvantages. 

#### Horizontal rulers

You can create a horizontal ruler by following these rules:

1. After an empty line there must be a line with either a hyphen (`-`) or an asterisk (`*`) or an underscore (`_`).
1. There must be at least three such characters on the line.
1. There might be zero to a maximum of three white space character to the left of the characters defining the ruler.
1. There are no other characters but spaces allowed, with the exception of [Special Attributes](#).

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

A common mistake is to forget the empty line required **before** the definition of a ruler because that might actually define a [SeText header](#The “=” and “-” syntax (SeText)).  

#### Images

Images are implemented so that an image can be included into a paragraph, a list or a table cell. If you want an image outside such an element then you are advised to insert it as [HTML block](#html-blocks) with an `<img>` tag.

The syntax of Markdown-images is of limited use because you cannot specify either height or width. However, with [Special attributes](#) one can get around this limitation.

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

However if you specify "alt" but not "title" or "title" but not "alt" then the undefined bit will show the same contents as the defined one.

In order to add [special attributes](#) use this syntax:

~~~
![Alt Text](/url "My title"){#foo .myclass style="color:red;"}
~~~

There must not be any white-space between the closing `{` and the opening `{`.

Example:

~~~
![Dots](http://download.aplteam.com/APL_Team_Dots.png "APL Team' dots"){height="70" width="70"}
~~~

![Dots](http://download.aplteam.com/APL_Team_Dots.png "APL Team' dots"){height="70" width="70"}

#### In-line mark up

First of all, all in-line mark up does **not** touch code (in-line as well as blocks) and to some extend links: they can be marked as code.

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

Notes:
* Underscores within words are not considered mark-up directives.

##### Emphasize with `<strong>`

To mark some text as `<strong>` you can enclose that text either with `*` or with `_`.

Therefore the following two lines are equivalent:

~~~
This is an *ordinary* paragraph.
This is an _ordinary_ paragraph.
~~~

This is the result in any case:

This is an *ordinary* paragraph.

Notes:
* Underscores within words are not considered mark-up directives.

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

* Have a backslash character (`\`) at the end of a line. This is much clearer but has still the disadvantage that you cannot use it in table cells - there is no "end of line" in those.
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

Note also that the number of back-ticks in a paragraph (list, cell,...) must be even. If that's not the case then a closing back-tick is added to the end. That's why this seems to work:

~~~
This is back-tick: ` ``
~~~

This is back-tick: ` ``

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

The title (that's the stuff within the double-quotes) is optional, therefore the link can also be written as:

~~~
[The APL wiki](http://aplwiki.com)
~~~

If you want the URL to become the link text then this would suffice:

~~~
[](http://aplwiki.com)
~~~

That would result in [](http://aplwiki.com).

However, see the next topic (AutoLinks) as well. 

##### Autolinks

Because external links are often injected "as is" --- meaning that they actually have no link text and no link title --- you can also specify a link as:

~~~
<http://aplwiki.com>
~~~

That results is this link: <http://aplwiki.com>: the link text and the URL are identical.

##### Internal links (bookmarks)

Bookmark links are defined by a leading `#`. This character tells that the link points to a place somewhere in the same document.

The text of a bookmark link must be compiled of one or more of `⎕D,'∆⍙',⎕A,Lowercase ⎕A`: All digits, all letters of the ASCII characters set, lowercase or uppercase and the two APL characters `∆` and `⍙`.

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

To link to this header you can say:

~~~
[Link to chapter 5-2](#this-is-really-chapter-5-2)
~~~

and that would work indeed.

However, instead you could use just the chapter title and specify a `#` in order to let **_MarkAPL_** know that this is an internal link:

~~~
[This is (really) chapter 5-2](#)
~~~

That will result in a bookmark link as well.

##### Link references

Link references are defined by `[ID]: url`. Such definitions can appear anywhere in the document. There might be a space between the colon and the URL or not.

IDs must consist of one or more characters of:

* The US ASCII character set, lower case as well as upper case.
* Digits.
* The underscore (`_`) character.
* The hyphen (`-`) character. 

Other characters are not permitted.

In the document you can refer to a link reference with:

~~~
[The APL wiki][aplwiki]
~~~

The text between the the first pair of square brackets is the link text, the text between the second pair of square brackets is the ID of the link reference in question.

If the link text is not specified then the URL becomes the link text.
~~~
[][aplwiki]
~~~

Note: in case of a typo --- meaning that **_MarkAPL_** cannot find the link reference --- the text will appear "as is" in the final document but the missing reference will also be reported on [`ns.report`](#report).


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

* In the first expression the \` are removed before the contents between `[` and `]` is converted into a link but it is still marked up with <pre> and <code>.
* The second statement is of course treated like code. No links then.

##### Links and special attributes

[Special Attributes](#{#SpecialAttrsForLinks) can be assigned to all links:

* `<http://aplwiki.com{#foo1}>`    `⍝`   Note that there must be **no** white-space here!
* `[BookMark Link](# {#foo2})`
* `[APL wiki](http://aplwiki.com {#foo3})`
* `[](http://aplwiki.com {target="_blank"})`

#### Lists

<<SubTOC>>

Lists look simple, but when they are nested and/or contain sub-paragraphs and code blocks then things can get quite complicated. 

If your lists comprise just short single sentences then you will find lists easy and intuitive to use; otherwise you are advised to read the list of rules carefully. 

##### General rules

1. Lists start with a blank line, followed by a line were the first non-white-space character is either one of `-+*` 
   for a bulleted list or a digit followed either by a dot (`.`) or a parenthesis (`)`) for an ordered list. This 
   is called the list marker.
   
1. If a list follows a paragraph the blank line is not needed.

   Note that this makes life often easier because pretty much everybody assumes that one can start a list straight away after
   a paragraph. Watch out, this can backfire: if a line within a paragraph happens to start with a number then this **starts a list**!
   
   In real life however this a) happens rarely and b) people are way more likely to want to start a list when it doesn't. That's why **_MarkAPL_** is taking this approach.
 
1. A list definition --- including all sub lists --- breaks at two consecutive empty lines.
 
1. A list definition --- including all sub lists --- also breaks when after an empty line something is detected that 
    does not carry a list marker **and** is not indented at all.

1. A change of the list marker for bulleted lists (from `+` to `*` for example) starts a new list.

1. Lists can be nested.

1. The number of leading white-space characters between the left margin and the list marker (in case of a list item itself)
   or content (in case of a sub-paragraph or a code block) defines the level of nesting.
 
   That means that any content that is supposed to belong to a particular list item must be indented by the number of 
   characters of the list marker plus the number of white-space characters to the left and to the right of the list marker.   

1. Between a list marker and the content there might be any number of white space characters.

1. A list item can contain nothing but:
   * text (sometimes called initial list item content)
   * paragraphs 
   * code blocks
   * sub-lists
   
   Note that this is a **_MarkAPL_** restriction.

1. If a list item contains a code block or a paragraph then there **must** be an empty line before the code block / paragraph. 

1. A stand-alone code block may have zero or up to three leading spaces. This rule **does not apply** for code blocks that are part
   of a list item since spaces are used as the means to work out which list level the code block belongs to.
 
1. Single empty lines between list items and sub-paragraphs / code blocks belonging to a list item are ignored.
 
1. There is no concept of "loose" or "tight" lists. As a consequence the initial contents of a list item is never wrapped in a `<p>` tag.

   Note that this is a **_MarkAPL_** restriction.

1. Neither a code block nor a sub-paragraph can reduce the nesting level. This is only possible with a line carrying a list marker.

1. Closing LI tags (`</li>`) are optional according to the W3C HTML5 specification. However, **_MarkAPL_** adds **always** a closing `</li>` tag starting with version 2.0.
 
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

An ordered list must start with a digit followed by a dot (`.`) or a parentheses (`)`) and one or more white-space characters. The digit(s) in the first row define the starting point. For the remaining rows any digit will do. The number of digits is limited to nine because some browser cannot deal with 10. 

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
* Line breaks can be injected anywhere, even within links, but not in code (anything between two back-ticks).
* Indentation matters only in the first line of any list item and sub-paragraph as well as for the fencing lines of any code blocks.
* The end of the contents of a list item (not a list!) is defined by one of:
  * An empty line (including lines that comprise nothing but spaces)  
  * A line (with or without any leading white-space) that starts with a list marker.

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

When Special_Attributes are assigned to other items than the first one then they are simply removed from that list item.

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

##### Overview

A table must be separated from other stuff by empty lines.

Note that table rows are defined by having at least one un-escaped pipe symbol. You may however add a leading as well as a trailing pipe symbol if you wish so. Many consider this to be more readable. 

However, in order to construct a one-column table to must have either a leading or a trailing un-escape pipe symbol, or both.

Note that leading and trailing spaces are removed from every cell.

In one respect **_MarkAPL_** goes beyond the standard: according to the Markdown specification you **must** have a second row with a hyphen ("`-`") and the appropriate number of pipe symbols and zero, one or two colons (`:`) per column but **_MarkAPL_** doesn't require this: if there is no such row it assumes that the first row is not a row with column headers but an ordinary row.

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

Note that one cell contains a pipe symbol (`|`); normally that would confuse the parser but not in this case because 
it is escaped with a backslash character: `\|`.

You can have a table with just column headers:

~~~
|First name |Last Name|
|-|-A
~~~

This is the result:

|First name |Last Name|
|-|-A

### Misc

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

* You cannot inject Markdown: it won't be processed any more when the function is called.
The function name must always be fully qualified; that means the function cannot live in either a class instance or an unnamed namespace.
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

* If the function returns something that starts with a < and ends with a corresponding tag then it it is recognized as an HTML block. You can prevent that by adding leading white space.
* The `<pre><code>` must go onto the same line as the first line of the code; otherwise you end up with a starting empty line.
* If the embedded function returns something with a depth different from 0, 1 and 2 an error is thrown.

#### Special attributes

One can add special attributes --- that is an ID, class name(s) and other attributes --- to many elements

* Code blocks
* Definition lists
* Headers
* Horizontal rulers
* Images
* Links
* Lists
* Paragraphs
* Tables

Notes:

* If you assign an ID to a header the ID is not actually assigned to the header itself but the associated anchor (bookmark link). Since such an anchor embraces the header tag it can be styled via the anchor. 
* If an attempted definition of a special attribute fails due to an error like missing `=` or an odd number of `"` etc then it's not going to become a special attribute definition but ordinary data.

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
* list item {#myid style="font-family:'APL385 Unicode' .class1 .class2 target="_blank"}'
~~~

Note that you cannot put double-quotes around the name of the font family here because double-quotes are already used to determine the definition of the "style" attribute. Therefore you **must** use single quotes in this instance.  

##### Paragraphs and special attributes

Naturally a multi-line paragraph must define any special attributes at the very end of the paragraph rather than the end of the first line.

Note that there is a chance for content being mistaken as a special attribute, but this chance is very small indeed. If that happens just escape the curlies with a backslash character:

~~~

This is a paragraph with curlies at the end: \{\}.

~~~

#### Data

You can define key-value pairs of data with statements like these:

~~~
[Data]:author='Kai Jaeger'
[DATA]:copies=2
[data]:sequence=1 2 3
[data]:company=Dyalog Ltd
~~~

This establishes the key-value pairs as ordinary variables in the namespace `ns.data`. See [The "ns" namespace](#) for details.

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
* There may be any number of white-space characters between "[data]:" and the name.
* The name must consist of nothing but US ASCII or digits.
* If the value is not enclosed by quotes **_MarkAPL_** attempts to establish it as numeric value. If that fails however it attempts to establish it as text.
* If an entry is invalid the value is empty. For example, in `[data]:invalid='text 1 2 3` the closing quote is missing, therefore the expression is invalid. 
* Problems are reported on [`ns.report`](#report).
* **_MarkAPL_** itself does not make use of such variables. It is up to other applications to take advantage of these pieces of data. 

  See <http://aplwiki.com/PresentAPL> for an example: it uses this features to allow the author to set variables like "author", "company" and "title" which are then used to populate slides and meta tags.  

#### Sub topics

By inserting `<<SubTopic>>` (case insensitive) one can insert a table of contents for a sub topic. This can be useful in order to avoid overloading the main table of contents. This document has several such SubTOCs embedded, for example [The "ns" namespace in detail](#).

### Methods

#### CreateParms

Niladic function that returns a namespace populated with parameters carrying their default values. `CreateParms` tries to find for every parameter a value from the command line or environment variables. If it cannot find them it will establish a default value.

#### CreateHelpParms

This function first calls `CreateParms` and then sets several parameters so that thy meet the special demands of the file Markdown.html which is this very document you are reading. See [`Help`](#) for details.
      
####  Execute

This function is used exclusively by test cases.
          
####  Help

Makes your default browser display the file "Markdown.html".

The function takes a Boolean right argument: a 1 forces **_MarkAPL_** to recompile the file MarkAPL.md into MarkAPL.html. A 0 just views MarkAPL.html with your default browser.

You might specify an optional left argument: a parameter space, typically created by calling the `CreateParms` method. This allows creating a help file with non-default parameters. Of course this has only an effect when the right argument is a 1. 

In order to enable `Help` to find the file Markdown.html (in case the defaults don't work) you must create a parameter space (see [`CreateHelpParms`](#) for details) and then set [`homeFolder`](#) accordingly.
             
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

Without a (optional) left argument it creates just the HTML from the Markdown.

However, you can also create a parameter space by calling `CreateParms` and set `outputFilename`. In that case it will create a fully-fledged HTML page from the Markdown and write it to that file. The generated page is also returned as result.

Finally one can also set the `inputFilesName` parameter. This trumps the right argument: it reads the input file, expecting it to be Markdown, creates HTML5 from it and write it to the output file. Again the HTML is also returned as result.

Internally it calls `Init` & `Process` & `MakHTML_Doc`. 

#### Process          

This function takes --- and returns --- an `ns` namespace which was typically created by calling `Init`. 
 
#### Version

Returns the name, the version number and the version date of **_MarkAPL_**.

### Parameters

#### Overview

In order to specify parameters follow these steps:

~~~
      parms←#.MarkAPL.CreateParms''
      parms.∆List                                  
 body                                                  
 bookmarkLink                                        6 
 charset                                         utf-8 
 checkFootnotes                                      1 
 checkLinks                                          1 
 compileFunctions                                    1 
 cssURL                                             ¯1 
 debug                                               1 
 head                                                  
 homefolder                                         ¯1
 inputFilename                                         
 linkToCSS                                           0 
 markdownStrict                                      0 
 numberHeaders                                       0 
 outputFilename                                        
 printCSS                            MarkAPL_print.css 
 screenCSS                          MarkAPL_screen.css 
 subTocs                                             1 
 title                                         MarkAPL 
 toc                                                 0 
 tocCaption                          Table of contents 
 verbose                                             1 
~~~

The function `∆List` lists the contents of the parameter space with the corresponding values.

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

##### checkLinks 

Boolean. The default depends on `debug`. If this is 1 the `Process` method checks the internal (bookmark) links and records any problems on `ns.report`.

##### compileFunctions

Boolean that defaults to 1. There is just one reason to prevent any function from being compiled: performance measurements.

However, with version 1.8.3 MarkAPL does not compile its functions anymore because this caused trouble under some circumstances while the performance gains are little.

##### createFullHtmlPage

This parameter is `¯1` by default (undefined). That means that the default behaviour of [`Markdown2HTML`](#) is defined by the setting of [`outputFilename`](#): if it is not empty it will default to 1, otherwise to 0.

It can be set to either 0 or 1:

* A 0 means that the given Markdown is converted into an HTML snippet, no matter whether `outputFilename` is empty or not.
* A 1 means that the given Markdown is converted into a fully fledged HTML page, no matter whether `outputFilename` is empty or not.

##### cssURL

Holds the web address or folder that is expected to host the two CSS files needed for screen and print. Is ignored in case `linkToCSS` is 0.

Defaults to `homeFolder`.

##### head

If you want to add additional meta tags to the `<head>` part of a document (just an example) you can assign them to `head`. They will then be added to the `<head>` section. This can be a simple string (representing <title> for example) or a vector of simple text vectors (several meta tags for example).

##### homeFolder

This points to the folder where Markdown.html etc live. If the script was loaded with SALT then it tries to find the `Files\` folder within the folder the script was loaded from. If it was not loaded with SALT then it tries to find the `Files\` folder in the current directory. If that fails as well then you must set `homeFolders` to ensure that it can find, say, the file Markdown.html when you call `Markdown.Help 0` for example.

##### inputFilename

If the markdown you want to process lives in a file rather than the workspace then you can pass an empty vector as right argument to the `Process` method and specify `parms.inputFilename` instead. 

##### linkToCSS

Boolean that defaults to 0. This means that CSS for screen and print is injected into the resulting HTML page. If this is 1 a <link> tag for the CSS file(s) is added to the header. Naturally `cssURL` must be set accordingly then.

##### markdownStrict

Boolean that defaults to 0. Settings this to 1 prevents **_MarkAPL_** from executing certain operations:

* It does **not** attempt to create typographically correct output by exchanging:
  * `...` by ellipses.
  * `---` by em-dashes. You may or you may not have blanks around them. 
  * `--` by en-dashes. You may or you may not have blanks around them.
  * straight quotes against curly quotes.
* It does not replace `(c)` by the copyright symbol.
* It does not replace `(tm)` by the trade-mark symbol. 

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

##### screenCSS

The name of the CSS file for the screen. Defaults to `MarkAPL_screen.css`. If this is empty no CSS for viewing purposes is included or linked to.

##### subTocs

Boolean that defaults to 1. If you want to suppress sub TOCs no matter whether there are any included in the Markdown or not then set this to 0. 

When set to 0 then any strings `<<SubTopic>>` are removed from the Markdown before processing it.

This is mainly needed in order to suppress subTOCs in blockquotes.

##### title

Defaults to "MarkAPL". Defines the `<title>` tag in the `<head>` section of the resulting HTML page.

##### toc (table of contents)

An integer or integer vector that defaults to 0, meaning that no table of contents is injected into a document created by **_MarkAPL_**.

You can change this by setting the parameter `toc` to ...

* a single integer like 3. That is interpreted as "up to 3": a TOC is compiled from the headers of level 1, 2 and 3 and injected into the HTML document. 
* a vector of integers. For example, 2 3 4 5 would mean that just these levels are used for creating the TOC.

Note that `bookmarkLink`must have at least the same value as `toc`.

##### tocCaption

Defaults to "Table of contents". Set this to any character vector you want to appear as header of the TOC. `tocCaption` will be ignored in case `toc` is 0.

##### verbose

Boolean that defaults to `debug`. If this is 1 then the `Process` method will print the contents off `ns.report` to the session.  

### The "ns" namespace.

#### Overview 

The `ns` namespace is returned (created) by the `Init` method and modified by the `Process` method. It contains both input and output variables.

Before `Process` is run the variables emptyLines, leadingChars, markdown, markdownLC and withoutBlanks hold data the is extracted from the markdown. When `Process` is running block by block is processed and removed from these variables. At the same time the variable `parms.html` is collecting the resulting html. Other variables (abbreviations, data, footnoteDefs, headers, linkRefs, subToc and toc) may or may not collect data in the process as well.

The two variables `report` and `lineNumber` are special, see there.

#### The "ns" namespace in detail

<<SubTOC>>

The namespace contains the following variables:

##### abbreviations

A (possibly empty) vector of two-item-vectors. The first item holds the abbreviation, the second item the explanation or comment. 
         
##### emptyLines

A vector of Booleans indicating which lines in `markdown` are empty. Lines consisting of white-space characters only are considered to be empty.

##### footnoteDefs

A matrix that carries all footnote definition found in `markdown`. The matrix has two columns:

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

After having created the `ns` namespace by calling `CreateParms` this variable is empty. By running the `Process` method this variable will be filled up.

##### leadingChars

After having created the `ns` namespace by calling `CreateParms` this variable contains a limited number of characters from `markdown`. Leading white-space is removed. This increases performance for many of the checks to be carried out by `Process`.  

##### lineNumbers

After having created the `ns` namespace by calling `CreateParms` this variable contains a vector of integers representing line numbers in `markdown`. This allows the line number to be reported. Also, [Function calls](#) can access the line number as well.

Note that line numbers refer to the MarkDown, **not** the HTML.  
  
##### linkRefs

A vector of two-item vectors holding the link id --- which you will use within the document to link to the definition --- in the first item and the URL in the second.

##### markdown

This variable holds the markdown to be processed by `Process`.
     
##### markdownLC

Same as `markdown` but all in lower case. That speeds things up at the expense of memory.
   
##### noOf

The number of lines processed in the next (or current) step.
       
##### parms

The parameters that were passed to `Init`.
        
##### report

After having created the `ns` namespace by calling `CreateParms` this variable is empty. The `Process` method might add remarks to this variable in case it finds something to complain about or comment on.

Some methods print the content of this variable to the session in case [verbose](#) is 1.

##### subToc

This is a vector of two-item vectors:

1. The level of the header, starting with 1.
2. The caption of the header as displayed.

##### toc

This is a vector of ~~three~~ four-item vectors (since version 1.3.3):

1. The level of the header, starting with 1.
2. The caption of the header as displayed.
3. The internal link name.
4. The type of the header: 1 = SeText, 2 = ATX.
       
##### withoutBlanks

Same as `markdown` but without any blanks. This speeds things up at the expense of memory.

## How to

First of all, you can bring the document your are reading right now into view by executing `#.MarkAPL.Help 0`. 

One way to study how to make use of **_MarkAPL_** is to trace through the method `MarkAPL.Help`. This should clarify the principles.

Another way is to look at the test cases named `Test_Examples_01` etc in `#.TestCases` in the workspace MarkAPL.DWS. You can execute them with 

~~~
#.TestCases.RunThese 'Examples'
~~~

You can trace through them with

~~~
#.TestCases.RunThese 'Examples' (-⍳1000)
~~~

The numbers select the test cases of the given group (here "Examples") to be executed. 1000 was chosen to make sure all of them are executed.

Negative numbers tell the test framework to stop right before a particular test function is going to be executed. That gives you the opportunity to trace through that function without tracing through the actual test framework. 

## Problems

### Crashes

When **_MarkAPL_** crashes the most likely reason is an invalid definition. Check the variable `ns.markdown`: that tells you how far **_MarkAPL_** got in processing the Markdown. 

However, since **_MarkAPL_** should not crash and always produce a document it is appreciated when you report any crashes. See the next topic for how to report a crash.

### Bugs

Please report any bugs to <mailto:kai@aplteam.com>. I appreciate:

* The input (Markdown)
* Any non-default settings of parameters
* A short description of the problem (not as short as "It did not work"... ;)
* The version number of **_MarkAPL_**.

### Unexpected results

Before reporting a bug please check carefully your Markdown, in particular when the problem appears in or after complex table or list definitions. More often than not mistakes in the Markdown are causing the problem.

If you cannot work out why it goes wrong report it to me -- see the previous topic for how to report a problem.

---

This document refers to version 2.0.0 of **_MarkAPL_**.
Kai Jaeger ⋄ APL Team Ltd ⋄ 2016-08-31

Footnotes
* * * * * * * * * {style="width:30%;margin-left:0;"}
[^abandon]: Wikipedia definition of abandonware: <https://www.wikiwand.com/en/Abandonware>
[^commonmark]: The CommonMark specification: <http://spec.commonmark.org/0.24/> 

*[Abbreviations]: Text is marked up with the <abbr> tag

[git]: https://help.github.com/articles/working-with-advanced-formatting/
[markdown_extra]: https://www.wikiwand.com/en/Markdown_Extra
[pandoc]: http://pandoc.org/README.html