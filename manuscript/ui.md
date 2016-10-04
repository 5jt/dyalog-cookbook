{:: encoding="utf-8" /}

# User interface 

Modern graphical user interfaces (GUIs, or more simply, UIs) are a wonder. UI conventions are so widely known it is now unremarkable for people to start using applications without prior training, expecting the software to make clear what they need to do. 

This is a high standard to meet, and writing UIs is a deep art. The primary platforms for professional writers of UIs are currently Windows Presentation Foundation (WPF) and a combination of HTML 5 and JavaScript (HTML/JS). These are rich platforms, which enable effective and attractive UIs to be written. 

The high quality of these UIs is particularly important for mass-market software, where users are unskilled and unsupported. 

WPF and HTML/JS have a high learning threshold. There is much to be mastered before you can write good UIs on these platforms. 

You have an alternative. The GUI tools native to Dyalog support perfectly workmanlike GUIs. They exploit and extend your existing knowledge of Dyalog. If you are producing high-value software for a few users, rather than software for casual use by millions, a native Dyalog GUI might be your best platform.

Creating a GUI form in Dyalog could hardly be simpler:

      UI←⎕NEW⊂'Form'
      UI.Caption←'Hello world'

![Hello world form](images/form_01.jpg)

To the form we add controls, set callback functions to run when certain events occur, and invoke the form's `Wait` method. See the _Dyalog for Microsoft Windows Interface Guide_ for details and tutorials. 

## Navigating the UI

Embedding a form into an application raises more difficult questions. Chief among them is where to put the form. 

It is common for a callback to read or set other controls in the UI. The question is: how to find them? Callback functions always receive in their arguments a reference to the UI control that triggered the callback. How to navigate the UI's hierarchy (tree) of controls? 

Keep in mind the following common practices we'll want to accommodate.

* A single callback function is often used to handle an event or events for several controls. 
* It is common during development or maintenance to redesign parts of the UI. If you think of the UI as a tree rooted in its form, redesign can move entire branches of the tree. 
* We might want multiple instances of the same form. For example, if the form allows us to browse a customer record, we might want two records open at the same time. 

Here are some strategies for embedding and navigating the UI tree. 

### Use absolute names 

This is the method used above: `UI←⎕NEW⊂'Form'`. The object `UI` is a child of the workspace root. It's the strategy implied by the interface tutorials. It's easy to read and understand:

        UI.(MB←⎕NEW⊂'Menubar')
        UI.MB.(MenuFile←⎕NEW⊂'Menu'('Caption' '&File'))

Notice that the `⎕NEW` that creates each control is executed within its parent. This constructs the UI tree. Notice too that the control is given a name within its parent. So, for example, we can refer to the File menu as `UI.MB.MenuFile`. This is clear enough, but it embeds the structure of the UI into the name of each control. So if we want to move a branch of the UI tree we have to find and edit every reference to controls in that branch. 

If we want multiple instances of the form, we will need to pass our code _references_ to forms, not _names_ of forms.


### Navigate relative paths 

A callback can navigate the UI tree starting at the control that called it. `obj.##` gives it a reference to the `obj`s parent. Much as you construct relative filepaths, you can construct relative paths to other controls. 

This strategy sacrifices a little clarity (you need the UI tree clearly in mind in order to read the path) but by avoiding absolute names it supports multiple instances. 

It also reduces the editing required when you move a branch of the UI tree. Relative paths entirely within the moved branch continue to work as before. Only paths that cross into or out of the branch require editing. 


### Navigate by searching the UI tree 

Relative paths support multiple instances and are more robust than absolute paths under changes to the UI, but they still bind the callbacks quite tightly to a particular structure of the tree. 

This binding can be loosened by searching the UI tree. For example, a callback from a button could (use a utility function to) find the button's closest ancestor SubForm and thence a Grid object that is a child of the Subform. 

A search could start from anywhere in the UI tree. 

If you have worked on Web interfaces, you might wish to write utility functions that would implement the CSS-style selector syntax used by JQuery. 


### Assign unique names to controls

Continuing the line of thought above, writers of JQuery interfaces know the simplest (and fastest) way to identify a control is to use its unique ID. We recommend a similar method for native Dyalog UIs.[^Mansour]

In this strategy: 

* The function that launches a form (of which the UI might contain many) creates, as a local variable, an empty namespace. Call this the _UI namespace_.
* The form -- and all its child controls -- is created in this namespace.
* As each control is created, it has a name assigned to it in the namespace. 
* As each control is created, it has embedded in it a reference to the UI namespace itself. 

The resulting UI namespace contains 

* The UI object tree
* A uniquely-named reference to each control 

Suppose the reference to the UI namespace is embedded in each control as its `ui` attribute. A callback on control `obj` can thus refer to another control `Foo` simply as `obj.ui.Foo` regardless of the structure of the UI tree. 

This depends on every control being created with a `ui` property referring back to the UI namespace. We can protect against failure to define this property. A utility function `GetRef2ui` can search up the UI tree until it finds an ancestor object with this `ui` property defined. 

We'll use this approach to build a simple user interface for MyApp. 


## A simple UI with native Dyalog forms

A new namespace script, UI in which a niladic function `Run` runs the user interface:

   ⍝ aliases
    (A E F)←#.(APLTreeUtils Environment FilesAndDirs)
    (M R U)←#.(MyApp RefNamespace Utilities)

    ∇ Run;ui
      ui.∆Path←F.PWD
      DQ ui.∆form
      Shutdown
     ⍝ done
    ∇

Here we see the outline clearly. An instance of the RefNamespace class is assigned to `ui`. It is a namespace, empty apart from some standard methods -- 
try `]adoc_browse #.RefNamespace` to see details. 

Functions `CreateGui` and `Init` build and initialise the user interface encapsulated in `ui`. Neither function needs to return a result, but doing so means the functions could be chained, for example:

      ui←Init CreateGui R.Create'User Interface'




### Forms

### Controls

### Callbacks and the event queue

### Extended controls



[^Mansour]: Thanks to Paul Mansour, the first person we know to describe this strategy. 