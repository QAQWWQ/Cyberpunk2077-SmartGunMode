@echo off
setlocal
rem SmartGunMode installer
rem Usage: enable.bat "D:\path\to\Cyberpunk 2077"
rem Or create game_path.txt containing the game folder path.

set "GAME=%~1"
if "%GAME%"=="" if exist "%~dp0game_path.txt" set /p GAME=<"%~dp0game_path.txt"
if "%GAME%"=="" set /p GAME=Enter Cyberpunk 2077 folder:
set GAME=%GAME:"=%

if not exist "%GAME%\r6" (
  echo [ERROR] Invalid game path: "%GAME%"
  pause
  exit /b 1
)

if not exist "%GAME%\r6\scripts" mkdir "%GAME%\r6\scripts"
if not exist "%GAME%\r6\tweaks" mkdir "%GAME%\r6\tweaks"

copy /Y "%~dp0r6\scripts\smartgun_mode.reds" "%GAME%\r6\scripts\smartgun_mode.reds" >nul
copy /Y "%~dp0r6\tweaks\smartgun_smart_full.yaml" "%GAME%\r6\tweaks\smartgun_smart_full.yaml" >nul

if errorlevel 1 (
  echo [ERROR] Copy failed. Check write permissions.
) else (
  echo [OK] SmartGunMode enabled. Restart the game.
)
pause
