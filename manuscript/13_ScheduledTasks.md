{:: encoding="utf-8" /}

# Scheduled Tasks


## What is a Scheduled Task?

Windows offers a task scheduler in order to run application at specific times. Like Services Scheduled Tasks are designed for background job, meaningthat such application have no GUI.

The Scheduler allows you to start the application on a specific date and time once, or every day, every week or every month. The user does not have to be logged on (that's different from old versions of Windows) and it allows different rights.


## Scheduled Tasks versus Services

If your application needs to run all the time, even with delays between actions, then running as a Service would be more approriate. Services are typically started automatically when the machine is bootet, and they keep running until the next boot.

To make this point clear, imagine these two scenarios:

* You need an application to start once a week and take a backup of a specific folder.
* You need an application to constantly monitor a specific folder for certain file types (say Markdown) and convert them (say into HTML files).

The former is clearly a candidate for a Scheduled Task while the latter is a candidate for a Service.


## Preconditions for a Scheduled Task

You need either a saved workspace with `⎕LX` set or an EXE created from a workspace. Unless you need to make sure that your code cannot be looked at, an EXE has no advantages over a simple saved workspace; it just adds complexity and therefore should be avoided if there aren't any advatages. However, if you cannot be sure whether Dyalog is installed on the target machine then you have no choice: it has to be a stand-alone EXE.

We have already taken care of handling errors and writing to log files, which are the only sources for analyzing any problems that pop up when a Scheduled Task runs, or crashes. In other words, we are ready to go.

Our application does not suggest itself as a Scheduled Task; it's obviously a candidate for running as a Service, but that does not mean it cannot run as a Scheduled Task, so let's start.


## Create a Scheduled Task


### Start the Scheduler

Press the <Win> key and type Scheduler. Select "Task Scheduler" form the list. This is what will come up:

![The Windows Task Scheduler](images/scheduler_01.jpg)

First thing to check is that the contents of the black rectangle in the "Actions" pane on the right reads "Enable All Tasks History" - if it does not you won't be able to get to the bottom of any problems.

The arrow points to the "Create Task" command - click it.

![Create Task](images/scheduler_02.jpg)

#### The "General" tab

Name 
: Used in the list presented by the Task Scheduler.

Description
: Shown in the list presented by the Task Scheduler. Keep it concise.

Run only when user is logged on
: You will almost certainly change this to "Run whether user is logged on or not".

Do not store password
: The password is stored savely, so there is not really a reason not to provide it.

Running with highest privileges
: Unfortunately this check box is offered no matter whether your user account has admin rights or not. If it does not, then ticking the box won't make a difference at all.

: If your user account has no admin rights but your Scheduled Task needs to run with hightest privileges then you need to specify a different user id / password after clicking the "Change user or group" button.

: Whether your application needs to run with hightest privileges or not is impossible to say. Experience shows that sometimes something that does not work when the application is running as a Scheduled Task will work fine with highest provoleges although it is by no means clear what those rights are required for.

Configure for

: Generaly you should select the OS the task is running on.

A> ### UAC, admin rights and all the rest
A> 
A> With the UAC, users of the admin group have 2 tokens. The filtered token represents standard user rights. This token is used by default, for example when you create a shell (console). Therefore you have just standard user rights by default even when using a user account with admin rights. However, when you have admin rights and you click an EXE and select "run as administor", the full token is used which contains admin rights.
A> 
A> Notes:
A> * Some applications ask for admin rights even when you do not right-click on the EXE and select "Run as administrator"; the "Registry editor" is an example.
A> * Even if you run an application with admin rights (sometimes called "in elevated mode") it does not mean that the application can do whatever it likes, but as an admin you can always give yourself any missing rights.


#### The "Trigger" tab

The tab does not carry any mysteries.


#### The tab "Action"

After clicking "New" this is what you get:

![New Action](images/scheduler_03.jpg)

Make sure that