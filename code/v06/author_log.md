# Author's log V06


## To Do

* Test cases for Utilities
* explain EstablishHelpersIn
* Test returned error codes in Windows
* Replace Trap 0 with an error #
* Write up EXE testing
* When HandleError caught a filename error, why did the EXE not exit -- with an error code?
* Now HandleError reports a RC=103 why does `echo %errorlevel% show `0`?

## Done

* Write tests for EXE
* Split off from `#.MyApp` into `#.Application` fns `Start`, `Off` and `GetParameters`. 
* Put `Export` into `#.Application`
* Disperse DevTools into `#.MyApp` when starting in Session mode. 


