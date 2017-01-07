{:: encoding="utf-8" /}

Package MyApp as an executable
===========================

For Version 1.0 we'll package `MyApp` as an EXE. Version 1.0 will run from the command line and it will run 'headless' -- without a user interface (UI). It won't have a session either. 

## Output to the session log

What happens to values that would otherwise be written in the session log? They disappear. That’s not actually a problem, but it is tidy to catch anything that would otherwise be written to the UI, including empty arrays. 

`TxtToCsv` has a shy result, so it won't write its result to the session. That’s fine. 

We'll also fix three key environment variables for it in `MyApp`:

~~~
(⎕IO ⎕ML ⎕WX)←1 1 3 ⍝ environment variables
~~~


## Reading arguments from the command line 

`TxtToCsv` needs an argument. The EXE must take it from the command line. We'll give `MyApp` a niladic function `StartFromCmdLine`. The DYAPP will use it to start the program:

~~~
Target #
Load Constants
Load Utilities
Load MyApp
Run MyApp.SetLX
~~~

and in `MyApp.dyalog`:

~~~
    ∇ SetLX
   ⍝ Set Latent Expression in root ready to export workspace as EXE
    #.⎕LX←'MyApp.StartFromCmdLine'
    ∇

    ∇ StartFromCmdLine;args
   ⍝ Read command parameters, run the application
      {}TxtToCsv 2⊃2↑⌷2 ⎕NQ'.' 'GetCommandLineArgs'
    ∇
~~~

This is how MyApp will run when called from the Windows command line. 

We're now nearly ready to export the first version of our EXE. 

1. From the File menu pick *Export*. 
2. Pick `Z:\` as the destination folder. 
3. From the list *Save as type* pick *Standalone Executable*. 
4. Set the *File name* as `MyApp`.
5. Check the *Runtime application* and *Console application* boxes.
6. Click *Save*. 

You should see an alert message: _File Z:\\MyApp.exe successfully created._ (This occasionally fails for no obvious reason. If it does, delete or rename any prior version and try again.) 

T> Use the *Version* button to bind to the EXE information about the application, author, version, copyright and so on. Specify an icon file to replace the Dyalog icon with one of your own. 

Let's run it. From a command line:

~~~
c:\Users\A.N. Other>CD Z:\
Z:\>MyApp.exe texts\en
~~~

Looking in Windows Explorer at `Z:\texts\en.csv`, we see its timestamp just changed. Our EXE works! 


