@echo off
REM ==========================================
REM        APACHE TOMCAT CONTROL MENU
REM ==========================================

SET TOMCAT_HOME=C:\tomcat
SET WEBAPPS_FOLDER=%TOMCAT_HOME%\webapps
SET LOCALHOST_URL=http://localhost:8080

:MENU
cls
echo ==========================================
echo        APACHE TOMCAT CONTROL PANEL
echo ==========================================
echo.
echo   1. Start Tomcat
echo   2. Stop Tomcat
echo   3. Restart Tomcat
echo   4. Open Webapps Root Folder
echo   5. Open Localhost (Port 8080)
echo   0. Exit
echo.
set /p choice=Please select an option: 

IF "%choice%"=="1" GOTO START
IF "%choice%"=="2" GOTO STOP
IF "%choice%"=="3" GOTO RESTART
IF "%choice%"=="4" GOTO OPEN_WEBAPPS
IF "%choice%"=="5" GOTO OPEN_LOCALHOST
IF "%choice%"=="0" EXIT

echo Invalid selection. Try again.
pause
GOTO MENU


:START
echo ------------------------------------------
echo Starting Apache Tomcat...
echo ------------------------------------------
cd /d "%TOMCAT_HOME%\bin"
call catalina.bat start
echo Tomcat started successfully.
pause
GOTO MENU


:STOP
echo ------------------------------------------
echo Stopping Apache Tomcat...
echo ------------------------------------------
cd /d "%TOMCAT_HOME%\bin"
call shutdown.bat
echo Tomcat stopped successfully.
pause
GOTO MENU


:RESTART
echo ------------------------------------------
echo Restarting Apache Tomcat...
echo ------------------------------------------
cd /d "%TOMCAT_HOME%\bin"
call shutdown.bat
echo Waiting for Tomcat to stop...
timeout /t 3 >nul
call catalina.bat start
echo Tomcat restarted successfully.
pause
GOTO MENU


:OPEN_WEBAPPS
echo ------------------------------------------
echo Opening Root Folder: %WEBAPPS_FOLDER%
echo ------------------------------------------
start "" "%WEBAPPS_FOLDER%"
pause
GOTO MENU


:OPEN_LOCALHOST
echo ------------------------------------------
echo Opening Localhost: %LOCALHOST_URL%
echo ------------------------------------------
start "" "%LOCALHOST_URL%"
pause
GOTO MENU
