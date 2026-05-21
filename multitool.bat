@echo off
:: =====================================================
:: Multi-Tool Batch Script
:: A menu-driven utility for common Windows tasks.
:: =====================================================
setlocal EnableDelayedExpansion
title Multi-Tool

:MAIN_MENU
cls
echo =====================================================
echo                    MULTI-TOOL MENU
echo =====================================================
echo  [1]  System Information
echo  [2]  Network Information (ipconfig)
echo  [3]  Ping a Host
echo  [4]  Traceroute a Host
echo  [5]  DNS Lookup (nslookup)
echo  [6]  List Running Processes
echo  [7]  Kill a Process (by name)
echo  [8]  Disk Usage / Drives
echo  [9]  Search for a File
echo  [10] Compute File Hash (SHA256)
echo  [11] Flush DNS Cache
echo  [12] Show Open Network Connections (netstat)
echo  [13] List Installed Updates (hotfixes)
echo  [14] Show Wi-Fi Profiles + Passwords
echo  [15] Create a Quick Backup (zip a folder)
echo  [16] Generate a Random Password
echo  [17] Show Public IP
echo  [0]  Exit
echo =====================================================
set /p "choice=Select an option: "

if "%choice%"=="1"  goto SYSINFO
if "%choice%"=="2"  goto NETINFO
if "%choice%"=="3"  goto PING
if "%choice%"=="4"  goto TRACERT
if "%choice%"=="5"  goto NSLOOKUP
if "%choice%"=="6"  goto PROCLIST
if "%choice%"=="7"  goto PROCKILL
if "%choice%"=="8"  goto DISKINFO
if "%choice%"=="9"  goto FILESEARCH
if "%choice%"=="10" goto HASH
if "%choice%"=="11" goto DNSFLUSH
if "%choice%"=="12" goto NETSTAT
if "%choice%"=="13" goto HOTFIX
if "%choice%"=="14" goto WIFI
if "%choice%"=="15" goto BACKUP
if "%choice%"=="16" goto PASSGEN
if "%choice%"=="17" goto PUBIP
if "%choice%"=="0"  goto END

echo Invalid choice. Try again.
pause
goto MAIN_MENU

:SYSINFO
cls
echo --- System Information ---
systeminfo
goto PAUSE_RETURN

:NETINFO
cls
echo --- Network Configuration ---
ipconfig /all
goto PAUSE_RETURN

:PING
cls
set /p "host=Enter host or IP to ping: "
if "%host%"=="" goto MAIN_MENU
ping %host%
goto PAUSE_RETURN

:TRACERT
cls
set /p "host=Enter host or IP for traceroute: "
if "%host%"=="" goto MAIN_MENU
tracert %host%
goto PAUSE_RETURN

:NSLOOKUP
cls
set /p "host=Enter domain to look up: "
if "%host%"=="" goto MAIN_MENU
nslookup %host%
goto PAUSE_RETURN

:PROCLIST
cls
echo --- Running Processes ---
tasklist
goto PAUSE_RETURN

:PROCKILL
cls
set /p "proc=Enter process name to kill (e.g. notepad.exe): "
if "%proc%"=="" goto MAIN_MENU
taskkill /F /IM "%proc%"
goto PAUSE_RETURN

:DISKINFO
cls
echo --- Drives and Free Space ---
wmic logicaldisk get deviceid,volumename,size,freespace
goto PAUSE_RETURN

:FILESEARCH
cls
set /p "fname=Enter filename or pattern (e.g. *.txt): "
if "%fname%"=="" goto MAIN_MENU
set /p "fpath=Enter path to search (default C:\): "
if "%fpath%"=="" set "fpath=C:\"
echo Searching for "%fname%" in "%fpath%" ...
dir /s /b "%fpath%\%fname%" 2>nul
goto PAUSE_RETURN

:HASH
cls
set /p "fpath=Enter full path to file: "
if "%fpath%"=="" goto MAIN_MENU
certutil -hashfile "%fpath%" SHA256
goto PAUSE_RETURN

:DNSFLUSH
cls
echo Flushing DNS cache...
ipconfig /flushdns
goto PAUSE_RETURN

:NETSTAT
cls
echo --- Active Network Connections ---
netstat -ano
goto PAUSE_RETURN

:HOTFIX
cls
echo --- Installed Hotfixes ---
wmic qfe list brief
goto PAUSE_RETURN

:WIFI
cls
echo --- Saved Wi-Fi Profiles ---
echo (Run as Administrator to view passwords)
echo.
for /f "tokens=2 delims=:" %%P in ('netsh wlan show profiles ^| findstr /R /C:"All User Profile"') do (
    set "profile=%%P"
    set "profile=!profile:~1!"
    echo Profile: !profile!
    netsh wlan show profile name="!profile!" key=clear | findstr /C:"Key Content"
    echo ----------------------------------
)
goto PAUSE_RETURN

:BACKUP
cls
set /p "src=Enter folder path to back up: "
if "%src%"=="" goto MAIN_MENU
set /p "dst=Enter destination zip file (e.g. C:\backup.zip): "
if "%dst%"=="" goto MAIN_MENU
echo Creating backup...
powershell -NoProfile -Command "Compress-Archive -Path '%src%' -DestinationPath '%dst%' -Force"
echo Done.
goto PAUSE_RETURN

:PASSGEN
cls
set /p "len=Password length (default 16): "
if "%len%"=="" set "len=16"
powershell -NoProfile -Command "$chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%%^&*'; -join ((1..%len%) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })"
goto PAUSE_RETURN

:PUBIP
cls
echo --- Public IP Address ---
powershell -NoProfile -Command "(Invoke-WebRequest -UseBasicParsing 'https://api.ipify.org').Content"
goto PAUSE_RETURN

:PAUSE_RETURN
echo.
pause
goto MAIN_MENU

:END
echo Goodbye!
endlocal
exit /b 0
