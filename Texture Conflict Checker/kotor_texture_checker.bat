@echo off
setlocal
:: Target Folder
set "TARGET_FOLDER=override"
:: Powsershell Scripts
set "PS_SCRIPT=.ktc\txchck.ps1"

::Run PowerShell scripts
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" "%TARGET_FOLDER%"

endlocal
