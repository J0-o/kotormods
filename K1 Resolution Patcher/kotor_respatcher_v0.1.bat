@echo off
setlocal enabledelayedexpansion

set "EXE=swkotor.exe"
set "BACKUP=swkotor_backup.exe"
set "MD5_A=9A44891011437DEB6536D992BCCDFE4B"
set "MD5_B=D2BC3D8EF527DF1B8547BC0740DB74ED"

echo === KOTOR Resolution Patcher v0.1 ===

:: Restore backup if it exists
if exist "%BACKUP%" (
    echo Restoring backup from %BACKUP%...
    copy /y "%BACKUP%" "%EXE%" >nul
    echo Backup restored.
)

:: MD5 check
for /f "tokens=* delims=" %%H in ('certutil -hashfile "%EXE%" MD5 ^| find /i /v "hash" ^| find /i /v "certutil"') do (
    set "HASH=%%H"
)
set "HASH=!HASH: =!"

echo Detected MD5: !HASH!

if /i not "!HASH!"=="%MD5_A%" if /i not "!HASH!"=="%MD5_B%" (
    echo ERROR: swkotor.exe is not a supported version.
    echo This patcher only supports GOG version or the editable exe.
    pause
    exit /b 1
)

:: Make backup if one doesn’t exist
if not exist "%BACKUP%" (
    echo Creating backup of %EXE%...
    copy /y "%EXE%" "%BACKUP%" >nul
    echo Backup saved as %BACKUP%.
)

echo MD5 verified. Continuing...
echo.

set /p "width=Enter desired width (e.g. 1920): "
set /p "height=Enter desired height (e.g. 1080): "

:: Resolution sanity check
if %width% lss 1440 (
    echo ERROR: Minimum allowed resolution is 1440x900.
    pause
    exit /b 1
)
if %height% lss 900 (
    echo ERROR: Minimum allowed resolution is 1440x900.
    pause
    exit /b 1
)

set /p "borderless=Enable borderless widescreen mode? (Y/N): "

:: Convert to little-endian hex
powershell -noprofile -command "$bytes = [BitConverter]::GetBytes(%width%); $hex = ''; foreach ($b in $bytes) { $hex += $b.ToString('x2') }; $hex" > width.hex
powershell -noprofile -command "$bytes = [BitConverter]::GetBytes(%height%); $hex = ''; foreach ($b in $bytes) { $hex += $b.ToString('x2') }; $hex" > height.hex

set /p WHEX=<width.hex
set /p HHEX=<height.hex

del width.hex
del height.hex

echo Width bytes:  !WHEX!
echo Height bytes: !HHEX!

if not defined WHEX (
    echo ERROR: Failed to convert width to hex.
    pause
    exit /b 1
)

if not defined HHEX (
    echo ERROR: Failed to convert height to hex.
    pause
    exit /b 1
)

:: Offsets to patch
set PATCH[0].OFFSET=0x3D6C
set PATCH[1].OFFSET=0x1F0C65
set PATCH[2].OFFSET=0x1F5B3B
set PATCH[3].OFFSET=0x28C4E3
set PATCH[4].OFFSET=0x3D78
set PATCH[5].OFFSET=0x1F0C6F
set PATCH[6].OFFSET=0x1F5B43
set PATCH[7].OFFSET=0x28C4F3
set PATCH[8].OFFSET=0x28C4FA

echo.
echo Patching %EXE% with %width%x%height%...

for /L %%I in (0,1,8) do (
    set "OFFSET=!PATCH[%%I].OFFSET!"

    if %%I lss 4 (
        set "BYTES=!WHEX!"
    ) else if %%I lss 7 (
        set "BYTES=!HHEX!"
    ) else (
        set "BYTES=00000000"
    )

    powershell -NoProfile -Command ^
        "$exe = Resolve-Path '%EXE%';" ^
        "$offset = [Int64]::Parse('!OFFSET!'.Replace('0x',''), 'HexNumber');" ^
        "$hex = '!BYTES!';" ^
        "$bytes = New-Object byte[] ($hex.Length / 2);" ^
        "for ($i = 0; $i -lt $hex.Length; $i += 2) {" ^
        "  $bytes[$i/2] = [Convert]::ToByte($hex.Substring($i,2),16)" ^
        "}" ^
        "$fs = [IO.File]::Open($exe, 'Open', 'ReadWrite');" ^
        "$fs.Seek($offset, 'Begin') > $null;" ^
        "$fs.Write($bytes, 0, $bytes.Length);" ^
        "$fs.Close(); Write-Host 'Patched offset !OFFSET!.'"
)

if /i "%borderless%"=="Y" (
    echo Enabling borderless windowed mode...

    powershell -NoProfile -Command ^
        "$exe = Resolve-Path '%EXE%';" ^
        "$offset = 0x4DC0C;" ^
        "$bytes = 0xBE,0x00,0x00,0x00,0x90;" ^
        "$fs = [IO.File]::Open($exe, 'Open', 'ReadWrite');" ^
        "$fs.Seek($offset, 'Begin') > $null;" ^
        "$fs.Write($bytes, 0, $bytes.Length);" ^
        "$fs.Close(); Write-Host 'Hex patch for borderless applied.'"
)

echo.
echo Resolution patch complete.
echo.
echo.
echo Updating swkotor.ini...

set "INI=swkotor.ini"
set "TMP=swkotor_temp.ini"
set "IN_GRAPHICS=0"
set "ADDED_AWM=0"

> "%TMP%" (
  for /f "usebackq tokens=1* delims=:" %%A in (`findstr /n "^" "%INI%"`) do (
    set "line=%%B"
    setlocal enabledelayedexpansion

    if /i "!line!"=="[Graphics Options]" (
      echo !line!
      echo AllowWindowedMode=1
      set "ADDED_AWM=1"
    ) else if /i "!line:~0,6!"=="Width=" (
      echo Width=%width%
    ) else if /i "!line:~0,7!"=="Height=" (
      echo Height=%height%
    ) else if /i "!line:~0,18!"=="AllowWindowedMode=" (
      rem skip existing AllowWindowedMode line
    ) else if /i "!line:~0,11!"=="FullScreen=" (
      if /i "%borderless%"=="Y" (
        echo FullScreen=0
      ) else (
        echo FullScreen=1
      )
    ) else (
      echo(!line!
    )


    endlocal
  )
)

move /y "%TMP%" "%INI%" >nul
echo swkotor.ini updated successfully.


pause