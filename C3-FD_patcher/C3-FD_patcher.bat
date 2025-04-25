@echo off
setlocal enabledelayedexpansion

set "EXE=swkotor2.exe"
set "BACKUP=swkotor2_backup.exe"
set "STEAMMD5=2f2d31e21acc6b3d9c5f28c79a28a202"
set "GOGMD5=1ffa92993d8015c9bb93ceac96c508c0"

rem Print ASCII art
for %%L in (
	"                                            000             "
	"                                            000             "
	"                                            000             "
	"                                            000             "
	"                                            00              "
	"                                           000              "
	"                         000000000         000              "
	"    000000000000000000000000    000000000000000000000000    "
	"   00                0000 00000000 0000                00   "
	" 00000000000000000000000 00      00 00000000000000000000000 "
	" 00            0     00 00        00 00                 000 "
	"00             0     00000        00 00       0000     00000"
	"000000000000000000000000 000    000 00000000000  00000000 00"
	"000000000      0      0000 000000 0000        0000     00000"
	"00             0        000000000000                    0000"
	" 00000000000000000000000000000000000000000000000000000000000"
	"             0000000000000000000000000000000000             "
	"                  00    00       000000000                  "
) do echo %%~L
echo ============================================================
echo 3C-FD Patcher by J
echo Includes: 4GB Memory Patch, Fog Fix, Reflections Fix, Color Adjustment
echo ============================================================

echo Usage Agreement:
echo.
echo By using this patcher, you accept that you do so at your own risk.
echo The creator is not responsible for any damage, loss, or other issues that may result.
echo No warranty is provided.
echo If you do not agree, do not use this patcher.
echo.

set /p "agree=Do you agree to these terms? (Y/N): "

if /i "%agree%"=="Y" (
    echo.
    echo Agreement accepted. Continuing...
) else (
    echo.
    echo You did not agree. Exiting.
    exit /b
)

rem backup
if exist "%BACKUP%" (
	copy /y "%BACKUP%" "%EXE%" >nul
	echo Backup restored to %EXE%.
	echo.
) else (
	echo.
	echo No backup found. Creating a backup now...
	copy /y "%EXE%" "%BACKUP%" >nul
	echo Backup created: %BACKUP%
	echo.
)

rem Calculate MD5
for /f "tokens=* delims=" %%H in ('certutil -hashfile "%EXE%" MD5 ^| find /i /v "hash" ^| find /i /v "certutil"') do (
    set "HASH=%%H"
)

set "HASH=!HASH: =!"
echo Detected MD5: !HASH!

rem Determine patch directory based on hash
if /i "!HASH!"=="%STEAMMD5%" (
    set "PATCHDIR=patches\steam"
    echo Detected Steam version.
) else if /i "!HASH!"=="%GOGMD5%" (
    set "PATCHDIR=patches\gog"
    echo Detected GOG version.
) else (
    echo ERROR: Unknown swkotor2.exe version. Unmoddified Steam and GOG exe support only. No patches applied.
    pause
    exit /b 1
)

echo Applying patches from !PATCHDIR! to %EXE%...

for %%F in (!PATCHDIR!\*.txt) do (
    set "OFFSET="
    set "DESC="

    rem Read metadata
    for /f "usebackq tokens=1,* delims==" %%A in ("%%F") do (
        set "key=%%A"
        set "val=%%B"
        if /i "!key!"=="OFFSET" set "OFFSET=!val!"
        if /i "!key!"=="DESC"   set "DESC=!val!"
    )

    echo.
    echo File: %%~nxF
    echo Description: !DESC!
    echo Offset: !OFFSET!

    powershell -NoProfile -Command ^
        "$exe = Resolve-Path '%EXE%';" ^
        "$offset = [Int64]::Parse('!OFFSET!'.Replace('0x',''), 'HexNumber');" ^
        "$patch = Get-Content -Raw '%%F';" ^
        "$hex = ($patch -split '\r?\n') | Where-Object { $_ -match '^BYTES=' } | ForEach-Object { $_ -replace '^BYTES=', '' };" ^
        "$bytes = [byte[]]::new($hex.Length / 2);" ^
        "for ($i = 0; $i -lt $hex.Length; $i += 2) { $bytes[$i/2] = [Convert]::ToByte($hex.Substring($i,2),16) }" ^
        "$fs = [IO.File]::Open($exe, 'Open', 'ReadWrite');" ^
        "if ($offset + $bytes.Length -gt $fs.Length) { Write-Host 'ERROR: Patch exceeds file size. Skipping.'; $fs.Close(); exit }" ^
        "$fs.Seek($offset, 'Begin') > $null;" ^
        "$fs.Write($bytes, 0, $bytes.Length);" ^
        "$fs.Close(); Write-Host 'Patch applied successfully.'"
)

echo.
echo All patches applied.
pause
