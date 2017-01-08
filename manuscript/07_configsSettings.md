{:: encoding="utf-8" /}

# Configuration settings

Right now our MyApp program counts only Latin letters, ignores case and maps accented characters to their unaccented correspondents. That makes it of less use for French and German texts and of no use at all for Greek or Japanese texts. Other alphabets are possible. They could be supplied with the EXE as alphabet DATs and selected with command-line options. The user could supplement them with her own alphabet DATs. The default alphabet could be any one of the alphabet DATs. Or we might store all the alphabets as a single XML document. 

Thinking more widely, an application's configuration includes all kinds of state: e.g., window positions, recent filepaths, and GUI themes. 

In the chapter on Logging, we considered the question of where to keep application logs. The answer depends in part on what kind of application you are writing. Will there be single or multiple instances? For example, while a web browser might have several windows open simultaneously, it is nonetheless a single instance of the application. Its user wants to run just one version of it, and for it to remember her latest preferences and browsing history. But a machine may have many users, and each user needs her own preferences and history remembered. 

Our MyApp program might well form part of other software processes, perhaps running as a service. There might be multiple instances of MyApp running at any time, quite independently of each other, each with quite different configuration settings. 

Where does that leave us? We want configuration settings:

As defaults for the application in the absence of any other configuration settings
: These must be coded into the application, so it will run in the absence of any configuration files. But an administrator should be able to revise these settings for a site. So they should be saved somewhere for all users. This filepath is represented in Windows by the `ALLUSERSPROFILE` environment variable. So we might look there for a `MyApp\MyApp.ini` file.

As part of the user's profile
: The Windows environment variable `USERPROFILE` points to the individual user's profile, so we might look there for a `MyApp\MyApp.ini` file. 

For invocation when the application is launched.
: We can look in the command line arguments for an INI. 

From the above we get a general pattern for configuration settings:

1. Set from program code
2. Overwrite from ALLUSERSPROFILE if any
3. If INI in command line, overwrite from it; else overwrite from USERPROFILE


## Using the Windows Registry

The Windows Registry is held in memory, so it is fast to read. It has been widely used to store configuration settings. Many would say _abused_. We follow a consensus opinion that it is well to minimise use of the Registry. 

Settings needed by Windows itself _have_ to be stored in the Registry. For example, associating a file extension with your application, so that double clicking on its icon launches your application. 

The APLTree class [WinReg](http://aplwiki.com/WinReg) provides methods for handling the Windows Registry. 

MyApp doesn't need the Windows Registry at this point. We'll store its configurations in configuration files.


## INI, JSON, or XML configuration files? 

Three formats are popular for configuration files: INI, JSON and XML. INI is the oldest, simplest, and most crude. The other formats offer advantages: XML can represent nested data structures, and JSON can do so with less verbosity. Both XML and JSON depend upon unforgiving syntax: a single typo in an XML document can render it impossible to parse. 

We want configuration files to be suitable for humans to read and write, so you might consider the robustness of the INI format an advantage. Or a disadvantage: a badly-formed XML document is easy to detect, and a clear indication of an error. 

Generally, we prefer simplicity and recommend the INI format where it will serve. 

By using the APLTree class `IniFiles` we get as a bonus additional features:

* Data types (Char and number)
* Nested vectors
* Embedded INI files
* Local variables (place holders)


## Parameters for MyApp

We'll introduce some choices for MyApp that can then be set by configuration parameters.

`ACCENTED`
: A flag to control whether accented characters are distinguished, or mapped to their unaccented forms. By default, this will be off. 

`ALPHABETS`
: We'll furnish MyApp with a repertoire of named alphabets, and allow more alphabets to be defined in configuration files. 

`ALPHABET`
: By default, MyApp will use the English alphabet. But we'll allow another default language to be configured. 

`OUTPUT`
: Output has so far been to a CSV eponymous with and sibling to the source. Now that can be specified. 

`SOURCE`
: So far, the source files have been specified either in the APL session, or in the Windows command line. But it might be convenient for a program calling `MyApp.exe` to specify everything in an INI file, so we'll make the source a configurable parameter. 


## Configuration _à la mode_

Distinguish two modes in which we run the MyApp code:

Application mode
: The exported EXE is run from the Windows command line.

Session mode
: The application has been assembled by the DYAPP and is being run in the development interpreter.

The mode will determine where we look for configuration parameters.


## Sources of configuration parameters


### Program code

We want MyApp to run in the absence of any external configuration parameters. So the program code must provide default values for all parameters. 


### User profiles

Windows provides filepaths for profiles for both individual users and all users. 

In Application mode, the All Users profile is consulted for defaults.

In Session mode, the User profile is consulted for defaults. 


### Command line

In Application mode, any parameter specified in the command line supersedes other values for that parameter. 

~~~
Z:\code\v04\>MyApp.exe ALPHABET=French ACCENTED=No Z:\texts\fr
~~~

In Session mode, we ignore parameters set on the command line, assuming that they relate to the Dyalog development environment. 

We might also call `MyApp.exe` specifying only an INI of configuration parameters:

~~~
Z:\code\v04>type M:\jobqueue\job008.ini
ALPHABET=French
ACCENTED=No
SOURCE=M:\texts\Rimbaud.txt
Z:\code\v04>MyApp.exe J:\queue\job008.ini OUTPUT=J:\results\out008.csv
~~~

Or we might use INIs as job 'profiles', for example:

~~~
Z:\code\v04>type M:\profiles\p06.ini
ALPHABET=French
ACCENTED=No
Z:\code\v04>MyApp.exe J:\profiles\p06.ini SOURCE=M:\texts\Rimbaud.txt OUTPUT=J:\results\out008.csv
~~~


## Manifest

Here's our manifest for Version 4: `MyApp.dyapp`:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\FilesAndDirs
Load ..\AplTree\HandleError
leanpub-start-insert
Load ..\AplTree\IniFiles
leanpub-end-insert
Load ..\AplTree\Logger
Load Constants
Load Utilities
Load MyApp
leanpub-start-insert
Run MyApp.Start 'Session'
leanpub-end-insert
~~~

We've included IniFiles to the DYAPP's build list. We'll use IniFiles to handle INI files. 

ADOC is useful for reading a class's documentation. The APLTree library scripts all have ADOC documentation. You can read it in a browser: 

~~~
]adoc_browse #.IniFiles
~~~

The DYAPP's `Run` command now calls `MyApp.Start`, specifying the mode. 


## Configuration parameters in program code

We'll start by implementing these parameters in the program code, independently of any external configuration files. Then continue to look for other sources of configuration parameters. A new function `GetParameters` will do that when the application starts, and put the results -- all the configuration parameters -- in `#.MyApp.Params`. 

The INIs can define new alphabets, so we'll put a namsepace `ALPHABETS` inside `#.MyApp.Params`.

~~~
    ∇ p←GetParameters mode;args;fromexe;fromallusers;fromcmdline;fromuser;env;paths;ini;alp
     ⍝ Derive parameters from defaults and command-line args (if any)
     
     ⍝ Application defaults: in the absence of any other values
      (p←⎕NS'').(accented alphabet source)←0 'English' '' ⍝ defaults
      p.ALPHABETS←⎕NS'' ⍝ container for new alphabet definitions
      p.ALPHABETS.English←⎕A
      p.ALPHABETS.French←'AÁÂÀBCÇDEÈÊÉFGHIÌÍÎJKLMNOÒÓÔPQRSTUÙÚÛVWXYZ'
      p.ALPHABETS.German←'AÄBCDEFGHIJKLMNOÖPQRSßTUÜVWXYZ'
      p.ALPHABETS.Greek←'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'
~~~

A> We've arbitrarily supposed here that diacritical marks in classical Greek are guides to pronunciation and are not to be counted as accented characters. 

And we extend our map of accented characters, remembering different characters can look the same:

~~~
    ∆←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝάΆέΈήΉίϊΐΊόΌύϋΎώΏ'
    ACCENTS←↑∆ 'AAAAAACDEEEEIIIINOOOOOOUUUUYΑΑΕΕΗΗΙΙΙΙΟΟΥΥΥΩΩ'
~~~

~~~
    =/⊃¨p.ALPHABETS.(English French) ⍝ A is A
1
    =/⊃¨p.ALPHABETS.(English Greek)  ⍝ A is not Alpha
0
~~~

Setting values in the program code ensures `MyApp.exe` will be able to run in the absence of any external INIs. 

Now we see what is on the command line that called it, and look around for other INIs. 

~~~
      args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'   ⍝ Command Line
      env←U.GetEnv                          ⍝ Windows Environment
~~~

~~~
     ⍝ An INI for this app as a sibling of the EXE
      fromexe←(⊃⎕NPARTS⊃args),⎕WSID,'.INI' ⍝ first arg is source of EXE
     ⍝ First INI on the command line, if any
      fromcmdline←{×≢⍵:⊃⍵ ⋄ ''}{⍵/⍨'.INI'∘≡¨¯4↑¨⍵}(1↓args)
     ⍝ An INI for this app in the ALLUSERS profile
      fromallusers←env.ALLUSERSPROFILE,'\',⎕WSID,'.INI'
     ⍝ An INI for this app in the USER profile
      fromuser←env.USERPROFILE,'\',⎕WSID,'.INI'
~~~

That identifies four possible INIs we might read. Which ones we consult depends on the mode:

~~~
      :Select mode
      :Case 'Application'
          paths←fromexe fromallusers fromcmdline
      :Case 'Session'
          paths←fromexe fromallusers fromuser
      :EndSelect
~~~


## Case and configuration parameters

It looks like we're almost there with configuration parameters. We can create an instance of IniFiles. Its `Convert` method will take a list of INIs, and return a namespace of parameters, with conflicts between the INIs resolved. 

But case gets in the way. 

Windows is case-insensitive, so `ALPHABET=FRENCH`, `alphabet=french`, and `Alphabet=French` should be equivalent.  Any of them has to be interpreted to set the APL variable `alphabet`: in APL, case matters. So we'll loop through the paths. 

We have already defined some alphabets `English`, `French` etc, so we'll set a convention that alphabet names are in title case. 

      :For path :In {⍵/⍨⎕NEXISTS¨⍵}{⍵/⍨×≢¨U.trim¨⍵}paths
         ⍝ Allow INI entries to be case-insensitive
          ini←⎕NEW #.IniFiles(,⊂path)
          vars←U.m2n ini.⎕NL 2
          :For parm :In {⍵/⍨ini.Exist¨'Config:'∘,¨⍵}PARAMS
             ⍝ Alphabet names are title case, eg Greek
              ∆←⊃ini.Get'Config:',parm
              parm p.{⍎⍺,'←⍵'}U.toTitlecase⍣(parm≡'alphabet') ∆
          :EndFor

          :If ini.Exist'Alphabets:'
              ∆←(ini.Convert ⎕NS'') ⍝ breaks if keys are not valid APL names
              a←∆.⍎'ALPHABETS'U.ciFindin U.m2n ∆.⎕NL 9
             ⍝ Alphabet names are title case, eg Russian
              ∆←,' ',a.⎕NL 2 ⍝ alphabet names
              (U.toTitlecase ∆)p.ALPHABETS.{⍎⍺,'←⍵'}a⍎∆
          :EndIf
      :EndFor

For this we've put new functions into `#.Utilities`: `m2n` _matrix to nest_, `ciFind` _case-independent find_, and `toTitlecase`. You can also observe the use of the _power_ operator `⍣` instead of an if/else control structure. 

Finally, in Application mode, we check the command line for any parameters set directly:

~~~
      :If mode≡'Application' ⍝ set params from the command line
      :AndIf ×≢a←{⍵/⍨'='∊¨⍵}args
          ∆←a⍳¨'=' ⋄ (k v)←((∆-1)↑¨a)((∆+1)↓¨a)
          ∆←(≢PARAMS)≥i←⊃⍳/U.toUppercase¨¨PARAMS k
          (⍕PARAMS[∆/i]) p.{⍎⍺,'←⍵'} ∆/v
      :EndIf
~~~


## Checking the agenda

Now that configuration parameters can be specified in INIs, there is more to check. So we pass the entire namespace of parameters to `CheckAgenda` as a left argument. `CheckAgenda` deploys a new error code -- for an invalid alphabet name - and extends its result also to return the collation alphabet, with or without accented characters. 

~~~
    ∇ (exit files alphabet)←params CheckAgenda ffp;fullfilepath;type
      (files alphabet)←'' '' ⍝ error defaults
      fullfilepath←F.NormalizePath ffp
      type←C.NINFO.TYPE ⎕NINFO fullfilepath
      :If 0=≢fullfilepath~' '
      :OrIf ~⎕NEXISTS fullfilepath
          exit←LogError'SOURCE_NOT_FOUND'
      :ElseIf ~type∊C.NINFO.TYPES.(DIRECTORY FILE)
          exit←LogError'INVALID_SOURCE'
leanpub-start-insert
      :ElseIf 2≠params.(ALPHABETS.⎕NC alphabet)
          exit←LogError'INVALID_ALPHABET_NAME'
leanpub-end-insert
      :Else
          exit←EXIT.OK
          :Select type
          :Case C.NINFO.TYPES.DIRECTORY
              files←⊃(⎕NINFO⍠'Wildcard' 1)fullfilepath,'\*.txt'
          :Case C.NINFO.TYPES.FILE
              files←,⊂fullfilepath
          :EndSelect
leanpub-start-insert
          alphabet←params.{(ALPHABETS⍎alphabet)~(~accented)/⍵}ACCENTS[1;]
leanpub-end-insert
      :EndIf
    ∇
~~~


## Initialising the workspace

Checking the agenda requires more or less the same work whether we are starting in Session or in Application mode. That's why the DYAPP (see above) now finishes with: 

~~~
Run MyApp.Start 'Session'
~~~

The validated configuration parameters will be set in a namespace `MyApp.Params`:

~~~
    ∇ Start mode;exit
    ⍝ Initialise workspace for session or application
    ⍝ mode: ['Application' | 'Session']
      :If mode≡'Application'
          ⍝ trap problems in startup
          ⎕TRAP←0 'E' '#.HandleError.Process '''''
      :EndIf
~~~
~~~
      ⎕WSID←'MyApp'
      Params←GetParameters mode
      :Select mode
      :Case 'Session'
          ⎕←'Alphabet is ',Params.alphabet
          ⎕←'Defined alphabets: ',⍕U.m2n Params.ALPHABETS.⎕NL 2
          #.⎕LX←'#.MyApp.Start ''Application''' ⍝ ready to export
      :Case 'Application'
          exit←TxtToCsv Params.source
          Off exit
      :EndSelect
    ∇
~~~


## What we think about when we think about encapsulating state

The configuration parameters are set in `Start` but the `Params` namespace is not passed explicitly to `TxtToCsv`. Perhaps `TxtToCsv` just refers to `Params`?

~~~
    ∇ exit←TxtToCsv fullfilepath;∆;Log;LogError;files;tgt;alpha

    ...

leanpub-start-insert    
      :If EXIT.OK=⊃(exit files alpha)←Params CheckAgenda fullfilepath
leanpub-end-insert    
          Log.Log'Target: ',tgt←(⊃,/2↑⎕NPARTS fullfilepath),'.CSV'
          exit←alpha CountLettersIn files tgt
      :EndIf
      Log.Log'All done'
    ∇
~~~

Yes, that's it. Bit of a compromise here. Let's pause to look at some other ways to write this:

* Let `TxtToCsv` ignore `Params`. It doesn't read or set the contents. `CheckAgenda` can read `Params` instead. But, where we can, we avoid passing information through globals and 'semiglobals'. The exact opposite practice is to pass everything through function arguments. There is no appreciable performance penalty for this. The interpreter doesn't make 'deep copies' of the arguments unless and until they are modified in the called function (which we hardly ever do) -- instead the interpreter just passes around references to the original variables. 
* So we could pass `Params` as a left argument of `TxtToCsv`, which then simply gets passed to `CheckAgenda`. No performance penalty for this, as just explained, but now we've loaded the syntax of `TxtToCsv` with a namespace it makes no direct use of, an unnecessary complication of the writing. And we've set a left argument we (mostly) won't want to specify when working in Session mode. We could make this left argument optional, taking `#.MyApps.Params` as its default. The cost of that is an if/else control statement, setting a value that, er, `TxtToCsv` still isn't reading or setting for itself. (And if we did want to set a left argument for `TxtToCsv` to use in Session mode, it would probably be the name of an alphabet... 

The matter of _encapsulating state_ -- which functions have access to state information, and how it is shared between them -- is very important. Poor choices can lead to tangled and obscure code. 

From time to time you will be offered (not by us) rules that attempt to make the choices simple. For example: _never communicate through globals_. (Or semi-globals.[^semi]) There is some wisdom in these rules, but they masquerade as satisfactory substitutes for thought, which they are not. Just as in a natural language, any rule about writing style meets occasions when it can and should be broken. Following style 'rules' without considering the alternatives will from time to time have horrible results, such as functions that accept complex arguments only to pass them on unexamined to other functions. 

Think about the value of style 'rules' and learn when to apply them. 

Sometimes it's only after writing many lines of code that it becomes apparent that a different choice would have been better. And sometimes it becomes apparent that the other choice would be so much better that it's worth unwinding and rewriting a good deal of what you've done. (Then be glad you're writing in  a terse language.) 

We share these musings here so you can see what we think about when we think about encapsulating state; and also that there is often no clear right answer. Think hard, make your best choices, and be ready to unwind and remake them later if necessary. 


## Accents

We'll retain our map of accented to unaccented characters and convert any accented character _not in the alphabet_ to its unaccented equivalent. 

However, we'll suppose that the diacritical marks in classical Greek are not to distinguish different characters, so we'll extend the accents map to Greek:

~~~
    ∆←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝάΆέΈήΉίϊΐΊόΌύϋΎώΏ' 
    ACCENTS←↑∆ 'AAAAAACDEEEEIIIINOOOOOOUUUUYΑΑΕΕΗΗΙΙΙΙΟΟΥΥΥΩΩ'
~~~

Note that for Greek this will map Á to the Greek Alpha, not the visually indistinguishable Roman A.

~~~
      '.*'[1+#.MyApp.(ACCENTS∊Params.ALPHABETS.Greek)]
.............................................
............................*****************
~~~

Where and how shall we set the alphabet to be used? We start by revising `CountLetters` to take an alphabet as left argument. And now that the alphabet is explicit, it makes sense to sort the result into alphabetical order. 

~~~
      CountLetters←{
          accents←↓ACCENTS/⍨~ACCENTS[2;]∊⍺ ⍝ ignore accented chars in alphabet ⍺
          ⍺{⍵[⍺⍋⍵[;1];]}{⍺(≢⍵)}⌸⍺{⍵⌿⍨⍵∊⍺}accents U.map U.toUppercase ⍵
      }
~~~

Reality check. From [Project Gutenberg](http://www.projectgutenberg.org/) save the UTF-8 text files for Homer's _Iliad_ and _Odyssey_ in Greek. Top and tail them in a text editor to remove the English-language header and licence. That will still leave a few stray Roman characters, and lots of line numbers:

~~~
      )CS #.MyApp
#.MyApp
      ≢il←⊃⎕NGET 'Z:\texts\gr\iliad.txt'
679693
      ⎕A ⎕D CountLetters¨⊂il
 B 1  0 1459 
 C 1  1  766 
 D 1  2  791 
 E 4  3  775 
 H 1  4  727 
 I 1  5 1749 
 K 1  6  455 
 L 5  7  444 
 O 6  8  359 
 P 1  9  316 
 R 2         
 S 2         
 T 2         
 V 1         
~~~

But most of it is in the Greek alphabet:

~~~
      Params.ALPHABETS.Greek CountLetters il
Α 50459
Β  4533
Γ  8955
Δ  7535
Ε 29370
Ζ  2132
Η 10347
Θ  5346
Ι 34425
Κ 20629
Λ 13520
Μ 16659
Ν 28182
Ξ  2655
Ο 41993
Π 17518
Ρ 21353
Σ 38822
Τ 41108
Υ 14682
Φ  6165
Χ  7085
Ψ   794
Ω  5877
~~~


## Putting it together

For our first 'sea trial' we'll use an INI file to define the Russian alphabet, and specify it to count the letter frequency in a [poem by Pushkin](http://www.gutenberg.org/ebooks/5316). 

One INI should define everything we need:

~~~
[CONFIG]
ALPHABET=RUSSIAN
SOURCE=Z:\TEXTS\PUSHKIN.TXT
[ALPHABETS]
RUSSIAN=АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ
~~~

Happily, Wikipedia assures us we have no accented characters to handle. 

We'll save the INI in the All-users Profile:

~~~
      ⎕CMD 'echo %allusersprofile%'
C:\ProgramData
~~~

i.e. in `C:\ProgramData\MyApp.ini` and test in Session mode. 

~~~
clear ws
Booting Z:\code\v04\MyApp.dyapp
Loaded: #.APLTreeUtils
Loaded: #.FilesAndDirs
Loaded: #.HandleError
Loaded: #.IniFiles
Loaded: #.Logger
Loaded: #.Constants
Loaded: #.Utilities
Loaded: #.MyApp
Alphabet is Russian
Defined alphabets:  English  French  German  Greek  Russian 
      MyApp.TxtToCsv 'Z:\texts\ru'
0
~~~

And the result? In `Z:\texts\ru.csv`:

~~~
А,109
Б,22
В,57
Г,19
Д,32
Е,101
Ж,13
З,16
И,61
Й,29
К,48
Л,45
М,30
Н,75
О,99
П,34
Р,58
С,76
Т,87
У,42
Ф,2
Х,14
Ц,4
Ч,10
Ш,12
Щ,6
Ы,31
Ь,18
Э,2
Ю,7
Я,26
~~~

Looks like a win.


[^semi]: So-called _semi-globals_ are variables to be read or set by functions to which they are not localised. They are _semi-globals_ rather than globals because they are local to either a function or a namespace. From the point of view of the functions that do read or set them, they are indistinguishable from globals -- they are just mysteriously 'around'. 