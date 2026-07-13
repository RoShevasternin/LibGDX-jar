@echo off
chcp 65001 >nul
cd /d "%~dp0"

REM ============================================================
REM  MSDF Atlas Generator - drag & drop wrapper
REM  Використання: перетягни .ttf файл НА цей .bat
REM  Поруч мають лежати: msdf-atlas-gen.exe та charset.txt
REM ============================================================

if "%~1"=="" (
    echo.
    echo   Перетягни .ttf файл НА цей скрипт.
    echo.
    pause
    exit /b 1
)

if not exist "msdf-atlas-gen.exe" (
    echo   ПОМИЛКА: msdf-atlas-gen.exe не знайдено поруч зі скриптом.
    pause
    exit /b 1
)
if not exist "charset.txt" (
    echo   ПОМИЛКА: charset.txt не знайдено поруч зі скриптом.
    pause
    exit /b 1
)

set "FONT=%~1"
set "NAME=%~n1"

echo.
echo   Шрифт: %NAME%
echo   (Enter = значення за замовчуванням)
echo.

set "SIZE=48"
set /p SIZE="  Розмір гліфа [48]: "

set "RANGE=32"
set /p RANGE="  Range (товщина ефектів: 8 тонкі / 32 товсті) [32]: "

set "DIM=auto"
set /p DIM="  Розмір атласу px (число, або auto) [auto]: "

echo.
echo   Генерую: size=%SIZE% range=%RANGE% dim=%DIM% ...
echo.

if /i "%DIM%"=="auto" (
    msdf-atlas-gen.exe -font "%FONT%" -charset charset.txt -type mtsdf -format png -imageout "%NAME%.png" -json "%NAME%.json" -size %SIZE% -pxrange %RANGE% -yorigin top
) else (
    msdf-atlas-gen.exe -font "%FONT%" -charset charset.txt -type mtsdf -format png -imageout "%NAME%.png" -json "%NAME%.json" -size %SIZE% -pxrange %RANGE% -dimensions %DIM% %DIM% -yorigin top
)

if errorlevel 1 (
    echo.
    echo   ПОМИЛКА генерації. Якщо "cannot fit" - збільш розмір атласу.
) else (
    echo.
    echo   ГОТОВО: %NAME%.png + %NAME%.json
    echo   Копіюй обидва у assets/font/msdf/
)
echo.
pause
