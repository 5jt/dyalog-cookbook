sc delete MyAppService
@echo off
if NOT ["%errorlevel%"]==["0"] (
    echo Error %errorlevel%
    pause
    exit /b %errorlevel%
)