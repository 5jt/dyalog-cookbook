{:: encoding=“utf-8” /}

# Special characters

The following assumes `⎕IO←1`.


| Character       | `⎕ML<3` | `⎕ML≥3` | Escaping | `⎕UCS` | Abbr. |  Hex |
|-----------------|--------:|--------:|---------:|-------:|------:|-----:|
| Carriage retur  |`⎕TC[3]` |`⎕TC[2]` |       \r |     13 |    CR | 0x0D |
| New line [^nl]  |`⎕TC[2]` |`⎕TC[3]` |       \n |     10 | LF,NL | 0x0A |
| Form feed       |     n/a |     n/a |       \f |     12 |    FF | 0x0D |



## Line ending characters


| OS            | Lines end |
|---------------|-----------|
| Windows       | CR,LF     |
| Linux & Unix  | NL        |
| Old Macs[^mac]| CR        |

[^nl]: Was "linefeed" in the old days.
[^mac]: Before OS X