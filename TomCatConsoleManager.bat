@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - FULLSTACK EDITION (v4.5)
REM   Author: Nguyen Quoc Anh (NQA TECH)
REM   Description: A simple Windows Batch script to manage Apache Tomcat server
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

REM --- 3. LOGIC KIEM TRA FILE CAU HINH ---
REM [FIX] Xoa dau ':' thua trong lenh goto
IF NOT EXIST "%CONFIG_FILE%" goto CASE_MISSING_CONFIG

call :LOAD_CONFIG_FROM_JSON
call :VALIDATE_TOMCAT_HOME
IF !errorlevel! NEQ 0 goto CASE_INVALID_CONFIG

call :INIT_DEPENDENT_VARS
goto MAIN_MENU

REM --- LABEL XU LY LOI CAU HINH ---
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
echo    APACHE TOMCAT MANAGER %cGray%(v3.5 - Stable)%cWhite%
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

REM --- Check Server Status ---
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
echo    %cYellow%5. Quan ly Project (Scan, Open, Edit)%cWhite%
echo    6. Mo thu muc Webapps
echo    7. Mo Localhost (Root)
echo    8. Cau hinh lai duong dan Tomcat
echo    9. Download va Cai dat Tomcat (Moi)
echo.
echo    J. Download va Cai dat Oracle JDK
echo    %cYellow%V. Download va Cai dat VS Code (Winget)%cWhite%
echo    0. Thoat
echo.
echo %cGray%------------------------------------------------------------%cWhite%

REM --- INPUT ---
set "opt="
set /p "opt=> Chon chuc nang [0-9, J, V]: "

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

:ACTION_SCAN_OPEN
    cls
    echo %cCyan%============================================================%cWhite%
    echo      CHON PROJECT DE LAM VIEC
    echo %cCyan%============================================================%cWhite%
    echo.
    set "count=0"
    REM List folders
    for /d %%D in ("%WEBAPPS_FOLDER%\*") do (
        set /a count+=1
        set "PROJ[!count!]=%%~nxD"
        echo    !count!. %%~nxD
    )
    
    echo.
    if !count! EQU 0 (
        echo %cRed%[!] Khong tim thay project nao.%cWhite%
        pause
        goto MAIN_MENU
    )
    echo    0. Quay lai Menu chinh
    echo.
    set "pChoice="
    set /p "pChoice=> Chon Project [1-!count!]: "
    if "%pChoice%"=="0" goto MAIN_MENU
    if !pChoice! GTR !count! goto ACTION_SCAN_OPEN
    
    set "SELECTED_PROJ=!PROJ[%pChoice%]!"
    goto PROJ_DETAIL_MENU

:PROJ_DETAIL_MENU
    cls
    echo %cCyan%============================================================%cWhite%
    echo      PROJECT: %cYellow%!SELECTED_PROJ!%cWhite%
    echo %cCyan%============================================================%cWhite%
    echo.
    echo    1. Mo Trang Chu (Browser)
    echo    2. Scan file JSP (Edit/Open)
    echo    3. Mo Folder Project (VS Code)
    echo    4. Mo Folder Project (Explorer)
    echo    0. Quay lai danh sach
    echo.
    set /p "pdOpt=> Lua chon: "
    
    if "%pdOpt%"=="1" (
        if /I "!SELECTED_PROJ!"=="ROOT" ( start "" "%LOCALHOST_URL%" ) else ( start "" "%LOCALHOST_URL%/!SELECTED_PROJ!" )
        goto MAIN_MENU
    )
    if "%pdOpt%"=="2" goto SCAN_JSP_FILES
    if "%pdOpt%"=="3" (
        echo Dang mo VS Code...
        call code "%WEBAPPS_FOLDER%\!SELECTED_PROJ!" >nul 2>&1
        if !errorlevel! NEQ 0 (
             call :AUTO_SET_VSCODE_PATH
             call code "%WEBAPPS_FOLDER%\!SELECTED_PROJ!" >nul 2>&1
        )
        goto MAIN_MENU
    )
    if "%pdOpt%"=="4" (
        start "" "%WEBAPPS_FOLDER%\!SELECTED_PROJ!"
        goto MAIN_MENU
    )
    if "%pdOpt%"=="0" goto ACTION_SCAN_OPEN
    goto PROJ_DETAIL_MENU

:SCAN_JSP_FILES
    cls
    echo %cCyan%--- JSP FILES IN: !SELECTED_PROJ! ---%cWhite%
    echo.
    set "jCount=0"
    set "TARGET_DIR=%WEBAPPS_FOLDER%\!SELECTED_PROJ!"
    
    REM Loop de tim file JSP (Recursive)
    for /R "%TARGET_DIR%" %%f in (*.jsp) do (
        set /a jCount+=1
        set "FULL_PATH_!jCount!=%%f"
        set "FILE_NAME_!jCount!=%%~nxf"
        
        set "ABS_PATH=%%f"
        set "REL_PATH=!ABS_PATH:%WEBAPPS_FOLDER%\=!"
        set "REL_PATH=!REL_PATH:\=/!"
        set "URL_PATH_!jCount!=!REL_PATH!"
        
        echo    !jCount!. %%~nxf  %cGray%^(!REL_PATH!^)%cWhite%
    )
    
    echo.
    if !jCount! EQU 0 (
        echo %cRed%Khong tim thay file .jsp nao!%cWhite%
        pause
        goto PROJ_DETAIL_MENU
    )
    
    echo    0. Quay lai
    echo.
    set /p "jOpt=> Chon file JSP [1-!jCount!]: "
    if "%jOpt%"=="0" goto PROJ_DETAIL_MENU
    if !jOpt! GTR !jCount! goto SCAN_JSP_FILES
    
    set "SEL_FILE_PATH=!FULL_PATH_%jOpt%!"
    set "SEL_FILE_URL=!URL_PATH_%jOpt%!"
    
    goto FILE_ACTION_MENU

:FILE_ACTION_MENU
    cls
    echo %cCyan%----------------------------------------%cWhite%
    echo FILE: %cGreen%!SEL_FILE_URL!%cWhite%
    echo %cCyan%----------------------------------------%cWhite%
    echo.
    echo    1. Mo tren Trinh duyet (Browser)
    echo    2. Edit voi VS Code
    echo    3. Edit voi Notepad
    echo    0. Quay lai danh sach file
    echo.
    set /p "faOpt=> Hanh dong: "
    
    if "%faOpt%"=="1" (
        echo %cGreen%Opening: %LOCALHOST_URL%/!SEL_FILE_URL!%cWhite%
        start "" "%LOCALHOST_URL%/!SEL_FILE_URL!"
        goto PROJ_DETAIL_MENU
    )
    
    if "%faOpt%"=="2" (
        echo %cYellow%Opening in VS Code...%cWhite%
        
        call code "!SEL_FILE_PATH!" >nul 2>&1
        if !errorlevel! EQU 0 goto PROJ_DETAIL_MENU
        
        call :AUTO_SET_VSCODE_PATH
        if !errorlevel! EQU 0 (
            call code "!SEL_FILE_PATH!"
            goto PROJ_DETAIL_MENU
        )
        
        echo.
        echo %cRed%[MISSING] Khong tim thay VS Code!%cWhite%
        echo Ban co muon tai va cai dat VS Code qua Winget khong?
        set /p "askInstall=> (Y/N): "
        if /I "!askInstall!"=="Y" (
            call :ACTION_INSTALL_VSCODE
            call code "!SEL_FILE_PATH!" 
        ) else (
            echo Chuyen sang Notepad...
            timeout /t 1 >nul
            notepad "!SEL_FILE_PATH!"
        )
        goto PROJ_DETAIL_MENU
    )
    
    if "%faOpt%"=="3" (
        notepad "!SEL_FILE_PATH!"
        goto PROJ_DETAIL_MENU
    )
    
    if "%faOpt%"=="0" goto SCAN_JSP_FILES
    goto FILE_ACTION_MENU

:UPDATE_PATH_FLOW
    cls
    color 0E
    echo %cYellow%============================================================%cWhite%
    echo      CAU HINH DUONG DAN TOMCAT
    echo %cYellow%============================================================%cWhite%
    echo.
    IF DEFINED MSG_REASON ( echo %cRed%[THONG BAO] %MSG_REASON%%cWhite% & echo. & set "MSG_REASON=" )
    echo Duong dan hien tai (trong file): "%TOMCAT_HOME%"
    echo.
    if "%NEED_CONFIG%"=="1" ( echo [Goi y] Ban co the nhap 9 de tai Tomcat tu dong. & set /p "NEW_HOME=> Nhap Path moi (hoac 9 de Download): " ) else ( set /p "NEW_HOME=> Nhap Path moi (0 de Quay lai, 9 de Download): " )
    set "NEW_HOME=!NEW_HOME:"=!"
    if "!NEW_HOME!"=="9" goto ACTION_DOWNLOAD_TOMCAT
    if "!NEW_HOME!"=="0" ( if "%NEED_CONFIG%"=="1" ( echo %cRed%[LOI] Can thiet lap path!%cWhite% & pause & goto UPDATE_PATH_FLOW ) else ( goto MAIN_MENU ) )
    if not exist "!NEW_HOME!\bin\catalina.bat" ( echo. & echo %cRed%[LOI] Path khong hop le!%cWhite% & pause & goto UPDATE_PATH_FLOW )
    echo.
    set /p "NEW_PORT=> Nhap Port (Enter de dung %DEFAULT_PORT%): "
    if "!NEW_PORT!"=="" set "NEW_PORT=%DEFAULT_PORT%"
    call :SAVE_CONFIG_TO_JSON "!NEW_HOME!" "!NEW_PORT!"
    echo. & echo %cGreen%[THANH CONG] Da cap nhat data.json!%cWhite%
    set "TOMCAT_HOME=!NEW_HOME!" & set "TOMCAT_PORT=!NEW_PORT!"
    call :INIT_DEPENDENT_VARS & pause & goto MAIN_MENU

REM ==============================================================================
REM   OTHER ACTIONS
REM ==============================================================================

:ACTION_INSTALL_JAVA
    cls
    echo %cCyan%============================================================%cWhite%
    echo      CHON PHIEN BAN ORACLE JDK
    echo %cCyan%============================================================%cWhite%
    echo.
    echo    1. JDK 25 (Latest / Early Access)
    echo    2. JDK 21 (LTS - Recommended)
    echo    3. JDK 17 (LTS - Stable)
    echo    4. Nhap so phien ban khac (VD: 24, 23...)
    echo    0. Quay lai
    echo.
    set /p "jChoice=> Chon phien ban [1-4]: "
    if "%jChoice%"=="0" goto MAIN_MENU
    set "J_VER="
    if "%jChoice%"=="1" set "J_VER=25"
    if "%jChoice%"=="2" set "J_VER=21"
    if "%jChoice%"=="3" set "J_VER=17"
    if "%jChoice%"=="4" ( echo. & set /p "J_VER=> Nhap so Version (VD: 24): " )
    if "!J_VER!"=="" goto ACTION_INSTALL_JAVA
    echo.
    echo --------------------------------------------------
    echo DANG CHUAN BI TAI ORACLE JDK !J_VER!
    echo.
    echo Nhap thu muc ban muon cai dat Java.
    set /p "J_INSTALL_DIR=> Install Location: "
    set "J_INSTALL_DIR=!J_INSTALL_DIR:"=!"
    IF "!J_INSTALL_DIR!"=="" goto MAIN_MENU
    if not exist "!J_INSTALL_DIR!" mkdir "!J_INSTALL_DIR!"
    set "JDK_URL=https://download.oracle.com/java/!J_VER!/latest/jdk-!J_VER!_windows-x64_bin.zip"
    echo.
    echo %cYellow%[1/2] Dang tai JDK !J_VER!...%cWhite%
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '!JDK_URL!' -OutFile '!J_INSTALL_DIR!\jdk.zip'"
    if not exist "!J_INSTALL_DIR!\jdk.zip" ( echo %cRed%[LOI] Download that bai!%cWhite% & pause & goto ACTION_INSTALL_JAVA )
    echo %cYellow%[2/2] Dang giai nen va cau hinh...%cWhite%
    powershell -Command "Expand-Archive -Path '!J_INSTALL_DIR!\jdk.zip' -DestinationPath '!J_INSTALL_DIR!' -Force"
    del "!J_INSTALL_DIR!\jdk.zip"
    set "DETECTED_JAVA="
    for /d %%D in ("!J_INSTALL_DIR!\jdk-*") do ( set "DETECTED_JAVA=%%D" )
    if "!DETECTED_JAVA!"=="" ( echo %cRed%[LOI] Khong tim thay folder JDK sau khi giai nen.%cWhite% & pause & goto MAIN_MENU )
    echo. & echo %cGreen%[THANH CONG] Da cai dat tai: !DETECTED_JAVA!%cWhite%
    setx JAVA_HOME "!DETECTED_JAVA!" >nul
    set "JAVA_HOME=!DETECTED_JAVA!"
    set "PATH=%JAVA_HOME%\bin;%PATH%"
    echo. & echo Da thiet lap JAVA_HOME. & java -version & echo. & pause & goto MAIN_MENU

:ACTION_INSTALL_VSCODE
    cls
    echo %cCyan%============================================================%cWhite%
    echo      CAI DAT VISUAL STUDIO CODE (VIA WINGET)
    echo %cCyan%============================================================%cWhite%
    echo.
    where winget >nul 2>&1
    if %errorlevel% NEQ 0 (
        echo %cRed%[LOI] May ban chua co Winget.%cWhite%
        pause
        exit /b 1
    )
    echo Dang tim kiem package 'Microsoft.VisualStudioCode'...
    echo.
    winget install -e --id Microsoft.VisualStudioCode --source winget --accept-source-agreements --accept-package-agreements
    if %errorlevel% NEQ 0 (
        echo. & echo %cRed%[LOI] Cai dat that bai hoac bi huy.%cWhite% & pause & exit /b 1
    )
    echo. & echo %cGreen%[THANH CONG] Winget bao da cai dat xong!%cWhite%
    call :AUTO_SET_VSCODE_PATH
    if !errorlevel! EQU 0 (
        echo %cGreen%[OK] Da them VS Code vao Session hien tai.%cWhite%
    ) else (
        echo %cYellow%[WARN] Khong tu dong set path duoc.%cWhite%
    )
    pause & exit /b 0

:AUTO_SET_VSCODE_PATH
    REM Check 1: Path san co
    where code >nul 2>&1
    if %errorlevel% EQU 0 exit /b 0
    
    REM Check 2: User AppData
    set "VS_USER=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin"
    if exist "!VS_USER!\code.cmd" (
        set "PATH=%PATH%;!VS_USER!"
        exit /b 0
    )
    REM Check 3: Program Files
    set "VS_SYS=%ProgramFiles%\Microsoft VS Code\bin"
    if exist "!VS_SYS!\code.cmd" (
        set "PATH=%PATH%;!VS_SYS!"
        exit /b 0
    )
    REM Check 4: Program Files x86
    set "VS_SYS86=%ProgramFiles(x86)%\Microsoft VS Code\bin"
    if exist "!VS_SYS86!\code.cmd" (
        set "PATH=%PATH%;!VS_SYS86!"
        exit /b 0
    )
    exit /b 1

:ACTION_START
    call :CHECK_JAVA_ENV
    if !errorlevel! NEQ 0 ( echo. & echo %cRed%[LOI] Chua cai dat JAVA!%cWhite% & pause & goto MAIN_MENU )
    if "%SERVER_STATUS%"=="RUNNING" ( echo. & echo %cYellow%[INFO] Server dang chay roi!%cWhite% & pause & goto MAIN_MENU )
    cd /d "%TOMCAT_HOME%\bin" & echo. & echo %cGreen%Starting Server...%cWhite%
    set "JAVA_HOME=%JAVA_HOME%" & call catalina.bat version & call catalina.bat start
    timeout /t 5 >nul & goto MAIN_MENU
:ACTION_CATALINA_START
    cd /d "%TOMCAT_HOME%\bin" & echo. & echo %cGreen%Starting Server...%cWhite%
    set "JAVA_HOME=%JAVA_HOME%" & call catalina.bat run
    timeout /t 5 >nul & goto MAIN_MENU
:ACTION_STOP
    echo. & echo %cRed%Stopping Server...%cWhite%
    cd /d "%TOMCAT_HOME%\bin" & set "JAVA_HOME=%JAVA_HOME%" & call shutdown.bat
    timeout /t 3 >nul & goto MAIN_MENU

:ACTION_RESTART
    echo. & echo %cYellow%Restarting Server...%cWhite%
    cd /d "%TOMCAT_HOME%\bin" & set "JAVA_HOME=%JAVA_HOME%" & call shutdown.bat
    timeout /t 3 >nul
    cd /d "%TOMCAT_HOME%\bin" & echo. & echo %cGreen%Starting Server...%cWhite%
    set "JAVA_HOME=%JAVA_HOME%" & call catalina.bat version & call catalina.bat start
    timeout /t 3 >nul & goto MAIN_MENU

:ACTION_CREATE_PROJECT
    echo. & echo %cCyan%--- NEW PROJECT ---%cWhite%
    set /p projName="> Project Name: "
    if "%projName%"=="" goto MAIN_MENU
    if exist "%WEBAPPS_FOLDER%\%projName%" ( echo %cRed%Project exists!%cWhite% & pause & goto MAIN_MENU )
    mkdir "%WEBAPPS_FOLDER%\%projName%"
    ( echo ^<h1^>Project: %projName%^</h1^> & echo ^<p^>Created via Tomcat Manager^</p^> ) > "%WEBAPPS_FOLDER%\%projName%\index.jsp"
    echo %cGreen%Created! Opening folder...%cWhite%
    timeout /t 1 >nul & explorer "%WEBAPPS_FOLDER%\%projName%" & goto MAIN_MENU

:ACTION_DOWNLOAD_TOMCAT
    cls
    echo %cCyan%============================================================%cWhite%
    echo      CHON PHIEN BAN TOMCAT DE TAI
    echo %cCyan%============================================================%cWhite%
    echo.
    echo    1. Tomcat 11 (Latest)
    echo    2. Tomcat 10 (Current)
    echo    3. Tomcat 9  (LTS)
    echo    4. Tomcat 8  (Legacy)
    echo    5. Custom Version
    echo    0. Quay lai
    echo.
    set /p "vChoice=> Chon phien ban [1-5]: "
    if "%vChoice%"=="0" goto MAIN_MENU
    set "DL_VER=" & set "DL_MAJOR="
    if "%vChoice%"=="1" ( set "DL_VER=11.0.2" & set "DL_MAJOR=11" )
    if "%vChoice%"=="2" ( set "DL_VER=10.1.34" & set "DL_MAJOR=10" )
    if "%vChoice%"=="3" ( set "DL_VER=9.0.98" & set "DL_MAJOR=9" )
    if "%vChoice%"=="4" ( set "DL_VER=8.5.100" & set "DL_MAJOR=8" )
    if "%vChoice%"=="5" ( echo. & set /p "DL_MAJOR=> Major Ver: " & echo. & set /p "DL_VER=> Full Ver: " )
    if "!DL_VER!"=="" goto ACTION_DOWNLOAD_TOMCAT
    set "DL_URL=https://archive.apache.org/dist/tomcat/tomcat-!DL_MAJOR!/v!DL_VER!/bin/apache-tomcat-!DL_VER!-windows-x64.zip"
    echo. & echo -------------------------------------------------- & echo URL: !DL_URL! & echo -------------------------------------------------- & echo.
    echo Nhap thu muc cai dat (VD: D:\Tools):
    set /p "INSTALL_DIR=> Install Location: "
    set "INSTALL_DIR=!INSTALL_DIR:"=!"
    IF "!INSTALL_DIR!"=="" goto MAIN_MENU
    if not exist "!INSTALL_DIR!" mkdir "!INSTALL_DIR!"
    echo. & echo %cYellow%[1/2] Downloading...%cWhite%
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '!DL_URL!' -OutFile '!INSTALL_DIR!\tomcat.zip'"
    if not exist "!INSTALL_DIR!\tomcat.zip" ( echo. & echo %cRed%[LOI] Download failed!%cWhite% & pause & goto ACTION_DOWNLOAD_TOMCAT )
    echo %cYellow%[2/2] Extracting...%cWhite%
    powershell -Command "Expand-Archive -Path '!INSTALL_DIR!\tomcat.zip' -DestinationPath '!INSTALL_DIR!' -Force"
    del "!INSTALL_DIR!\tomcat.zip"
    for /d %%D in ("!INSTALL_DIR!\apache-tomcat-*") do ( set "DETECTED_HOME=%%D" )
    echo. & echo %cGreen%[THANH CONG] Installed at: !DETECTED_HOME!%cWhite%
    call :SAVE_CONFIG_TO_JSON "!DETECTED_HOME!" "%DEFAULT_PORT%"
    set "TOMCAT_HOME=!DETECTED_HOME!" & set "TOMCAT_PORT=%DEFAULT_PORT%" & set "NEED_CONFIG=0"
    call :INIT_DEPENDENT_VARS & pause & goto MAIN_MENU
