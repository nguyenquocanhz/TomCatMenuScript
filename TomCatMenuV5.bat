@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - FULLSTACK EDITION (v5.0 - Servlet Support)
REM   Author: Nguyen Quoc Anh (NQA TECH) & Gemini
REM   Description: Batch script to manage Tomcat & Auto-build Java Servlets
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
set "NEED_CONFIG=0"

IF NOT EXIST "%CONFIG_FILE%" goto CASE_MISSING_CONFIG
call :LOAD_CONFIG_FROM_JSON
call :VALIDATE_TOMCAT_HOME
IF !errorlevel! NEQ 0 goto CASE_INVALID_CONFIG
call :INIT_DEPENDENT_VARS
goto MAIN_MENU

:CASE_MISSING_CONFIG
    set "MSG_REASON=Chua tim thay file cau hinh data.json. Vui long thiet lap lan dau."
    set "NEED_CONFIG=1"
    goto UPDATE_PATH_FLOW

:CASE_INVALID_CONFIG
    set "MSG_REASON=Duong dan trong data.json khong ton tai tren may nay."
    set "NEED_CONFIG=1"
    goto UPDATE_PATH_FLOW

REM ==============================================================================
REM   MAIN MENU
REM ==============================================================================
:MAIN_MENU
cls
call :CHECK_JAVA_ENV
echo %cCyan%============================================================%cWhite%
echo    APACHE TOMCAT MANAGER %cYellow%(v5.0 - Servlet Edition)%cWhite%
echo %cCyan%============================================================%cWhite%
echo.
echo    %cGray%Tomcat Home:%cWhite% %TOMCAT_HOME%
echo    %cGray%Tomcat Port:%cWhite% %TOMCAT_PORT%
if "%JAVA_STATUS%"=="OK" (
    echo    %cGray%Java Home:  %cWhite% %JAVA_HOME% %cGreen%[OK]%cWhite%
) else (
    echo    %cGray%Java Home:  %cWhite% %cRed%[MISSING] - Can not start server!%cWhite%
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
echo    9. Download/Cai dat Tomcat  J. Download/Cai dat Oracle JDK
echo    V. Install VS Code          0. Thoat
echo.
echo %cGray%------------------------------------------------------------%cWhite%

set "opt="
set /p "opt=> Chon chuc nang: "
if /I "%opt%"=="J" goto ACTION_INSTALL_JAVA
if /I "%opt%"=="V" goto ACTION_INSTALL_VSCODE
if "%opt%"=="1" goto ACTION_START
if "%opt%"=="2" goto ACTION_STOP
if "%opt%"=="3" goto ACTION_RESTART
if "%opt%"=="4" goto ACTION_CREATE_PROJECT
if "%opt%"=="5" goto ACTION_SCAN_OPEN
if "%opt%"=="6" start "" "%WEBAPPS_FOLDER%" & goto MAIN_MENU
if "%opt%"=="7" start "" "%LOCALHOST_URL%" & goto MAIN_MENU
if "%opt%"=="8" goto UPDATE_PATH_FLOW
if "%opt%"=="9" goto ACTION_DOWNLOAD_TOMCAT
if "%opt%"=="0" exit
goto MAIN_MENU

REM ==============================================================================
REM   CORE FUNCTIONS
REM ==============================================================================

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

REM ==============================================================================
REM   PROJECT ACTIONS
REM ==============================================================================

:ACTION_CREATE_PROJECT
    echo. & echo %cCyan%--- NEW SERVLET PROJECT ---%cWhite%
    set /p projName="> Project Name: "
    if "%projName%"=="" goto MAIN_MENU
    set "TARGET_P=%WEBAPPS_FOLDER%\%projName%"
    if exist "%TARGET_P%" ( echo %cRed%Project exists!%cWhite% & pause & goto MAIN_MENU )
    
    mkdir "%TARGET_P%"
    mkdir "%TARGET_P%\WEB-INF\classes"
    mkdir "%TARGET_P%\WEB-INF\lib"
    
    (
    echo ^<h1^>Project: %projName%^</h1^>
    echo ^<p^>Created via Tomcat Manager Pro^</p^>
    echo ^<a href="hello"^>Test Hello Servlet^</a^>
    ) > "%TARGET_P%\index.jsp"
    
    echo %cGreen%[OK] Project structure created!%cWhite%
    explorer "%TARGET_P%"
    goto MAIN_MENU

:ACTION_SCAN_OPEN
    cls
    echo %cCyan%============================================================%cWhite%
    echo      CHON PROJECT DE LAM VIEC
    echo %cCyan%============================================================%cWhite%
    set "count=0"
    for /d %%D in ("%WEBAPPS_FOLDER%\*") do (
        set /a count+=1
        set "PROJ[!count!]=%%~nxD"
        echo    !count!. %%~nxD
    )
    echo.
    if !count! EQU 0 ( echo %cRed%Khong tim thay project.%cWhite% & pause & goto MAIN_MENU )
    echo    0. Quay lai
    set /p "pChoice=> Chon: "
    if "%pChoice%"=="0" goto MAIN_MENU
    set "SELECTED_PROJ=!PROJ[%pChoice%]!"
    goto PROJ_DETAIL_MENU

:PROJ_DETAIL_MENU
    cls
    echo %cCyan%============================================================%cWhite%
    echo      PROJECT: %cYellow%!SELECTED_PROJ!%cWhite%
    echo %cCyan%============================================================%cWhite%
    echo.
    echo    1. Mo Trang Chu (Browser)
    echo    2. Compile Servlets
    echo    3. Quan ly file JSP
    echo    4. Mo VS Code
    echo    5. Mo Explorer
    echo    0. Quay lai
    echo.
    set /p "pdOpt=> Lua chon: "
    if "%pdOpt%"=="1" start "" "%LOCALHOST_URL%/!SELECTED_PROJ!" & goto PROJ_DETAIL_MENU
    if "%pdOpt%"=="2" goto ACTION_BUILD_SERVLET
    if "%pdOpt%"=="3" goto SCAN_JSP_FILES
    if "%pdOpt%"=="4" call code "%WEBAPPS_FOLDER%\!SELECTED_PROJ!" & goto PROJ_DETAIL_MENU
    if "%pdOpt%"=="5" start "" "%WEBAPPS_FOLDER%\!SELECTED_PROJ!" & goto PROJ_DETAIL_MENU
    if "%pdOpt%"=="0" goto ACTION_SCAN_OPEN
    goto PROJ_DETAIL_MENU

:ACTION_BUILD_SERVLET
    cls
    echo %cYellow%--- COMPILING SERVLETS ---%cWhite%
    set "PROJ_PATH=%WEBAPPS_FOLDER%\!SELECTED_PROJ!"
    set "BIN_PATH=%PROJ_PATH%\WEB-INF\classes"
    if not exist "%BIN_PATH%" mkdir "%BIN_PATH%"
    
    echo Dang quet file .java trong: !SELECTED_PROJ!
    set "foundJava=0"
    for /r "%PROJ_PATH%" %%f in (*.java) do (
        set "foundJava=1"
        echo %cGray%Compiling: %%~nxf...%cWhite%
        javac -cp "%TOMCAT_HOME%\lib\*;%PROJ_PATH%\WEB-INF\lib\*" -d "%BIN_PATH%" "%%f"
        if !errorlevel! EQU 0 (
            echo %cGreen%[SUCCESS] %%~nxf%cWhite%
        ) else (
            echo %cRed%[FAILED] %%~nxf%cWhite%
        )
    )
    if %foundJava% EQU 0 echo %cRed%Khong tim thay file .java nao.%cWhite%
    echo.
    pause
    goto PROJ_DETAIL_MENU

:SCAN_JSP_FILES
    cls
    echo %cCyan%--- JSP FILES: !SELECTED_PROJ! ---%cWhite%
    set "jCount=0"
    set "TARGET_DIR=%WEBAPPS_FOLDER%\!SELECTED_PROJ!"
    for /R "%TARGET_DIR%" %%f in (*.jsp) do (
        set /a jCount+=1
        set "FULL_PATH_!jCount!=%%f"
        set "REL_PATH=%%f"
        set "REL_PATH=!REL_PATH:%WEBAPPS_FOLDER%\=!"
        set "REL_PATH=!REL_PATH:\=/!"
        set "URL_PATH_!jCount!=!REL_PATH!"
        echo    !jCount!. %%~nxf %cGray%(!REL_PATH!^)%cWhite%
    )
    echo.
    if !jCount! EQU 0 ( pause & goto PROJ_DETAIL_MENU )
    echo    0. Quay lai
    set /p "jOpt=> Chon: "
    if "%jOpt%"=="0" goto PROJ_DETAIL_MENU
    start "" "%LOCALHOST_URL%/!URL_PATH_%jOpt%!"
    goto SCAN_JSP_FILES

REM ==============================================================================
REM   SYSTEM ACTIONS (KEEP ORIGINAL LOGIC)
REM ==============================================================================

:UPDATE_PATH_FLOW
    cls
    color 0E
    echo %cYellow%--- CAU HINH TOMCAT ---%cWhite%
    if defined MSG_REASON echo %cRed%[!] %MSG_REASON%%cWhite%
    set /p "NEW_HOME=> Nhap Path Tomcat (VD: C:\tomcat): "
    set "NEW_HOME=!NEW_HOME:"=!"
    if not exist "!NEW_HOME!\bin\catalina.bat" ( echo Path loi! & pause & goto UPDATE_PATH_FLOW )
    call :SAVE_CONFIG_TO_JSON "!NEW_HOME!" "%DEFAULT_PORT%"
    set "TOMCAT_HOME=!NEW_HOME!" & call :INIT_DEPENDENT_VARS
    goto MAIN_MENU

:ACTION_START
    if "%SERVER_STATUS%"=="RUNNING" ( echo Server is running! & pause & goto MAIN_MENU )
    cd /d "%TOMCAT_HOME%\bin" & call catalina.bat start
    timeout /t 5 >nul & goto MAIN_MENU

:ACTION_STOP
    cd /d "%TOMCAT_HOME%\bin" & call shutdown.bat
    timeout /t 3 >nul & goto MAIN_MENU

:ACTION_RESTART
    call :ACTION_STOP
    call :ACTION_START
    goto MAIN_MENU

:ACTION_INSTALL_JAVA
    cls
    echo %cCyan%--- INSTALL JDK ---%cWhite%
    set /p "J_VER=> Version (17/21/25): "
    set /p "J_DIR=> Location: "
    set "J_DIR=!J_DIR:"=!"
    mkdir "!J_DIR!" 2>nul
    set "URL=https://download.oracle.com/java/!J_VER!/latest/jdk-!J_VER!_windows-x64_bin.zip"
    powershell -Command "Invoke-WebRequest -Uri '!URL!' -OutFile '!J_DIR!\jdk.zip'"
    powershell -Command "Expand-Archive -Path '!J_DIR!\jdk.zip' -DestinationPath '!J_DIR!' -Force"
    del "!J_DIR!\jdk.zip"
    echo Install Done! & pause & goto MAIN_MENU

:ACTION_INSTALL_VSCODE
    winget install -e --id Microsoft.VisualStudioCode --source winget
    pause & goto MAIN_MENU