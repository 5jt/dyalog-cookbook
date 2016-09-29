:Namespace MyApp
⍝ Dyalog Cookbook, Version 07
⍝ Error handling
⍝ Vern: sjt29sep16

⍝ Object Log is defined by #.Environment.Start

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    (A C F U)←#.(APLTreeUtils Constants FilesAndDirs Utilities)

⍝ Constants and defaults

      ExitOn←{ ⍝ Custom Windows exit codes
          ⍵≡'OK':0
          ⍵≡'NOT STARTED':97
          ⍵≡'VALIDATED':98
          ⍵≡'STARTED':99
          ⍵≡'APPLICATION CRASHED':100
          ⍵≡'INVALID SOURCE':101
          ⍵≡'SOURCE NOT FOUND':102
          ⍵≡'UNABLE TO READ SOURCE':103
          ⍵≡'UNABLE TO WRITE TARGET':104
          ⍵≡'INVALID ALPHABET NAME':105
          911 ⍝ unidentified error
      }

      tabulateObject←{
          (↓n),[1.5]⍵⍎,' ',n←⍵.⎕NL 2
      }

    :Namespace ALPHABETS ⍝ built-in alphabets
        English←⎕A
        French←'AÁÂÀBCÇDEÈÊÉFGHIÌÍÎJKLMNOÒÓÔPQRSTUÙÚÛVWXYZ'
        German←'AÄBCDEFGHIJKLMNOÖPQRSßTUÜVWXYZ'
        Greek←'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'
    :EndNamespace

    :Namespace PARAMETERS ⍝ built-in default job parameters
        accented←0 ⍝ distinguish accented letters
        alphabet←'English'
        out←''
        source←''
    :EndNamespace


⍝ === VARIABLES ===

    ∆←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝάΆέΈήΉίϊΐΊόΌύϋΎώΏ'
    ACCENTS←↑∆ 'AAAAAACDEEEEIIIINOOOOOOUUUUYΑΑΕΕΗΗΙΙΙΙΟΟΥΥΥΩΩ'

⍝ === End of variables definition ===

      CountLetters←{
          accents←↓ACCENTS/⍨~ACCENTS[2;]∊⍺ ⍝ ignore accented chars in alphabet ⍺
          0=≢⍺∩⍵:0 2⍴'' 0 ⍝ nothing of this alphabet in text
          (l c)←↓⍉{⍺(≢⍵)}⌸⍺{⍵⌿⍨⍵∊⍺}accents U.map U.toUppercase ⍵
          ⍉↑(⍺)((c,0)[l⍳⍺])
      }

      retry←{
          ⍺←⊣
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          ⍺ ⍺⍺ ⍵
      }

      within←{ ⍝ file(string) ⍺ within filepath ⍵
          ⍺≡'':⍵
          s←F.CurrentSep
          f←F.NormalizePath ⍵ ⍝ filepath
          f,(s/⍨s≠⊃⌽f),⍺
      }

    ∇ job←CreateJob
     ⍝ job parameters using current defaults
      job←⎕NS''
      job.⎕DF'MyApp Job Parameters'
     ⍝ from PARAMETERS
      job.accented←PARAMETERS.accented
      job.alphabet←PARAMETERS.alphabet
      job.out←PARAMETERS.out
      job.source←PARAMETERS.source
     ⍝ transient
      job.files←''
      job.status←'NOT STARTED'
      job.table←0 2⍴'A' 0
    ∇

    ∇ job←TxtToCsv fullfilepath
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text
      Log.Log'Source: ',fullfilepath
     
      job←CreateJob
      job.source←fullfilepath
      job←CheckAgenda job
      :If job.status≡'VALIDATED'
          job←CountLettersIn job
      :EndIf
      Log.Log⍕job.status
      Log.Log'All done'
    ∇

    ∇ job←CheckAgenda job;type
    ⍝ job: (ns) parameters
      job.source←F.NormalizePath job.source
      :If 0=≢job.source~' '
      :OrIf ~⎕NEXISTS job.source
          job.status←'SOURCE NOT FOUND'
      :ElseIf ~(type←C.NINFO.TYPE ⎕NINFO job.source)∊C.NINFO.TYPES.(DIRECTORY FILE)
          job.status←'INVALID SOURCE'
      :ElseIf 2≠ALPHABETS.⎕NC job.alphabet
          job.status←'INVALID ALPHABET NAME'
      :Else
          type←C.NINFO.TYPE ⎕NINFO job.source
      :EndIf
     
    ⍝ output
      :If job.status≡'NOT STARTED'
          :If job.out≡''
              :Select type
              :Case C.NINFO.TYPES.DIRECTORY
                  job.out←job.source F.{⍵,⍨{⍵↓⍨-CurrentSep=⊃⌽⍵}NormalizePath ⍺}'.CSV'
              :Case C.NINFO.TYPES.FILE
                  job.out←job.source F.{(NormalizePath⊃,/2↑⎕NPARTS ⍺),⍵}'.CSV'
              :EndSelect
          :EndIf
          :If ~⎕NEXISTS⊃⎕NPARTS job.out
          :OrIf {~⎕NEXISTS ⍵:0 ⋄ ~⎕NDELETE ⍵}job.out
              job.status←'UNABLE TO WRITE TARGET'job.out
          :EndIf
      :EndIf
     
     ⍝ files and alphabet characters
      :If job.status≡'NOT STARTED'
          :Select type
          :Case C.NINFO.TYPES.DIRECTORY
              job.files←⊃(⎕NINFO⍠'Wildcard' 1)'*.txt'within job.source
          :Case C.NINFO.TYPES.FILE
              job.files←,⊂job.source
          :EndSelect
          job.characters←(ALPHABETS⍎job.alphabet)~(~job.accented)/ACCENTS[1;]
          job.status←'VALIDATED'
      :EndIf
     
      Log.Log(⊂'[Parameters]'),'='U.join¨↓⍕¨tabulateObject job
    ∇

    ∇ job←CountLettersIn job;i;txt;tbl;enc;nl;lines;bytes
      job.status←'STARTED'
      tbl←0 2⍴'a' 0
      i←1
      :While job.status≡'STARTED'
          :Trap 0
              (txt enc nl)←⎕NGET retry i⊃job.files
              tbl⍪←job.characters CountLetters txt
          :Else
              job.status←'UNABLE TO READ SOURCE'(i⊃job.files)
          :EndTrap
      :Until (≢job.files)<i←i+1
      :If job.status≡'STARTED'
          job.table←⊃{⍺(+/⍵)}⌸/↓[1]tbl ⍝ summary of results from all files
          lines←{⍺,',',⍕⍵}/job.table
          :Trap 0
              bytes←(lines enc nl)⎕NPUT retry job.out C.NPUT.OVERWRITE
              job.status←'OK'
          :Else
              bytes←0
              job.status←'UNABLE TO WRITE TARGET'job.out
          :EndTrap
          Log.Log(⍕bytes),' bytes written to ',job.out
      :EndIf
    ∇

:EndNamespace
