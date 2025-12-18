@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - FULLSTACK EDITION (v5.3 - Stability Fix)
REM   Author: Nguyen Quoc Anh (NQA TECH) & Gemini
REM   Description: Batch script for Tomcat, Rust & Servlet Management
REM ==============================================================================

REM --- 1. KHOI TAO MA MAU ---
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "cGreen=%ESC%[92m"
set "cRed=%ESC%[91m"
set "cYellow=%ESC%[93m"
set "cCyan=%ESC%[96m"
set "cWhite=%ESC%[0m"
set "cGray=%ESC%[90m"

REM --- 2. CAU HINH ---
set "CONFIG_FILE=data.json"
set "DEFAULT_PORT=8080"
set "TOMCAT_PORT=%DEFAULT_PORT%"
set "TOMCAT_HOME="
set "SERVER_STATUS=UNKNOWN"
set "JAVA_STATUS=UNKNOWN"
set "RUST_STATUS=UNKNOWN"

IF NOT EXIST "%CONFIG_FILE%" goto CASE_MISSING
call :LOAD_CFG
call :VAL_HOME
IF !errorlevel! NEQ 0 goto CASE_INVALID
call :INIT_VARS
goto MAIN_MENU

:CASE_MISSING
    set "MSG=Chua co file data.json. Vui long thiet lap."
    goto UPDATE_PATH
:CASE_INVALID
    set "MSG=Duong dan Tomcat khong hop le."
    goto UPDATE_PATH

REM ==============================================================================
REM   MAIN MENU
REM ==============================================================================
:MAIN_MENU
cls
call :CHECK_JAVA
call :CHECK_RUST

echo %cCyan%============================================================%cWhite%
echo    APACHE TOMCAT MANAGER %cYellow%(v5.3 - Stable Edition)%cWhite%
echo %cCyan%============================================================%cWhite%
echo.
echo    %cGray%Tomcat Home:%cWhite% %TOMCAT_HOME%
echo    %cGray%Java Home:  %cWhite% %JAVA_HOME% %cGreen%[%JAVA_STATUS%]%cWhite%
echo    %cGray%Rust/Cargo: %cWhite% %cGreen%[%RUST_STATUS%]%cWhite%
echo.
netstat -ano | findStr ":%TOMCAT_PORT% " | findStr "LISTENING" >nul
if %errorlevel%==0 (
    set "SERVER_STATUS=RUNNING"
    echo    STATUS: %cGreen%[  ONLINE  ] %cWhite% Port %TOMCAT_PORT%
) else (
    set "SERVER_STATUS=STOPPED"
    echo    STATUS: %cRed%[  OFFLINE ] %cWhite% Stopped
)
echo.
echo %cGray%------------------------------------------------------------%cWhite%
echo.
echo    1. Bat Server (Start)       4. %cGreen%Tao Project Servlet moi%cWhite%
echo    2. Tat Server (Stop)        5. Quan ly Project (Build)
echo    3. Khoi dong lai (Restart)  6. Mo thu muc Webapps
echo.
echo    7. Mo Localhost (Root)      R. Setup RUST Environment
echo    8. Cau hinh lai Tomcat      J. Cai dat Oracle JDK
echo    9. Download Tomcat          V. Install VS Code          0. Thoat
echo.
echo %cGray%------------------------------------------------------------%cWhite%

set "opt="
set /p "opt=> Chon chuc nang: "

if "%opt%"=="1" goto ACT_START
if "%opt%"=="2" goto ACT_STOP
if "%opt%"=="3" goto ACT_RESTART
if "%opt%"=="4" goto ACT_NEW_PROJ
if "%opt%"=="5" goto ACT_SCAN
if "%opt%"=="6" start "" "%WEBAPPS_FOLDER%" & goto MAIN_MENU
if "%opt%"=="7" start "" "%LOCALHOST_URL%" & goto MAIN_MENU
if "%opt%"=="8" goto UPDATE_PATH
if "%opt%"=="9" goto ACT_DL_TOMCAT
if /I "%opt%"=="R" goto ACT_SET_RUST
if /I "%opt%"=="J" goto ACT_SET_JAVA
if /I "%opt%"=="V" goto ACT_SET_VSCODE
if "%opt%"=="0" exit

goto MAIN_MENU

REM ==============================================================================
REM   HANDLERS (DUNG GOTO DE TRANH LOI LABEL)
REM ==============================================================================

:ACT_NEW_PROJ
    cls
    echo %cCyan%--- TAO PROJECT SERVLET ---%cWhite%
    set /p pName="> Ten Project: "
    if "%pName%"=="" goto MAIN_MENU
    set "TPATH=%WEBAPPS_FOLDER%\%pName%"
    if exist "%TPATH%" ( echo Project ton tai! & pause & goto MAIN_MENU )
    
    mkdir "%TPATH%"
    mkdir "%TPATH%\WEB-INF\classes"
    mkdir "%TPATH%\WEB-INF\lib"
    (
        echo ^<h1^>Project %pName% Ready^</h1^>
        echo ^<a href="hello"^>Test Servlet^</a^>
    ) > "%TPATH%\index.jsp"
    
    echo %cGreen%Done!%cWhite%
    explorer "%TPATH%"
    pause
    goto MAIN_MENU

:ACT_SCAN
    cls
    echo %cCyan%--- PROJECT LIST ---%cWhite%
    set "cnt=0"
    for /d %%D in ("%WEBAPPS_FOLDER%\*") do (
        set /a cnt+=1
        set "P[!cnt!]=%%~nxD"
        echo    !cnt!. %%~nxD
    )
    if !cnt! EQU 0 ( pause & goto MAIN_MENU )
    set /p "pc=> Chon: "
    if "%pc%"=="0" goto MAIN_MENU
    set "SEL_P=!P[%pc%]!"
    goto PROJ_MENU

:PROJ_MENU
    cls
    echo %cCyan%--- !SEL_P! ---%cWhite%
    echo    1. Browser  2. Build  3. JSP  4. VS Code  0. Back
    set /p "po=> "
    if "%po%"=="1" start "" "%LOCALHOST_URL%/!SEL_P!" & goto PROJ_MENU
    if "%po%"=="2" goto ACT_BUILD
    if "%po%"=="3" goto ACT_JSP
    if "%po%"=="4" call code "%WEBAPPS_FOLDER%\!SEL_P!" & goto PROJ_MENU
    if "%po%"=="0" goto ACT_SCAN
    goto PROJ_MENU

:ACT_BUILD
    cls
    echo %cYellow%--- COMPILING ---%cWhite%
    set "PP=%WEBAPPS_FOLDER%\!SEL_P!"
    set "CP=%PP%\WEB-INF\classes"
    if not exist "%CP%" mkdir "%CP%"
    for /r "%PP%" %%f in (*.java) do (
        echo Compiling: %%~nxf
        javac -cp "%TOMCAT_HOME%\lib\*;%PP%\WEB-INF\lib\*" -d "%CP%" "%%f"
    )
    pause
    goto PROJ_MENU

:ACT_JSP
    cls
    set "jc=0"
    for /R "%WEBAPPS_FOLDER%\!SEL_P!" %%f in (*.jsp) do (
        set /a jc+=1
        set "R=%%f"
        set "R=!R:%WEBAPPS_FOLDER%\=!"
        set "R=!R:\=/!"
        set "U[!jc!]=!R!"
        echo    !jc!. %%~nxf
    )
    set /p "jo=> "
    if "%jo%"=="0" goto PROJ_MENU
    start "" "%LOCALHOST_URL%/!U[%jo%]!"
    goto ACT_JSP

:ACT_START
    cd /d "%TOMCAT_HOME%\bin" & call catalina.bat start
    timeout /t 5 >nul & goto MAIN_MENU

:ACT_STOP
    cd /d "%TOMCAT_HOME%\bin" & call shutdown.bat
    timeout /t 3 >nul & goto MAIN_MENU

:ACT_RESTART
    call :ACT_STOP
    call :ACT_START
    goto MAIN_MENU

:ACT_SET_RUST
    cls
    winget install --id Rustlang.Rustup -e --accept-source-agreements
    call code --install-extension rust-lang.rust-analyzer
    pause & goto MAIN_MENU

:UPDATE_PATH
    cls
    if defined MSG echo %cRed%!MSG!%cWhite%
    set /p "NH=> Path Tomcat: "
    set "NH=!NH:"=!"
    if not exist "!NH!\bin\catalina.bat" ( echo Path error! & pause & goto UPDATE_PATH )
    call :SAVE_CFG "!NH!" "%DEFAULT_PORT%"
    set "TOMCAT_HOME=!NH!" & call :INIT_VARS
    goto MAIN_MENU

:ACT_SET_JAVA
    set /p "v=> Ver: "
    set /p "d=> Dir: "
    powershell -Command "Invoke-WebRequest -Uri 'https://download.oracle.com/java/!v!/latest/jdk-!v!_windows-x64_bin.zip' -OutFile '!d!\j.zip'"
    powershell -Command "Expand-Archive -Path '!d!\j.zip' -DestinationPath '!d!' -Force"
    pause & goto MAIN_MENU

:ACT_SET_VSCODE
    winget install --id Microsoft.VisualStudioCode -e
    pause & goto MAIN_MENU

:ACT_DL_TOMCAT
    set /p "m=> Major: "
    set /p "v=> Full: "
    set /p "d=> Dir: "
    powershell -Command "Invoke-WebRequest -Uri 'https://archive.apache.org/dist/tomcat/tomcat-!m!/v!v!/bin/apache-tomcat-!v!-windows-x64.zip' -OutFile '!d!\t.zip'"
    powershell -Command "Expand-Archive -Path '!d!\t.zip' -DestinationPath '!d!' -Force"
    pause & goto MAIN_MENU

REM ==============================================================================
REM   INTERNAL FUNCTIONS
REM ==============================================================================

:CHECK_JAVA
    if "%JAVA_HOME%"=="" ( set "JAVA_STATUS=MISSING" ) else ( set "JAVA_STATUS=OK" )
    exit /b
:CHECK_RUST
    where cargo >nul 2>&1
    if %errorlevel% EQU 0 ( set "RUST_STATUS=OK" ) else ( set "RUST_STATUS=MISSING" )
    exit /b
:LOAD_CFG
    for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "try {(Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json).TOMCAT_HOME} catch {}"`) do set "TOMCAT_HOME=%%A"
    for /f "usebackq delims=" %%B in (`powershell -NoProfile -Command "try {(Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json).TOMCAT_PORT} catch {}"`) do set "TOMCAT_PORT=%%B"
    if "%TOMCAT_PORT%"=="" set "TOMCAT_PORT=%DEFAULT_PORT%"
    exit /b
:SAVE_CFG
    powershell -NoProfile -Command "$d = @{ TOMCAT_HOME = '%~1'; TOMCAT_PORT = '%~2' }; $d | ConvertTo-Json | Set-Content '%CONFIG_FILE%'"
    exit /b
:VAL_HOME
    if "%TOMCAT_HOME%"=="" exit /b 1
    if not exist "%TOMCAT_HOME%\bin\catalina.bat" exit /b 1
    exit /b 0
:INIT_VARS
    set "WEBAPPS_FOLDER=%TOMCAT_HOME%\webapps"
    set "LOCALHOST_URL=http://localhost:%TOMCAT_PORT%"
    exit /b