@echo off
setlocal

REM Set your target folder here (or leave empty to prompt)
set "TARGET_FOLDER=override"

REM Set your PowerShell scripts
set "PS_SCRIPT=txchck.ps1"

REM Run the first PowerShell script to generate the lists
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" "%TARGET_FOLDER%"


endlocal
