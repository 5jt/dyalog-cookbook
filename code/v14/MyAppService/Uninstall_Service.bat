sc delete MyAppService
@echo off
if NOT ["%errorlevel%"]==["0"] (
pause
exit /b %errorlevel%
)