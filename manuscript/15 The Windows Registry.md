{:: encoding="utf-8" /}
[parm]:title='Registry'

# The Windows Registry

## What is it, actually?

We cannot say it any better than the Wikipedia [^wikipedia]:

> The Registry is a hierarchical database that stores low-level settings for the Microsoft Windows operating system and for applications that opt to use the Registry. The kernel, device drivers, services, Security Accounts Manager (SAM), and user interface can all use the Registry. The Registry also allows access to counters for profiling system performance.
> 
> In simple terms, The Registry or Windows Registry contains information, settings, options, and other values for programs and hardware installed on all versions of Microsoft Windows operating systems. For example, when a program is installed, a new subkey containing settings like a program's location, its version, and how to start the program, are all added to the Windows Registry.

The Windows Registry is still subject of heated discussions among programmers. Most hate it, some like it, but whatever your opinion is: you cannot ignore it. 

Originally Microsoft designed the database as _the_ source for any configuration parameters, be it for the operating system, users or applications.

The Windows Registry will certainly remain to be the source for any OS-related pieces of information, but for applications we have seen a comeback of the old-fashioned configuration file, be at as an INI, an XML or a JSON file.

Even if you go for configuration files in order to configure your own application, you must be able to read and occasionally also to write to the Windows Registry, if only to configure Dyalog APL in order to make it suit your needs.

The Windows Registry can be useful for any application to store user specific data. For example, if you want to save the current position and size of the main form of your application for every user in order to be able to restore both position and size next time the application is started then the Windows Registry is the prefect place to store theses pieces of information. The key suggests itself:

~~~
HKCU\Software\MyApplication\MainForm\Posn
HKCU\Software\MyApplication\MainForm\Size
~~~

Note that `HKCU` is a short cut for "HKey Current User". There are others, and we will discuss them.

## Terminology

If you find the terminology strange: so do we, but it was invented by Microsoft and therefore defines the standard. 

That is the reason why we go for it: it makes it easier to understand the Microsoft documentation but also to understand others while talking about the Windows Registry. It also helps when you google for Registry tweaks because the guys posting the solution to your problem are most likely using Microsoft speech as well.

Why is the terminology strange? Because Microsoft uses common words but gives them unusual meaning when it comes to the Windows Registry. Let's look at an example. This is the definition of the MAXWS parameter for Dyalog 64 bit Unicode version 16:

![Definition of maxws in the Windows Registry](Images/WinReg_maxws.png)

The full path is:

~~~
Computer\HKEY_CURRENT_USER\Software\Dyalog\Dyalog APL/W-64 16.0 Unicode\maxws
~~~

We can get rid of "Computer" if it is the local machine, and we can shorten "HKEY_CURRENT_USER" as "HKCU". That leaves us with:

~~~
HKCU\Software\Dyalog\Dyalog APL/W-64 16.0 Unicode\maxws
~~~

That looks pretty much like a file path, doesn't it? So what about calling the different parts to the left of `maxws` folders? 

Well, that would be logical, therefore Microsoft did not do that. Instead they call `HKCU` a _key_, although the top level ones are sometimes called _root keys_. The other bits and pieces but `maxws` are called subkeys but sometimes just keys.

Okay, what's `maxws` then? Well it holds a value, so why not call it _key_? Ups, that's been taken already, but maybe "name" or "ID"? Well, Microsoft calls it a _value_. That's a strange name because is _has_ as value, in our example the string `'64000'`.

To repeat: any given path to a particular piece of data stored in the Windows Registry consists of a key, one or more subkeys and a value that is associated with data.

There are a couple of things you should know:

* Keys and subkeys must not contain a backslash character (`\`) but values (!) and data may.
* A subkey may or may not have a _default value_. This is a piece of data that is associated with the subkey, not with a particular value.
* The Microsoft documentation clearly defines the word _key_ for the top level only but later uses _key_ and _subkey_ interchangeably.
* According to the Microsoft documentation both keys and subkeys are case insensitive. That seems to imply that values are case sensitive but they are case insensitive, too.
* Key names are not localized into other languages, although values may be.


## Data types

These days the Windows Registry offers quite a range of data types, but most of the time you can get away with these:

REG_SZ
: The "string" data type. APLers call this a text vector. Both `WinReg` as well as `WinRegSimple` write text vectors as Unicode strings.

REG_DWORD
: A 32-bit number.

REG_BINARY
: Binary data in any form.

REG_MULTI_SZ
: For an APLer this is a vector of text vectors. This data type was not available in the early days of the Windows Registry which is probably why it is not as widely used as you would expect.

REG_QWORD
: A 64-bit number

There are more data types available, but they are not exactly popular.


## Root keys

Any Windows Registry has just 5 root keys:

| Root key            | Shortcut |
|---------------------|----------|
| HKEY_CLASSES_ROOT   | HKCR     |
| HKEY_CURRENT_USER   | HKCU     |
| HKEY_LOCAL_MACHINE  | HKLM     |
| HKEY_USERS          | HKU      |
| HKEY_CURRENT_CONFIG | HKCC    |

From an application programmers point of view the HKCU and the HKLM are the most important ones, and usually the only ones they might actually write to.


### 32/64-bit nightmares

That's what the MSDN has to say about 32-bit and 64-bit applications when it comes to the Windows Registry:

> On 64-bit Windows, portions of the registry entries are stored separately for 32-bit application and 64-bit applications and mapped into separate logical registry views using the registry redirector and registry reflection, because the 64-bit version of an application may use different registry keys and values than the 32-bit version. There are also shared registry keys that are not redirected or reflected.
>
> The parent of each 64-bit registry node is the Image-Specific Node or ISN. The registry redirector transparently directs an application's registry access to the appropriate ISN subnode. Redirection subnodes in the registry tree are created automatically by the WOW64 component using the name Wow6432Node. As a result, it is essential not to name any registry key you create Wow6432Node.
>
> The KEY_WOW64_64KEY and KEY_WOW64_32KEY flags enable explicit access to the 64-bit registry view and the 32-bit view, respectively. For more information, see Accessing an Alternate Registry View.

It's probably best to avoid 32-bit applications and just create 64-bit applications these days if you can. If for any reason you are forced to deliver 32-bit applications then you are advised to read up the details in the MSDN [^deflection].

With the knowledge you have accumulated by now you can probably get away for the rest of your life as an application programmer. If you want to know all the details we recommend the Microsoft documentation [^microsoft].


## The class "WinRegSimple"

The APLTree class `WinRegSimple` is a very simple class that offers just three methods:

* `Read`
* `Write`
* `Delete`

It is also limited to the two data types `REG_SZ` and `REG_DWORD`.

The class uses the Windows Scripting Host (WSH) [^wsh]. It is available on all Windows systems although it can be switched off by group policies, something we have never seen in the wild.

If you just want to read a certain value then this -- very small -- class might be sufficient. For example, in order to read the aforementioned `maxws` value:

~~~
      #.WinRegSimple.Read 'HKCU\Software\Dyalog\Dyalog APL/W-64 16.0 Unicode\maxws'
64000
~~~

You can create a new value as well as a new key with `Write`:

~~~
      #.WinRegSimple.Write 'HKCU\Software\Cookbooktests\MyValue' 1200

~~~

![MyValue](Images/WinReg_MyValue.png)

You can also delete a subkey or a value, but a subkey must be empty:

~~~
      #.WinRegSimple.Delete 'HKCU\Software\Cookbooktests'      
      #.WinRegSimple.Read 'HKCU\Software\Cookbooktests'
      #.WinRegSimple.Read'HKCU\Software\Cookbooktests\MyValue'
1200
      #.WinRegSimple.Delete 'HKCU\Software\Cookbooktests\MyValue'
Unable to open registry key "HKCU\Software\Cookbooktests\MyValue" for reading.
      #.WinRegSimple.Read'HKCU\Software\Cookbooktests\MyValue'
     ∧        
      #.WinRegSimple.Delete 'HKCU\Software\Cookbooktests\'
~~~

Note that in order to delete a subkey you must specify a trailing backslash.

You can also write the default value for a key. For that you must specify a trailing backslash as well. The same holds true for reading a default value:

~~~
      #.WinRegSimple.Write 'HKCU\Software\Cookbooktests\' 'APL is great'
      #.WinRegSimple.Read 'HKCU\Software\Cookbooktests\'
APL is great
~~~

![Default values](Images/WinReg_DefaultValue.png)

Note that whether `Write` writes REG_SZ or a REG_DWORD depends on the data: a text vector becomes "REG_SZ" while a 32-bit integer becomes "REG_DWORD" though Booleans as well as smaller integers are converted to a 32-bit integer. Other data types are rejected.


If the `WinRegSimple` class does not suit your needs then have a look at the `WinReg` class. This class is much larger but has virtually no limitations at all.

To give you idea here the list of methods:

~~~
]adoc WinReg -summary
*** WinReg (Class) ***

Shared Fields:
  ERROR_ACCESS_DENIED
  ...
  REG_SZ
Shared Methods:
  Close
  CopyTree
  DeleteSubKeyTree
  DeleteSubKey
  DeleteValue
  DoesKeyExist
  DoesValueExist
  GetAllNamesAndValues
  GetAllSubKeyNames
  GetAllValueNames
  GetAllValues
  GetDyalogRegPath
  GetErrorAsStringFrom
  GetString
  GetTreeWithValues
  GetTree
  GetTypeAsStringFrom
  GetValue
  History
  KeyInfo
  ListError
  ListReg
  OpenAndCreateKey
  OpenKey
  PutBinary
  PutString
  PutValue
  Version

 ~~~


## Examples

We will use both the `WinReg` class and the `WinRegSimple` class for two tasks:

* Add a specific folder holding user commands to all versions of Dyalog APL installed on the current machine.
* Add pieces of information to the caption definitions for all dialog boxes of all versions of Dyalog APL installed on the current machine.

The functions we develop along the way as well as the variables we need can be found in the workspace `WinReg` in the folder `Z:\code\Workspaces\`.


### Add user command folder

Let's assume we have a folder `C:\MyUserCommands`. We want to add this folder to the list of folders holding user commands. For that we must find out the subkeys of all versions of Dyalog installed on your machine:

~~~
∇ list←GetAllVersionsOfDyalog dummy
[1] ⍝ Returns a vector of text vectors with Registry subkeys for all
[2] ⍝ versions of Dyalog APL installed on the current machine.
[3]   list←#.WinReg.GetAllSubKeyNames'HKCU\Software\Dyalog'
[4]   ⍝ Get rid of "Installed components" etc:
[5]   list←'Dyalog'{⍵/⍨((⍴⍺)↑[2]↑⍵)∧.=⍺}list
∇
      ↑GetAllVersionsOfDyalog ⍬
Dyalog APL/W 14.1 Unicode   
Dyalog APL/W 15.0 Unicode   
Dyalog APL/W 16.0 Unicode   
Dyalog APL/W-64 13.2 Unicode
Dyalog APL/W-64 14.0 Unicode
Dyalog APL/W-64 14.1 Unicode
Dyalog APL/W-64 15.0        
Dyalog APL/W-64 15.0 Unicode
Dyalog APL/W-64 16.0 Unicode
~~~

That's step one. In the next step we need to write a function that adds a folder to the list of user command folders:

~~~
∇ {r}←path Add version;subkey;folders
   r←⍬
   subkey←'HKCU\Software\Dyalog\',version,'\SALT\CommandFolder'
   'Subkey does not exist'⎕SIGNAL 11/⍨1≠#.WinReg.DoesValueExist subkey
   folders←#.WinReg.GetString subkey
   folders←';'{¯1↓¨⍵⊂⍨';'=¯1↓';',⍵}folders,';'
   folders←(({(819⌶)⍵}¨folders)≢¨⊂(819⌶)path)/folders ⍝ drop doubles
   folders←⊃{⍺,';',⍵}/folders,⊂path
   #.WinReg.PutString subkey folders
∇   
~~~

Let's check the current status:

~~~
      dyalogVersions←AllVersionsOfDyalog ''
      ⍪{#.WinReg.GetValue 'HKCU\Software\Dyalog\',⍵,'\SALT\CommandFolder'}¨dyalogVersions
 C:\...\Dyalog APL 14.1 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\
 C:\...\Dyalog APL 15.0 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\
 C:\...\Dyalog APL 16.0 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\
... 
      'C:\MyUserCommands'∘Add¨dyalogVersions
      ⍪{#.WinReg.GetValue 'HKCU\Software\Dyalog\',⍵,'\SALT\CommandFolder'}¨dyalogVersions
      C:\..\Dyalog APL 14.1 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\;C:\MyUserCommands
C:\...\Dyalog APL 15.0 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\;C:\MyUserCommands
C:\...\Dyalog APL 16.0 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\;C:\MyUserCommands
...
      'C:\MyUserCommands'∘Add¨dyalogVersions
      ⍪{#.WinReg.GetValue 'HKCU\Software\Dyalog\',⍵,'\SALT\CommandFolder'}¨dyalogVersions
C:\...\Dyalog APL 14.1 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\;C:\MyUserCommands
C:\...\Dyalog APL 15.0 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\;C:\MyUserCommands
C:\...\Dyalog APL 16.0 Unicode\SALT\Spice;C:\T\UserCommands\APLTeam\;C:\MyUserCommands
~~~

Note that although we called `Add` twice the folder `C:\MyUserCommands` makes an appearance only once. This is because we carefully removed it before adding it.


### Configure Dyalog's window captions

In "[Appendix 4 — The development environment](./53 Appendix 4 — The development environment.html)" we mention that if you run more than once instance of Dyalog in parallel then you want to be able to allocate any dialog box to the instance it was issued from. This can be achieved by adding certain pieces of information to certain entries in the Windows Registry. We talk about this subkey of, say, Dyalog APL/W-64 16.0 Unicode:

~~~
HKCU\Software\Dyalog\Dyalog APL/W-64 16.0 Unicode\Captions
~~~

If that subkey exists (after an installation it doesn't) then it is supposed to contain particular values defining the captions for all dialog boxes that might make an appearance when running an instance of Dyalog. 

So in order to configure all these window captions you have to add the subkey `Chapter` and the required values in one way or another. This is a list of values honoured by version 16.0:

| Editor |
| Event_Viewer |
| ExitDialog |
| Explorer |
| FindReplace |
| MessageBox |
| Rebuild_Errors |
| Refactor |
| Session |
| Status |
| SysTray |
| WSSearch |

Although it is not a big deal to add these values with the Registry Editor we do not recommend this, if only because when the next version of Dyalog comes along then you have to do it again.

Let's assume that you have a variable `captionValues` which is a matrix with two columns: 

* `[;1]` is the name of a value
* `[;2]` is the definition of the caption

That's what `captionValues` may look like:

~~~
      ⍴⎕←values
 Editor          {PID} {TITLE} {WSID}-{NSID} {Chars} {Ver_A}.{VER_B}.{VER_C} {BITS}    
 Event_Viewer    {PID} {WSID} {PRODUCT}                                                
 ExitDialog      {PID} {WSID} {PRODUCT}                                                
 Explorer        {PID} {WSID} {PRODUCT}                                                
 FindReplace     {PID} {WSID}-{SNSID} {Chars} {Ver_A}.{VER_B}.{VER_C} {BITS}           
 MessageBox      {PID} {WSID} {PRODUCT}                                                
 Rebuild_Errors  {PID} {WSID} {PRODUCT}                                                
 Refactor        {PID} {WSID}-{SNSID} {Chars} {Ver_A}.{VER_B}.{VER_C} {BITS}           
 Session         {PID} {WSID}-{NSID} {Chars} {Ver_A}.{VER_B}.{VER_C} {BITS}            
 Status          {PID} {WSID} {PRODUCT}                                                
 SysTray         {PID} {WSID}                                                          
 WSSearch        {PID} {WSID} {PRODUCT}                                                
13 2
~~~

Again, this variable can be copied from the workspace `Z:\code\Workspaces\WinReg`. We are going to write this data to the Windows Registry for all versions of Dyalog installed on the current machine. 

For that we need a list with all versions of Dyalog installed on the current machine. For this we can use the function `GetAllVersionsOfDyalog` we've developed earlier in this chapter:

~~~
   dyalogVersions←GetAllVersionsOfDyalog ''
~~~

Now we write a function that takes a version and the variable `captionValues` as argument and creates a subkey `Captions` with all the values. This time we use `#.WinRegSimple.Write` for this:

~~~
∇ {r}←values WriteCaptionValues version;rk
[1]  r←⍬
[2]  rk←'HKCU\Software\Dyalog\',version,'\Captions\'
[3]  rk∘{#.WinRegSimple.Write(⍺,(1⊃⍵))(2⊃⍵)}¨↓values
∇
~~~
   
We can now write `captionValues` to all versions:

~~~
       captionValues∘WriteCaptionValues¨dyalogVersions
      ⍝ Let's check:
      rk←'HKCU\Software\Dyalog\Dyalog APL/W-64 16.0 Unicode\Captions'
      #.WinReg.GetTreeWithValues rk
0  HKCU\...\Captions\
1  HKCU\...\Editor          {PID} {TITLE} {WSID}-{NSID} {Chars} {Ver_A}.{VER_B}.{VER_C} {BITS}
1  HKCU\...\Event_Viewer    {PID} {WSID} {PRODUCT}
1  HKCU\...\ExitDialog      {PID} {WSID} {PRODUCT}
1  HKCU\...\Explorer        {PID} {WSID} {PRODUCT}
1  HKCU\...\FindReplace     {PID} {WSID}-{SNSID} {Chars} {Ver_A}.{VER_B}.{VER_C} {BITS}
1  HKCU\...\MessageBox      {PID} {WSID} {PRODUCT}
1  HKCU\...\Rebuild_Errors  {PID} {WSID} {PRODUCT}
1  HKCU\...\Refactor        {PID} {WSID}-{SNSID} {Chars} {Ver_A}.{VER_B}.{VER_C} {BITS}
1  HKCU\...\Session         {PID} {WSID}-{NSID} {Chars} {Ver_A}.{VER_B}.{VER_C} {BITS}
1  HKCU\...\Status          {PID} {WSID} {PRODUCT}
1  HKCU\...\SysTray         {PID} {WSID}
1  HKCU\...\WSSearch        {PID} {WSID} {PRODUCT}
~~~


[^wikipedia]: The Wikipedia on the Windows Registry:  
<https://en.wikipedia.org/wiki/Windows_Registry>

[^deflection]: The MSDN on 32-bit and 64-bit applications and the Windows Registry:
<https://msdn.microsoft.com/en-us/library/windows/desktop/ms724072(v=vs.85).aspx>


[^microsoft]: Microsoft on the Windows Registry:  
<https://msdn.microsoft.com/en-us/library/windows/desktop/ms724946(v=vs.85).aspx>


[^wsh]: The Wikipedia on the Windows Scripting Host:  
<https://en.wikipedia.org/wiki/Windows_Script_Host>


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