{:: encoding="utf-8" /}

# Configuration settings

Before we start establishing error handling on a general level we first need to establish a way to configure the application. That's why we now introduce configuration settings.

Thinking more widely, an application's configuration includes all kinds of state: e.g., folders for log files and crashes, debug flag, flag for switching off error trapping, email address to report to in case of an error, window positions, recent filepaths, and GUI themes...


## Using the Windows Registry

The Windows Registry is held in memory, so it is fast to read. It has been widely used to store configuration settings. Many would say _abused_. For quite some time it was considered bad to have application-specific config files. Everything was expected to go into the Windows Registry. The pendulum started to swing back the other way now for several years, and we see application-specific config files becoming ever more common. We follow a consensus opinion that it is well to minimise use of the Registry. 

Settings needed by Windows itself _have_ to be stored in the Registry. For example, associating a file extension with your application, so that double clicking on its icon launches your application. 

The APLTree class [WinReg](http://aplwiki.com/WinReg) provides methods for handling the Windows Registry. 

MyApp doesn't need the Windows Registry at this point. We'll store its configurations in configuration files.


## INI, JSON, or XML configuration files? 

Three formats are popular for configuration files: INI, JSON and XML. INI is the oldest, simplest, and most crude. The other formats offer advantages: XML can represent nested data structures, and JSON can do so with less verbosity. Both XML and JSON depend upon unforgiving syntax: a single typo in an XML document can render it impossible to parse. 

We want configuration files to be suitable for humans to read and write, so you might consider the robustness of the INI format an advantage. Or a disadvantage: a badly-formed XML document is easy to detect, and a clear indication of an error. 

Generally, we prefer simplicity and recommend the INI format where it will serve. 

By using the APLTree class `IniFiles` we get as a bonus additional features:

* Data types (char and number)
* Nested vectors
* Embedded INI files
* Local variables (place holders)


## Where to save an INI file

In the chapter on Logging, we considered the question of where to keep application logs. The answer depends in part on what kind of application you are writing. Will there be single or multiple instances? For example, while a web browser might have several windows open simultaneously, it is nonetheless a single instance of the application. Its user wants to run just one version of it, and for it to remember her latest preferences and browsing history. But a machine may have many users, and each user needs her own preferences and history remembered. 

Our MyApp program might well form part of other software processes, perhaps running as a service. There might be multiple instances of MyApp running at any time, quite independently of each other, each with quite different configuration settings. 

Where does that leave us? We want configuration settings:

As defaults for the application in the absence of any other configuration settings, for all users.
: These must be coded into the application ("Convention over configuration"), so it will run in the absence of any configuration files. But an administrator should be able to revise these settings for a site. So they should be saved somewhere for all users. This filepath is represented in Windows by the `ALLUSERSPROFILE` environment variable. So we might look there for a `MyApp\MyApp.ini` file.

For invocation when the application is launched.
: We could look in the command line arguments for an INI.

As part of the user's profile
: The Windows environment variable `APPDATA` points to the individual user's roaming profile, so we might look there for a `MyApp\MyApp.ini` file. "Roaming" means that no matter which computer a user logs on to in a Windows Domain [^domain] her personal settings, preferences, desktop etc. roams with her. The Windows environment variable `LOCALAPPDATA` on the other hand defines a folder that is saved just locally. Typically `APPDAATA` points to something like `C:\Users\{username}\AppData\Roaming` and `LOCALAPPDATA` to `C:\Users\{username}\AppData\Local`.

I> Note that when a user logs on to another computer all the files in `APPDATA` are syncronized first. Therefore it is not too good an idea to save a logfile in `APPDATA` that will eventually grow large -- that should go into `LOCALAPPDATA`.

From the above we get a general pattern for configuration settings:

1. Defaults in the program code
2. Overwrite from ALLUSERSPROFILE if any
3. If INI in command line, overwrite from it; else overwrite from USERPROFILE

However, for the Cookbook we keep things simple: we look for an INI file that is a sibling of the DYAPP or the EXE for now but will allow this to be overwritten via the command line with something like `INI='C:\MyAppService\MyApp.ini`. We need this when we make MyApp a Windows Scheduled Task, or run it as a Windows Service.


## Let's start

Save a copy of `Z:\code\v05` as `Z:\code\v06` or copy `v06` from the Cookbook's website. We add one line to `MyApp.dyapp`:

~~~
...
Load ..\AplTree\FilesAndDirs
Load ..\AplTree\IniFiles
Load ..\AplTree\OS
...
~~~

You can read `IniFiles`'s documentation in a browser with `]adoc_browse #.IniFiles`.

## The INI file

This is the contents of `code\v04\MyApp.ini`:

~~~
localhome = '%LOCALAPPDATA%\MyApp'

[Config]
debug       = ¯1
Trap        = 1

[Folders]
Logs        = '{localhome}\Log'
Errors      = '{localhome}\Log'

Watch       = ''
Watch       ,='D:\MyAppInput1'
Watch       ,='D:\MyAppInput2'

[Ride]
Active      = 0
Port        = 4502
~~~

If you have not copied `v05` from the website make sure you create an INI file with this contents as a sibling of the DYAPP.

Notes:

* Assignments above the first section -- which is `[Config]` -- are variables local to the INI file. We can refer to them by putting curlies (`{}`) around their names as with `{localhome}` but they have no other purpose. You can see that `localhome` is referred to twice in the `[Folders]` section, and why that is useful.

* `Debug` is set to ¯1 -- it is indeed going to be a numeric value because there are no quotes involved. `debug` defines whether the application runs in debug mode or not. Most importantly `debug←1` will switch off global error trapping, something we will soon introduce. `¯1` means that the INI file does not set the flag. Therefore it will default to 1 in a development environment and to 0 in a runtime evenvironment. By setting this to either 1 or 0 in the INI file you can overwrite this.

* `Trap` can be used to switch off error trapping globally. It will be used in statements like `:Trap G.Traps/0`. What the `G` stands for we will discuss in a minute.

* `Accents` is set as an empty vector but then values are added with `,=`. That means that `Accents` will be a vtv: a vector of text vectors. Same as before: it has always been a global variable, but now it is more clearly defined as such. Since we define the default to be the same as what the INI file contains anyway it makes not too much sense but it illustrates a second -- better?! -- way of dealing with global variables.

* `Logs` defines the folder were MyApp will save its log files.

* `Errors` defines the folder were MyApp will save crash information later on when we establish global error handling.

* The `[Ride]` section is useful when a stand-alone EXE does not do what it's expected to do but everything works fine in the development version of Dyalog. In that case you have to debug your EXE, and Ride will help you in doing this. We will discuss this topic in the next chapter.


## Initialising the workspace

We create a new function `CreateGlobals` for that:

~~~
∇ G←CreateGlobals dummy;myIni;iniFilename
  G←⎕NS''
  G.⎕FX'r←∆List' 'r←{0∊⍴⍵:0 2⍴'''' ⋄ ⍵,[1.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2'
  G.Debug←A.IsDevelopment
  G.Trap←1
  G.Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'
  G.LogFolder←'./Logs'
  G.DumpFolder←'./Errors'
  G.Watch←''  ⍝ not used yet
  iniFilename←'expand'F.NormalizePath'MyApp.ini'
  :If F.Exists iniFilename
      myIni←⎕NEW ##.IniFiles(,⊂iniFilename)
      G.Debug{¯1≡⍵:⍺ ⋄ ⍵}←myIni.Get'Config:debug'
      G.Trap←⊃G.Trap myIni.Get'Config:trap'
      G.Accents←⊃G.Accents myIni.Get'Config:Accents'
      G.LogFolder←⊃G.LogFolder myIni.Get'Folders:Logs'
      G.DumpFolder←⊃G.DumpFolder myIni.Get'Folders:Errors'
      G.Watch←⊃G.Watch myIni.Get'Folders:Watch'
  :EndIf
∇
~~~

What the function does:

* First it creates an unnamed namespace and assigns it to `G` (for "Globals").
* It then fixes a function `∆List` inside `G`.
* It then populates `G` with the defaults for all the globals we are going to use.
* It then creates a name for the INI file and checks whether such an INI file exists
* If that is the case then it instatiates the INI file and then copies all values it can find from the INI file to `G`.

Notes 

* The `Get` function requires a section and a key as right argument. They can be provided either as a two-item vector as in `'Config' 'debug'` or as a text vector with section and key separated by a colon as in `'Config:debug'`.

* `Get` requires a given section to exist, otherwise it will throw an error. It is tolerant in case a given key does not exist in case a left argument is provided: in that case the left argument is considered a default and returned by `Get`. In case no left argument was specified an error is thrown.

* In case you cannot be sure whether a section/key combination exists (a typical problem when after an update a newer version of an application hits an old INI file) you can check with the `Exist` method.
  
The built-in function `∆List` comes handy when you want to check the contents of `G`:

~~~
      G.∆List
 Accents      ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ  AAAAAACDEEEEIIIINOOOOOOUUUUY  
 Debug                                                                  0 
 DumpFolder                          C:\Users\kai\AppData\Local\MyApp\Log 
 LogFolder                           C:\Users\kai\AppData\Local\MyApp\Log 
 Trap                                                                   1 
 Watch                                                                    
~~~
  
Now that we have moved `Accents` to the INI file we can get rid of these lines in the `MyApp` script:

~~~
⍝ === VARIABLES ===

    Accents←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ' 'AAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===
~~~

Where should we call `CreateGlobals` from? Surely that has to be `Initial`:

~~~
∇ (G MyLogger)←Initial dummy
⍝ Prepares the application.
⍝ Side effect: creates `MyLogger`, an instance of the `Logger` class.
  #.⎕IO←1 ⋄ #.⎕ML←1 ⋄ #.⎕WX←3 ⋄ #.⎕PP←15 ⋄ #.⎕DIV←1
  G←CreateGlobals ⍬
  MyLogger←OpenLogFile G.LogFolder
  MyLogger.Log↓⎕FMT G.∆List
∇
~~~

Note that we also changed what `Initial` returns: a vector of length two, the globals namespace `G` but also the instance of the MyLogger class.

`Initial` was called within `StartFromCmdLine`, and we are not going to change this but we must change the call as such because now it returns something useful:

~~~
∇ {r}←StartFromCmdLine arg;MyLogger;G
⍝ Needs command line parameters, runs the application.
    r←⍬
    (G MyLogger)←Initial ⍬
    r←TxtToCsv arg
∇
~~~

Although both `MyLogger` as well as `G` are kind of global and not passed as arguments it helps to assign them this way rather then hide the statement that creates them somewhere down the stack. This way it's easy to see where they are coming from. 

We now need to think about how to access `G` from within `TxtToCsv`.

## What we think about when we think about encapsulating state

The globals, including `Accents`, are now collected in the namespace `G`.  That namespace is not passed explicitly to `TxtToCsv` but is needed by `CountLetters` which is called by `TxtToCsv`. We have two options here: we can pass a reference to `G` to `TxtToCsv`, for example as left argument, and `TxtToCsv` in turn can pass it to `CountLetters`. The other option is that `CountLetters` just assumes the `G` is around and has a variable `Accents` in it:

~~~
CountLetters←{
    {⍺(≢⍵)}⌸⎕A{⍵⌿⍨⍵∊⍺}G.Accents U.map A.Uppercase ⍵
}
~~~

Yes, that's it. Bit of a compromise here. Let's pause to look at some other ways to write this:

* Passing everything through function arguments does not come with a performance penalty. The interpreter doesn't make 'deep copies' of the arguments unless and until they are modified in the called function (which we hardly ever do) -- instead the interpreter just passes around references to the original variables. 
* So we could pass `G` as a left argument of `TxtToCsv`, which then simply gets passed to `CountLetters`. No performance penalty for this, as just explained, but now we've loaded the syntax of `TxtToCsv` with a namespace it makes no direct use of, an unnecessary complication of the writing. And we've set a left argument we (mostly) don't want to specify when working in Session mode.

The matter of _encapsulating state_ -- which functions have access to state information, and how it is shared between them -- is very important. Poor choices can lead to tangled and obscure code. 

From time to time you will be offered (not by us) rules that attempt to make the choices simple. For example: _never communicate through globals_. (Or semi-globals.[^semi]) There is some wisdom in these rules, but they masquerade as satisfactory substitutes for thought, which they are not. Just as in a natural language, any rule about writing style meets occasions when it can and should be broken. Following style 'rules' without considering the alternatives will from time to time have horrible results, such as functions that accept complex arguments only to pass them on unexamined to other functions. 

Think about the value of style 'rules' and learn when to apply them. 

One of the main reasons why globals should be used with great care is that they can easily be confused with local variables with similar or -- worse --  the same name. By encapsulating all globals in `G` we get around this, and with a proper search tool like Fire [^fire] it is easy to get a report on all lines to refer to anything in `G`, or set it.

Sometimes it's only after writing many lines of code that it becomes apparent that a different choice would have been better. And sometimes it becomes apparent that the other choice would be so much better that it's worth unwinding and rewriting a good deal of what you've done. (Then be glad you're writing in  a terse language.) 

We share these musings here so you can see what we think about when we think about encapsulating state; and also that there is often no clear right answer. Think hard, make your best choices, and be ready to unwind and remake them later if necessary. 

## The IniFiles class

We have used the most important features of the `IniFiles` class, but it has more to offer. We just want to mention some major topics here.

* The `Get` method can be used to list sections of even everything:

  ~~~
        myIni.Get 'Config' ⍬
   Debug                                                               0 
   Trap                                                                1 
   Accents   ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝ  AAAAAACDEEEEIIIINOOOOOOUUUUY        
        ⍴myIni.Get ⍬ ⍬
   7 3
  ~~~
  
  The first column contains per row a section name or an empty vector, the second one a key or an empty vector and the third one a value or an empty vector.

* Instead of using the `Get` method you can also use indexing:

  ~~~
        myIni[⊂'Config:debug']
  0
        myIni['Config:debug' 'Folders:']
   0   %LOCALAPPDATA%\MyApp\Log  %LOCALAPPDATA%\MyApp\Log  
  ~~~
  
* You can actually assign a value to a key with the index syntax and save the INI file by calling the `Save` method. However, you should _only_ use this to write default values to an INI file, typically in order to create one. An INI file is not a database and should not be abused as such.

* We instantiated the `IniFiles` class with the statement `myIni←⎕NEW ##.IniFiles(,⊂iniFilename)` but you can actually specify more than just one INI file. Let's assume that your computer's name is "Foo" then this:

  ~~~
  myIni←⎕NEW ##.IniFiles('MyApp.ini' 'Foo.ini')
  ~~~
 
  would create a new instance which contains all definitions. In case of a name conflict the last one wins. In this case this would mean that machine specific definitions would overwrite more general ones.
  
* Sometimes it is more appropriate to have a namespace representing the INI file as such, with sub namespaces representing the sections and variables within them representing the keys and values. This can be achieved by using the instance method `Convert`. See `]ADOC_Browse #.IniFiles` for details.

## Final steps for version 5

We need to change the `Version` function:

~~~
∇ r←Version
   ⍝ * 1.2.0:
   ⍝   * The application now honours INI files.
   ⍝ * 1.1.0:
   ⍝   * Can now deal with non-existent files.
   ⍝   * Logging implemented.
   ⍝ * 1.0.0
   ⍝   * Runs as a stand-alone EXE and takes parameters from the command line.
      r←(⍕⎕THIS)'1.2.0' '2017-02-26'
∇
~~~

And finally we create a new standalone EXE as before and run it to make sure that everything keeps working. (Yes, we need test cases)
 
[^domain]: <https://en.wikipedia.org/wiki/Windows_domain>

[^semi]: So-called _semi-globals_ are variables to be read or set by functions to which they are not localised. They are _semi-globals_ rather than globals because they are local to either a function or a namespace. From the point of view of the functions that do read or set them, they are indistinguishable from globals -- they are just mysteriously 'around'. 

[^fire]: FiRe stands for _Find and Replace_. It is a powerful tool for both search and replace operations in the workspace. It is also a member of the APLTree Open Source Library. For details see <http://http://aplwiki.com/Fire>.