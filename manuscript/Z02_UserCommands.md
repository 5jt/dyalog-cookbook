{:: encoding="utf-8" /}
[parm]:title  = 'User CMDs'


# Appendix 2 --- User commands


## Overview

User commands are a great way to make utilities available to the developer without cluttering the workspace. They also allow you to have one code base for several Dyalog installations. Since its introduction they have proven to be be indispensable.

Whether you want to write your own user commands or to make use of any third-party user commands like those available from the APL wiki for download [^wiki], you need to consider your options how to integrate non-Dyalog user commands into your development environment.

The default folder depends on your version of Dyalog of course, but you can always find out from a running instance of Dyalog APL:

~~~
      '"',(2⎕NQ # 'GetEnvironment' 'Dyalog'),'\SALT\spice\"'
"C:\Program Files\Dyalog\Dyalog APL-64 16.0 Unicode\SALT\spice\"
~~~

The above is the default folder for the 64-bit Unicode version of Dyalog 16.0 for all Dyalog user commands available within that version.


## Using the default folder

If you want to keep life simple the obvious choice seems to be this folder: you just copy your user command into this folder and it becomes available straight away.

Simple may it be, but this is _not_ recommended:

* When a new version of Dyalog comes along you need to copy your own stuff over.
* When you use more than one version of Dyalog in parallel you have to maintain several copies of your user commands.
* Because of Microsoft's security measures, writing to that folder requires admin rights.

For these reasons you are advised to use a different folder.


## Use your own dedicated folder

Let's assume that you have a folder `C:\MyUserCommands` that's supposed to hold all non-Dyalog user commands. Via the "Options > Configure" command you can select the "User Commands" tab and add that folder to the search path; don't forget to press the "Add" button once you have browsed to the right directory.

If you use several versions of Dyalog in parallel then you are advised _not_ to add that folder via the configuration dialog box in each of those versions. Instead we recommend to write an APL function that adds the folder to all versions of Dyalog currently installed. See the chapter "The Windows Registry" where this scenario is used as an example.


## Name clashes

If two user commands share the same name the last definition wins. You can achieve this only by having a user command "Foo" in two different scripts in different folders _with the same group name, or no group name at all!_

In other words, the full name of a user command is compiled by the group name (say "foo") and the user comand name (say "goo"): `]foo.goo`. However, as long as there is only one user command `goo` this will do nicely:

~~~
      ]goo
~~~


## Group name

Group names are not only useful in order to avoid name clashes, they also allow user commands to be, well, grouped in a sensible way. Whether you should add your own user commands to any of the groups Dyalog comes with is a diffult question to answer. There are pros and cons:

### Pros

+ Keeping the number of groups small is a good idea. 
+ When a user command clearly belongs to such a group, where else should it go anyway?

### Cons

- You might miss on a new Dyalog user command because of a _real_ name clash.
- Your own stuff and the Dyalog stuff are mixed up.


## Updates

Note that once you've copied a new user command into that folder it is available straight away, even in instances of Dyalog that have already been running. However, auto-complete does not know about the new user command until it was called for the first time in an already running instance. You can at any time execute `]ureset` to make sure that even auto-complete knows about it.

In case you change an existing user command, for example by modifying the parsing rules, you must execute `]ureset` in order to get access to the changes from any instance of Dyalog that has already been running by then.


## Writing your own user commands

It's not difficult to write your own user commands, and there is an example script available that makes that easy and straightforward. However, if your user command is not too simple consider developing it as an independent application, living in a particular namespace (let's assume `Foo`) in a particular workspace (let's assume `Goo`). Then write a user command that creates a namespace local to the function in the user command script, copy the namespace `Foo` from the workspace `Goo` into that local namespace and finally run the required function. Make sure the workspace is a sibling of the user command script.

This approach has the advantage that you can develop and test your user commands independently from the user command framework. This is particularly important because changing a user command script from the Tracer is a bit dangerous; you will see more aplcores than under normal circumstances. On the other hand it is difficult to execute the user command without the user command framework calling it: you need those arguments and sometimes even variables that live in the parent (`##`).
  
You are therefore advised to make sure that no function in `Foo` relies on anything provided by the user command framework. Instead the calling function (`Run` in your user command) must pass such values as arguments to any functions in `Foo` called by `Run`. That makes it easy to test all the public functions in `Foo`. Of course you should have proper test cases for them.

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

* The user command refers to `##.SourceFile`; this is a variable created by SALT that carries the full path of the currently executed user command. By taking just the directory part we know where to find the workspace.
* We create an unnamed namespace and assign it to a variable `ref`. We make sure that `Foo` is copied _into_ `ref` by executing `ref.⎕CY`.
* The user command's `Run` function extracts the argument and the optional flag and passes both of them as arguments to the function `Foo.Run`. That way `Foo` does not rely on anything but the arguments passed to its functions.
* We have implemented the user command as a namespace. It could have been a class instead but in this case that does not offer any benefits since all functions are public anyway.

The workspace `Goo` can be tested independently from the user command framework, and the workspace `Goo` might well hold test cases for the functions in ` Foo`.


[^wiki]:Dyalog user commands from the APL wiki  
<http://aplwiki.com//CategoryDyalogUserCommands>