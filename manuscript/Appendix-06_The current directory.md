[parm]:toc                 =  0
[parm]:title               =   'The current directory'


# Appendix 6 --- current directory

## Overview

The _current directory_, sometimes also referred to as _working directory_ --- or even _starting working directory_ --- as well as _Start in_" in some dialog boxes is an important concept: it's where a file without a path name will be searched for


## The possible scenarios


Double-clicking a Dyalog EXE

: The EXE's installation path is the current directory.


Calling a Dyalog EXE or a DYAPP from a console window

: The current directory of the console window is also going to be the EXE's current directory.

Double-clicking DWS or DYAPP

: The current directory is going to be where the workspace or the DYAPP file lives.


Double-clicking a shortcut

: The result depends on whether a folder is specified in "Start in" (available via the shortcut's "Properties" dialog):

: -- If "Start in" specifies a valid folder then this will determine the current directory.
: -- If "Start in" is empty or specifies an invalid folder[^invalid] then the folder the shortcut lives in will determine the current directory.


## Special cases: soft and hard links

|⍝TODO⍝ |{style="font-size:xx-large;color:red;"}

## Remarks

Normally when a program is started the folder the EXE lives in determines the current directory.

This is also true when you call any Dyalog EXE. However, from an APL programmer's point of view the workspace defines the program, not the EXE. That's why we advocate changing the current directory to where the workspace was loaded from.

It's similar for DYAPPs, though they don't load a workspace but assemble it dynamically. In case of a double-click on a DYAPP luckily there is no need to do anything because the current directory will be the folder the DYAPP lives in, which is exactly how it should be.

|⍝TODO⍝: we need a mechanism for DYAPPs in case they got called programmitically!|{style="font-size:xx-large;color:red;"}

[^invalid]: Although it is impossible to enter an invalid path in the "Properties" dialog of a shortcut, a valid folder name might of course become invalid at a later point.