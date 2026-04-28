@echo off
title CaraVax
echo.
echo  =============================
echo   CaraVax wird gestartet...
echo  =============================
echo.
cd /d "%~dp0"
venv\Scripts\python.exe app.py
pause
