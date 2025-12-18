@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - FULLSTACK EDITION (v5.2 - Confirmation Support)
REM   Author: Nguyen Quoc Anh (NQA TECH) & Gemini
REM   Description: Batch script with case-insensitive y/N confirmation
REM ==============================================================================

REM --- 1. KHOI TAO MA MAU (ANSI COLORS) ---
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "cGreen=%ESC%[92m"
set "cRed=%ESC%[91m"
set "cYellow=%ESC%[93m"
set "cCyan=%ESC%[96m"
set "cWhite=%ESC%[0m"
set "cGray=%ESC%[90m"

REM --- 2. CAU HINH CO BAN ---
set "CONFIG_FILE=data.json"
set "DEFAULT_PORT=8080"
set "TOMCAT_PORT=%DEFAULT_PORT%"
set "TOMCAT_HOME="
set "SERVER_STATUS=UNKNOWN"
set "JAVA_STATUS=UNKNOWN"

IF NOT EXIST "%CONFIG_FILE%" goto CASE_MISSING_CONFIG
call :LOAD_CONFIG_FROM_JSON
call :VALIDATE_TOMCAT_HOME
IF !errorlevel! NEQ 0 goto CASE_INVALID_CONFIG
call :INIT_DEPENDENT_VARS
goto MAIN_MENU

:CASE_MISSING_CONFIG
    set "MSG_REASON=Chua tim thay file cau hinh data.json. Vui long thiet lap lan dau."
    goto UPDATE_PATH_FLOW

:CASE_INVALID_CONFIG
    set "MSG_REASON=Duong dan trong data.json khong ton tai tren may nay."
    goto UPDATE_PATH_FLOW

REM ==============================================================================
REM   MAIN MENU
REM ==============================================================================
:MAIN_MENU
cls
call :CHECK_JAVA_ENV
echo %cCyan%============================================================%cWhite%
echo    APACHE TOMCAT MANAGER %cYellow%(v5.2 - Confirmation Edition)%cWhite%
echo %cCyan%============================================================%cWhite%
echo.
echo    %cGray%Tomcat Home:%cWhite% %TOMCAT_HOME%
echo    %cGray%Tomcat Port:%cWhite% %TOMCAT_PORT%
if "%JAVA_STATUS%"=="OK" (
    echo    %cGray%Java Home:  %cWhite% %JAVA_HOME% %cGreen%[OK]%cWhite%
) else (
    echo    %cGray%Java Home:  %cWhite% %cRed%[MISSING] - Vui long kiem tra JDK!%cWhite%
)
echo.
netstat -ano | findStr ":%TOMCAT_PORT% " | findStr "LISTENING" >nul
if %errorlevel%==0 (
    set "SERVER_STATUS=RUNNING"
    echo    STATUS: %cGreen%[  ONLINE  ] %cWhite% Server is running on port %TOMCAT_PORT%
) else (
    set "SERVER_STATUS=STOPPED"
    echo    STATUS: %cRed%[  OFFLINE ] %cWhite% Server is stopped
)
echo.
echo %cGray%------------------------------------------------------------%cWhite%
echo.
echo    1. Bat Server (Start)       4. Tao Project moi (Auto Structure)
echo    2. Tat Server (Stop)        5. %cYellow%Quan ly Project (Build Servlet, JSP)%cWhite%
echo    3. Khoi dong lai (Restart)  6. Mo thu muc Webapps
echo.
echo    7. Mo Localhost (Root)      8. Cau hinh lai duong dan Tomcat
echo    0. Thoat
echo.
echo %cGray%------------------------------------------------------------%cWhite%

set "opt="
set /p "opt=> Chon chuc nang: "
if "%opt%"=="1" goto ACTION_START
if "%opt%"=="2" goto ACTION_STOP
if "%opt%"=="3" goto ACTION_RESTART
if "%opt%"=="4" goto ACTION_CREATE_PROJECT
if "%opt%"=="5" goto ACTION_SCAN_OPEN
if "%opt%"=="6" start "" "%WEBAPPS_FOLDER%" & goto MAIN_MENU
if "%opt%"=="7" start "" "%LOCALHOST_URL%" & goto MAIN_MENU
if "%opt%"=="8" goto UPDATE_PATH_FLOW
if "%opt%"=="0" exit
goto MAIN_MENU

REM ==============================================================================
REM   PROJECT ACTIONS
REM ==============================================================================

:ACTION_SCAN_OPEN
    cls
    echo %cCyan%--- CHON PROJECT DE LAM VIEC ---%cWhite%
    set "count=0"
    for /d %%D in ("%WEBAPPS_FOLDER%\*") do (
        set /a count+=1
        set "PROJ[!count!]=%%~nxD"
        echo    !count!. %%~nxD
    )
    if !count! EQU 0 ( echo %cRed%Khong tim thay project.%cWhite% & pause & goto MAIN_MENU )
    echo    0. Quay lai
    set /p "pChoice=> Chon: "
    if "%pChoice%"=="0" goto MAIN_MENU
    set "SELECTED_PROJ=!PROJ[%pChoice%]!"
    goto PROJ_DETAIL_MENU

:PROJ_DETAIL_MENU
    cls
    echo %cCyan%--- PROJECT: %cYellow%!SELECTED_PROJ!%cWhite% ---
    echo.
    echo    1. Mo Browser (URL)         4. Mo VS Code
    echo    2. %cGreen%Build Java Servlet%cWhite%      5. Mo Explorer
    echo    3. Quan ly file JSP         0. Quay lai
    echo.
    set /p "pdOpt=> Lua chon: "
    if "%pdOpt%"=="1" start "" "%LOCALHOST_URL%/!SELECTED_PROJ!" & goto PROJ_DETAIL_MENU
    if "%pdOpt%"=="2" goto ACTION_SELECT_JAVA_FILE
    if "%pdOpt%"=="3" goto SCAN_JSP_FILES
    if "%pdOpt%"=="4" call code "%WEBAPPS_FOLDER%\!SELECTED_PROJ!" & goto PROJ_DETAIL_MENU
    if "%pdOpt%"=="5" start "" "%WEBAPPS_FOLDER%\!SELECTED_PROJ!" & goto PROJ_DETAIL_MENU
    if "%pdOpt%"=="0" goto ACTION_SCAN_OPEN
    goto PROJ_DETAIL_MENU

:ACTION_SELECT_JAVA_FILE
    cls
    echo %cYellow%--- LUA CHON FILE JAVA DE BUILD ---%cWhite%
    set "PROJ_PATH=%WEBAPPS_FOLDER%\!SELECTED_PROJ!"
    set "jFileCount=0"
    for /r "%PROJ_PATH%" %%f in (*.java) do (
        set /a jFileCount+=1
        set "JAVA_F[!jFileCount!]=%%f"
        set "JAVA_N[!jFileCount!]=%%~nxf"
        echo    !jFileCount!. %%~nxf
    )
    if !jFileCount! EQU 0 ( echo %cRed%Khong tim thay file .java.%cWhite% & pause & goto PROJ_DETAIL_MENU )
    echo.
    echo    A. Build TAT CA (All)
    echo    0. Huy bo
    echo.
    set /p "fChoice=> Nhap so thu tu (hoac A): "
    if /I "%fChoice%"=="0" goto PROJ_DETAIL_MENU
    if /I "%fChoice%"=="A" (
        call :CONFIRM_DIALOG "Ban co chac muon build TAT CA file Java?"
        if errorlevel 1 goto ACTION_SELECT_JAVA_FILE
        goto ACTION_BUILD_ALL
    )
    set "SEL_FILE_PATH=!JAVA_F[%fChoice%]!"
    set "SEL_FILE_NAME=!JAVA_N[%fChoice%]!"
    if "!SEL_FILE_PATH!"=="" ( echo %cRed%Loi lua chon!%cWhite% & pause & goto ACTION_SELECT_JAVA_FILE )
    call :COMPILE_LOGIC "!SEL_FILE_PATH!" "!SEL_FILE_NAME!"
    pause & goto PROJ_DETAIL_MENU

:ACTION_BUILD_ALL
    echo %cYellow%Dang build tat ca file .java...%cWhite%
    for /L %%i in (1,1,!jFileCount!) do ( call :COMPILE_LOGIC "!JAVA_F[%%i]!" "!JAVA_N[%%i]!" )
    pause & goto PROJ_DETAIL_MENU

:COMPILE_LOGIC
    set "F_PATH=%~1"
    set "F_NAME=%~2"
    set "BIN_PATH=%WEBAPPS_FOLDER%\!SELECTED_PROJ!\WEB-INF\classes"
    if not exist "%BIN_PATH%" mkdir "%BIN_PATH%"
    echo %cGray%Compiling: %F_NAME%...%cWhite%
    "%JAVA_HOME%\bin\javac" -encoding UTF-8 -cp "%TOMCAT_HOME%\lib\*;%WEBAPPS_FOLDER%\!SELECTED_PROJ!\WEB-INF\lib\*" -d "%BIN_PATH%" "%F_PATH%"
    if !errorlevel! EQU 0 ( echo %cGreen%[SUCCESS]%cWhite% %F_NAME% ) else ( echo %cRed%[FAILED]%cWhite% %F_NAME% )
    exit /b

REM ==============================================================================
REM   SYSTEM CORE
REM ==============================================================================

:CONFIRM_DIALOG
    set "conf="
    set /p "conf=%cYellow%[?] %~1 (y/N): %cWhite%"
    if /I "%conf%"=="y" exit /b 0
    echo %cGray%Thao tac da duoc huy.%cWhite%
    exit /b 1

:CHECK_JAVA_ENV
    if "%JAVA_HOME%"=="" ( set "JAVA_STATUS=MISSING" & exit /b 1 )
    if not exist "%JAVA_HOME%\bin\java.exe" ( set "JAVA_STATUS=MISSING" & exit /b 1 )
    set "JAVA_STATUS=OK"
    exit /b 0

:LOAD_CONFIG_FROM_JSON
    for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "try {(Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json).TOMCAT_HOME} catch {}"`) do set "TOMCAT_HOME=%%A"
    for /f "usebackq delims=" %%B in (`powershell -NoProfile -Command "try {(Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json).TOMCAT_PORT} catch {}"`) do set "TOMCAT_PORT=%%B"
    if "%TOMCAT_PORT%"=="" set "TOMCAT_PORT=%DEFAULT_PORT%"
    exit /b 0

:SAVE_CONFIG_TO_JSON
    powershell -NoProfile -Command "$data = @{ TOMCAT_HOME = '%~1'; TOMCAT_PORT = '%~2' }; $data | ConvertTo-Json -Depth 2 | Set-Content '%CONFIG_FILE%'"
    exit /b 0

:VALIDATE_TOMCAT_HOME
    if "%TOMCAT_HOME%"=="" exit /b 1
    if not exist "%TOMCAT_HOME%\bin\catalina.bat" exit /b 1
    exit /b 0

:INIT_DEPENDENT_VARS
    set "WEBAPPS_FOLDER=%TOMCAT_HOME%\webapps"
    set "LOCALHOST_URL=http://localhost:%TOMCAT_PORT%"
    title Tomcat Manager - %TOMCAT_HOME%
    exit /b 0

:UPDATE_PATH_FLOW
    cls
    echo %cYellow%--- CAU HINH TOMCAT ---%cWhite%
    set /p "NEW_HOME=> Nhap Path Tomcat (VD: C:\tomcat): "
    set "NEW_HOME=!NEW_HOME:"=!"
    if not exist "!NEW_HOME!\bin\catalina.bat" ( echo Path loi! & pause & goto UPDATE_PATH_FLOW )
    call :SAVE_CONFIG_TO_JSON "!NEW_HOME!" "%DEFAULT_PORT%"
    set "TOMCAT_HOME=!NEW_HOME!" & call :INIT_DEPENDENT_VARS
    goto MAIN_MENU

:ACTION_START
    cd /d "%TOMCAT_HOME%\bin" & start catalina.bat run
    goto MAIN_MENU

:ACTION_STOP
    call :CONFIRM_DIALOG "Ban co chac chan muon tat Server?"
    if errorlevel 1 goto MAIN_MENU
    cd /d "%TOMCAT_HOME%\bin" & call shutdown.bat
    goto MAIN_MENU

:ACTION_RESTART
    call :CONFIRM_DIALOG "Ban co chac chan muon khoi dong lai Server?"
    if errorlevel 1 goto MAIN_MENU
    call :ACTION_STOP
    timeout /t 2 >nul
    goto ACTION_START