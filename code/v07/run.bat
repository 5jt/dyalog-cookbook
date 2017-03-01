MyApp.exe ''
echo Call with no filename; exit Code is %errorlevel%

MyApp.exe 'does not exist'
echo Call with filename that does not exist; exit Code is %errorlevel%

MyApp.exe 'C:\Users\kai\Dropbox\thedyalogcookbook\texts\en\ageofinnocence.txt'
echo Call with filename that does exist; exit Code is %errorlevel%

MyApp.exe '"C:\Users\kai\Dropbox\thedyalogcookbook\texts\en\"'
echo Call with directory name; exit Code is %errorlevel%
