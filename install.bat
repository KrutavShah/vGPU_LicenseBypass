@echo off
REM Wrapper to run a PowerShell script as administrator without changing ExecutionPolicy.
REM I feel like this shouldn't work - why else have ExecutionPolicy? - but it does, soooo...
REM This should pass through arguments untouched, but cmd argument parsing is iffy; no promises.

setlocal
set ps_script_name=Set-VGpuEternalTrial.ps1
goto check_admin

REM Check if we have admin rights by running 'net session' and checking the return code.
REM Works on everything from Windows XP thru Windows 11.
:check_admin
    echo Checking for admin rights...
    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Admin permissions available, proceeding with installation.
        goto get_script_dir
    ) else (
        echo Failure: This script requires admin rights to function.
        echo Please right-click 'install.bat' and click 'Run as administrator'.
        pause
        exit /b 1
    )

REM Get the directory this file is located in. Resolves relative paths.
:get_script_dir
    echo Getting script path...
    pushd %~dp0
        set script_dir=%CD%
    popd
    echo Script directory: %script_dir%
    goto run_ps_script

REM Actually execute the script.
:run_ps_script
    echo "Running PowerShell script %script_dir%\%ps_script_name% with args %*"
    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%script_dir%\%ps_script_name%" %*
    exit /b %errorlevel%
