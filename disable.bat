@echo off
setlocal
rem SmartGunMode uninstaller
rem Usage: disable.bat "D:\path\to\Cyberpunk 2077"
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

del /Q "%GAME%\r6\scripts\smartgun_mode.reds" 2>nul
del /Q "%GAME%\r6\tweaks\smartgun_smart_full.yaml" 2>nul

echo [OK] SmartGunMode disabled. Restart the game to restore vanilla behavior.
pause
