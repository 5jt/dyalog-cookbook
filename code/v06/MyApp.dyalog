:Namespace MyApp
⍝ Dyalog Cookbook, Version 06
⍝ Error handling
⍝ Vern: sjt21sep16

⍝ Object Log is defined by #.Environment.Start

⍝ Environment
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝ Aliases
    (C F U)←#.(Constants FilesAndDirs Utilities) ⍝ must be defined previously

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

    ∇ exit←TxtToCsv ffp;fullfilepath;files;alpha;out;LogError
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text
      Log.Log'Source: ',ffp
      fullfilepath←F.NormalizePath ffp
      LogError←Log∘{code←EXIT⍎⍵ ⋄ code⊣⍺.LogError code ⍵}
     
      :If EXIT.OK=⊃(exit files alpha out)←PARAMETERS CheckAgenda fullfilepath
          exit←alpha CountLettersIn files out
      :EndIf
      Log.Log'All done'
    ∇

    ∇ (exit files alpha out)←p CheckAgenda fullfilepath;type
    ⍝ p: (ns) parameters
    ⍝ source
      :If 0=≢fullfilepath~' '
      :OrIf ~⎕NEXISTS fullfilepath
          exit←LogError'SOURCE_NOT_FOUND'
      :ElseIf ~(type←C.NINFO.TYPE ⎕NINFO fullfilepath)∊C.NINFO.TYPES.(DIRECTORY FILE)
          exit←LogError'INVALID_SOURCE'
      :ElseIf 2≠p.(ALPHABETS.⎕NC alphabet)
          exit←LogError'INVALID_ALPHABET_NAME'
      :Else
          type←C.NINFO.TYPE ⎕NINFO fullfilepath
          exit←EXIT.OK
      :EndIf
     
    ⍝ output
      :If exit≡EXIT.OK
          :If ''≡out←p.output
              :Select type
              :Case C.NINFO.TYPES.DIRECTORY
                  out←fullfilepath F.{{⍵↓⍨-CurrentSep=⊃⌽⍵}NormalizePath ⍺}'.CSV'
              :Case C.NINFO.TYPES.FILE
                  out←fullfilepath F.{(NormalizePath⊃,/2↑⎕NPARTS ⍺),⍵}'.CSV'
              :EndSelect
          :ElseIf ~⎕NEXISTS⊃⎕NPARTS out
              exit←EXIT.UNABLE_TO_WRITE_TARGET
          :EndIf
      :EndIf
     
     ⍝ files and alphabet characters
      :If exit≡EXIT.OK
          :Select type
          :Case C.NINFO.TYPES.DIRECTORY
              files←⊃(⎕NINFO⍠'Wildcard' 1)'*.txt'within fullfilepath
          :Case C.NINFO.TYPES.FILE
              files←,⊂fullfilepath
          :EndSelect
          alpha←p.{(ALPHABETS⍎alphabet)~(~accented)/⍵}ACCENTS[1;]
      :Else
          (alpha files out)←⊂'' ⍝ error defaults
      :EndIf
     
      Log.Log U.join'[Parameters]'{(⊂⍺),⍵}p∘{⍺,'=',⍕⍺⍎⍵}¨'accented' 'alphabet' 'source' 'output'
      Log.Log'fullfilepath=',fullfilepath
      Log.Log U.join'[FILES]'U.push files
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
              exit←LogError'UNABLE_TO_READ_SOURCE: ',i⊃files
          :EndTrap
      :Until (≢files)<i←i+1
      :If exit=EXIT.OK
          lines←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
          :Trap 0
              bytes←(lines enc nl)⎕NPUT retry tgt C.NPUT.OVERWRITE
          :Else
              exit←LogError'UNABLE_TO_WRITE_TARGET: ',tgt
              bytes←0
          :EndTrap
          Log.Log(⍕bytes),' bytes written to ',tgt
      :EndIf
    ∇

:EndNamespace
