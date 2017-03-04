MyApp.exe 'C:\thedyalogcookbook\texts\en\ageofinnocence.txt'
echo Call with filename that does exist; exit Code is %errorlevel%

MyApp.exe '"C:\thedyalogcookbook\texts\en\does_not_exist"'
echo Call with non-existing filename; exit Code is %errorlevel%

MyApp.exe '"C:\thedyalogcookbook\texts\en\"'
echo Call with directory name; exit Code is %errorlevel%
