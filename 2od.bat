@echo off
setlocal EnableDelayedExpansion

:: --- Configuration: place links under this subfolder in OneDrive ---
:: Default: empty means OneDrive root
set "OD_SUBDIR="

title Create OneDrive Link

:: Require a file or folder via drag-and-drop
if "%~1"=="" (
  echo Usage: Drag and drop a file or folder onto this script.
  echo.
  echo Press any key to exit.
  pause >nul
  exit /b 1
)

:: Elevate to Administrator if needed
openfiles >nul 2>&1
if errorlevel 1 (
  echo Requesting Administrator privileges...
  powershell -Command "Start-Process '%~f0' -ArgumentList '%*' -Verb RunAs"
  exit /b
)

set "SRC=%~1"

:: Validate source exists
if not exist "%SRC%" (
  echo Error: "%SRC%" does not exist.
  echo Press any key to exit.
  pause >nul
  exit /b 2
)

:: Derive link name (file/folder name or drive letter)
if "%~n1"=="" (
  rem Drive root (e.g., D:\)
  set "LET=%~d1"
  set "LET=!LET:~0,1!"
  set "NAME=!LET!_Drive"
  ) else (
  set "NAME=%~n1"
)

:: Locate OneDrive folder
if defined OneDriveConsumer (
  set "OD=%OneDriveConsumer%"
  ) else if defined OneDrive (
  set "OD=%OneDrive%"
  ) else if exist "%USERPROFILE%\OneDrive" (
  set "OD=%USERPROFILE%\OneDrive"
  ) else (
  echo Error: Could not find OneDrive folder.
  pause >nul
  exit /b 3
)

if not exist "%OD%\" (
  echo Error: "%OD%" not found.
  pause >nul
  exit /b 4
)

:: Determine final link path based on configuration
if "%OD_SUBDIR%"=="" (
  set "LINK=%OD%\%NAME%"
) else (
  if not exist "%OD%\%OD_SUBDIR%\" mkdir "%OD%\%OD_SUBDIR%\\"
  set "LINK=%OD%\%OD_SUBDIR%\%NAME%"
)

echo.
echo Source: "%SRC%"
echo OneDrive: "%OD%"
echo Creating link: "%LINK%"
echo.

:: Prevent overwrite
if exist "%LINK%" (
  echo Error: "%LINK%" already exists.
  pause >nul
  exit /b 5
)

:: Create symbolic link
if exist "%SRC%\" (
  mklink /D "%LINK%" "%SRC%"
  ) else (
  mklink "%LINK%" "%SRC%"
)

if errorlevel 1 (
  echo Error: Failed to create symbolic link.
  ) else (
  echo Success: Link created.
)

echo.
echo Press any key to finish.
pause >nul
endlocal
exit /b 0
