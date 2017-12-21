{:: encoding="utf-8" /}
[parm]:title     = 'RegEx'
[parm]:linkToCSS = 1
⍝[parm]:printCSS  = 'C:\Program Files (x86)\APL Team Ltd\Meddy\CSS\BlackOnWhite_print.css'
⍝[parm]:screenCSS = 'C:\Program Files (x86)\APL Team Ltd\Meddy\CSS\BlackOnWhite_print.css'
⍝[parm]:cssURL    = ''



# Regular expressions with Dyalog


## To whom it concerns

You should be able to read and understand this chapter without any previous knowledge of regular expressions.

Even if you are fluent in regular expressions but not with Dyalog's implemention you are advised to read this chapter. Dyalog's implementation has some unique and extremely powerful features not offered by any other implementation we have seen.

If you are heavily involved in number crunching without any memory of ever having scanned strings for certain patterns then there is no point in looking into regular expressions because you just don't need them. 

Let's be clear, regular expressions are an extremely powerful tool, but the level of abstraction is high. You will find it hard to master them without using them regularly. 

So, if you need to find a pattern in a string twice a year you are probably better off finding an expert on the matter you can ask for advice.

Having said this it is amazing how many APLers do not realize how often they actually _do_ search for strings and patterns.


## Overview

In this chapter we take the approach to explain regular expressions purely by example. The examples start simple and grow complex. Along the line we introduce more features of regular expressions in general and Dyalog's implementation in particular. 

Your best strategy is to read the following stuff from start to end. It will introduce you to the basic concepts and provide you with the necessary knowledge to become a keen amateur. 

From there constant usage of regular expressions --- together with plenty of reasearch on the Internet -- will convert you into an expert, though it will take a bit of time and effort. Be assured that this time will be well invested.

This chapter is by no means a comprehensive introduction to regular expressions, but it should get you to a point where you can take advantage of examples, documents and books that are not addressing Dyalog's implementation.


## What exactly are regular expressions?

Regular expressions allow you to find the position of a search string in another string. They also allow you to replace a string by another one.


## Background

Dyalog is using the PCRE implementation of regular expressions. This library attempts to stay as close as possible to the Perl 5 implementation. There are many other implementations available, and they all differ in one way or another. Therefore it is important to know what kind of engine you are actually using when you do RegExes from within Dyalog. 

Dyalog 16.0 uses PCRE version 8. Note that PCRE is considered one the most complete and powerful implementations of regular expressions.


## Examples


### Search a string in a string

~~~
      ⍴'notfound' ⎕s 0⊣ 'the cat sat on the medallion'
0
      'cat' ⎕s 0⊣ 'the cat sat on the medallion'
 4
~~~

A> # Operators, operands, derived functions and arguments
A>
A> `⎕S` is, like `⎕R`, an _operator_. An operator takes either just a left operand (monadic) or a left and right operand (dyadic) and forms a so-called derived function. For example, the operator `/` when fed with a left operand `+` forms the derived function "sum".
A>
A> In the example the `0` is the right operand. With `⎕S` the right operand can be one to many of 0, 1, 2 and 3 (those are called transformation codes) or a user defined function which is explained later.
A>
A> * `0` stands for: offset from the start of the line to the start of the match.
A> * `1` stands for: length of the match.
A>
A>
A> The transformation codes `2` and `3` will be discussed later.
A>
A> The right argument provided to the derived function is the string `'the cat sat on the medallion'`. The operand and the string are separated by the `⊣` function. Instead we could have used parenthesis with exactly the same result: `('notfound' ⎕s 0) 'the cat sat on the medallion'`.

In the first expression the result is empty because the string `notfound` was not found. In the second expression `cat` was actually found. That means that we could say:

~~~
      'cat' {⍵↓⍨⍺ ⎕s 0 ⊣ ⍵}'the cat sat on the medallion'
cat sat on the medallion
~~~

That was easy, wasn't it! Obviously regular expressions are nothing to be afraid off. 

### What's between the double quotes

Let's look at another example: find out what's between double quotes. First attempt:

~~~
      '"' ⎕S 0 ⊣ 'He said "Yes"'
 8 12
~~~

That gives us the offset of the two double quotes, but what if we want to have the offset and the length of any string found _between_ --- and including --- the double quotes? 

For that we need to introduce the _meta character_ dot (`.`) which has a special meaning in a regular expression: it represents _any_ character (not strictly true but we will soon discuss the one and only exception, the NewLine character). 

A> # Meta Characters
A>
A> Meta characters, sometimes called special characters, are those characters that have a special meaning in a regular expression.
A> 
A> **In order to really master regular expressions you have to know _all_ of them**. 
A>
A> That will not only enable you to use them properly, it will also prevent you from advertising yourself as a non-skilled RegEx user: those tend to escape pretty much everything that is not a letter or a digit because they don't know what they are doing. 
A> 
A> Even if you don't care, unnecessary escaping also reduces readability significantly; that is already a good reason for not escaping more than necessary.
A>
A> Note that if you want a meta character to be taken literally (like searching for a dot) then you have to escape the meta character by a backslash (`\`) which therefore is itself a meta character. 
A>
A> Therefore the expression `'"\.\\"'` would search for double-quote followed by a single dot followed by a single backslash followed by a double-quote.

So we try:

~~~
      '"."' ⎕S 0 1 ⊣ 'He said "Yes"'

~~~

Opps - no hit. If your are surprised keep reading, otherwise skip over the list.

In order to understand this we have to know _exactly_ what the regular expression engine did:

1. It starts at the beginning of the string; that is actually one to the left of the "H"! That position can only be matched by the meta character `^` which represents the _start of a line_. 
1. If there is no match the engine forgets about it and moves one character forward. This is called "consuming" the position the engine has looked at. 
1. It then tries to match `"` to `H`. Since there is no match either...
1. It carries on until it arrives at the `"`. Now there is a match!
1. The engine now tries to match the `.` against the `Y`. Since the`.` matches _any_ character this is a match, too. 
1. It then moves forward one more character and tries to match the `"` with `e` - that's _not_ a match.
1. The engine forgets what it has done, goes back to where it started from (that was the `"`) and moves one character forward. 
1. It now tries to  match the `"` with the `Y` ... 

You can now see why it does not report any hit - it would only work on any single character that is embraced by two double quotes, for example on `'He said "Y"'`.

### Repeating a search pattern

What we need is a way to tell the engine that it should try to match the `.` more than once. There is a general way of doing this and three shortcuts that cover most cases. First we discuss the general way.

For example, in order to match a minimum of one to a maximum of three underscore characters:

~~~
      '_{1,3}' ⎕S 0 ⊢'_one__two___three____four'
0 4 9 17 20
~~~

It is actually easier to check the result by replacing the hits with something that stands out:

~~~
      '_{1,3}' ⎕R '⌹' ⊢'_one__two___three____four'
⌹one⌹two⌹three⌹⌹four  
      '_{2,3}' ⎕R '⌹' ⊢'_one__two___three____four'
_one⌹two⌹three⌹_four
~~~

A> ### The right operand of ⎕R
A>
A> `⎕R` takes one or more replace strings _or_ a user defined function (discussed later) as the right operand; you cannot mix replace strings with user defined functions.

What's between the curlies (`{}`) -- which are meta characters as well -- defines how many are required as minimum and maximum. This is called a quantifier.

* `{x,y}` means a min of x and a max of y.
* `{,y}` is the same as `{0,y}`.
* `{x,}` means a min of x with no max limit.
* `{x}` means exactly x.

Then there are the shortcuts that make life a bit easier:

* The star (`*`) is a shortcut for `{0,y}` and `{,y}`.
* The plus (`+`) is a shortcut for `{1,}`.
* The question mark (`?`) is a shortcut for `{0,1}`.

### Greedy and lazy

Therefore:

~~~
      '".*"' ⎕R '⌹' ⊣ 'He said "Yes"!'
He said ⌹!
~~~

~~~
      '".*"' ⎕R '⌹' ⊣ 'He said "Yes" and "No"!'
He said ⌹!
~~~

Just one hit, and that hit spans `"Yes" and "No"`?! 

That's because by default the engine is _greedy_ as opposed to _lazy_: it carries on and tries to match the `.` against as many characters as it can. 

That means that in our example it will stop only after it reached the _end of the line_, because all characters found are a match. It would then go back until it finds a `"` (coming from the right!) and then stop because it's done the job.

The same is true for the `{x,y}` quantifiers: by default they are all _greedy_ rather than _lazy_, so repeating `y` times is tried before reducing the repetition to `x` times.

What we need instead is a _lazy_ search. We can change the default by specifying the "Greedy" option:

~~~
      '".*"' ⎕R '⌹' ⍠('Greedy' 0) ⊣ 'He said "Yes" and "No"!'
He said ⌹ and ⌹!
~~~

A> # The Options operator
A>
A> Between the right operand and the right argument you may specify options. They are marked by the `⍠` operator. These are the options available:
A>
A> IC, Mode, DotAll, EOL, ML, Greedy, OM, InEnc, OutEnc, Enc, ResultText, UCP
A>  
A> Note that "IC" is the principle option. That means that if no other option needs to be specified you can omit the "IC".
A> 
A> Therefore this would do: `⎕S 0 ⍠ 1 ⊢ 'whatever'`. "IC" stands for "Ignore Case". A 1 would make a search pattern case insensitive. The default is 0.
A> 
A> In this chapter we won't discuss all options but "IC", "Mode", "DotAll", "Greedy" and "UCP"; these are the most important ones. For the others refer to `⎕R`'s help page.

Let's repeat our findings because this is so important:

* Greedy means match _longest_ possible string.
* Lazy means match _shortest_ possible string.


### The "+" can be dangerous!

But wouldn't it be better to use `+` rather than `*` here? After all we are not interested in `""` because their is nothing between the two double quotes? Good point except that it does not work:

~~~
      '".+"' ⎕R '⌹' ⍠('Greedy' 0) ⊣ 'He said "" and ""'
He said ⌹"
~~~

That's because the engine would perform the following steps:

1. Investigate until we find a `"`.
1. Investigate any character after the first double quote. That is the second double quote so _that is consumed_ because it required _at least one_. Since all other characters are a match as well the `.+` consumes all characters to the end of the input string. 
1. It then goes back the the current position --- because it is lazy! --- which is bacause the second `"` was already consumed the space after (!) the second `"` and before the `a` of "and". From there it carries on until it finds a `"`. That is the first `"` after the "and". All that is then relpaced by the `⌹` character.
1. The engine then carries on but because there is only a single `"` left there is no other match.

If we want to ignore any `""` pairs then we need to use a look-ahead, something we weill discuss soon.


### Negate 

Note that there is another --- and better --- way to solve our problem:

~~~
      '"[^"]*"'⎕R'⌹'⊣'He said "" and ""'
~~~

* The engine carries on until it finds a `"`.
* It then carries on until it finds a character that is not a `"` because the expression `[^"]` means "not a double-quote". The start after it repeats that expression until we either find a `"` or reach the end of the line or document.
* Then is performs the last step, matching the `"`.

Note that this expression has two advantages:

1. It is faster then our first attempt although in our example the difference it miniscule.
1. It's _independent_ from the settings of "Greedy", so it does not matter.


### Garbage in, garbage out

Let's modify the input string: 

~~~
      is←'He said "Yes"" and "No"'  ⍝ define "input string" 
~~~

There are _two_ double quotes after the word "Yes"; that seems to be a typo. Watch what our RegEx is making of this:

~~~
      '".*"' ⎕R '⌹' ⍠('Greedy' 0) ⊣ is
 He said ⌹⌹No"
~~~

This example highlights a potential problem with input strings: many regular expressions work perfectly well as long as the input string is, well, let's say match your expectations, but it could also be defined as "syntacially correct".

That's the reason (among others) why regular expressions are not recommended for processing HTML because HTML is very often full of syntactical errors. 

However, if you can be certain that the HTML you have to deal with _is_ syntactically correct _and_ the piece of HTML is short and not nested then there is nothing wrong with using regular expressions to process HTML.

A> # Regular expressions and HTML
A>
A> There are claims that you _cannot_ parse HTML with regular expressions because a regular expression engine is a Finite Automata while HTML can be nested indefinitely. This is partly wrong and partly misleading.
A> 
A> * It is wrong because today's regular expression engines come with features (back referencing) that are clearly beyond the feature set of a Finite Automata.
A> * It is misleading because it ignores that regular expression engines are perfectly capable of processing small pieces of HTML that are known to be syntactically correct.

### Meta chracters: the full list

By now we've met quite a number of meta characters; how many do we have to deal with? Well, quite a lot:

|   | Meta character               | Symbol | |Meaning
|---|------------------------------|--------|-|-----------------------------
|1. | Backslash                    | `\`    |✔| Escape character
|2. | Caret                        | `^`    |✔| Start of line
|3. | Dollar sign                  | `$`    | | End of line
|4. | Period or dot                | `.`    |✔| Any character but NewLine
|5. | Pipe symbol                  | `|`    | | Logical "OR"
|6. | Question mark                | `?`    | | Extends meaning of `(`; 0 or 1 quantifier (=optional); make it lazy
|7. | Asterisk or star             | `*`    |✔| Repeat 0 to many times
|8. | Plus sign                    | `+`    |✔| Repeat 1 to many times
|9. | Opening parenthesis          | `(`    | | Start sub pattern
|10.| Closing parenthesis          | `)`    | | End sub pattern
|11.| Opening square bracket       | `[`    | | Start character class (or set)
|12.| Opening curly brace          | `{`    |✔| Start min/max quantifier

By now we have already discussed six of them; they carry a check mark.

Note that both `}` and `]` are considered meta characters only after an opening `{` or `[`. Without the opening counterpart they are taken literally; that's why they did not make it onto the list of meta characters.


### Search digits in a string

Let's assume we want to match all digits in a string:

~~~
      '[0123456789]'⎕R '⌹' ⊣ 'It''s 23.45 plus 99.12.'
It's ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

Everything between the `[` and the `]` is treated as a simple character - with a few exceptions we'll soon discuss. That makes both `[` and `]` meta characters.

The same but shorter:

~~~
      '[0-9]'⎕R '⌹' ⊣ 'It''s 23.45 plus 99.12.'
It's ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

The minus is treated as a meta character here: it means "all digits from 0 to 9".

### The escape character: \

Even shorter:

~~~
      '\d'⎕R '⌹' ⊣ 'It''s 23.45 plus 99.12.'
It's ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

Note that the meta character backslash (`\` ) is used for two different purposes:

* To escape any of the RegEx meta characters so that they are stripped of their special meaning and taken literally.
* To give the next character a special meaning in case it is an ordinary ASCII letter.

So `\*` takes away the special meaning from the `*` while `\d` gives the `d` the special meaning "all digits".

We take the opportunity to add the dot (`.`) and the minus (`-`) to the character class. 

Note that the minus is not escaped; from the context the regular expression engine can work out that here the minus cannot mean from-to, so it is taken literally.

Note also that the `.` is not escaped either: inside the pair of `[]` the `.` is _not_ a meta character.

~~~
      '[\d.-]'⎕R '⌹' ⊣ 'It''s 23.45 plus -99.12.'
It's ⌹⌹⌹⌹⌹ plus ⌹⌹⌹⌹⌹⌹⌹
~~~

Here we have another problem: we want the dot only to be a match when there is a digit to both the left and the right of the dot. Our search pattern is not dealing with this, therefore the trailing `.` is a match. We will tackle this problem soon.

Character classes work for letters as well:

~~~
      '[a-zA-Z]'⎕R '⌹' ⊣'It''s 23.45 plus 99.12.'
⌹⌹'⌹ 23.45 ⌹⌹⌹⌹ 99.12.
~~~

We can negate with `^` right after the opening `[`:

~~~
    '[^a-zA-Z]'⎕R '⌹' ⊣'It''s 23.45 plus 99.12.'
It⌹s⌹⌹⌹⌹⌹⌹⌹plus⌹⌹⌹⌹⌹⌹⌹
~~~

Notes:

* Only at the beginning of a character class definition has the caret the meaning "negate". Therefore you could also say that `[^` means "negate" while, say, `[1^2]` means "Match for one of these three characters: `1^2`".

* For APLers the caret is a bit tricky because it can easily be confused with the logical AND (`∧`) primitive. Only next to each other it becomes apparent what it what: `^∧`: the caret is a bit higher than the logical AND.

### Negate with digits and dots:

~~~
      '[^.0-9]'⎕R '⌹' ⊣'It''s 23.45 plus 99.12.'
⌹⌹⌹⌹⌹23.45⌹⌹⌹⌹⌹⌹99.12.
~~~

Want to search for "gray" and "grey" in a document?

~~~
      'gr[a|e]y'⎕S 0⊣'Americans spell it "gray" and Brits "grey".'
20 37
      'gr[a|e]y'⎕R '⌹' ⊣'Americans spell it "gray" and Brits "grey".'
Americans spell it "⌹" and Brits "⌹".      
~~~

So the pipe symbol (`|`) has a special meaning inside a character class: it means logical "OR".


### Meta characters within a character class

Note that there are only a few meta characters inside character classes:

| Meta character    | Symbol | Meaning                    |
|-------------------|--------|----------------------------|
| Closing bracket   | `]`    |                            |
| Backslash         | `\`    | Escape next character      |
| Caret             | `^`    | Negate the character class |
| Minus             | `-`    | From-to                    |

We already worked out that the engine is smart enough to take a minus literally when it makes an appearance somewhere where it cannot mean from-to: the beginning and the end of a character class. 

Similarly the caret (`^`) character can only negate a character class as a whole, when it follows the opening square bracket (`[^`). If the caret is specified elsewhere it is taken literally. 

Therefore the expression `[0-9^1]` does _not_ mean "all digits but 1", it means "all digits plus the caret character plus a 1".


### Searching for white space characters

Finding 0 to 3 white space characters followed by an ASCII letter at the beginning of a line:

~~~
      {'^\s{0,3}[a-zA-Z]' ⎕R '⌹' ⊣ ⍵}¨'Zero' ' One' '  Two' '   Three' '    four'
⌹ero  ⌹ne  ⌹wo  ⌹hree      four 
~~~

`\s` escapes the ASCII letter "s", meaning that the "s" takes on a special meaning: `\s` stands for "any whitespace" character. That is at the very least the space character (`⎕UCS 32`) and the tab character (`⎕UCS 9`).

There are two options (the stuff that can be set with the `⍠` operator) that influence which other characters qualify as white space:

* "Mode"
* "UCP"

Both will be discussed soon.


### The options "DotAll" and "Mode"

We've learned that the `.` matched any character but not and of line.

~~~
      '".*"'⎕R'⌹'⊣ '"Foo' 'Goo"'
 "Foo  Goo" 
~~~

I> Specifying a vector of text vectors is internally processed like a file with two records in it.

Because the `.` does not match end-of-line it finds `"Foo` but then stops rather than carrying on trying to match the pattern with `Goo"`, so no hit is found.

The "DotAll" option --- which defaults to 0 --- we can tell the RegEx engine to let `.` even match the end of a line:

~~~
      '".*"'⎕R'⌹'⍠('DotAll' 1)('Mode' 'D')⊣'"Foo' 'Goo "'
 ⌹
~~~

Note that we had to specify the "Mode" option as well because `DotAll←` is invalid with `Mode←L` and that's the default. It is important to understand the different modes and their influence on `^` (start of document or line), `$` (end of document or line) and `DotAll`; please refer to the Help for this.

It's not difficult to imagine a situation where you have a single search pattern but in one part you want the `.` to match end-of-line and in others you won't.


### The meta character `\N`

`\N` has almost the same meaning as the `.` except that it never matches the end of a line. It's therefor independent from the setting of "DotAll":

~~~
      '"\N*"'⎕R'⌹'⍠('DotAll' 1)('Mode' 'D')⊣'"Foo' 'Goo "'
 "Foo  Goo " 
~~~

Note that `\N` and `\n` are different: `\n` stands for a newline character.


### Analyzing APL code: Replace

Let's assume that you want to investigate APL code for a variable name `foo` but you want text and comments to be ignored. This is our input string:

~~~
      is←'a←1 ⋄ foo←1 2 ⋄ txt←''The ⍝ marks a comment; foo'' ⍝ set up vars a, foo, txt'
~~~

We want `foo←1 2` to be found/changed while the text and the comment shall be ignored/remain unchanged. The problem is aggravated by the fact that the text contains a `⍝` symbol.

The naive approach does not work:

~~~
      'foo' ⎕R '⌹' ⊣ is
a←1 ⋄ ⌹←1 2 ⋄ txt←'The ⍝ marks a comment; ⌹' ⍝ set up vars a, ⌹, txt
~~~

Dyalog's implementation of regular expressions offers an elegant solution to the problem:

~~~
      '''\N*''' '⍝\N*$' 'foo'⎕R(,¨'&&⌹')⍠('Greedy' 0)⊣is
a←1 ⋄ ⌹←1 2 ⋄ txt←'The ⍝ marks a comment; foo' ⍝ set up vars a, foo, txt
~~~

This needs some explanation:

1. `\N` is the same as a `.`: it matches all characters but the end-of-line character. 

   Setting `('DotAll' 1)` might make sense for the third search pattern (`foo`) but it would under certain circumstances prevent the first two search patterns from working, therefore we _must_ use the `\N` syntax for those patterns.

1. `'''\N*'''` catches all text --- that is everything between quotes --- and for that text `&` is specified as replacement. 

   Now `&` stands for the matching text, therefore nothing will change at all but the matching text _won't participate in any further actions!_ In other words: everything between quotes is left alone.

1. `'⍝\N*$'` catches everything from a lamp (`⍝`) to the end of the line (`$`) and replaces it by itself (`&`). Again nothing changes but the comment will not be affected by anything that follows. 

   Since the first expression has already masked everything within (and including) quotes the first `⍝` does not cause problems; it will be ignored at this stage.

1. Finally `foo` catches the string "foo" in the remaining part, and that is what we are interested in.

As a result `foo` is found within the code but neither within the text nor as part of the comment.

As far as we know this powerful feature is specific to Dyalog, but then we have limited experience with other regular expression engines.

### Regular expressions and scalar extension

Note that the `,¨` in `,¨'&&⌹'` is essential: without it the RegEx engine would use the pattern `'&&⌹'` thrice. The reason is that `⎕R` actually does not accept scalars, it only accepts vectors. So if you specify three search patterns on the left, then you need to specify not four and not two but three replace patterns as well. In case only a single vector is specified then this vector is taken thrice. Kind of weird flavour of scalar extension.


### Analyzing APL code: Search

The extremely powerful syntax discussed above is also available whith `⎕S`:

~~~
      '''\N*''' '⍝\N*$' 'foo'⎕S 0 1 2⍠('Greedy' 0)⊣is
 6 3 2  20 28 0  49 25 1 
~~~

We have already discussed the transformation codes 0 (offset) and 1 (length) but not 3: this returns the pattern number which matched the input document, origin zero.

In our case it is the third pattern (`foo`) we are interested in, therefore we can ignore those that are 0 an 1.

A> # Greedy and lazy
A>
A> Note that using the option `⍠('Greedy' 0)` has a disadvantage: it makes _all_ search patterns lazy.
A>
A> There will be cases when you want only a part of your search pattern to be lazy and other parts greedy, or some search patterns lazy and others greedy.
A>
A> Luckily this can be achieved with the meta character question mark (`?`):
A> 
A>  ~~~
A>       '"\N*?"'⎕R '⌹' ⊣ is
A> He said ⌹ and ⌹
A> ~~~
A>
A> Since "Greedy" is the engine's default you need to specify the `?` only for those parts of your search pattern you want to be lazy.


### Word boundaries

Our search pattern is still not perfect since it would work on `boofoogoo` as well:

~~~
      '''\N*''' '⍝\N*$' 'foo'⎕R(,¨'&&⌹')⍠('Greedy' 0)⊣'This boofoogoo is found as well'
This boo⌹goo is found as well
~~~

We can solve this problem with `\b` (word boundaries). `\b` does not attempt to match a particular character on a particular position. Instead it checks whether there is a word boundary either before are after the current position. 

That means that no matter whether they are successful or not they won't change the position the engine is currently investigating. They are also called anchors.

To put it simply, `\b` allows you to perform a "whole word only" search as in `\bword\b`.

Prior to version 8 of PCRE (and 16.0 of Dyalog) this was true only for ASCII characters. Therefore it worked only for the English language.

~~~
       ⍴'\bger\b'⎕S 0 ⊣'Kai Jägerßabc'
1
~~~

That's because both ä and ß are non-ANSI characters.

Now you can set the "UCP" option to 1 if you want Unicode characters to be taken into account as well:

~~~
      ⍴'\bger\b'⎕S 0 ⍠('UCP' 1)⊣'Kai Jägerßabc'
0
~~~

Now both "ä" and "ß" don't qualify as word boundaries any more.


### Look-ahead and look-behind (look-around)

We can use look-ahead and look-behind to solve a problem we did run into earlier with numbers. This did not really work because _all_ dots got replaced when we wanted only those with digits to the right and the left being a match:

~~~
      '[\d.¯-]'⎕R'⌹'⊣'It''s 23.45 plus 99.12.'
It's ⌹⌹⌹⌹⌹ plus ⌹⌹⌹⌹⌹⌹
~~~

We don't want the last dot to be a match. Obviously we need to check the characters to the left and to the right of each dot.

Both look-ahead and look behind start with `(?`. A look behind then needs a `<` while the look-ahead doesn't. 

Both then need either a `=` for "equal" or a `!` for "not equal" followed by the search token and finally a closing `)`. Hence `(?<=\d)` for the look-behind and `(?=\d)` for the look-ahead:

~~~
      '\d' '(?<=\d).(?=\d)'⎕R'⌹'⊣'It''s 23.45 plus 99.12.'
It's ⌹⌹⌹⌹⌹ plus ⌹⌹⌹⌹⌹.      
~~~

That works! We use two expression here: first we look for all digits and then we look for dots that have a digits to their right and their left. 


I> What is important to realize is that the current position does not change when a look-behind or a look-ahead is performed; that's why they are called zero-length assertions.


However, in case you need `⎕S` to return the start and the length of any matches then the result is unlikely to be what you are after:

~~~
      '\d' '(?<=\d).(?=\d)'⎕S 0 1 ⊣'It''s 23.45 plus 99.12.'
 5 1  6 1  7 1  8 1  9 1  16 1  17 1  18 1  19 1  20 1
~~~

We need an expression that identifies any vector of digits as one unit, no matter whether there is a dot between the digits or not:

~~~
      '\d+(?<=\d).(?=\d)\d+' ⎕R '⌹' ⊣ 'It''s 23.45 plus 99.12.'
It's ⌹ plus ⌹.
      '\d+(?<=\d).(?=\d)\d+' ⎕S 0 1 ⊣ 'It''s 23.45 plus 99.12.'
 5 5  16 5 
~~~

That's better.

As mentioned earlier a look-ahead as well as a look-behind can be negated by using a `!` rather than a `=`

Lets' try this. Assuming we look for "x" and "y":

~~~
      'x(?<=y)' ⎕R'⌹' ⊣ 'abxycxd' ⍝ Exchange all "x" when followed by a "y"
ab⌹ycxd
      'x(?!y)' ⎕R'⌹' ⊣ 'abxycxd' ⍝ Exchange all "x" when NOT followed by a "y"
abxyc⌹d      
      '(?<=x)y' ⎕R'⌹' ⊣ 'abxycyd' ⍝ Exchange all "y" when preceeded by an "x"
abx⌹cyd
      '(?<!x)y' ⎕R'⌹' ⊣ 'abxycyd' ⍝ Exchange all "y" when NOT preceeded by an "x"
abxyc⌹d       
~~~


## Transformation function

Instead of providing a replace string one can also pass a function as operand to `⎕R` (and `⎕S` as well). The powerful feature is again Dyalog-only.

Our earlier example:

~~~
      is←'a←1 ⋄ foo←1 ⋄ txt←''text; foo'' ⍝ comment'
~~~

Let's replace just the variable name with something else with a transformation function:

~~~
      ∇test[⎕]∇
[0]   r←{x}test y
[1]   .

      '''.*''' '⍝.*$' 'foo'⎕R  test⊣is
SYNTAX ERROR
test[1] .
       ∧
      y.(⊃{⍵ (⍎⍵)}¨↓⎕nl 2 9)
 Block        a←1 ⋄ foo←1 ⋄ txt←'text; foo' ⍝ comment 
 BlockNum                                           0 
 Lengths                                            3 
 Match                                            foo 
 Names                                                
 Offsets                                            6 
 Pattern                                          foo 
 PatternNum                                         2 
 ReplaceMode                                        0 
 TextOnly                                           0       
~~~

The right argument contains all the pieces of information that you will possibly need.

We modify `test` so that is leaves the text and the comment untouched:

~~~
      )reset
      ∇test[⎕]∇
[0]   r←{x}test y
[1]   :If ''''''≡2⍴¯1⌽y.Match
[2]       ⎕←r←y.Match
[3]   :ElseIf '⍝'=1⍴y.Match
[4]       ⎕←r←y.Match
[5]   :Else
[6]       r←'⌹Hello world⌹'
[7]   :EndIf

      '''.*''' '⍝.*$' 'foo'⎕R test⊣is
'text; foo'
⍝ comment
a←1 ⋄ ⌹Hello world⌹←1 ⋄ txt←'text; foo' ⍝ comment
~~~

Since any match that starts and ends with a quote is text by definition the function returns those untouched. Anything that starts with a lamp symbol is a comment, so they are returned untouched as well. That leaves the hits for the real variable names: they are exchanged against `⌹Hello world⌹`.

Naturally transformation functions gives you enormous power: you can do whatever you like.

Note that transformation functions can be specified with `⎕S` as well.


## Document mode

So far we have specified just a simple string as input. We can however pass a vector of strings as well. Look at this example:

~~~
      input←'He said: "Yes, that might' 'well be right." She answered: "So be it!"'
~~~

It's not a bad idea to think of the two elements of the input vector as "blocks". Note that the first text spans over both blocks. 

By default the search engine operates in "Line" mode. That means that each block is processed independently by the engine. Therefore you cannot search for `\r` (carriage return) in line mode: the search engine will never see them. 

In mixed mode as well as document mode you _can_ search for `\r` because all blocks are passed at once. Naturally this also requires more memory than line mode.

Let's do some tests:

~~~
      '".*"'⎕R'⌹'⍠('Greedy' 0)⊣input
 He said: "Yes, that might  well be right.⌹So be it!" 
      '".*"'⎕R'⌹'⍠('Greedy' 0)('Mode' 'M')('DotAll' 1)⊣input
He said: ⌹ She answered: ⌹       
~~~

Note that in order to specify `('DotAll' 1)` it is necessary to set `('Mode' 'M')`. `('Mode' 'D')` would have worked in the same way. However, when it comes to `^` and `$` then it makes a big difference:

* In line mode (`('Mode' 'L')`) `^` finds the start of the line and `$` finds the end of the line.
* In mixed mode (`('Mode' 'M')`) `^` finds the start of each block and `$` finds the end of each block.
* In document mode (`('Mode' 'D')`) `^` finds the start of the document and `$` finds the end of the document.


### Grouping

Let's assum that we have a piece of HTML code, and that we are interested in any text betwen anchor tags (`<a>`). Let's also assume that we know that there is no other tag inside the `<a>`, just simple text.

Now an anchor text has always either an `href="..."` or an `id="..."` because otherwise it has no purpose.

Therefore it should be save to say:

~~~
      '<a.*>.*<'⎕R'⌹'⊣'This <a href="http://aplwiki.com">is a link</a>, really!'
This ⌹, really!
~~~

Works, right? 

Well, yes, but it also work on this:

~~~

~~~

## Misc


### Tests

Given that complex regular expressions are hard to read and maintain you should document intensively. The best way to document them is to write exhaustive test cases.


### Performance

Don't expect regular expressions to be faster than a taylored APL solution; instead expect them to be slightly slower.

However, many regular expressions like finding a simple string in another simple string or uppercasing or lowercasing characters are converted by the interpreter into a native (=faster) APL expression (`⍷` and (`⌶ 819`).


### Helpful stuff

RegexBuddy
: This is a software that helps interpreting (or building) regular expressions.

<http://www.regular-expressions.info/tutorial.html>
: This is a web site that really goes into the details. It's from the author of RegExBuddy.

: The web site also comes with detailed book reviews: <http://www.regular-expressions.info/hipowls.html>