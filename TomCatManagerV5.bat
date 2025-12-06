@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - STATIC MENU
REM   Author: Fullstack Dev
REM   Description: Giao dien quan ly Tomcat (Khong tu dong refresh)
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
set "NEED_CONFIG=0"

REM --- 3. LOGIC KIEM TRA FILE CAU HINH (FIX LOI SYNTAX) ---

REM Truong hop 1: File data.json KHONG ton tai
IF NOT EXIST "%CONFIG_FILE%" goto :CASE_MISSING_CONFIG

REM Truong hop 2: File ton tai -> Doc va Kiem tra noi dung
call :LOAD_CONFIG_FROM_JSON
call :VALIDATE_TOMCAT_HOME
IF !errorlevel! NEQ 0 goto :CASE_INVALID_CONFIG

REM Truong hop 3: Moi thu OK -> Khoi tao bien va vao Menu
call :INIT_DEPENDENT_VARS
goto :MAIN_MENU

REM --- CAC LABEL XU LY LOI CAU HINH ---
:CASE_MISSING_CONFIG
    set "MSG_REASON=Chua tim thay file cau hinh data.json. Vui long thiet lap lan dau."
    set "NEED_CONFIG=1"
    goto :UPDATE_PATH_FLOW

:CASE_INVALID_CONFIG
    set "MSG_REASON=Duong dan trong data.json khong ton tai tren may nay."
    set "NEED_CONFIG=1"
    goto :UPDATE_PATH_FLOW


REM ==============================================================================
REM   MAIN MENU (STATIC)
REM ==============================================================================
:MAIN_MENU
cls
echo %cCyan%============================================================%cWhite%
echo    APACHE TOMCAT MANAGER %cGray%(Static Menu)%cWhite%
echo %cCyan%============================================================%cWhite%
echo.
echo    %cGray%Home:%cWhite% %TOMCAT_HOME%
echo    %cGray%Port:%cWhite% %TOMCAT_PORT%
echo.

REM --- Check Status (Chi check 1 lan khi load menu) ---
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
echo    1. Bat Server (Start)
echo    2. Tat Server (Stop)
echo    3. Khoi dong lai (Restart)
echo.
echo    4. Tao Project moi
echo    5. Mo thu muc Webapps
echo    6. Mo Localhost
echo    7. Cau hinh lai duong dan
echo    8. Refresh (Tai lai trang thai)
echo    0. Thoat
echo.
echo %cGray%------------------------------------------------------------%cWhite%

REM --- INPUT ---
set "opt="
set /p "opt=> Chon chuc nang [0-8]: "

if "%opt%"=="1" goto ACTION_START
if "%opt%"=="2" goto ACTION_STOP
if "%opt%"=="3" goto ACTION_RESTART
if "%opt%"=="4" goto ACTION_CREATE_PROJECT
if "%opt%"=="5" start "" "%WEBAPPS_FOLDER%" & goto MAIN_MENU
if "%opt%"=="6" start "" "%LOCALHOST_URL%" & goto MAIN_MENU
if "%opt%"=="7" goto UPDATE_PATH_FLOW
if "%opt%"=="8" goto MAIN_MENU
if "%opt%"=="0" exit

goto MAIN_MENU

REM ==============================================================================
REM   CORE FUNCTIONS
REM ==============================================================================

:LOAD_CONFIG_FROM_JSON
    for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "try {(Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json).TOMCAT_HOME} catch {}"`) do set "TOMCAT_HOME=%%A"
    for /f "usebackq delims=" %%B in (`powershell -NoProfile -Command "try {(Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json).TOMCAT_PORT} catch {}"`) do set "TOMCAT_PORT=%%B"
    if "%TOMCAT_PORT%"=="" set "TOMCAT_PORT=%DEFAULT_PORT%"
    exit /b 0

:SAVE_CONFIG_TO_JSON
    set "p_home=%~1"
    set "p_port=%~2"
    powershell -NoProfile -Command "$data = @{ TOMCAT_HOME = '%p_home%'; TOMCAT_PORT = '%p_port%' }; $data | ConvertTo-Json -Depth 2 | Set-Content '%CONFIG_FILE%'"
    exit /b 0

:VALIDATE_TOMCAT_HOME
    if "%TOMCAT_HOME%"=="" exit /b 1
    if not exist "%TOMCAT_HOME%\bin\catalina.bat" exit /b 1
    exit /b 0

:INIT_DEPENDENT_VARS
    set "WEBAPPS_FOLDER=%TOMCAT_HOME%\webapps"
    set "LOCALHOST_URL=http://localhost:%TOMCAT_PORT%"
    title Tomcat Manager - %TOMCAT_HOME%
    color 07
    exit /b 0

REM ==============================================================================
REM   ACTION HANDLERS
REM ==============================================================================

:UPDATE_PATH_FLOW
    cls
    color 0E
    echo %cYellow%============================================================%cWhite%
    echo      CAU HINH DUONG DAN TOMCAT
    echo %cYellow%============================================================%cWhite%
    echo.
    IF DEFINED MSG_REASON (
        echo %cRed%[THONG BAO] %MSG_REASON%%cWhite%
        echo.
        set "MSG_REASON="
    )
    echo Duong dan hien tai (trong file): "%TOMCAT_HOME%"
    echo.
    
    REM Hien thi prompt khac nhau (Bat buoc hay Tuy chon)
    if "%NEED_CONFIG%"=="1" (
        set /p "NEW_HOME=> Nhap Path moi: "
    ) else (
        set /p "NEW_HOME=> Nhap Path moi (0 de Quay lai): "
    )
    
    set "NEW_HOME=!NEW_HOME:"=!"
    
    REM Xu ly quay lai neu nhap 0 va khong phai dang cau hinh bat buoc
    if "!NEW_HOME!"=="0" (
        if "%NEED_CONFIG%"=="1" (
            echo.
            echo %cRed%[LOI] Ban can thiet lap duong dan truoc khi su dung!%cWhite%
            pause
            goto UPDATE_PATH_FLOW
        ) else (
            goto MAIN_MENU
        )
    )
    
    if not exist "!NEW_HOME!\bin\catalina.bat" (
        echo.
        echo %cRed%[LOI] Duong dan khong hop le!%cWhite%
        echo Khong tim thay \bin\catalina.bat tai duong dan nay.
        echo.
        pause
        goto UPDATE_PATH_FLOW
    )
    
    echo.
    set /p "NEW_PORT=> Nhap Port (Enter de dung %DEFAULT_PORT%): "
    if "!NEW_PORT!"=="" set "NEW_PORT=%DEFAULT_PORT%"
    
    call :SAVE_CONFIG_TO_JSON "!NEW_HOME!" "!NEW_PORT!"
    
    echo.
    echo %cGreen%[THANH CONG] Da cap nhat data.json!%cWhite%
    set "TOMCAT_HOME=!NEW_HOME!"
    set "TOMCAT_PORT=!NEW_PORT!"
    call :INIT_DEPENDENT_VARS
    pause
    goto MAIN_MENU

:ACTION_START
    if "%SERVER_STATUS%"=="RUNNING" (
        echo.
        echo %cYellow%[INFO] Server dang chay roi!%cWhite%
        pause
        goto MAIN_MENU
    )
    cd /d "%TOMCAT_HOME%\bin"
    echo.
    echo %cGreen%Starting Server...%cWhite%
    call catalina.bat version
    start "Apache Tomcat Log" call catalina.bat start
    REM Cho mot chut de server khoi dong roi quay lai menu check status
    timeout /t 5 >nul
    goto MAIN_MENU

:ACTION_STOP
    echo.
    echo %cRed%Stopping Server...%cWhite%
    cd /d "%TOMCAT_HOME%\bin"
    call shutdown.bat
    timeout /t 3 >nul
    goto MAIN_MENU

:ACTION_RESTART
    call :ACTION_STOP
    call :ACTION_START
    goto MAIN_MENU

:ACTION_CREATE_PROJECT
    echo.
    echo %cCyan%--- NEW PROJECT ---%cWhite%
    set /p projName="> Project Name: "
    if "%projName%"=="" goto MAIN_MENU
    if exist "%WEBAPPS_FOLDER%\%projName%" (
        echo %cRed%Project exists!%cWhite%
        pause
        goto MAIN_MENU
    )
    mkdir "%WEBAPPS_FOLDER%\%projName%"
    (
        echo ^<h1^>Project: %projName%^</h1^>
        echo ^<p^>Created via Tomcat Manager^</p^>
    ) > "%WEBAPPS_FOLDER%\%projName%\index.jsp"
    echo %cGreen%Created! Opening folder...%cWhite%
    timeout /t 1 >nul
    explorer "%WEBAPPS_FOLDER%\%projName%"
    goto MAIN_MENU
