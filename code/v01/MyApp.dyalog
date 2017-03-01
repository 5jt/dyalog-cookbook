:Namespace MyApp
⍝ Version 1
⍝ === VARIABLES ===

Accents←2 28⍴'ÁÂÃÀÄÅÇÐÈÊËÉÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝAAAAAACDEEEEIIIINOOOOOOUUUUY'

⍝ === End of variables definition ===

(⎕IO ⎕ML ⎕WX ⎕PP ⎕DIV)←0 3 3 15 1

 CountLetters←{
     ⍝ Table of letter frequency in txt
     {⍺(≢⍵)}⌸⎕A{⍵/⍨⍵∊⍺}(↓Accents)map toUppercase ⍵
 }

∇ noOfBytes←TxtToCsv fullfilepath;NINFO_WILDCARD;NPUT_OVERWRITE;csv;tgt;files;path;stem;txt;enc;nl;lines
     ⍝ Write a sibling CSV of the TXT located at fullfilepath,
     ⍝ containing a frequency count of the letters in the file text.
 NINFO_WILDCARD←NPUT_OVERWRITE←1 ⍝ constants
 fullfilepath~←'"'
 csv←'.csv'
 :Select 1 ⎕NINFO fullfilepath
 :Case 1 ⍝ folder
     tgt←fullfilepath,'total',csv
     files←⊃(⎕NINFO⍠NINFO_WILDCARD)fullfilepath,'\*.txt'
 :Case 2 ⍝ file
     (path stem)←2↑⎕NPARTS fullfilepath
     tgt←path,stem,csv
     files←,⊂fullfilepath
 :EndSelect
     ⍝ assume txt<memory
 (txt enc nl)←{(⊃,/1⊃¨⍵)(1 2⊃⍵)(1 3⊃⍵)}⎕NGET¨files
 lines←','join¨↓⍕¨{⍵[⍒⍵[;2];]}CountLetters txt
     ⍝ use encoding and NL from first source file
 noOfBytes←(lines enc nl)⎕NPUT tgt NPUT_OVERWRITE
     ⍝Done
∇

 join←{
     ⍺←⎕UCS 13 10
     (-≢⍺)↓⊃,/⍵,¨⊂⍺
 }

 map←{
     (old new)←⍺
     nw←∪⍵
     (new,nw)[(old,nw)⍳⍵]
 }

 toUppercase←{1(819⌶)⍵}

:EndNamespace
