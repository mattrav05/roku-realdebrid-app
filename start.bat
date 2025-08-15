@echo off
echo ========================================
echo   Real-Debrid Roku App Server
echo ========================================
echo.

REM Check if Node.js is installed
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if npm is installed
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: npm is not installed
    echo Please install npm
    pause
    exit /b 1
)

REM Check if package.json exists
if not exist "package.json" (
    echo Error: package.json not found
    echo Please run this script from the project directory
    pause
    exit /b 1
)

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo Installing Node.js dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo Error: Failed to install dependencies
        pause
        exit /b 1
    )
    echo.
)

REM Check if .env file exists
if not exist ".env" (
    echo Warning: .env file not found
    echo Please create a .env file with your Real-Debrid API key:
    echo REALDEBRID_API_KEY=your_api_key_here
    echo.
)

REM Get local IP address
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /c:"IPv4 Address"') do set LOCAL_IP=%%i
set LOCAL_IP=%LOCAL_IP: =%
if "%LOCAL_IP%"=="" set LOCAL_IP=localhost

echo Starting server...
echo Local IP: %LOCAL_IP%
echo Server will be available at:
echo   - Local: http://localhost:3000
echo   - Network: http://%LOCAL_IP%:3000
echo.
echo Update your Roku app config with: http://%LOCAL_IP%:3000
echo Press Ctrl+C to stop the server
echo ========================================
echo.

REM Start the server
npm start

pause