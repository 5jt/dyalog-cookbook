{:: encoding="utf-8" /}
[parm]:title='Structure'

# Structure

In this chapter we consider your choices for making your program available to others, and for taking care of the source code, including tracking the changes through successive versions. 

To follow this, we'll make a very simple program. It counts the frequency of letters used in one or multiple text files. (This is simple, but useful in cryptanalysis, at least at hobby level.) We'll put the source code under version control, and package the program for use. 

Some of the things we are going to add to this application will seem like overkill, but keep in mind that we use this application just as a very simple example for all the techniques we are going to introduce.

Let's assume you've done the convenient thing. Your code is in a workspace. Everything it needs to run is defined in the workspace. Maybe you set a latent expression, so the program starts when you load the workspace. 

We shall convert a DWS to some DYALOG scripts and introduce a DYAPP script to assemble an active workspace from them. 

Using scripts to store your source code has many advantages: You can use a traditional source code management system rather than having your code and data stored in a binary blob. 

Changes that you make to your source code are saved immediately, rather than relying on your remembering to save the workspace at some suitable point in your work process. 

Finally, you don't need to worry about crashes in your code or externally called modules and also any corruption of the active workspace which might prevent you from saving it.

A> # Corrupted workspaces
A> 
A> The _workspace_ (WS) is where the APL interpreter manages all code and all data in memory. The Dyalog tracer / debugger has extensive edit-and-continue capabilities; the downside is that these have been known to occasionally corrupt the workspace.
A> 
A> The interpreter checks WS integrity every now and then; how often can be influenced by setting certain debug flags; see the "[Appendix 3 — aplcores and WS integrity](./52 Appendix 3 — aplcores and WS integrity.html)" for details. More details regarding aplcores are available in the appendix "Aplcores".


## How can you distribute your program?


### Send a workspace file (DWS)

Could not be simpler. If your user has a Dyalog interpreter, she can also save and send you the crash workspace if your program hits an execution error. But she will also be able to read your code -- which might be more than you wish for. 

A> # Crash workspaces
A>
A> A crash workspace is a workspace that was saved by a function what was initiated by error trapping, typically by a setting of `⎕TRAP`. It's a snapshot of the workspace at the moment an unforseen problem triggered error trapping to take over. It's usually very useful to analyze such problems.
A>
A> Note that a workspace cannot be saved when more than one thread is running.

If she doesn't have an interpreter, and you are not worried about her someday getting one and reading your code, and you have a Run-Time Agreement with Dyalog, you can send her the Dyalog Run-Time interpreter with the workspace. The Run-Time interpreter will not allow the program to suspend, so when the program breaks the task will vanish, and your user won't see your code. All right so far. But she will also not have a crash workspace to send you. 

If your application uses multiple threads, the thread states can't be saved in a crash workspace anyway. 

You need your program to catch and report any errors before it dies, something we will discuss in the chapter [Handling errors](./07 Handling errors.html).


### Send an executable file (EXE)

This is the simplest form of the program to install, because there is nothing else it needs to run: everything is embedded within the EXE. You export the workspace as an EXE, which can have the Dyalog Run-Time interpreter bound into it. The code cannot be read. As with the workspace-based runtime above, your program cannot suspend, so you need it to catch and report any errors before dying. 

We'll do that! 


## Where should you keep the code?

Let's start by considering the workspace you will export as an EXE.

The first point is PCs have a lot of memory relative to your application code volume. So all your Dyalog code will be in the workspace. That's probably where you have it right now anyway. 

Your workspace is like your desk top – a great place to get work done, but a poor place to store things. In particular it does nothing to help you track changes and revert to an earlier version. 

Sometimes a code change turns out to be for the worse, and you need to undo it. Perhaps the change you need to undo is not the most recent change. 

We'll keep the program in manageable pieces – 'modules' – and keep those pieces in text files under version control. 

For this there are many _source-control management_ (SCM) systems and repositories available. Subversion, Git and Mercurial are presently popular. These SCMs support multiple programmers working on the same program, and have sophisticated features to help resolve conflicts between them. 

A> # Source code management with acre
A> Some members of the APL community prefer to use a source code management system that is tailored to solve the needs of an APL programmer, or a team of APL programmers: acre. 
A>
A> APL code is very compact, teams are typically small, and work on APL applications tends to be very oriented towards functions rather than modules. 
A>
A> Other aspects of working in APL impact the importance of features of the SCM that you use. acre is an excellent alternative to Git etc., and it is available as Open Source; we will discuss acre in its own appendix. ⍝TODO⍝

Whichever SCM you use (we used GitHub for writing this book and the code in it) your source code will comprise class and namespace scripts (DYALOGs) for the application. The help system will be an ordinary --- non-scripted --- namespace. We us a _build script_ (DYAPP) to assemble the application as well as the development environment.

You'll keep your local working copy in whatever folder you please. We'll refer to this _working folder_ as `Z:\` but it will of course be wherever suits you. 

## The LetterCount workspace

We suppose you already have a workspace in which your program runs. We don't have your code to hand so we'll use ours. We'll use a very small and simple program, so we can focus on packaging the code as an application, not on writing the application itself.

So we'll begin with the LetterCount workspace. It's trivially simple (we'll extend a bit what it does as we go) but for now it will stand in for your code. You can download it from the book's web site: <https://cookbook.dyalog.com>.

A> # On encryption
A> 
A> Frequency counting relies on the distribution of letters being more or less constant for any given language. It is the first step in breaking a substitution cypher. 
A>
A> Substitution cyphers have been superseded by public-private key encryption, and are mainly of historical interest, or for studying cryptanalysis. But they are also fun to play with. 
A> 
A> We recommend _The Code Book: The secret history of codes & code-breaking_ by Simon Singh and _In Code_ by Sarah Flannery as introductions if you find this subject interesting.


## Versions

In real life you will produce successive versions of your program, each better than the last. In an ideal world, all your users will have and use the current version. In that ideal world, you have only one version to maintain: the latest. 

In the real world, your users will have and use multiple versions. If you charge for upgrading to a newer version, this will surely happen. And even in your ideal world, you have to maintain at least two versions: the current and the next. 

What does it mean to maintain a version? At the very minimum, you keep the source code for it, so you could recreate its EXE from scratch, exactly as it was distributed. There will be things you want to improve, and perhaps bugs you must fix. Those will all go into the next version, of course. But some you may need to put into the released version and re-issue it to current users as a patch. 

So in _The Dyalog Cookbook_ we shall develop in successive versions. Our 'versions' are not ready to ship, so are probably better considered as milestones on the way to version 1.0. You could think of them as versions 0.1, 0.2 and so on. But we'll just refer to them as Versions 1, 2, and so on.

Our first version won't even be ready to export as an EXE. It will just create a workspace MyApp.dws from scripts: a DYAPP and some DYALOGs. We'll call it Version 1. 


Load the `LetterCount.dws` workspace from the `code\foo` folder on the book website. Again, this is just the stand-in for your own code. Here's a quick tour.


### Investigating the workspace LetterCount

Let's load the workspace `LetterCount` and investigate it a bit.

Function `TxtToCsv` takes the filepath of a TXT and writes a sibling CSV [^csv] containing the frequency count for the letters in the file. It uses function `CountLetters` to produce the table. 

~~~
      ∆←'Now is the time for all good men'
      ∆,←' to come to the aid of the party.'
      CountLetters ∆
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

I> Note that we use a variable `∆` here. Not exactly a memorable or self-explaining name. However, we use `∆` whenever we collect data for temporary use.

`CountLetters` returns a table of the letters in `⎕A` and the number of times each is found in the text. The count is insensitive to case and ignores accents, mapping accented to unaccented characters:

~~~
      Accents
ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ
AAAAAACDEEEEIIIINOOOOOOUUUUY
~~~   

That amounts to five functions. Two of them are specific to the application: `TxtToCsv` and `CountLetters`. The other three -- `toUppercase`, `join` and `map` are utilities, of general use. 

Note that we have some functions that start with lowercase characters while others start with uppercase characters. In a larger application you might want to be able to tell data from calls to functions and operators by introducing consistent naming conventions. Which one you settle for is less important then choosing something consistent. And don't forget to put it into a document any programmer joining the team is supposed to read first. 

`toUppercase` uses the fast case-folding I-beam introduced in Dyalog 15.0 (also available in 14.0 & 14.1 from revision 27141 onwards).

`TxtToCsv` uses the file-system primitives `⎕NINFO`, `⎕NGET`, and `⎕NPUT` introduced in Dyalog 15.0.

### How to organise the code     

To expand this program into distributable software we're going to add features, many of them drawn from the APLTree library. To facilitate that we'll first organise the existing code into script files, and write a _build script_ to assemble a workspace from them.  

I> The APLTree library is an open source project hosted in the APL wiki. It attempts to provide solutions for many every-day problems a Dyalog APL programmer might run into. In the Cookbook we will use many of its members. For details see <http://aplwiki.com/CategoryAplTree>.

Start at the root namespace (`#`). We're going to be conservative about defining names in `#`. Why? Right now the program stands by itself and can do what it likes in the workspace. But in the future your program might become part of a larger APL system. In that case it will share `#` with other objects you don't know anything about right now. 

So your program will be a self-contained object in `#`. Give it a distinctive name, not a generic name such as `Application` or `Root`. From here on we'll call it `MyApp`. (We know: almost as bad.) 

But there _are_ other objects you might define in `#`. If you're using classes or namespaces that other systems might also use, define them in `#`. For example, if `MyApp` should one day become a module of some larger system, it would make no sense for each module to have its own copy of, say, the APLTree class `Logger`. 

With this in mind, let's distinguish some categories of code, and how the code in `MyApp` will refer to them.

General utilities and classes
: For example, the `APLTreeUtils` namespace and the `Logger` class. (Your program doesn't yet use these utilities.) In the future, other programs, possibly sharing the same workspace, might use them too.

Your program and its modules
: Your top-level code will be in `#.MyApp`. Other modules and `MyApp`-specific classes may be defined within it.

Tools and utility functions specific to `MyApp`
: These might include your own extensions to Dyalog namespaces or classes. Define them inside the app object, eg `#.MyApp.Utils`.

Your own language extensions and syntax sweeteners
: For example, you might like to use functions `means` and `else` as simple conditionals. These are effectively your local _extensions_ to APL, the functions you expect always to be around. Define your collection of such functions into a namespace in `#`, eg `#.Utilities`. 

The object tree in the workspace might eventually look something like: 

~~~
#
|-⍟Constants
|-⍟APLTreeUtils
|-⍟Utilities
|-○MyApp
| |-⍟Common
| |-⍟Engine
| |-○TaskQueue
| \-⍟Utils
\-○Logger
\-⍟UI
~~~

I> `⍟` denotes a namespace, `○` a class. These are the characters (among others) you can use to tell the editor what kind of object you wish to create, so for a class `)ed ○ Foo`. Press F1 with the cursor on `)ed` in the session for details. 

Note that we keep the user interface (`UI`) separate from the business logic. This is considered good practise because whatever you believe right now, you will almost certainly consider to exchange a particular type of UI (say .NET Windows forms) against a different one (say HTML+JavaScript). This is difficult in any case but much easier when you separate them right from the start. However, our application is so simple that we collect all its code in a namespace script `MyApp` in order to save one level in the namespace hirarchy. 

If this were to be a serious project then you would not do this even if the amount of code is small: application tend to change and grow over time, sometimes significantly. Therefore you would be better prepared to have, say, a namespace `MyApp` that contains, say, a namespace script `engine` with all the code.

The objects in `#` are 'public'. They comprise `MyApp` and objects other applications might use; you might add another application that uses `#.Utilities`. Everything else is encapsulated within `MyApp`. Here's how to refer in the `MyApp` code to these different categories of objects. 

1. `log←⎕NEW #.Logger` 
2. `queue←⎕NEW TaskQueue`
3. `tbl←Engine.CountLetters txt`
4. `status←(bar>3) #.Utilities.means 'ok' #.Utilities.else 'error'`

⍝TODO⍝
⍝ Andy made a good point here that this is a diversion he was not happy with. 
⍝ Maybe this should be moved elsewhere?

The last one is pretty horrible. It needs some explanation.

Many languages offer a short-form syntax for if/else, eg (JavaScript, PHP, C...) 

~~~
status = bar>3 ? 'ok' : 'error' ;
~~~

Some equivalents in Dyalog:

* Control structure

  ~~~
  :If bar>3 
      status←'ok' 
  :Else 
      status←'error' 
  :EndIf
  ~~~

* Pick -1-

  ~~~
  status←(⎕IO+bar>3)⊃'error' 'ok'
  ~~~

* Pick -2-

  ~~~
  status←⊃(bar>3)⌽'error' 'ok'
  ~~~
  
* Defined functions: `means` and `else` here provide a short-form syntax:

  ~~~
  status←(bar>3) means 'ok' else 'error'
  ~~~

  The readability gain is largely lost if we have to qualify the functions with their full paths:

  ~~~
  status←(bar>3) #.Utilities.means 'ok' #.Utilities.else 'error'
  ~~~

  We can improve it by defining aliases within `#.MyApp`:
  
  I> We use the term "alias" her for a reference pointing to a particular script or namespace. In this context it is important to note that after executing `C←#.Constants` the alias `C` is _identical_ to `#.Constants`, therefore  ` 1 ←→ C≡#.Constants`.

  ~~~
  C←#.Constants ⋄ U←#.Utilities
  ~~~

  allowing it to be written as 

  ~~~
  status←(bar>3) U.means 'ok' U.else 'error'
  ~~~

What style you prefer is mainly a matter of personal taste, and indeed even the authors do not necessarily agree on this. There are however certain rules you should keep in mind:

#### Execution time

~~~
status←(bar>3) U.means 'ok' U.else 'error'
~~~

In this approach two user defined functions are called. Not much overhead but don't go for this if the line is, say, executed thousands of times within a loop.

#### Keep the end user in mind

The authors have done pair programming for years with end users being the second party. For a user a statement like:

~~~
taxfree←(dob>19491231) U.means 35000 U.else 50000
~~~

is easily readable despite it being formed of APL primitives and user defined functions. In an agile environment when the end user is supposed to discuss business logic with implementors this can be a big advantage.

For classes however there is another way to do this: include the namespace `#.Utilities`. In order to illustrate this let's assume for a moment that `MyApp` is not a namespace but a class.

~~~
:Clase MyApp
:Include Utilities
...
:EndClass
~~~

This requires the namespace `#.Utilities` to be a sibling of the assumed class `MyApp`. Now within the class you can do

~~~
status←(bar>3) means 'ok' else 'error'
~~~

yet Shift+Enter in the Tracer or the Editor still works, and any changes would go into `#.Utilities`.

A> # More about :Include
A>
A>  When a namespace is :Included, the interpreter will execute functions from that namespace as if they had been defined in the current class. However, the actual _code_ is shared with the original namespace. For example, this means that if the code of `means` or `else` is changed while tracing into it from the `MyApp` class those changes are reflected in `#.Utilities` immediately (and any other classes that might have :Included it).
A>
A> Most of the time, this works as you expect it to, but it can lead to confusion, in particular if you were to `)COPY #.Utilities` from another workspace. This will change the definition of the namespace, but the class has pointers to functions in the old copy of `#.Utilities`, and will not pick up the new definitions until the class is fixed again.
A> 
A> If you were to edit these functions while tracing into the `MyApp` class, the changes will not be visible in the namespace. Likewise, if you were to `)ERASE #.Utilities`, the class will continue to work until the class itself is edited, at which point it will complain that the namespace does not exist.
A>
A> Let's assume that in a WS `C:\Test_Include` we have just this code:
A> 
A> ~~~
A> :Class Foo
A> :Include Goo
A> :EndClass
A>
A> :Namespace Goo
A> ∇ r←Hello
A>     :Access Public Shared
A>       r←'World'
A>     ∇
A> :EndNamespace
A> ~~~
A> 
A> Now we do this:
A> 
A> ~~~
A> Foo.Hello
A> world
A>       )Save
A> Saved...
A>       ⎕EX 'Goo'
A>       Goo
A> VALUE ERROR      
A>       Foo.Hello
A> world
A> )copy c:\Test_Include Goo
A> copied...
A> ~~~
A> If you would at this stage edit `Goo` and change `'world'` to `'Universe'` and then call again `Foo.Hello` it would still print `world` to the session.

If you experience this sort of confusion, it is a good idea to re-fix your classes (in this case `Foo`). Building a fresh WS from source files might be even better.

#### Be careful with diamonds

The `:If - :Then - :else` solution could have been written this way:

~~~
:If bar>3 ⋄ status←'ok' ⋄ :Else ⋄ status←'error' ⋄ :EndIf
~~~

There is one major problem with this: when executing the code in the Tracer the line will be executed in one go. If you think you might want to follow the control flow and trace into the individual expressions, you should spread the control structure over 5 lines.

In general: if you have a choice between a short and a long expression then your are advised to go for the short one unless the long one offers an incentive like improved readability, better debugging or faster execution speed; only a short program has a chance of being bug free. 

Diamonds can be useful in some situations, but in general it's a good idea to avoid them.

A> # Diamonds
A> 
A> In some circumstances diamonds are quite useful:
A> 
A> * To make sure that no thread switch takes place between two statements. Something like
A> 
A>   ~~~ 
A>   tno←filename ⎕nTIE 0 ⋄ l←⍴⎕nread tno 80 (⎕nsize tno) ⋄ ⎕nuntie tno
A>   ~~~
A> 
A>   is guaranteed to be executed as a unit. Depending on the circumstances this can be really important.
A>
A> * Make multiple assignments on a single line as in `⎕IO←1 ⋄ ⎕ML←3 ⋄ ⎕PP←20`. Not for variable settings, just system stuff. 
A> * Assignments to `⎕LX` as in `⎕LX←#.FileAndDirs.PolishCurrentDir ⋄ ⎕←Info`.
A> * To make dfns more readable as in `{w←⍵ ⋄ ((w='¯')/w)←'-' ⋄ ⍵}`. There is really no reason to make this a multi-line dfn.
A>
A>   (Note that from version 16 onwards you can achieve the same result with `{'-'@(⍸⍵='¯')⊣⍵}`)
A> * You _cannot_ trace into a one-line dfn. This can be quite useful. For example, this function:
A>
A>   ~~~
A>   OnConfigure←{(4↑⍵),((⊃⍺){(0∊⍴⍺):⍵ ⋄ ⍺⌈⍵}⍵[4]),((⊃⌽⍺){(0∊⍴⍺):⍵ ⋄ ⍺⌈⍵}⍵[5])}
A>   ~~~
A>
A>   makes sure that a GUI Form (window) is not going to be smaller than a minimum size defined by `⍺`.
A>  
A>   You don't want to have a multi-line dfn here because then you won't be able to trace into any `⎕DQ` (or `Wait`) statement any more; the number of "Config" events is simply overwhelming. Thanks to the `⋄` we can solve the task on a single line and prevent the Tracer from ever entering the dfn.

#### Why not use `⎕PATH`?

`⎕PATH` tempts us. We could set `⎕PATH←'#.Utilities'`. The expression above could then take its most readable form:

~~~
status←(bar>3) means 'ok' else 'error'
~~~

Trying to resolve the names `means` and `else`, the interpreter would consult `⎕PATH` and find them in `#.Utilities`. So far so good: this is what `⎕PATH` is designed for. It works fine in simple cases, but in our experience its use quickly leads to confusion about which functions are called or edited, and where new names are created. We recommend that you avoid `⎕PATH` if reasonable alternatives are available.

### Convert the WS LetterCount into a single scripted namespace.

If your own application is already using scripted namespaces and/or classes then you can skip this, of course.

We assume you have downloaded the WS and saved it as `Z:\code\v00\LetterCount`.

Note that all the stuff in that WS lives in `#`. We have to change that so that all the stuff lives in a single namespace `MyApp`. In order to achieve that execute the following steps:

1. Start an instance of Dyalog
1. Execute `)ns MyApp` in order to create a namespace `MyApp` in the workspace.
1. Execute `)cs MyApp` in order to change _into_ `MyApp`, making `MyApp` effectively the _current namespace_. 
1. Execute `)copy Z:\code\v00\LetterCount` in order to copy all functions and the single variable into the current namespace which happens to be `#.MyApp`. 
1. Execute `)copy Z:\code\v00\LetterCount ⎕IO ⎕ML` 

   This makes sure that we really use the same values for important system variables as the WS by copying their values into the namespace `#.MyApp`. 
1. Execute `]save #.MyApp Z:\code\v01\MyApp -makedir -noprompt` 

The last step will save the contents of the namespace `#.MyApp` into `Z:\code\v01\MyApp.dyalog`. In the case that the folder `v01` or any of its parents do not already exist the `-makedir` option will cause them to be created. `-noprompt` makes sure that `]save` does not ask any questions.

This is how the script would look like:

~~~
:Namespace MyApp
⍝ === VARIABLES ===

Accents←2 28⍴'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝAAAAAACDEEEEIIIINOOOOOOUUUUY'


⍝ === End of variables definition ===

(⎕IO ⎕ML ⎕WX ⎕PP ⎕DIV)←1 1 3 15 1

 CountLetters←{
     ⍝ Table of letter frequency in txt
     {⍺(≢⍵)}⌸⎕A{⍵/⍨⍵∊⍺}(↓Accents)map toUppercase ⍵
 }

∇ noOfBytes←TxtToCsv fullfilepath;NINFO_WILDCARD;NPUT_OVERWRITE;tgt;files;path;stem;txt;enc;nl;lines;csv
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text.
 NINFO_WILDCARD←NPUT_OVERWRITE←1 ⍝ constants
 fullfilepath~←'"'
 csv←'.csv'
 :Select 1 ⎕NINFO fullfilepath
 :Case 1 ⍝ folder
     tgt←fullfilepath,'\total',csv
     files←⊃(⎕NINFO⍠NINFO_WILDCARD)fullfilepath,'\*.txt'
 :Case 2 ⍝ file
     (path stem)←2↑⎕NPARTS fullfilepath
     tgt←path,stem,csv
     files←,⊂fullfilepath
 :EndSelect
     ⍝ assume txt<<memory
 (txt enc nl)←{(⊃,/1⊃¨⍵)(1 2⊃⍵)(1 3⊃⍵)}⎕NGET¨files
 lines←','join¨↓⍕¨CountLetters txt
     ⍝ use encoding and NL from first source file
 noOfBytes←(lines enc nl)⎕NPUT tgt NPUT_OVERWRITE
     ⍝Done
∇

 join←{
     ⍺←⎕UCS 13 10
     (-≢⍺)↓⊃,/⍵,¨⊂⍺
 }

 map←{
     (old new)←⍺
     nw←∪⍵
     (new,nw)[(old,nw)⍳⍵]
 }

 toUppercase←{1(819⌶)⍵}

:EndNamespace 
~~~

There might be minor differences depending on the version of the `]save` user command and the version of SALT you are actually using.

This is the easiest way to convert any ordinary workspace into one or more scripted namespaces.

We start improving based on this version.

## Project Gutenberg

We'll raid [Project Gutenberg](https://www.gutenberg.org/) for some texts to read. 

We're tempted by the complete works of William Shakespeare but we don't know that letter distribution stayed constant over four centuries. Interesting to find out, though, so we'll save a copy as `Z:\texts\en\shakespeare.dat`. And we'll download some 20th-century books as TXTs into the same folder. Here are some texts we can use. 

~~~
      ↑⊃(⎕NINFO⍠'Wildcard' 1) 'z:\texts\en\*.txt'
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

We'll first make `MyApp` a simple 'engine' that does not interact with the user. Many applications have functions like this at their core. Let's enable the user to call this engine from the command line with appropriate parameters. By the time we give it a user interface, it will already have important capabilities, such as logging errors and recovering from crashes. 

Our engine will be based on the `TxtToCsv` function. It will take one parameter, a fully qualified filepath for a folder or file. If it is a file it will write a sibling CSV. If it is a folder it will read all TXT files in the folder, count the letter frequencies and write them as a CSV file sibling to that folder. Simple enough. Here we go. 

## Building from a DYAPP

In your text editor open a new document.

A> You need a text editor that handles Unicode. If you're not already using a Unicode text editor, Windows' own Notepad will do for occasional use. (Set the default font to APL385 Unicode)
A>
A> For a full-strength multifile text editor [Notepad++](https://notepad-plus-plus.org/) works well but make sure that the editor converts TAB into spaces; by default it does not, and Dyalog does not like TAB characters. 
A>
A> You can even make sure that Windows will call Notepad++ when you enter "notepad.exe" into a console window or double-click a TXT file: google for "notepad replacer".

Here's how the object tree will look:

~~~
#
|-⍟Constants
|-⍟Utilities
\-⍟MyApp
~~~

We've saved the very first version as `z:\code\v01\MyApp.dyalog`. Now we take a copy of that and save it as `z:\code\v02\MyApp.dyalog`. Alternatively you can download version 2 from the book's website of course.

Note that compared with version 1 we will improve in several ways:

* We create a DYAPP which will assemble the workspace for us.
* We define all constants we need in a scripted namespace `Constants` which has a sub-namespace `NINFO` which in turn has a sub-namespace `TYPES`.
* The three utility functions go into their own separate namespace script `Utilities`.

The file tree will look like this:

~~~
z:\code\v02\Constants.dyalog
z:\code\v02\MyApp.dyalog
z:\code\v02\Utilities.dyalog
z:\code\v02\MyApp.dyapp
~~~

`MyApp.dyapp` looks like this if we take the simple approach:

~~~
Target #
Load Constants
Load Utilities
Load MyApp
~~~

This is the `Constants.dyalog` script:

~~~
:Namespace Constants
    ⍝ Dyalog constants
    :Namespace NINFO
        ⍝ left arguments
        NAME←0
        TYPE←1
        SIZE←2
        MODIFIED←3
        OWNER_USER_ID←4
        OWNER_NAME←5
        HIDDEN←6
        TARGET←7        
        :Namespace TYPES
            NOT_KNOWN←0
            DIRECTORY←1
            FILE←2
            CHARACTER_DEVICE←3
            SYMBOLIC_LINK←4
            BLOCK_DEVICE←5
            FIFO←6
            SOCKET←7            
        :EndNamespace
    :EndNamespace
    :Namespace NPUT
        OVERWRITE←1
    :EndNamespace
:EndNamespace
~~~

Note that we use uppercase here for the names of the "constants" (they are of course not really constants but ordinary variables so far). It is a common convention in most programming languages to use uppercase letters for constants.

I> Later on we'll introduce a more convenient way to represent and maintain the definitions of constants. This will do nicely for now. 

This is the `Utilities.dyalog` script:
 
~~~
:Namespace Utilities
      map←{
          (old new)←⍺
          nw←∪⍵
          (new,nw)[(old,nw)⍳⍵]
      }
    toLowercase←0∘(819⌶)
    toUppercase←1∘(819⌶)
:EndNamespace
~~~ 

Finally the `MyApp.dyalog` script:

~~~
:Namespace MyApp

   (⎕IO ⎕ML ⎕WX ⎕PP ⎕DIV)←1 1 3 15 1

⍝ === Aliases

    U←##.Utilities ⋄ C←##.Constants

⍝ === VARIABLES ===

    Accents←↑'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

      CountLetters←{
          {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}(↓Accents)U.map U.toUppercase ⍵
      }

    ∇ noOfBytes←TxtToCsv fullfilepath;csv;stem;path;files;lines;nl;enc;tgt;tbl
   ⍝ Write a sibling CSV of the TXT located at fullfilepath,
   ⍝ containing a frequency count of the letters in the file text.
      fullfilepath~←'"'
      csv←'.csv'
      :Select C.NINFO.TYPE ⎕NINFO fullfilepath
      :Case C.TYPES.DIRECTORY
          tgt←fullfilepath,'total',csv
          files←⊃(⎕NINFO⍠'Wildcard' 1)fullfilepath,'\*.txt'
      :Case C.TYPES.FILE
          (path stem)←2↑⎕NPARTS fullfilepath
          tgt←path,stem,csv
          files←,⊂fullfilepath
      :EndSelect      
      (tbl enc nl)←{(⊂⍪⊃⍵)1↓⍵)}(CountLetters ProcessFiles) files
      lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
      noOfBytes←(lines enc nl)⎕NPUT tgt C.NPUT.OVERWRITE
    ∇
    
    ∇(data enc nl)←(fns ProcessFiles) files;txt;file
   ⍝ Reads all files and executes `fns` on the contents. `files` must not be empty.
      data←⍬
      :For file :In files
          (txt enc nl)←⎕NGET file
          data,←⊂fns txt
      :EndFor     
    ∇

:EndNamespace
~~~

This version comes with a number of improvements. Let's discuss them in detail:

* We address `Utilities` as well as `Constants` with "`##.`": that works as long as they are siblings of `MyApp`. "`#.`" would of course work as well but is inferior. For example, one day you might want to convert this application into a user command; then `##.` will continue to work while `#.` might or might not work, depending on what happens to be in the workspace at the time of execution. The same would be true if making it a ASP.NET application: those have no concept of a "root" at all.

* We have changed the assignment of the `Accents` variable so that we don't need to know the length of it any more.     

* It is good programming practise to _not_ use any numeric constants in your code. `TxtToCsv` tried to avoid this to some extend by assigning descriptive names at the start and using those. That's not too bad, but if every function did the same, we risk multiple definitions of the same constant, breaching the [DRY principle](https://en.wikipedia.org/wiki/Don't_repeat_yourself) -- don't repeat yourself. (And open to errors: _A man with two watches never knows what time it is._) 

   We can do better by defining all the Dyalog constants we want to use in a single namespace in `#`. We have also replaced the remaining integers in the `:Case` statements by references to symbolic variables in `Constants.NINFO.Type`.

* We have replaced the line `(txt enc nl)←{(⊃,/1⊃¨⍵)(1 2⊃⍵)(1 3⊃⍵)}⎕NGET¨files` by a `:For` loop and moved the code into `ProcessFiles`. Why?

  * We have two fewer local variables.
  * It keeps `TxtToCsv` nice and short.
  * When something goes wrong with a file (corrupted, missing rights, tied by another proces...) then the original version would not even allow you to identify easily what file is causing the problem. Now you would know exactly which file is causing a problem without any effort.
  * Tracing through a function can be painful in case there is any kind of loop involved while you are not interested in the loop at all.
    
    Now it is simply a choice of whether you want to trace _into_ `ProcessFiles` or not.
    
    In short: way more often than not it is a good idea to move loops (`:For`, `:Repeat`, `:While`) into their own function (or operator) doing just the loop.
    
* `ProcessFile` is an operator rather than a function. Currently it takes the function `CountLetters` as operand, but it could be any other function that's supposed to do something useful with the contents of those files. Therefore having `ProcessFiles` as an operator is more general.
  
* Because of `enc` and `nl` we have to have two lines anyway, but if we weren't interested in `enc` and `nl` a one-liner would do: `tbl⍪←CountLetters ⊃⎕NGET file`. Is this a good idea?

  The answer is no. In case you have to inspect what comes from several files because one (or more) of them contain something unexpected you want to be able to check what you've got, one by one. By separating it on two lines you can open an edit window on `txt`, put a stop vector on line 5 and you can easily check on the contents of one file after the other.

* Although the system settings are done in `MyApp` that's not exactly ideal because these settings should be set for everything in the WS, in particular `#`.   

  Naturally this is important for the "Utilities" script because as soon as we introduce a function into it that depends on either `⎕IO` or `⎕ML` we might or might not be in trouble.

  But there is more to it: when we execute a statement like `ref←#.⎕NS ''` (note the `#.`!) then the (unnamed) namespace created by this statement would inherit all the system settings from its parent `#`. Now we can safely assume that you have configured your session according to your needs. However, when you start the app with a double-click on the DYAPP then you might be on a different machine with different settings. In that case you have no idea what you are going to get.
  
  It is therefore safer - and strongly recommended - to make sure that the setting is well-defined. We will come back to this later.

W> If you see any namespaces called `SALT_Data` ignore them. They are part of how SALT manages meta data for scripted objects.

We have converted the saved workspace to a bunch of text files, and invented a DYAPP that assembles the workspace from the DYALOGs. But we have not saved a workspace; we will always assemble a workspace from scripts. 

Launch the DYAPP by double-clicking on its icon in Windows Explorer. Examine the active session. We see

~~~
- Constants
  - NINFO
    - NAME
    - ...
    - TYPES
      - NOT_KNOWN
      - DIRECTORY
      - ...
  - NPUT
    - OVERWRITE
- MyApp 
  - Accents
  - C
  - CountLetters
  - TxtToCsv
  - U
- Utilities
  - map
  - toLowercase
  - toUppercase
~~~

Note that `MyApp` contains `C` and `U`. That means that the code in the script got executed in the process of assembling the WS, otherwise they wouldn't exist. That's nice because when you type `#.MyApp.C.` then autocomplete pops in and suggests all the names contained in `Constants`.

We have reached our goal: 

* Everything is now stored in text files
* With a double-click on `MyApp.dyapp` we can assemble the WS.
* Along the way we have improved the quality of the code, making it more readable and easier to debug.


[^csv]: With version 16.0 Dyalog has introduced a system function `⎕CSV` for both importing from and exporting to CSV files.












































*[HTML]: Hyper Text Mark-up language
*[DYALOG]: File with the extension 'dyalog' holding APL code
*[TXT]: File with the extension 'txt' containing text
*[INI]: File with the extension 'ini' containing configuration data
*[DYAPP]: File with the extension 'dyapp' that contains 'Load' and 'Run' commands in order to compile an APL application
*[EXE]: Executable file with the extension 'exe'
*[BAT]: Executeabe file that contains batch commands
*[CSS]: File that contains layout definitions (Cascading Style Sheet)
*[MD]: File with the extension 'md' that contains markdown
*[CHM]: Executable file with the extension 'chm' that contains Windows Help(Compiled Help) 
*[DWS]: Dyalog workspace
*[WS]: Short for Workspaces