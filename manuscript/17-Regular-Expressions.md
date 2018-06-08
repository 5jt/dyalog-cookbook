{:: encoding="utf-8" /}
[parm]:title     = 'RegEx'
[parm]:linkToCSS = 1


# Regular expressions with Dyalog


## Start here

You should be able to read and understand this chapter without any previous knowledge of regular expressions.

If you are fluent in regular expressions but unfamiliar with Dyalog's implementation, read this chapter. Dyalog's implementation has some unique and extremely powerful features not offered by any other we have seen.

If you are heavily involved in number crunching and never search strings for certain patterns you probably don’t need regular expressions.

Regular expressions are an extremely powerful tool, but the level of abstraction is high. They are hard to master without regular use. 
If you need to find a pattern in a string twice a year, you are probably better off finding a friend you can ask for advice.

Having said this, it is amazing how few APLers realize how often they actually _do_ search for patterns in strings.


## What you can expect

In this chapter we explain regular expressions mostly by example. The examples start off simple and grow complex. Along the way we introduce more features of regular expressions in general and Dyalog's implementation in particular. 

Mastering even the very basic features of regular expressions might improve your APL applications.

Your best strategy is to read the following from start to end, not necessarily in one sitting. It will introduce you to the basic concepts and provide you with the necessary knowledge to become a keen amateur. 

From there frequent usage of regular expressions --- and some research on the Web -- will render you an expert. This time and effort is well invested.

This chapter is by no means a comprehensive introduction to regular expressions. It should get you to a point where you can take advantage of examples, documents and books that are not specific to Dyalog's implementation.


## What exactly are regular expressions?

Regular expressions allow you to find the position of a string in another string. They also allow you to replace a string by another one.


## Background

Dyalog uses the PCRE implementation of regular expressions. There are other other implementations available, and they differ in their use and performance characteristics. So you need to know what kind of engine you are using to find the right advice, examples and solutions on the Web.

Dyalog 16.0 uses PCRE version 8. PCRE is considered one the most complete and powerful implementations of regular expressions.


## RegEx in a nutshell


### Search a string in a string

~~~
      ⍴'notfound' ⎕s 0⊣ 'the cat sat on the medallion'
0
      'cat' ⎕s 0⊣ 'the cat sat on the medallion'
 4
~~~

A> # Operators, operands, derived functions and arguments
A>
A> `⎕S` is, like `⎕R`, an _operator_. An operator takes either just a left operand (monadic) or a left and right operand (dyadic) and forms a so-called derived function. For example, the operator `/` when given a left operand `+` forms the derived function _sum_.
A>
A> In the example, the `0` is the right operand. With `⎕S` the right operand can be one or more of 0, 1, 2 and 3 (the _transformation codes_) or a user-defined function, discussed later.
A>
A> * `0` stands for: offset from the start of the line to the start of the match.
A> * `1` stands for: length of the match.
A>
A>
A> The transformation codes `2` and `3` will be discussed later.
A>
A> The right argument to the derived function is the string `'the cat sat on the medallion'`. The operand and the string are separated by the `⊣` function. Instead we could have used parentheses, with the same result
A> ~~~
A>       ('notfound' ⎕s 0) 'the cat sat on the medallion'`.
A> ~~~

In the first expression the result is empty because the string `notfound` was not found. In the second expression `cat` was actually found. So we could say:

~~~
      'cat' {⍵↓⍨⍺ ⎕s 0 ⊣ ⍵}'the cat sat on the medallion'
cat sat on the medallion
~~~

That was easy, wasn't it! Regular expressions are nothing to be afraid of. 


### What's between the double quotes

Let's look at another example: find out what's between double quotes. First attempt:

~~~
      '"' ⎕S 0 ⊣ 'He said "Yes"'
 8 12
~~~

That gives us the offset of the two double quotes, but what if we want to have the offset and the length of any string found _between_ --- and including --- the double quotes? 

For that we need to introduce the _metacharacter_ dot (`.`), which has a special meaning in a regular expression: it represents _any_ character. (Not quite: we will soon discuss the one and only exception, the NewLine character). 

A> # Metacharacters
A>
A> Metacharacters, sometimes called special characters, are characters with a special meaning in a regular expression. 
A>
A> To specify a character that serves as a metacharacter, we _escape_ it with a backslash. So, yes, backslash is another metacharacter. To represent a dot followed by a backslash we would write `\.\\`
A> 
A> We’ll encounter more metacharacters as we go.

So we try:

~~~
      '"."' ⎕S 0 1 ⊣ 'He said "Yes"'

~~~

Oops - no hit. To understand this we have to know _exactly_ what the regular expression engine did:

1. It starts at the beginning of the string; that is actually one to the left of the "H"! That position can only be matched by the metacharacter `^` which represents the _start of a line_. 

1. Since we did not specify a leading `^` the RegEx engine moves to the first character.

1. It then tries to match `"` to `H`. Since there is no match...

1. It carries on until it arrives at the `"`; this is called "consuming a character". Now there is a match!

1. The engine now tries to match the `.` against the `Y`. Since the`.` matches _any_ character this is a match, too. 

1. It then moves forward one more character and tries to match the `"` with `e` - that's _not_ a match.

1. The engine forgets what it has done, goes back to where it started from (that was the `"`) and moves one character forward. 

1. It now tries to  match the `"` with the `Y` ... 

You can now see why it does not report any hit - it would only work on any single character that is embraced by two double quotes, for example on `'He said "Y"'`.


### Repeating a search pattern (quantifiers)

What we need is a way to tell the engine that it should try to match the `.` more than once. There is a general way of doing this and three abbreviations that cover most cases. First, the general way.

For example, in order to match a minimum of one to a maximum of three underscore characters:

~~~
      '_{1,3}' ⎕S 0 ⊢'_one__two___three____four'
0 4 9 17 20
~~~

It is actually easier to check the result by _replacing_ the hits with something that stands out:

~~~
      '_{1,3}' ⎕R '⍈' ⊢'_one__two___three____four'
⍈one⍈two⍈three⍈⍈four  
      '_{2,3}' ⎕R '⍈' ⊢'_one__two___three____four'
_one⍈two⍈three⍈_four
~~~

A> ### The right operand of ⎕R
A>
A> `⎕R` takes one or more replace strings as the right operand – _or_ a user defined function, discussed later. You cannot mix replace strings with user defined functions.

What's between the curly braces (`{}`) -- those are metacharacters as well -- defines how many instances are required: minimum and maximum. This is called a quantifier.

* `{x,y}` means at least `x` and no more than `y`.
* `{,y}` is the same as `{0,y}`.
* `{x,}` means at least `x`.
* `{x}` means exactly `x`.

Then there are the abbreviations that make life a bit easier:

* `*` is an abbreviation for `{0,y}` and `{,y}`.
* `+` is an abbreviationfor `{1,}`.
* `?` is an abbreviation for `{0,1}`. For that reason you can call it _optional_.


So:

~~~
      '".*"' ⎕R '⍈' ⊣ 'He said "Yes"!'
He said ⍈!
~~~

~~~
      '".*"' ⎕R '⍈' ⊣ 'He said "Yes" and "No"!'
He said ⍈!
~~~

Just one hit, and that hit spans `"Yes" and "No"`?! 


### Greedy and lazy

By default the engine is _greedy_ as opposed to _lazy_: 

1. First it tries to match the `.` against as many characters as it can. 

   That means it will stop only at the end of the line, because the dot will match everything but the end-of-line. as the asterisk repeats it over and over again.

2. Then the RegEx engine will _backtrack_ and try to find a double quote, coming from the right; once it finds one it's done the job.

The same is true for the `{x,y}` quantifiers: by default they are all _greedy_ rather than _lazy_, so repeating `y` times is done first before reducing the repetition to `x` times.

What we need instead is a _lazy_ search:

1. First it tries to match the `.` against the current character which is the "Y". That's a match.

1. It then tries to match the double quote against the next character. That fails, therefore the engine backtracks and tries again to match the dot against the "e". 

1. That's a match, so it again tries to match the double-quote with the "s"...

You can see how we end up at the _first_ double quote rather than the last one.

We can achieve that by specifying the "Greedy" option with a zero (default is one):

~~~
      '".*"' ⎕R '⍈' ⍠('Greedy' 0) ⊣ 'He said "Yes" and "No"!'
He said ⍈ and ⍈!
~~~

A> # Specifying options
A>
A>
A> Various options are available to control aspects of Search and Replace; these are selected using the _variant_ operator `⍠`.
A>
A> Note that if you use Classic Dyalog, or just want to ensure your code runs in a classic interpreter, `⎕OPT` is a synonym for `⍠`.
A>
A> Between the right operand and the right argument you may specify options. They are marked by the `⍠` operator. These are the options available:
A>
A> IC, Mode, DotAll, EOL, ML, Greedy, OM, InEnc, OutEnc, Enc, ResultText, UCP
A>  
A> IC – ignore case – is the principal option. That means that if no other option needs to be specified you can omit the `'IC'`.
A> 
A> So this would do: `⎕S 0 ⍠ 1 ⊢ 'whatever'`. A 1 would make a search pattern case insensitive. The default is 0.
A> 
A> In this chapter we’ll discuss Mode, DotAll, Greedy and UCP: these are the most important options. For the others refer to `⎕R`'s help page.

Let's repeat our findings because this is so important:

* Greedy means match _longest_ possible string.
* Lazy means match _shortest_ possible string.


### Lazy quantifiers

The quantifiers we discussed earlier are all greedy, but you can make them lazy by adding a `?` as shown here:

~~~
      .{0,}?
      .*?
      .+?
      .??
~~~


### The + can be dangerous!

But wouldn't it be better to use `+` rather than `*` here? After all, we are not interested in `""` because there is nothing between the two double quotes? Good point except that it does not work:

~~~
      '".+"' ⎕R '⍈' ⍠('Greedy' 0) ⊣ 'He said "" and ""'
He said ⍈"
~~~

That's because the engine would perform the following steps:

1. Investigate until we find a `"`.

1. Investigate the character right after the first double quote. That is the second double quote so _that is consumed_ because the regular expression required _at least one_. Since all other characters are a match as well the `.+` consumes all characters to the very end of the input string. 

1. Because it is lazy it then goes back the current position which by then is the space to the _right of the second double-quote_!

   From there it carries on until it finds a `"`. That is the _first_ `"` _after_ the word <<and>>. All that is then replaced by the `⍈` character.

1. The engine then carries on but because there is only a single `"` left there is no other match.

If we want to ignore any `""` pairs then we need to use a look-ahead, something we will discuss soon.


### Negate 

Here is another --- and better --- way to solve our problem:

~~~
      '"[^"]*"'⎕R'⍈'⊣'He said "" and ""'
~~~

* The engine carries on until it finds a `"`.
* It then carries on until it finds a character that is not a `"` because the expression `[^"]` means "not a double-quote". It then repeats the expression until it either find a `"` or reaches the end of the line or document.
* Then is performs the last step, matching the `"`.

Note that this expression has two advantages:

1. It is faster than our first attempt although in our example the difference is miniscule.
1. It's _independent_ of the setting of Greedy.


### Garbage in, garbage out

Let's modify the input string: 

~~~
      is←'He said "Yes"" and "No"'  ⍝ define "input string" 
~~~

There are _two_ double quotes after the word "Yes"; that seems to be a typo. Watch what our RegEx is making of this:

~~~
      '".*"' ⎕R '⍈' ⍠('Greedy' 0) ⊣ is
 He said ⍈⍈No"
~~~

This example highlights a potential problem with input strings: many regular expressions work perfectly well as long as the input string is syntactically correct (or matches your expectations).

That's the reason (among others) why regular expressions are not recommended for processing HTML because HTML is very often full of syntactical errors. 

However, if you can be certain that the HTML you have to deal with _is_ syntactically correct _and_ the piece of HTML is short and not nested then you can use regular expressions to process HTML.

A> # Regular expressions and HTML
A>
A> There are claims that you _cannot_ parse HTML with regular expressions because a regular expression engine is a Finite Automata while HTML can be nested indefinitely. This is partly wrong and partly misleading.
A> 
A> * It is wrong because today's regular expression engines come with features (back referencing) that are clearly beyond the feature set of Finite Automata.
A> * It is misleading because it ignores that regular expression engines are perfectly capable of processing small pieces of HTML that are known to be syntactically correct.


### Metacharacters: the full list

By now we've met quite a number of metacharacters; how many do we have to deal with? Well, quite a lot:

|   | Metacharacter               | Symbol | |Meaning
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

Note that both `}` and `]` are considered metacharacters only after an opening `{` or `[`. Without the opening counterpart they are taken literally; that's why they did not make it onto the list of metacharacters.


### Search digits in a string

Let's suppose we want to match all digits in a string:

~~~
      '[0123456789]'⎕R '⍈' ⊣ 'It''s 23.45 plus 99.12.'
It's ⍈⍈.⍈⍈ plus ⍈⍈.⍈⍈.
~~~

Everything between the `[` and the `]` is treated as a simple character - with a few exceptions we'll soon discuss. That makes both `[` and `]` metacharacters.

The same but shorter:

~~~
      '[0-9]'⎕R '⍈' ⊣ 'It''s 23.45 plus 99.12.'
It's ⍈⍈.⍈⍈ plus ⍈⍈.⍈⍈.
~~~

The minus is treated as a metacharacter here: it means "all digits from 0 to 9".


### The escape character: \

Even shorter:

~~~
      '\d'⎕R '⍈' ⊣ 'It''s 23.45 plus 99.12.'
It's ⍈⍈.⍈⍈ plus ⍈⍈.⍈⍈.
~~~

Note that the metacharacter backslash (`\` ) is used for two different purposes:

* To escape any of the RegEx metacharacters so that they are stripped of their special meaning and taken literally.
* To give the next character a special meaning if it is an ordinary ASCII letter.

So `\*` takes away the special meaning from the `*` while `\d` gives the `d` the special meaning: all digits.

We take the opportunity to add the dot (`.`) and the minus (`-`) to the character class. 

Note that the minus is not escaped; from the context the regular expression engine can work out that here the minus cannot mean from-to, so it is taken literally.

Note also that the `.` is not escaped either: inside the pair of `[]` the `.` is _not_ a metacharacter.

A> # Escaping several characters
A>
A> Say you need to escape all the metacharacters because you want to search them. Escaping every single one of them with a backslash is laborious and decreases readability, but there is a better way:
A> ~~~
A>       '\Q\^$.|?*+()[{\E'
A> ~~~
A> This escapes all characters between the `\Q` and the `\E`.

~~~
      '[\d.-]'⎕R '⍈' ⊣ 'It''s 23.45 plus -99.12.'
It's ⍈⍈⍈⍈⍈ plus ⍈⍈⍈⍈⍈⍈⍈
~~~

Here we have another problem: we want the dot only to be a match when there is a digit to both the left and the right of the dot. Our search pattern does not deal with this, so the trailing `.` is a match. We will tackle this problem soon.

Character classes work for letters as well:

~~~
      '[a-zA-Z]'⎕R '⍈' ⊣'It''s 23.45 plus 99.12.'
⍈⍈'⍈ 23.45 ⍈⍈⍈⍈ 99.12.
~~~

We can negate with `^` right after the opening `[`:

~~~
    '[^a-zA-Z]'⎕R '⍈' ⊣'It''s 23.45 plus 99.12.'
It⍈s⍈⍈⍈⍈⍈⍈⍈plus⍈⍈⍈⍈⍈⍈⍈
~~~

Notes:

* Only at the beginning of a character class definition has the caret the meaning "negate". Therefore you could also say that `[^` means "negate" while, say, `[1^2]` means "Match for one of these three characters: `1^2`".

* For APLers the caret is a bit tricky because it is confused with the logical AND (`∧`) primitive. Only next to each other does it become apparent which is which: `^∧`: the caret is a bit higher than the logical AND.

  ~~~
      ⎕UCS '^'     ⍝ The caret
   94
         ⎕UCS '∧'  ⍝ Logical OR
   8743
  ~~~


### Negate with digits and dots

~~~
      '[^.0-9]'⎕R '⍈' ⊣'It''s 23.45 plus 99.12.'
⍈⍈⍈⍈⍈23.45⍈⍈⍈⍈⍈⍈99.12.
~~~

Want to search for _gray_ and _grey_ in a document?

~~~
      'gr[ae]y'⎕S 0⊣'Americans spell it "gray" and Brits "grey".'
20 37
      'gr[ae]y'⎕R '⍈' ⊣'Americans spell it "gray" and Brits "grey".'
Americans spell it "⍈" and Brits "⍈".      
~~~


### Metacharacters within a character class

Note that there are only a few metacharacters inside character classes:

| Metacharacter    | Symbol | Meaning                    |
|-------------------|--------|----------------------------|
| Closing bracket   | `]`    |                            |
| Backslash         | `\`    | Escape next character      |
| Caret             | `^`    | Negate the character class but only after the opening `[` |
| Minus             | `-`    | From-to if there is something to both the left & right. |

We already worked out the engine is smart enough to take a minus literally when it makes an appearance somewhere where it cannot mean from-to: the beginning and the end of a character class. 

Similarly, the caret (`^`) character can only negate a character class as a whole when it follows the opening square bracket (`[^`). If the caret is specified elsewhere it is taken literally. 

Therefore the expression `[0-9^1]` does _not_ mean "all digits but 1", it means "all digits and the caret character and a 1".


### Searching for whitespace characters

Finding 0 to 3 whitespace characters followed by an ASCII letter at the beginning of a line:

~~~
      {'^\s{0,3}[a-zA-Z]' ⎕R '⍈' ⊣ ⍵}¨'Zero' ' One' '  Two' '   Three' '    four'
⍈ero  ⍈ne  ⍈wo  ⍈hree      four 
~~~

`\s` escapes the ASCII letter `s`, meaning that the `s` takes on a special meaning: `\s` stands for any whitespace character. That is at the very least the space character (`⎕UCS 32`) and the tab character (`⎕UCS 9`).

There are two options (set with the `⍠` operator) that control which other characters qualify as white space:

* "Mode"
* "UCP"

Both will be discussed soon.


### The options DotAll and Mode

We've learned that the `.` matched any character but not end of line.

~~~
      '".*"'⎕R'⍈'⊣ '"Foo' 'Goo"'
 "Foo  Goo" 
~~~

I> A vector of text vectors is internally processed like a file with multiple records.

Because the `.` does not match end-of-line it finds `"Foo` but then stops rather than carrying on trying to match the pattern with `Goo"`, so no hit is found.

With the DotAll option --- which defaults to 0 --- we can tell the RegEx engine to let `.` even match the end of a line:

~~~
      '".*"'⎕R'⍈'⍠('DotAll' 1)('Mode' 'D')⊣'"Foo' 'Goo "'
 ⍈
~~~

Note that we had to specify the Mode option as well because `DotAll←1` is invalid with `Mode←L`, which is the default. 

It is important to understand the different modes and their influence on `^` (start of document or line), `$` (end of document or line) and `DotAll` see [Document mode](#) for details.

It's not difficult to imagine a situation where you have a single search pattern but in one part you want the `.` to match end-of-line and in others you won't.


### The metacharacter `\N`

`\N` has almost the same meaning as the `.` except that it never matches the end of a line. That means it's independent of the setting of DotAll:

~~~
      '"\N*"'⎕R'⍈'⍠('DotAll' 1)('Mode' 'D')⊣'"Foo' 'Goo "'
 "Foo  Goo " 
~~~

Note that `\N` and `\n` are different: `\n` stands for a newline character.


### Analyzing APL code: Replace

Let's suppose you want to investigate APL code for a variable name `foo` but you want text and comments ignored. This is our input string:

~~~
      is←'a←1 ⋄ foo←1 2 ⋄ txt←''The ⍝ marks a comment; foo'' ⍝ set up vars a, foo, txt'
~~~

We want `foo←1 2` to be found or changed while the text and the comment remain ignored or unchanged. The problem is aggravated by the fact that the text contains a `⍝` symbol.

A naïve approach does not work:

~~~
      'foo' ⎕R '⍈' ⊣ is
a←1 ⋄ ⍈←1 2 ⋄ txt←'The ⍝ marks a comment; ⍈' ⍝ set up vars a, ⍈, txt
~~~

Dyalog's implementation of regular expressions offers an elegant solution to the problem:

~~~
      '''\N*''' '⍝\N*$' 'foo'⎕R(,¨'&&⍈')⍠('Greedy' 0)⊣is
a←1 ⋄ ⍈←1 2 ⋄ txt←'The ⍝ marks a comment; foo' ⍝ set up vars a, foo, txt
~~~

This needs some explanation:

1. `\N` is the same as a `.`: it matches all characters but the end-of-line character. 

   Setting `('DotAll' 1)` might make sense for the third search pattern (`foo`) but it would under certain circumstances prevent the first two search patterns from working, therefore we _must_ use the `\N` syntax for those patterns.

1. `'''\N*'''` catches all text --- that is everything between quotes --- and for that text `&` is specified as a replacement. 

   Now `&` stands for the matching text, therefore nothing will change at all but the matching text _won't participate in any further actions!_ In other words: everything between quotes is left alone.

1. `'⍝\N*$'` catches everything from a lamp (`⍝`) to the end of the line (`$`) and replaces it by itself (`&`). Again nothing changes but the comment will not be affected by anything that follows. 

   Since the first expression has already masked everything within (and including) quotes the first `⍝` does not cause problems; it is ignored at this stage anyway.

1. Finally `foo` catches the string `foo` in the remaining part, and that is what we are interested in.

As a result `foo` is found within the code but neither between the double quotes nor as part of the comment.

As far as we know, this powerful feature is specific to Dyalog, but we have only limited experience with other regular expression engines.

However, be aware that the third pattern must be very specific! To rephrase it: if the third pattern is matching anything between quotes etc. then it will change them anyway. 

In this example this is illustrated:

~~~
      '''\N*''' '⍝\N*$' '^.*$'⎕R(,¨'&&⍈')⍠('Greedy' 1)('Mode' 'D')⊣is
⍈
~~~

The expression `^.*$` together with `('Greedy' 1)` and `('Mode' 'D')` means:

1. The `^` matches the _start of the document_!

1. The `$` matches the _end of the document_!

1. The expression `.*` matches _everything including line breaks_!

Therefore the expression changes the whole document into a single `⍈` despite the first two patterns.


### Regular expressions and scalar extension

Note that the `,¨` in `,¨'&&⍈'` is essential: without it the RegEx engine would use the pattern `'&&⍈'` thrice. 

The reason is that `⎕R` actually does not accept scalars, it only accepts vectors. So if you specify three search patterns on the left, then you need to specify not four and not two but three replace patterns as well. 

If only a single vector is specified then this vector is taken thrice: a version of scalar extension.


### Analysing APL code: Search

The extremely powerful syntax discussed above is also available with `⎕S`:

~~~
      '''\N*''' '⍝\N*$' 'foo'⎕S 0 1 2⍠('Greedy' 0)⊣is
 6 3 2  20 28 0  49 25 1 
~~~

We have already discussed the transformation codes 0 (offset) and 1 (length) but not 3: this returns the pattern number which matched the input document, origin zero.

In our case it is the third pattern (`foo`) we are interested in, so we can ignore those that are 0 and 1.

A> # Greedy and lazy
A>
A> Using the option `⍠('Greedy' 0)` has a disadvantage: it makes _all_ search patterns lazy.
A>
A> There will be cases when you want only a part of your search pattern to be lazy and other parts greedy.
A>
A> Luckily this can be achieved with the metacharacter question mark (`?`):
A> 
A>  ~~~
A>       '"\N*?"'⎕R '⍈' ⊣ is
A> He said ⍈ and ⍈
A> ~~~
A>
A> Since the engine is greedy by default, you need specify the `?` only for those parts of your search pattern you want to be lazy.


### Word boundaries

Our search pattern is still not perfect since it would work on `boofoogoo` as well:

~~~
      '''\N*''' '⍝\N*$' 'foo'⎕R(,¨'&&⍈')⍠('Greedy' 0)⊣'This boofoogoo is found as well'
This boo⍈goo is found as well
~~~

We can solve this problem with `\b` (word boundaries). `\b` does not attempt to match a particular character on a particular position. Instead it checks whether there is a word boundary either before are after the current position – but not both.

That means no matter whether they are successful or not they won't change the position the engine is currently investigating. They are also called anchors.

To put it simply, `\b` allows you to perform a ‘whole word only’ search as in `\bword\b`.

Prior to version 8 of PCRE (and 16.0 of Dyalog) this was true only for ASCII characters. So it worked only for the English language.

~~~
       ⍴'\bger\b'⎕S 0 ⊣'Kai Jägerßabc'
1
~~~

That's because both ä and ß are non-ANSI characters.

Now you can set the UCP option to 1 if you want Unicode characters to be taken into account as well:

~~~
      ⍴'\bger\b'⎕S 0 ⍠('UCP' 1)⊣'Kai Jägerßabc'
0
~~~

Now `ä` and `ß` no longer qualify as word boundaries.


### Backreferences

Suppose you want to search for three digits:

~~~
      '[0-9]{3,}' ⎕R '⍈' ⊣ ' 3 digits: 123;'
 3 digits: ⍈;
~~~

But what if you want to ensure it's always the _same_ digits? 

For that you need back references:

~~~
      '([0-9])\1{2,}' ⎕R '⍈' ⊣ ' 3 digits: 333; 444; 123;'
 3 digits: ⍈; ⍈; 123;
~~~

The first two groups of digits are found while the last one is ignored --- exactly what we want.

Notes:

* We place parentheses around `[0-9]` to be able to refer to it; that's called _backreferencing_.
* With `\1` we refer to the group.
* The group is repeated once with `{2,}`, so we end up checking for three digits in total.

I> You can define and use up to 99 groups.

If you want to find only numbers that consist of exactly three digits which have to be the same then this would work:

~~~
      '([0-9])\1{2,}' ⎕R '⍈' ⊣ '333; 444; 123;'
⍈; ⍈; 123;
~~~

But be aware:

~~~
      '([0-9])\1{2,}' ⎕R '⍈' ⊣ '3333; 4444; 1234;'
⍈; ⍈; 1234;
~~~

To solve this problem you need to master look-arounds.


### Look-ahead and look-behind (look-arounds)

We can use look-ahead and look-behind to solve a problem we ran into earlier with numbers. This did not really work because _all_ dots got replaced when we wanted only those with digits to the right and the left being a match:

~~~
      '[\d.¯-]'⎕R'⍈'⊣'It''s 23.45 plus 99.12.'
It's ⍈⍈⍈⍈⍈ plus ⍈⍈⍈⍈⍈⍈
~~~

We don't want the last dot to be a match. Obviously we need to check the characters to the left and to the right of each dot.

Both look-ahead and look behind start with `(?`. A look-behind then needs a `<` while the look-ahead doesn't. 

Both then need either a `=` for _equal_ or a `!` for _not equal_ followed by the search token and finally a closing `)`. Hence `(?<=\d)` for the look-behind and `(?=\d)` for the look-ahead:

~~~
      '\d' '(?<=\d).(?=\d)'⎕R'⍈'⊣'It''s 23.45 plus 99.12.'
It's ⍈⍈⍈⍈⍈ plus ⍈⍈⍈⍈⍈.      
~~~

That works! We use two expressions here: first we look for all digits and then we look for dots that have a digit to their right and their left. 


I> It’s important to realise that the current position does not change when a look-behind or a look-ahead is performed; that's why they are called _zero-length assertions_.

However, if you need `⎕S` to return the start and the length of any matches then the result is unlikely to be what you are after:

~~~
      '\d' '(?<=\d).(?=\d)'⎕S 0 1 ⊣'It''s 23.45 plus 99.12.'
 5 1  6 1  7 1  8 1  9 1  16 1  17 1  18 1  19 1  20 1
~~~

We need an expression that identifies any vector of digits as one unit, no matter whether there is a dot between the digits or not:

~~~
      '\d+(?<=\d).(?=\d)\d+' ⎕R '⍈' ⊣ 'It''s 23.45 plus 99.12.'
It's ⍈ plus ⍈.
      '\d+(?<=\d).(?=\d)\d+' ⎕S 0 1 ⊣ 'It''s 23.45 plus 99.12.'
 5 5  16 5 
~~~

That's better.

As mentioned earlier a look-ahead, as well as a look-behind, can be negated by using a `!` rather than a `=`

Lets' try this. Assuming we look for `x` and `y`:

~~~
      'x(?<=y)' ⎕R'⍈' ⊣ 'abxycxd' ⍝ Exchange all "x" when followed by a "y"
ab⍈ycxd
      'x(?!y)' ⎕R'⍈' ⊣ 'abxycxd' ⍝ Exchange all "x" when NOT followed by a "y"
abxyc⍈d      
      '(?<=x)y' ⎕R'⍈' ⊣ 'abxycyd' ⍝ Exchange all "y" when preceeded by an "x"
abx⍈cyd
      '(?<!x)y' ⎕R'⍈' ⊣ 'abxycyd' ⍝ Exchange all "y" when NOT preceeded by an "x"
abxyc⍈d       
~~~


### Transformation functions

Instead of providing a replace string one can also pass a function as operand to `⎕R` (and `⎕S` as well). This feature is particularly useful when not only pattern matching is required but also calculations based on the findings.

Look at this piece of CSS code:

~~~
p {
    /* font-size: 12px; */
    font-size: 12px;
    border: 1px solid black;
}
~~~

Though using "px" always was and still is quite common, these days you are advised to used "em" (and sometimes "rem") instead. The reason is that "em" refers to the parent of the current object. 

For example, this:

~~~
p {
    font-size: 0.9em;
}
~~~

means that the size is 90% oif the font size defined for <p>'s parent. 

But there has to be at least one absolute definition, and that's usually to be found in the <body> tag:

~~~
body {
    font-size: 18px;
}
~~~

I> If such a definition is missing then it falls back to the browser's default which these days usually is 16px.

The advantage is that in order to change the size of the fonts used you have to change one single value.

Now lets assume that we want to convert "px" into "em". Just replacing "px" against "em" doesn't do the job, we also need to calculate the correct value (we ignore the inheritance problem here).

This is where a transformation functions come in handy:

~~~
     ∇ r←Change arg;v;em;baseFontSize
[1]    baseFontSize←18        ⍝ What's defined for body; that should be defined in "px".
[2]    :If 0=arg.PatternNum
[3]        r←arg.Match
[4]    :Else
[5]        v←⊃(//)⎕VFI¯2↓arg.Match
[6]        :If v∊1 2          ⍝ Those should be left alone.
[7]            r←arg.Match
[8]        :Else
[9]            em←0.01×⌊0.5+100×v÷baseFontSize
[10]           r←(⍕em),'em'
[11]       :EndIf
[12]   :EndIf
[13]  ⍝Done
     ∇
~~~

We assign the CSS code we've discussed earlier on a variable `∆`:

~~~
∆←''
∆,←⊂'p {'
∆,←⊂'    /* font-size: 12px; */'
∆,←⊂'    font-size: 12px;'
∆,←⊂'    border: 1px solid black;'
∆,←⊂'}'
∆←,¨∆
~~~

Note that the last statement is essential, otherwise you'll get a `RANK ERROR: Invalid input source`: the input vector _must not_ contain scalars.

We want to investigate the right argument `Change` is going to get, therefore we set a stop vector on line 1 of `Change`:

~~~
      1 ⎕STOP 'Change'
~~~

Now we run this expression:

~~~
      ∆2←'/\*.*\*/' '\b[0-9]{1,3}px'⎕R Change⍠('DotAll' 1)('Mode' 'M')('Greedy' 0)⊣∆
~~~

The left operand of `⎕R` is a two-element vector:

* The first item matches comments; remember that we need to escape any `*` character we want to be taken literally.
* The second item matches a word boundary followed by one, two or three digits followed by "px".

Because of the stop vector execution stops on line 1 of `Change`. That allows us to investigate the right argument:

~~~
      arg.(⊃{⍵ (⍎⍵)}¨↓⎕nl 2 9)
 Block       p { 
                /* font-size: 12px; */
                font-size: 12px;
                border: 1px solid black;
             }
 BlockNum                                                                         0 
 Lengths                                                                         22 
 Match                                                       /* font-size: 12px; */ 
 Names                                                                                           
 Offsets                                                                          9 
 Pattern                                                                   /\*.*\*/ 
 PatternNum                                                                       0 
 ReplaceMode                                                                      1 
 TextOnly                                                                         1 
~~~

The right argument contains all the pieces of information that you might possibly need.

Now it's time to discuss the function `Change` in detail:

~~~
     ∇ r←Change arg;v;em;baseFontSize
[1]    baseFontSize←18        ⍝ What's defined for body; that should be defined in "px".
[2]    :If 0=arg.PatternNum
[3]        r←arg.Match
[4]    :Else
[5]        v←⊃(//)⎕VFI¯2↓arg.Match
[6]        :If v∊1 2          ⍝ Those should be left alone.
[7]            r←arg.Match
[8]        :Else
[9]            em←0.01×⌊0.5+100×v÷baseFontSize
[10]           r←(⍕em),'em'
[11]       :EndIf
[12]   :EndIf
[13]  ⍝Done
     ∇
~~~

* `PatternNum` is a running number that starts  with 0.

   In our case we have two patterns. The first one catches comments. We want them to survive unchanged, so we just return `Match` meaning that nothing is changed at all.

* In line `[5]` we drop "px" from the pattern and convert what's left into a numeric value.

* In line `[6]` we check whether the value is just 1 or 2. If that's the case then this is most likely a definition of a border. However, it's best to leave such small values alone in any case, so again we return the match.

* In line `[9]` we calculate the value of the pixels into "em" in proportion to the base font size.

A> ### "em" versus "rem"
A>
A> There is not only "em" available, there is also "rem". "em" are calculated in proportion to their parent. That's usually what you want.
A> 
A> Imagine a list (<ul> or <ol>). If you want to make the <li>'s font slightly smaller than the parent's font then specifying `0.85em;` seems to be fine, right? Well, only as long as you do not have nested lists!
A>
A> With deeply nested lists things get quickly out of hand because with every level the font gets smaller and smaller.
A>
A> "rim" to the rescue! In opposite to "em" they refer to the base font size size; that's what was defined in the <body> tag. That way all lists use the same --- slightly smaller --- font size.  
A>

⍝A> Difficulties to remember "rim"? Try "Reset IM".

Transformation functions give you enormous power: you can do whatever you like.


### Document mode

So far we have specified just a simple string as input. We can, however, pass a vector of strings as well. Look at this example:

~~~
      input←'He said: "Yes, that might' 'well be right." She answered: "So be it!"'
~~~

It's not a bad idea to think of the two elements of the input vector as ‘blocks’. Note that the first reported speech straddles the blocks. 

By default the search engine operates in Line mode. That means each block is processed independently by the engine. You cannot search for `\r` (carriage return) in Line mode: the search engine will never see them. 

In Mixed mode as well as Document mode you _can_ search for `\r` because all blocks are passed at once. Naturally this also requires more memory than Line mode.

Let's do some tests:

~~~
      '".*"'⎕R'⍈'⍠('Greedy' 0)⊣input
 He said: "Yes, that might  well be right.⍈So be it!" 
      '".*"'⎕R'⍈'⍠('Greedy' 0)('Mode' 'M')('DotAll' 1)⊣input
He said: ⍈ She answered: ⍈       
~~~

Note that in order to specify `('DotAll' 1)` it is necessary to set `('Mode' 'M')`. `('Mode' 'D')` would have worked in the same way. However, when it comes to `^` and `$` then it makes a big difference:

* In Line mode (`('Mode' 'L')`) `^` finds the start of the line and `$` finds the end of the line.
* In Mixed mode (`('Mode' 'M')`) `^` finds the start of each block and `$` finds the end of each block.
* In Document mode (`('Mode' 'D')`) `^` finds the start of the document and `$` finds the end of the document.


### Alternations

Suppose we want to match either the word _cat_ or the word _dog_:

~~~
      'cat|dog' ⎕R '⍈'⊣ 'donkey, bird, cat, rat, dog'
donkey, bird, ⍈, rat, ⍈
~~~

The `|` has the lowest precedence of all RegEx operators. Therefore it first tries to match `cat` and only then `dog`.

However, be careful:

~~~
      'cat|catfish' ⎕R '⍈'⊣ 'donkey, bird, cat, rat, dog, catfish'
donkey, bird, ⍈, rat, dog, ⍈fish
~~~

This is not what we want. The reason for this is that once the string `cat` has matched the RegEx engine gives up because it was successful, therefore it does not see the need to check later options. It's said the engine is _eager_.

Sorting the alternatives by length gets us around this problem:

~~~
      'catfish|cat' ⎕R '⍈'⊣ 'donkey, bird, cat, rat, dog, catfish'
donkey, bird, ⍈, rat, dog, ⍈
~~~

However, in real life we would put word boundaries to good use, avoiding the problem altogether:

~~~
      '\bcat\b|\bcatfish\b' ⎕R '⍈'⊣ 'donkey, bird, cat, rat, dog, catfish'
donkey, bird, ⍈, rat, dog, ⍈
~~~

Or even shorter:

~~~
      '\b(cat|catfish)\b' ⎕R '⍈'⊣ 'donkey, bird, cat, rat, dog, catfish'
donkey, bird, ⍈, rat, dog, ⍈
~~~

Note the parentheses used here for grouping.


### Optional items

The `?` makes the preceeding token optional. If you want to find either _November_ or its shortcut _Nov_:

~~~
      'Nov(ember)?' ⎕R '⍈'⊣ '...October, November, December; ... Oct, Nov, Dec'
...October, ⍈, December; ... Oct, ⍈, Dec
~~~

For plurals:

~~~
      'cars?' ⎕R '⍈'⊣ 'car, boat, plain, cars, boats, plains'
⍈, boat, plain, ⍈, boats, plains
~~~


### Extract what's between HTML tags

Suppose we have a piece of HTML code and are interested in any text between anchor tags (`<a>`). Suppose also we know there is no other tag inside the `<a>`, just simple text.

Now an `<a>` tag has always either an `href="..."` or an `id="..."` because otherwise it has no purpose. <!-- FIXME or `name=` -->

So it should be safe to say:

~~~
      '<a.*>.*<'⎕R'⍈'⊣'This <a href="http://aplwiki.com">is a link</a>, really!'
This ⍈, really!
~~~

Works, right? 

Well, yes, but it also works on this:

~~~
      txt←'This <abbr title="FooGoo"><a href="#page">is a link</a></abbr>'
      '<a.*>.*</a>'⎕R'⍈'⊣txt
This ⍈</abbr>    
~~~

That might come as a nasty surprise but when you think it through it's obvious why that is: the expression `<a.*>` does indeed catch not only `<a` but also `<abbr>`. Shows how important it is to be precise.

We can work around this quite easily: because any `<a>` tag must have at least one attribute in order to make sense there _must_ be a space after the `a`; therefore we can rewrite the expression as follows:

~~~
      '<a .*>.*</a>'⎕R'⍈'⊣txt
This <abbr title="FooGoo">⍈</abbr>
~~~

What a difference a space can make!

But somebody _might_ put in an `<a>` tag without any attribute at all, and then this would not work. So we are still in need not for a better but a perfect solution.

Here it is:

~~~
      '<a\b[^>]*>(.*?)</a>'⎕R'⍈'⊣'This <a>is a link</a>; more: <a id="_2">Foo</a>'
This ⍈; more: ⍈
~~~

Notes:

* The `\b` makes sure we catch nothing but `<a>` tags.

* The `[^>]*` consumes zero or more characters that are _not_ a closing `>`. In other words, it consumes everything after the `a>` and before the closing `>`.

* The `>` then consumes itself.

* The `.*`consumes everything until the RegEx engine arrives at the `<` (as part of `</a>`) because the `?` makes the quantifier lazy.


## Warnings

### The `.` character

Be very careful whith the `.` in RegEx: because it matches _every_ character except newline (and with `('DotAll' 1)` even newline) it can produce unwanted results, in particular with `('Greedy' 1)` but not restricted to that.

Because it's so powerful it allows you to be lazy: you write a RegEx and it matches everything that you want it to match, but it might always match everything, including stuff it shouldn't!

To illustrate the point let's assume that we want to match a date in a text vector in the international date format (`yyyy-mm-dd`). The naive approach with a dot works fine:

~~~
      '\d\d\d\d.\d\d.\d\d'⎕S 0 ⊣'1988-02-03'
0
~~~

Not really:

~~~
      '\d\d\d\d.\d\d.\d\d'⎕S 0 ⊣'1988/02/03'
0
~~~

While this might be acceptable because it seems to give the user the freedom to use a different separator the following example is certainly not acceptable:

~~~
      '\d\d\d\d.\d\d.\d\d'⎕S 0 ⊣'1988020312'
0
~~~

Its's much better to specify what's excepted as separator explicitly:

~~~
      '\d\d\d\d[-./ ]\d\d[-./ ]\d\d'⎕S 0⊣'1988/02/03'
0
~~~

Even this has it's problems:

~~~
      '\d\d\d\d[-./ ]\d\d[-./ ]\d\d'⎕S 0⊣'1988 02/03'
0
      '\d\d\d\d[-./ ]\d\d[-./ ]\d\d'⎕S 0⊣'1988-99-99'
0
~~~

Whether that's acceptable or not depends on the application.


### Assumptions

One of the greatest problems in programming is making assumptions and not document them. Or worse, not even being aware of your assumptions.

The above is an example. Imagine these two different scenarios:

1. You want to extract everything from a log file that's a date. You know that every record, if it carries a date at all, will start with the date, and you can safely assume that the dates are correctly saved in international date format.

1. You allow the user to enter her date of birth in a dialog box.

In the first case you can take a relaxed approach because you know all dates are valid and follow precise rules while in the second you have to be meticulous because otherwise you will accept and save rubbish sooner rather than later.


### Empty vectors

Given this variable:

~~~
      v←''  'A paragraph.'  ''
~~~

This should not change anything because it just attempts to replace any <TAB> character by four spaces yet the trailing empty vector disappears:

~~~
      Display '\t'⎕R(4⍴' ')⍠('Mode' 'M')⊣v
┌→─────────────────────────┐
│ ┌⊖┐ ┌→─────────────────┐ │
│ │ │ │A paragraph.      │ │
│ └─┘ └──────────────────┘ │
└∊─────────────────────────┘
~~~

This is because the three-element vector is transformed into a single document `<CRLF>A paragraph.<CRLF>` which is then passed in its entirety to PCRE, the underlying RegEx engine. PCRE has only generated two lines of output from this so the result is a two-element vector.

If you want a stricter correspondence between input and output you need to process the elements separately, e.g.:

~~~
      ]display '\t'⎕R(4⍴' ')⍠('Mode' 'M')¨v
┌→─────────────────────────────┐
│ ┌⊖┐ ┌→─────────────────┐ ┌⊖┐ │
│ │ │ │A paragraph.      │ │ │ │
│ └─┘ └──────────────────┘ └─┘ │
└∊─────────────────────────────┘
~~~

That's what happens in version 16.0. Be aware that this might change in a later version of Dyalog.


## Miscellaneous


### Tests

Complex regular expressions are hard to read and maintain. Document them intensively and cover them with exhaustive test cases.

At first this might seem overkill, but as usual tests will prove to be useful when you need to...

* understand a RegEx because the tests will demonstrate what the RegEx was supposed to do.

* make sure that after a change a RegEx is still doing what it was supposed to do, no matter whether the change was trivial or not.


### Performance

Don't expect regular expressions to be faster than a tailored APL solution; expect them to be slightly slower.

However, many regular expressions, like finding a simple string in another simple string or uppercasing or lowercasing characters are converted by the interpreter into a native (faster) APL expression (`⍷` and `⌶ 819` respectively) anyway.


### Helpful stuff

Online Tutorial

: A website that explores Regular Expressions in detail:
: <https://www.regular-expressions.info/tutorial.html>
: From the author of RegExBuddy.

RegexBuddy
: Software that helps interpret or build  regular expressions:

: <https://www.regexbuddy.com/>

Book reviews

: The aforementioned website comes with detailed book reviews: 

: <https://www.regular-expressions.info/hipowls.html>


*[HTML]: Hyper Text Mark-up language
*[DYALOG]: File with the extension 'dyalog' holding APL code
*[TXT]: File with the extension 'txt' containing text
*[INI]: File with the extension 'ini' containing configuration data
*[DYAPP]: File with the extension 'dyapp' that contains 'Load' and 'Run' commands in order to put together an APL application
*[EXE]: Executable file with the extension 'exe'
*[BAT]: Executable file that contains batch commands
*[CSS]: File that contains layout definitions (Cascading Style Sheet)
*[MD]: File with the extension 'md' that contains markdown
*[CHM]: Executable file with the extension 'chm' that contains Windows Help(Compiled Help) 
*[DWS]: Dyalog workspace
*[WS]: Short for Workspaces
*[PF-key]: Programmable function key