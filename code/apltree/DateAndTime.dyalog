:Class DateAndTime
⍝ ## Overview
⍝ This namespace contains functions that deal with date and time.
⍝
⍝ Note that virtually all functions have been implemented by Phil Last
⍝ (<http://aplwiki.com/PhilLast>) - unless stated otherwise - and generously
⍝ granted to the APLTree project.
⍝
⍝ This class does **not** need .NET.

⍝ ## Terms
⍝ | Term           | Definition |
⍝ | - | - |
⍝ | Y              | Year |
⍝ | M              | Month |
⍝ | D              | Day |
⍝ | h              | Hour |
⍝ | m              | Minute |
⍝ | s              | Second |
⍝ | i              | Millisecond |
⍝ | yyyy_mm_dd     | Three-item vector representing (y,m,d) |
⍝ | yyyymmdd       | Scalar representing (y,m,d) |
⍝ | date.time      | Float representing date and time as in 20160101.235959 or even 20160101.2359599999 (milliseconds)|
⍝ | TS             | Timestamp; vector of length 1 to 7 like `⎕TS` |
⍝ | period         | Length defines it: 1=years(s), 2=year(s) month(s), ... 6=Y,M,D,h,m,s |
⍝ | gsd            | Gregorian serial date; Integer representing a date as number of days with 1 = 1.1.1 |
⍝ | daysDec        | gsd.hms when hsm is represented as decimal |
⍝ | date           | Three-item vector representing a date as in 2016 1 2|

⍝ ## Examples
⍝ | ''Result''             | ''`⍺`''          | ''Function'' | ''`⍵`'' |
⍝ | '' Cast''              |
⍝ | 735965.058159722       |                  | DateTime2DayDecimal          | 20160102.012345    |
⍝ | 20160102.012345        |                  | DayDecimal2DateTime          | 735965.058159722   |
⍝ | 24193                  |                  | DateTime2Month               | 20160102.058159722 |
⍝ | 20160101               |                  | Month2DateTime               | 24193              |
⍝ | 2016 1 1 1 23 45 0     |                  | DateTime2Timestamp           | 20160101.012345    |
⍝ | 20160101.012345        |                  | Timestamp2DateTime           | 2016 1 1 1 23 45   |
⍝ | 2016 1 2 1 23 44 999   |                  | DayDecimal2Timestamp         | 735965.058159722   |
⍝ | 735965.058148148       |                  | Timestamp2DayDecimal         | 2016 1 2 1 23 44   |
⍝ | 736329                 |                  | Date2GregorianSerialDate     | 2016 12 31         |
⍝ | 2016 12 31             |                  | GregorianSerialDate2Date     | 736329             |
⍝ | ''Week numbers''       |
⍝ | 52                     |                  | WeekNo_ISO                   | 2016 12 31         |
⍝ | 2016 12 26             |                  | DateFrom_Year_WeekNumberISO  | 2016 52            |
⍝ | 2016 12 29             | 'Thursday'       | DateFrom_Year_WeekNumberISO  | 2016 52            |
⍝ | 53                     |                  | WeekNo_US                    | 016 12 31          |
⍝ | 2016 12 25             |                  | DateFrom_Year_WeekNumberUS   | 2016 53            |
⍝ | 2016 12 29             | 'Thursday'       | DateFrom_Year_WeekNumberUS   | 2016 53            |
⍝ | ''Misc''               |
⍝ | 5                      |                  | DayOfWeekAsNumber            | 2016 1 1           |
⍝ | 'Friday'               |                  | DayOfWeek                    | 2016 1 1           |
⍝ | 20000423 20010415      |                  | Easter                       | 2000 2001          |
⍝ | '2016-12-31 01:23:45'  |                  | FormatDateTime               | 20161231.012345    |
⍝ | 1 1 0                  |                  | LeapYear                     | 2000 2016 2100     |
⍝ | 60                     |                  | OrdinalNumber                | 2016 2 29          |
⍝ | ''Math''               |
⍝ | 20161231               | 0                | AddPeriod2DateTime           | 20161231           |
⍝ | 20170301               | 0 2              | AddPeriod2DateTime           | 20161229           |
⍝ | 20160229               | 0 2              | AddPeriod2DateTime           | 20151229           |
⍝ | 20161231               | 0 0 2            | AddPeriod2DateTime           | 20161229           |
⍝ | 20161229.032345        | 0 0 0 2          | AddPeriod2DateTime           | 20161229.012345    |
⍝ | 20161230.022345        | 0 0 0 25         | AddPeriod2DateTime           | 20161229.012345    |
⍝ | 20161229.014845        | | 0 0 0 0 25    | AddPeriod2DateTime           | 20161229.012345    |
⍝ | 20161229.012348        | | 0 0 0 0 0 3   | AddPeriod2DateTime           | 20161229.012345    |
⍝ | 20000101               | | 0             | AddPeriod2DateTime           | 20000101           |
⍝ | 20030101               | | 3             | AddPeriod2DateTime           | 20000101           |
⍝ | 20030201               | | 3 1           | AddPeriod2DateTime           | 20000101           |
⍝ | 20030203               | | 3 1 2         | AddPeriod2DateTime           | 20000101           |
⍝ | 20030203.04            | | 3 1 2 4       | AddPeriod2DateTime           | 20000101           |
⍝ | 20030203.23            | | 3 1 2 23      | AddPeriod2DateTime           | 20000101           |
⍝ | 20030204               | | 3 1 2 24      | AddPeriod2DateTime           | 20000101           |
⍝ | 20030203.0405          | | 3 1 2 4 5     | AddPeriod2DateTime           | 20000101           |
⍝ | 20030203.0459          | | 3 1 2 4 59    | AddPeriod2DateTime           | 20000101           |
⍝ | 20030203.05            | | 3 1 2 4 60    | AddPeriod2DateTime           | 20000101           |
⍝ | 20030203.040507        | | 3 1 2 4 5 7   | AddPeriod2DateTime           | 20000101           |
⍝ | 20030203.040607        | | 3 1 2 4 5 67  | AddPeriod2DateTime           | 20000101           |

⍝ ## Misc
⍝ Responsible: Kai Jaeger
⍝
⍝ Homepage: <http://aplwiki.com/DateAndTime>

    ⎕IO←⎕ML←0

    ∇ r←Version
      :Access Public Shared
      ⍝ * 1.2.0: Requires now at least Dyalog 15.0 Unicode
      ⍝ * 1.1.0: Doc converted to Markdown (requires at least ADOC 5.0)
      ⍝ Few more examples and one more test case.
      r←({1↓⊃,/¯1↑⍵⊂⍨'.'=⍵}⍕⎕THIS)'1.2.0' '2016-09-01'
    ∇

    :Field ReadOnly Public Shared WeekDays←'Monday' 'Tuesday' 'Wednesday' 'Thursday' 'Friday' 'Saturday' 'Sunday'

    ∇ r←DayDecimal2DateTime daysDecs
    ⍝ `⍵` days.decs - ddddd.dddddd          - scalar or vector\\
    ⍝ `←` date.time - yyyymmdd.hhmmssmmm    - shape ⍴⍵\\
    ⍝ See also [`DateTime2DayDecimal`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←Timestamp2DateTime DayDecimal2Timestamp daysDecs
    ∇

    ∇ r←DateTime2DayDecimal dateTime
    ⍝ `⍵` date.time - yyyymmdd.hhmmssmmm    - Scalar or vector\\
    ⍝ `←` days.decs - ddddd.dddddd          - shape ⍴⍵\\
    ⍝ See also [`DayDecimal2DateTime`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←Timestamp2DayDecimal DateTime2Timestamp dateTime
    ∇

    ∇ r←DayDecimal2Timestamp dayDecs
    ⍝ `⍵` days.decs ddddd.dddddd            - Scalar or vector\\
    ⍝ `←` timestamp yyyy mm dd hh mm ss mmm - shape `(⍴⍵),7`\\
    ⍝ Try:
    ⍝ ~~~
    ⍝ `a←(24÷⍨6+2.2×1○2×○(92⌽⍳366)÷366)+(39436+⍳366)`
    ⍝ `FormatDateTime∘Timestamp2DateTime∘DayDecimal2Timestamp a`
    ⍝ ~~~
    ⍝ See also [`Timestamp2DayDecimal`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←{
          dhm←24 60 60 1000
          (GregorianSerialDate2Date⌊⍵),⌊⍉dhm⊤⍉(1|⍵)××/dhm
      }dayDecs
    ∇

    ∇ r←Timestamp2DayDecimal TS;dhm
    ⍝ `⍵` timestamp yyyy mm dd [hh [mm [ss [mmm]]]] - Either a simple vector or a simple matrix.\\
    ⍝ `←` days.decs ddddd.dddddd                    - shape `¯1↓⍴⍵`\\
    ⍝ 1899-12-31 00:00 `→` 0 - a year and a day before the end of the 19th century!\\
    ⍝ See also [`DayDecimal2Timestamp`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      dhm←24 60 60 1000
      r←(¯1↓⍴TS)⍴⊃{(Date2GregorianSerialDate ⍺)+(⍉dhm⊥⍉⍵)÷×/dhm}/1 0 0 1 0 0 0⊂7↑[0⊥⍳⍴⍴TS]TS
    ∇

    ∇ r←DateTime2Month dateTime
    ⍝ `⍵` date.time      - shape any\\
    ⍝ `←` months         - shape ⍴⍵\\
    ⍝ Origin is 1 Jan 1 bce (for what it's worth)\\
    ⍝ See also [`Month2DateTime`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←0 12⊥0 100⊤⌊dateTime÷100
    ∇

    ∇ r←Month2DateTime M
    ⍝ `⍵` months       - shape any\\
    ⍝ `←` date.time    - shape ⍴⍵\\
    ⍝ See also [`DateTime2Month`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←101+100×100⊥0 12⊤M-1
    ∇

    ∇ r←DateTime2Timestamp dateTime
    ⍝ `⍵` date.time - yyyymmdd.hhmmssmmm      - Either a simple scalar or a nested vector or a simple matrix\\
    ⍝ `←` timestamp - yyyy mm dd hh mm ss mmm - shape is 7 for a simple scalar and (⍴,⍵),7 otherwise\\
    ⍝ See also [`Timestamp2DateTime`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←⍉⌊(1 5 1/0,10*2 3)⊤⍉dateTime×10*9
    ∇

    ∇ r←Timestamp2DateTime TS
    ⍝ `⍵` timestamp - yyyy mm dd [hh [mm [ss [mmm]]]] - Either a simple vector or a simple matrix\\
    ⍝ `←` date.time - yyyymmdd.hhmmssmmm              - shape `¯1↓⍴⍵`\\
    ⍝ Does not support negatives.\\
    ⍝ See also [`DateTime2Timestamp`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←⍉1E¯9×(1 5 1/0,10*2 3)⊥⍉7↑[0⊥⍳⍴⍴TS]TS
    ∇

    ∇ r←GregorianSerialDate2Date gsd
      ⍝ `⍵` is a gregorian serial date\\
      ⍝ `←` is a matrix with three columns. The number of rows matches the length of ⍵\\
      ⍝ See also [`Date2GregorianSerialDate`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←{
          d←,⍵-1                       ⍝ proleptic gregorian days
          q c o y←0                    ⍝ local
          q d∘←↓0 146097⊤d             ⍝ quadricentennium - 400 100 4 1+.×365 1 ¯1 1
          c d∘←↓0 36524⊤d              ⍝ century          -    100 25 1+.×365 1 ¯1
          s←c=4                        ⍝ end of quadricentennium
          o d∘←↓0 1461⊤d               ⍝ quadrennium      -         4 1+.×365 1
          y d∘←↓0 365⊤d                ⍝ year & day
          s∨←y=4                       ⍝ end of quadrennium
          y d+←1+¯1 365×⊂s             ⍝ end of century/quadricentennium
          y∘←↑q c o y+.×400 100 4 1    ⍝ total years
          l←=⌿0=4 100 400∘.|y          ⍝ leap year
          m←(1 31 29,10⍴5⍴31 30)/⍳13   ⍝ a year of months
          d+←l<d>59                    ⍝ skip 29 Feb for non leap-year
          m∘←m[d]                      ⍝ month
          n←+\0 0 31 29,10⍴5⍴31 30     ⍝ days to previous month end
          d-←n[m]                      ⍝ remainder
          ((⍴⍵),3)⍴⍉↑(⊂0≠⍵)×y m d      ⍝ yyyy mm dd - 2d
      }gsd
    ∇

    ∇ r←Date2GregorianSerialDate yyyy_mm_dd
    ⍝ `⍵` yyyy mm dd - 3 cols matrix or a 3 item vector.\\
    ⍝ `←` dddd       - rank 1\\
    ⍝ See also [`GregorianSerialDate2Date`](#).\\
    ⍝ Phil Last
      :Access Public Shared
      r←{
          y m d←↓⍉↑,↓⍵                            ⍝ separate years months & days
          Y←{(⍵×365)+(⌊⍵÷4)-(⌊⍵÷100)-⌊⍵÷400}y-1   ⍝ days for full years
          M←(+\0 0 31 28,10⍴5⍴31 30)[m]           ⍝ days to previous month end
          M←M+(m>2)∧(0=4|y)>(0=100|y)>(0=400|y)   ⍝ + leap day after Feb
          (⍵∨.≠0)×Y+M+d                           ⍝ total proleptic gregorian days
      }yyyy_mm_dd
    ∇

    ∇ r←period AddPeriod2DateTime dateTime
    ⍝ `⍺` period(s)    - Y [M [D [h [m [s [i]]]]]]   - vector or matrix\\
    ⍝ `⍵` date.time(s) - yyyymmdd.hhmmssmmm - scalar or vector\\
    ⍝ `⍺` conforms `⍤ 1 0 ⊢ ⍵`\\
    ⍝ i.e. each row in `⍺` corresponds to each element in `⍵`\\
    ⍝ `← date.time ← period ∇ date.time`\\
    ⍝ Phil Last
      :Access Public Shared
      r←period{
          d←⍉(DateTime2Timestamp ⍵)+∘(7∘↑)⍤1⊢⍺
          m d←1 0+(0 12)(0 24 60 60 1000){⍺⊤⍺⊥⍵}¨(¯1+2↑d)(2↓d)
          (1 0 0 0 0⌿d)+←Date2GregorianSerialDate⍉m⍪0
          Timestamp2DateTime(GregorianSerialDate2Date⊣⌿d),⍉1↓d
      }dateTime
    ∇

    ∇ r←FormatDateTime arg;⎕CT
    ⍝    `((⍴⍵),19)⍴'K6G<9999-99-99 99:99:99>'⎕FMT,⍵`
    ⍝ above gives `2008-02-19 08:11:60 for 20080219.081159910`\\
    ⍝ `⍵` date.time yyyymmdd.hhmmssmmm    - shape any\\
    ⍝ `←` chararray 'yyyy-mm-dd hh:mm:ss' - shape `(⍴⍵),19`\\
    ⍝ Phil Last
      :Access Public Shared
      ⎕CT←0 ⍝ don't let ⌊ round UP
      r←((⍴arg),19)⍴'O<>G<9999-99-99 99:99:99>'⎕FMT⌊,arg×10*6
    ∇

    ∇ r←Easter year
    ⍝ Easter Sunday in year `⍵`.\\
    ⍝ John Scholes; see <https://dfns.dyalog.com/n_easter.htm>
      :Access Public Shared
      r←{
          G←1+19|⍵                ⍝ year "golden number" in 19-year Metonic cycle.
          C←1+⌊⍵÷100              ⍝ Century: for example 1984 → 20th century.

          X←¯12+⌊C×3÷4            ⍝ number of years in which leap year omitted.
          Z←¯5+⌊(5+8×C)÷25        ⍝ synchronises Easter with moon's orbit.

          S←(⌊(5×⍵)÷4)-X+10       ⍝ find Sunday.
          E←30|(11×G)+20+Z-X      ⍝ Epact.
          F←E+(E=24)∨(E=25)∧G>11  ⍝   (when full moon occurs).

          N←(30×F>23)+44-F        ⍝ find full moon.
          N←N+7-7|S+N             ⍝ advance to Sunday.

          M←3+N>31                ⍝ month: March or April.
          D←N-31×N>31             ⍝ day within month.
          ↑10000 100 1+.×⍵ M D    ⍝ yyyymmdd.
      }year
    ∇

    ∇ bool←LeapYear year
    ⍝ Returns 1 in case integer `⍵` represents a leap year otherwise 0.\\
    ⍝ Phil Last
      :Access Public Shared
      bool←0≠.=4 100 400∘.|year
    ∇

    ∇ r←DayOfWeek yyyy_mm_dd
    ⍝ `⍵` can be either a vector with 3 elements (Y M D) or a matrix with
    ⍝ n rows and 3 columns.\\
    ⍝ `←` Monday ..., Sunday.\\
    ⍝ First year in the domain of this function is 1753. Anything earlier is a DOMAIN Error.\\
    ⍝ See also [`DayOfWeekAsNumber`)(#).\\
    ⍝ Phil Last
      :Access Public Shared
      'Year must be 1753 or later'⎕SIGNAL 11/⍨1752∧.≥0⌷⍤1⊣yyyy_mm_dd
      r←{
          gsd←¯1+Date2GregorianSerialDate 3↑⍤1⊣⍵
          WeekDays[7|gsd]
      }yyyy_mm_dd
    ∇

    ∇ r←OrdinalNumber yyyy_mm_dd;Y;M;D
    ⍝ `⍵` can be either a vector with 3 elements (Y M D) or a matrix with n rows and 3 columns.\\
    ⍝ Returns the ordinal number (= the position within the year) of the give date.\\
    ⍝ The first of March has an ordinal number of 61 in leap years and 60 otherwise.\\
    ⍝ The last day of the year has an ordinal number 365 in leap years and 364 otherwise.\\
    ⍝ Kai Jaeger
      :Access Public Shared
      'Year must be 1753 or later'⎕SIGNAL 11/⍨1752∧.≥0⌷⍤1⊣yyyy_mm_dd
      (Y M D)←↓∘⍉⍣(⊃2=⍴⍴yyyy_mm_dd)⊣yyyy_mm_dd
      r←D+Y{+/(1+⍳⍵)DaysInMonth ⍺}¨M-1
    ∇

    ∇ r←DayOfWeekAsNumber date
    ⍝ `⍵` date (like `3↑⎕ts`). Can be either a vector with 3 elements (Y M D) or a matrix with
    ⍝ n rows and 3 columns.\\
    ⍝ `←` 1 for Monday, ..., 7 for Sunday.\\
    ⍝ First year in the domain of this function is 1753. Anything earlier is a DOMAIN Error.\\
    ⍝ Kai Jaeger
      :Access Public Shared
      'Year must be 1753 or later'⎕SIGNAL 11/⍨1752∧.≥0⌷⍤1⊣date
      r←1+7|¯1+Date2GregorianSerialDate 3↑⍤1⊣date
    ∇

    ∇ r←WeekNo_ISO yyyy_mm_dd;b1;b2;r2;Calc
    ⍝ Calculates the week number according to the ISO standard.\\
    ⍝ See <https://www.wikiwand.com/en/ISO_week_date for details>.\\
    ⍝ See also `DateFrom_Year_WeekNumberISO`.\\
    ⍝ Example:\\
    ⍝ `39 ← WeekNo_ISO 2008 9 22`\\
    ⍝ Kai Jaeger
      :Access Public Shared
      Calc←{⌊(10+(OrdinalNumber ⍵)-DayOfWeekAsNumber ⍵)÷7}
      r←Calc yyyy_mm_dd
      b1←r=0
      b2←r=53
      :If ∨/b1
          (b1/r)←Calc((b1/¯1+0⌷⍤1⊣yyyy_mm_dd),[0.5]12),31
      :EndIf
      :If ∨/b2
      :AndIf 0∧.≠r2←Calc((b2/1+0⌷⍤1⊣yyyy_mm_dd),[0.5]1),1
          b2∧←b2\r2≠0
          (b2/r)←(0≠r2)/r2
      :EndIf
    ∇

    ∇ r←{day}DateFrom_Year_WeekNumberISO(Y weekNo);corr;ind;ord;month
    ⍝ `⍵` Year and week number (ISO standard)\\
    ⍝ `⍺` Optional day (as char vector).\\
    ⍝ `←` Depends on whether "day" was specified or not:\\
    ⍝ * If "day" was specified the date of that day is returned.
    ⍝ * If "day" was not specified then the start date of the week is returned.
    ⍝
    ⍝ Note that "day" is case sensitive and must be specified as, say, "Sunday".\\
    ⍝ For details see <https://www.wikiwand.com/en/ISO_week_date#Calculation> \\
    ⍝ Examples:
    ⍝ ~~~
    ⍝ (2008 9 22)   ←            DateFrom_Year_WeekNumberISO 2008 39
    ⍝ (2015 12 33)  ← 'Saturday' DateFrom_Year_WeekNumberISO 2015 53
    ⍝ ~~~
    ⍝ See also [`WeekNo_ISO`](#).\\
    ⍝ Kai Jaeger
      :Access Public Shared
      day←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'day'
      'Invalid week number'⎕SIGNAL 11/⍨~weekNo∊1+⍳53
      corr←3+DayOfWeekAsNumber Y 1 4
      ord←1+(weekNo×7)-corr
      month←1+1⍳⍨ord<+\DaysInMonth Y
      :If 0∊⍴day
          r←Y,month,(ord-+/(1+⍳month-1)DaysInMonth Y)
      :Else
          ind←WeekDays⍳⊂day
          ord+←ind
          'Invalid day (Monday, ..., Sunday)'⎕SIGNAL 11/⍨ind=⍴WeekDays
          r←Y,month,(ord-+/(1+⍳month-1)DaysInMonth Y)
      :EndIf
    ∇

    ∇ r←WeekNo_US yyyy_mm_dd
    ⍝ Calculates the week number according to the US standard.\\
    ⍝ See <https://www.wikiwand.com/en/ISO_week_date> for details.\\
    ⍝ See also [`DateFrom_Year_WeekNumberUS`](#).\\
    ⍝ Kai Jaeger
      :Access Public Shared
      r←{
          days←DayOfWeekAsNumber↑⍵[0]{⍺,1,⍵}¨1+⍳7
          (¯1+OrdinalNumber ⍵)⊃(1⍴⍨1+days⍳6),⊃,/7⍴¨2+⍳52
      }yyyy_mm_dd
    ∇

    ∇ r←{day}DateFrom_Year_WeekNumberUS(Y weekNo);ind;corr;fd;fw;ord;month
    ⍝ `⍵` Year and week number (US method).\\
    ⍝ `⍺` Optional day (as char vector).\\
    ⍝ `←` Depends on whether "day" was specified or not:
    ⍝    * If "day" was specified the date of that day is returned.
    ⍝    * If "day" was not specified then the start date of the week is returned.
    ⍝
    ⍝ Note that "day" is case sensitive and must be specified as, say, "Sunday".\\
    ⍝ For details see <https://www.wikiwand.com/en/ISO_week_date#Calculation>.\\
    ⍝ Examples:
    ⍝ ~~~
    ⍝ (2008 9 27) ← 'Saturday' DateFrom_Year_WeekNumberISO_Day 2008 39
    ⍝ (2015 12 28) ← 'Saturday' DateFrom_Year_WeekNumberISO_Day 2015 53
    ⍝ ~~~
    ⍝ See also [`WeekNo_US`](#).\\
    ⍝ Kai Jaeger
      :Access Public Shared
      day←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'day'
      'Invalid week number'⎕SIGNAL 11/⍨~weekNo∊1+⍳53
      'Invalid day (Monday, ..., Sunday)'⎕SIGNAL 11/⍨0=+/(⊂day)∊(⊂''),WeekDays
      fd←DayOfWeek Y 1 1                ⍝ First day
      fw←(weekNo>1)×7-1+WeekDays⍳fd     ⍝ No of days in first week
      ord←1++/fw,(0⌈weekNo-2)⍴7         ⍝ Ordinal number of first day
      month←1+1⍳⍨ord<+\DaysInMonth Y
      r←Y,month,(ord-+/(month-1)↑DaysInMonth Y)+(~0∊⍴day)×(¯1⌽WeekDays)⍳⊂day
    ∇

    ∇ r←{M}DaysInMonth Y
    ⍝ `⍵` The year. Must be a single integer value.\\
    ⍝ `⍺` Optional: month; If not specified then all 12 months for the year given are returned.\\
    ⍝ `←` Scalar with number of days.\\
    ⍝ Kai Jaeger
      :Access Public Shared
      M←{0<⎕NC ⍵:⍎⍵ ⋄ 1+⍳12}'M'
      'Invalid month'⎕SIGNAL 11/⍨∨/~M∊1+⍳12
      r←(31(28+LeapYear Y)31 30 31 30 31 31 30 31 30 31)[M-1]
    ∇

:EndClass
