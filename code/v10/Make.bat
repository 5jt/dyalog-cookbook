"C:\Program Files\Dyalog\Dyalog APL-64 15.0 Unicode\Dyalog.exe" MAXWS=128MB DYAPP="%~dp0Make" %1
@echo off
if NOT ["%errorlevel%"]==["0"] (
    echo Error %errorlevel%
    pause
    exit /b %errorlevel%
)