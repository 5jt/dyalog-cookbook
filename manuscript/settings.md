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

Settings needed by Windows itself _have_ to be store in the Registry. For example, associating a file extension with your application, so that double clicking on its icon launches your application. 

The APLTree class [WinReg](http://aplwiki.com/WinReg) provides methods for handling the Windows Registry. 

MyApp doesn't need the Windows Registry at this point. We'll store its configurations in configuration files.


## INI, JSON, or XML configuration files? 

Three formats are popular for configuration files: INI, JSON and XML. INI is the oldest, simplest, and most crude. The other formats offer advantages: XML can represent nested data structures, and JSON can do so with less verbosity. Both XML and JSON depend upon unforgiving syntax: a single typo in an XML document can render it impossible to parse. 

We want configuration files to be suitable for humans to read and write, so you might consider the robustness of the INI format an advantage. Or a disadvantage: a badly-formed XML document is easy to detect, and a clear indication of an error. 

Generally, we prefer simplicity and recommend the INI format where it will serve. 


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


## Configuration parameters in program code

We'll start by implementing these parameters in the program code, independently of any external configuration files. 


### Alphabets

We'll provide MyApp with some language-specific alphabets. These will include accented characters used in the corresponding languages:

~~~
    :Namespace ALPHABETS
        English←⎕A
        French←'AÁÂÀBCÇDEÈÊÉFGHIÌÍÎJKLMNOÒÓÔPQRSTUÙÚÛVWXYZ'
        German←'AÄBCDEFGHIJKLMNOÖPQRSßTUÜVWXYZ'
        Greek←'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'
    :EndNamespace
~~~

We've arbitrarily supposed here that diacritical marks in classical Greek are guides to pronunciation and are not to be counted as accented characters. 

And we extend our map of accented characters, remembering different characters can look the same:

~~~
    ∆←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝάΆέΈήΉίϊΐΊόΌύϋΎώΏ'
    ACCENTS←↑∆ 'AAAAAACDEEEEIIIINOOOOOOUUUUYΑΑΕΕΗΗΙΙΙΙΟΟΥΥΥΩΩ'
~~~

~~~
    =/⊃¨#.MyApp.ALPHABETS.(English French) ⍝ A is A
1
    =/⊃¨#.MyApp.ALPHABETS.(English Greek)  ⍝ A is not Alpha
0
~~~

We modify how the workspace is initialised, in both Session and Application modes. For this we'll merge `SetLX` and `StartFromCmdLine` into `Start`, as seen here in the DYAPP:

~~~
Target #
Load ..\AplTree\APLTreeUtils
Load ..\AplTree\ADOC
Load ..\AplTree\HandleError
leanpub-start-insert
Load ..\AplTree\IniFiles
leanpub-end-insert
Load ..\AplTree\Logger
Load ..\AplTree\WinFile
Load Constants
Load Utilities
Load MyApp
leanpub-start-insert
Run MyApp.Start 'Session'
leanpub-end-insert
~~~

We've also added ADOC and IniFiles to the DYAPP's build list. We'll use IniFiles to handle INI files. ADOC is useful for reading a class's documentation. We'll come to that later. 

~~~
    ∇ Start mode
    ⍝ Initialise workspace for session or application
    ⍝ mode: ['Application' | 'Session']
      :If mode≡'Application'
          ⍝ trap problems in startup
          ⎕TRAP←0 'E' '#.HandleError.Process ''''' 
      :EndIf
      ⎕WSID←'MyApp'
      Params←GetParameters mode
      :Select mode
      :Case 'Session'
          #.⎕LX←'Start ''Application''' ⍝ ready to export
      :Case 'Application'
          exit←Params TxtToCsv Params.source
          ⎕OFF exit
      :EndSelect
    ∇
~~~

`GetParameters` defines the default parameters. They get passed to `TxtToCsv` as its optional left argument. (That is redundant, since `TxtToCsv` will read them anyway if omitted, but it allows us to substitute other parameter namespaces when testing in Session mode, while stil being able to call the function monadically.) 

We'll start `GetParameters` by defining its default result:

~~~
      (p←⎕NS'').(accented alphabet source)←0 'English' ''
      p.ALPHABETS←⎕NS'' ⍝ container for new alphabet definitions
~~~

Now let's look for other parameter values. We'll be wanting the command line:

~~~
      args←⌷2 ⎕NQ'.' 'GetCommandLineArgs'   ⍝ Command Line
      env←U.GetEnv                          ⍝ Windows Environment
~~~

and via a new function in `#.Utilities`, the Windows environment variables. We also need a list of INI files to read:

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

Which of those we look for and read depends on the mode:

~~~
      :Select mode
      :Case 'Application'
          paths←fromexe fromallusers fromcmdline
      :Case 'Session'
          paths←fromexe fromallusers fromuser
      :EndSelect
~~~

If any of these paths exists, `#.IniFiles.Convert` will merge them and return them as a namespace


We'll retain our map of accented to unaccented characters and convert any accented character _not in the alphabet_ to its unaccented equivalent. 

However, we'll suppose that the diacritical marks in classical Greek are not to distinguish different characters, so we'll extend the accents map to Greek:

~~~
    ∆←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝάΆέΈήΉίϊΐΊόΌύϋΎώΏ' 
    ACCENTS←↑∆ 'AAAAAACDEEEEIIIINOOOOOOUUUUYΑΑΕΕΗΗΙΙΙΙΟΟΥΥΥΩΩ'
~~~

Note that for Greek this will map Á to the Greek Alpha, not the visually indistinguishable Roman A.

~~~
      #.MyApp.(ACCENTS∊ALPHABETS.GREEK)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
~~~

Where and how shall we set the alphabet to be used? We start by revising `CountLetters` to take an alphabet as left argument. And now that the alphabet is explicit, it makes sense to sort the result into alphabetical order. 

~~~
      CountLetters←{
          accents←↓ACCENTS/⍨~ACCENTS[2;]∊⍺ ⍝ ignore accented chars in alphabet ⍺
          ⍺{⍵[⍺⍋⍵[;1];]}{⍺(≢⍵)}⌸⍺{⍵⌿⍨⍵∊⍺}accents U.map U.toUppercase ⍵
      }
~~~

Reality check. From [Project Gutenberg]{http://www.projectgutenberg.org/) save the UTF-8 text files for Homer's Iliad and Odyssey in Greek. Top and tail them in a text editor to remove the English-language header and licence. That will still leave a few stray Roman characters, and lots of line numbers:

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
      ALPHABETS.GREEK CountLetters il
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

We make `TxtToCsv` ambivalent, so we can test it in the session with a non-default alphabet. 

~~~
    ∇ exit←{ALPHABET}TxtToCsv fullfilepath;∆;isDev;Log;Error;files;tgt
          ...
leanpub-start-insert
          :If 2≠⎕NC'ALPHABET' ⋄ ALPHABET←ALPHABETS.ENGLISH ⋄ :EndIf
leanpub-end-insert
          exit←ALPHABET CountLettersIn files tgt
          ...
~~~

Simularly we make `CountLettersIn` dyadic and have it call `CountLetters` dyadically. 

~~~
leanpub-start-insert
    ∇ exit←ALPHABET CountLettersIn(files tgt);i;txt;tbl;enc;nl;lines;bytes
leanpub-end-insert
     ⍝ Exit code from writing a letter-frequency count for a list of files
      tbl←0 2⍴'A' 0
      exit←EXIT.OK ⋄ i←1
      :While exit=EXIT.OK
          :Trap 0
              (txt enc nl)←⎕NGET retry i⊃files
leanpub-start-insert
              tbl⍪←ALPHABET CountLetters txt
leanpub-end-insert
          :Else
          ...
~~~

In the above, `TxtToCsv` handles its ambivalence and sets the alphabet if it's called monadically. Other functions that need to refer to the alphabet have it passed them as an argument. So `TxtToCsv` is the only function that need to know the rule that the default alphabet is English. 

Sadly, this won't do. MyApp might be called from the command line in a configuration that sets a _different_ alphabet by default. Some process has to figure all this out, whether MyApp is called from the command line or built by the DYAPP and run in the session. 

We'll change the last line of the DYAPP to run `#.MyApp.InitSession`, which will do the job for the interactive session, before setting the Latent Expression for export. 

