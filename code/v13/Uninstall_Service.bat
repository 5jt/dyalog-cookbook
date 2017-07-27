sc delete MyAppService
@echo off
    echo Error %errorlevel%
    if NOT ["%errorlevel%"]==["0"] (
    pause
exit /b %errorlevel%
)