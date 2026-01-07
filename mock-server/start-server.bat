@echo off
echo ========================================
echo   myEvent Mock Server
echo ========================================
echo.
echo Starting JSON Server on http://192.168.86.23:3000
echo.
echo Press Ctrl+C to stop the server
echo.
json-server --watch db.json --routes routes.json --host 0.0.0.0 --port 3000
