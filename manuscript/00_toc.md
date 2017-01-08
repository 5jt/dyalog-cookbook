{:: encoding="utf-8" /}

# Introduction

# Structure

# Package MyApp as an executable

# Logging what happens

> * Why UTF8? Should be explained because many tools except ANSI only, so there might be a drawback depending on the circumstances.
> * Shall we use FilesAndDirs everywere? That would avoid using FileSep (/ instead) and `NormalizePath` (is done iunternally)
> * The composed function `LogError` should be passed as an argument to the main function (but not ⎕LX`). 
    That would allow using a stub in test cases. Important concept when it comes to testing.

## Log files

> To be added:
* Choice of `encoding`
* `autoRopen` and `filenameType` (Date)
* `printToSession`
* `active` flag

## Windows Event Log

> Add something basic regarding the WindowsEventLog class and why it is important to notify the Windows Event Log, at least for serious problems: in many companies on servers the Windows Event Logs are constanctly scanned for any problems. In case of a problem typically an admin is notified in one way or another. See "Windows Event collector" for example.

# Handling errors

> Question regarding the "Event" namespace
> * Shouldn't those variables be niladic functions, imitating the concept of constants?
> * Why specifying text as argument to `LogError` etc? It's better to use the numeric constant name and avoid the `⍎`, and it's in line with any other programming language.

> Explain (and maybe use) these:
> * customFns
> * customFnsParent
> * logFunction
> * off
> * signal
> * windowsEventSource

# Configuration settings

# Testing: the sound of breaking glass

> The container namespace being a scripted namespace might has significant disadvantages: investigate.

> Needs some more information regarding the advanced features of the test framework.
> * Running numbers and group names.
> * The different `Run*` functions.
> * Using the constants for returning a result.
> * `PassesIf`, `FailsIf` and `GoToTidyUp`.
> * The `Cleanup` function.
> * Special INI files for test purposes.
> * `G`, `L` and `E`.

# Make me

# Documentation - the Doc is in

# User Interface

> Discuss the pros and cons of both native GUI and the HTML5/JavaScript approach. Mention MiServer.

> Explain how important it is to separate business logic from UI:

> * It is then much easier to exchange one UI by another
> * It is also easier (or possible at all) to implement test cases for the business logic.

> Discuss why testing the UI as such is often not exactly a brilliant idea, and what exceptions there are and why.

# Providing help

> We introduce just Markdown2Help because...
> 1. it needs nothing but Dyalog.
> 2. it provides a functionality that it very close to a CHM file.

> Although it's a Windows solution we still get a working --- though very basic --- HTML version on Linux and Mac OS.

# Writing an installer

> We focus on the --- relatively simple --- Inno installer for the Cookbook.

> However, we should mention that large companies often have special needs. For example, they might require an MSI installer. This can only be achieved with the much more complex Wix solution from Microsoft.

> We need to discuss the best way of how to install under Linux and Mac-OS with Andy.

# Working with other processes

## Launching tasks (Windows Scheduler)

### Importance of log files

### Windows Event log

### Pre-prepare for a RIDE

## Running as a Windows service

Same as for Windows Scheduled Tasks.

## Linux/Mac OS?

## Storing and retrieving data

> Compare...
> * Component files
> * Native files
> * Relational data bases
> * XML
> * JSON

> Mention:
> * The Dyalog file server
> * FlipDB
> * SQAPL
> * Reading (and writing?!) Excel spreadsheets.

# Managing your source code

> What software to use / download.

> How to create an account on GitHub.

> How to make a local folder a Git managed repository and upload it.

> How to process changes and push them onto the server.

> How to clone a GitHub repository

> How to invite contributors to a project

## Documentation of the code

> What and how

> Generate readable documents

## Useful user commands

* `]Fire`
* `]CompareThese`
* `]CompareWorkspaces`
* `]Latest2`
* `]ListObjects`
* `]Storing data`
* `]GetMySession`

# Professional programming: tips, tricks and pitfalls.

> Discuss lobal variables.

> What exactly should a function do? **One** thing!

> Write a function so that at any stage you can simply execute `→1`.

> Classes and scripted namespaces versus ordinary namespaces.
> * Public interface (Black box principle)
> * Multiple versus single undo/redo stack

> Direct versus traditional functions - pros and cons
* You cannot trace into one-line direct functions
* No thread switches in direct functions after line 0
* Direct functions have disadvantages when it comes to tracing.

> Passing parameters to functions
> * List of values (typically mandatory parameters, right argument)
> * Optional parameters (often left argument)
>   * Lists of key-value pairs
>   * Namepsace with variables and possibly references


> Pros and cons of the diamond (statement separator)
> ⎕LX←'#.Foo ⋄ #.Goo'
> No thread switch in a line with ⋄ (except when user defined fns/opr are called)
> Tracer!

> Write trace-friendly code.
> Assigning intermediate results to variables can improve readability as well as maintainability.

> The `dfns` workspace.

> Names!
> _There are only two real challanges in writing software: memory management and finding the right names._