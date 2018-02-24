{:: encoding="utf-8" /}
[parm]:title='Introduction'

# Introduction

You want to write a Windows [^win] application in Dyalog APL. You have already learned enough of the language to put some of your specialist knowledge into functions you can use in your work. The code works for you. Now you want to turn it into an application others can use. Perhaps even sell it. 

This is where you need professional programming skills. How to install your code into an unknown computer. Have it catch, handle and log errors. Manage the different versions of your software as it evolves. Provide online help.

You are not necessarily a professional programmer. Perhaps you don't have those skills. Perhaps you need a professional programmer to turn your code into an application. But you’ve come a long way already. Perhaps you can get there by yourself - with _The Dyalog Cookbook_. Alternatively, you might be a professional programmer wondering how to solve these familiar problems in Dyalog APL. 

_The Dyalog Cookbook_ is about how to turn your Dyalog code into an application. We’ll cover packaging your code into a robust environment. And we’ll introduce some software development tools you’ve managed without so far, which will make your life easier.

You might continue as the sole developer of your application for a long time yet. But if it becomes a successful product you will eventually want other programmers collaborating on it. So we’ll set up your code in a source-control system that will accommodate that. Even while you remain a sole developer, a source-control system will also allow you to roll back and recover from your own mistakes. 

Not so long ago it was sufficient for an application to be packaged as an EXE that could be installed and run on other PCs. Nowadays many corporate clients run programs in terminal servers or in private clouds. So we’ll look at how to organise your program to run as tasks that communicate with each other. 

Many applications written in Dyalog focus on some kind of numerical analysis, and can have CPU-intensive tasks. We'll look at how such tasks can be packaged to run either in background or on remote machines. 


## Method

It’s conventional in this context for authors to assure readers that the techniques expounded here have been hammered out, proven and tested in many successful applications. That is true of individual components here, particularly of scripts and applications from the APLTree [^apltree] library. 

But the development tools introduced by Dyalog in recent years are still finding their places with development teams. Some appear here in print for the first time. This book is the first sustained attempt to combine all the current Dyalog tools into an integrated approach. 

Many of the issues addressed here are entangled with each other. We’ll arrive at our best solutions by way of interim solutions. Proposing some wickedly intricate ‘complete solution’ framework does little to illuminate the problems it solves. So we’ll add features -- INI files, error handling, and so on -- one at a time, and as we go we’ll find ourselves revisiting the code that embeds the earlier features. 

We will also improve the code along the way, while explaining why exactly the changes are improvements.

That is the method for chapters 1 – 14. Later chapters stand on their own.

If you are an experienced Dyalog developer, you may be able to improve on what is described here. For this reason _The Dyalog Cookbook_ remains for now [an open-source project on GitHub](https://github.com/5jt/dyalog-cookbook). 

Working through the book, you get to understand how the implementation issues, and the solutions to them, work. In the first chapters you will find ‘framework’ code for your application, growing more complex as the book progresses. You can find scripts for these interim versions in the `code` folder on the book website. Watch out: they are _interim_ solutions, constantly improved along the way.

You are of course welcome simply to copy and use the last version of the scripts. But there is much to be learned while stumbling. 

Later on we’ll introduce some professional writing techniques that might make maintaining your code easier – in what we hope will be a long useful future for it. This includes third-party tools, configuring your development environment and discussing user commands.


## What you need to use the Dyalog Cookbook

* The Dyalog Version 16.0 Unicode interpreter or later.

* Microsoft Windows 10

* Good knowledge of APL – the Cookbook is by no means an introduction.
  
* To know how to use namespaces, classes and instances. The utility code in the Cookbook is packaged as namespaces and classes. 
  This is the form in which it is easiest for you to slide the code into your app without name conflicts. 

  We recommend you use classes to organise your own code [^classes]. But even if you don’t, you need to know at least how to use classes. This is a deep subject, but all you need to know is the basics: how to call the static methods of a class (sufficient in most cases) or how to create an instance of a class and use its methods and properties. 
  
  See _Dyalog Programmer’s Reference Guide_ for an introduction. 

* A good understanding of SALT, Dyalog’s built-in code-management system that allows you to load and save scripts either automatically in the background or at will.
  
* Internet access. Not necessarily all the time, but probably most of the time. Not only because it gives you access to the [APL wiki](http://aplwiki.com) and the Dyalog forum (see below) but mainly for accessing the APLTree tools and this book’s web site: <https://cookbook.dyalog.com>.

  However, we have also tried to write the book so that you can just read it – if that works better for you.
  
We have not attempted to ‘dumb down’ our use of the language for readers with less experience. In some cases we stop to discuss linguistic features; mostly not. 

If you see an expression you cannot read, a little experimentation and consultation of the reference material should show you how it works. 

But we have not tried to be smart either. Code should be as terse as reasonable, but should always be readable, maintainable and traceable.

We encourage you to take the time to do this. Generally speaking – not invariably – short, crisp expressions are less work for you and the interpreter to read. Learn them and prefer them. 

In case you still need help the [Dyalog Forum](http://forum.dyalog.com) provides access to a competent and friendly community around Dyalog.


## Conventions

I> Note that we assume `⎕IO←1` and `⎕ML←1`, not because  we are making a statement, but because that’s the Dyalog default. That keeps the Cookbook in sync with the Dyalog documentation.

A> # Getting deeper
A>
A> In case we want to discuss a particular issue in more detail but we are not sure whether the reader is ready for this, now or ever, we format the information this way.

W> Sometimes we need to warn you, for example in order to avoid common traps. This is how that would look like.

T> Sometimes we want to provide a tip, and this is how that looks.

When we refer to a text file, e.g. something with the extension `.txt`, we refer to it as a TXT. We refer to a dyalog script (`*.dyalog`) as a DYALOG. We refer to a dyapp script (`*.dyapp`) as a DYAPP. You get the pattern.


## Acknowledgements

We are deeply grateful for contributions, ideas, comments and outright help from our colleagues, particularly from (in alphabetical order) Gil Athoraya, Morten Kromberg, Paul Mansour, Nick Nickolov, Andy Shiers and Richard Smith.

We jealously claim any errors as entirely our own work. 


Kai Jaeger & Stephen Taylor


[^win]: Perhaps one day you would like it to ship on multiple platforms. Perhaps one day we’ll write that book too. Meanwhile, Microsoft Windows. 
   
  You will however find that whenever possible we keep the code platform independent. If we use platform-dependent utilities we mention it and explain why; we might also mention alternatives available on other platforms.


[^apltree]: _APLTree_ is the name of an open-source library that offers robust, tested and well documented solutions to many everyday problems you  face when addressing the tasks discussed in this book.

  We will use this library extensively and discuss it in detail. More at the source: <https://aplteam.github.io/apltree>. You can also search for "apltree" on [GitHub](https://github.com).
  
  
[^classes]: These days seasoned programmers often have strong opinions about whether to use an object-oriented approach or a functional approach, or to mix them both. 

  We have seen friendships broken on these issues. In this book we take a mixed approach.


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