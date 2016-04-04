# Stay DRY – don’t repeat yourself

If you say something twice (or more) and later have to change it, you have to change it everywhere you said it. Here are some refactoring techniques for removing duplications from your code. 

# APL.local

Every developer, and every development group, has utility functions uses throughout the code base. Most of these can and should be grouped into topic-specific namespaces, such as the WinFile namespace from the APLTree library. Aliasing the namespaces, such as `W←#.WinFile` allows utility functions to be called in abbreviated form, e.g. `W.Dir` instead of `#.WinFile.Dir`. 

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
