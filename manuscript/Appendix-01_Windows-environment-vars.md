{:: encoding="utf-8" /}
[parm]:title='EnvVars'


# Appendix 1 --- Windows environment variables


## Overview

Windows comes with quite a number of environment variables. Those variables are helpful in addressing, say, a particular path without actually using a physical path. 

For example, on most PCs, Windows is installed in C:\\Windows, but this is by no means guaranteed. It is therefore much better to address this particular folder as `⊣2 ⎕NQ # 'GetEnvironment' 'WINDIR'`. 

Below some of the environment variables found on a Windows 10 system are listed and explained.

I> The Dyalog Cookbook is usually referring to Windows 10 which, in most cases, is identical with Windows 8 and 7. The Cookbook is not applicable to unsupported versions of Windows like Vista and earlier.

Notes:

* When something like "{this}" is part of a path then it means that this string has to be exchanged for something reasonable. For example, in "C:/Users/{yourName}/" the string "{yourName}" needs to be replaced by the value of `⎕AN`.
* The list of environment variables discussed in this appendix is by no means exhaustive.
* Under Windows, the names of environment variables are case-insensitive.


## Outdated?!

Some consider environment variables an outdated technology. We don't want to get involved in this argument here but enviroment variables will be round for a very long time, and Windows relies on them. (They are also standard under UNIX, including Linux and MacOS.)


## The variables

### `AllUserProfile`

Defaults to `C:\ProgramData`: see [`ProgramData`](#programdata)


### `AppData`

Defaults to `C:\Users\{yourName}\AppData\Roaming`

Use this to store data that is both application **and** user specific that is supposed to roam [^roaming] with the user. An INI might be an example.

See also **[`LocalAppData`](#localappdata)**


### `CommonProgramFiles`
Defaults to `C:\Program Files\Common Files`

### `CommonProgramFiles(x86)`

Defaults to `C:\Program Files (x86)\Common Files`

### `CommonProgramW6432`

Defaults to `C:\Program Files\Common Files`

### `ComputerName`

The name of the computer

### `ComSpec`

Defaults to `C:\WINDOWS\system32\cmd.exe`

### `ErrorLevel`

This variable does not necessarily exist. If you execute `⎕OFF 123` in an APL application it will set `ErrorLevel` to 123.

### `HomeDrive

Carries the drive letter and a colon (like `C:`) but only if the user's data (documents, downloads, music...) do not live on a UCN path; for that see [`HomeShare`](#HomeShare).

### `HomePath`

Defaults to `\Users\{yourName}`. Note that this means it comes **without** the drive letter or UNC path! For a full path you need also either [`HomeDrive`](#HomeDrive) or [`HomeShare`](#HomeShare).

See also [`USERPROFILE`](#UserProfile) which is usually identical with [`HOMEPATH`](#HomePath)[^homepath]  but comes **with** the drive letter.


### `HomeShare`

This variable exists only if the user's data (documents, downloads, music...) live on a UNC path. See also [`HomePath`](#HomeShare).

### `LocalAppData`{#localappdata}

Defaults to `C:\Users\{yourName}\AppData\Local`

Use this to store data that is both application **and** user specific that is **not** supposed to roam [^roaming] with the user. 

A log file might be an example. The reason is that when a user logs in all the data stored in [`APPDATA`](#AppData) is copied over. A large log file might take significant time to be copied with very little (or no) benefit.

See also **[`AppData`](#AppData)**.

### `LogonServer`

Defaults to the name of the computer your are logged on to. In case of your own desktop PC the values of `LogonServer` and [`ComputerName`](#ComputerName) will be the same. In a Windows Server Domain however they will differ.

### `OS`

Specifies the Operating System; under Windows 10, `Windows_NT`

### `Path`

All the folders (separated by semicola) that the operating system should check if the user enters something like `my.exe` into a console window and `my.exe` is not found in the current directory.

### `PathExt`

A list of the file extensions the operating system considers executable, for example: `.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC`.

### `ProgramData`{#programdata}

Defaults to `C:\ProgramData`. Use this for information that is application-specific and needs write access after installation. For Dyalog, this would be the right place to store the session file, workspaces and user commands.

### `ProgramFiles`{#programfiles}

Defaults to `C:\Program Files`. On a 64-bit version of Windows this is where 64-bit programs are installed. Note however that on a 32-bit version of Windows this points to [`ProgramFiles(x86)`](#x86).

But this is true only when you execute it on a command line. When you use Microsoft's `ExpandEnvironmentStrings` API function (via `⎕NA`) then the result **depends on the version of Dyalog**! That means that executed from a 64-bit version of Dyalog you get the 64 bit location while from the 32-bit version you get the 32-bit location.

To get around this use the [`ProgramW6432`](#x86) variable.

### `ProgramFiles(x86)`{#x86}

Defaults to `C:\Program Files (x86)`. This is where 32-bit programs are installed.

### `ProgramW6432`

Defaults to `C:\Program Files`. On a 64-bit version of Windows this path points to [`ProgramFiles`](#programfiles). On a 32-bit version of Windows it also points to `ProgramFiles` which in turn points to [`ProgramFiles(x86)`](#x86). 

For this it does not matter whether the conversion was initiated from a 32- or 64 bit application; in this respect this variable differs from `ProgramFiles`.

For details see _WOW64 Implementation Detail_ [^wow].

### `PSModulePath`

Defaults to `C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\`. This path is used by Windows Power Shell [^powershell] to locate modules when the user does not specify the full path to a module.

### `Public`

Defaults to `C:\Users\Public`. It contains folders like `\Public Documents`, `\Public Music`, `\Public Pictures`, `\Public Videos`, ... well, you get the picture.

### `SystemRoot`{#systemroot}

Specifies the folder in which Windows is installed. Defaults to `C:\WINDOWS`.

### `Temp`

Points to the folder that holds temporary files and folders. Defaults to `C:\Users\{username}\AppData\Local\Temp`. See also [`TMP`](#TMP).

### `TMP`

Points to the folder that holds temporary files and folders. Defaults to `C:\Users\{username}\AppData\Local\Temp`. Note that the `GetTempFileName` API function (which is available as `FilesAndDirs.GetTempFilename`) will first look for the `TMP` environment variable and only if that does not exist for the [`TEMP`](#Temp) variable.

### `Username`

The username of the user currently logged on. Same as `⎕AN` in APL.

### `UserProfile`

Defaults to `C:\Users\{username}`. That's where everything is saved that belongs to the user currently logged on. 

This is usally identical[^homepath] to [`HomePath`](#HomePath) except that `HomePath` does not carry the drive letter. 

### `WinDir`

Defaults to the value of [`SystemRoot`](#systemroot). Deprecated.

[^homepath]: The difference between `HomeDrive|HomeShare\HomePath` and `UserProfile` is that _usually_ they are the same. However, it is possible --- and relatively simple --- to put the user's data (`HomePath\*`) elsewhere, a network drive for example. `UserProfile` however is where the user's profile is loaded from, and that cannot be changed.

   Note that it is possible to have no profile loaded, but this is a very special --- and rare --- case. Google for it when you run into this.

[^roaming]: <https://en.wikipedia.org/wiki/Roaming_user_profile>

[^powershell]: <https://en.wikipedia.org/wiki/PowerShell>

[^wow]: <https://msdn.microsoft.com/en-us/library/windows/desktop/aa384274(v=vs.85).aspx>


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