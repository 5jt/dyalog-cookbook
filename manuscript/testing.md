{:: encoding="utf-8" /}

# Testing: the sound of breaking glass

Our application here is simple – just count letter frequency in text files. 

All the other code has been written to package the application for shipment, and to control how it behaves when it encounters problems. 

Developing code refines and extends it. We have more developing to do. Some of that developing might break what we already have working. Too bad. No one’s perfect. But we would at least like to know when we’ve broken something – to hear the sound of breaking glass behind us. Then we can fix the error before going any further. 

In our ideal world we would have a team of testers continually testing and retesting our latest build to see if it still does what it’s supposed to do. The testers would tell us if we broke anything. In the real world we have programs – tests – to do that. 

What should we write tests for? “Anything you think might break,” says Kent Beck[^beck], author of _Extreme Programming Explained_. We’ve already written code to allow for ways in which the file system might misbehave. We should write tests to discover if that code works. We’ll eventually discover conditions we haven’t foreseen and write fixes for them. Then those conditions too join the things we think might break, and get added to the test suite. 


## Why you want to write tests


### Notice when you break things

Some functions are more vulnerable than others to being broken under maintenance. Many functions are written to encapsulate complexity, bringing a common order to a range of different arguments. For example, you might write a function that takes as argument any of a string[^string], a vector of strings, a character matrix or a matrix of strings. If you later come to define another case, say, a string with embedded line breaks, it's easy enough inadvertently to change the function's behaviour with the original cases. 

If you have tests that check the function's results with the original cases, it's easy to ensure your changes don't change the results unintentionally. 


### More reliable than documentation

No, tests don't replace documentation. They don't convey your intent in writing a class or function. They don't record your ideas for how it should and should not be used, references you consulted before writing it, or thoughts about how it might later be improved.

But they do document with crystal clarity what it is _known_ to do. In a naughty world in which documentation is rarely complete and even less often revised when the code is altered, it has been said the _only_ thing we know with certainty about any given piece of software is what tests it passes. 


### Understand more 

Test-Driven Design (TDD) is a high-discipline practice associated with Extreme Programming. TDD tells you to write the tests _before_ you write the code. Like all such rules, we recommend following TDD thoughtfully. The reward from writing an automated test is not _always_ worth the effort. But it is a very good practice and we strongly recommend it. 

If you are writing the first version of a function, writing the tests first will clarify your understanding of what the code should be doing. It will also encourage you to consider boundary cases or edge conditions: for example, how should the function above handle an empty string? A character scalar? TDD first tests your understanding of your task. If you can't define tests for your new function, perhaps you're not ready to write the function either. 

If you are modifying an existing function, write new tests for the new things it is to do. Run the revised tests and see that the code fails the new tests. If the unchanged code _passes_ any of the new tests... review your understanding of what you're trying to do! 


### Write better 

Writing functions with a view to passing formal tests will encourage you to write in _functional style_. In pure functional style, a function reads only the information in its arguments and writes only its result. No side effects or references. 

      ∇ Z←mean R;r
    [1] Z←((+/r)÷≢r←,R)
      ∇

In contrast, this line from `TxtToCsv` reads a value from a namespace external to the function (`EXIT.APPLICATION_CRASHED`) and sets another: `#.ErrorParms.returnCode`. 

      #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED

In principle, `TxtToCsv` _could_ be written in purely functional style. References to classes and namespaces `#.HandleError`, `#.APLTreeUtils`, `#.WinFile`, `EXIT`, and `#.ErrorParms` could all be passed to it as arguments. If those references ever varied -- for example, if there were an alternative namespace `ReturnCodes` sometimes used instead of `EXIT` -- that might be a useful way to write `TxtToCsv`. But as things are, cluttering up the function's _signature_ -- its name and arguments -- with these references harms rather than helps readability. It is an example of the cure being worse than disease. 

You can't write _everything_ in pure functional style but the closer you stick to it, the better your code will be, and the easier to test. Functional style goes hand in hand with good abstractions, and ease of testing. 


## Why you don't want to write tests

There is nothing magical about tests. Tests are just more code. The test code needs maintaining like everything else. If you refactor a portion of your application code, the associated tests need reviewing -- and possibly revising -- as well. In programming, the number of bugs is generally a linear function of code volume. Test code is no exception to this rule. Your tests are both an aid to development and a burden on it. 

You want tests for everything you think might break, but no more tests than you need. 

Beck's dictum -- test anything you think might break -- provides useful insight. Some expressions are simple enough not to need testing. If you need the indexes of a vector of flags, you can _see_ that `{⍵/⍳≢⍵}` will find them. It's as plain as `2+2` making four. You don't need to test that. APL's scalar extension and operators such as _outer product_ allow you to replace nested loops (a common source of error) with expressions which don't need tests. The higher level of abstraction enabled by working with collections allows not only fewer code lines but also fewer tests. 

Time for a new version of MyApp. Make a copy of `Z:\code\v04` as `Z:\code\v05`.


## Setting up the test environment

We'll need the Tester class from the APLTree library. And a namespace of tests, which we'll dub `#.Tests`. 

Write `Z:\code\v05\Tests.dyalog`:


    :Namespace Tests
    ⍝ Dyalog Cookbook, Version 05
    ⍝ Tests
    ⍝ Vern: sjt24jun16
    
    :EndNamespace

and include both scripts in the DYAPP:

    Target #
    Load ..\AplTree\APLTreeUtils
    Load ..\AplTree\ADOC
    Load ..\AplTree\HandleError
    Load ..\AplTree\IniFiles
    Load ..\AplTree\Logger
    Load ..\AplTree\WinFile
    leanpub-start-insert
    Load ..\AplTree\Tester
    leanpub-end-insert
    Load Constants
    Load Utilities
    leanpub-start-insert
    Load Tests
    leanpub-end-insert
    Load MyApp
    Run MyApp.Start 'Session'

Run the DYAPP to build the workspace. In the session execute `#.ADOC.Browse #.Tester` to see the documentation for the Tester class, and browse also to [aplwiki.com/Tester](http://aplwiki.com/Tester) to see the discussion there. 


## Unit and functional tests 

> Unit tests tell a developer that the code is _doing things right_; functional tests tell a developer that the code is _doing the right things_. 

It's a question of perspective. Unit tests are written from the programmer's point of view. Does the function or method return the correct result for given arguments? Functional tests, on the other hand, are written from the user's point of view. Does the software do what its _user_ needs it to do?

Both kinds of tests are important. If you are a professional programmer you need a user representative to write functional tests. If you are a domain-expert programmer[^dep] you can write both. 

In this chapter we'll tackle unit tests. Later in the book we'll consider functional tests. 


## Writing unit tests

### Unit tests without state

Utilities are a good place to start writing tests. Many utility functions are simply names assigned to common expressions. Others encapsulate complexity, making similar transformations of different arguments. 

We'll start in `#.Utilities` with the simple case-transforming functions: `toLowercase`, `toUppercase`, and `toTitlecase`. The first two of these merely compose left arguments of 0 and 1 to the experimental I-beam `819⌶`. 

Why test that? When could that ever break? Well, an experimental I-beam is just that: experimental. It might be withdrawn. If that ever happened, we'd write new versions of `toLowercase` and `toUppercase`, and we would definitely want tests. But the time to write the tests is now, when we are most clear what we need the functions to do. 

One thing we need these functions to do is handle case in bicameral scripts other than Latin, eg Greek and Cyrillic. That is neglected by many case-switching utilities. So we'll test a few Greek characters as well. In `Z:\code\v05\Tests.dyalog`:

    :Namespace Tests
    ⍝ Dyalog Cookbook, Version 05
    ⍝ Tests
    ⍝ Vern: sjt26jun16
       
        EN_lower←'abcdefghijklmnopqrstuvwxyz'
        ⍝ accented Latin and Greek characters
        AccentedUpper←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝΆΈΉΊόΌύΎΏ'
        AccentedLower←'áâãàäåçðèêëéìíîïñòóôõöøùúûüýάέήίόόύύώ'

Now some boundary cases

    ∇ Z←Test_toLowercase_001(debugFlag batchFlag)
     ⍝ boundary case
      Z←''≢#.Utilities.toLowercase''
    ∇
        
    ∇ Z←Test_toLowercase_002(debugFlag batchFlag)
     ⍝ no case
      Z←∆≢#.Utilities.toLowercase ∆←' .,/'
    ∇

The two-flag right argument is part of the signature of a test function. We'll come back to what the flags do. The result `Z` indicates `¯1`: the test broke ; `0`: no problem found; `1`: problem found. 

Now the basic English alphabet, and the Latin and Greek accented characters

    ∇ Z←Test_toLowercase_003(debugFlag batchFlag)
     ⍝ base case
      Z←EN_lower≢#.Utilities.toLowercase ⎕A
    ∇
        
    ∇ Z←Test_toLowercase_004(debugFlag batchFlag)
     ⍝ accented Latin and Greek characters
      Z←AccentedLower≢#.Utilities.toLowercase AccentedUpper
    ∇

This is tedious already, but writing tests is all about being thorough, so we'll replicate these four tests for `toUppercase` (reversing the arguments) and throw in a couple for `toTitlecase` as well. 

    ⍝ #.Utilities.toTitlecase
       
    ∇ Z←Test_toTitlecase_001(debugFlag batchFlag)
     ⍝ base case
      Z←'The Quick Brown Fox'≢ #.Utilities.toTitlecase'the QUICK brown FOX'
    ∇
        
    ∇ Z←Test_toTitlecase_002(debugFlag batchFlag)
     ⍝ Greek script
      Z←'Όι Πολλοί'≢ #.Utilities.toTitlecase'όι ΠΟΛΛΟΊ'
    ∇

That will do as a start. Notice each test is defined as a function that returns a scalar flag indicating whether it has found an error. (Not whether it has passed.) No test has referred to any argument: we'll come back to that shortly. 

Let's give these tests a run.

          #.Tester.Run #.Tests
    --- Tests started at 2016-06-26 14:08:04  on #.Tests -----------------
      Test_toLowercase_001 (1 of 10) : boundary case
      Test_toLowercase_002 (2 of 10) : no case
      Test_toLowercase_003 (3 of 10) : base case
      Test_toLowercase_004 (4 of 10) : accented Latin and Greek characters
      Test_toTitlecase_001 (5 of 10) : base case
      Test_toTitlecase_002 (6 of 10) : Greek script
      Test_toUppercase_001 (7 of 10) : boundary case
      Test_toUppercase_002 (8 of 10) : no case
      Test_toUppercase_003 (9 of 10) : base case
    * Test_toUppercase_004 (10 of 10) : accented Latin and Greek characters
     ----------------------------------------------------------------------
       10 test cases executed
       1 test case failed
       0 test cases broken

Ah. Now there's a surprise. Despite their simplicity, we already have a test that failed. Let's investigate. 

          )CS #.Tests
    #.Tests
          AccentedLower ≡ #.Utilities.{toLowercase toUppercase ⍵} AccentedLower
    1
          AccentedUpper ≡ #.Utilities.{toUppercase toLowercase ⍵} AccentedUpper
    0

So the problem is with `AccentedUpper`. 

          where←{⍵/⍳≢⍵}
          where AccentedUpper≠#.Utilities.{toUppercase toLowercase ⍵} AccentedUpper
    33 35
          AccentedUpper[33 35]
    όύ

And there we have it. `AccentedUpper` includes two lowercase characters. Easy enough to miss if you're not familiar with Greek script. Easy enough to find and fix! Testing rocks. Redefine the accented character lists. 

        ⍝ accented Latin and Greek characters
        AccentedUpper←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝΆΈΉΊΌΎΏ'
        AccentedLower←'áâãàäåçðèêëéìíîïñòóôõöøùúûüýάέήίόύώ'

Now our tests all pass. We'll proceed to something more substantial: `CountLetters`. A base case would run it against the English alphabet:

          Params.ALPHABETS.English CountLetters 'The Quick Brown Fox'
    B 1
    C 1
    E 1
    F 1
    H 1
    I 1
    K 1
    N 1
    O 2
    Q 1
    R 1
    T 1
    U 1
    W 1
    X 1

That result could be specified more conveniently as two columns. 

          ↓[1]Params.ALPHABETS.English CountLetters 'The Quick Brown Fox'
    ┌───────────────┬─────────────────────────────┐
    │BCEFHIKNOQRTUWX│1 1 1 1 1 1 1 1 2 1 1 1 1 1 1│
    └───────────────┴─────────────────────────────┘

So our new section in `#.Tests` becomes 

        ⍝ #.MyApp.CountLetters
        
    ∇ Z←Test_CountLetters_001(debugFlag batchFlag);a;r
     ⍝ base case
      a←#.MyApp.Params.ALPHABETS.English
      r←('BCEFHIKNOQRTUWX')(1 1 1 1 1 1 1 1 2 1 1 1 1 1 1)
      Z←r≢↓[1]a #.MyApp.CountLetters'The Quick Brown Fox'
    ∇


### Unit tests with state

You might have spotted some 'state' hidden in the last test. `CountLetters` refers to the matrix `ACCENTS` of accented characters. That table is a constant, so perhaps we can be allowed to say the last test is a stateless unit test. 

The same cannot be true of the `CountLettersIn` function, which reads and writes files. The result depends on the state in the files. 

At this point we need to incorporate files and folders into our test apparatus. We have suitable source folders and output files in `Z:\texts`, but we have a problem with using them as they are: we have no independent way of verifying the results for the contents. 

Better to use shorter files for which the correct results can be determined independently. Best of all, let the tests generate the files. 

The Tester class looks in the tests for a function called `Initial` and runs that first. We'll use this convention to create test files with known character frequencies.

    C←#.Constants
    TEST_FLDR←'./tests/'
    ∇ Initial;C;file
      :If ⎕NEXISTS TEST_FLDR
          :For file :In ⊃C.NINFO.NAME(⎕NINFO⍠'Wildcard' 1)TEST_FLDR,'*.*'
              ⎕NDELETE file
          :EndFor
      :Else
          ⎕MKDIR TEST_FLDR
      :EndIf
    ∇
    ...

A> Why loop on `file` rather than `⎕NDELETE¨` the list of files? Because `⎕NDELETE¨` will break on an empty list. 

    ∇ Z←Test_CountLettersIn_001(debugFlag batchFlag);a;files;cf;cc2n;sas;res
     ⍝ across multiple files
      a←#.MyApp.Params.ALPHABETS.English
      cc2n←{2 1∘⊃¨⎕VFI¨2↓¨⍵}                    ⍝ CSV col 2 as numbers
      res←TEST_FLDR,'count.csv'                 ⍝ results file
      sas←{⍵[?⍨≢⍵]}                             ⍝ scramble a string
      cf←?1000⍴⍨5,≢a                            ⍝ random freqs for 5 files
      files←{TEST_FLDR,'test',⍵,'.txt'}∘⍕¨⍳≢cf
      (sas¨(↓cf)/¨⊂a)⎕NPUT¨files
      :If Z←#.MyApp.EXIT.OK≢a #.MyApp.CountLettersIn files res
      :OrIf Z←(+⌿cf)≢cc2n⊃⎕NGET res 1
      :EndIf
    ∇

A> Admire how elegantly the notation lets us generate randomised character frequencies from alphabet `a` for 5 files (`?1000⍴⍨5,≢a`) and scramble them (`{⍵[?⍨≢⍵]}`). 

But our elegant test breaks!

          #.Tester.EstablishHelpersIn #.Tests
          #.Tests.Run
    --- Tests started at 2016-07-24 11:18:08  on #.Tests ----------------------
    # Test_CountLettersIn_001 (1 of 12) : across multiple files
      Test_CountLetters_001 (2 of 12) : base case
      Test_toLowercase_001 (3 of 12) : boundary case
      Test_toLowercase_002 (4 of 12) : no case
      Test_toLowercase_003 (5 of 12) : base case
      Test_toLowercase_004 (6 of 12) : accented Latin and Greek characters
      Test_toTitlecase_001 (7 of 12) : base case
      Test_toTitlecase_002 (8 of 12) : Greek script
      Test_toUppercase_001 (9 of 12) : boundary case
      Test_toUppercase_002 (10 of 12) : no case
      Test_toUppercase_003 (11 of 12) : base case
      Test_toUppercase_004 (12 of 12) : accented Latin and Greek characters
     --------------------------------------------------------------------------
       12 test cases executed
       0 test cases failed
       1 test case broken

Investigation reveals the problem: 

          )CS #.Tests
    #.Tests
          Initial
          Test_CountLettersIn_001 0 0
    VALUE ERROR
    CountLettersIn[21] Log.Log(⍕bytes),' bytes written to ',tgt
                      ∧

`Log` is undefined. In the envisaged use in production, it is defined by and local to `TxtToCsv`, the function that calls `CountLettersIn`. We have a similar issue with function `LogError`. That design followed Occam's Razor[^occam]: (entities are not to be needlessly multiplied) in keeping the log object in existence only while needed. But it now prevents us from testing `CountLettersIn` independently. So we'll refactor `Log` to be a child of `#.MyApp`, created by `Start`:

      ...
      ⎕WSID←'MyApp'
        
      'CREATE!'W.CheckPath'Logs' ⍝ ensure subfolder of current dir
      ∆←L.CreatePropertySpace
      ∆.path←'Logs\' ⍝ subfolder of current directory
      ∆.encoding←'UTF8'
      ∆.filenamePrefix←'MyApp'
      ∆.refToUtils←#
      Log←⎕NEW L(,⊂∆)
     
      Log.Log'Started MyApp in ',W.PWD
     
      LogError←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
       
      Params←GetParameters mode
      ...

And `Initial` will call `#MyApp.Start 'Session'`. 

Now we have both stateless and state-full tests passing. This completes Version 5. 





[^beck]: Kent Beck, in conversation with one of the authors.

[^string]: APL has no _string_ datatype. We use the word as a casual synonym for _character vector_.

[^dep]: an expert in the domain of the application rather than an expert programmer, but who has learned enough programming to write the code. 

[^occam]: _Non sunt multiplicanda entia sine necessitate._