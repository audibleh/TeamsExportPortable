@echo off
:: Re-launch in persistent cmd so window stays open on crash
if "%1"=="" ( cmd /k "%~f0" run & exit /b )
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: ============================================================
::  Teams Chat Export - Windows Launcher
::  Double-click this file to export your Teams chats.
::  All data stays on this machine.
:: ============================================================

title Teams Chat Export

echo.
echo  ============================================================
echo.
echo   Teams Chat Export
echo.
echo   This tool exports your Teams chats
echo   into an HTML file you can keep.
echo.
echo   Requirements:
echo   - Microsoft Edge must be CLOSED
echo   - You should already be logged into Teams in Edge
echo.
echo   No data is sent anywhere - everything stays local.
echo.
echo  ============================================================
echo.

:: Navigate to script directory
cd /d "%~dp0"

:: ---- Step 1: Find or install Python ----
echo [1/5] Checking Python...

:: Check if previously downloaded embedded Python exists
set "PYTHON_DIR=%~dp0.python"
if exist "%PYTHON_DIR%\python.exe" (
    set "PYTHON=%PYTHON_DIR%\python.exe"
    goto :python_found
)

:: Try system Python - must verify it actually works (not Windows Store alias)
py -3 --version >nul 2>&1
if %ERRORLEVEL%==0 (
    set "PYTHON=py -3"
    goto :python_found
)

python3 --version >nul 2>&1
if %ERRORLEVEL%==0 (
    set "PYTHON=python3"
    goto :python_found
)

python --version >nul 2>&1
if %ERRORLEVEL%==0 (
    set "PYTHON=python"
    goto :python_found
)

:: No Python found - download embedded Python
echo   Python not found. Downloading portable Python...
set "PYTHON_DIR=%~dp0.python"
set "PYTHON=%PYTHON_DIR%\python.exe"

if exist "%PYTHON%" goto :python_found

mkdir "%PYTHON_DIR%" 2>nul

:: Download Python Embedded (3.12)
set "PYTHON_URL=https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip"
set "PYTHON_ZIP=%PYTHON_DIR%\python.zip"

echo   Downloading Python 3.12...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%PYTHON_ZIP%' }"
if %ERRORLEVEL% neq 0 (
    echo   ERROR: Could not download Python. Check your internet connection.
    pause
    exit /b 1
)

echo   Extracting Python...
powershell -Command "Expand-Archive -Path '%PYTHON_ZIP%' -DestinationPath '%PYTHON_DIR%' -Force"
del "%PYTHON_ZIP%" 2>nul

:: Enable pip in embedded Python (uncomment import site in python312._pth)
set "PTH_FILE=%PYTHON_DIR%\python312._pth"
if exist "%PTH_FILE%" (
    powershell -Command "(Get-Content '%PTH_FILE%') -replace '#import site','import site' | Set-Content '%PTH_FILE%'"
)

:: Install pip
echo   Installing pip...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%PYTHON_DIR%\get-pip.py' }"
"%PYTHON%" "%PYTHON_DIR%\get-pip.py" --no-warn-script-location >nul 2>&1

:python_found
echo   OK: Using %PYTHON%

:: ---- Step 2: Install dependencies ----
echo.
echo [2/5] Installing dependencies (first run takes a while)...

"%PYTHON%" -m ensurepip --upgrade >nul 2>&1

echo   Installing pip and setuptools...
"%PYTHON%" -m pip install --upgrade pip setuptools wheel 2>&1
if %ERRORLEVEL% neq 0 (
    echo   ERROR: pip upgrade failed. Continuing anyway...
)

echo   Installing playwright...
"%PYTHON%" -m pip install playwright 2>&1
if %ERRORLEVEL% neq 0 (
    echo   ERROR: Could not install playwright.
    pause
    exit /b 1
)

echo   Installing msteams-export...
"%PYTHON%" -m pip install --upgrade --force-reinstall --no-deps "%~dp0." 2>&1
if %ERRORLEVEL% neq 0 (
    echo   ERROR: Could not install msteams-export.
    echo   Full path: %~dp0.
    pause
    exit /b 1
)

echo   OK: Dependencies installed.

:: ---- Step 2b: Ensure Visual C++ Runtime is installed ----
:: greenlet (used by Playwright) needs vcruntime140_1.dll
"%PYTHON%" -c "import _greenlet" >nul 2>&1
if %ERRORLEVEL%==0 goto :vcok

echo.
echo   Visual C++ Runtime is missing (needed by Playwright).
echo   Downloading and installing Microsoft Visual C++ Redistributable...
set "VCREDIST=%PYTHON_DIR%\vc_redist.x64.exe"
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%VCREDIST%' }"
if not exist "%VCREDIST%" (
    echo   ERROR: Could not download Visual C++ Runtime.
    echo   Please install it manually from: https://aka.ms/vs/17/release/vc_redist.x64.exe
    pause
    exit /b 1
)
echo   Installing... (may ask for admin permission)
start /wait "" "%VCREDIST%" /install /quiet /norestart
del "%VCREDIST%" 2>nul
echo   OK: Visual C++ Runtime installed.

:vcok

:: ---- Step 3: Install Edge for Playwright ----
echo.
echo [3/5] Setting up Playwright browser...

"%PYTHON%" -m playwright install msedge >nul 2>&1

:: ---- Step 4: Login and Export ----
echo.
echo [4/5] Starting export...
echo.
echo   A browser window will open with Teams.
echo   If you are NOT already logged in, log in now.
echo   Close the browser window when ready.
echo.

set "PROFILE_DIR=%~dp0.profile"
set "EXPORT_DIR=%~dp0exports"

:: Open interactive session for login
"%PYTHON%" -m msteams_export session-open --browser edge --profile "%PROFILE_DIR%"

echo.
echo   Starting export of all chats.
echo   This can take 10-60 minutes depending on chat count.
echo.

:: Run the export
"%PYTHON%" -m msteams_export export all --outdir "%EXPORT_DIR%" --browser edge --profile "%PROFILE_DIR%" --skip-existing

if %ERRORLEVEL% neq 0 (
    echo.
    echo   WARNING: Export completed with errors. Trying to generate archive anyway...
)

:: ---- Step 5: Generate HTML Archive ----
echo.
echo [5/5] Generating HTML archive...

"%PYTHON%" -m msteams_export generate-html-archive "%EXPORT_DIR%" --output "%~dp0teams-archive.html"

if %ERRORLEVEL% neq 0 (
    echo   ERROR: Could not generate HTML archive.
    pause
    exit /b 1
)

:: ---- Step 6: Ask user where to save the archive ----
echo.
echo   Choose where to save the archive...

set "SAVE_PATH="
for /f "usebackq delims=" %%P in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; $d = New-Object System.Windows.Forms.SaveFileDialog; $d.Title = 'Save your Teams archive'; $d.FileName = 'teams-archive.html'; $d.Filter = 'HTML files (*.html)^|*.html'; $d.DefaultExt = 'html'; $d.AddExtension = $true; if ($d.ShowDialog() -eq 'OK') { Write-Output $d.FileName }"`) do set "SAVE_PATH=%%P"

set "FINAL_PATH=%~dp0teams-archive.html"
if defined SAVE_PATH (
    if /I not "%SAVE_PATH%"=="%~dp0teams-archive.html" (
        move /Y "%~dp0teams-archive.html" "%SAVE_PATH%" >nul 2>&1
        if exist "%SAVE_PATH%" (
            set "FINAL_PATH=%SAVE_PATH%"
            echo   Saved to: %SAVE_PATH%
        ) else (
            echo   Could not save to chosen location, keeping in current folder.
        )
    ) else (
        echo   Keeping archive in current folder.
    )
) else (
    echo   Keeping archive in current folder.
)

echo.
echo  ============================================================
echo.
echo   DONE!
echo.
echo   Your archive has been saved.
echo   Open it in a browser to view your chats.
echo.
echo  ============================================================
echo.
echo   Location: %FINAL_PATH%
echo.

:: Open the file and reveal in Explorer
start "" "%FINAL_PATH%"
explorer /select,"%FINAL_PATH%"

pause
