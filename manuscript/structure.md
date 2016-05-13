{:: encoding="utf-8" /}

Structure
=========

In this chapter we consider your choices for making your program available to others, and for taking care of the source code, including tracking the changes through successive versions. 

To follow this, we'll make a very simple program. It counts the frequency of letters used in one or multiple text files. (This is simple, but useful in cryptanalysis, at least at hobby level.) We'll put the source code under version control, and package the program for use. 

Let's assume you've done the convenient thing. Your code is in a workspace. Everything it needs to run is defined in the workspace. Maybe you set a latent expression, so the program starts when you load the workspace. 

In this chapter, we shall convert a DWS (saved workspace) to some DYALOG scripts and a DYAPP script to assemble an active workspace from them. 


How can you distribute your program?
--------------------------------

### Send a workspace file (DWS)

Could not be simpler. If your user has a Dyalog interpreter, she can also save and send you the crash workspace if your program hits an execution error. But she will also be able to read your code -- which might be more than you wish for. 

If she doesn't have an interpreter, and you are not worried about her someday getting one and reading your code, and you have a Run-Time Agreement with Dyalog, you can send her the Dyalog Run-Time interpreter[^ext] with the workspace. The Run-Time interpreter will not allow the program to suspend, so when the program breaks the task will vanish, and your user won't see your code. All right so far. But she will also not have a crash workspace to send you. So you need your program to catch and report any errors before it dies. 


### Send an executable file (EXE)

This is the simplest form of the program to install, because there is nothing else it needs to run: everything is embedded within the EXE. You export the workspace as an EXE, which can have the Dyalog Run-Time interpreter bound into it. The code cannot be read. As with the workspace-based runtime above, your program cannot suspend, so you need it to catch and report any errors before dying. 

We'll do that! 


## Where should you keep the code?

Let's start by considering the workspace you will export as an EXE.

The first point is PCs have a lot of memory relative to your application code volume. So all your Dyalog code will be in the workspace. That's probably where you have it right now: all saved in a workspace. 

Your workspace is like your desk top – a great place to get work done, but a poor place to store things. In particular it does nothing to help you track changes and revert to an earlier version. 

Sometimes a code change turns out to be for the worse, and you need to undo it. Perhaps the change you need to undo is not the most recent change. 

We'll keep the program in manageable pieces – 'modules' – and keep those pieces in text files under version control. 

For this there are many _source-control management_ (SCM) systems and repositories available. Subversion, GitHub and Mercurial are presently popular. These SCMs support multiple programmers working on the same program, and have sophisticated features to help resolve conflicts between them. 

Whichever SCM you use (we used GitHub for writing this book and the code in it) your source code will comprise class and namespace scripts (DYALOGs) and a _build script_ (DYAPP) to assemble them.

You'll keep your local working copy in whatever folder you please. We'll refer to this _working folder_ as `Z:\` but it will of course be wherever suits you. 

## Versions

In real life you will produce successive _versions_ of your program, each better than the last. In an ideal world, all your users will have and use the latest version. In that ideal world, you have only one version to maintain: the latest. In the real world, your users will have and use multiple versions. If you charge for upgrading to a newer version, this will surely happen. And even in your ideal world, you have to maintain at least two versions: the latest and the next. 

What does it mean to maintain a version? At the very minimum, you keep the source code for it, so you could recreate its EXE from scratch, exactly as it was distributed. There will be things you want to improve, and perhaps bugs you must fix. Those will all go into the next version, of course. But some you may need to put into the released version and re-issue it to current users as a patch. 

So in _The Dyalog Cookbook_ we shall develop in successive versions. Our 'versions' are not ready to ship, so are probably better considered as milestones on the way to version 1.0. You could think of them as versions 0.1, 0.2 and so on. But we'll just refer to them as Versions 1, 2, and so on. 

Our first version won't even be ready to export as an EXE. It will just recreate MyApp.DWS from scripts: a DYAPP and some DYALOGs. We'll call it Version 0. 


## The MyApp workspace

We suppose you already have a workspace in which your program runs. We mean to get from your workspace to class and namespace scripts and a build script. 

We don't have your wonderful code to hand so we'll use ours. We'll use a very small and simple program, so we can focus on packaging the code as an application, not on writing the application itself.

Your application will of course be much more interesting!

So we'll begin with the MyApp workspace. It's trivially simple (we'll extend a bit what it does as we go) but for now it will stand in for your much more interesting code. 


A> ### On encryption
A> 
A> Frequency counting relies on the distribution of letters being more or less constant for any given language. It is the first step in breaking a substitution cypher. Substitution cyphers have been superseded by public-private key encryption, and are mainly of historical interest, or for studying cryptanalysis. But they are also fun to play with. 
A> 
A> We recommend _The Code Book: The secret history of codes & code-breaking_ by Simon Singh and _In Code_ by Sarah Flannery as introductions if you find this subject interesting.


From the `code\v01` folder on the book website load `LetterCount.dws`. Again, this is just the stand-in for your own code. Here's a quick tour.


### Discussion

Function `TxtToCsv` takes the filepath of a TXT (text file) and writes a sibling CSV file containing the frequency count for the letters in the file. It uses function `CountLetters` to produce the table. 

~~~
      ∆←'Now is the time for all good men'
      ∆,←' to come to the aid of the party.'
      MyApp.CountLetters ∆
N 2
O 8
W 1
I 3
S 1
T 7
H 3
E 6
M 3
F 2
R 2
A 3
L 2
G 1
D 2
C 1
P 1
Y 1
~~~

`CountLetters` returns a table of the letters in `⎕A` and the number of times each is found in the text. The count is insensitive to case and ignores accents, mapping accented to unaccented characters:

~~~
      ACCENTS
ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ
AAAAAACDEEEEIIIINOOOOOOUUUUY
~~~   

That amounts to five functions. Two of them are specific to the application: `TxtToCsv` and `CountLetters`. The other three -- `caseUp`, `join`, and `map` are utilities, of general use. 


`caseUp` uses the fast case-folding I-beam introduced in Dyalog 15.0. 

`TxtToCsv` uses the file-system primitives `⎕NINFO`, `⎕NGET`, and `⎕NPUT` introduced in Dyalog 15.0.

`TxtToCsv` observes _Cannon's Canon_, which tells us to avoid representing options with numeric constants. Instead, it assigns descriptive names at the start and uses those. That's not too bad, but if every function did the same, we risk multiple definitions of the same constant, breaching the DRY principle -- don't repeat yourself. (And open to errors: _A man with two watches never knows what time it is._) We can do better by defining all the Dyalog constants we want to use in a single namespace in the root.       


### How to organise the code     

To expand this program into distributable software we're going to add features, many of them drawn from the APLTree library. To facilitate that we'll first organise the existing code into script files, and write a _build script_ to assemble a workspace from them.  

Start at the root. We're going to be conservative about defining names in the root of the workspace. Why? Right now the program stands by itself and can do what it likes in the workspace. But in the future your program might become part of a larger APL system. In that case it will share the workspace root with other objects you don't know anything about right now. 

So your program will be a self-contained object in the workspace root. Give it a distinctive name, not a generic name such as `Application` or `Root`. From here on we'll call it `MyApp`. (We know: almost as bad.) 

But there _are_ other objects you might define in the root. If you're using classes or namespaces that other systems might also use, define them in the root. For example, if `MyApp` should one day become a module of some larger system, it would make no sense for each module to have its own copy of, say, the APLTree class `Logger`. 

With this in mind, let's distinguish some categories of code, and how the code in `MyApp` will refer to them.

General utilities and classes

: For example, the `APLTreeUtils` namespace and the `Logger` class. (Your program doesn't yet use these utilities.) In the future, other programs, possibly sharing the same workspace, might use them too.

Your program and its modules

: Your top-level code will be in `#.MyApp`. Other modules and MyApp-specific classes may be defined within it.

Tools and utility functions specific to MyApp

: These might include your own extensions to Dyalog namespaces or classes. Define them inside the app object, eg `#.MyApp.Utils`.

Your own language extensions and syntax sweeteners

: For example, you might like to use functions `means` and `else` as simple conditionals. These are effectively your local _extensions_ to APL, the functions you expect always to be around. Define your collection of such functions into a namespace in the root, eg `#.Utilities`. 

The object tree in the workspace might eventually look something like: 

~~~~~~~~
#
|-⍟Constants
|-⍟APLTreeUtils
|-⍟Utilities
|-○MyApp
| |-⍟Common
| |-⍟Engine
| |-○TaskQueue
| \-⍟UI
\-○Logger
~~~~~~~~

I> `⍟` denotes a namespace, `○` a class. 

The objects in the root are 'public'. They comprise `MyApp` and objects other applications might use. (You might add another application that uses `#.Utilities`. Everything else is encapsulated within `MyApp`. Here's how to refer in the MyApp code to these different categories of objects. 

1. `log←⎕NEW #.Logger`
2. `queue←⎕NEW TaskQueue`
3. `tbl←Engine.CountLetters txt`
4. `r←ok,ok #.Utilities.means r #.Utilities.else 'error'`

That last is pretty horrible, but we can improve it by defining aliases within `#.MyApp`:

~~~
(C U)←#.(Constants Utilities)
~~~

allowing (4) to be written as 

~~~
r←ok,ok U.means r U.else 'error'
~~~


### Why not use `⎕PATH`?

`⎕PATH` tempts us. We could set `⎕PATH←'#.Utilities'`. The expression above could then take its most readable form:

~~~
r←ok,ok means r else 'error'
~~~

Trying to resolve the names `means` and `else`, the interpreter would consult `⎕PATH` and find them in `#.Utilities`. So far so good: this is what `⎕PATH` is designed for. It works fine in simple cases, but it will lead us into problems later:

* As long as each name leads unambiguously to an object, shift-clicking on it will display it in the editor, a valuable feature of APL in development and debugging. The editor allows us to change code during execution, and save those changes back to the scripts. But `⎕PATH` can interfere with this and break that valuable connection. 
* Understanding the scope of the space in which a GUI callback executes can be challenging enough; introducing `⎕PATH` makes it harder still. 


## Project Gutenberg

We'll raid [Project Gutenberg](https://www.gutenberg.org/) for some texts to read. 

We're tempted by the complete works of William Shakespeare but we don't know that letter distribution stayed constant over four centuries. Interesting to find out, though, so we'll save a copy as `Z:\texts\en\shakespeare.dat`. And we'll download some 20th-century books as TXTs into the same folder. Here are some texts we can use. 

~~~
      ↑⊃(⎕NINFO⍠1) 'z:\texts\en\*.txt'
z:/texts/en/ageofinnocence.txt 
z:/texts/en/dubliners.txt      
z:/texts/en/heartofdarkness.txt
z:/texts/en/metamorphosis.txt  
z:/texts/en/pygmalion.txt      
z:/texts/en/timemachine.txt    
z:/texts/en/ulysses.txt        
z:/texts/en/withthesehands.txt 
z:/texts/en/wizardoz.txt       
~~~   


## MyApp reloaded

We'll first make MyApp a simple 'engine' that does not interact with the user. Many applications have functions like this at their core. Let's enable the user to call this engine from the command line with appropriate parameters. By the time we give it a user interface, it will already have important capabilities, such as logging errors and recovering from crashes. 

Our engine will be based on the `TxtToCsv` function. It will take one parameter, a fully-qualified filepath for a folder or file. If a file, it will write a sibling CSV. If a folder, it will read any TXT files in the folder, count the letter frequencies and report them as a CSV file sibling to the folder. Simple enough. Here we go. 


## Building from a DYAPP

In your text editor open a new document. (Or you can take the DYAPP from the folder for this chapter.)  

I> You need a text editor that handles Unicode. If you're not already using a Unicode text editor, Windows' own Notepad will do for occasional use. (Set the default font to APL385 Unicode.) For a full-strength multifile text editor [Notepad++](https://notepad-plus-plus.org/) works well.

Here's how the object tree will look:

~~~
#
|-⍟Constants
|-⍟Utilities
\-⍟MyApp
~~~

I> See the _SALT User Guide_ for more about DYAPPs. 

The file tree will look like this:

~~~
z:\code\v01\Constants.dyalog
z:\code\v01\MyApp.dyalog
z:\code\v01\Utilities.dyalog
z:\code\v01\MyApp.dyapp
~~~

So `z:\code\v01\MyApp.dyapp` looks like this:

~~~
Target #
Load Constants
Load Utilities
Load MyApp
~~~

and the DYALOGs look like this. `Constants.dyalog`: 

I> You can download all the scripts in this chapter from the corresponding folder in the book website. Or create the namespaces in the session and use SALT to save them to files.   

~~~
:Namespace Constants
   ⍝ Dyalog constants

   :Namespace NINFO
      WILDCARD←1
   :EndNamespace

   :Namespace NPUT
      OVERWRITE←1
   :EndNamespace

:EndNamespace
~~~

A> Later on we'll introduce a more convenient way to represent and maintain the definitions of constants. This will do nicely for now. 

And `Utilities.dyalog`:
 
~~~
:Namespace Utilities

    ⍝ Ubiquitous functions that for local purposes 
    ⍝  effectively extend the language
    ⍝ Treat as reserved words: do not shadow

    caseDn←{0(819⌶)⍵}
    caseUp←{1(819⌶)⍵}
~~~

~~~
      map←{
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }

:EndNamespace
~~~ 

And another:

~~~
:Namespace MyApp

⍝ Aliases
    (C U)←#.(Constants Utilities) ⍝ must be already defined

⍝ === VARIABLES ===

    ACCENTS←↑'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

    CountLetters←{
      {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}(↓ACCENTS)U.map U.caseUp ⍵
    } ⍝ Table of letter counts in string ⍵
~~~

~~~ 
    ∇ {ok}←TxtToCsv fullfilepath;xxx;csv;stem;path;files;txt;type;lines;nl
	;enc;tgt;src;tbl
   ⍝ Write a sibling CSV of the TXT located at fullfilepath,
   ⍝ containing a frequency count of the letters in the file text
      csv←'.csv'
      :Select type←1 ⎕NINFO fullfilepath
      :Case 1 ⍝ folder
          tgt←fullfilepath,csv
          files←⊃(⎕NINFO⍠C.NINFO.WILDCARD)fullfilepath,'\*.txt'
      :Case 2 ⍝ file
          (path stem xxx)←⎕NPARTS fullfilepath
          tgt←path,stem,csv
          files←,⊂fullfilepath
      :EndSelect
      tbl←0 2⍴'A' 0
      :For src :In files
          (txt enc nl)←⎕NGET src
          tbl⍪←CountLetters txt
      :EndFor
      lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
      ok←×(lines enc nl)⎕NPUT tgt C.NPUT.OVERWRITE
    ∇

:EndNamespace
~~~

Launch the DYAPP by double-clicking on its icon in Windows Explorer. Examine the active session. We see

~~~
- Constants
  - NINFO
    - WILDCARD
  - NPUT
    - OVERWRITE
- LocalAPL
  - caseDn 
  - caseUp
  - map
- MyApp 
  - ACCENTS
  - CountLetters
  - TxtToCsv
~~~

W> If you also see containers `SALT_Data` ignore them. They are part of how the Dyalog editor updates script files.

We have converted the saved workspace to a DYAPP that assembles the workspace from DYALOGs. We can use `MyApp.dyapp` anytime to recreate the app as a workspace. But we have not saved a workspace. We will always assemble a workspace from scripts. 


