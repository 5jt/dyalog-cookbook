{:: encoding="utf-8" /}
[parm]:toc                 =  0
[parm]:title               =   'Special Chars'


# Appendix 5 --- Special characters

The following assumes `⎕IO←1`.

## Carriage return, new line  and form feed 

The following contains everything you need to know about those characters.


| Character       | `⎕ML<3` | `⎕ML≥3` | Escaping | `⎕UCS` | Abbr. |  Hex |
|-----------------|--------:|--------:|---------:|-------:|------:|-----:|
| Carriage return |`⎕TC[3]` |`⎕TC[2]` |       \r |     13 |    CR | 0x0D |
| New line [^nl]  |`⎕TC[2]` |`⎕TC[3]` |       \n |     10 | LF,NL | 0x0A |
| Form feed       |     n/a |     n/a |       \f |     12 |    FF | 0x0D |



## Line-ending characters

The following table contains everything you need to know about how different operating systems make use of line-ending characters.

| OS            | Lines end |
|---------------|-----------|
| Windows       | CR,LF     |
| Linux & Unix  | NL        |
| Old Macs[^mac]| CR        |

[^nl]: Was "linefeed" in the old days.
[^mac]: Before OS X

Strictly speaking, a file should always end with such characters. However, for example under Windows even different software packages from Microsoft handle this differently. 


## Common abbreviations

*[BAT]: Executable file that contains batch commands
*[CHM]: Executable file with the extension `.chm` that contains Windows Help (Compiled Help) 
*[CSS]: File that contains layout definitions (Cascading Style Sheet)
*[DWS]: Dyalog workspace
*[DYALOG]: File with the extension `.dyalog` holding APL code
*[DYAPP]: File with the extension `.dyapp` that contains `Load` and `Run` commands in order to put together an APL application
*[EXE]: Executable file with the extension `.exe`
*[HTM]: File in HTML format
*[HTML]: HyperText Mark-up language
*[INI]: File with the extension `.ini` containing configuration data
*[MD]: File with the extension `.md` that contains markdown
*[PF-key]: Programmable function key
*[TXT]: File with the extension `.txt` containing text
*[WS]: Workspaces
