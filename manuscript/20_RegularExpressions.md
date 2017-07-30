# Regular expressions with Dyalog

One: -

Two: --

Three: ---


## Overview

In this chapter we try an unusual approach: we explain regular expressions purely by example. The examples start simple and grow complex. Along the line we introduce more features of regular expressions in general and Dyalog's implementation in particular. Your best strategy is to read the following stuff from start to end. It will introduce you to the basic concepts and provide your with the necessary knowledge to become a keen amateur. From there constant usage of regular expressions and the Internet will convert you into an expert, though it will take a bit of time and effort.

This chapter is by no means a comprehensive introduction to regular expressions, but it should get you to a point where you can take advantage of examples, documents and books that are not addressings Dyalog's implementation.

Note that we explain the syntax of `⎕R` and `⎕R` separately from the main text. That makes it easy to ignore those bits in case you are already familiar with the syntax of them.


## What are regular expression

Regular expression allow you to find the position of a search string in another string. They also allow you to replace a string by another one.


## Background

Dyalog is using the PCRE implementation of regular expressions. This library attempts to stay as close as possible to the Perl 5 implementation. There are many other implementations available, and they all differ more or less. Therefore it is important to know what kind of engine you are actually using when you do RegExes from within Dyalog. Dyalog 16.0 uses PCRE version 8. Note that PCRE is considered one the most complete and powerful implementations of regular expressions.


## Examples


### Example 1 - search a string in a string

~~~
      ⍴'notfound' ⎕s 0⊣ 'the cat sat on the medallion'
0
      'cat' ⎕s 0⊣ 'the cat sat on the medallion'
 4
~~~

A> ### The right operand and the right argument
A>
A> `⎕S` is, like `⎕R`, an _operator_. An operator takes a left operand (monadic) and left and right operand (dyadic) and form a so-called derived function. For example, the operator `/` when fed with a left operand `+` forms the derived function "sum".
A>
A> In the example the `0` is the right operand. With `⎕S` the right operand can be one to many of 0, 1, 2 and 3. They are called transformation codes. 
A>
A> * `0` stands for: offset from the start of the line to the start of the match.
A> * `1` stands for: length of the match.
A>
A>
A> Note that `2` and `3` will be discussed later.
A>
A> The right argument provided to the derived function is the string `the cat sat on the medallion`. The operand and the string are separated by the `⊣` function. Instead we could have used paranthesis with exactly the same result: `('notfound' ⎕s 0) 'the cat sat on the medallion'`.

In the first expression the result is empty because the string `notfound` was not found. In the second expression `cat` was actually found. That means that we could say:

~~~
      'cat' {⍵↓⍨⍺ ⎕s 0 ⊣ ⍵}'the cat sat on the medallion'
cat sat on the medallion
~~~

That was easy, wasn't it. Obviously regular expressions are nothing to be afraid off. Let's look at another example: find out what's between double quotes:

~~~
      '"' ⎕S 0 ⊣ 'He said "Yes"'
 8 12
~~~

That gives us the offset of the two double quotes, but what if we want to have the offset and the length of any string found _between_ double quotes? For that we need to introduce the _meta character_ `.` which has a special meaning in a regular expression: it represents _any_ character (not strictly true but we will discuss the exception, the NewLine character, soon). So we try:

~~~
      '"."' ⎕S 0 1 ⊣ 'He said "Yes"'

~~~

Opps - no hit. 

In order to understand this we have to know what exactly the regular expression engine did:

1. Start at the beginning of the string; that is actually one to the left off the initial "t"! That position can only match to the meta character `^` which represents the start of a line. 
1. If there is no match the engine forgets about it and moves one character forward. This is called "consuming" the position the engine has looked at. 
1. It then tries to match `"` to `H`. Since there is no match either ...
1. It carries on until it arrives at the `"`. Now there is a match!
1. The engine now tries to match the `.` against the `Y`. Since the`.` matches _any_ character this is a match, too. 
1. It then moves forward one more character and tries to match the `"` with `e` - that's _not_ a match.
1. The engine forgets what it has done, goes back to where it started (that was the `"`) and moves one character forward. 
1. It now tries to  matche the `"` with the `Y` ... 

You can now see why it does not report any hit - it would work on `'He said "Y"'` or more generally, on any single character that is embraced by two double quotes.

What we need is a way to tell the engine that it should try to match the `.` more than once. There is a general way of doing this and two shortcuts that cover most cases. For example, in order to match zero to a maximum of three white space characters:

~~~
      '\s{1,3}' ⎕R '⌹' ⊢' one two   three    four'
⌹one⌹two⌹three⌹⌹four  
~~~

The backslash character (`\`) gives the `s` a special meaning: `\s` stands for a single white space character: a space or a tab (`\t`) or a new line (`\n`) or a carriage return (`\r`). 

The curlies (`{}`) define how many of those are required as minimum and maximum. This is called a quantifier.

* `{x,y}` means a min of x and a max of y.
* `{,y}` is the same as `{0,y}`.
* `{x,}` means a min of x with no max limit.
* `{x}` means exactly x.

These quantifiers are greedy, so repeating y times is tried before reducing the repetition to x times. You can make them lazy by adding a trailing `?`.

* The star (`*`) is a shortcut for `{0,y}` and `{,y}`.
* The plus (`+`) is a shortcut for `{1,}`.

Therefore:

~~~
      '".*"' ⎕S 0 1 ⊣ 'He said "Yes"!'
 8 5
~~~

Seems to work perfectly, right. Well, keep reading:

~~~
      '".*"' ⎕S 0 1 ⊣ 'He said "Yes" and "No"!'
 8 14 
~~~

It is easier to check the result by replacing the hits with something very obvious:

~~~
      '".*"' ⎕R '⌹' ⊣ 'He said "Yes" and "No"!'
He said ⌹!
~~~

Just one hit, and that has a length of 14?! That's because by default the engine is greedy: it carries on and tries to match the `.` against as many characters as it can. That means it will stop only after it reached the end of the line, because all characters found are a match. It would then go back until it finds a `"` and then stop because it found a match.

What we need instead is a lazy search, therefore:

~~~
      '".*"' ⎕S 0 1⍠('Greedy' 0) ⊣ 'He said "Yes" and "No"'
 8 5  18 4 
~~~

We actually think that it would be better having this as the default. That way it would become apparent straight away what works and what doesn't. With "greedy" being the default it would appear to work if there is either no hit at all or only a single hit but it would not work with more than one hit. However, all implementations come with "greedy" being the default.

Let's repeat our findings because this is so important:

* Greedy means match longest possible string.
* Lazy means match shortest possible string.

Let's modify the input string: 

~~~
      is←'He said "Yes"" and "No"'  ⍝ define "input string" 
~~~

There are _two_ double quotes after the word "Yes"; that seems to be a typo. Watch what our RegEx is making of this:

~~~
      '".*"' ⎕R '⌹' ⍠('Greedy' 0) ⊣ is
 He said ⌹⌹No"
~~~

This example highlights a potential problem with input strings: many regular expressions would work prefectly well as long as the input string is, well, let's say syntactically correct. That's (among other reasons) why regular expressions are not recommended for processing HTML because HTML is very often full of syntactical errors. However, if you can be certain that the HTML you have to deal with _is_ syntactically correct _and_ the piece of HTML you have to process is short then there is nothing wrong with using regular expression processing it.

A> ### Regular expressions and HTML
A>
A> There are claims that you _cannot_ parse HTML with regular expression because a regular expression engine is a Finite Automata while HTML can be nested indefinitely. This is partly wrong and partly misleading
A> 
A> * It is wrong because today's regular expressions come with features (back referencing) that are clearly beyond the feature set of a Finite Automata.
A> * It is misleading because it ignores what is meant by "HTML". Regular expressions are clearly incapable of processing a complex HTML page, but they are perfectly capable of processing a small piece of HTML that is known to be syntactically correct.

How many special characters, also called meta characters, do we have to deal with? Well, quite a lot:

| Meta character | Symbol |
|-|-|
| Backslash | `\` |
| Caret | `^` |
| Dollar sign | `$` |
| Period or dot | `.` |
| Vertical bar or pipe symbol | `|` |
| Question mark | `?` |
| Asterisk or star | `*` |
| Plus sign | `+` |
| Opening parenthesis | ` (` |
| Closing parenthesis | `)` |
| Opening square bracket | `[` |
| Opening curly brace | `{` |

In order to really master regular expressions you have to know all of them. That will not only enable you to use them properly, it will also prevent you from advertising yourself as a non-skilled RegEx user: those tend to escape pretty much everything that is not a letter or a digit because they don't know what they are doing.


### Example 2 - numbers in a string

Let's assume we want to match all numbers in a string:

~~~
      '[0123456789]'⎕R '⌹' ⊣ 'It 23.45 plus 99.12.'
It ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

Everything between the `[` and the `]` is treated as a simple character - with a few exceptions we'll soon discuss.

The same but shorter:

~~~
      '[0-9]'⎕R '⌹' ⊣ 'It 23.45 plus 99.12.'
It ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

Note that the `-` is treated as a special character here: in our example it means "0 to 9".

Even shorter:

~~~
      '\d'⎕R '⌹' ⊣ 'It 23.45 plus 99.12.'
It ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

Note that the backslash character (`\` ) is used for two different purposes:

* To escape any of the RegEx meta characters so that they are stripped of their special meaning and taken literally.
* To give the next character a special meaning.

So `\*` takes away the special meaning from the `*` and takes it literally while `\d` gives the `d` the special meaning "all digits".

We take the opportunity to add the `.` and the `-` to the character class. Note that the `-` is not escaped; from the context the regular expression egine can work out that here the `-` cannot have the from-to meaning, so it take it literally.

~~~
      '[\d.-]'⎕R '⌹' ⊣ 'It 23.45 plus -99.12.'
It ⌹⌹⌹⌹⌹ plus ⌹⌹⌹⌹⌹⌹⌹
~~~

Here we have another problem: we want the `.` only to be a match when there is a digit to both the left and the right of the `.`. We will tackle this problem soon with look-ahead and look-behind.

Character classes work for characters as well:

~~~
      '[a-zA-Z]'⎕R '⌹' ⊣'It 23.45 plus 99.12.'
⌹⌹ 23.45 ⌹⌹⌹⌹ 99.12.
~~~

Finally we can negate it with `^`:

~~~
    '[^a-zA-Z]'⎕R '⌹' ⊣'It 23.45 plus 99.12.'
It⌹⌹⌹⌹⌹⌹⌹plus⌹⌹⌹⌹⌹⌹⌹
~~~

Negate with digits and dots:

~~~
      '[^.0-9]'⎕R '⌹' ⊣'It 23.45 plus 99.12.'
⌹⌹⌹23.45⌹⌹⌹⌹⌹⌹99.12.
~~~

Want to search for "gray" and "grey" in a document?

~~~
      'gr[a|e]y'⎕S 0⊣'Americans spell it "gray" and Brits "grey".'
20 37
      'gr[a|e]y'⎕R '⌹' ⊣'Americans spell it "gray" and Brits "grey".'
Americans spell it "⌹" and Brits "⌹".      
~~~

So the pipe symbol (`|`) has a special meaning inside a character class: it means "or".

Note that there are only a few meta characters inside `[]`:

| Meta character    | Symbol | Meaning                    |
|-------------------|--------|----------------------------|
| Closing bracket   | `]`    |                            |
| Backslash         | `\`    | Escape next character      |
| Caret             | `^`    | Negate the character class |
| Hyphen            | `-`    | From-to                    |

We already worked out that the engine is smart enough to take a `-` literally when it makes an appearance somewhere where it cannot be a from-to indicator: the beginning and the end of a character class.


### Finding zero to three white space characters followed by an ASCII letter at the beginning of a line.

~~~
      {'^\s{0,3}[a-zA-Z]' ⎕R '⌹' ⊣ ⍵}¨'Zero' ' One' '  Two' '   Three' '    four'
⌹ero  ⌹ne  ⌹wo  ⌹hree      four 
~~~


### Analyzing APL code

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

Dyalog's implementation of regular expression offers a very elegant solution to the problem:

~~~
      '''.*''' '⍝.*$' 'foo'⎕R(,¨'&&⌹')⍠('Greedy' 0)⊣is
a←1 ⋄ ⌹←1 2 ⋄ txt←'The ⍝ marks a comment; foo' ⍝ set up vars a, foo, txt
~~~

This needs some explanation:

1. `'''.*'''` catches all text, and for that text `&` is specified as replacement. Now `&` stands for the matching text, therefore nothing will change at all but the mathing text _won't participate in any further actions_! In other words: everything between quotes is left alone.

1. `'⍝.*$'` catches everything from a lamp (`⍝`) to the end of the line (`$`) and replaces it by itself (`&`). Again nothing changes but the comments will not be affacted by anything that follows.

1. Finally `foo` catches the string "foo" in the remaining part, and that is what we are interested in. 

As a result `foo` is only found with the code but neither within the text nor the comment.

As far as we know this feature is specific to Dyalog, but then we have limited experience with other regular expression engines.

Note that the `,¨` in `,¨'&&⌹'` is essential because otherwise  ....`⍝TODO⍝`  Bug report <01406>

However, this is still not perfect since it would work on `boofoogoo` as well:

~~~
      '''.*''' '⍝.*$' 'foo'⎕R(,¨'&&⌹')⍠('Greedy' 0)⊣'This boofoogoo is found as well'
This boo⌹goo is found as well
~~~

To solve this we need to introduce look-ahead and look-behind. The names make it pretty previous what this is about but we want to emphasize that all matching attempts we've introduced so far have been "consuming". Look-ahead as well as look-behind are _not_ consuming. That means that whether they are successful or not they won't change the position the engine is currently investigating. They are also called zero-length assertions.

However, before we tackle our probelem 

A look-behind is expressed by `(?<!f)/b`

## Some theory

In Dyalog you use `⎕S` for search operations and `⎕R` for replace operations. The two are _system operators_. There are no other system operators in Dyalog available in 16.0. 

By definition an operator takes one or two operands and returns a function which is called _derived_. `⎕S` and `⎕R` are dualo operators, so they take two operands. 

* The left operand is always a search pattern.
* The right operand is the transformation (if any) to be applied.