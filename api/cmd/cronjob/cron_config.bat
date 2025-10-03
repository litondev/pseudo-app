@echo off
REM Log Cleanup Scheduled Task Configuration Script for Windows
REM This script sets up a monthly scheduled task to clean up .log files

set SCRIPT_DIR=%~dp0
set CRONJOB_SCRIPT=%SCRIPT_DIR%log_cleanup.go
set CRON_LOG_FILE=%SCRIPT_DIR%..\..\logger\cron_cleanup.log
set TASK_NAME=LogCleanupMonthly

echo Setting up monthly log cleanup scheduled task...
echo Script location: %CRONJOB_SCRIPT%
echo Log file: %CRON_LOG_FILE%

REM Create the scheduled task
REM Run on the 1st day of every month at 2:00 AM
schtasks /create /tn "%TASK_NAME%" /tr "cmd /c cd /d \"%SCRIPT_DIR%\" && go run log_cleanup.go >> \"%CRON_LOG_FILE%\" 2>&1" /sc monthly /d 1 /st 02:00 /f

if %errorlevel% equ 0 (
    echo Scheduled task configured successfully!
    echo The log cleanup will run monthly on the 1st day at 2:00 AM
    echo.
    echo To verify the scheduled task, run: schtasks /query /tn "%TASK_NAME%"
    echo To remove the scheduled task, run: schtasks /delete /tn "%TASK_NAME%" /f
    echo.
    echo Manual execution: cd "%SCRIPT_DIR%" && go run log_cleanup.go
) else (
    echo Failed to create scheduled task. Please run as Administrator.
)

pause