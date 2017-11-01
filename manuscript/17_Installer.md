Creating a SetUp.exe with the Inno installer
============================================

Before we goin into the details please copy


Defining the goal
--------------------

Are application is now ready for being installed on a client's machine. What we need is a piece of software that does a couple of things for us:

1. Collect all the files that need to go onto a client's machine
1. Create a file `SetUp.exe` (you might choose a different name) that contains the program that is capable of installing our application on a client's machine and also carries all those files after compressing them.

There are many more things an installer might or might not do, but these are the essential tasks.


Which tool
----------

There are quite a number of installers available. The market leader is clearly Wix which is required in case you need to roll out our software to large corporations.

Wix is very powerful, but the power has a price: it's also very complex. We reckon that you start smaller than with large corporotations. Event if this assumption is wroong it would mean you are lost likely in a position to hire a professional doing the job for you. 

To start smaller means choosing a tool that is less complicated and can be mastered fast. Inno has made itself a name as a tool that combines features with an easy interface.

To download Inno visit <http://www.jrsoftware.org/isdl.php>. We suggest to go for the "QuickStart Pack". That does not only install the Inno compiler and help but also Inno Script Studio from Kymoto (<https://www.kymoto.org/>).

It also comes with en encrypting DLL although we don't see the point of encrypting the installer. After the installation has been carried out a user can access all the files anyway.

The Script Studio does not only make it easier to use Inno, it comes also with a debugger which can be very helpful if you want to get to the bottom of a problem.

Note that both packages are free to use, even for commercial usage. However, you are encouraged to donate to both Inno and Script Studio as soon as you start to make money with your software.


Using Inno with Script Studio
-----------------------------

The easiest way to start with Inno is to take an existing script and study it. Trial and error and Inno's old-fashioned looking but otherwise excellent help are your friends.


Inno
----


### Structure of an Inno script

Inno requires, similar to good old fashioned INI files, a number of sections:


Setup
: In this section you are supposed to define constants that carry all the pieces of information that are specific to your application. There should be no otyher places where, say, a path or a filename is specified; that should all be done in the `[Setup]` section.


Language
: Used to define the language and the message file.


Registry
: This section can be used to write information to the Windows Registry.


Dirs
: Used to define constants that point to particular directories, and to specify permissions.


Files
: Specifies all the files that are going to be collected within `SetUp.exe`.


Icons
: Specifies the icons that are required.


Run
: Run other programm, either during installation or afterwards.


Tasks
: Add check boxes or radio buttons to the installation wizard's windows so that the user can decided whether those tasks should be carried out or not.


Code
: Used to define programs in a scripting language similar to Pascal for doing more complex things.

: Inno has powerful built-in capabilities which allow us to reach all our goals without writing any code. Note however that for many common tasks there are scripts available on the Internet.





Sources of information
----------------------

When you run into an issue or need badly a particular feature then Googling for it is of course a good idea, even better than reeferring to Inno's help: the help is excellent as a reference, you just type a term you need help with and press F1, but in case you don't know exactly what to search for Google is your friend. You will find that Google often enough suggest Inno's help anyway, but Google gets you to the right page without further ado.

We found that that's enough to get advice on all the problems we run into while getting acquainted to Inno.

