# Appendix 01: Windows environment variables

## Overview

Windows comes with quite a number of environment variables. Those variables are helpful in addressing, say, a particular path without actually using a physical path. For example, on most PCs Windows is installed in C:\\Windows, but this is by no means guaranteed. It is therefore much better to address this particular folder as `⊣2 ⎕NQ # 'GetEnvironment' 'WINDIR'`. 

Underneath you find some of the environment variables found on a Windows 10 system listed and explained.

I> Keep in mind that the Dyalog Cookbook is usually referring to Windows 10 which in most cases is identicall with Windows 8 and 7. The Cookbook does not care about unsupported versions of Windows like Vista and earlier.

Notes:

* When something like "{this}" is part of a path then it means that this string has to be exchanged against something reasonable. For example, in "C:/Users/{yourName}/" the string "{yourName}" needs to be replaced by the value of `⎕AN`.
* The selection of environment variables discussed in this appendix is by no means complete.
* Under Windows, the names of environment variables is case insensitive.


## Outdated?!

Some consider environment variables an outdated technology. We don't want to get involved into a religious argument here but we insist that enviroment variables will be round for a very long time, and that Windows relies on them. Also, they are standard in Linux and macOS.

## The variables

### AllUserProfile
Defaults to "C:\\ProgramData". See [ProgramData](#).

### AppData
Defaults to "C:\\Users\\{yourName}\\AppData\\Roaming".

Use this to store application specific data that is supposed to roam [^roaming] with the user. An INI file might be an example.

See also **[LocalAppData](#)**.

### CommonProgramFiles
Defaults to "C:\\Program Files\\Common Files".

### CommonProgramFiles(x86)
Defaults to "C:\\Program Files (x86)\\Common Files".

### CommonProgramW6432
Defaults to "C:\\Program Files\\Common Files".

### ComputerName
Carries the name of the computer.

### ComSpec
Defaults to "C:\\WINDOWS\\system32\\cmd.exe".

### ErrorLevel
This variable does not necessarily exist. If you execute `⎕OFF 123` in an APL application then this will set `ErrorLevel` to 123.

### HomePath
Defaults to "\\Users\\{yourName}".

### LocalAppData
Defaults to "C:\\Users\\{yourName}\\AppData\\Local".

Use this to store application specific data the is **not** supposed to roam [^roaming] with the user. A log file might be an example. The reason is that when a user logs in all the data stored in %APPDATA% is copied over. A large log file might take significant time to be copied over with very little benefit.

See also **[AppData](#)**.

### LogonServer:
Defaults to "ComputerName". This carries the name of the computer your are logged on to. In case of your own desktop PC the values of `LogonServer` and `ComputerName` will be the same. In a Windows Server Domain however they will differ.

### OS
Specifies the Operating System. Under Windows 10 you get "Windows_NT".

### Path
Specifies all the folders (separated by semicola) that the operating system should check in case the user enters something like `my.exe` into a console window and `my.exe` does not live in the current directory.

### PathExt
The `PathExt` environment variable returns a list of the file extensions that the operating system considers to be executable, for example: ".COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC".

### ProgramData
Defaults to "C:\\ProgramData". Use this for storing information that is application specific but needs write rights beyond installation. For Dyalog, this would actually be the right place to store the session file, workspaces and user commands.

### ProgramFiles
Defaults to "C:\\Program Files". On a 64-bit version of Windows this is where 64-bit programs are installed. Note however that on a 32-bit version of Windows this points to [ProgramFiles(x86)](#).

### ProgramFiles(x86)
Defaults to "C:\\Program Files (x86)". This is where 32-bit programs are installed.

### ProgramW6432
Defaults to "C:\\Program Files". On a 64-bit version of Windows this path points to "[ProgramFiles](#)". On a 32-bit version of Windows it also points to "ProgramFiles" which in turn points to [ProgramFiles(x86)](#).

For details see "WOW64 Implementation Detail" [^wow].

### PSModulePath
Defaults to "C:\\WINDOWS\\system32\\WindowsPowerShell\\v1.0\\Modules\\". This path is used by Windows Power Shell [^powershell] to locate modules when the user does not specify the full path to a module.

### Public
This defaults to "C:\\Users\\Public". It contains folders like "Public Documents", "Public Music", "Public Pictures", "Public Videos", ... well, you get the picture,

### SystemRoot
Specifies the folder Windows is installed in. Defaults to "C:\\WINDOWS".

### Temp
Points to the folder that holds temporary files and folders. Defaults to "C:\\Users\{username}\\AppData\\Local\\Temp". See also "TMP".

### TMP
Points to the folder that holds temporary files and folders. Defaults to "C:\\Users\\{username}\\AppData\\Local\\Temp". Note that the `GetTempFileName` API function (which is available as `FilesAndDirs.GetTempFilename`) will first look for the "TMP" environment variable and only if that does not exist for the "TEMP" variable.

### Username
The username of the user currently logged on. Same as `⎕AN` in APL.

### UserProfile
Defaults to "C:\\Users\\{username}". That's where all the stuff is saved that belongs to the user currently logged on. Note that this is kept apart from other user's spying eyes by the operating system.

### WinDir
Defaults to %[SystemRoot](#)%. Deprecated.


[^roaming]: <https://en.wikipedia.org/wiki/Roaming_user_profile>

[^powershell]: <https://en.wikipedia.org/wiki/PowerShell>

[^wow]: <https://msdn.microsoft.com/en-us/library/windows/desktop/aa384274(v=vs.85).aspx>