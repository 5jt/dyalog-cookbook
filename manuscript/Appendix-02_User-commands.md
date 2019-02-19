{:: encoding="utf-8" /}
[parm]:title  = 'User CMDs'


# Appendix 2 --- User commands


## Overview

User commands are a great way to make utilities available to the developer without cluttering the workspace. They also allow you to have one code base for several Dyalog installations. Since its introduction they have proven to be be indispensable.

Whether you want to write your own user commands or to make use of any third-party user commands like those available from the APL wiki for download [^wiki], you need to consider your options for how to integrate non-Dyalog user commands into your development environment.

The default folder depends on your version of Dyalog of course, but you can always find out from a running instance of Dyalog APL:

~~~
      '"',(2⎕NQ # 'GetEnvironment' 'Dyalog'),'\SALT\spice\"'
"C:\Program Files\Dyalog\Dyalog APL-64 17.0 Unicode\SALT\spice\"
~~~

The above is the default folder for the 64-bit Unicode version of Dyalog 17.0 for all Dyalog user commands available within that version.


## Where to put user commands


### Using the default folder

If you want to keep life simple the obvious choice is to copy your user command into the folder Dyalog has reserved for this very purpose starting with version 17.0.

It's in `%HOMEDRIVE%%HOMEPATH%\Documents\MyUCMDs`[^envvars]. This folder is scanned automatically by Dyalog at start-up time and when `]URESET` is executed. Any script with the extension `.dyalog` is expected to be a user command class or user command script. This is also true for any sub folders.

Notes:

* User commands in that folder are only available for that specific user, not all users. Naturally it depends on the circumstances whether that's a good thing or a bad thing for you.
* From version 17.0 onwards every version will look into the same folder, so the user command must check itself whether it is compatible with the version it is called from.

For these reasons you might decide to go for a different folder.


### Use your own dedicated folder

Let's assume that you have a folder `C:\MyUserCommands` that's supposed to hold all non-Dyalog user commands. 

Via the _Options > Configure_ command you can select the User Commands dialog and add that folder to the search path; remember to press the _Add_ button once you have browsed to the right directory.

If you use several versions of Dyalog in parallel then you are advised _not_ to add that folder via the configuration dialog box in each of those versions.

Instead we recommend writing an APL function that adds the folder to all versions of Dyalog currently installed. See the chapter [The Windows Registry](./15 The Windows Registry) where this scenario is used as an example. The reason is that you can solve the problem for all installed versions with a single function call, and you can repeat that in case you have to re-install any of the versions.


## Name clashes

Where two user commands share the same name, the last definition wins. You can achieve this just by having a user command Foo in two different scripts in different folders _with the same group name, or no group name at all!_

In other words, the full name of a user command is compiled by the group name (say `foo`) and the user-command name (say `goo`): `]foo.goo`. However, as long as there is only one user command `goo` this will do nicely:

~~~
      ]goo
~~~


## Group names

Group names are not only useful to avoid name clashes, they also allow user commands to be, well, grouped in a sensible way. Whether you should add your own user commands to any of the groups Dyalog comes with is a diffult question to answer. There are pros and cons:

### Pros

+ Keeping the number of groups small is a good idea. 
+ When a user command clearly belongs to such a group, where else should it go anyway?

### Cons

- You might miss on a new Dyalog user command because of a _real_ name clash.
- Your own stuff and the Dyalog stuff are mixed up.


## Updates

Note that once you've copied a new user command into that folder it is available straight away, even in instances of Dyalog that are already running.

However, auto-complete does not know about the new user command until it was called for the first time in an already running instance. You can at any time execute `]ureset` to make sure that even auto-complete knows about it.

In case you change an existing user command, for example by modifying the parsing rules, you must execute `]ureset` in order to get access to the changes from any instance of Dyalog that has already been running by then.


## Writing your own user commands

It's not difficult to write your own user commands, and there is an example script available that makes that easy and straightforward. However, if your user command is not too simple consider developing it as an independent application, living in a particular namespace (let's assume `Foo`) in a particular workspace (let's assume `Goo`).

Then write a user command that creates a namespace local to the function in the user command script, copy the namespace `Foo` from the workspace `Goo` into that local namespace and finally run the required function. Make sure the workspace is a sibling of the user command script.

This approach has the advantage that you can develop and test your user commands independently from the user command framework.

This is particularly important because changing a user command script from the Tracer is a bit dangerous; you will see more aplcores than under normal circumstances. On the other hand it is difficult to execute the user command without the user command framework calling it: you need those arguments and sometimes even variables that live in the parent (`##`).
  
We therefore recommend you ensure no function in `Foo` relies on anything provided by the user-command framework. Instead, the calling function (`Run` in your user command) must pass such values as arguments to any functions in `Foo` called by `Run`. 

That makes it easy to test all the public functions in `Foo`. Of course you should have proper test cases for them.

The following code is a simple example that assumes the following conditions:

* It requires a single argument.
* It offers an optional switch `-verbose`.
* It copies `Foo` from `Goo` and then runs `Foo.Run`.

~~~
:Namespace  Foo
      ⎕IO←1 ⋄ ⎕ML←1

    ∇ r←List
      r←⎕NS''          
      r.Name←'Foo'
      r.Desc←'Does this and that'
      r.Group←'Cookbook'    
      r.Parse←'1 -verbose'
    ∇

    ∇ r←Run(Cmd Args);verbose;ref;path;arg
      ref←⎕NS''
      verbose←Args.Switch'verbose'      
      path←⊃1 ⎕NPARTS ##.SourceFile
      arg←⊃Args.Arguments      
      :Trap 11
          'Foo'ref.⎕CY path,'\Goo'
      :Else
          'Copy operation for "Foo" in "Goo" failed' ⎕Signal 11
      :EndTrap
      r←ref.Foo.Run arg verbose
    ∇

    ∇ r←Help Cmd
      r←⊂'Help for "Foo".'
      r,←⊂'This user command ...'
      r←,[0.5]r
    ∇   

:EndNamespace
~~~

Notes:

* The user command refers to `##.SourceFile`; this is a variable created by SALT with the full path of the currently-executed user command. By taking just the directory part we know where to find the workspace.
* We create an anonymnous namespace and assign it to a variable `ref`. We make sure `Foo` is copied _into_ `ref` by executing `ref.⎕CY`.
* The user command's `Run` function extracts the argument and the optional flag and passes both of them as arguments to the function `Foo.Run`. That way `Foo` does not rely on anything but the arguments passed to its functions.
* We have implemented the user command as a namespace. It could have been a class instead but in this case that offers no benefits, since all functions are public anyway.

The workspace `Goo` can be tested independently from the user command framework, and the workspace `Goo` might well hold test cases for the functions in ` Foo`.


[^wiki]:Dyalog user commands from the APL wiki  
<http://aplwiki.com//CategoryDyalogUserCommands>

[^envvars]: See _Appendix 01 - Windows environment vars_ for details regarding the environment variables used here.


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