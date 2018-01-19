1{:: encoding="utf-8" /}
[parm]:title='Testing'

# Testing – the sound of breaking glass

Our application here is simple – just count letter frequency in text files. 

All the other code has been written to configure the application, package it for shipment, and to control how it behaves when it encounters problems. 

Developing code refines and extends it. We have more developing to do. Some of that developing might break what we already have working. Too bad. No one’s perfect. 

But we would at least like to know when we’ve broken something – to hear the sound of breaking glass behind us. Then we can fix the error before going any further. 

In our ideal world we would have a team of testers continually testing and retesting our latest build to see if it still does what it’s supposed to do. The testers would tell us if we broke anything. In the real world we have programs – tests – to do that. 

What should we write tests for? “Anything you think might break,” says Kent Beck[^beck], author of _Extreme Programming Explained_. 
We’ve already written code to allow for ways in which the file system might misbehave. We should write tests to discover if that code works. We’ll eventually discover conditions we haven’t foreseen and write fixes for them. Then those conditions too will join the things we think might break, and get added to the test suite. 


## Why you want to write tests


### Notice when you break things

Some functions are more vulnerable than others to being broken under maintenance. Many functions are written to encapsulate complexity, bringing a common order to a range of different arguments. 

For example, you might write a function that takes as argument any of a string[^string], a vector of strings, a character matrix or a matrix of strings. 

If you later come to define another case, say, a string with embedded line breaks, it’s easy enough inadvertently to change the function’s behaviour with the original cases. 

If you have tests that check the function’s results with the original cases, it’s easy to ensure your changes don't change the results unintentionally. 


### More reliable than documentation

No, tests don’t replace documentation. They don’t convey your intent in writing a class or function. They don’t record your ideas for how it should and should not be used, references you consulted before writing it, or thoughts about how it might later be improved.

But they do document with crystal clarity what it is _known_ to do. In a naughty world in which documentation is rarely complete and even less often revised when the code is altered, it has been said the _only_ thing we know with certainty about any given piece of software is what tests it passes. 


### Understand more 

Test-Driven Design (TDD) is a high-discipline practice associated with Extreme Programming. TDD tells you to write the tests _before_ you write the code. Like all such rules, we recommend following TDD – thoughtfully. 

The reward from writing an automated test is not _always_ worth the effort. But it is a very good practice and we recommend it given that the circumstances are right. 

For example, if you know from the start _exactly_ what your program is supposed to do then TDD is certainly an option. If you start prototyping in order to find out what the user actually wants the program to do, TDD is no option at all.

If you are writing the first version of a function, writing the tests first will clarify your understanding of what the code should be doing. It will also encourage you to consider boundary cases or edge conditions: for example, how should the function above handle an empty string? A character scalar? 

TDD first tests your understanding of your task. If you can't define tests for your new function, perhaps you’re not ready to write the function either. 

If you are modifying an existing function, write new tests for the new things it is to do. Run the revised tests and see that the code fails the new tests. If the unchanged code _passes_ any of the new tests… review your understanding of what you’re trying to do! 


## Readability

Reading and understanding APL code is more difficult than in other programming language due to the higher abstraction level and the power of APL’s primitives. However, as long as you have at least one example with correct arguments, it’s always possible to decipher the code. 

Things can become very nasty indeed if an application crashes because inappropriate data arrives at your function. However, before you can figure out whether the data is appropriate or not you need to understand the code – a chicken-egg problem.

That’s when test cases can be very useful as well, because they demonstrate which data a function is expected to process. It also emphasises why it is important to have test cases for all the different types of data (or parameters) a function is supposed to process. In this respect test cases should be exhaustive.


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

In principle, `TxtToCsv` _could_ be written in purely functional style. References to classes and namespaces `#.HandleError`, `#.APLTreeUtils`, `#.FilesAndDirs`, `EXIT`, and `#.ErrorParms` could all be passed to it as arguments. 

If those references ever varied – for example, if there were an alternative namespace `ReturnCodes` sometimes used instead of `EXIT` – that might be a useful way to write `TxtToCsv`. 

But as things are, cluttering up the function’s _signature_ – its name and arguments – with these references harms rather than helps readability. It is an example of the cure being worse than the disease. 

You shouldn’t write _everything_ in pure functional style but the closer you stick to it, the better your code will be, and the easier to test. Functional style goes hand in hand with good abstractions, and ease of testing. 


## Why you don’t want to write tests

There is nothing magical about tests. Tests are just more code. The test code needs maintaining like everything else. If you refactor a portion of your application code, the associated tests need reviewing – and possibly revising – as well.

In programming, the number of bugs is generally a linear function of code volume. Test code is no exception to this rule. Your tests are both an aid to development and a burden on it. 

You want tests for everything you think might break, but no more tests than you need. 

Beck’s answer – test anything you think might break – provides useful insight. Some expressions are simple enough not to need testing. If you need the indexes of a vector of flags, you can _see_ that `{⍵/⍳≢⍵}` [^where] will find them. It’s as plain as `2+2` making four. You don’t need to test that. 

APL’s scalar extension and operators such as _outer product_ allow you to replace nested loops (a common source of error) with expressions which don’t need tests. The higher level of abstraction enabled by working with collections allows not only fewer code lines but also fewer tests. 

Time for a new version of MyApp. Make a copy of `Z:\code\v07` as `Z:\code\v08`.


## Setting up the test environment

We’ll need the `Tester` class from the APLTree library. And a namespace of tests, which we’ll dub `#.Tests`. 

Create `Z:\code\v08\Tests.dyalog`:

~~~
    :Namespace Tests
    
    :EndNamespace
~~~

Save this as `Z:\code\v08\Tests.dyalog` and include both scripts in the DYAPP:

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

Run the DYAPP to build the workspace. In the session you might want to execute `]ADoc #.Tester` to see the documentation for the Tester class.


## Unit and functional tests 

I> Unit tests tell a developer that the code is _doing things right_; functional tests tell a developer that the code is _doing the right things_. 

It’s a question of perspective. Unit tests are written from the programmer’s point of view. Does the function or method return the correct result for given arguments?

Functional tests, on the other hand, are written from the user’s point of view. Does the software do what its _user_ needs it to do?

Both kinds of tests are important. If you are a professional programmer you need a user representative to write functional tests. If you are a domain-expert programmer [^domain] you can write both. 

In this chapter we'll tackle unit tests. 


## Speed

Unit tests should execute _fast_: developers often want to execute them even when still working on a project in order to make sure that they have not broken anything, or to find out what they broke. If executing the test suite takes too long it defeats the purpose.

Sometimes it cannot be avoided that tests take quite a while, for example when testing GUIs. In that case it might be an idea to create a group of tests that comprehend not all, but just the most important ones. 

Those can then be executed while actually working on the code base while the full-blown test suite is only executed every now and then, maybe only before checking in the code.


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

Some of the helpers (`G`, `L` and `ListHelpers`) are just helpful while others, like all the `Run*` functions and the flow control functions, are essential. We need them to be around before we can execute any test case. 

The fact that we had to establish them with a function call upfront contradicts this. But there is an escape route: we add a line to the DYAPP:

~~~
...
Run #.MyApp.SetLX ⍬
leanpub-start-insert
Run #.Tester.EstablishHelpersIn #.Tests  
leanpub-end-insert
~~~

Of course we don’t need this when the DYAPP is supposed to assemble the workspace for a productive environment; we will address this problem later.

We will discuss all helpers in detail, and we start with the flow control helpers.


### Flow control helpers

Let’s look at an example: `FailsIf` takes a boolean right argument and returns either `0` in case the right argument is `1` or an empty vector in case the right argument is `0`:

~~~
      FailsIf 1
0
      FailsIf 0

      ⍴FailsIf 0
0
~~~

That means that the statement `→FailsIf 1` will jump to 0, exiting the function carrying the statement.

Since GoTo statements are rarely used these days because under most circumstances control structures are far better, it is probably worthwhile to mention that `→⍬` -- as well as `→''` -- makes the interpreter carry on with the next line. 

In other words the function just carries on. That’s exactly what we want when the right argument of `FailsIf` is a `0` because in that case the test has not failed.

`PassesIf` is exactly the same thing but just with a negated argument: it returns a `0` when the right argument is `0` and an empty vector in case the right argument is `1`.

`GoToTidyUp` is a special case. It returns an empty vector when the right argument is `0`. If the right argument is `1` by convention the function that calls it has a line labelled `∆TidyUp`; the line number of that label is then returned.

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

But why are we using functions for all this anyway? We could do without, couldn’t we? Yes, so far we could, but there is just one more thing. 


## Writing unit tests

We have automated the way the helpers are established in `Tests`. Now we are ready to implement the first test case.

Utilities are a good place to start writing tests. Many utility functions are simply names assigned to common expressions. Other utilities encapsulate complexity, making similar transformations of different arguments. 

We’ll start with `map` in `#.Utilities`. We know by now that in general it works although even that needs confirmation by a test of course. What we don’t know yet is whether it works under all circumstances. We also need to ensure it complains when given inappropriate arguments. 

To make writing test cases as easy as possible you can ask `Tester` to provide a test case template.

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

The template covers all possibilities, and we will discuss all of them. However, for the time being we want to keep it simple, so we will delete quite a lot and also add three more functions:

~~~
:Namespace Tests
⎕IO←1 ⋄ ⎕ML←1
∇Initial
  U←##.Utilities ⋄ F←##.FilesAndDirs ⋄ A←##.APLTreeUtils
∇
∇ R←Test_001(stopFlag batchFlag);⎕TRAP
 ⍝ Is the length of the left argument of the `map` function checked?
  ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
  R←∆Failed     
  :Trap 5
      {}(⊂⎕A)U.map'APL is great'
      →FailsIf 1
  :Else
      .
  :EndTrap     
  R←∆OK
∇
∇ {r}←GetHelpers
  r←##.Tester.EstablishHelpersIn ⎕THIS
∇
∇ Cleanup dummy
  ⎕EX¨'AFU'
∇
:EndNamespace
~~~

What we changed:

* We renamed the template from `Test_000` to `Test_001`.

* We described in line 1 as thoroughly as possible what the test case is doing. The reason is that this line is later the only way to tell this test case from any other. 

  In other words, it is really important to get this right. And if you cannot describe in a single line what the test case is doing, it may be doing too much.

* We set `⎕TRAP` so that any error 999 will stop the interpreter with a deliberate error; we will soon see why and what for.

* We also localise `⎕TRAP` so that any error 999 has an effect only within the test function. In fact, any error other than 999 is passed through with the `N` option in order to allow traps further up the stack to take control.

* We initialise the explicit result `R` by assigning the value returned by the niladic function `∆Failed`. That allows us simply to leave the function in case a test fails: the result will then tell.

* We trap the call to `map`, which we expect to fail with a length error because we provide a scalar as left argument.

* In case there is no error we call the function `∆FailsIf` and provide a `1` as right argument. That makes `∆FailsIf` return a `0` and therefore leave `Test_001`.


You might have noticed we address, say, `Utilities` with `##.Utilities` rather than `#.Utilities`. Making this a habit is a good idea: currently it does not make a difference, but when you later decide to move everything in `#` into, say, a namespace `#.Container` (you never know!) then `##.` would still work while `#.` wouldn't.

The `:Else` part is not ready yet; the full stop will prevent the test function from carrying on when we get there.

Notes:

* We also added a function `GetHelpers` to the script. The reason is that the helpers will disappear as soon as we fix the `Test` script. And we are going to fix it whenever we change something or add a new test case. Therefore we need an easy way to get them back: `GetHelpers` to the rescue.

* The function `Initial` will be executed by the test framework before any test function is executed. This can be used to initialise stuff that all (or many) test cases need. Here we establish the references `A` (for the `APLTreeUtils` module), `F` (for the `FilesAndDirs` module) and `U` (for the `Utilities` module). 

  `Initial` relies on naming conventions; if there is a function in scope with that name, it will be executed. More later.

* The function `Cleanup` will be executed by the test framework after all test functions have been executed. This can be used to clean up stuff that’ no longer needed. Here we delete the references `A`, `F` and `U`. More later.


A> # Ordinary namespaces versus scripted ones 
A>
A> There’s a difference between an ordinary namespace and a scripted namespace: imagine you've called `#.Tester.EstablishHelpersIn` within an ordinary namespace. 
A>
A> Now you change/add/delete test functions; that would have no effect on anything else in that namespace. In other words, the helpers would continue to exist.
A>
A> When you change a namespace script on the other hand the namespace is re-created from the script, and that means that our helpers will disappear because they are not a part of the `Tests` script.

Let’s call our test case. We do this by running the `Run` method first:

~~~
Run
--- Test framework "Tester" version 3.5.0 from 2017-07-16 ---------------------------------
Searching for INI file Testcases.ini
  ...not found
Searching for INI file testcases_APLTEAM2.ini
  ...not found
Looking for a function "Initial"...
  "Initial" found and successfully executed
--- Tests started at YYYY-MM-DD hh:mm:ss on #.Tests ---------------------------------------
# Test_001 (1 of 1) : Is the length of the left argument of the `map` function checked?
 ------------------------------------------------------------------------------------------
   1 test case executed
   0 test cases failed
   1 test case broken
Time of execution recorded on variable #.Tests.TestCasesExecutedAt in: YYYY-MM-DD hh:mm:ss
Looking for a function "Cleanup"...
  Function "Cleanup" found and executed.
*** Tests done
~~~

That’s what we expect. 

I> Note that there are INI files mentioned. Ignore this for the time being; we will discuss this later on.

A> # What is a test case?!
A> You might wonder how `Run` established what is a test case and what isn’t: that’s achieved by naming conventions. Al test functions start their names with `Test_`. After that there are two possibilities:
A> 
A> 1. In the simple case the `_` is followed by nothing but digits. All these qualify as test cases: `Test_1`, `Test_01`, `Test_001` and so on. (`Test_01A` however does not.)
A> 1. If you have a large number of test cases you most probably want to group them. You can insert a group name between two underscores, followed by one or more digits. So `Test_map_1` is recognized as a test case, and so is `Test_Foo_9999`. `Test_Foo_Goo_1` however is not.

What if we want to look into a broken or failing test case? Of course in our current scenario – which is extremely simple – we could just trace into `Test_001` and find out what’s going on, but if we take advantage of the many features the test framework offers, we cannot do this. (Soon to become clear why.) 

However, there is a way to do this no matter whether the scenario is simple, reasonably complex or extremely complex: we call `RunDebug`:

~~~
RunDebug 0
--- Test framework "Tester" version 3.6.0 from  -------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  "Initial" found and successfully executed
--- Tests started at YYYY-MM-DD hh:mm:ss on #.Tests -------------
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
~~~

It stopped in line 6. Obviously the call to `FailsIf` has something to do with this, and so has the `⎕TRAP` setting, because apparently that’s where the “Deliberate error” comes from. 

This is indeed the case. All three flow-control functions, `FailIf`, `PassesIf` and `GoToTidyUp` check whether they are running in debug mode; if so, rather than return a result that indicates a failing test case, they `⎕SIGNAL 999`, which is then caught by the `⎕TRAP`, which in turn first prints `⍝ Deliberate error` to the session and then hands over control to the user. 

You can now investigate variables or start the Tracer, etc. to investigate the problem.

The difference between `Run` and `RunDebug` is the setting of the first of the two flags provided as right argument to the test function: `stopFlag`. This is `0` when `Run` executes the test cases, but it is `1` when `RunDebug` is in charge. The three flow-control functions `FailsIf`, `PassesIf` and `GoToTidyUp` all honour `stopFlag` – that’s how it works.

Now sometimes you don’t want the test function to go to the point where the error actually appears, for example if the test function does a lot of precautioning, and you want to check this upfront because there might be something wrong with it, causing the failure. 

Note that so far we passed a `0` as right argument to `RunDebug`. If we pass a `1` instead, then the test framework would stop just before executing the test case:

~~~
      RunDebug 1
--- Test framework "Tester" version 3.6.0 from YYYY-MM-DD -------
Searching for INI file Testcases.ini
  ...not found
Searching for INI file testcases_APLTEAM2.ini
  ...not found
Looking for a function "Initial"...
  "Initial" found and successfully executed
--- Tests started at YYYY-MM-DD hh:mm:ss on #.Tests -------------

ExecuteTestFunction[6]
      )si
#.Tester.ExecuteTestFunction[6]*
#.Tester.ProcessTestCases[6]
#.Tester.Run__[39]
#.Tester.RunDebug[17]
#.Tests.RunDebug[3]
~~~

You could now trace into `Test_001` and investigate. Instead, enter `→0`. You should see something like this: 

~~~
* Test_001 (1 of 1) : Is the length of the left argument of the `map` function checked?
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
   1 test case executed                                                                                                                                                    
   1 test case failed                                                                                                                                                      
   0 test cases broken                                                                                                                                                     
Time of execution recorded on variable #.Tests.TestCasesExecutedAt in: YYYY-MM-DD hh:mm:ss
Looking for a function "Cleanup"...
  Function "Cleanup" found and executed.
*** Tests done
~~~

Let’s have `map` check its left argument:

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

Now run `RunDebug 1`. Trace into `Test_001` and watch whether now any error 5 (LENGTH ERROR) is trapped, You should end up on line 8 of `Test_001`. Exchange the full stop by:

~~~
    →PassesIf'Left argument is not a two-element vector'≡⎕DMX.EM
~~~

A> # ⎕DM versus ⎕DMX
A>
A> You have always used `⎕DM`, and it was fine, right? No need to switch to the (relatively) new `⎕DMX`, right? Well, the problem with `⎕DM` is that it is not thread-safe, while `⎕DMX` is. That’s why we suggest you stop using `⎕DM` and use just `⎕DMX`. It also provides more, and more precise, information.

This checks whether the error message is what we expect. Trace through the test function and watch what it is doing. After having left the test function you may click the green triangle in the Tracer. (Continues execution of all threads.)

Now what if you’ve executed, say, not one but 300 test cases with `Run`, and just one failed, say number 289? You expected them all to succeed; now you need to check on the failing one. 

Calling `Run` as well as `RunDebug` would always execute _all_ test cases found. The function `RunThese` allows you to run just the specified test functions:

~~~
      RunThese 1
--- Test framework "Tester" version 3.5.0 from 2017-07-16 --------------------------------
Searching for INI file Testcases.ini
  ...not found
Searching for INI file testcases_APLTEAM2.ini
  ...not found
Looking for a function "Initial"...
  "Initial" found and successfully executed
--- Tests started at YYYY-MM-DD hh:mm:ss on #.Tests --------------------------------------
  Test_001 (1 of 1) : Process a single file with .\MyApp.exe
 -----------------------------------------------------------------------------------------
   1 test case executed
   0 test cases failed
   0 test cases broken
Time of execution recorded on variable #.Tests.TestCasesExecutedAt in: YYYY-MM-DD hh:mm:ss
Looking for a function "Cleanup"...
  Function "Cleanup" found and executed.
*** Tests done
~~~

This would run just test case number 1. If you specify it as `¯1` it would stop just before actually executing the test case. Same as before since we have just one test function yet but take our word for it, it would execute just `Test_001` no matter how many other test cases there are. 

We have discussed the functions `Run`, `RunDebug` and `RunThese`. That leaves `RunBatchTests` and `RunBatchTestsInDebugMode`; what are they for? 

Imagine a test that would either require an enormous amount of effort to implement – or alternatively you just build something up and ask the human in front of the monitor: _Does this look alright?_. 

That’s certainly _not_ a batch test case because it needs a human sitting in front of the monitor. If you know upfront that there won’t be a human paying attention then you can prevent non-batch test cases from being executed by calling either `RunBatchTests` or `RunBatchTestsInDebugMode`.

How does this work? We already learned that `stopFlag`, the first of the two flags passed to any test case as the right argument, governs whether any errors are trapped or not. 

The second flag is called `batchFlag`, and that gives you an idea of what it’s good for. If you have a test that interacts with a user (i.e. cannot run without a human) then your test case would typically look like this:

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

The test function checks the `batchFlag` and sees from the explicit result that it did not execute because it is not suitable for batch testing.

One can argue whether the test case we have implemented makes much sense, but it allowed us to investigate the basic features of the test framework. We are now ready to investigate the more sophisticated features.

Of course we also need a test case that checks whether `map` does what it’s supposed to do when appropriate arrays are passed as arguments, therefore we add this to `Tests`:

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
  →FailsIf'APL IS GREAT'≢Config.Accents U.map A.Uppercase'APL is great'
  →FailsIf'UßU'≢Config.Accents U.map A.Uppercase'üßÜ'
  R←∆OK
∇
...
~~~

I> Note how using the references `U` and `A` here simplifies the code greatly.

Now we try to execute these test cases:

~~~
      #.Tests.GetHelpers
      RunThese 2
--- Test framework "Tester" version 3.6.0 from YYYY-MM-DD ----------------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  "Initial" found and successfully executed
--- Tests started at YYYY-MM-DD hh:mm:ss on #.Tests ----------------------
  Test_002 (1 of 1) : Check whether `map` works fine with appropriate data
 -------------------------------------------------------------------------
   1 test case executed
   0 test cases failed
   0 test cases broken
~~~

Works fine. Excellent.

Now let’s make sure the workhorse is doing okay; for this we add another test case:

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

Let’s call this test:

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

Oops. `MyLogger` is undefined. In the envisaged use in production, it is defined by, and local to, `StartFromCmdLine`. That design followed Occam’s Razor[^occam]: (entities are not to be needlessly multiplied) in keeping the log object in existence only while needed. But it now prevents us from testing `TxtToCsv` independently. So we’ll refactor:

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

Note that now both `Config` and `MyLogger` exist within `MyApp`, not in `Tests`. Therefore we don't even have to keep them local within `Test_003`. They are however not part of the script, so will disapear as soon as the script `Tests` is fixed again, very much like the helpers. 

Let’s try again:

~~~
      RunThese 3
--- Test framework "Tester" version 3.6.0 from YYYY-MM-DD -------------------------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  "Initial" found and successfully executed
--- Tests started at 2017-03-22 15:56:41 on #.Tests -------------------------------
  Test_003 (1 of 1) : Test whether `TxtToCsv` handles a non-existing file correctly
 ----------------------------------------------------------------------------------
   1 test case executed
   0 test cases failed
   0 test cases broken
Time of execution recorded on variable #.Tests.TestCasesExecutedAt: YYYY-MM-DD hh:mm:ss
Looking for a function "Cleanup"...
  Function "Cleanup" found and executed.
~~~

Clearly we need to have one test case for every result the function `TxtToCsv` might return but we leave that as an exercise to you. We have more important test cases to write: we want to ensure whenever we create a new version of the EXE that it will keep working.

Let’s rename the test functions we have so far: 

* `Test_001` becomes `Test_map_01` 
* `Test_002` becomes `Test_map_02` 
* `Test_003` becomes `Test_TxtToCsv_01` 

The new test cases we are about to add will be named `Test_exe_01`, etc. For our application we could manage without grouping, but once you have more than, say, 20 test cases, grouping is a must. So we demonstrate now how this can be done.


### The "Initial" function

We've already introduced a function `Initial` for establishing the references `A`, `U` and `F` before we execute any test cases. For testing the EXE we need a folder where we can store files temporarily. We add this to `Initial`:

~~~
:Namespace Tests
⎕IO←1 ⋄ ⎕ML←1
leanpub-start-insert   
 ∇ R←Initial;list;rc
leanpub-end-insert    
   U←##.Utilities ⋄ F←##.FilesAndDirs ⋄ A←##.APLTreeUtils
leanpub-start-insert   
   ∆Path←F.GetTempPath,'\MyApp_Tests'
   F.RmDir ∆Path
   'Create!'F.CheckPath ∆Path
   list←⊃F.Dir'..\..\texts\en\*.txt'
   rc←list F.CopyTo ∆Path,'\'
   :If ~R←0∧.=⊃rc
       ⎕←'Could not create ',∆Path
   :EndIf
leanpub-end-insert   
 ∇
...
~~~

`Initial` does not have to return a result but if it does it must be a Boolean. For "success" it should return a `1` and otherwise a `0`. If it does return `0` then no test cases are executed, but if there is a function `Cleanup` it will be executed. Therefore `Cleanup` should be ready to clean up in case `Initial` was only partly or not at all successful. 

We have changed `Initial` so that it now returns a result because copying the files over might fail for all sorts of reasons – and we cannot do without them.

`Initial` may or may not accept a right argument. If it does it will be passed a namespace that holds all the parameters.

What to do in `Initial`, apart from creating the references:

* Create a global variable `∆Path` which holds a path to a folder `MyApp_Tests` within the Windows temp folder.
* Remove that folder, in case it persists from previously failing test cases.
* Create it.
* Get a list of all text files in the `texts\en\` folder.
* Copy those files to our temporary test folder.
* Check the return code of the copy operation; `R` gets 1 (indicating success) only if it was successful.


A> # Machine-dependent initialisation
A> 
A> What if you need to initialise something (say a database connection) but it is depends on the machine the tests are executed on  – its IP address, user-id, password…?
A>
A> The test framework looks for two different INI files in the current directory:
A> First it looks for `testcase.ini`. It then tries to find `testcase_{computername}.ini`. `computername` here is what you get when you execute `⊣ 2 ⎕nq # 'GetEnvironment' 'Computername'`.
A>
A> If it finds any of them (or both) it instantiates the `IniFile` class as `INI` on these INI files within the namespace that hosts your test cases. In the case of a clash, the setting in `testcase_{computername}.ini` prevails.

Now we are ready to test the EXE; create it from scratch. Our first test case will process the file `ulysses.txt`:

~~~
:Namespace Tests
...
    ∇ R←Test_exe_01(stopFlag batchFlag);⎕TRAP;rc
      ⍝ Process a single file with .\MyApp.exe
      ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
      R←∆Failed
     ⍝ Precautions:
      F.DeleteFile⊃F.Dir ∆Path,'\*.csv' ⍝ (1)
      rc←##.Execute.Application'MyApp.exe ',∆Path,'\ulysses.txt' ⍝ (2)
      →GoToTidyUp ##.MyApp.EXIT.OK≠⊃rc ⍝ (3)
      →GoToTidyUp~F.Exists ∆Path,'\ulysses.csv' ⍝ (4)
      R←∆OK
     ∆TidyUp:
      F.DeleteFile⊃F.Dir ∆Path,'\*.csv' ⍝ (5)
    ∇
...
~~~

Notes:

1. Ensure there are no CSVs in `∆Path`.
2. Call the EXE with `ulysses.txt` as a command line parameter.
3. Check the return code and jump to `∆TidyUp` if it’s not what we expect.
4. Check whether there is now a file `ulysses.cvs` in `∆Path`.
5. Clean up and delete (again) all CSV files in `∆Path`.

Let’s run our new test case:

~~~
      GetHelpers
      RunThese 'exe'
--- Test framework "Tester" version 3.6.0 from YYYY-MM-DD -----
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  "Initial" found and successfully executed
--- Tests started at YYYY-MM-DD hh:mm:ss on #.Tests -----------
  Test_exe_01 (1 of 1) : Process a single file with .\MyApp.exe
 --------------------------------------------------------------
   1 test case executed
   0 test cases failed
   0 test cases broken
Time of execution recorded on variable #.Tests.TestCasesExecutedAt in: YYYY-MM-DD hh:mm:ss
Looking for a function "Cleanup"...
  Function "Cleanup" found and executed.
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
  F.DeleteFile⊃F.Dir ∆Path,'\*.csv'
  rc←##.Execute.Application'MyApp.exe ',∆Path,'\'
  →GoToTidyUp ##.MyApp.EXIT.OK≠⊃rc
  listCsvs←⊃F.Dir ∆Path,'\*.csv'
  →GoToTidyUp 1≠⍴listCsvs
  →GoToTidyUp'total.csv'≢A.Lowercase⊃,/1↓⎕NPARTS⊃listCsvs
  R←∆OK
 ∆TidyUp:
  F.DeleteFile⊃F.Dir ∆Path,'\*.csv'
∇
...
~~~

This one will process _all_ TXTs in `∆Path` and write a file `total.csv`. We check whether this is the case and we are done. Almost: in a real-world application we most likely would also check for a path that contains spaces in its name. We don’t do this, instead we execute the full test suite:

~~~
      GetHelpers
      ⎕←⊃Run
--- Test framework "Tester" version 3.6.0 from YYYY-MM-DD ----------------------------
Searching for INI file testcases_{computername}.ini
  ...not found
Searching for INI file Testcases.ini
  ...not found
Looking for a function "Initial"...
  "Initial" found and successfully executed
--- Tests started at YYYY-MM-DD hh:mm:dd on #.Tests ---------------------------------------
  Test_TxtToCsv_03 (1 of 5) : Test whether `TxtToCsv` handles a non-existing file correctly
  Test_exe_01 (2 of 5)      : Process a single file with .\MyApp.exe
  Test_exe_02 (3 of 5)      : Process all TXT files in a certain directory
  Test_map_01 (4 of 5)      : Is the length of the left argument of the `map` function checked?
  Test_map_02 (5 of 5)      : Check whether `map` works fine with appropriate data  
 ------------------------------------------------------------------------------------------
   5 test cases executed
   0 test cases failed
   0 test cases broken
Time of execution recorded on variable #.Tests.TestCasesExecutedAt in: YYYY-MM-DD hh:mm:ss
Looking for a function "Cleanup"...
  Function "Cleanup" found and executed.
0   
~~~

Note that the function `Run` prints its findings to the session but also returns a result. That’s a two-item vector:

1. Is a return code. `0` means OK.
2. Is a vector of vectors, identical to what’s printed to the session.


### Cleaning up

Although we have been careful and made sure that every single test case cleans up after itself (in particular those that failed), we have not removed the directory that `∆Path` points to. We add some code to the `Cleanup` function in order to achieve that:

~~~
:Namespace Tests
...
∇ Cleanup dummy
  ⎕EX¨'AFU'
leanpub-start-insert      
  :If 0<⎕NC'∆Path'
      ##.FilesAndDirs.RmDir ∆Path
      ⎕EX '∆Path'
  :EndIf
leanpub-start-insert        
∇

:EndNamespace
~~~

This function now checks whether a global `∆Path` exists. If so, the directory it points to is removed and the global variable deleted. The `Tester` framework checks whether there is a function `Cleanup`. 

If so, the function is executed after the last test case has been executed. The function must be either monadic or niladic; if it is a monadic function the right argument will be `⍬`. It must either return a shy result (ignored) or no result at all.


### Markers

We’ve already mentioned elsewhere that it is useful to mark code in particular ways, like `⍝FIXME⍝` or `⍝TODO⍝`. It is an excellent idea to have a test case that checks for such markers. Before something makes it to a customer such strings should probably be removed from the code.

### The "L" and "G" helpers

Now that we have three groups we can take advantage of the `G` and the `L` helpers:

~~~
      G
exe
map
TxtToCsv
      L''
 Test_exe_01       Process a single file with .\MyApp.exe                      
 Test_exe_02       Process all TXT files in a certain directory                  
 Test_map_01       Is the length of the left argument of the `map` function checked?                         
 Test_map_02       Check whether `map` works fine with appropriate data          
 Test_TxtToCsv_01  Test whether `TxtToCsv` handles a non-existing file correctly 
      L'ex'
 Test_exe_01  Process a single file with .\MyApp.exe
 Test_exe_02  Process all TXT files in a certain directory    
~~~


## TestCasesExecutedAt

Whenever the test cases were executed `Tester` notifies the time on a global variable `TestCasesExecutedAt` in the hosting namespace. This can be used in order to find out whether part of the code has been changed since the last time the cases were executed.

However, in order to do this you have to make sure that the variable is either saved somewhere or added to the script `Tests`. For example, it could be handled by a cover function that calls any of `Tester`s `Run*` functions and then handled that variable.


## Conclusion

We have now a test suite available that allows us at any stage to call it in order to make sure that everything still works. Invaluable.


## The sequence of tests

Please note that there is always the possibility of dependencies between test cases, however you try to avoid that. That might be a mistake – or due to an unnoticed side effect.

That doesn’t mean that you shouldn’t aim for making all test cases completely independent from one another. A future version of `Tester` might have an option to shuffle the test cases before executing them. That would help find dependencies.


## Testing in different versions of Windows 

When you wrote for yourself, your code needed to run only on the version of Windows you use yourself. To ship it as a product, you will support it on the versions your customers use. 

You need to pick the versions of Windows you will support, and run your tests on all those versions. (If you are not already a fan of automated tests, you are about to become one.) 

For this you will need one of:

* a test machine for each OS (version of Windows) you support.
* a test machine and VM (virtual-machine) software.

What VM software should you use? One of us has had good results with _Workstation Player_ from [VMware](http://www.vmware.com).

If you use VM software you will save a _machine image_ for each OS. Include in each machine image your preferred development tools, such as text editor and Dyalog APL. You will need to keep each machine image up to date with fixes and patches to its OS and your tools. 

The machine images are large, about 10 GB each. So you want several hundred gigabytes of fast SSD (solid-state drive) on your test machine. With this you should be able to get a machine image loaded in 20 seconds or less. 


## Testing APLTree modules

By now we are using quite a number of modules from the APLTree project. Shouldn’t we test them as well? After all if they break, our application will stop working! Well, there are pros and cons:

Pro
: The modules have their own unit tests, and those are exhaustive. An update is published only after all the test cases have passed.

: The modules are constantly adapted to new demands or changes in the environment, etc. Therefore a new version of Windows or Dyalog won’t break them, although you need to allow some time for this to happen. “Some time” just means that you cannot expect the APLTree modules to be ready on the day a new version of either Windows or Dyalog becomes available.

Contra
: We cannot know whether those test cases cover the same environment/s (different versions of Windows, different versions of Dyalog, domain-managed network or not, network drives or not, multi-threaded versus single-threaded, you name it) our application will run in. 

That suggests we should incorporate the tests the modules come with into our own test suite. <!-- , although we are sure that not too many people/companies using modules from the APLTree library are actually doing this. --> 

It’s not difficult to do: every module has a workspace saved on GitHub that comes with everything needed to run the test cases. 

All it requires is 

* start Dyalog (_your_ version of Dyalog that is)
* load that workspace
* execute `#.TestCases.Run` (because all modules of the APLTree library host their test cases in an ordinary (non-scripted) namespace
* catch the result and return it with `⎕OFF` to the calling environment: as long as it’s `0`, all is well

If it’s not `0`:

* start your version of Dyalog
* load the workspace of the module that has one or more failing test cases
* run `#.TestCases.RunDebug 0` to investigate what went wrong


[^beck]: Kent Beck, in conversation with one of the authors.

[^string]: APL has no _string_ datatype. We use the word as a casual synonym for _character vector_.

[^domain]: An expert in the domain of the application rather than an expert programmer, but who has learned enough programming to write the code. 

[^occam]: _Non sunt multiplicanda entia sine necessitate._

[^where]: With version 16.0 the same can be achieved with the new primitive `⍸`.



## Common abbreviations


*[HTML]: Hyper Text Mark-up language
*[DYALOG]: File with the extension 'dyalog' holding APL code
*[TXT]: File with the extension 'txt' containing text
*[INI]: File with the extension 'ini' containing configuration data
*[DYAPP]: File with the extension 'dyapp' that contains 'Load' and 'Run' commands in order to put together an APL application
*[EXE]: Executable file with the extension 'exe'
*[BAT]: Executeabe file that contains batch commands
*[CSS]: File that contains layout definitions (Cascading Style Sheet)
*[MD]: File with the extension 'md' that contains markdown
*[CHM]: Executable file with the extension 'chm' that contains Windows Help(Compiled Help) 
*[DWS]: Dyalog workspace
*[WS]: Short for Workspaces
*[PF-key]: Programmable function key