@echo off
echo ========================================
echo   Real-Debrid Roku Local Server
echo ========================================
echo.
echo This server runs on your local network only
echo No cloud deployment needed!
echo.
echo Your Roku must be on the same WiFi network
echo.

REM Get local IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set IP=%%a
    goto :found
)
:found
set IP=%IP: =%

echo Server will be available at:
echo   http://%IP%:3000
echo.
echo Configure your Roku app with this URL
echo.
echo Starting server...
npm start