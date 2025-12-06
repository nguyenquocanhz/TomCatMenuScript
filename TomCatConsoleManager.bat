@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - STATIC MENU
REM   Author: Fullstack Dev
REM   Description: Giao dien quan ly Tomcat (Download Version Selection)
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

REM --- 3. LOGIC KIEM TRA FILE CAU HINH ---

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

REM --- Check Status ---
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
echo    9. Download va Cai dat Tomcat (Moi)
echo    0. Thoat
echo.
echo %cGray%------------------------------------------------------------%cWhite%

REM --- INPUT ---
set "opt="
set /p "opt=> Chon chuc nang [0-9]: "

if "%opt%"=="1" goto ACTION_START
if "%opt%"=="2" goto ACTION_STOP
if "%opt%"=="3" goto ACTION_RESTART
if "%opt%"=="4" goto ACTION_CREATE_PROJECT
if "%opt%"=="5" start "" "%WEBAPPS_FOLDER%" & goto MAIN_MENU
if "%opt%"=="6" start "" "%LOCALHOST_URL%" & goto MAIN_MENU
if "%opt%"=="7" goto UPDATE_PATH_FLOW
if "%opt%"=="8" goto MAIN_MENU
if "%opt%"=="9" goto ACTION_DOWNLOAD_TOMCAT
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
    
    if "%NEED_CONFIG%"=="1" (
        echo [Goi y] Ban co the nhap 9 de tai Tomcat tu dong.
        set /p "NEW_HOME=> Nhap Path moi (hoac 9 de Download): "
    ) else (
        set /p "NEW_HOME=> Nhap Path moi (0 de Quay lai, 9 de Download): "
    )
    
    set "NEW_HOME=!NEW_HOME:"=!"
    
    REM Logic Download/Quay lai
    if "!NEW_HOME!"=="9" goto ACTION_DOWNLOAD_TOMCAT
    if "!NEW_HOME!"=="0" (
        if "%NEED_CONFIG%"=="1" (
            echo %cRed%[LOI] Ban can thiet lap duong dan truoc!%cWhite%
            pause
            goto UPDATE_PATH_FLOW
        ) else (
            goto MAIN_MENU
        )
    )
    
    if not exist "!NEW_HOME!\bin\catalina.bat" (
        echo.
        echo %cRed%[LOI] Duong dan khong hop le!%cWhite%
        echo Khong tim thay \bin\catalina.bat
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

:ACTION_DOWNLOAD_TOMCAT
    cls
    echo %cCyan%============================================================%cWhite%
    echo      CHON PHIEN BAN TOMCAT DE TAI
    echo %cCyan%============================================================%cWhite%
    echo.
    echo    1. Tomcat 11 (Latest Stable - 11.0.2)
    echo    2. Tomcat 10 (Current Stable - 10.1.34)
    echo    3. Tomcat 9  (LTS Pho bien - 9.0.98)
    echo    4. Tomcat 8  (Legacy - 8.5.100)
    echo    5. Nhap version thu cong (Custom)
    echo    0. Quay lai
    echo.
    
    set /p "vChoice=> Chon phien ban [1-5]: "
    
    if "%vChoice%"=="0" goto MAIN_MENU
    
    REM --- Logic set URL ---
    set "DL_VER="
    set "DL_MAJOR="
    
    if "%vChoice%"=="1" (
        set "DL_VER=11.0.2"
        set "DL_MAJOR=11"
    )
    if "%vChoice%"=="2" (
        set "DL_VER=10.1.34"
        set "DL_MAJOR=10"
    )
    if "%vChoice%"=="3" (
        set "DL_VER=9.0.98"
        set "DL_MAJOR=9"
    )
    if "%vChoice%"=="4" (
        set "DL_VER=8.5.100"
        set "DL_MAJOR=8"
    )
    if "%vChoice%"=="5" (
        echo.
        echo Hay nhap Major Version (VD: 9)
        set /p "DL_MAJOR=> Major Ver: "
        echo.
        echo Hay nhap Full Version (VD: 9.0.98)
        set /p "DL_VER=> Full Ver: "
    )
    
    if "!DL_VER!"=="" goto ACTION_DOWNLOAD_TOMCAT
    
    REM Tao URL dong
    set "DL_URL=https://dlcdn.apache.org/tomcat/tomcat-!DL_MAJOR!/v!DL_VER!/bin/apache-tomcat-!DL_VER!-windows-x64.zip"
    
    echo.
    echo --------------------------------------------------
    echo DANG CHUAN BI TAI TOMCAT !DL_VER!
    echo URL: !DL_URL!
    echo --------------------------------------------------
    echo.
    echo Nhap thu muc ban muon cai dat Tomcat. (VD: D:\Tools)
    echo Script se tao folder va giai nen tai do.
    echo.
    
    set /p "INSTALL_DIR=> Install Location: "
    set "INSTALL_DIR=!INSTALL_DIR:"=!"
    IF "!INSTALL_DIR!"=="" goto MAIN_MENU
    
    if not exist "!INSTALL_DIR!" mkdir "!INSTALL_DIR!"
    
    echo.
    echo %cYellow%[1/2] Dang tai xuong... (Vui long cho)%cWhite%
    
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '!DL_URL!' -OutFile '!INSTALL_DIR!\tomcat.zip'"
    
    if not exist "!INSTALL_DIR!\tomcat.zip" (
        echo.
        echo %cRed%[LOI] Download that bai!%cWhite%
        echo Link co the da het han hoac khong ton tai.
        echo URL: !DL_URL!
        pause
        goto ACTION_DOWNLOAD_TOMCAT
    )
    
    echo %cYellow%[2/2] Dang giai nen...%cWhite%
    powershell -Command "Expand-Archive -Path '!INSTALL_DIR!\tomcat.zip' -DestinationPath '!INSTALL_DIR!' -Force"
    del "!INSTALL_DIR!\tomcat.zip"
    
    for /d %%D in ("!INSTALL_DIR!\apache-tomcat-*") do (
        set "DETECTED_HOME=%%D"
    )
    
    echo.
    echo %cGreen%[THANH CONG] Da cai dat tai: !DETECTED_HOME!%cWhite%
    
    call :SAVE_CONFIG_TO_JSON "!DETECTED_HOME!" "%DEFAULT_PORT%"
    set "TOMCAT_HOME=!DETECTED_HOME!"
    set "TOMCAT_PORT=%DEFAULT_PORT%"
    set "NEED_CONFIG=0"
    
    call :INIT_DEPENDENT_VARS
    echo Da cap nhat cau hinh tu dong.
    pause
    goto MAIN_MENU
