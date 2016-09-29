:Namespace UI
⍝ Dyalog Cookbook. Version 07
⍝ User interface
⍝ Vern: sjt29sep16

   ⍝ aliases
    (A E F M R U)←#.(APLTreeUtils Environment FilesAndDirs MyApp RefNamespace Utilities)

    ∇ Run;ui
      ui←R.Create'User Interface'
      ui←CreateGui ui
      ui←Init ui
      ui.∆Path←F.PWD
      DQ ui.∆form
      Shutdown
     ⍝ done
    ∇

    ∇ ui←CreateGui ui
      ui.∆LanguageCommands←''
      ui.∆MenuCommands←''
     
      ui←CreateForm ui
      ui←CreateMenubar ui
      ui←CreateEdit ui
    ∇

    ∇ ui←CreateForm ui;∆
      ui.Font←⎕NEW'Font'(('Pname' 'APL385 Unicode')('Size' 16))
      ui.Icon←⎕NEW'Icon'(E.IconComponents{↓⍉↑⍵(⍺⍎¨⍵)}'Bits' 'CMap' 'Mask')
     
      ∆←''
      ∆,←⊂'Coord' 'Pixel'
      ∆,←⊂'Posn'(50 70)
      ∆,←⊂'Size'(400 500)
      ∆,←⊂'Caption' 'Frequency Counter'
      ∆,←⊂'MaxButton' 0
      ∆,←⊂'FontObj'ui.Font
      ∆,←⊂'IconObj'ui.Icon
      ui.∆form←⎕NEW'Form'∆
      ui.∆form.ui←ui
    ∇

    ∇ ui←CreateMenubar ui
      ui.MB←ui.∆form.⎕NEW⊂'Menubar'
     
      ui←CreateFileMenu ui
      ui←CreateLanguageMenu ui
     
      ui.∆MenuCommands.onSelect←⊂'OnMenuCommand'
      ui.∆MenuCommands.ui←ui
    ∇

    ∇ ui←CreateFileMenu ui
      ui.MenuFile←ui.MB.⎕NEW'Menu'(⊂'Caption' '&File')
     
      ui.Quit←ui.MenuFile.⎕NEW'MenuItem'(⊂'Caption'('Quit',(⎕UCS 9),'Alt+F4'))
      ui.∆MenuCommands,←ui.Quit
    ∇

    ∇ ui←CreateLanguageMenu ui;alph;mi
      ui.MenuLanguage←ui.MB.⎕NEW'Menu'(⊂'Caption' '&Language')
     
      :For alph :In U.m2n M.ALPHABETS.⎕NL 2
          mi←ui.MenuLanguage.⎕NEW'MenuItem'(⊂'Caption'alph)
          alph ui.{⍎⍺,'←⍵'}mi ⍝ Watch Out for conflict with control names
          ui.∆LanguageCommands,←mi
      :EndFor
      ui.∆LanguageCommands.Checked←ui.∆LanguageCommands∊ui⍎M.PARAMETERS.alphabet
      ui.∆MenuCommands,←ui.∆LanguageCommands
    ∇

    ∇ ui←CreateEdit ui;∆
      ∆←''
      ∆,←⊂'Posn'(0 0)
      ∆,←⊂'Size'ui.∆form.Size
      ∆,←⊂'AcceptFiles' 1
     
      ui.Edit←ui.∆form.⎕NEW'Edit'∆
      ui.Edit.onDropFiles←'OnDropFiles'
    ∇

    ∇ ui←Init ui
    ∇

    ∇ Z←OnDropFiles(obj xxx paths xxx xxx);job;ui;text;i;ok;tbl
      ui←GetRef2ui obj
      tbl←0 2⍴' ' 0
      i←0
      ok←1
      :While (≢paths)≥i←i+1
            job←M.CreateJob
            job.source←i⊃paths
          job←M.TxtToCsv job
          tbl⍪←job.table
      :Until ~ok←job.status≢'OK'
      :If ok
          text←U.join{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
      :Else
          text←job.status
      :EndIf
      ui.Edit.Text←text
      Z←0
    ∇

    ∇ Z←OnMenuCommand(obj xxx);ui
      ui←GetRef2ui obj
      :Select obj
      :Case ui.Quit
          Z←0⊣⎕NQ ui.∆form'Close'
      :CaseList ui.∆LanguageCommands
          M.PARAMETERS.alphabet←obj.Caption
          ui.∆LanguageCommands.Checked←ui.∆LanguageCommands=obj
      :EndSelect
    ∇

    ∇ {r}←DQ ref
      r←⎕DQ ref
     ⍝ done
    ∇

    ∇ Shutdown
      :If A.IsDevelopment
          →
      :Else
          ⎕OFF
      :EndIf
    ∇

    GetRef2ui←{9=⍵.⎕NC'ui':⍵.ui ⋄ ∇ ⍵.##}

:EndNamespace
