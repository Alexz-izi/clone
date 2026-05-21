@echo off
:: =====================================================
:: Multi-Tool - GUI launcher
:: This .bat just launches the PowerShell GUI script.
:: =====================================================
setlocal
title Multi-Tool

set "SCRIPT=%~dp0multitool.ps1"

if not exist "%SCRIPT%" (
    echo ERROR: Cannot find "%SCRIPT%"
    echo Make sure multitool.ps1 is in the same folder as this .bat file.
    pause
    exit /b 1
)

:: -STA is required for Windows Forms
:: -ExecutionPolicy Bypass lets the script run without changing system policy
:: -WindowStyle Hidden hides the PowerShell console window so only the GUI shows
powershell -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%SCRIPT%"

endlocal
exit /b 0
