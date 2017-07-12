{:: encoding="utf-8" /}

# Testing: the sound of breaking glass (Unit tests)

Our application here is simple – just count letter frequency in text files. 

All the other code has been written to configure the application, package it for shipment, and to control how it behaves when it encounters problems. 

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

Test-Driven Design (TDD) is a high-discipline practice associated with Extreme Programming. TDD tells you to write the tests _before_ you write the code. Like all such rules, we recommend following TDD thoughtfully. The reward from writing an automated test is not _always_ worth the effort. But it is a very good practice and we recommend it given that the circumstances are right. For example, if you know from the start _exactly_ what your program is supposed to do then TDD is certainly an option. If you start prototyping in order to find out what the user actually wants the program to do TDD is no option at all.

If you are writing the first version of a function, writing the tests first will clarify your understanding of what the code should be doing. It will also encourage you to consider boundary cases or edge conditions: for example, how should the function above handle an empty string? A character scalar? TDD first tests your understanding of your task. If you can't define tests for your new function, perhaps you're not ready to write the function either. 

If you are modifying an existing function, write new tests for the new things it is to do. Run the revised tests and see that the code fails the new tests. If the unchanged code _passes_ any of the new tests... review your understanding of what you're trying to do! 


## Readability

Reading and understanding APL code is more difficult than in other programming language due to the higher abstraction level and the power of APL's primitives. However, as long as you have an example were the function is fed with correct data it's always possible to decipher the code. Things can become very nasty indeed if an application crashes because inappropriate data arrives at your function. However, before you can figure out whether the data is appropriate or not you need to understand the code - a hen-egg problem.

That's when test cases can be very useful as well, because they demonstrate which data a function is expected to process. It also emphasizes why it is important to have test cases for all the different types of data (or parameters) a function is supposed to process. In this respect test cases should be exhaustive.


### Write better 

Writing functions with a view to passing formal tests will encourage you to write in _functional style_. In pure functional style, a function reads only the information in its arguments and writes only its result. No side effects or references. 

~~~
  ∇ Z←mean R;r
   [1] Z←((+/r)÷≢r←,R)
  ∇
~~~	  

In contrast, this line from `TxtToCsv` reads a value from a namespace external to the function (`EXIT.APPLICATION_CRASHED`) and sets another: `#.ErrorParms.returnCode`. 

~~~
    #.ErrorParms.returnCode←EXIT.APPLICATION_CRASHED
~~~      

In principle, `TxtToCsv` _could_ be written in purely functional style. References to classes and namespaces `#.HandleError`, `#.APLTreeUtils`, `#.FilesAndDirs`, `EXIT`, and `#.ErrorParms` could all be passed to it as arguments. If those references ever varied -- for example, if there were an alternative namespace `ReturnCodes` sometimes used instead of `EXIT` -- that might be a useful way to write `TxtToCsv`. But as things are, cluttering up the function's _signature_ -- its name and arguments -- with these references harms rather than helps readability. It is an example of the cure being worse than the disease. 

You can't write _everything_ in pure functional style but the closer you stick to it, the better your code will be, and the easier to test. Functional style goes hand in hand with good abstractions, and ease of testing. 


## Why you don't want to write tests

There is nothing magical about tests. Tests are just more code. The test code needs maintaining like everything else. If you refactor a portion of your application code, the associated tests need reviewing -- and possibly revising -- as well. In programming, the number of bugs is generally a linear function of code volume. Test code is no exception to this rule. Your tests are both an aid to development and a burden on it. 

You want tests for everything you think might break, but no more tests than you need. 

Beck's dictum -- test anything you think might break -- provides useful insight. Some expressions are simple enough not to need testing. If you need the indexes of a vector of flags, you can _see_ that `{⍵/⍳≢⍵}` will find them. It's as plain as `2+2` making four. You don't need to test that. APL's scalar extension and operators such as _outer product_ allow you to replace nested loops (a common source of error) with expressions which don't need tests. The higher level of abstraction enabled by working with collections allows not only fewer code lines but also fewer tests. 

Time for a new version of MyApp. Make a copy of `Z:\code\v07` as `Z:\code\v08`.


## Setting up the test environment

We'll need the `Tester` class from the APLTree library. And a namespace of tests, which we'll dub `#.Tests`. 

Write `Z:\code\v08\Tests.dyalog`:

~~~
    :Namespace Tests
    
    :EndNamespace
~~~	

and include both scripts in the DYAPP:

~~~
    Target #
    Load ..\AplTree\APLTreeUtils
    Load ..\AplTree\FilesAndDir
    Load ..\AplTree\HandleError
    Load ..\AplTree\IniFiles
    Load ..\AplTree\Logger
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
~~~	

Run the DYAPP to build the workspace. In the session you might want to execute `]ADoc #.Tester` to see the documentation for the Tester class if you are in doubt about any of the methods and helpers in `Tester` later on.


## Unit and functional tests 

I> Unit tests tell a developer that the code is _doing things right_; functional tests tell a developer that the code is _doing the right things_. 

It's a question of perspective. Unit tests are written from the programmer's point of view. Does the function or method return the correct result for given arguments? Functional tests, on the other hand, are written from the user's point of view. Does the software do what its _user_ needs it to do?

Both kinds of tests are important. If you are a professional programmer you need a user representative to write functional tests. If you are a domain-expert programmer [^domain] you can write both. 

In this chapter we'll tackle unit tests. 


## Speed

Unit tests should execute _fast_: developers often want to execute them even when still working on a project in order to make sure that they have not broken anything, or to find out what they broke. When executing the test suite takes too long it defeats the purpose.

Sometimes it cannot be avoided that tests take quite a while, for example when testing GUIs. In that case it might be an idea to create a group of tests that comprehend not all but just the most important ones. Those can then be executed while actually working on the code base while the full-blown test suite is only executed every now and then, maybe only before checking in the code.


## Preparing: helpers

The first thing we are going to do is to establish a number of helpers in `Tests` that the `Tester` class provides. We can simply call `Tester.EstablishHelpersIn` and provide a ref to the namespace hosting our test cases as right argument:

~~~
    )cs #
#
    Tester.EstablishHelpersIn #.Tests
    #.Tests.⎕nl 3
FailsIf                 
G                       
GoToTidyUp              
L                       
ListHelpers             
PassesIf                
Run                     
RunBatchTests           
RunBatchTestsInDebugMode
RunDebug                
RunThese                
∆Failed                 
∆Inactive               
∆LinuxOnly              
∆LinuxOrMacOnly         
∆LinuxOrWindowsOnly     
∆MacOnly                
∆MacOrWindowsOnly       
∆NoAcreTests            
∆NoBatchTest            
∆OK                     
∆WindowsOnly                
~~~

The helpers can be categorized:

* Those starting their names with a `∆` character are niladic functions that return a result. They act like constants in other programming languages. APL does not have constants, but they can be emulated with niladic functions. (Strictly speaking they are not helpers)
* Those starting their names with `Run` are used to run all or selected test cases in slightly different scenarios.
* `FailsIf`, `PassesIf` and `GoToTidyUp` are used for flow control. 
* Miscellaneous

Some of the helpers (`G`, `L` and `ListHelpers`) are just helpful while others, like all the `Run*` functions and the flow control functions, are essential. We need them to be around before we can execute any test case. The fact that we had to establish them with a function call upfront contradicts this. But there is an escape route: we add a line to the DYAPP:

~~~
...
Run #.MyApp.SetLX #.MyApp.GetCommandLineArg ⍬
leanpub-start_insert
Run #.Tester.EstablishHelpersIn #.Tests  
leanpub-end_insert
~~~

Of course we don't need this when DYAPP is supposed to assemble the workspace for a productive environment; we will address this problem later.

We will discuss all helpers in detail, and we start with the flow control helpers.


### Flow control helpers

Let's look at an example: `FailsIf` takes a Boolean right argument and returns either `0` in case the right argument is `1` or an empty vector in case the right argument is `0`:

~~~
      FailsIf 1
0
      FailsIf 0

      ⍴FailsIf 0
0
~~~

That means that the statement `→FailsIf 1` will jump to 0, exiting the function carrying the statement.

Since GoTo statements are rarely used these days because under most circumstances control structures are way better, it is probably worthwhile to mention that `→⍬` -- as well as `→''` -- makes the interpreter carry on with the next line. In other words the function just carries on. That's exactly what we want when the right argument of `FailsIf` is a `0` because in that case the test has not failed.

`PassesIf` is exactly the same thing but just with a negated argument: it returns a `1` when the right argument is `1` and an empty vector in case the right argument is `0`.

`GoToTidyUp` is a special case. It returns an empty vector in case the right argument is `0`. If the right argument is `1` it expects the function where it was called from to have a line that carries a label `∆TidyUp`; the line number of that label is then returned.

This is useful in case a test function needs to do some cleaning up, no matter whether it has failed or not. Imagine you need a temporary file for a test but want to delete it after carrying out the test case. In that case the bottom of your test function might look like this:

~~~
...
∆TidyUp:
    #.FilesAndDirs.DeleteFile tempFilename
~~~

When everything goes according to plan the function would eventually execute these lines anyway, but when a test case fails you need this:

~~~
    →GoToTidyUp expected≢result
~~~

Like `FailsIf` the test function would just carry on in case `expected≢result` returns a `0` but jump to the label `∆TidyUp` in case the test fails (=the condition is true).

But why are we using functions for all this anyway? We could do without, couldn't we? Yes, so far we could, but there is just one more thing. Stay with us...


## Writing unit tests


We have automated the way the helpers are established in `Tests`. Now we are ready to implement the first test case.

Utilities are a good place to start writing tests. Many utility functions are simply names assigned to common expressions. Others encapsulate complexity, making similar transformations of different arguments. We'll start with `map` in `#.Utilities`. We know by now that in general it works although even that needs to be confirmed by a test of course. What we don't know yet is whether it works under all circumstances. We also need to make sure that it complains when it is fed with inappropriate data. 

To make writing test cases as easy as possible you can ask `Tester` for providing a test case template.

~~~
    ⎕←⍪#.Tester.GetTestFnsTemplate
  R←Test_000(stopFlag batchFlag);⎕TRAP               
 ⍝ Model for a test function.                   
  ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N') 
  R←∆Failed                                     
                                                
 ⍝ Preconditions...                             
 ⍝ ...                                          
                                                
  →PassesIf 1≡1                                 
  →FailsIf 1≢1                                  
  →GoToTidyUp 1≢1                               
  R←∆OK                                         
                                                
 ∆TidyUp: ⍝ Clean up after this label           
           ⍝ ...                                
~~~

The template covers all possibilities, and we will discuss all of them. However, for the time being we want to keep it simple, so we will delete quite a lot:

~~~
:Namespace Tests
⎕IO←1 ⋄ ⎕ML←1
∇ R←Test_001(stopFlag batchFlag);⎕TRAP
 ⍝ Check the length of the left argument
  ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
  R←∆Failed     
  :Trap 5
      {}(⊂⎕A)##.Utilities.map'APL is great'
      →FailsIf 1
  :Else
      .
  :EndTrap     
  R←∆OK
∇

∇ {r}←GetHelpers
  r←##.Tester.EstablishHelpersIn ⎕THIS
∇

:EndNamespace
~~~

What we changed:

* We renamed the template from `Test_000` to `Test_001`.
* We described in line 1 as thoroughly as possible what the test case is doing. The reason is that this line is later the only way to tell this test case from any other. In other words, it is really important to get this right. By the way: if you cannot describe in a single line what the test case is doing it's most likely doing too much.
* We set `⎕TRAP` so that any error 999 will stop the interpreter with a deliberate error; we will soon see why and what for.
* We also localize `⎕TRAP` so that any error 999 has an effect only within the test function. In fact any other error than 999 is passed through with the `N` option in order to allow `⎕TRAP`s further up the stack to take control.
* We initialize the explicit result `R` by assigning the value returned by the niladic function `∆Failed`. That allows us to simply leave the function in case a test fails: the result will then tell.
* We trap the call to `map` which we expect to fail with a length error because we provide a scalar as left argument.
* In case there is no error we call the function `∆FailsIf` and provide a `1` as right argument. That makes `∆FailsIf` return a `0` and therefore leave `Test_001`.

You might have noticed that we address, say, `Utilities` with `#.Utilities` rather than `##.Utilities`. Making this a habit is a good idea: currently it does not make a difference, but when you later decide to move everything in `#` into, say, a namespace `#.Container` (you never know!) then `##.` would still work while `#.` wouldn't.

The `:Else` part is not ready yet; the full stop will prevent the test function from carrying on when we get there.

Note that we also added a function `GetHelpers` to the script. The reason is that the helpers will disappear as soon as we fix the `Test` script. And we are going to fix it whenever we change something or add a new test case. Therefore we need an easy way to get them back: `GetHelpers` to the rescue.

A> ### Ordinary namespaces versus scripted ones 
A>
A> There's a difference between an ordinary namespace and a scripted namespace: imagine you've called `#.Tester.EstablishHelpersIn` within an ordinary namespace. Now you change/add/delete test functions; that would have no effect on anything else in that namespace. In other words, the helpers would continue to exist.
A>
A> When you change a namespace script on the other hand the namespace is re-created from the script, and that means that our helpers will disappear because they are not a part of the `Tests` script.

Let's call our test case. We do this by running the `Run` method first:

~~~
Run
--- Tests started at 2017-03-14 12:08:42 on #.Tests ----------
* Test_001 (1 of 1) : Check the length of the left argument
 -------------------------------------------------------------
   1 test case executed
   1 test case failed
   0 test cases broken
~~~

That's what we expect. 

A> ### What is a test case?!
A> You might wonder how `Run` established what is a test case and what isn't: that's achieved by naming conventions. Any test function _must_ start their name with `Test_`. After that there are two possibilities:
A> 
A> 1. In the simple case there are one or more digits after the `_`; nothing but digits. Therefore these all qualify as test cases: `Test_1`, `Test_01`, `Test_001` and so on. `Test_01A` however does not.
A> 1. In case you have a large number of test cases you most probably want to group them in one way or another. You can add a group name after the first `_` and add a second `_` followed by one or more digits. Therefore `Test_map_1` is recognized as a test case, and so is `Test_Foo_9999`. `Test_Foo_Goo_1` however is not.

What if we want to look into a broken or failing test case? Of course in our current scenario -- which is extremely simple -- we could just trace into `Test_001` and find out what's going on, but if we take advantage of the many features the test framework is actually offering then we cannot do this (soon it will become clear why). However, there is a way to do this no matter whether the scenario is simple, reasonably complex or extremely complex: we call `RunDebug`:

~~~
RunDebug 0
--- Test framework "Tester" version 3.2.0 from 2017-03-24 -------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  ...not found
--- Tests started at 2017-03-14 12:16:00 on #.Tests -------------
SYNTAX ERROR
      . ⍝ Deliberate error
     ∧
      )si
#.Tests.Test_001[6]*
⍎
#.Tester.ExecuteTestFunction[6]
#.Tester.ProcessTestCases[6]
#.Tester.Run__[39]
#.Tester.RunDebug[17]
#.Tests.RunDebug[3]
Time of execution recorded on variable #.Tests.TestCasesExecutedAt: yyyy-mm-dd hh:mm:ss
Looking for a function "Cleanup"...
  ...not found
~~~

I> Note that there are INI files mentioned, and `Initial` and `Cleanup`. Ignore this for the time being; we will discuss this later on.

It stopped in line 6. Obviously the call to `FailsIf` has something to do with this, and so has the `⎕TRAP` setting, because apparently that's where the "Deliberate error" comes from. Indeed this is the case: all three flow control functions, `FailIf`, `PassesIf` and `GoToTidyUp` check whether they are running in debug mode and if that is the case then rather returning a result that indicates a failing test case they `⎕SIGNAL 999` which is then caught by the `⎕TRAP` which in turn first prints `⍝ Deliberate error` to the session and then hands over control to the user. You can now investigate variables or start the Tracer etc. in order to investigate why the test case failed.

The difference is the first of the two flags provided as right argument to the test function: `stopFlag`. This is `0` when `Run` executes the test cases, but it is `1` when `RunDebug` is in charge. The three flow control functions `FailsIf`, `PassesIf` and `GoToTidyUp` all honour `stopFlag` - that's how it works.

Now sometimes you don't want the test function to go to the point where the error actually appears, for example in case the test function does a lot of precautioning, and you want to check this because there might be something wrong with it, causing the failure. Note that so far we passed a `0` as right argument to `RunDebug`. If we pass a `1` instead then the test framework would stop just before it would start executing the test case:

~~~
      RunDebug 1
--- Test framework "Tester" version 3.2.0 from 2017-03-24 -------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  ...not found      
--- Tests started at 2017-03-14 13:29:24 on #.Tests -------------

ExecuteTestFunction[6]
      )si
#.Tester.ExecuteTestFunction[6]*
#.Tester.ProcessTestCases[6]
#.Tester.Run__[39]
#.Tester.RunDebug[17]
#.Tests.RunDebug[3]
Time of execution recorded on variable #.Tests.TestCasesExecutedAt: yyyy-mm-dd hh:mm:ss
Looking for a function "Cleanup"...
  ...not found
~~~

You can now trace into `Test_001`.

Now what if you've executed, say, 300 test cases with `Run`, and just one failed, number 289, say? You expected them all to succeed but since one did not you need to check on this one. Calling `Run` as well as `RunDebug` always would execute _all_ test cases found. The function `RunThese` allow you to run just the specified test function(s):

~~~
      RunThese 289
~~~

This would run just test case number 289. If you specify it as `¯289` it would stop just before actually executing the test case.

Let's make sure that `map` is checking its left argument:

~~~
:Namespace Utilities
      map←{
leanpub-start-insert
          (,2)≢⍴⍺:'Left argument is not a two-element vector'⎕SIGNAL 5
leanpub-end-insert
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }
:EndNamespace
~~~

Now enter `)reset` and then run `RunDebug 1`. Trace into `Test_001` and watch whether now any error 5 (LENGTH ERROR) is trapped, You should end up on line 8 of `Test_001`. Exchange the full stop by:

~~~
    →PassesIf'Left argument is not a two-element vector'≡⊃⎕DM
~~~

This checks whether the error message is what we expect. Trace through the test function and watch what it is doing. After having left the test function you may click the green triangle in the Tracer ("Continue execution of all threads").

We have discussed the functions `Run`, `RunDebug` and `RunThese`. That leaves `RunBatchTests` and `RunBatchTestsInDebugMode`; what are they for? Imagine a test that would either require an enormous amount off effort to implement or alternatively you just build something up and then ask the human in front of the monitor: "Does this look alright?". That's certainly _not_ a batch test case because it needs a human sitting in front of the monitor. If you know upfront that there won't be a human paying attention then you can prevent non-batch test cases from being executed by calling either `RunBatchTests` or `RunBatchTestsInDebugMode`.

But how does this work? We already learned that `stopFlag`, the first of the two flags passed to any test case, is ruling whether any errors are trapped or not. The second flag is called `batchFlag`, and that gives you an idea what it's good for. If you have a test which interacts with a user (=cannot run without a human) then your test case would typically look like this:

~~~
 R←Test_001(stopFlag batchFlag);⎕TRAP
⍝ Check ...
 ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
 R←∆Failed
 :If batchFlag
     ⍝ perform the test
     R←∆OK
 :Else
     R←∆NoBatchTest
 :EndIf
~~~

The test function checks the `batchFlag` and tells via the explicit result that it did not execute because it is not suitable for batch testing.

One can argue whether the test case we have implemented makes much sense, but it allowed us to investigate the basic features of the test framework. We are now ready to investigate the more sophisticated features.

Of course we also need a test case that checks whether `map` does what it's supposed to do when appropriate arrays are passed as arguments, therefore we add this to `Tests`:

~~~
Namespace Tests

∇ R←Test_001(stopFlag batchFlag);⎕TRAP
...
∇

∇ R←Test_002(stopFlag batchFlag);⎕TRAP;Config;MyLogger
  ⍝ Check whether `map` works fine with appropriate data
  ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
  R←∆Failed
  (Config MyLogger)←##.MyApp.Initial ⍬
  →FailsIf'APL IS GREAT'≢Config.Accents ##.Utilities.map ##.APLTreeUtils.Uppercase'APL is great'
  →FailsIf'UßU'≢Config.Accents ##.Utilities.map ##.APLTreeUtils.Uppercase'üßÜ'
  R←∆OK
∇
...
~~~	

Now we try to execute this test cases:

~~~
      #.Tests.GetHelpers
      RunThese 2
--- Test framework "Tester" version 3.2.0 from 2017-03-24 ----------------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  ...not found
--- Tests started at 2017-03-22 15:37:12 on #.Tests ----------------------
  Test_002 (1 of 1) : Check whether `map` works fine with appropriate data
 -------------------------------------------------------------------------
   1 test case executed
   0 test cases failed
   0 test cases broken
~~~

Works fine. Excellent.

Now let's make sure that the work horse is doing okay; for this we add another test case:

~~~
:Namespace Tests
...
    ∇ R←Test_002(stopFlag batchFlag);⎕TRAP
...
    ∇ R←Test_003(stopFlag batchFlag);⎕TRAP;Config;MyLogger
    ⍝ Test whether `TxtToCsv` handles a non-existing file correctly
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
      rc←##.MyApp.TxtToCsv 'This_file_does_not_exist'
      →FailsIf ##.MyApp.EXIT.SOURCE_NOT_FOUND≢rc
      R←∆OK
    ∇
...
~~~

Let's call this test:

~~~
      )CS #.Tests
#.Tests
      GetHelpers
      RunThese 3
...      
VALUE ERROR
TxtToCsv[4] MyLogger.Log'Source: ',fullfilepath
            ∧
~~~					  

`MyLogger` is undefined. In the envisaged use in production, it is defined by and local to `StartFromCmdLine`. That design followed Occam's Razor[^occam]: (entities are not to be needlessly multiplied) in keeping the log object in existence only while needed. But it now prevents us from testing `TxtToCsv` independently. So we'll refactor `Log` to be a child of `#.MyApp`, created by `Start`:

~~~
:Namespace Tests
...
    ∇ R←Test_003(stopFlag batchFlag);⎕TRAP
    ⍝ Test whether `TxtToCsv` handles a non-existing file correctly
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
leanpub-start-insert      
      ##.MyApp.(Config MyLogger)←##.MyApp.Initial ⍬
leanpub-end-insert      
      rc←##.MyApp.TxtToCsv 'This_file_does_not_exist'
      →FailsIf ##.MyApp.EXIT.SOURCE_NOT_FOUND≢rc
      R←∆OK
    ∇      
...
~~~	  

Note that now both `Config` and `MyLogger` exist within `MyApp`, not in `Tests`. Therefore we don't even have to keep them local within `Test_003`. They are however not part of the script, therefore they will cease to exist as soon as the script `Tests` is fixed again, very much like the helpers. 

Let's try again:

~~~
      RunThese 3
--- Test framework "Tester" version 3.2.0 from 2017-03-24 -------------------------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  ...not found      
--- Tests started at 2017-03-22 15:56:41 on #.Tests -------------------------------
  Test_003 (1 of 1) : Test whether `TxtToCsv` handles a non-existing file correctly
 ----------------------------------------------------------------------------------
   1 test case executed
   0 test cases failed
   0 test cases broken
Time of execution recorded on variable #.Tests.TestCasesExecutedAt: yyyy-mm-dd hh:mm:ss
Looking for a function "Cleanup"...
  ...not found   
~~~

Clearly we need to have one test case for every result the function `TxtToCsv` might return but we leave that as an exercise to you. We have more important test cases to write: we want to make sure that whenever we create a new version of the EXE it will keep working.

Time for a new version of MyApp. Make a copy of `Z:\code\v08` as `Z:\code\v09`.

First we rename the test functions we have so far: 

* `Test_001` becomes `Test_map_01` 
* `Test_002` becomes `Test_map_02` 
* `Test_003` becomes `Test_TxtToCsv_01` 

This way we group all `map`-related functions together. The new test cases we are about to add will be named `Test_exe_01` etc. For our application we could get  away without grouping, but once you have more than, say, 20 test cases grouping is a must.


### The "Initial" function

For testing the EXE we need a folder where we can store files temporarily. We add a function `Initial` to the `Test` script:

~~~
:Namespace Tests
⎕IO←1 ⋄ ⎕ML←1
 ∇ Initial;list;rc
   ∆Path←##.FilesAndDirs.GetTempPath,'\MyApp_Tests'
   ##.FilesAndDirs.RmDir ∆Path
   'Create!'##.FilesAndDirs.CheckPath ∆Path
   list←↑##.FilesAndDirs.Dir'..\..\texts\en\*.txt'
   rc←list ##.FilesAndDirs.CopyTo ∆Path,'\'
   ⍎(0∨.≠⊃rc)/'.'
 ∇
...
~~~

Before the `Tester` framework executes any test cases it first checks whether there is a function `Initial`. If that's the case it executes `Initial`. Therefore `Initial` is the ideal place to get things done that all test cases rely on. 

`Initial` does not have to return a result but if it does it must be a Boolean. For "success" it should return a `1` and otherwise a `0`. If it does return `0` then no test cases are executed but if there is a function `Cleanup` it will be executed. Therefore `Cleanup` should be ready to clean up in case `Initial` was partly successful. 

`Initial` may or may not accept a right argument. If it does it will be fed with a namespace that holds all the parameters.

What we do in `Initial`:

* First we create a global variable `∆Path` which holds a path to a folder `MyApp_Tests` within the Windows temp folder.
* We then remove that folder in case it still exists from any previously failing test cases.
* We then create it.
* We ask for a list of all text files in the `texts\en\` folder.
* We copy all those files over to our temporary test folder.
* Finally we check the return code of the copy operation; if any of them is not OK we execute a full stop; there is no point in carrying on in such a case.

A> What if you need to initialize something (say a database connection) but it is somehow different depending on what machine the tests are exected on (IP address, user-id, password...)?
A> The test framework tries to find two different INI files in the current directory:
A> First it looks for `testcase_{computername}.INI`. If it cannot find this then it tries to find `testcase.INI`. If it finds any of them then it instantiates the `IniFile` class as `INI` on these INI files within the namespace that hosts your test cases.

Now we are ready to test the EXE: create it from scratch. Our first test case will process "Ulysses":

~~~
:Namespace Tests
...
    ∇ R←Test_exe_01(stopFlag batchFlag);⎕TRAP;rc
      ⍝ Process a single file with .\MyApp.exe
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
      ⍝ Precautions:
      ##.FilesAndDirs.DeleteFile⊃##.FilesAndDirs.Dir ∆Path,'\*.csv'
      rc←##.Execute.Application'MyApp.exe ',∆Path,'\ulysses.txt'
      →GoToTidyUp ##.MyApp.EXIT.OK≠⊃rc
      →GoToTidyUp~##.FilesAndDirs.Exists ∆Path,'\ulysses.csv'
      R←∆OK
     ∆TidyUp:
      ##.FilesAndDirs.DeleteFile⊃##.FilesAndDirs.Dir ∆Path,'\*.csv'
    ∇
...
~~~

Notes:

* First we make sure that there are no CSV files in `∆Path`.
* Then we call the EXE and pass the filename of "Ulysses" as a command line parameter.
* We check the return code and jump to `∆TidyUp` in case it's not what we expect.
* We then check whether there is now a file "Ulysses.cvs" in `∆Path`.
* Finally we clean up and delete (again) all CSV files in `∆Path`.

Let's run our new test case:

~~~
      GetHelpers
      RunThese 'exe'
--- Test framework "Tester" version 3.2.0 from 2017-03-24 -----
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  ...not found
--- Tests started at 2017-03-22 20:07:20 on #.Tests -----------
  Test_exe_01 (1 of 1) : Process a single file with .\MyApp.exe
 --------------------------------------------------------------
   1 test case executed
   0 test cases failed
   0 test cases broken
Time of execution recorded on variable #.Tests.TestCasesExecutedAt in: yyyy-mm-dd hh:mm:ss
Looking for a function "Cleanup"...
  ...not found   
~~~

We need one more test case:

~~~
:Namespace Tests
...
∇ R←Test_exe_01(stopFlag batchFlag);⎕TRAP;rc
...
∇ R←Test_exe_02(stopFlag batchFlag);⎕TRAP;rc;listCsvs
  ⍝ Process all TXT files in a certain directory
  ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
  R←∆Failed
  ⍝ Precautions:
  ##.FilesAndDirs.DeleteFile⊃##.FilesAndDirs.Dir ∆Path,'\*.csv'
  rc←##.Execute.Application'MyApp.exe ',∆Path,'\'
  →GoToTidyUp ##.MyApp.EXIT.OK≠⊃rc
  listCsvs←⊃##.FilesAndDirs.Dir ∆Path,'\*.csv'
  →GoToTidyUp 1≠⍴listCsvs
  →GoToTidyUp'total.csv'≢##.APLTreeUtils.Lowercase⊃,/1↓⎕NPARTS⊃listCsvs
  R←∆OK
 ∆TidyUp:
  ##.FilesAndDirs.DeleteFile⊃##.FilesAndDirs.Dir ∆Path,'\*.csv'
∇
...
~~~

This one will process _all_ TXT files in `∆Path` and create a file `total.csv`. We check that this is the case and we are done. Almost: in a real world application we most likely would also check for a path that contains spaces in its name. We don't do this, instead we execute the full test suite:

~~~
      GetHelpers
      ⎕←⊃Run
--- Test framework "Tester" version 3.2.0 from 2017-03-24 ----------------------------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  ...not found      
--- Tests started at 2017-03-22 20:16:26 on #.Tests ---------------------------------------
  Test_TxtToCsv_03 (1 of 5) : Test whether `TxtToCsv` handles a non-existing file correctly
  Test_exe_01 (2 of 5)      : Process a single file with .\MyApp.exe
  Test_exe_02 (3 of 5)      : Process all TXT files in a certain directory
  Test_map_01 (4 of 5)      : Check the length of the left argument
  Test_map_02 (5 of 5)      : Check whether `map` works fine with appropriate data  
 ------------------------------------------------------------------------------------------
   5 test cases executed
   0 test cases failed
   0 test cases broken
Time of execution recorded on variable #.Tests.TestCasesExecutedAt in: yyyy-mm-dd hh:mm:ss
Looking for a function "Cleanup"...
  ...not found   
0   
~~~

Note that the function `Run` prints its findings to the session but also returns a result. That's a two-item vector:

1. Is a return code. `0` means "okay".
2. Is a vector of vectors that is identical with what's printed to the session.


### Cleaning up

Although we have been careful and made sure that every single test case cleans up after itself (in particular those that failed), we have not removed the directory `∆Path` points to. We can achieve this by introducing a function `Cleanup`:

~~~
:Namespace Tests
...
∇ Cleanup
  :If 0<⎕NC'∆Path'
      ##.FilesAndDirs.RmDir ∆Path
      ⎕EX '∆Path'
  :EndIf
∇

:EndNamespace
~~~

This function checks whether a global `∆Path` exists. If that's the case then it is removed and the global variable deleted. The `Tester` framework checks whether there is a function `Cleanup`. If that's the case the function is executed. The function must be niladic and either not return a result or a shy result.


### Markers

We've already mentioned elsewhere that it is useful to mark code in particular ways, like `⍝FIXME⍝` or `⍝TODO⍝`. It is an excellent idea to have a test case that checks for such markers. Before something makes it to a customer such strings should probably be removed from the code.

### The "L" and "G" helpers

Now that we have two groups we can take advantage of the `G` and the `L` helpers:

~~~
      G
exe
map
      L''
 Test_exe_01       Process a single file with .\MyApp.exe                      
 Test_exe_02       Process all TXT files in a certain directory                  
 Test_map_01       Check the length of the left argument                         
 Test_map_02       Check whether `map` works fine with appropriate data          
 Test_TxtToCsv_03  Test whether `TxtToCsv` handles a non-existing file correctly 
      L'ex'
 Test_exe_01  Process a single file with .\MyApp.exe
 Test_exe_02  Process all TXT files in a certain directory    
~~~


## TestCasesExecutedAt

Whenever the test cases were executed `Tester` notifies the time on a global variable `TestCasesExecutedAt` in the hosting namespace. This can be used in order to find out whether part of the code has been changed since the last time the cases were executed. However, in order to do this you have to make sure that the variable is either saved somewhere or added to the scripts `Tests`.


## Conclusion

We have now a test suite available that allows us at any stage to call it in order to make sure that everything still works. This is invaluable.


## The sequence of tests

We will discover later on that the sequence in which test cases are executed might have on impact on whether they fail or not, even if you try to avoid any dependencies. That doesn't mean that you don't need to pay attention! In fact you should always aim for any test case to be completely independent from any other test case.


## Testing in different versions of Windows 

When you wrote for yourself, your code needed to run only on the version of Windows you use yourself. To ship it as a product you will have to support it on the versions your customers use. 

You need to pick the versions of Windows you will support, and run your tests on all those versions. If you are not already a fan of automated tests, you are about to become one. 

For this you will need either 

* a test machine for each OS (version of Windows) you support; or
* a test machine and VM (virtual-machine) software 

What VM software should you use? One of us has had good results with _Workstation Player_ from [VMware](http://www.vmware.com).

If you use VM software you will save a _machine image_ for each OS. Include in each machine image your preferred development tools, such as text editor and Dyalog APL. You will need to keep each machine image up to date with fixes and patches to its OS and your tools. 

The machine images are large, about 10 GB each. So you want several hundred gigabytes of fast SSD (solid-state drive) on your test machine. With this you should be able to get a machine image loaded in 20 seconds or less. 


## Testing APLTree modules

By now we are using quite a number of modules from the APLTree project. Shouldn't we test them as well? After all if they break our application will stop working! Well, there are pros and cons:

Pro
: The modules have their own unit tests, and those are exhaustive. An update is published only after all the test cases have passed.

: The modules are constantly adapted to new demands or changes in the environment etc. Therefore a new version of Windows or Dyalog won't stop them from working, although you need to allow some time for this to happen. 

Contra
: We cannot know whether those test cases cover the same environment(s) (different versions of Windows, different versions of Dyalog, domain-managed network or not, network drives or not, multi-threaded versus single-threaded, you name it) our application will run in. 

⍝TODO⍝ `↓↓↓` That's only true for most but not for all modules: some need files, a special environment etc.. We need to think about this when we consider the future role of GitHub for the APLTree project.

That clearly means that we should incorporate the tests those modules come with into our own test suite, although we are sure that not too many people/companies using modules from the APLTree library are actually doing this. 

Anyway, it's not difficult to do at all: every module has a workspace saved on GitHub that comes with all that's needed in order to carry out the test cases. All it requires it starting Dyalog (_your_ version of Dyalog that is), load that workspace, execute `#.TestCases.Run` (because all modules of the APLTree library host their test cases in an ordinary (non-scripted) namespace, catch the result and return it with `⎕OFF` to the calling environment. As long as that is `0` that's all what's required.

If it's not `0` you start your version of Dyalog, load the workspace of the module with one or more failing test cases and run `#.TestCases.RunDebug 0` in order to investigate what went wrong. 


[^beck]: Kent Beck, in conversation with one of the authors.

[^string]: APL has no _string_ datatype. We use the word as a casual synonym for _character vector_.

[^domain]: An expert in the domain of the application rather than an expert programmer, but who has learned enough programming to write the code. 

[^occam]: _Non sunt multiplicanda entia sine necessitate._
