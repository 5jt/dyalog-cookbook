rem MyApp.exe ''
rem echo Call with no filename; exit Code is %errorlevel%

rem MyApp.exe 'does not exist'
rem echo Call with filename that does not exist; exit Code is %errorlevel%

MyApp.exe 'C:\thedyalogcookbook\texts\en\dos_not_exist'
echo Call with filename that does exist; exit Code is %errorlevel%

MyApp.exe 'C:\thedyalogcookbook\texts\en\ageofinnocence.txt'
echo Call with filename that does exist; exit Code is %errorlevel%

MyApp.exe '"C:\thedyalogcookbook\texts\en\"'
echo Call with directory name; exit Code is %errorlevel%
