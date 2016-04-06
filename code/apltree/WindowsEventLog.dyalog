:Class WindowsEventLog
⍝ This class offers only methods and properties useful to write ordinary _
⍝ application related logging information to the Windows Event Log.
⍝ It also comes with defaults that make this as easy as possible.
⍝ <h2>Examples</h2>
⍝ To write messages to a source "myApp" in the "Application" class:
⍝ <pre>
⍝ my←⎕NEW WindowsEventLog (,⊂'myApp')
⍝ my.WriteInfo 'An information'
⍝ my.WriteError 'An error message'
⍝ my.WriteWarning 'A warning'
⍝ ⎕ex 'my'  ⍝ close it
⍝ </pre>
⍝ Author: Kai Jaeger ⋄ APL Team Ltd ⋄ http://aplteam.com
⍝ Homepage: http://aplwiki.com/WindowsEventLog

    :Include APLTreeUtils

    ⎕io←1 ⋄ ⎕ml←3

    ∇ r←Version
      :Access Public Shared
      r←(Last⍕⎕THIS)'1.2.1' '2015-01-10'
    ∇

    :Property Class
    :Access Public
        ∇ r←get
          r←_Class
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
      _Class←'Application'
      _Source←source
      Init ⍬
    ∇

    ∇ make2(class source)
      :Access Public
      :Implements Constructor
      ⎕USING←'System.Diagnostics,System.dll' ''
      _Class←class
      _Source←source
      Init ⍬
    ∇

    ∇ Init dummy
    ⍝ We cannot be sure about the source, so let's check and create it if needed:
      :If ~System.Diagnostics.EventLog.SourceExists⊂_Source
      ⍝ ↑↑ System.Security.SecurityException? See http://aplwiki.com/WindowsEventLog ↑↑
          System.Diagnostics.EventLog.CreateEventSource _Source _Class
      :EndIf
    ⍝ Create an EventLog instance and assign its source
      myLog←⎕NEW System.Diagnostics.EventLog(⊂_Class)
      myLog.Source←_Source
    ∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    ∇ {r}←WriteInfo Msg
      :Access Public
     ⍝ Write "Msg" as "Information" to the Windows Event Log
      r←⍬
      Msg←{0 1∊⍨≡⍵:⊂⍵ ⋄ ⍵}Msg
      {myLog.WriteEntry ⍵ System.Diagnostics.EventLogEntryType.Information}¨Msg
    ∇

    ∇ {r}←WriteError Msg
      :Access Public
     ⍝ Write "Msg" as "Error" to the Windows Event Log
      r←⍬
      myLog.WriteEntry Msg System.Diagnostics.EventLogEntryType.Error
    ∇

    ∇ {r}←WriteWarning Msg
      :Access Public
     ⍝ Write "Msg" as "Warning" to the Windows Event Log
      r←⍬
      myLog.WriteEntry Msg System.Diagnostics.EventLogEntryType.Warning
    ∇

    ∇ r←Read;i
      :Access Public
      ⍝ Return all event log entries
      r←''
      :For i :In ⍳myLog.Entries.Count
          r,←⊂(⍕i),'. ',{myLog.Entries.(get_Item ⍵).Message}i-1
      :EndFor
    ∇

    ∇ r←ReadThese ind;i
      :Access Public
      ⍝ Return the specified log file entries
      r←''
      :For i :In ind
          r,←⊂(⍕i),'. ',{myLog.Entries.(get_Item ⍵).Message}i-1
      :EndFor
    ∇

    ∇ {r}←DeleteClass
      :Access Public
      ⍝ Won't work on built-in classes, of course
      r←⍬
      myLog.Delete⊂_Class
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