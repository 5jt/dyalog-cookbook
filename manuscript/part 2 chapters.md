# Minimise semantic distance 

Modern programs are much bigger as are machine memories. In general the scarcest resource is human attention. For the _human_ reader, assigning a name to a value (defining a variable) equates to _remember this_. Remember this value, just calculated, by this name. The more such associations the reader has to remembers, and the longer she has to remember them, the greater the demand, the cognitive load, upon the reader. 

_Semantic distance_ is the 'distance' in the code between assigning a variable and using it in another expression. Minimise the distance. Use the variable as soon as possible after setting it. Don't ask your reader to remember an association over 10 lines of code if she need only remember it over two. 

## No names 

The minimum semantic distance is zero. This is when you 'use' a value in the same expression in which you calculated it. If you can do this -- and have no further need to refer to the value -- then avoid assigning it a name at all. Even a short name, such as `x`, is a demand that the reader remember it until at least the end of the function. 

You can often use anonymous D-functions (lambdas) within a function to avoid defining variables in it. Assignments _within_ the D-function disappear when the D-function leaves the stack, so it's clear the reader has nothing to remember. 

For example, suppose you want to apply a function `foo` to the second element of the result of an expression before passing the lot onto another function `bar`. You might write:

~~~
triple←expression
(2⊃triple)←foo 2⊃triple
bar triple
~~~

But you can avoid defining `triple`, for which you have no further use and thus no need for the reader to remember, with an anonymous D-function:

~~~
bar {(a b c)←⍵ ⋄ a (foo b) c} expression
~~~

Or even an operator:

~~~
bar 0 1 0 foo{⍺⍺⍣⍺⊢⍵}¨expression
~~~

## Delta, the Heraclitean variable

Sometimes you need a name even though your reader need remember it only until the next line. You might need multiple lines to construct an array:

~~~
∆←('Dog' 'Mammal')('Cat' 'Mammal')('Carp' 'Fish')
∆,←('Eagle' 'Bird')('Viper' 'Reptile')('Rabbit' 'Mammal')
RegisterAnimals ∆
~~~

Here we follow a convention that the variable `∆` need not be remembered past the following line. 


# Stay DRY – don’t repeat yourself

If you say something twice (or more) and later have to change it, you have to change it everywhere you said it. Here are some refactoring techniques for removing duplications from your code. 


## Define variables once -- if that

_A man with two watches never knows what time it is._ On this principle, we avoid redefining variables. 

This seems counterintuitive. The point of a variable is that its content can vary. Early programming practice, working with scarce memory, positively encouraged 're-use' of variables, treating them as bins or containers in which to park data. 

Experience has taught us great respect for our capacity for confusion. When tracing and debugging, it is a great comfort to know that having found the definition of a variable, there are no other definitions to consider. 

The obvious exception is where different possible values are most clearly expressed in control structures, in which case minimise the semantic distance between the different definitions.

~~~
:if test1
:ElseIf test2 ⋄ x←'foo'
:Else ⋄ x←'bar'
:EndIf
~~~

# APL.local

Every developer, and every development group, has utility functions uses throughout the code base. Most of these can and should be grouped into topic-specific namespaces, such as the FilesAndDirs namespace from the APLTree library. Aliasing the namespaces, such as `F←#.FilesAndDirs` allows utility functions to be called in abbreviated form, e.g. `F.Dir` instead of `#.FilesAndDirs.Dir`. 

But some functions are so ubiquitous and general it makes better sense to treat them as your local extensions to the language itself. For example the simplified conditional functions `means` and `else` are ‘syntax sweeteners’ that allow you to write 

    :if a=b
       Z←'this'
    :else
       Z←'that'
    :endif
    
more legibly as `Z←(a=b) means 'this' else 'that'`

Functions `means` and `else` could be defined in say a namespace `#.Utilities` and abbreviated to `U`, permitting

    Z←(a=b) U.means 'this' U.else 'that'
    
But you might reasonably prefer to omit even the `U.` prefix.

## Defining ubiquitous utilities

Here is how to define your `Utilities` namespace in the workspace root so that you can refer to them without prefixes.

W> Every function or object you include in the root as your ‘local extension’ to the APL language effectively becomes a reserved word in your ‘local’ APL dialect. Be conservative and define functions this way only when you have found them ubiquitous and indispensable!

…

## Some utilities you might like to make ubiquitous 

# Hooray for arrays

You’ve already discovered how APL lets you write code that is helpfully light on ‘ceremony’. For example, you don’t have to declare variable types or loop through collections. Here are some more advanced array programming techniques that might give you a further lift. 

# Functional is funky 

Functional style makes your code easier to test, debug and re-use. 

# Complex data structures 

Some ways array programmers commonly use to represent more complex data structures, such as trees, dictionaries and tables. 

# Passing parameters perfectly 

# The ghastliness of globals

Nothing is handier when developing your code than keeping bits of information in global variables. They are like the Post-It™ notes or scraps of paper on your real-world desktop. They have no place in your application. Here’s why professional programmers keep the global symbol table as empty as possible – and how. 

# Coding with class

Classes are like micro-workspaces, and a great way of organising your code and data into modules. 
