@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - FULLSTACK EDITION (v6.3 - Final Robust Fix)
REM   Author: Nguyen Quoc Anh (NQA TECH) & Gemini
REM   Description: Fix triet de loi '.' hoac ')' unexpected bang DIR /S /B
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
set "MSG="

REM --- 3. KIEM TRA FILE CAU HINH ---
if not exist "%CONFIG_FILE%" goto :CASE_MISSING
call :LOAD_CFG
call :VAL_HOME
if !errorlevel! NEQ 0 (
    set "MSG=Duong dan Tomcat trong cau hinh khong hop le."
    goto :UPDATE_PATH
)
call :INIT_VARS
goto :MAIN_MENU

:CASE_MISSING
    set "MSG=Chua co file data.json. Vui long thiet lap duong dan Tomcat."
    goto :UPDATE_PATH

REM ==============================================================================
REM   MAIN MENU
REM ==============================================================================
:MAIN_MENU
cls
call :CHECK_JAVA

echo %cCyan%============================================================%cWhite%
echo    APACHE TOMCAT MANAGER %cYellow%(v6.3 - Final Robust Edition)%cWhite%
echo    Support: .java ^| .jsp ^| .html
echo %cCyan%============================================================%cWhite%
echo.
echo    %cGray%Tomcat Home:%cWhite% %TOMCAT_HOME%
echo    %cGray%Java Home:  %cWhite% %JAVA_HOME% %cGreen%[%JAVA_STATUS%]%cWhite%
echo.

REM Kiem tra trang thai server mot cach chinh xac hon
netstat -ano | findstr /R /C:":%TOMCAT_PORT% .*LISTENING" >nul
if !errorlevel! EQU 0 (
    set "SERVER_STATUS=RUNNING"
    echo    TRANG THAI: %cGreen%[  ONLINE  ] %cWhite% Port %TOMCAT_PORT%
) else (
    set "SERVER_STATUS=STOPPED"
    echo    TRANG THAI: %cRed%[  OFFLINE ] %cWhite% Stopped
)
echo.
echo %cGray%------------------------------------------------------------%cWhite%
echo.
echo    1. Bat Server (Start)       4. %cGreen%Tao Project Servlet moi%cWhite%
echo    2. Tat Server (Stop)        5. Quan ly Project (Build)
echo    3. Khoi dong lai (Restart)  6. Mo thu muc Webapps
echo.
echo    7. Mo Localhost (Root)      8. Cau hinh lai Tomcat
echo    J. Cai dat Oracle JDK       9. Download Tomcat
echo    V. Cai dat VS Code          0. Thoat
echo.
echo %cGray%------------------------------------------------------------%cWhite%

set "opt="
set /p "opt=> Chon chuc nang: "

if "%opt%"=="1" goto :ACT_START
if "%opt%"=="2" goto :ACT_STOP
if "%opt%"=="3" goto :ACT_RESTART
if "%opt%"=="4" goto :ACT_NEW_PROJ
if "%opt%"=="5" goto :ACT_SCAN
if "%opt%"=="6" start "" "%WEBAPPS_FOLDER%" & goto :MAIN_MENU
if "%opt%"=="7" start "" "%LOCALHOST_URL%" & goto :MAIN_MENU
if "%opt%"=="8" goto :UPDATE_PATH
if "%opt%"=="9" goto :ACT_DL_TOMCAT
if /I "%opt%"=="J" goto :ACT_SET_JAVA
if /I "%opt%"=="V" goto :ACT_SET_VSCODE
if "%opt%"=="0" exit /b

echo %cRed%Lua chon khong hop le!%cWhite%
timeout /t 2 >nul
goto :MAIN_MENU

REM ==============================================================================
REM   HANDLERS
REM ==============================================================================

:ACT_NEW_PROJ
    cls
    echo %cCyan%--- TAO PROJECT SERVLET MOI ---%cWhite%
    set /p pName="> Ten Project (viet lien): "
    if "%pName%"=="" goto :MAIN_MENU
    set "TPATH=%WEBAPPS_FOLDER%\%pName%"
    if exist "%TPATH%" ( echo %cRed%Project da ton tai!%cWhite% & pause & goto :MAIN_MENU )
    
    mkdir "%TPATH%" 2>nul
    mkdir "%TPATH%\WEB-INF\classes" 2>nul
    mkdir "%TPATH%\WEB-INF\lib" 2>nul
    (
        echo ^<h1^>Project %pName% is Ready^</h1^>
        echo ^<p^>Duoc tao boi Tomcat Manager Pro v6.3^</p^>
        echo ^<a href="hello"^>Truy cap Servlet mau^</a^>
    ) > "%TPATH%\index.jsp"
    
    echo %cGreen%Khoi tao cau truc Servlet thanh cong!%cWhite%
    explorer "%TPATH%"
    pause
    goto :MAIN_MENU

:ACT_SCAN
    cls
    echo %cCyan%--- DANH SACH PROJECT HIEN CO ---%cWhite%
    set "cnt=0"
    for /d %%D in ("%WEBAPPS_FOLDER%\*") do (
        set /a cnt+=1
        set "P[!cnt!]=%%~nxD"
        echo    !cnt!. %%~nxD
    )
    if !cnt! EQU 0 ( echo %cRed%Chua co project nao trong webapps.%cWhite% & pause & goto :MAIN_MENU )
    echo    0. Quay lai
    set /p "pc=> Chon so: "
    if "%pc%"=="" goto :MAIN_MENU
    if "%pc%"=="0" goto :MAIN_MENU
    if not defined P[%pc%] ( echo %cRed%So khong hop le!%cWhite% & timeout /t 2 >nul & goto :ACT_SCAN )
    set "SEL_P=!P[%pc%]!"
    goto :PROJ_MENU

:PROJ_MENU
    cls
    echo %cCyan%--- QUAN LY PROJECT: !SEL_P! ---%cWhite%
    echo    1. Mo tren Browser     2. Bien dich (.java -^> .class)
    echo    3. %cYellow%Danh sach File (.java, .jsp, .html)%cWhite%
    echo    4. Mo folder trong VS Code
    echo    0. Quay lai danh sach
    echo.
    set /p "po=> Lua chon: "
    if "%po%"=="1" start "" "%LOCALHOST_URL%/!SEL_P!" & goto :PROJ_MENU
    if "%po%"=="2" goto :ACT_BUILD
    if "%po%"=="3" goto :ACT_LIST_FILES
    if "%po%"=="4" call code "%WEBAPPS_FOLDER%\!SEL_P!" & goto :PROJ_MENU
    if "%po%"=="0" goto :ACT_SCAN
    goto :PROJ_MENU

:ACT_BUILD
    cls
    echo %cYellow%--- DANG BIEN DICH SERVLET (JAVAC) ---%cWhite%
    set "PP=%WEBAPPS_FOLDER%\!SEL_P!"
    set "CP=!PP!\WEB-INF\classes"
    if not exist "!CP!" mkdir "!CP!"
    set "foundJava=0"
    
    REM Quet file Java bang DIR /S /B de tranh loi unexpected char
    for /f "delims=" %%f in ('dir "!PP!" /s /b /a-d ^| findstr /i "\.java$"') do (
        set "foundJava=1"
        echo Dang xu ly: %%~nxf
        javac -cp "!TOMCAT_HOME!\lib\*;!PP!\WEB-INF\lib\*" -d "!CP!" "%%f"
        if !errorlevel! EQU 0 ( echo %cGreen%[OK]%cWhite% ) else ( echo %cRed%[LOI]%cWhite% )
    )
    if !foundJava! EQU 0 echo %cRed%Khong tim thay file .java nao trong project.%cWhite%
    echo.
    pause
    goto :PROJ_MENU

:ACT_LIST_FILES
    cls
    echo %cCyan%--- TAT CA FILE CODE: !SEL_P! ---%cWhite%
    set "jc=0"
    REM Reset mang an toan
    for /L %%i in (1,1,100) do (
        set "U[%%i]="
        set "F[%%i]="
        set "E[%%i]="
    )
    
    set "TARGET_DIR=%WEBAPPS_FOLDER%\!SEL_P!"

    REM Su dung DIR /S /B ket hop FINDSTR de loc file - Cuc ky on dinh tren Win 10/11
    for /f "delims=" %%f in ('dir "!TARGET_DIR!" /s /b /a-d ^| findstr /i "\.java$ \.jsp$ \.html$"') do (
        set /a jc+=1
        set "F_P=%%f"
        set "F_EXT=%%~xf"
        set "F_NAME=%%~nxf"
        
        REM Lay duong dan tuong doi bang cach xoa phan dau (WEBAPPS_FOLDER)
        set "REL=%%f"
        set "REL=!REL:%WEBAPPS_FOLDER%\=!"
        set "REL=!REL:\=/!"
        
        set "U[!jc!]=!REL!"
        set "F[!jc!]=%%f"
        set "E[!jc!]=!F_EXT!"
        
        set "colorCode=%cWhite%"
        if /I "!F_EXT!"==".java" set "colorCode=%cCyan%"
        if /I "!F_EXT!"==".jsp" set "colorCode=%cYellow%"
        if /I "!F_EXT!"==".html" set "colorCode=%cGreen%"
        
        set "outMsg=   !jc!. !colorCode!!F_NAME!%cWhite% %cGray%[!REL!]%cWhite%"
        echo !outMsg!
    )
    
    if !jc! EQU 0 ( echo %cRed%Khong tim thay file code nao.%cWhite% & pause & goto :PROJ_MENU )
    echo.
    echo    0. Quay lai
    set /p "jo=> Chon file: "
    if "%jo%"=="" goto :PROJ_MENU
    if "%jo%"=="0" goto :PROJ_MENU
    if not defined U[%jo%] ( echo %cRed%Sai lua chon!%cWhite% & timeout /t 2 >nul & goto :ACT_LIST_FILES )
    
    set "SEL_FILE_PATH=!F[%jo%]!"
    set "SEL_FILE_EXT=!E[%jo%]!"
    set "SEL_FILE_URL=!U[%jo%]!"

    if /I "!SEL_FILE_EXT!"==".java" (
        goto :FILE_ACTION_CODE
    ) else (
        goto :FILE_ACTION_WEB
    )

:FILE_ACTION_CODE
    cls
    echo %cCyan%--- FILE SOURCE CODE: !SEL_FILE_URL! ---%cWhite%
    echo.
    echo    1. Edit voi VS Code
    echo    2. Edit voi Notepad
    echo    0. Quay lai
    echo.
    set /p "fa=> Lua chon: "
    if "%fa%"=="1" call code "!SEL_FILE_PATH!" & goto :ACT_LIST_FILES
    if "%fa%"=="2" notepad "!SEL_FILE_PATH!" & goto :ACT_LIST_FILES
    goto :ACT_LIST_FILES

:FILE_ACTION_WEB
    cls
    echo %cCyan%--- FILE WEB: !SEL_FILE_URL! ---%cWhite%
    echo.
    echo    1. Mo tren Browser
    echo    2. Edit voi VS Code
    echo    3. Edit voi Notepad
    echo    0. Quay lai
    echo.
    set /p "fa=> Lua chon: "
    if "%fa%"=="1" start "" "%LOCALHOST_URL%/!SEL_FILE_URL!" & goto :ACT_LIST_FILES
    if "%fa%"=="2" call code "!SEL_FILE_PATH!" & goto :ACT_LIST_FILES
    if "%fa%"=="3" notepad "!SEL_FILE_PATH!" & goto :ACT_LIST_FILES
    goto :ACT_LIST_FILES

:ACT_START
    if "%SERVER_STATUS%"=="RUNNING" ( echo %cYellow%Server dang chay roi!%cWhite% & pause & goto :MAIN_MENU )
    echo %cGreen%Dang khoi dong Tomcat...%cWhite%
    cd /d "%TOMCAT_HOME%\bin" && start "Tomcat Server" catalina.bat run
    timeout /t 5 >nul
    goto :MAIN_MENU

:ACT_STOP
    echo %cRed%Dang tat Tomcat...%cWhite%
    cd /d "%TOMCAT_HOME%\bin" && call shutdown.bat
    timeout /t 3 >nul
    goto :MAIN_MENU

:ACT_RESTART
    echo %cYellow%Dang tai khoi dong...%cWhite%
    cd /d "%TOMCAT_HOME%\bin" && call shutdown.bat
    timeout /t 3 >nul
    start "Tomcat Server" /d "%TOMCAT_HOME%\bin" catalina.bat run
    timeout /t 5 >nul
    goto :MAIN_MENU

:UPDATE_PATH
    cls
    echo %cYellow%--- CAU HINH DUONG DAN TOMCAT ---%cWhite%
    if defined MSG echo %cRed%!MSG!%cWhite%
    set /p "NH=> Nhap Path (VD: C:\tomcat): "
    set "NH=!NH:"=!"
    if not exist "!NH!\bin\catalina.bat" (
        set "MSG=Duong dan khong co catalina.bat. Thu lai."
        goto :UPDATE_PATH
    )
    call :SAVE_CFG "!NH!" "%DEFAULT_PORT%"
    set "TOMCAT_HOME=!NH!"
    call :INIT_VARS
    set "MSG="
    goto :MAIN_MENU

:ACT_SET_JAVA
    cls
    echo %cCyan%--- TAI ^& CAI DAT JDK (ORACLE) ---%cWhite%
    set /p "v=> Version (17/21/25): "
    set /p "d=> Thu muc cai (VD: C:\Java): "
    if not exist "!d!" mkdir "!d!"
    echo Dang tai xuong...
    powershell -Command "Invoke-WebRequest -Uri 'https://download.oracle.com/java/!v!/latest/jdk-!v!_windows-x64_bin.zip' -OutFile '!d!\jdk.zip'"
    echo Dang giai nen...
    powershell -Command "Expand-Archive -Path '!d!\jdk.zip' -DestinationPath '!d!' -Force"
    del "!d!\jdk.zip"
    echo %cGreen%Hoan thanh!%cWhite%
    pause & goto :MAIN_MENU

:ACT_SET_VSCODE
    winget install --id Microsoft.VisualStudioCode -e --accept-source-agreements
    pause & goto :MAIN_MENU

:ACT_DL_TOMCAT
    cls
    echo %cCyan%--- TAI APACHE TOMCAT ---%cWhite%
    set /p "m=> Major Version (9/10/11): "
    set /p "v=> Full Version (VD: 10.1.34): "
    set /p "d=> Thu muc dich: "
    if not exist "!d!" mkdir "!d!"
    powershell -Command "Invoke-WebRequest -Uri 'https://archive.apache.org/dist/tomcat/tomcat-!m!/v!v!/bin/apache-tomcat-!v!-windows-x64.zip' -OutFile '!d!\t.zip'"
    powershell -Command "Expand-Archive -Path '!d!\t.zip' -DestinationPath '!d!' -Force"
    del "!d!\t.zip"
    echo %cGreen%Da tai xong Tomcat !v!%cWhite%
    pause & goto :MAIN_MENU

REM ==============================================================================
REM   INTERNAL FUNCTIONS
REM ==============================================================================

:CHECK_JAVA
    if "%JAVA_HOME%"=="" ( set "JAVA_STATUS=MISSING" ) else ( set "JAVA_STATUS=OK" )
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