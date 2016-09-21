ReadMe for MarkAPL
=============

By now you probably know that MarkAPL converts Markdown to HTML.

All you need is the class `MarkAPL` and the namespace script `APLTreeUtils`.

## Quick start

Let's assume you have some Markdown:

~~~
      MyMarkdown←'# MarkAPL' 'All about **_MarkAPL_**'
~~~

There are two possible scenarios:

### Convert some Markdown into HTML

All you need to do is to call the `Markdown2HTML` method:

~~~
      (html ns)←#.MarkAPL.Markdown2HTML MyMarkdown
      50↑∊html
<a id="markapl" class="autoheaderlink"><h1>MarkAPLstrong></p>
~~~

Note that not only the HTML but also a namespace `ns` is returned which, among other stuff, has a variable `report` that might carry warnings and report errors. Ideally `reports` is empty.

This way of calling `Markdown2HTML` relies entirely on defaults. If you are not happy with those you must specify a parameter space via the left argument. The next topic explain how to do that.

### Create a fully fledged HTML page from Markdown

In order to make **_MarkAPL_** create a complete HTML page you can either specify `outputFilename` or set the `createFullHtmlPage` flag to 1:

~~~
      parms←#.MarkAPL.CreateParms
      parms.createFullHtmlPage←1
      (html ns)←parms #.MarkAPL.Markdown2HTML MyMarkdown
      ⍪4↑html
 <!DOCTYPE html>        
 <html>                 
 <head>                 
 <meta charset="utf-8"> 
~~~

## Full documentation

Call `#.MarkAPL.Help 0` in order to put the documentation on display.

Note that this requires the file Markdown.html to be found either in the folder `Files\` within the current directory or, if the script MarkAPL.dyalog was loaded with Salt, in the folder `Files\` relative to where the script was loaded from. 

If those assumptions don't work you must tell `Help` where to find the file:

~~~
      parms←#.MarkAPL.CreateHelpParms
      parms.homeFolder←'C:\WhereMarkdown.HTML_lives'
      parms #.MarkAPL.Help 0
~~~

## The workspace

The workspace contains not only the two scripts but also the test suite. To run them execute `#.TestCases.Run`. 

For further information consult the script `#.Tester` in the workspace.

## Misc

Please send comments, suggestions and bug reports to kai@aplteam.com.   

Kai Jaeger ⋄ APL Team Ltd ⋄ 2016-02-17

Latest update: 2016-06-02