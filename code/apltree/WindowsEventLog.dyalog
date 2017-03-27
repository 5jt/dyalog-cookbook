:Class WindowsEventLog
⍝ This class offers only methods and properties useful to write application related logging
⍝ information to the Windows Event Log.\\
⍝ It comes with reasonable defaults to make this as easy as possible.\\
⍝ Note that `source` must have been registered by a user with admin rights. Typically that
⍝ is done by an installer, so we can rely on it being available.\\
⍝ Applications and services should write to the Application log or to a custom log. Device
⍝ drivers should write to the System log.\\                                               
⍝ Note that when you specify just a one-element vector as argument to the constructor (by
⍝ calling `⎕NEW`) then this is interpreted as `source`. If you specify a two-element vector
⍝ then this is treated as `(log source)`.
⍝
⍝ ## Examples
⍝ To write messages to a source "myApp" in the "Application" log:
⍝ ~~~
⍝ my←⎕NEW WindowsEventLog (,⊂'myApp')
⍝ my.WriteInfo 'An information'
⍝ my.WriteError 'An error message'
⍝ my.WriteWarning 'A warning'
⍝ ⎕ex 'my'  ⍝ close it
⍝ ~~~
⍝ <https://msdn.microsoft.com/en-us/library/system.diagnostics.eventlog(v=vs.110).aspx>
⍝
⍝ Author: Kai Jaeger ⋄ APL Team Ltd\\
⍝ Homepage: <http://aplwiki.com/WindowsEventLog>

    :Include APLTreeUtils

    ⎕io←1 ⋄ ⎕ml←3

    ∇ r←Version
      :Access Public Shared
      ⍝ * 1.5.2
      ⍝   * Documentation was faulty.
      ⍝ * 1.5.1
      ⍝   * Test cases improved.
      ⍝ * 1.5.0
      ⍝   * The two-item constructor now accepts an empty text vector as "Log". This defaults to
      ⍝     "Application" then.
      r←(Last⍕⎕THIS)'1.5.2' '2017-03-27'
    ∇

    :Property Log
    :Access Public
        ∇ r←get
          r←_Log
        ∇
    :EndProperty

    :Property Source
    :Access Public
        ∇ r←get
          r←_Source
        ∇
    :EndProperty

⍝ ---------------------------------------

    ∇ make1(source)
      :Access Public
      :Implements Constructor
      ⎕USING←'System.Diagnostics,System.dll' ''
      _Log←''
      _Source←source
      Init ⍬
    ∇

    ∇ make2(log source)
      :Access Public
      :Implements Constructor
      ⎕USING←'System.Diagnostics,System.dll' ''
      _Log←log
      _Source←source
      Init ⍬
    ∇

    ∇ {r}←Init dummy
      r←⍬
      ⍝ We cannot be sure about the source but `SourceExists` won't work , so let's check and create it if needed:
      :If ~System.Diagnostics.EventLog.SourceExists⊂_Source  ⍝ If this fails you are most likely lacking rights!
      ⍝ ↑↑ System.Security.SecurityException? See http://aplwiki.com/WindowsEventLog ↑↑
          :Trap 0
              System.Diagnostics.EventLog.CreateEventSource _Source _Log
          :EndTrap
      :EndIf
    ⍝ Create an EventLog instance and assign its source
      myLog←⎕NEW System.Diagnostics.EventLog(⊂_Log)
      myLog.Source←_Source
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    ∇ {r}←WriteInfo Msg
      :Access Public
     ⍝ Write "Msg" as "Information" to the Windows Event Log.
      r←⍬
      Msg←{0 1∊⍨≡⍵:⊂⍵ ⋄ ⍵}Msg
      {myLog.WriteEntry ⍵ System.Diagnostics.EventLogEntryType.Information}¨Msg
    ∇

    ∇ {r}←WriteError Msg
      :Access Public
     ⍝ Write `Msg` as "Error" to the Windows Event Log.
      r←⍬
      myLog.WriteEntry Msg System.Diagnostics.EventLogEntryType.Error
    ∇

    ∇ {r}←WriteWarning Msg
      :Access Public
     ⍝ Write `Msg` as "Warning" to the Windows Event Log.
      r←⍬
      myLog.WriteEntry Msg System.Diagnostics.EventLogEntryType.Warning
    ∇

    ∇ r←Read;i
      :Access Public
      ⍝ Return **all** event log entries.
      r←''
      :For i :In ⍳myLog.Entries.Count
          r,←⊂(⍕i),'. ',{myLog.Entries.(get_Item ⍵).Message}i-1
      :EndFor
    ∇

    ∇ r←ReadThese rowNumbers;row
      :Access Public
      ⍝ Return the specified log file entries.
      r←''
      :For row :In rowNumbers
          r,←⊂(⍕row),'. ',{myLog.Entries.(get_Item ⍵).Message}row-1
      :EndFor
    ∇

    ∇ {r}←DeleteClass
    ⍝ Deprecated: use DeleteLog instead
      :Access Public
      ⍝ Won't work on built-in logs of course.
      r←⍬
      myLog.Delete⊂_Log
    ∇

    ∇ {r}←DeleteLog
      :Access Public
      ⍝ Won't work on built-in logs of course.
      r←⍬
      myLog.Delete⊂_Log
    ∇

    ∇ r←NumberOfLogEntries
      :Access Public
      r←myLog.Entries.Count
    ∇

    ∇ Close
      :Implements Destructor
      :Trap 0 ⋄ myLog.Close ⋄ :End
    ∇
:EndClass
