{:: encoding="utf-8" /}
[parm]:title     = 'GUI'
[parm]:linkToCSS = 1
[parm]:printCSS  = 'C:\T\Projects\APLTree\Meddy\CSS\BlackOnWhite_print.css'
[parm]:screenCSS = 'C:\T\Projects\APLTree\Meddy\CSS\BlackOnWhite_screen.css'
[parm]:cssURL    = ''



# User interface 

## Introduction

Modern graphical user interfaces (GUIs, or more simply, UIs) are a wonder. UI conventions are so widely known it is now unremarkable for people to start using applications without prior training, expecting the software to make clear what they need to do. 

This is a high standard to meet, and writing UIs is a deep art. The primary platforms for professional writers of UIs are currently a combination of HTML 5 and JavaScript (HTML/JS) and Windows Presentation Foundation (WPF). These are rich platforms, which enable effective and attractive UIs to be written. 

The high quality of these UIs is particularly important for mass-market software, where users are unskilled and unsupported. 

HTML/JS and WPF have a high learning threshold. There is much to be mastered before you can write good UIs on these platforms. 

You have an alternative. The GUI tools native to Dyalog support perfectly workmanlike GUIs. They exploit and extend your existing knowledge of Dyalog. If you are producing high-value software for a few users, rather than software for casual use by millions, a native Dyalog GUI might be your best platform.

You can still run your application from within a browser if you wish to: Amazon offers the "AppStream" [^appstream] service allowing exactly that.


### ⎕WC versus ⎕NEW

`⎕NEW` came much later than `⎕WC`. Is `⎕NEW` replacing `⎕WC`? Certainly not. It's just an alternative. Both have pros and cons, but after having tried them both in real-world projects we settle for `⎕WC`. Here's why:

**Pro `⎕NEW`:**

* Syntax checks are more strict. Yes, that is actually an advantage: problems are detected early.
* It does not need a name. 

  This point has implications that are not obvious: when you create a GUI control within a class and then try to use it later as parent in another GUI control in a different class you cannot create a reference from the `⎕WC` statement with something like:

  ~~~
  ref←⍎'MyControlName'parent.⎕wc'Button ('Caption' 'OK')
  ~~~

  because a name used by `⎕WC` is local to the class the `⎕WC` was executed in. `⎕NEW` gets us around this problem.

**Pro `⎕WC`:**

* Every control has its own name, and that name shows in the Event Viewer when debugging a GUI. With `⎕NEW` you see something like `[Form].[SubForm].[Group].[Button]` which is not exactly helpful.
* Can host Microsoft's WebBrowser control, an HTML renderer that can be integrated into your GUI.

We hope that Dyalog will eventually use `⎕DF` for the Event Viewer for GUI controls created by `⎕NEW`. However, for the time being the disadvantages on `⎕NEW` are severe, therefore we settle for `⎕WC`.


### A simple example

Creating a GUI form in Dyalog could hardly be simpler:

~~~
      ∆Form←⍎'MyForm'⎕WC 'Form'
      ∆Form.Caption←'Hello world'
~~~      

![Hello world form](Images/form_01.png)

To the form we add controls, set callback functions to run when certain events occur, and invoke the form's `Wait` method or `⎕DQ` to hand control over to the user. See the _Dyalog for Microsoft Windows Interface Guide_ for details and tutorials. 

Experience has shown that it is a good idea to keep references to all controls as well as any variables that belong logically to those controls within a namespace. Since this is a temporary namespace --- it will cease to exist once the form is closed --- we use an unnamed namespace for this. 

We create the controls with names but generate references for them which we assign to the very same names within that unnamed namespace. The concept will become clear when we create an example.


## A simple UI with native Dyalog forms

We are going to implement a sample form that looks like this:

![Find and replace](Images/gui_example.png)

Obviously this is a GUI that allows a programmer to search the current workspace.

We would like to emphasize that it is a very good idea to keep the UI and its code separate from the application. Even if you think that you are absolutely sure that you will never go for a different --- or additional --- UI, you should still keep it separate. 

Over and over again assumptions like "This app will only be used for a year or two" or "This app will never use a different type of GUI" have proven to be wrong. 

Better prepare for it from the start, in particular because it takes actually little effort to do this early, but it will be a major effort if you need to change or add a GUI later.

In this chapter we will construct the GUI shown above as an example, and we will keep all stuff that is not related to the GUI in `#.BusinessLogic`.

Everything that is GUI-related starts their names with `MainGUI`.

We start with creating...


⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹⌹
the main function which we call `Run`:

~~~
:Namespace MainGUI

    ∇ {n}←Run dummy;n;∆Posn;∆Wsid;U
      ⎕IO←1 ⋄ ⎕ML←1
      n←Init ⍬
      n←CreateGUI n
      n.SearchFor U.DQ n.∆Form
      Shutdown n
    ⍝Done
    ∇

:EndNamespace
~~~

What this function does:

* It sets system variables.
* It prepares (initializes) the application.
* It creates the GUI.
* It hands over control to the user.
* When the user quits it cleans up.

Next we introduce the `Init` function:

~~~
∇ n←Init dummy
  U←##.GuiUtils
  n←U.CreateNspace
  n.∆Buttons←n.⎕NS''
  n.∆Labels←n.⎕NS''
  n.(∆V_Gap ∆H_Gap)←##.GuiGlobals.(∆V_Gap ∆H_Gap)
  ∆Posn←80 30
  ∆Size←600 800
  n.InputFont←'InputFont'⎕WC'Font'('PName' 'APL385 Unicode')('Size' 17)
⍝Done
∇
~~~

* It creates a reference to `GuiUtils`, something that does not yet exists.
* It calls a method `CreateNspace` ikn `GuiUtils` which seem to return a namespace which is assigned to `n`.
* It creates a globals variable `∆Buttons` in `n` which we use to collect references to all push buttons on the GUI.
* It creates a global variable `∆Labels` in `n` which we use to collect references to all lables on the GUI.
* It creates two globals variables `∆V_Gap` and `∆H_Gap` in `n` with values we borrow from `GuiGlobals which again does not exist yet.
* It defines two globals `∆Posn` and `∆Size` which will defines the position and the size of the main form.
* It creates a font object.

Next we introduce the namespace script `GuiUtils`:

~~~
:Namespace GuiUtils

    ⎕IO←1 ⋄ ⎕ML←1

      GetRef2n←{
          9=⍵.⎕NC'n':⍵.n
          ∇ ⍵.##
      }

    ∇ r←CreateNspace
      r←⎕NS''
      r.⎕FX'r←∆List' 'r←'' ''~¨⍨↓⎕nl 9'
    ⍝Done
    ∇

      AddPosnAndSize←{
          +⌿↑⍵.(Posn Size)
      }

    ∇ {r}←{focus}DQ ref
      focus←{0<⎕NC ⍵:⍎⍵ ⋄ ref}'focus'
      ⎕NQ focus'GotFocus' ⋄ r←⎕DQ ref
     ⍝Done
    ∇

:EndNamespace
~~~

This introduces 4 functions. At the moment only `CreateNspace` is of interest to us; the others will be discussed later. `CreateNspace` creates an unnamed namespace, populates it with a niladic function `∆List` which returns the names of all namespaces within that unnamed namespaces. Of course their are'nt any yet.


We then create `GuiGlobal`:

~~~
:Namespace GuiGlobals

    ∆V_Gap←10
    ∆H_Gap←5

:EndNamespace
~~~

The `V` stands for "Vertical" and the "H" for "Horizontal". Those two variables defined the vertical and horizontal distance between controls on the GUI.

Now the `Init` function would run; we are ready to create the function `CreateGUI`:

~~~
∇ n←CreateGUI n
[1]   n←CreateMainForm n
[2]   n←CreateSearch n
[3]   n←CreateStartLookingHere n
[4]   n.∆Groups←⎕NS''
[5]   n←CreateOptionsGroup n
[6]   n←CreateObjectTypesGroup n
[7]   n←CreateScanGroup n
[8]   n←CreateRegExGroup n
[9]   {⍵.Size←(⊃⊃⌈/⍵.Size),¨2⊃¨⍵.Size}'Group'⎕WN n.∆Form
[10]   n←CreateList n
[11]   n←CreatePushButtons n
[12]   n←CreateHiddenButtons n
[13]   n.HitList.Size[1]-←n.∆V_Gap+n.∆Form.Size[1]-n.Find.Posn[1]
[14]   n.(⍎¨↓⎕NL 9).onKeyPress←⊂'OnKeyPress'
[15]   n.∆WriteToStatusbar←n∘{⍺.Statusbar.StatusField1.Text←⍵ ⋄ 1:r←⍬}
[16]   n.∆Form.onConfigure←'OnConfigure'(335,CalculateMinWidth n)
[17] ⍝Done
∇
~~~

Note that for any of the controls (what are we searching, were to start, the groups) we have a didicated function `CreateSearch`, `CreateStartLookingHere` etc. Experience has shown that this is the most readable and maintainable way of creating controls.

The function does some more things;

* In line 4 a global variable `∆Groups` is created. We will discuss later why this is useful.
* In line 9 the width of the form is calculated depending on the space the groups require.
* In line 13 the size of the ListView named `HitList` is calculated.
* In line 14 a KeyPress event handler is established for **all** controls.
* In line 15 we establish a function `WriteToStatusbar` which gets a glued left argument: the `n` namespace which will be discussed soon.
* In line 16 we establish a handler `OnConfigure` which gets a left argument: a vector of length two with 335 being the first item and the result of the function `CalculateMinWidth`.

In the next step we create the function `CreateMainForm`:

~~~
∇ n←CreateMainForm n;∆
[1]   ∆←⊂'Form'
[2]   ∆,←⊂'Coord' 'Pixel'
[3]   ∆,←⊂'Caption' 'MyApp'
[4]   ∆,←⊂'Posn'∆Posn
[5]   ∆,←⊂'Size'∆Size
[6]   n.∆Form←⍎'Form'⎕WC ∆
[7]   n.∆Form.n←n
[8]   n←CreateMenubar n
[9]   n←CreateStatusbar n
[10]  ⍝Done
∇
~~~

The function collects properties which are assigned to a local variables `∆`. We don't attempt to give it a proper name here because we just use it to collect stuff.

Why are we not assigning the properties in one go? Something like this:

~~~
n.∆Form←⍎'Form'⎕WC 'Form'('Coord' 'Pixel')('Caption' 'MyApp')('Posn'∆Posn)('Size'∆Size)
~~~

Haven't we agreed that shorter programs are better? We did, but there are exceptions. Apart from being more readable having just one property on a line has the big advantage of allowing us to skip the line in the Tracer if wish so. That is particularly pleasant when we don't want a statement like `('Visible' 0)` or `('Active' 0)` to be executed. If they are part of a lengthy line, well, you get the idea.


### Collecting controls

We are not using a designer for creating the GUI, we use APL code. We start with a container that will collect the names of most if not all the controls we are about to create. That container is a namespace. We suggest to use a short name, because you will refer to this name very often. Let's name it `n` like "names" as in `n←⎕NS ''`. We do this because the hierarchy of the controls is not of much interest to us, we are happy to refer to them by a simple name. Flattening the hirarchy has even advantages: it makes it much easier to move controls elsewhere.

We will create the different controls in dedicated functions. Experience has shown that this is more readable and easier to maintain (in case a re-design of the GUI is needed) than any other approach. Before we start to produce code we create a namespace `GUI` in the root that will hold the main form and all forms created by actions on the main form. Everything that is not the main form will go into its own sub namespace:

~~~
      'GUI. #.⎕NS''
      )cs #.GUI
~~~

Let's start with a function that creates the whole form. Since we have already jumped into `#.GUI` we can create this function locally:

~~~
∇ n←CreateGUI n
  n←CreateMainForm n
  n←CreateSearch n
  n←CreateReplace n
  n←CreateOptionGroup n
  n←CreateScanGroup n
  n←CreateRegExGroup n
  n←CreatePushButtons n
∇
~~~

## To be invented

......

⍝TODO Check!

~~~
    ∇ {r}←Run dummy;n;A
     ⍝ The main ...
      ⎕IO←1 ⋄ ⎕ML←`
      A←#.APLTreeUtils 
      r←⍬
      n←⎕NS ''
      n←CreateGui n
      n←Init n
      DQ n.∆form
      Shutdown
     ⍝ done
    ∇
~~~    

I> For the time being we create the `n` namespace with `⎕NS`. Later we will introduce a class that lives in `#.GUI` which not only creates a new namespace but populates that namespace with some useful methods.

Here we see the outline clearly. An instance of the RefNamespace class is assigned to `ui`. It is a namespace, empty apart from some standard methods -- try `]ADoc #.RefNamespace` to see details. 

Functions `CreateGui` and `Init` build and initialise the user interface encapsulated in `ui`. Neither function needs to return a result, but doing so means the functions could be chained, for example:

      ui←Init CreateGui R.Create'User Interface'


### Forms

Again, the functional style of `CreateGui` produces expository code. 

~~~
    ∇ ui←CreateGui ui
      ui.∆LanguageCommands←''
      ui.∆MenuCommands←''
     
      ui←CreateForm ui
      ui←CreateMenubar ui
      ui←CreateEdit ui
      ui←CreateStatusbar ui
    ∇
~~~    

The UI namespace gets a couple of empty lists as properties: `∆LanguageCommands` and `∆MenuCommands`. We'll come to those in the menu bar. 

Creating the form is also straightforward:

~~~
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
~~~    

But notice key moves in the last two lines. When the form is created, its reference is assigned to a new property of the UI namespace: `∆form`. And, as will all its children, the form is given, as property `ui`, a reference to the UI namespace. 

It follows, from any control `obj` in the UI, the form can be referred to as `obj.ui.∆form`. 

We'll see this first in creating the menubar. 


### Controls

Here we create a menubar as a child of the form, which we can refer to as `ui.∆form`. A reference to the menubar is saved in the UI namespace under the name `MB`. 

~~~
    ∇ ui←CreateMenubar ui
      ui.MB←ui.∆form.⎕NEW⊂'Menubar'
     
      ui←CreateFileMenu ui
      ui←CreateLanguageMenu ui
     
      ui.∆MenuCommands.onSelect←⊂'OnMenuCommand'
      ui.∆MenuCommands.ui←ui
    ∇
~~~    

When both menus have been made, the callback `OnMenuCommand` is set for all the objects in the list `ui.∆MenuCommands`. Presumably that list was populated as a side effect of `CreateFileMenu` and/or `CreateLanguageMenu`. Just so:

~~~
    ∇ ui←CreateFileMenu ui
      ui.MenuFile←ui.MB.⎕NEW'Menu'(⊂'Caption' '&File')
     
      ui.Quit←ui.MenuFile.⎕NEW'MenuItem'(⊂'Caption'('Quit',(⎕UCS 9),'Alt+F4'))
      ui.∆MenuCommands,←ui.Quit
    ∇
~~~    

Just so: the menu item Quit is created as a child of the File menu, and a reference to it appended to `ui.∆MenuCommands`. 

The Language menu has to be created dynamically from the languages defined in `#.MyApp.ALPHABETS`. 

In principle we have a serious potential problem here. We're assigning menu items to alphabet names in the UI. The alphabet names are drawn from (among other sources) INI files. They could conflict with names defined during `CreateGui`. Although that seems highly unlikely, we should encapsulate the language names in their own namespace. For now, we've left a comment on the line that might break, and wrapped the assignment in a for-loop rather than using the _each_ operator. 

~~~
    ∇ ui←CreateLanguageMenu ui;alph;mi
      ui.MenuLanguage←ui.MB.⎕NEW'Menu'(⊂'Caption' '&Language')
     
      :For alph :In U.m2n M.ALPHABETS.⎕NL 2
          mi←ui.MenuLanguage.⎕NEW'MenuItem'(⊂'Caption'alph)
          alph ui.{⍎⍺,'←⍵'}mi ⍝ FIXME possible conflict with control names
          ui.∆LanguageCommands,←mi
      :EndFor
      ui.∆LanguageCommands.Checked←ui.∆LanguageCommands∊ui⍎M.PARAMETERS.alphabet
      ui.∆MenuCommands,←ui.∆LanguageCommands
    ∇
~~~    

The Language menu items use the `Checked` property to display the current selection. By listing them in the property `∆LanguageCommands`, we can set `Checked` in a single test.


### Callbacks and the event queue

A _callback_ function receives as right argument information about the event that triggered it, and a reference to the object that fired it. The callback takes its own action and returns a result that tells `⎕DQ` what else to do before moving on to the next event. A result of 0 tells `⎕DQ` to do nothing more.  

We've set a single callback function `OnMenuCommand` on all the menu items. In this skeleton interface, a 'portmanteau' function such as `OnMenuCommand` looks a bit excessive. After all, it immediately decides whether it has been invoked from the Quit menu item or one of the Language menu items. Simpler to set one callback on the Quit menu item and a different one on all the Language menu items. 

But with many more menu items that strategy produces a 'cloud' of tiny callback functions. More legible to have a single 'portmanteau' callback for all menu items. 

~~~
    ∇ Z←OnMenuCommand(obj xxx);ui
      ui←GetRef2ui obj
      :Select obj
      :Case ui.Quit
          ⎕NQ ui.∆form'Close'
      :CaseList ui.∆LanguageCommands
          M.PARAMETERS.alphabet←obj.Caption
          ui.∆LanguageCommands.Checked←ui.∆LanguageCommands=obj
      :EndSelect
      Z←0
    ∇
~~~    

The first move of the callback finds the UI namespace. This should be simply `obj.ui` but in case the `ui` property has not been defined for the invoking control, we use `GetRef2ui`, which either returns the property or searches the object's ancestors until it finds it. (Because the `ui` property was defined for the form itself, we know any search will at worst terminate there.)

~~~
    GetRef2ui←{9=⍵.⎕NC'ui':⍵.ui ⋄ ∇ ⍵.##}
~~~    

Object references are scalars, so the expression `ui.∆LanguageCommands=obj` yields a simple Boolean vector. 


### Quitting the UI

`⎕DQ` on the form was started by `Run`. (Using the cover function `DQ`, which provides a shell for future logging, tracing and debugging.) 

In the `OnMenuComamnd` callback, if `obj` was the Quit menu, a Close event is enqueued for the form. When the callback exits, that Close event is the next one `⎕DQ` encounters. 

When `⎕DQ` encounters the Close event for its argument, it closes the object and exits. That terminates `DQ`. The `Shutdown` function deletes the form explicitly, rather than relying on Windows to do so when `Run` leaves the execution stack and the UI namespace in its local variable `ui` vanishes.


### D functions

Most of the UI functions can be written as Dfns and some writers prefer this form. Here as examples are a constructor and a callback. 

~~~
      CreateGui←{
          ui←⍵
     
          ui.∆LanguageCommands←''
          ui.∆MenuCommands←''
     
          ui←CreateForm ui
          ui←CreateMenubar ui
          ui←CreateEdit ui
          ui←CreateStatusbar ui
     
          ui
      }

      OnMenuCommand←{
          (obj xxx)←⍵
          ui←GetRef2ui obj
          obj=ui.Quit:0⊣⎕NQ ui.∆form'Close'
          M.PARAMETERS.alphabet←obj.Caption
          ui.∆LanguageCommands.Checked←ui.∆LanguageCommands=obj
          0
      }
~~~


[^Mansour]: Thanks to Paul Mansour, the first person we know to describe this strategy. 


[^appstream]: <https://aws.amazon.com/appstream2/>