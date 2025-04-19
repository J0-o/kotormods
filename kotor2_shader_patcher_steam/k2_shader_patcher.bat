@echo off
setlocal enabledelayedexpansion

set "EXE=swkotor2.exe"
set "PATCHDIR=patches"

echo Applying patches to %EXE%...

for %%F in (%PATCHDIR%\*.txt) do (
    set "OFFSET="
    set "BYTES="
    set "DESC="

    for /f "usebackq tokens=1,* delims==" %%A in ("%%F") do (
        set "key=%%A"
        set "val=%%B"
        if /i "!key!"=="OFFSET" set "OFFSET=!val!"
        if /i "!key!"=="BYTES" set "BYTES=!val!"
        if /i "!key!"=="DESC"  set "DESC=!val!"
    )

    echo.
    echo File: %%~nxF
    echo Description: !DESC!
    echo Offset: !OFFSET!
    echo Bytes: !BYTES!

    powershell -NoProfile -Command ^
      "$fs = [IO.File]::Open('%EXE%', 'Open', 'ReadWrite');" ^
      "$offset = [int64]::Parse('!OFFSET!'.Replace('0x',''), 'HexNumber');" ^
      "if ($offset -gt $fs.Length) { Write-Host 'ERROR: Offset exceeds file size. Skipping.'; $fs.Close(); exit }" ^
      "$hex = '!BYTES!';" ^
      "$bytes = [byte[]]::new($hex.Length / 2);" ^
      "for ($i = 0; $i -lt $hex.Length; $i += 2) { $bytes[$i/2] = [Convert]::ToByte($hex.Substring($i,2),16) }" ^
      "$fs.Seek($offset, 'Begin') > $null; $fs.Write($bytes, 0, $bytes.Length); $fs.Close()"

)

echo.
echo All patches applied.
pause
