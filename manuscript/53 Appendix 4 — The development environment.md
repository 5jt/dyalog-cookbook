{:: encoding="utf-8" /}
[parm]:toc    =  0
[parm]:title  = 'Quad-SE'


# Appendix 4 --- The development environment.



## Configure your session

Most developers adapt the development environment in one way or another:

* Make your favourite utilities available from within `⎕SE`.
* Add a menu to the session with often used commands.
* Define some function keys carrying out often used commands (not applicable with Ride).
* ...

There are several ways to achieve this:

1. Modify and save a copy of the default session file (by default `def_{countryCode}.dse` in the installation directory) and edit the configuration so that this new DSE is loaded. 
1. Modify and save a copy of the build workspace; that is typically something like `C:\Program Files\Dyalog\...\ws\buildse.dws`. Then use it to create your own tailored version of a DSE.

Both approaches have their own problems, the most obvious being that with a new version of Dyalog you start from scratch. However, there is a better way: save a function `Setup` in either `C:\Users\{UserName}\Documents\MyUCMDs\setup.dyalog` or one of the SALT work directories and it will be executed when...

* a new instance of Dyalog is fired up as part of the SALT boot process. 

  Note that the SALT boot process will be carried out even when the Enable_ SALT callbacks_ checkbox on the _SALT_ tab of the Configuration dialog box is not ticked.
  
* the user command `]usetup` is issued. 

  This means that you can execute the function at will at any time in order to re-initialise your environment.

The function may be saved in that file either on its own or as part of a namespace.

I> You might expect that saving a class script `Setup.dyalog` with a public shared function `Setup` would work as well but that's not the case.

A> # SALT work directories
A>
A> You can check which folders are currently considered SALT work directories by issuing `]settings workdir`.
A>
A> You can add a folder `C:\Foo` with `]settings workdir ,C:\Foo`.

When called as part of the SALT boot process a right argument `'init'` will be passed. When called via `]usetup` then whatever is specified as argument to the user command will become the right argument of the `Setup` function.

The Dyalog manuals mention this feature only when discussing the user command `]usetup` but not anywhere near how you can configure your environment; that's why we mention it here.

If you want to debug any `Setup` function then the best way to do this is to make `⎕TRAP` a local variable of `Setup` and then add these lines at the top of the function:

~~~
[1] ⎕TRAP←0 'S'
[2] .
~~~

This will cause an error that stops execution because error trapping is switched off. This way you get around the trap that the SALT boot process uses to avoid `Setup` causing a hiccup. However, if you change the function from the Tracer don't expect those changes to be saved automatically: you have to take care of that yourself.

The following code is an example for how you can put this mechanism to good use:

~~~
:Namespace Setup
⍝ Up to - and including - version 15.0 this script needs to go into:
⍝ "C:\Users\[username]\Documents\MyUCMDs"
⍝ Under 16.0 that still works but the SALT workdir folders are scanned as well.
  ⎕IO←1 ⋄ ⎕ML←1 

∇ {r}←Setup arg;myStuff
  r←⍬
  'MyStuff'⎕SE.⎕CY 'C:\MyStuff'
  ⎕SE.MyStuff.DefineMyFunctionKeys ⍬
  EstablishOnDropHandler ⍬
∇
   
∇ {r}←EstablishOnDropHandler dummy;events
  r←⍬
  events←''
  events,←⊂'Event' 'DropObjects' '⎕se.MyStuff.OnDrop'
  events,←⊂'Event' 'DropFiles' '⎕se.MyStuff.OnDrop'
  events,←⊂'AcceptFiles' 1
  events∘{⍵ ⎕WS ¨⊂⍺}'⎕se.cbbot.bandsb2.sb' '⎕se.cbbot.bandsb1.sb'
∇
   
:EndNamespace
~~~

Suppose in the workspace `MyStuff` there is a namespace `MyStuff` that contains at least two functions:

1. `DefineMyFunctionKeys`; this defines the function keys.
1. `OnDrop`; a handler that handles "DropObject" and "DropFiles" events on the session's status bar.

This is how the `OnDrop` function might look:

~~~
OnDrop msg;⎕IO;⎕ML;files;file;extension;i;target
⍝ Handles files dropped onto the status bar.
 ⎕IO←1 ⋄ ⎕ML←1
 files←3⊃msg
 :For file :In files
     extension←1(819⌶)3⊃1 ⎕NPARTS file
     :Select extension
     :Case '.DWS'
         ⎕←'     )XLOAD ',{b←' '∊⍵ ⋄ (b/'"'),⍵,(b/'"')}file
     :Case '.DYALOG'
         :If 9=⎕NC'⎕SE.SALT'
             target←((,'#')≢,1⊃⎕NSI)/' -Target=',(1⊃⎕NSI),''''
             ⎕←'      ⎕SE.SALT.Load ''',file,'',target
         :EndIf
     :Else
         :If 'APLCORE'{⍺≡1(819⌶)(⍴⍺)↑⍵}2⊃⎕NPARTS file
             ⎕←'      )COPY ',{b←' '∊⍵ ⋄ (b/'"'),⍵,(b/'"')}file,'.'
         :Else
             :If ⎕NEXISTS file
                 ⎕←{b←' '∊⍵ ⋄ (b/'"'),⍵,(b/'"')}file
             :Else
                 ⎕←file
             :EndIf
         :EndIf
     :EndSelect
 :EndFor
~~~

What this handler does depends on what extension the file has:

* For `.dyalog` it writes a SALT load statement to the session. 

  If the current namespace is not `#` but, say, `Foo` then `-target=Foo` is added.
* For `.dws` it writes an )XLOAD statement to the session.
* If the filename contains the string `aplcore` then it writes a )COPY statement for that aplcore with a trailing dot to the session.
* For any other files the fully qualified filename is written to the session.

I> When you start Dyalog with admin rights then it's not possible to drop files onto the status bar. That's because Microsoft considers drag'n drop too dangerous for admins. (One might think it better strategy to leave the dangerous stuff to the admins.)

How you configure your development environment is of course very much a matter of personal preferences. 

However, you might consider loading a couple of scripts into `⎕SE` from within `Setup.dyalog`; the obvious candidates for this are `APLTreeUtils`, `FilesAndDirs`, `OS`, `WinSys`, `WinRegSimple` and `Events`. That would allow you to write user commands that can reference them with, say, `⎕SE.APLTreeUtils.Split`.


## Define your function keys

Defining function keys is of course not exactly a challenge. Implementing it in a way that is actually easy to read and maintain _is_ a challenge.

~~~
:Namespace FunctionKeyDefinition

    ∇ {r}←DefineFunctionKeys dummy;⎕IO;⎕ML
      ⎕IO←1 ⋄ ⎕ML←3
      r←⍬
      ⎕SHADOW⊃list←'LL' 'DB' 'DI' 'ER' 'LC' 'DC' 'UC' 'RD' 'RL' 'RC' 'Rl' 'Ll' 'CP' 'PT' 'BH'
      ⍎¨{⍵,'←⊂''',⍵,''''}¨list
      r⍪←'F01'('')('(Reserved for help)')
      r⍪←'F02'(')WSID',ER)(')wsid')
      r⍪←'F03'('')('Show next hit')                  ⍝ Reserved for NX
      r⍪←'F04'('⎕SE.Display ')('Call "Display"')
      r⍪←'F05'(LL,'→⎕LC+1 ⍝ ',ER)('→⎕LC+1')
      r⍪←'F06'(LL,'→⎕LC ⍝',ER)'→⎕LC'
      ...
:EndNamespace
~~~

This approach first defines all special shortcuts -- like `ER` for Enter -- as local variables; using `⎕SHADOW` avoids the need for maintaining a long list of local variables. The statement `⍎¨{⍵,'←⊂''',⍵,''''}¨list` assigns every name as an enclosed text string to itself like `ER←⊂'ER'`. Now we can use `ER` rather than `(⊂'ER)` which improves readability.

A definition like `LL,'→⎕LC ⍝',ER` reads as follows:

* `LL` positions the cursor to the very left of the current line.
* `→⎕LC ⍝` is then written to the session, meaning that everything that was already on that line is now on the right of the `⍝` and therefore has no effect.
* `ER` then executes Enter, meaning that the statement is actually executed.

I> If you don't know what `LL` and `ER` actually are read the page "Keyboard shortcuts" in the _UI Guide_. 


## Windows captions

If you always run just one instance of the interpreter you can safely ignore this. 

If on the other hand you run occasionally (let alone often) more than one instance of Dyalog in parallel then you are familiar with how it feels when all of a sudden an unexpected dialog box pops up, be it an aplcore or a message box asking "Are you sure?" when you have no idea what you are expected to be sure about, or which instance has just crashed. 

There is a way to get around this. With version 14.0 Windows captions became configurable. This is a screenshot from the online help:

![Dyalog's help on Windows captions](Images\HelpOnWindowCaptions.png)

A> # Help --- online versus offline
A>
A> There are pros and cons:
A>
A> * Pressing F1 on something you need help with opens the offline help at the time of writing (2017-07).
A> * The online help is frequently updated by Dyalog.


We suggest you configure Windows captions in a particular way in order to overcome this problem. The following screen shot shows the definitions for all Windows captions in the Windows Registry for version 16 in case you follow our suggestions:

![Windows Registry entries for "Window captions"](Images/WindowsCaptions.png)

Notes:

* All definitions start with `{PID}`, which stands for process ID. That allows you to identify which process a particular window belongs to, and even to kill that process if needs must.
* All definitions contain `{WSID}` which stands for the workspace ID.
* `{PRODUCT}` tells all about the version of Dyalog: version number, 32/64 and Classic/Unicode.

  You might not be interested in this if you use just one version of Dyalog.

The other pieces of information are less important. For details refer to the page "Window captions" in the _Installation and Configuration Guide_. These definitions ensure most dialog boxes (there are a few exceptions) can easily be associated with a particular Dyalog session. This is just an example:

![A typical dialog box](Images/WindowsCaptionsDialogBox.png)

You can ask for the current settings with the user command `]caption`:

~~~
      ]caption
~~~

You can also change the settings with this user command. For details enter:

~~~
      ]??Caption
~~~


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