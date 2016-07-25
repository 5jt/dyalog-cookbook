:Namespace MyApp
⍝ Dyalog Cookbook, Version 06
⍝ Error handling
⍝ Vern: sjt25jul16

⍝ Objects Log and Params are defined by #.Environment.Start

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    (C U)←#.(Constants Utilities) ⍝ must be defined previously

⍝ Constants and defaults

    :Namespace EXIT
       ⍝ Custom Windows exit codes
        OK←0
        APPLICATION_CRASHED←100
        INVALID_SOURCE←101
        SOURCE_NOT_FOUND←102
        UNABLE_TO_READ_SOURCE←103
        UNABLE_TO_WRITE_TARGET←104
        INVALID_ALPHABET_NAME←105
    :EndNamespace

    :Namespace PARAMETERS
        :Namespace ALPHABETS
            English←⎕A
            French←'AÁÂÀBCÇDEÈÊÉFGHIÌÍÎJKLMNOÒÓÔPQRSTUÙÚÛVWXYZ'
            German←'AÄBCDEFGHIJKLMNOÖPQRSßTUÜVWXYZ'
            Greek←'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'
        :EndNamespace
        accented←0
        alphabet←'English'
        source←''
        output←''
    :EndNamespace


⍝ === VARIABLES ===

    ∆←'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝάΆέΈήΉίϊΐΊόΌύϋΎώΏ'
    ACCENTS←↑∆ 'AAAAAACDEEEEIIIINOOOOOOUUUUYΑΑΕΕΗΗΙΙΙΙΟΟΥΥΥΩΩ'

⍝ === End of variables definition ===

      CountLetters←{
          accents←↓ACCENTS/⍨~ACCENTS[2;]∊⍺ ⍝ ignore accented chars in alphabet ⍺
          ⍺{⍵[⍺⍋⍵[;1];]}{⍺(≢⍵)}⌸⍺{⍵⌿⍨⍵∊⍺}accents U.map U.toUppercase ⍵
      }

      retry←{
          ⍺←⊣
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          0::⍺ ⍺⍺ ⍵⊣⎕DL 0.5
          ⍺ ⍺⍺ ⍵
      }

    ∇ exit←TxtToCsv fullfilepath;files;alpha;out
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text
      Log.Log'Source: ',fullfilepath

     ⍝ Output defaults to CSV sibling of source
      :If 0=×≢out←Params.output
          out←(⊃,/2↑⎕NPARTS fullfilepath),'.CSV'
      :EndIf
     
      :If EXIT.OK=⊃(exit files alpha)←Params CheckAgenda fullfilepath
          exit←alpha CountLettersIn files out
      :EndIf
      Log.Log'All done'
    ∇

    ∇ (exit files alphabet)←params CheckAgenda fullfilepath;type
      (files alphabet)←'' '' ⍝ error defaults
      :If 0=≢fullfilepath~' '
      :OrIf ~⎕NEXISTS fullfilepath
          exit←LogError'SOURCE_NOT_FOUND'
      :ElseIf ~(type←C.NINFO.TYPE ⎕NINFO fullfilepath)∊C.NINFO.TYPES.(DIRECTORY FILE)
          exit←LogError'INVALID_SOURCE'
      :ElseIf 2≠params.(ALPHABETS.⎕NC alphabet)
          exit←LogError'INVALID_ALPHABET_NAME'
      :Else
          exit←EXIT.OK
          :Select type
          :Case C.NINFO.TYPES.DIRECTORY
              files←⊃(⎕NINFO⍠'Wildcard' 1)fullfilepath,'\*.txt'
          :Case C.NINFO.TYPES.FILE
              files←,⊂fullfilepath
          :EndSelect
          alphabet←params.{(ALPHABETS⍎alphabet)~(~accented)/⍵}ACCENTS[1;]
      :EndIf
    ∇

    ∇ exit←alphabet CountLettersIn(files tgt);i;txt;tbl;enc;nl;lines;bytes
     ⍝ Exit code from writing a letter-frequency count for a list of files
      tbl←0 2⍴'A' 0
      exit←EXIT.OK ⋄ i←1
      :While exit=EXIT.OK
          :Trap 0
              (txt enc nl)←⎕NGET retry i⊃files
              tbl⍪←alphabet CountLetters txt
          :Else
              exit←LogError'UNABLE_TO_READ_SOURCE'
          :EndTrap
      :Until (≢files)<i←i+1
      :If exit=EXIT.OK
          lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
          :Trap 0
              bytes←(lines enc nl)⎕NPUT retry tgt C.NPUT.OVERWRITE
          :Else
              exit←LogError'UNABLE_TO_WRITE_TARGET'
              bytes←0
          :EndTrap
          Log.Log(⍕bytes),' bytes written to ',tgt
      :EndIf
    ∇

:EndNamespace
