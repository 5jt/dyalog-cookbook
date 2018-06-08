{:: encoding="utf-8" /}
[parm]:title='Help'


# Providing help

Users expect applications to provide help in one way or another. One option is to provide the help as a hypertext system. Under Windows, CHM files are the standard way to provide such help. There are powerful applications available that can assist you in providing help; HelpAndManual [^ham] is just an example.

However, we take a different approach here: rather than using any third-party software we use `Markdown2Help` from the APL_cation [^aplcation] project. That allows us to create a help system that:

* offers pretty much the same functionality as CHM.
* allows us to keep the Help close to the code.

This is the simplest way to create a Help system, and it allows you to run the Help system from within your application in order to view either its start page or a particular page as well as viewing the Help system without running your application at all.

While CHM files are Windows specific, `Markdown2Help` allows you to export a Help system as a web page that can be displayed with any modern browser. That makes it OS-independent. We’ll discuss later how to do this.


## Getting ready

It’s time to save a copy of `Z:\code\v10` as `Z:\code\v11`. 

To use `Markdown2Help` you need to download it from <http://download.aplwiki.com/>. We suggest creating a folder `Markdown2Help` within the folder `Z:\code\APLTree`. Copy into `Z:\code\APLTree\Markdown2Help` the contents of the ZIP you’ve just downloaded:

![Download target](Images/DownloadTarget.png)

Within that folder you will find a workspace `Markdown2Help` (from which we are going to copy the module) and a folder `help`. 

This folder contains in turn a subfolder `files` (which contains `Markdown2Help`’s own Help system) and the file `ViewHelp.exe`. That EXE is the external viewer for viewing your Help system independently from your application.

Double-click `ViewHelp.exe` in order to see `Markdown2Help2`’s own Help system:

![Markdown2Help's Help](Images/HelpViewer.png)

By default, `ViewHelp.exe` expects to find a folder `files` as a sibling of itself, and it assumes this folder contains a Help system. 


A> # Specify help folder and help page
A>
A> You can change the folder `ViewHelper.exe` expects to host the Help system by specifying a command-line parameter `helpFolder`:
A>
A> ~~~
A> ViewHelp.exe -helpfolder=C:\Foo\Help
A> ~~~
A>
A> You can also tell `ViewHelper.exe` to put a particular help page on display rather than the default page:
A>
A> ~~~
A> ViewHelp.exe -page=Sub.Foo
A> ~~~
A>
A> However, all these details are discussed in `Markdown2Help`’s own Help system.


`Markdown2Help` is an ordinary (non-scripted) namespace. We therefore need to copy it from its workspace. We also need the script `MarkAPL`, which is used to convert the help pages from Markdown to HTML. You know by now how to download scripts from the APLTree library. Modify `MyApp.dyapp` so that it loads the module `MarkAPL` and also copies `Markdown2Help`:

~~~
...
Load ..\AplTree\Execute
leanpub-start-insert
Load ..\AplTree\MarkAPL
Run 'Markdown2Help' #.⎕CY '..\apltree\Markdown2Help\Markdown2Help.dws'  
leanpub-end-insert
Load Tests
...
~~~

Double-click the DYAPP to get started.


## Creating a new Help system

`Markdown2Help` comes with a function `CreateStub` that creates a new Help system for us. We need an unused name for it: the obvious candidate is `MyHelp`. 

We want the Help system managed by SALT, for which we need a folder for all the Help files. For that we call `CreateParms` and then specify the folder in the parameter `saltFolder`:

~~~
parms←#.Markdown2Help.CreateParms ⍬
parms.saltFolder←'Z:\code\v11\MyHelp'
parms.folderName←'Z:\code\v11\Help\Files'
parms #.Markdown2Help.CreateStub '#.MyHelp'
~~~

`CreateStub` will create some pages and a node (or folder) for us; here’s what you should see:

![Download target](Images/MyFirstHelpPage.png)

Notes:

* In our example the name of `saltFolder` and the Help system are the same; not necessary but a good idea.
* `folderName` is the folder the compiled Help system will be saved into. That’s the stuff that needs to be installed in your customer’s machine in order to be able to view the Help system.
* The right argument must be a valid and unused APL name. `CreateStub` will create a namespace with that name for us.

  If a simple (not fully qualified) name is specified, that namespace will be created in the namespace the function `CreateStub` was called from. Instead you can specify a fully qualified name like `#.Foo.Goo.Help`. Note that `Foo` and `Goo` must both exist and `Help` must not.
* `CreateStub` will check the callback associated with the `Fix` event. If that happens to be a SALT function `CreateStub` will check the `saltFolder` parameter. If that’s not empty the Help system will use SALT for saving the nodes (namespaces), help pages (variables) and functions that resemble a help system.  
* `CreateStub` will return a reference pointing to the Help system, but you don’t normally need to assign that.
* When the Help system is managed by SALT you will find a namespace `SALT_Var_Data` in the root. Ignore this; it is used by SALT for metadata.


## Behind the scenes

In the workspace all nodes (in our case `MyHelp` and `Sub`) are ordinary namespaces, while the pages are variables. You can check with the Workspace Explorer:

![The help system in the Workspace Explorer](Images/Structure.png)

This is why the names of nodes and pages must be valid APL names. Those names appear in the Help tree as topics by default, but we can of course improve on that. We’ll come back to this soon.


## Editing a page

When you right-click on a page like `Copyright` and then select _Edit help page_ from the context menu (pressing <Ctrl+Enter> will do the same) the APL editor opens and shows something similar to this:

![A help page in the editor](Images/EditMarkdown.png)

This is the source of the help page in Markdown. 

Notes:

* The first line specifies a key-value-pair (`[DATA]`). `index` is the key and `Copyright` is the value of that key.
  This is interpreted by `Markdown2Help` as an index entry.

  Note that this is not a feature of Markdown feature but of `Markdown2Help`.
* `# Copyright` defines a header of level one. Every help page must have such a header.
* `(c) Copyright 2017 xyz` is a simple paragraph.

Make some changes, for example add another paragraph `Go to →[Overview]`, and then press Esc. `Markdown2Help` takes your changes, converts the Markdown to HTML and shows you the changed page. 

This gives you an idea of how easy it actually is to change help pages. Adding, renaming and deleting help pages – and nodes – can be achieved via the context menu.

Note also that `→[Overview]` is a link. For the link to work `Overview` must be the name of an existing page. If the title of the page differs from the name, the title will appear as the link text in the help page.

**Watch out** Read `Markdown2Help`’s own help file before you start using `Markdown2Help` in earnest. Some Markdown features are not supported by the Help system, and internal links are implemented in a simplified way.


## Changing title and sequence

Note that the Copyright page comes first. That’s because by default the pages are ordered alphabetically. You can change this with a right-click on either the Copyright or the Overview page and then selecting _Manage ∆TopicProperties_. 

After confirming this is really what you want to do you will see something like this:

~~~
 ∆TopicProperties←{
⍝ This function is needed by the Markdown2Help system.
⍝ You can edit this function from the Markdown2Help GUI via the context menu.
⍝ *** NOTE:
⍝     Make only changes to this function that affect the explicit result.
⍝     Any other changes will eventually disappear because these functions are rebuilt
⍝     under program control from their explicit result under certain circumstances.
⍝        This is also the reason why you should use the `active` flag to hide a topic
⍝     temporarily because although just putting a `⍝` symbol in front of its line
⍝     seems to have the same effect, in the long run that's not true because the
⍝     commented line will disappear in the event of a rebuild.
⍝ ----------------------------------
⍝ r gets a table with these columns:
⍝ [;0] namespace or function name.
⍝ [;1] caption in the tree view. If empty the namespace/fns name is taken.
⍝ [;2] active flag.
⍝ [;3] developmentOnly flag; 1=the corresponding node does not show in user mode.
     r←0 4⍴''
     r⍪←'Copyright' '' 1 0
     r⍪←'Overview' '' 1 0
     r⍪←'Sub' '' 1 0
     r
}
~~~

We recommend reading the comments in this function.

You can specify a different sequence of the pages simply by changing the sequence in which the pages are added to `r`. Here we swap the position of Copyright and Overview:

~~~
 ∆TopicProperties←{
     ...
     r←0 4⍴''
leanpub-start-insert     
     r⍪←'Overview' 'Miller''s overview' 1 0
     r⍪←'Copyright' '' 1 0
leanpub-end-insert     
     r⍪←'Sub' '' 1 0
     r
 }
~~~
 
We have also changed the title of the Overview page to _Miller’s overview_. That’s how you can specify an alternative title to the name of the page.

After fixing the function, the Help system is recompiled automatically; and our changes become visible immediately:

![The changed help system](Images/MyHelp_2.png)

What “compiling the help system” actually means is discussed soon.


## More commands

The context menu has many commands. The first three commands are always available. The other commands are useful for a developer (or shall we say Help system author?) and are available only when the Help system is running in a development version of Dyalog.

![The context menu](Images/ContextMenu.png)

As a developer you will have no problem mastering these commands.


## Compiling the help system

Compiling the help system converts 

* the information represented by the structure of the Help system
* the variables holding Markdown 
* the additional rules defined by any `∆TopicProperties` function 

into a single component file (DCF) containing the HTML generated from the Markdown, plus some more pieces of information.

It’s more than just converting Markdown to HTML. For example, the words of all the pages are extracted, ‘dead’ words like _and_, _then_, _it_, etc. are removed (because searching for them does not make too much sense) and the index, together with pointers to the pages they appear on, are saved in a component. 

This allows `Markdown2Help` to provide a very fast Search function. The list is actually saved in two forms, ‘as is’ and with all words lowercased to speed up any case-insensitive search operations.
 
Without specifying a particular folder, `Markdown2Help` would create a temporary folder and compile into that folder. It is better to define a permanent location, which avoids having the Help system compile the Markdown into HTML whenever it is called. 

Such a permanent location is also the precondition for using the Help system with the external viewer, necessary if your Help system tells how to _install_ your application.

For converting the Markdown to HTML, `Markdown2Help` needs the `MarkAPL` class, but once the Help system has been compiled this class is no longer needed. The final version of your application does not need `MarkAPL`. As `MarkAPL` comprises roughly 3,000 lines of code, this is good news.


## Editing the Help system directly

Besides editing a variable with a double-click in the Workspace Explorer, you could also edit it from the session with `)ED`. Our advice: **don't!**

The reason is simple: when you change a Help system via the context menu then other important steps are performed. An example is when you have a `∆TopicProperties` function in a particular node and you want to add a new help page to that node. 

You have to right-click on a page and select the _Inject new help page (stub)_ command from the context menu. You will then be prompted for a valid name and finally the new help page is injected after the page you have clicked at. 

But there is more to it than just that: the page is also added to the `∆TopicProperties` function. That’s one reason why you should perform all changes via the context menu rather than manipulating the Help system directly.

Maybe even more important: `Markdown2Help` also executes the necessary steps in order to keep the files and folders in `saltFolder` in sync with the Help system _and_ automatically recompiles the Help system for you.

The only exception is when you change your mind about the structure of a Help system. If that involves moving around namespaces or plenty of pages between namespaces then it is indeed better to do it in the Workspace Explorer and, when you are done, to check all the `∆TopicProperties` functions within your Help system and finally recompile the Help system; unless somebody implements drag-and-drop for the TreeView of the Help system one day…

However, if you do that, you must ensure the Help system is saved properly. That means that you have to invoke the `SaveHelpSystemWithSalt` method yourself. You also need to call the `Markdown2Help.CompileHelpFileInto` method to compile the Help system from the source. Refer to `Markdown2Help`’s own Help system for details.

  
## The Developers menu

If the Help system is running under a development version of Dyalog, you will see a _Developers_ menu on the right side of the menubar. This offers commands that support you in keeping your Help system healthy. We discuss just the most important ones:


### _Show topic in browser_

Particularly useful when you use non-default CSS and there is a problem with it: all modern browsers offer excellent tools for investigating CSS, supporting you when hunting bugs or trying to understand unexpected behaviour.


### _Create proofread document_

This command creates an HTML document from all the help pages and writes the HTML to a temporary file. The filename is printed to the session.

You can then open that document with your preferred word processor, say Microsoft Word. This will show something like this:

![The help system as a single HTML page](Images/ProofRead.png)

This is a great help when it comes to proofreading a document: one can use the review features of the word processor, and also print the document. You are much more likely to spot any problems in a printed copy than on a screen.


### _Reports_

Several reports identify broken and ambiguous links, `∆TopicProperties` functions, and help pages that do not carry any index entries.


## Export to HTML

You can export the Help system as a website. For that select _Export as HTML…_ from the _File_ menu.

The resulting website does not offer all the features the Windows version comes with, but you can read and print all the pages, you have the tree structure representing the contents, and all the links work. <!-- That must do under Linux and macOS for the time being. -->


## Making adjustments

If you have not copied the contents of `code\v11\*` from the book’s website then you need to make adjustments to the Help system to keep it in sync with the book. We have just two help pages; a page regarding the main method `TxtToCsv`:

![The changed help system](Images/Helppage_1.png)

And a page regarding copyright:

![The changed help system](Images/Helppage_2.png)


## How to view the Help system

We want to confirm we can call the Help system from within our application. For that we need a new function; its obvious name is `ShowHelp`.

The function’s vector right argument is the name of the page the Help system should open at; if empty, the first page is shown. It returns an instance of the Help system. The function goes into the `MyApp.dyalog` script:

~~~
:Namespace MyApp
...
∇

leanpub-start-insert 
∇{r}←ShowHelp pagename;ps
  ps←#.Markdown2Help.CreateParms ⍬
  ps.source←#.MyHelp     
  ps.foldername←'Help'
  ps.helpAbout←'MyApp''s help system by John Doe'
  ps.helpCaption←'MyApp Help'
  ps.helpIcon←'file://',##.FilesAndDirs.PWD,'\images\logo.ico'
  ps.helpVersion←'1.0.0'
  ps.helpVersionDate←'YYYY-MM-DD'
  ps.page←pagename
  ps.regPath←'HKCU\Software\MyApp'
  ps.noClose←1
  r←#.Markdown2Help.New ps
∇
leanpub-end-insert       

∇ r←Public
leanpub-start-insert
  r←'StartFromCmdLine' 'TxtToCsv' 'SetLX' 'ShowHelp'
leanpub-end-insert  
∇

:EndNamespace
~~~

I> A Windows Registry key? The user can mark any help page as a favourite, and this is saved in the Windows Registry. We will discuss the Windows Registry in a later chapter. 

This function requires the Help system to be available in the workspace.

Strictly speaking, only the `source` parameter needs to be specified to get it to work, but best to specify the other parameters too before a client sets eyes on your Help system.

Most of the parameters should explain themselves, but if in doubt you can always start `Markdown2Help`’s own Help system with `#.Markdown2Help.Selfie ⍬` and read the pages under the `Parameters` node. Here’s what you should see:

![The context menu](Images/HelpParameters.png)

You can request a list of all parameters with their default values with this statement:

~~~
      ⎕←(#.Markdown2Help.CreateParms'').∆List''
~~~

Note that `CreateParms` is one of the few functions in the APLTree library so named that actually requires a right argument. <!-- Breaking our rule! --> This right argument may be just an empty vector, but instead it could be a namespace with variables like `source` or `page`. In that case `CreateParms` would inject any missing parameters into that namespace and return it as a result. 

Therefore we could rewrite the function `ShowHelp`:

~~~
∇{r}←ShowHelp pagename;ps
  ps←⎕NS ''
  ps.source←#.MyHelp     
  ps.foldername←'Help'
  ps.helpAbout←'MyApp''s help system by John Doe'
  ps.helpCaption←'MyApp Help'
  ps.helpIcon←'file://',##.FilesAndDirs.PWD,'\images\logo.ico'
  ps.helpVersion←'1.0.0'
  ps.helpVersionDate←'YYYY-MM-DD'
  ps.page←pagename
  ps.regPath←'HKCU\Software\MyApp'
  ps.noClose←1
  ps←#.Markdown2Help.CreateParms ps     
  r←#.Markdown2Help.New ps
∇
~~~

This version of `ShowHelp` would produce exactly the same result.


## Calling the Help system from your application

* Start the Help system by calling the `New` function as soon as the user presses F1 or selects _Help_ from the menu bar or requests a particular help page by other means. Catch the result and assign it to a meaningful name: this represents your Help system. Here we use the name `MyHelpInstance`.
* Specify `noClose←1`. This means that when the user attempts to close the Help system with a click into the Close box or by selecting the _Quit_ command from the _File_ menu or by pressing Alt+F4 or Ctrl+W then the Help system is not really closed down, but just makes itself invisible.
* When the user next requests a help page use this:

  ~~~
  1 #.Markdown2Help.Display MyHelpInstance 'Misc'
  ~~~
  
  * The `1` provided as left argument forces the GUI to make itself visible, whether visible before or not: the user might have ‘closed’ the Help system since requesting a help page earlier on.
  * `MyHelpInstance` represents the Help system. 
  * `Misc` is the name of the page to be displayed. Can also be empty (`⍬`), in which case the first page is shown.
  
  Note that the overhead of recalling the Help system this way is pretty close to zero. If you _really_ want to get rid of the Help system call the `Close` method before deleting the reference:
  
  ~~~
  MyHelpInstance.Close
  )erase MyHelpInstance
  ~~~


## Adding the help system to "MyApp.dyapp"

Now that we have a Help system that is saved in the right place we have to ensure it is loaded when we assemble a workspace with a DYAPP. First we add a function `LoadHelp` to the `DevHelpers` class:

~~~
:Namespace DevHelpers
...

    ∇{r}←LoadHelp dummy;parms
    parms←#.Markdown2Help.CreateParms ⍬
    parms.saltFolder←#.FilesAndDirs.PWD,'\MyHelp'
    parms.source←'#.MyHelp'
    parms.folderName←#.FilesAndDirs.PWD,'\Help\Files'
    {}#.Markdown2Help.LoadHelpWithSalt parms
    ∇

:EndNamespace
~~~

Calling this function will load the Help system from `saltFolder` into the namespace `#.MyHelp` in the current workspace. So we need to call this function within `MyApp.dyapp`:

~~~
...
Load DevHelpers
leanpub-start-insert     
Run DevHelpers.LoadHelp ⍬
leanpub-end-insert     
Run #.MyApp.SetLX ⍬
...
~~~


## Enhancing Make.dyapp and Make.dyalog

Now we need to ensure the Make process includes the Help system. First we add the required modules to `Make.dyapp`:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
Load ..\AplTree\HandleError
Load ..\AplTree\IniFiles
Load ..\AplTree\OS
Load ..\AplTree\Logger
Load ..\AplTree\EventCodes
leanpub-start-insert     
Load ..\APLTree\WinReg
Run 'Markdown2Help' #.⎕CY '..\apltree\Markdown2Help\Markdown2Help.dws'  
leanpub-end-insert     
Load Constants
Load Utilities
Load MyApp
Run #.MyApp.SetLX ⍬

Load Make
Run #.Make.Run 1
~~~

Finally we ensure the compiled Help system is copied over together with the standalone Help Viewer:

~~~
:Class Make
...
leanpub-start-insert     
⍝ 5. Creates `MyApp.exe` within `DESTINATION\`
⍝ 6. Copy the Help system into `DESTINATION\Help\files`
⍝ 7. Copy the stand-alone Help viewer into `DESTINATION\Help`
leanpub-end-insert     
⎕IO←1 ⋄ ⎕ML←1

    DESTINATION←'MyApp'

    ∇ {filename}←Run offFlag;rc;en;more;successFlag;F;U;msg
      :Access Public Shared
      (F U)←##.(FilesAndDirs Utilities)
      (rc en more)←F.RmDir DESTINATION
      U.Assert 0=rc
      successFlag←'Create!'F.CheckPath DESTINATION
      U.Assert successFlag
      (successFlag more)←2↑'images'F.CopyTree DESTINATION,'\images'
      U.Assert successFlag
      (rc more)←'MyApp.ini.template'F.CopyTo DESTINATION,'\MyApp.ini'
      U.Assert 0=rc
leanpub-start-insert           
      (successFlag more)←2↑'Help\files'F.CopyTree DESTINATION,'\Help\files'
      U.Assert successFlag
      (rc more)←'..\apltree\Markdown2Help\help\ViewHelp.exe'F.CopyTo DESTINATION,'\Help\'
      U.Assert 0=rc
leanpub-end-insert           
      Export'MyApp.exe'
      filename←DESTINATION,'\MyApp.exe'
      :If offFlag
          ⎕OFF
      :EndIf
    ∇
...
:EndClass
~~~


[^ham]: <http://www.helpandmanual.com/>

[^aplcation]: <https://github.com/aplteam/apltree/wiki/Members>


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