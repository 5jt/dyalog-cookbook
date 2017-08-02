# Regular expressions with Dyalog


## Overview

In this chapter we take an unusual approach: we explain regular expressions purely by example. The examples start simple and grow complex. Along the line we introduce more features of regular expressions in general and Dyalog's implementation in particular. Your best strategy is to read the following stuff from start to end. It will introduce you to the basic concepts and provide you with the necessary knowledge to become a keen amateur. From there constant usage of regular expressions and the Internet will convert you into an expert, though it will take a bit of time and effort. Be assured that it will be well invested time.

This chapter is by no means a comprehensive introduction to regular expressions, but it should get you to a point where you can take advantage of examples, documents and books that are not addressing Dyalog's implementation.

Note that we explain the syntax of `⎕R` and `⎕R` separately from the main text. That makes it easy to ignore those bits in case you are already familiar with the syntax of them.


## What are regular expressions?

Regular expressions allow you to find the position of a search string in another string. They also allow you to replace a string by another one.


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
A> `⎕S` is, like `⎕R`, an _operator_. An operator takes either just a left operand (monadic) or a left and right operand (dyadic) and forms a so-called derived function. For example, the operator `/` when fed with a left operand `+` forms the derived function "sum".
A>
A> In the example the `0` is the right operand. With `⎕S` the right operand can be one to many of 0, 1, 2 and 3 (those are called transformation codes) or a user defined function which is explained later.
A>
A> * `0` stands for: offset from the start of the line to the start of the match.
A> * `1` stands for: length of the match.
A>
A>
A> Note that the transformation codes `2` and `3` will be discussed later.
A>
A> The right argument provided to the derived function is the string `'the cat sat on the medallion'`. The operand and the string are separated by the `⊣` function. Instead we could have used parenthesis with exactly the same result: `('notfound' ⎕s 0) 'the cat sat on the medallion'`.

In the first expression the result is empty because the string `notfound` was not found. In the second expression `cat` was actually found. That means that we could say:

~~~
      'cat' {⍵↓⍨⍺ ⎕s 0 ⊣ ⍵}'the cat sat on the medallion'
cat sat on the medallion
~~~

That was easy, wasn't it! Obviously regular expressions are nothing to be afraid off. Let's look at another example: find out what's between double quotes. First attempt:

~~~
      '"' ⎕S 0 ⊣ 'He said "Yes"'
 8 12
~~~

That gives us the offset of the two double quotes, but what if we want to have the offset and the length of any string found _between_ --- and including --- the double quotes? For that we need to introduce the _meta character_ dot (`.`) which has a special meaning in a regular expression: it represents _any_ character (not strictly true but we will discuss the exception, the NewLine character, soon). 

A> ### Meta Characters
A>
A> Meta characters, sometimes called special characters, are those characters that have a special meaning in a regular expression. In order to really master regular expressions you have to know _all of them_. That will not only enable you to use them properly, it will also prevent you from advertising yourself as a non-skilled RegEx user: those tend to escape pretty much everything that is not a letter or a digit because they don't know what they are doing. Even if you don't care, unnecessary escaping also reduces readability significantly; you really should only escape the characters that _need_ to be escaped.
A>
A> Note that if you want a meta character to be taken literally (like searching for a dot) then you have to escape the meta character by a backslash (`\`) which therefore is itself a meta character. The expression `'"\.\\"'` would search for double-quote followed by a single dot followed by a single backslash followed by a double-quote.

So we try:

~~~
      '"."' ⎕S 0 1 ⊣ 'He said "Yes"'

~~~

Opps - no hit. 

In order to understand this we have to know _exactly_ what the regular expression engine did:

1. It starts at the beginning of the string; that is actually one to the left of the initial "t"! That position can only match to the meta character `^` which represents the start of a line. 
1. If there is no match the engine forgets about it and moves one character forward. This is called "consuming" the position the engine has looked at. 
1. It then tries to match `"` to `H`. Since there is no match either...
1. It carries on until it arrives at the `"`. Now there is a match!
1. The engine now tries to match the `.` against the `Y`. Since the`.` matches _any_ character this is a match, too. 
1. It then moves forward one more character and tries to match the `"` with `e` - that's _not_ a match.
1. The engine forgets what it has done, goes back to where it started from (that was the `"`) and moves one character forward. 
1. It now tries to  match the `"` with the `Y` ... 

You can now see why it does not report any hit - it would work on `'He said "Y"'` or more generally, on any single character that is embraced by two double quotes.

What we need is a way to tell the engine that it should try to match the `.` more than once. There is a general way of doing this and two shortcuts that cover most cases. For example, in order to match a minimum of one to a maximum of three white space characters:

~~~
      '\s{1,3}' ⎕S 0 ⊢' one two   three    four'
0 4 8 16 19
~~~

It is actually easier to check the result by replacing the hits with something outstanding:

~~~
      '\s{1,3}' ⎕R '⌹' ⊢' one two   three    four'
⌹one⌹two⌹three⌹⌹four  
~~~

A> ### The right operand 
A>
A> `⎕R` takes one or more replace strings or a user defined function (discussed later) as the right operand.

The backslash character (`\`) gives the `s` a special meaning: `\s` stands for a single white space character: a space or a tab (`\t`) or a new line (`\n`) or a carriage return (`\r`). 

What's between the curlies (`{}`) -- which are meta characters as well -- defines how many are required as minimum and maximum. This is called a quantifier.

* `{x,y}` means a min of x and a max of y.
* `{,y}` is the same as `{0,y}`.
* `{x,}` means a min of x with no max limit.
* `{x}` means exactly x.

* The star (`*`) is a shortcut for `{0,y}` and `{,y}`.
* The plus (`+`) is a shortcut for `{1,}`.

Therefore:

~~~
      '".*"' ⎕R '⌹' ⊣ 'He said "Yes"!'
He said ⌹!
~~~

Seems to work perfectly, right? Well, keep reading:

~~~
      '".*"' ⎕R '⌹' ⊣ 'He said "Yes" and "No"!'
He said ⌹!
~~~

Just one hit, and that hit spans `"Yes" and "No"`?! That's because by default the engine is greedy: it carries on and tries to match the `.` against as many characters as it can. That means it will stop only after it reached the end of the line, because all characters found are a match. It would then go back (from right to left) until it finds a `"` (coming from the right!) and then stop because it's done the job.

The same is true for the `{x,y}` quantifiers: by default they are all greedy rather than lazy, so repeating `y` times is tried before reducing the repetition to `x` times.

What we need instead is a lazy search, therefore:. We can change the default by specifying the "Greedy" option:

~~~
      '".*"' ⎕R '⌹' ⍠('Greedy' 0) ⊣ 'He said "Yes" and "No"!'
He said ⌹ and ⌹!
~~~

A> ### Options
A>
A> Between the right operand and the right argument you may specify options. They are marked by the `⍠` operator. These are the options available:
A>
A> IC, Mode, DotAll, EOL, ML, Greedy, OM, InEnc, OutEnc, Enc, ResultText, UCP
A>  
A> Note that "IC" is the principle option. That means that if no other option needs to be specified you can omit the "IC"; this would do: `⎕S 0 ⍠ 1 ⊢ 'whatever'`. "IC" stands for "Ignore Case". A 1 would make a search pattern case insensitive. The default is 0.
A> 
A> In this chapter we won't discuss all these options but "IC", "Mode", "DotAll", "Greedy" and "UCP". For the others refer to the help page of `⎕R`.

We actually think that it would be better having `('Greedy' 0)` as the default. That way it would become apparent straight away what works and what doesn't. With "greedy" being the default it would appear to work if there is either no hit at all or only a single hit but it would not work with more than one hit. However, all implementations come with "greedy" being the default.

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

This example highlights a potential problem with input strings: many regular expressions work perfectly well as long as the input string is, well, let's say syntactically correct. That's (among other reasons) why regular expressions are not recommended for processing HTML because HTML is very often full of syntactical errors. However, if you can be certain that the HTML you have to deal with _is_ syntactically correct _and_ the piece of HTML is short then there is nothing wrong with using regular expressions to process it.

A> ### Regular expressions and HTML
A>
A> There are claims that you _cannot_ parse HTML with regular expressions because a regular expression engine is a Finite Automata while HTML can be nested indefinitely. This is partly wrong and partly misleading.
A> 
A> * It is wrong because today's regular expression engines come with features (back referencing) that are clearly beyond the feature set of a Finite Automata.
A> * It is misleading because it ignores that regular expression engines are perfectly capable of processing small pieces of HTML that are known to be syntactically correct.

By now we've met quite a number of meta characters; how many do we have to deal with? Well, quite a lot:

| Meta character                   | Symbol | |
|---|------------------------------|--------|-|-----------------------------|
|1. | Backslash                    | `\`    |✔| Escape character
|2. | Caret                        | `^`    |✔| Start of line
|3. | Dollar sign                  | `$`    | | End of line
|4. | Period or dot                | `.`    |✔| Any character but NewLine
|5. | Vertical bar or pipe symbol  | `|`    | | Logical "OR"
|6. | Question mark                | `?`    | | Extends meaning of `(`; 0 or 1 quantifier; makes quantifiers lazy
|7. | Asterisk or star             | `*`    |✔| Repeat 0 to many times
|8. | Plus sign                    | `+`    |✔| Repeat 1 to many times
|9. | Opening parenthesis          | `(`    | | Start sub pattern
|10.| Closing parenthesis          | `)`    | | End sub pattern
|11.| Opening square bracket       | `[`    |✔| Start character set
|12.| Opening curly brace          | `{`    |✔| Start min/max quantifier

By now we have already discussed six of them.

Note that both `}` and `]` are considered meta characters only after an opening `{` or `[`. Without the opening counterpart they are taken literally; that's why they did not make it into the list of meta characters.


### Example 2 - numbers in a string

Let's assume we want to match all numbers in a string:

~~~
      '[0123456789]'⎕R '⌹' ⊣ 'It 23.45 plus 99.12.'
It ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

Everything between the `[` and the `]` is treated as a simple character - with a few exceptions we'll soon discuss. That makes both `[` and `]` meta characters.

The same but shorter:

~~~
      '[0-9]'⎕R '⌹' ⊣ 'It 23.45 plus 99.12.'
It ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

Note that the `-` is treated as a meta character here: in our example it means "0 to 9".

Even shorter:

~~~
      '\d'⎕R '⌹' ⊣ 'It 23.45 plus 99.12.'
It ⌹⌹.⌹⌹ plus ⌹⌹.⌹⌹.
~~~

Note that the meta character backslash (`\` ) is used for two different purposes:

* To escape any of the RegEx meta characters so that they are stripped of their special meaning and taken literally.
* To give the next character a special meaning in case it is an ordinary ASCII letter.

So `\*` takes away the special meaning from the `*` while `\d` gives the `d` the special meaning "all digits".

We take the opportunity to add the dot (`.`) and the hyphen (`-`) to the character class. Note that the hyphen is not escaped; from the context the regular expression engine can work out that here the hyphen cannot mean from-to, so it is taken literally.

~~~
      '[\d.-]'⎕R '⌹' ⊣ 'It 23.45 plus -99.12.'
It ⌹⌹⌹⌹⌹ plus ⌹⌹⌹⌹⌹⌹⌹
~~~

Here we have another problem: we want the dot only to be a match when there is a digit to both the left and the right of the dot. Our search pattern is not dealing with this, therefore the trailing `.` is a match. We will tackle this problem soon with look-ahead and look-behind.

Character classes work for letters as well:

~~~
      '[a-zA-Z]'⎕R '⌹' ⊣'It 23.45 plus 99.12.'
⌹⌹ 23.45 ⌹⌹⌹⌹ 99.12.
~~~

Finally we can negate it with `^`:

~~~
    '[^a-zA-Z]'⎕R '⌹' ⊣'It 23.45 plus 99.12.'
It⌹⌹⌹⌹⌹⌹⌹plus⌹⌹⌹⌹⌹⌹⌹
~~~

I> Many problem can be solved in more than one way with regular expressions. For example, our earlier problem to find everything between (and including) double quotes can be solved with this expression as well: `'"[^"]*"' ⎕R '⌹' ⊣ 'He said "Yes", she said "No".'`. It matches a double quote, then as many characters as possible that are _not_ a double quote and finally the closing double quote. This expression has the advantage of working just fine with `(Greedy' 1)` as well as with `(Greedy' 0)`.

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

So the pipe symbol (`|`) has a special meaning inside a character class: it means logical "OR".

Note that there are only a few meta characters inside `[]`:

| Meta character    | Symbol | Meaning                    |
|-------------------|--------|----------------------------|
| Closing bracket   | `]`    |                            |
| Backslash         | `\`    | Escape next character      |
| Caret             | `^`    | Negate the character class |
| Hyphen            | `-`    | From-to                    |

We already worked out that the engine is smart enough to take a hyphen literally when it makes an appearance somewhere where it cannot mean from-to: the beginning and the end of a character class. Similarly the caret (`^`) character can only negate a character class as a whole, when it follows the opening square bracket (`[^`). If the caret is specified elsewhere it is taken literally. Therefore the expression `[0-9^1]` does _not_ mean "all digits but 1, it means "all digits plus the caret character plus a 1".


### Finding 0 to 3 white space characters followed by an ASCII letter at the beginning of a line

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

1. `'''.*'''` catches all text, and for that text `&` is specified as replacement. Now `&` stands for the matching text, therefore nothing will change at all but the matching text _won't participate in any further actions_! In other words: everything between quotes is left alone.

1. `'⍝.*$'` catches everything from a lamp (`⍝`) to the end of the line (`$`) and replaces it by itself (`&`). Again nothing changes but the comments will not be affected by anything that follows.

1. Finally `foo` catches the string "foo" in the remaining part, and that is what we are interested in. 

As a result `foo` is found within the code but neither within the text nor as part of the comment.

As far as we know this feature is specific to Dyalog, but then we have limited experience with other regular expression engines.

Note that the `,¨` in `,¨'&&⌹'` is essential because otherwise  ....`⍝TODO⍝`  Bug report <01406>

A> ### Greedy and lazy
A>
A> Note that using the option (`⍠('Greedy' 0)`) has a disadvantage: it makes the _whole expression_ lazy. There might be cases when you want part of your search pattern to be lazy and other parts greedy. Luckily this can be achieved with the meta character question mark (`?`):
A> 
A> ~~~
A>       '".*?"'⎕R '⌹' ⊣is
A> He said ⌹ and ⌹
A> ~~~
A>
A> Since "Greedy" is the engine's default you need to specify the `?` only for those parts of your search pattern you want to be lazy.

Our search pattern is still not perfect since it would work on `boofoogoo` as well:

~~~
      '''.*''' '⍝.*$' 'foo'⎕R(,¨'&&⌹')⍠('Greedy' 0)⊣'This boofoogoo is found as well'
This boo⌹goo is found as well
~~~

To solve this we need to introduce look-ahead and look-behind. The names make it pretty previous what this is about but we want to emphasize that all matching attempts we've introduced so far have been "consuming". Look-ahead as well as look-behind are _not_ consuming. That means that no matter whether they are successful or not they won't change the position the engine is currently investigating. They are also called zero-length assertions.

However, before we tackle our problem we need to introduce the concept of both word boundaries and anchors. We've already met one anchor, the caret (`^`) which matches the beginning of a line. There is also the dollar (`$`) which matches the end of a line. And there is `\b` which matches a "word boundary". All these characters are zero-length matches.

To put it simply, `\b` allows you to perform a "whole word only" search. Prior to version 8 of PCRE (and 16.0 of Dyalog) this was true only for ASCII characters. Now you can set the "UCP" option to 1 if you want Unicode characters to be taken into account as well:

~~~
       ⍴'\bger\b'⎕S 0 ⊣'Kai Jägerßabc'
1
      ⍴'\bger\b'⎕S 0 ⍠('UCP' 1)⊣'Kai Jägerßabc'
0
~~~

A look-behind is expressed by `(?<!f)/b`

## Performance

...

## Wands and potions

* RegexBuddy
* http://www.regular-expressions.info/tutorial.html
* Teach yourself regular expressions
* Regular expression cookbook