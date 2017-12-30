{:: encoding="utf-8" /}
[parm]:title     = 'GUI'


# Graphical user interface 

## Introduction

Modern graphical user interfaces (GUI) are a wonder. GUI conventions are so widely known it is now unremarkable for people to start using applications without prior training, expecting the software to make clear what they need to do. 

This is a high standard to meet, and writing UIs is a deep art. The primary platforms for professional writers of UIs are currently a combination of HTML 5 and JavaScript (HTML/JS) and Windows Presentation Foundation (WPF). These are rich platforms, which enable effective and attractive UIs to be written. 

The high quality of these UIs is particularly important for mass-market software, where users are unskilled and unsupported. 

HTML/JS and WPF have a high learning threshold. There is much to be mastered before you can write good UIs on these platforms. 

You have an alternative. The GUI tools native to Dyalog support perfectly workmanlike GUIs. They exploit and extend your existing knowledge of Dyalog. If you are producing high-value software for a few users, rather than software for casual use by millions, a native Dyalog GUI might be your best platform.

You can still run your application from within a browser if you wish to: Amazon offers the "AppStream" [^appstream] service allowing exactly that.


### `⎕WC` versus `⎕NEW`

`⎕NEW` came much later than `⎕WC`. Is `⎕NEW` replacing `⎕WC`? Certainly not. It's just an alternative. Both have pros and cons, but after having tried them both in real-world projects we settle for `⎕WC`. Here's why:

**Pro `⎕NEW`:**

* Syntax checks are stricter. Yes, that is actually an advantage: problems are detected early.
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

Experience has shown that it is a good idea to keep references to all controls as well as any variables that belong logically to those controls within a namespace. Since this is a temporary namespace --- it will exist only as long as the application is running --- we use an unnamed namespace for this. 

We create the controls with names but generate references for them which we assign to the very same names within that unnamed namespace. The concept will become clear when we create an example.


### A simple GUI with native Dyalog forms

We are going to implement a sample form that looks like this:

![Find and replace](Images/gui_example.png)

Obviously this is a GUI that allows a programmer to search the current workspace.

We would like to emphasize that it is a very good idea to keep the GUI and its code separate from the application. Even if you think that you are absolutely sure that you will never go for a different --- or additional --- GUI, you should still keep it separate. 

Over and over again assumptions like "This app will only be used for a year or two" or "This app will never use a different type of GUI" have proven to be wrong. 

Besides, testing the business logic of an application is way easier when it is separated from the GUI.

Better prepare for it from the start, in particular because it takes actually little effort to do this early, but it will be a major effort if you need to change or add a GUI later.

In this chapter we will construct the GUI shown above as an example, and we will keep all stuff that is not related to the GUI in a namespace `BusinessLogic`.


### The goal

What we try to achieve is simple: create code that is easy to understand and easy to change.

In order to achieve that we do the following:

* We keep all controls and all data in a single namespace `n`; we've already discussed that, now we need to put this into practice.

* We don't define more than one property at the time when creating a GUI control.

  This is not only easier to understand and maintain, it also allows us to skip over certain properties in the Tracer; an obvious example is a line `props,←⊂'Visible' 0`; it's easy to imagine why you don't want that to be executed when debugging a GUI application.

* We keep the functions that create the GUI short so that each function is solving just one task.

While reading this you might think something along the lines of "I've never heard a programmer saying that she strived for unmaintainable code yet most GUI code is ugly spaghetti code which is actually really hard to understand!". Stay with us!


## The implementation


### Prerequisites

We create a top-level namespace that will host our application:

~~~
      'MyApp' ⎕NS ''
~~~

We need three sub namespaces within `MyApp`:

~~~
      'GUI'#.MyApp.⎕ns''
      'BusinessLogic'#.MyApp.⎕ns''
      'GuiUtils'#.MyApp.⎕ns''
~~~

* `GUI` will host everything that is related to the user interface

* `BusinessLogic` will host the functions that do the hard work.

* `GuiUtils` hosts functions that would be useful for other forms than the main form.


### The function `GUI.Run`

We start with the function `Run`:

~~~
     ∇ {n}←Run testFlag
[1]    ⎕IO←1 ⋄ ⎕ML←1
[2]    'Invalid right argument'⎕SIGNAL 11/⍨~(⊂testFlag)∊0 1
[3]    n←Init ⍬
[4]    n.∆TestFlag←testFlag
[5]    n←CreateGUI n
[6]    :If 0=testFlag
[7]        n.SearchFor U.DQ n.∆Form
[8]        Shutdown n
[9]    :EndIf
[10]  ⍝Done
     ∇
~~~

What this function does:

* It sets system variables.

* It prepares (initializes) the application by calling `Init`.

* It assigns `testFlag` to `n.∆TestFlag` so that all GUI callbacks will have access to this; we'll discuss soon how this magic works --- it's _not_ because `n` is global.

* It creates the GUI by calling `CreateGUI`.
  
  * `n.SearchFor` points to the "Search for:" field in the GUI we are about to create. That is going to get the focus.
  
  * `n.∆form` points to the main form.

* It hands over control to the user by calling `DQ`.

* When the user quits it cleans up by calling `Shutdown`.

Notes:

* The function returns a shy result, the namespace `n`; this is only needed for test cases.

* Not that neither the function `U.DQ` nor `Shutdown` is executed in case the right argument is `1`. We will discuss this later.


### The function `GUI.Init`


Next we introduce the `Init` function:

~~~
     ∇ n←Init dummy
[1]    U←GuiUtils
[2]    n←U.CreateNamespace
[3]    n.∆Buttons←''
[4]    n.∆Labels←n.⎕NS''
[5]    n.(∆V_Gap ∆H_Gap)←5 10
[6]    n.∆Posn←80 30
[7]    n.∆Size←600 800
[8]    n.InputFont←'InputFont'⎕WC'Font'('PName' 'APL385 Unicode')('Size' 17)
[9]   ⍝Done
     ∇
~~~

* It creates a reference `U` which is pointing to the namespace `GuiUtils`. Note that `U` is _not_ local in `Run`; that's because otherwise the test cases --- which we will eventually introduce --- would have a problem.

* It calls a method `CreateNamespace` in `GuiUtils` which returns a namespace which is assigned to `n`. 

  **Watch out:** it is this namespace that represents the GUI in the workspace. It will keep references to all controls and variables related to the GUI.

* It creates an empty global variable `∆Buttons` in `n` which we will use to collect references to all push buttons on the GUI when we create them.

* It creates an unnamed namespace in `n` which is assigned to `∆Labels`. We will use this to collect references to all labels on the GUI when we create them. 

  The reason is that we normally don't deal with the labels anymore after they got created, but occasionally we have to. Therefore we keep them separate from the more important ones. That way they are not disturbing us but are still available if must needs.

* It creates two global variables `∆V_Gap` and `∆H_Gap` in `n`. These are used for the vertical (`∆V_Gap`) and horizontal (`∆H_Gap`) distances between controls on our form.

* It defines two globals `∆Posn` and `∆Size` inside `n`; they will define the position and the size of the main form.

* It creates an instance of the font "APL385 Unicode" with an appropriate size.

* It has --- like most functions in this chapter  --- a comment line at the end that reads `⍝Done`. The simple purpose of this line is to prevent the Tracer from jumping to line 0 after having executed the very last line.

`GuiUtils` is an ordinary namespace that contains some functions. We will discuss them when we need them. 


### The function `GuiUtils.CreateNamespace`

`CreateNamespace` is used to create the namespace `n`:

~~~
     ∇ r←CreateNamespace                                                                                         
[1]    r←⎕NS''                                                                                                   
[2]    r.⎕FX'r←∆List' 'r←{⍵,[1.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2 9'                                                           
[3]   ⍝Done                                                                                                      
     ∇                                                                                                           
~~~

This function creates an unnamed namespace and populates it with a function `∆List` which returns a matrix with two columns:

| Column | Contains |
|-|-|
| [;1] |Name of a variable or reference |
| [;2] | The value of that name |


After running `Init` the `n` namespace does not contain (yet) any GUI controls but it does contains a couple of variables that will define certain properties of the GUI:

~~~
      n.∆List
 InputFont                         #._MyApp.MyApp.GUI.InputFont 
 ∆Buttons                                                       
 ∆H_Gap                                                      10 
 ∆Labels    #._MyApp.MyApp.GUI.GuiUtils.[Namespace].[Namespace] 
 ∆Posn                                                    80 30 
 ∆Size                                                  600 800 
 ∆V_Gap                                                       5 
~~~


### The function `GUI.CreateGUI`

This function calls all the functions that create controls. They all start their names with `Create`.

~~~
     ∇ n←CreateGUI n
[1]    n←CreateMainForm n
[2]    n←CreateSearch n
[3]    n←CreateStartLookingHere n
[4]    n.∆Groups←⎕NS''
[5]    n←CreateOptionsGroup n
[6]    n←CreateObjectTypesGroup n
[7]    n←CreateScanGroup n
[8]    n←CreateRegExGroup n
[9]    {⍵.Size←(⌈/1⊃¨⍵.Size),¨1+2⊃¨⍵.Size}'Group'⎕WN n.∆Form
[10]   n←CreateList n
[11]   n←CreatePushButtons n
[12]   n←CreateHiddenButtons n
[13]   n.HitList.Size[1]-←(2×n.∆V_Gap)+n.∆Form.Size[1]-n.Find.Posn[1]
[14]   n.(⍎¨↓⎕NL 9).onKeyPress←⊂'OnKeyPress'
[15]   n.∆WriteToStatusbar←n∘{⍺.Statusbar.StatusField1.Text←⍵ ⋄ 1:r←⍬}
[16]   n.∆Form.onConfigure←'OnConfigure'(335,CalculateMinWidth n)
[17]  ⍝Done
     ∇
~~~

Notes:

* There is an unnamed namespace created and assigned to `∆Groups` within `n`. We will create all groups within this sub namespace.

* The height of all groups is calculated dynamically in line [9]: it's defined by the size of the tallest group plus 1 pixel.

* The height of the "hit list" is calculated dynamically in line [13] so that it's fits onto the form.

* Line [14] assigns the callback `OnKeyPress` to all controls on the form.

* Line [15] defines dynamically a function `∆WriteToStatusbar` inside `n` with `n` glued to the function as left argument. 

  With this construct we _always_ have `n` as left argument at our disposal inside `∆WriteToStatusbar`.

* Line [16] assigns a callback `OnConfigure` to the "Configure" event. The callback gets a left argument which is a two-item vector with the constant 335 and a dynamically calculated value for the width.

  The value is only calculated once, for the assignment. This is a necessity because the number of "Configure" events can be overwhelming.

Because that callback is very important (without it any "Configure" event would cause a VALUE ERROR which in turn would make you lose your workspace because there are just too many of them) we introduce it straight away so we cannot forget it.


### The function `GUI.OnConfigure'

~~~
∇ OnConfigure←{⍵[1 2 3 4],(⍺[1]⌈⍵[5]),(⍺[2]⌈⍵[6])}       
∇                                                        
~~~

As already mentioned it is absolutely essential that this function is a one-liner because that makes the Tracer ignore this function.


### All the `GUI.Create*` functions

Although we list all functions here you might not necessarily follow us on each of them in detail, but you should at least keep reading until you reach `GUI.AdjustGroupSize`.

However, we suggest to scan through them rather than skipping them and carrying on with [The callback functions](#).


#### The function `CreateMainForm`

~~~
     ∇ n←CreateMainForm n;∆
[1]    ∆←⊂'Form'
[2]    ∆,←⊂'Coord' 'Pixel'
[3]    ∆,←⊂'Caption' 'MyApp'
[4]    ∆,←⊂'Posn'n.∆Posn
[5]    ∆,←⊂'Size'n.∆Size
[6]    n.∆Form←⍎'Form'⎕WC ∆
[7]    n.∆Form.n←n
[8]    n←CreateMenubar n
[9]    n←CreateStatusbar n
[10]  ⍝Done
     ∇
~~~

There is one statement we need to discuss: line [7] assigns `n` to `n.∆Form.n` -- what for?

This allows us to find `n` with ease: we know that there is always a reference to `n` available inside the main form. When we introduce the callback functions we will need `n` is almost all of them, and this will make is easy for them to find it.


##### Collecting properties

Note that the function collects properties which are assigned to a local variable `∆`; we don't attempt to give it a proper name because we use it just for collecting stuff.

Why are we not assigning the properties in one go? Something like this:

~~~
n.∆Form←⍎'Form'⎕WC 'Form'('Coord' 'Pixel')('Caption' 'MyApp')('Posn'∆Posn)('Size'∆Size)
~~~

Haven't we agreed that shorter programs are better? We did, but there are exceptions. 

Apart from being way more readable, having just one property on a line has the big advantage of allowing us to skip the line in the Tracer if we wish so. That is particularly pleasant when we don't want something to be executed like `('Visible' 0)` or `('Active' 0)`. If they are part of a lengthy line, well, you get the idea.


##### Collecting controls

We are not using a designer for creating the GUI, we use APL code. Whenever possible we calculate "Posn" and "Size" dynamically, otherwise we assign constants.

The name we use as left argument of `⎕WC` is also used within `n` when we assign the reference that is created with the `⍎` primitive on the (shy) result of `⎕WC`. That's what a statement like this does:

~~~
      n.∆Form←⍎'Form'⎕WC ∆
~~~

`CreateMainForm` calls two functions which we introduce next.


#### The function `GUI.CreateMenubar`

~~~
     ∇ n←CreateMenubar n;TAB;∆
[1]    TAB←⎕UCS 9
[2]    n.∆Menubar←⍎'∆Menubar'n.∆Form.⎕WC⊂'Menubar'
[3]    n.∆Menubar.FileMenu←⍎'FileMenu'n.∆Menubar.⎕WC'Menu'('Caption' '&File')
[4]    ∆←⊂'MenuItem'
[5]    ∆,←⊂'Caption'('Quit',TAB,'Escape')
[6]    ∆,←⊂'Accelerator'(27 0)
[7]    n.∆Menubar.Quit←⍎'Quit'n.∆Menubar.FileMenu.⎕WC ∆
[8]    n.∆Menubar.Quit.onSelect←1
[9]   ⍝Done
     ∇
~~~

Note that we assign the result of `⍎'∆Menubar'n.∆Form.⎕WC⊂'Menubar'` (which is actually _the_ menubar on our form) to `∆Menubar` rather than `Menubar` as you might have expected. 

The reason is that we do not assign the "Menu" and "MenuItem" and "Separator" objects to `n` but to the menubar itself; because it's a static menu we don't want matters to be blurred, so we keep them separate, similar to the labels.


#### The function `GUI.CreateStatusbar`

~~~
     ∇ n←CreateStatusbar n;∆
[1]    n.Statusbar←⍎'Statusbar'n.∆Form.⎕WC⊂'Statusbar'
[2]    ∆←⊂'StatusField'
[3]    ∆,←⊂'Coord' 'Prop'
[4]    ∆,←⊂'Posn'(0 0)
[5]    ∆,←⊂'Size'(⍬ 100)
[6]    ∆,←⊂'Attach'('Bottom' 'Left' 'Bottom' 'Right')
[7]    n.StatusField1←⍎'StatusField1'n.Statusbar.⎕WC ∆
[8]   ⍝Done
     ∇
~~~


#### The function `GUI.CreateSearch`

~~~
     ∇ n←CreateSearch n;∆
[1]    ∆←⊂'Label'
[2]    ∆,←⊂'Posn'n.(∆V_Gap ∆H_Gap)
[3]    ∆,←⊂'Caption' '&Search for:'
[4]    ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Left')
[5]    n.∆Labels.SearchFor←⍎'SearchFor'n.∆Form.⎕WC ∆
[6]
[7]    ∆←⊂'Edit'
[8]    ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.∆Labels.SearchFor)n.∆H_Gap)
[9]    ∆,←⊂'Size'(⍬(n.∆Form.Size[2]-2×n.∆H_Gap))
[10]   ∆,←⊂'FontObj'n.InputFont
[11]   ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Right')
[12]   n.SearchFor←⍎'SearchFor'n.∆Form.⎕WC ∆
[13]  ⍝Done
     ∇
~~~

This function creates the label "Search for" and the associated edit field.

Notes:

* The position of the label on the form is defined by the global variables `n.∆V_Gap` and `n.∆H_Gap`.

* Note that the reference for the label is assigned to the sub namespace `∆Labels` within `n` as discussed earlier.

* The position of the Edit control is calculated dynamically from the position and size of the label by the function `GuiUtils.AddPosnAndSize` which we therefore need to introduce.


#### The function `GuiUtils.AddPosnAndSize`

~~~
     ∇ AddPosnAndSize←{                                            
[1]        +⌿↑⍵.(Posn Size)                                        
[2]    }                                                           
     ∇                                                             
~~~

Not much code, but very helpful and used over and over again, therefore it makes sense to make it a function.

It just makes "Posn" and "Size" a matrix and sums up the rows. That is exactly what we need for positioning the Edit control vertically. Its horizontal position  is of course defined by `n.∆H_Gap`.


#### The function `GUI.CreateStartLookingHere`

~~~
 n←CreateStartLookingHere n;∆
 ∆←⊂'Label'
 ∆,←⊂'Posn'((n.∆V_Gap+⊃U.AddPosnAndSize n.SearchFor)n.∆H_Gap)
 ∆,←⊂'Caption' 'Start &looking here:'
 ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Left')
 n.∆Labels.StartLookingHere←⍎'StartLookingHere'n.∆Form.⎕WC ∆

 ∆←⊂'Edit'
 ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.∆Labels.StartLookingHere)n.∆H_Gap)
 ∆,←⊂'Size'(⍬(n.∆Form.Size[2]-2×n.∆H_Gap))
 ∆,←⊂'FontObj'n.InputFont
 ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Right')
 n.StartLookingHere←⍎'StartLookingHere'n.∆Form.⎕WC ∆
⍝Done
~~~

Note that this time the vertical position of the Label is defined by the total of the "Posn" and "Size" of the "Search for" Edit control plus `n.∆V_Gap`.


#### The function `GUI.CreateOptionsGroup`

~~~
     ∇ n←CreateOptionsGroup n;∆
[1]    ∆←⊂'Group'
[2]    ∆,←⊂'Caption' 'Options'
[3]    ∆,←⊂'Posn'((n.∆V_Gap+⊃U.AddPosnAndSize n.StartLookingHere),n.∆H_Gap)
[4]    ∆,←⊂'Size'(300 400)
[5]    ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Left')
[6]    n.∆Groups.OptionsGroup←⍎'OptionsGroup'n.∆Form.⎕WC ∆
[7]
[8]    ∆←⊂'Button'
[9]    ∆,←⊂'Style' 'Check'
[10]   ∆,←⊂'Posn'(3 1×n.(∆V_Gap ∆H_Gap))
[11]   ∆,←⊂'Caption' '&Match case'
[12]   n.MatchCase←⍎'MatchCase'n.∆Groups.OptionsGroup.⎕WC ∆
[13]
[14]   ∆←⊂'Button'
[15]   ∆,←⊂'Style' 'Check'
[16]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.MatchCase),n.∆H_Gap)
[17]   ∆,←⊂'Caption' 'Match &APL name'
[18]   n.MatchAPLname←⍎'MatchAPLname'n.∆Groups.OptionsGroup.⎕WC ∆
[19]
[20]   AdjustGroupSize n.∆Groups.OptionsGroup
[21]  ⍝Done
     ∇
~~~

The group as such is assigned to `OptionsGroup` inside `n.∆Groups` as discussed earlier.

The function calls `AdjustGroupSize` which we therefore need to introduce.


#### The function `GUI.AdjustGroupSize`

~~~
     ∇ AdjustGroupSize←{
[1]    ⍝ Ensures that the group is just big enough to host all its children
[2]        ⍵.Size←n.(∆H_Gap ∆V_Gap)+⊃⌈/{+⌿↑⍵.(Posn Size)}¨⎕WN ⍵
[3]        1:r←⍬
[4]    }
     ∇
~~~

The comment in line [1] tells it all.

Note that the system function `⎕WN` gets a reference as right argument rather than a name; that's important because in that case `⎕WN` returns references as well.


#### The function `GUI.CreateObjectTypesGroup`

~~~
     ∇ n←CreateObjectTypesGroup n;∆
[1]    ∆←⊂'Group'
[2]    ∆,←⊂'Caption' 'Object &types'
[3]    ∆,←⊂'Posn'({⍵.Posn[1],(2×n.∆V_Gap)+2⊃U.AddPosnAndSize ⍵}n.∆Groups.OptionsGroup)
[4]    ∆,←⊂'Size'(300 400)
[5]    ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Left')
[6]    n.∆Groups.ObjectTypes←⍎'ObjectTypes'n.∆Form.⎕WC ∆
[7]
[8]    ∆←⊂'Button'
[9]    ∆,←⊂'Style' 'Check'
[10]   ∆,←⊂'Posn'(3 1×n.(∆V_Gap ∆H_Gap))
[11]   ∆,←⊂'Caption' 'Fns, opr and scripts'
[12]   n.FnsOprScripts←⍎'FnsOprScripts'n.∆Groups.ObjectTypes.⎕WC ∆
[13]
[14]   ∆←⊂'Button'
[15]   ∆,←⊂'Style' 'Check'
[16]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.FnsOprScripts),n.∆H_Gap)
[17]   ∆,←⊂'Caption' 'Variables'
[18]   n.Variables←⍎'Variables'n.∆Groups.ObjectTypes.⎕WC ∆
[19]
[20]   ∆←⊂'Button'
[21]   ∆,←⊂'Style' 'Check'
[22]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.Variables),n.∆H_Gap)
[23]   ∆,←⊂'Caption' 'Name list &only (⎕NL)'
[24]   n.NameList←⍎'NameList'n.∆Groups.ObjectTypes.⎕WC ∆
[25]
[26]   AdjustGroupSize n.∆Groups.ObjectTypes
[27]  ⍝Done
     ∇
~~~


#### The function `GUI.CreateScanGroup`

~~~
      ∇ n←CreateScanGroup n;∆
[1]    ∆←⊂'Group'
[2]    ∆,←⊂'Caption' 'Scan... '
[3]    ∆,←⊂'Posn'({⍵.Posn[1],(2×n.∆V_Gap)+2⊃U.AddPosnAndSize ⍵}n.∆Groups.ObjectTypes)
[4]    ∆,←⊂'Size'(300 400)
[5]    ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Left')
[6]    n.∆Groups.ScanGroup←⍎'ScanGroup'n.∆Form.⎕WC ∆
[7]
[8]    ∆←⊂'Button'
[9]    ∆,←⊂'Style' 'Check'
[10]   ∆,←⊂'Posn'(3 1×n.(∆V_Gap ∆H_Gap))
[11]   ∆,←⊂'Caption' 'APL'
[12]   n.APL←⍎'APL'n.∆Groups.ScanGroup.⎕WC ∆
[13]
[14]   ∆←⊂'Button'
[15]   ∆,←⊂'Style' 'Check'
[16]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.APL),n.∆H_Gap)
[17]   ∆,←⊂'Caption' 'Comments'
[18]   n.Comments←⍎'Comments'n.∆Groups.ScanGroup.⎕WC ∆
[19]
[20]   ∆←⊂'Button'
[21]   ∆,←⊂'Style' 'Check'
[22]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.Comments),n.∆H_Gap)
[23]   ∆,←⊂'Caption' 'Text'
[24]   n.Text←⍎'Text'n.∆Groups.ScanGroup.⎕WC ∆
[25]
[26]   AdjustGroupSize n.∆Groups.ScanGroup
[27]  ⍝Done
     ∇
~~~


#### The function `GUI.CreateRegExGroup`

~~~
     ∇ n←CreateRegExGroup n;∆
[1]    ∆←⊂'Group'
[2]    ∆,←⊂'Caption' 'RegEx'
[3]    ∆,←⊂'Posn'({⍵.Posn[1],n.∆V_Gap+2⊃U.AddPosnAndSize ⍵}n.∆Groups.ScanGroup)
[4]    ∆,←⊂'Size'(300 400)
[5]    ∆,←⊂'Attach'('Top' 'Left' 'Top' 'Left')
[6]    n.∆RegEx←⍎'ObjectTypes'n.∆Form.⎕WC ∆
[7]
[8]    ∆←⊂'Button'
[9]    ∆,←⊂'Style' 'Check'
[10]   ∆,←⊂'Posn'(2 1×n.(∆V_Gap ∆H_Gap))
[11]   ∆,←⊂'Caption' 'Is RegE&x'
[12]   n.IsRegEx←⍎'IsRegEx'n.∆RegEx.⎕WC ∆
[13]   n.IsRegEx.onSelect←'OnToggleIsRegEx'
[14]
[15]   ∆←⊂'Button'
[16]   ∆,←⊂'Style' 'Check'
[17]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.IsRegEx),4×n.∆H_Gap)
[18]   ∆,←⊂'Caption' 'Dot&All'
[19]   n.DotAll←⍎'DotAll'n.∆RegEx.⎕WC ∆
[20]
[21]   ∆←⊂'Button'
[22]   ∆,←⊂'Style' 'Check'
[23]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.DotAll),4×n.∆H_Gap)
[24]   ∆,←⊂'Caption' '&Greedy'
[25]   n.Greedy←⍎'Greedy'n.∆RegEx.⎕WC ∆
[26]
[27]   AdjustGroupSize n.∆RegEx
[28]  ⍝Done
     ∇
~~~

This function makes sure that both "DotAll" and "Greedy" are indented in order to emphasize that they are available only in case the "Is RegEx" check box is ticked.

The callback `OnToggleRegEx` will toggle the "Active" property of these two check boxes accordingly.


#### The function `GUI.CreateList`

~~~
     ∇ n←CreateList n;∆;h
[1]    ∆←⊂'ListView'
[2]    h←⊃n.∆V_Gap+U.AddPosnAndSize n.MatchCase.##
[3]    ∆,←⊂'Posn'(h,n.∆H_Gap)
[4]    ∆,←⊂'Size'((n.∆Form.Size[1]-h),n.∆Form.Size[2]-n.∆H_Gap×2)
[5]    ∆,←⊂'ColTitles'('Name' 'Location' 'Type' '⎕NS' 'Hits')
[6]    ∆,←⊂'Attach'('Top' 'Left' 'Bottom' 'Right')
[7]    n.HitList←⍎'HitList'n.∆Form.⎕WC ∆
[8]   ⍝Done
     ∇
~~~


#### The function `GUI.CreatePushButtons`

~~~
     ∇ n←CreatePushButtons n;∆
[1]    n.∆Buttons←''
[2]    ∆←⊂'Button'
[3]    ∆,←⊂'Caption' 'Find'
[4]    ∆,←⊂'Size'(⍬ 120)
[5]    ∆,←⊂'Default' 1
[6]    ∆,←⊂'Attach'(4⍴'Bottom' 'Left')
[7]    n.∆Buttons,←n.Find←⍎'Find'n.∆Form.⎕WC ∆
[8]    n.Find.Posn←(n.∆Form.Size[1]-n.Find.Size[1]+n.Statusbar.Size[1]+n.∆V_Gap),n.∆V_Gap
[9]    n.Find.onSelect←'OnFind'
[10]
[11]   ∆←⊂'Button'
[12]   ∆,←⊂'Caption' 'Replace'
[13]   ∆,←⊂'Size'(⍬ 120)
[14]   ∆,←⊂'Active' 0
[15]   ∆,←⊂'Attach'(4⍴'Bottom' 'Left')
[16]   n.∆Buttons,←n.Replace←⍎'Replace'n.∆Form.⎕WC ∆
[17]   n.Replace.Posn←(n.Find.Posn[1]),n.∆V_Gap+2⊃U.AddPosnAndSize n.Find
[18]  ⍝Done
     ∇
~~~

Note that the "Find" button gets a callback `OnFind` assigned to the "Select" event. That's the real work horse.

A> # On callbacks
A>
A> Rather than doing all the hard work in the callback we could have assigned a 1 to `n.Find.onSelect` (so that clicking the button quits `⎕DQ` or `Wait`) and doing the hard work after that. At first glance there seems to be little difference between the two approaches.
A>
A> However, if you want to test your GUI automatically then you _must_ execute the "business logic" in a callback and avoid calling `⎕DQ` or `Wait` altogether.
A> 
A> That's the reason why our `Run` function expects a Boolean right argument, and that it's named `testFlag`. If it's a `1` then MyApp is running in test mode, and neither `U.DQ` nor `Shutdown` --- which would close down the GUI --- are executed. 
A>
A> That allows us in test mode to...
A> 1. call `Run`
A> 1. populate the "Search for" and "Start looking here" fields
A> 1. "click" the "Find" button programmatically
A> 1. check the contents of `n.HitList`


#### The function `GUI.CreateHiddenButtons`

~~~
     ∇ n←CreateHiddenButtons n;∆
[1]    ∆←⊂'Button'
[2]    ∆,←⊂'Caption' 'Resize (F12)'
[3]    ∆,←⊂'Size'(0 0)
[4]    ∆,←⊂'Posn'(¯5 ¯5)
[5]    ∆,←⊂'Attach'(4⍴'Top' 'Left')
[6]    ∆,←⊂'Accelerator'(123 0)
[7]    n.Resize←⍎'Resize'n.∆Form.⎕WC ∆
[8]    n.Resize.onSelect←'OnResize'
[9]   ⍝Done
     ∇
~~~

Note that this button has no size (`(0 0)`) and is positioned _outside_ the GUI. That means it is invisible to the user, and she cannot click it as a result of that. So what's the purpose of such a button?

Well, it has an accelerator key attached to it which, assuming that the caption is not lying, will be F12. This is an easy and straightforward way to implement a PF-key without overloading any "onKeyPress" callback.

It also makes it easy to disable F12: just execute `n.Resize.Active←0`.


### The function `GuiUtils.GetRef2n`

We introduce this function here because almost all callbacks --- which we will introduce next --- will call `GetRef2n`. 

Earlier on we saw that a reference to `n` was assigned to `n.∆form.n`. Now all callbacks, by definition, get a reference pointing to the control the callback is associated with as the first element of its right argument. 

We also know that the control is owned by the main form, either directly, like "Search for", or indirectly like the "DotAll" checkbox which is owned by the "RegEx" group which in turn is owned by the main form.

That means that in order to find `n` we just need to check whether it exists at the current level. If not we go up one level (with `.##`) and try again.

`GetRef2n` is doing just that with a recursive call to itself until it finds `n`:

~~~
     ∇ GetRef2n←{                                                                                                               
[1]        9=⍵.⎕NC'n':⍵.n                                                                                                       
[2]        ⍵≡⍵.##:''           ⍝ Can happen in context menus, for example                                                       
[3]        ∇ ⍵.##                                                                                                               
[4]    }                                                                                                                        
     ∇
~~~

Of course this means that you should not use the name `n` --- or whatever name _you_ prefer instead for this namespace --- anywhere in the hierarchy.

Note that line [2] is an insurance against `GetRef2n` being called inside a callback that is associated with a control that is _not_ owned by the main form. Of course that should not happen because it makes no sense, but if you do it anyway by accident then the function would call itself recursively forever without that line.


### The callback functions


#### The function `GUI.OnKeyPress`

~~~
      ∇ OnKeyPress←{
[1]        (obj key)←⍵[1 3]
[2]        n←U.GetRef2n obj
[3]        _←n.∆WriteToStatusbar''
[4]        'EP'≢key:1                ⍝ Not Escape? Done!
[5]        _←2 ⎕NQ n.∆Form'Close'    ⍝ Close the main form...
[6]        0                         ⍝ ... and suppress the <esacape> key.
[7]    }
     ∇
~~~

This function just handles the <escape> key.


#### The function `GUI.OnToggleIsRegEx`

~~~
     ∇ OnToggleIsRegEx←{
[1]        n←U.GetRef2n⊃⍵
[2]        n.(DotAll Greedy).Active←~n.IsRegEx.State
[3]        ⍬
[4]    }                       
     ∇
~~~

This callback toggles the "Active" property of both "DotAll" and "Greedy" so that they are active only when the content of "Search for" is to be interpreted as a regular expression.


#### The function `GUI.OnResize`

~~~
      ∇ OnResize←{
[1]        n←⎕NS''
[2]        list←CollectControls(⊃⍵).##
[3]        n.∆Form←(⊃⍵).##
[4]        width←CalculateMinWidth n.∆Form.n
[5]        ⎕NQ n.∆Form,(⊂'Configure'),n.∆Form.Posn,(n.∆Form.Size[1]),width
[6]    }
     ∇
~~~

This function makes sure that the width of the GUI is reduced to the minimum required to display all groups properly.


#### The function `GUI.OnFind`

~~~
     ∇ r←OnFind msg;n
[1]    r←0
[2]    n←U.GetRef2n⊃msg
[3]    n.∆WriteToStatusbar''
[4]    :If 0∊⍴n.SearchFor.Text
[5]        Dialogs.ShowMsg n'"Search for" is empty - nothing to look for...'
[6]    :ElseIf 0∊⍴n.StartLookingHere.Text
[7]        Dialogs.ShowMsg n'"Start looking here" is empty?!'
[8]    :ElseIf 9≠⎕NC n.StartLookingHere.Text
[9]    :AndIf (,'#')≢,n.StartLookingHere.Text
[10]       Dialogs.ShowMsg n'Contents of "Start looking here" is not a namespace'
[11]   :Else
[12]       Find n
[13]   :EndIf
[14]  ⍝Done
     ∇
~~~~

The callback performs some checks and either puts an error message on display by calling a function `Dialogs.ShowMsg` or executes the `Find` function, providing `n` as the right argument.

Note that `Dialog.ShowMsg` follows exactly the same principles we have outlines in this chapter, so we do not discuss it in detail, but you can download the code and look at it if you want to.

One thing should be pointed out however: the Form created by `Dialog.ShowMsg` is actually a child of our main form. 

That gets us around a nasty problem: when it's not a child of the main form and you give the focus to another application which then hides completely the Form created by `Dialog.ShowMsg` but not all of the main form then a click on the main form should bring the application to the front, with the focus on `Dialogs.ShowMsg`, but that's not going to happen in an application written in Dyalog APL.

By making it a child of the main form we enforce this behaviour. We don't want the user believe that the application has stopped working just because the form is hidden by another application window.


### The function `GUI.Find`

This is the real work horse:

~~~
     ∇ Find←{
[1]        n←⍵
[2]        G←CollectData n
[3]        was←n.∆Buttons.Active
[4]        n.∆Buttons.Active←0
[5]        _←n.∆WriteToStatusbar'Searching...'
[6]        n.∆Result←(noOfHits noOfObjects cpuTime)←##.BusinessLogic.Find G
[7]        n.∆Buttons.Active←was
[8]        txt←(⍕noOfHits),' hits in ',(⍕noOfObjects),' objects. Search time ',(⍕cpuTime),' seconds.'
[9]        _←n.∆WriteToStatusbar txt
[10]       1:r←⍬
[11]   }
     ∇
~~~

An important thing to discuss is the function `CollectData`. We want our "business logic" to be independent from the GUI. Therefore we don't want anything inside `##.BusinessLogic` access the `n` namespace. 

But it needs access to the data entered and decisions made by the user on the GUI. Therefore we collect all the data and assign them to variables inside a newly created unnamed namespace which we assign to `G`.


### The function `GUI.CollectData`

~~~
     ∇ CollectData←{
[1]        n←⍵
[2]        G←⎕NS''
[3]        _←G.⎕FX'r←∆List' 'r←{⍵,[1.5]⍎¨⍵}'' ''~¨⍨↓⎕NL 2'
[4]        G.APL←n.APL.State
[5]        G.Comments←n.Comments.State
[6]        G.DotAll←n.DotAll.State
[7]        G.FnsOprScripts←n.FnsOprScripts.State
[8]        G.Greedy←n.Greedy.State
[9]        G.IsRegEx←n.Greedy.State
[10]       G.MatchAPLname←n.MatchAPLname.State
[11]       G.MatchCase←n.MatchCase.State
[12]       G.NameList←n.NameList.State
[13]       G.SearchFor←n.SearchFor.Text
[14]       G.StartLookingHere←n.StartLookingHere.Text
[15]       G.Text←n.Text.State
[16]       G.Variables←n.Variables.State
[17]       G
[18]   }
     ∇
~~~

This namespace (`G`) is passed as the only argument to the `Find` function.

Imagine that you replace the Windows native GUI by an HTML5/JavaScript GUI. All you have to do is to make sure that the `G` namespace is fed with all the data needed. `##.BusinessLogic` will not be affected in any way.

### The function `##.BusinessLogic.Find`

Of course nothing is really happening in `##.BusinessLogic.Find`, we just mock something up:

~~~
     ∇ (noOfHits noOfObjects cpuTime)←Find G;was
[1]   ⍝ Here's where all the searching takes place.
[2]   ⍝ `G` is a namespace that contains all the relevant GUI control settings (check boxes 
[3]   ⍝ and text fields) as ordinary field. It's the interface between GUI and application.
[4]    ⎕DL 3
[5]    noOfHits←123
[6]    noOfObjects←645
[7]    cpuTime←2.3
     ∇
~~~


### The function `GUI.CalculateMinWidth`

~~~
     ∇ CalculateMinWidth←{
[1]        n←⍵
[2]        ignore←'HitList' 'SearchFor' 'StartLookingHere' 'Statusbar' 'StatusField1' '∆Form'
[3]        list2←n.{⍎¨(' '~¨⍨↓⎕NL 9)~⍵}ignore
[4]        (2×n.∆V_Gap)+⌈/{0::0 0 ⋄ 2⊃+⌿↑⍵.(Posn Size)}¨list2
[5]    }
     ∇
~~~

The function calculates the minimum width needed by the form to be presentable. It takes all controls owned by the form into account except those listed on `ignore`.


### The function `GUI.CollectControls`

~~~
     ∇ CollectControls←{                                                                
[1]        0∊⍴l←⎕WN ⍵:⍬                                                                 
[2]        l,(⊃,/∇¨l)~⍬                                                                 
[3]    }                                                                                
     ∇
~~~

It collects all controls found in `⍵` and then calls itself on them until nothing is found anymore.


### The function `GUI.DQ`

~~~
     ∇ {r}←{focus}DQ ref                                                                                                 
[1]    focus←{0<⎕NC ⍵:⍎⍵ ⋄ ref}'focus'                                                                                   
[2]    ⎕NQ focus'GotFocus' ⋄ r←⎕DQ ref                                                                                   
[3]   ⍝Done                                                                                                              
     ∇                                                                                                                   
~~~

The function accepts an optional left argument which, when specified, must be a reference pointing to a control. The function then  forces the focus onto that control before executing `⎕DQ` on the right argument, usually the main form.

We put this into a separate function so that we can at any time interrupt the function, investigate variables or change functions and then carry on by executing `→1`.


### The function `GUI.Shutdown`

~~~
     ∇ {r}←Shutdown n                                                                   
[1]    r←⍬                                                                              
[2]    :Trap 6 ⋄ 2 ⎕NQ n.∆Form'Close' ⋄ :EndTrap                                        
     ∇
~~~

This function makes sure that the main form is closed in case it still exists.

Note that we need the trap. Even checking the main form with `⎕NS` might fail in case the user clicks the close box right after the check has been performed but before the next line is executed.

This would produce one of these nasty crashes that occur only every odd year and are not reproducible. This is one of the rare cases where a trap is better than any check.


## Changing the GUI

In order to demonstrate the power of the outlined approach we have to prove that it is easy to change.

Let's assume the following:

1. We have a user who is unhappy with the arrangement of the controls on the GUI. On her monstrous 5k monitor it looks indeed at bit clumsy.

2. She also wants the groups to be arranged in two rows, with "Options" and "RegEx" in the first row and "Object types" and "Scan..." in the second row.

How much work is required to make these changes?

First we double the vertical and horizontal distance between the controls on the main form:

~~~
     ∇ n←Init dummy
...
[4]    n.∆Labels←n.⎕NS''
leanpub-start-insert
[5]    n.(∆V_Gap ∆H_Gap)←10 20
leanpub-end-insert
[6]    n.∆Posn←80 30
...
     ∇
~~~

Then we change the sequence in which the groups are created:

~~~
leanpub-start-insert
     ∇ n←CreateGUI n;groups
leanpub-end-insert
[1]    n←CreateMainForm n
[2]    n←CreateSearch n
[3]    n←CreateStartLookingHere n
[4]    n.∆Groups←⎕NS''
leanpub-start-insert
[5]    n←CreateOptionsGroup n
[6]    n←CreateRegExGroup n
[7]    groups←'Group'⎕WN n.∆Form
[8]    {⍵.Size←(⌈/1⊃¨⍵.Size),¨1+2⊃¨⍵.Size}groups
[9]    n←CreateObjectTypesGroup n
[10]   n←CreateScanGroup n
[11]   {⍵.Size←(⌈/1⊃¨⍵.Size),¨1+2⊃¨⍵.Size}('Group'⎕WN n.∆Form)~groups
leanpub-end-insert
[12]   n←CreateList n
[13]   n←CreatePushButtons n
[14]   n←CreateHiddenButtons n
[15]   n.HitList.Size[1]-←(2×n.∆V_Gap)+n.∆Form.Size[1]-n.Find.Posn[1]
[16]   n.(⍎¨↓⎕NL 9).onKeyPress←⊂'OnKeyPress'
[17]   n.∆WriteToStatusbar←n∘{⍺.Statusbar.StatusField1.Text←⍵ ⋄ 1:r←⍬}
[18]   n.∆Form.onConfigure←'OnConfigure'(335,CalculateMinWidth n)
[19]  ⍝Done
     ∇
~~~

We need to calculate the height of the groups here twice: once in line [8], after having created the first two groups and then again in line [11] on all groups but the first two. For that we save the references of the first two on `groups` and exclude them in line 11.

We then tell the RegEx group where it should go, and we make sure that the position of the "DotAll" and the "Greedy" check boxes are corrected:

~~~
     ∇ n←CreateRegExGroup n;∆
[1]    ∆←⊂'Group'
[2]    ∆,←⊂'Caption' 'RegEx'
leanpub-start-insert
[3]   ⍝∆,←⊂'Posn'({⍵.Posn[1],(2×n.∆V_Gap)+2⊃U.AddPosnAndSize ⍵}n.∆Groups.ScanGroup)
[4]    ∆,←⊂'Posn'({⍵.Posn[1],(2×n.∆V_Gap)+2⊃U.AddPosnAndSize ⍵}n.∆Groups.OptionsGroup)
leanpub-end-insert
[5]    ∆,←⊂'Size'(300 400)
...
[16]   ∆←⊂'Button'
[17]   ∆,←⊂'Style' 'Check'
leanpub-start-insert
[18]  ⍝∆,←⊂'Posn'((⊃U.AddPosnAndSize n.IsRegEx),4×n.∆H_Gap)
[19]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.IsRegEx),2×n.∆H_Gap)
leanpub-end-insert
[20]   ∆,←⊂'Caption' 'Dot&All'
...
[24]   ∆,←⊂'Style' 'Check'
leanpub-start-insert
[25]  ⍝∆,←⊂'Posn'((⊃U.AddPosnAndSize n.DotAll),4×n.∆H_Gap)
[26]   ∆,←⊂'Posn'((⊃U.AddPosnAndSize n.DotAll),2×n.∆H_Gap)
leanpub-end-insert
[27]   ∆,←⊂'Caption' '&Greedy'
...
     ∇
~~~

We keep  the old version to make a comparison easy.

W> # Keeping old versions of lines
W>
W> We _do not_ generally advocate the technique used here. We only do this for demonstrating purposes.
W> 
W> In a real-world scenario rather than cluttering the code it should be left to a source code management system and proper comparison tools to solve such problems.

For `CreateObjectTypesGroup` we just need to change the "Posn" property:

~~~
     ∇ n←CreateObjectTypesGroup n;∆
[1]    ∆←⊂'Group'
[2]    ∆,←⊂'Caption' 'Object &types'
leanpub-start-insert
[3]   ⍝∆,←⊂'Posn'({⍵.Posn[1],(2×n.∆V_Gap)+2⊃U.AddPosnAndSize ⍵}n.∆Groups.OptionsGroup)
[4]    ∆,←⊂'Posn'((n.∆V_Gap+1⊃U.AddPosnAndSize n.∆Groups.OptionsGroup),n.∆H_Gap)
leanpub-end-insert
[5]    ∆,←⊂'Size'(300 400)
...
     ∇
~~~

The last group-related function, `CreateScanGroup`, does not change at all because it still makes itself a neighbour of `CreateObjectTypesGroup`.

Since we now have significant less space available for the `HitList` we need to change `CreateList` as well:

~~~
     ∇ n←CreateList n;∆;h
[1]    ∆←⊂'ListView'
leanpub-start-insert
[2]   ⍝h←⊃n.∆V_Gap+U.AddPosnAndSize n.MatchCase.##
[3]    h←⊃n.∆V_Gap+U.AddPosnAndSize n.FnsOprScripts.##
leanpub-end-insert
[4]    ∆,←⊂'Posn'(h,n.∆H_Gap)
...
     ∇
~~~

And that was it.


## Testing


### Prerequisites{#2}

For implementing tests execute the following steps:

1. Create a namespace with 

   ~~~
   'TestCases'#._Meddy.⎕ns''
   ~~~

2. Load the script `APLTreeUtils` and the class `Testers` into `#` as discusses in the chapter regarding [tests](./08 Testing — the sound of breaking glass.html) chapter.

3. Execute these statements:

   ~~~
   )cs #._MyApp.TestCases
   #.Tester.EstablishHelpersIn ⍬
   ~~~


### Testing "Find"

 Edit `#._MyApp.TestCases.Test_000` and make it look like this:

~~~
     ∇ R←Test_01(stopFlag batchFlag);⎕TRAP;n
[1]   ⍝ Test that the GUI comes up and the "Find" works well
[2]    ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
[3]    R←∆Failed
[4]
[5]    n←##.MyApp.GUI.Run 1
[6]    n.SearchFor.Text←'⎕IO'
[7]    n.StartLookingHere.Text←'#'
[8]    1 ⎕NQ n.Find'Select'
[9]    →GoToTidyUp 123 645 2.3≢n.∆Result
[10]   R←∆OK
[11]
[12]  ∆TidyUp:
[13]   1 ⎕NQ n.∆Form'Close'
     ∇
~~~

Of course this is not how a real test would look like (line [9]) but it emphasizes the principles.

Note that `n.∆Result` was set in the `GUI.Find` function.

Note that after having executed `Init` there is a global reference `GUI.U` around that points to the namespace GUI.GuiUtils; that's necessary because otherwise later calls might well fail with a VALUE ERROR when `GUI.U` is not available.

That's not a problem because we don't save the workspace, we re-compile it from scratch whenever we start a development session.


### Testing the business logic

Take a copy of the first test and make it look like this:

~~~
     ∇ R←Test_02(stopFlag batchFlag);⎕TRAP;n;G
[1]   ⍝ Test the business logic
[2]    ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
[3]    R←∆Failed
[4]
[5]    n←##.MyApp.GUI.Run 1
[6]    n.SearchFor.Text←'⎕IO'
[7]    n.StartLookingHere.Text←'#'
[8]    G←##.MyApp.GUI.CollectData n
[9]    →GoToTidyUp 123 645 2.3≢##.MyApp.BusinessLogic.Find G
[10]   R←∆OK
[11]
[12]  ∆TidyUp:
[13]   1 ⎕NQ n.∆Form'Close'
     ∇
~~~


### Test missing "Search For"

Take a copy of the first test and make it look like this:

~~~
     ∇ R←Test_03(stopFlag batchFlag);⎕TRAP;n
[1]   ⍝ Test whether an empty "Search for" field leads to an error message.
[2]    ⎕TRAP←(999 'C' '. ⍝ Deliberate error')(0 'N')
[3]    R←∆Failed
[4]
[5]    n←##.MyApp.GUI.Run 1
[6]    n.StartLookingHere.Text←'#'
[7]    1 ⎕NQ n.Find'Select'
[8]    →GoToTidyUp 0=n.⎕NC'∆ErrorMsg'
[9]    →GoToTidyUp'"Search for" is empty - nothing to look for...'≢n.∆ErrorMsg
[10]   R←∆OK
[11]
[12]  ∆TidyUp:
[13]   1 ⎕NQ n.∆Form'Close'
     ∇
~~~

This works because when `testFlag` -- the right argument of `GUI.Run` --- is 1 then the function `Dialog.ShowMsg` does nothing but set a global variable `n.∆ErrorMsg` which we use in the test case in order to check whether our actions triggered the correct behaviour.

We have eariler stated that we won't discuss `Dialogs.ShowMsg` in details but we list it here because the function illustrates an important concept of how GUIs can be tested at all:

~~~
     ∇ {r}←{caption}ShowMsg(n msg);n2;U
[1]   ⍝ Takes `n` and a message to be displayed as mandatory right arguments.
[2]   ⍝ Takes an optional `caption` as left argument.
[3]   ⍝ Returns 1 when running under test conditions and 0 otherwise.
[4]   ⍝ In test mode no GUI is created at all but a global `n.∆ErrorMsg` is set to `msg`.
[5]    r←0
[6]    caption←{0<⎕NC ⍵:⍎⍵ ⋄ 'Attention!'}'caption'
leanpub-start-insert
[7]    :If n.∆TestFlag
[8]        n.∆ErrorMsg←msg
[9]        r←1
[10]   :Else
leanpub-end-insert
[11]       U←##.GuiUtils
[12]       n2←U.CreateNamespace
[13]       n2.(∆V_Gap ∆H_Gap)←n.(∆V_Gap ∆H_Gap)
[14]       n2←n2 CreateGUI n msg caption
[15]       {}n2.OK U.DQ n2.∆Form
[16]       Close n2.∆Form
[17]   :EndIf
     ∇
~~~

Now it becomes apparent why we assigned the right argument of `GUI.Run` --- `testFlag` --- to `n.∆TestFlag`: we need this potentially in order to avoid handing over control to the user; in test cases we don't want to do this.


### Final steps

1. Delete `#._MyApp.TestCases.Test_0001`

1. Run `#._MyApp.TestCases.RunDebug 0`.


### Pros and cons of GUI testing

GUIs tend to change quite a lot over time, and rewriting --- or adding --- plenty of test cases can take a significant amount of time, sometimes way more than is needed to implement the GUI in the first place.

In such cases the time invested into exhaustive test cases might be too high.

On the other hand if the application's main purposes is to make complex tasks managable then there will be a lot of dependencies and checking going on in the background. In that case exhaustive test cases might well be a good investment if only because you will find bugs for sure. Your call.


## Conclusion

We believe that we have demonstrated that the combination of techniques outlined in this chapter leads not only to better code but makes it also way easier to actually write GUI applications in the first place.

Having said this, the approach outlined here is insufficient in case the GUI of an application changes heavily depending on the user's actions. 

However, the principal ideas can still be used but the list of controls would probably best be compiled from scratch at the start of each callback function rather than having them as a static list in a namespace.

It was Paul Mansour who came up with many of the ideas outlined here. We stole plenty from him and therefore owe him a big thank you.



[^appstream]: <https://aws.amazon.com/appstream2/>


*[HTML]: Hyper Text Mark-up language
*[DYALOG]: File with the extension 'dyalog' holding APL code
*[TXT]: File with the extension 'txt' containing text
*[INI]: File with the extension 'ini' containing configuration data
*[DYAPP]: File with the extension 'dyapp' that contains 'Load' and 'Run' commands in order to put together an APL application
*[EXE]: Executable file with the extension 'exe'
*[BAT]: Executeabe file that contains batch commands
*[CSS]: File that contains layout definitions (Cascading Style Sheet)
*[MD]: File with the extension 'md' that contains markdown
*[CHM]: Executable file with the extension 'chm' that contains Windows Help(Compiled Help) 
*[DWS]: Dyalog workspace
*[WS]: Short for Workspaces
*[PF-key]: Programmable function key