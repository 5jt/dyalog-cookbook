# Workpace integrity, corruptions and aplcores

The _workspace_ (WS) is where the APL interpreter manages all code and all data in memory. The Dyalog tracer / debugger has extensive edit-and-continue capabilities; the downside is that these have been known to occasionally corrupt the workspace.

The interpreter checks WS integrity every now and then; how often can be influenced by setting certain debug flags; see "The APL Command Line" in the documentation for details.

When it finds that the WS is damaged it will create a dump file called "aplcore" and exit in order to prevent your application from producing (or storing) incorrect results.

Regularly rebuilding the workspace from source files removes the risk of accumulating damage to the binary workspace.

Note that an aplcore is useful in two ways: 

* You can copy from it. It's not a good idea to copy the whole thing though; something has been wrong with it after all. It may be fine to recover a particular object (or some objects) from it, although you would be advised to extract the source and rebuild recovered objects from the source, rather than using binary data recovered from an aplcore. Add a colon: `)copy aplcore. myObj`

* Send the aplcore to Dyalog. It's kind of a dump, so they might be able to determine the cause of the problem.