@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - FULLSTACK EDITION
REM   Author      : NQA TECH
REM   Version     : 7.0.0 (Cyber Neon)
REM   Description : 
REM     1. Quan ly Tomcat Server (Start/Stop/Logs/User Config)
REM     2. Quan ly MySQL Database (Start/Stop/Backup/Restore/Query)
REM     3. Tu dong hoa Project Java Web (Create/Build Servlet/JDBC)
REM     4. Quan ly moi truong (Auto Detect Paths/Ports/Config)
REM   Config      : config.ini
REM ==============================================================================

REM --- 1. KHOI TAO MA MAU (ANSI COLORS) ---
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "cGreen=%ESC%[92m"
set "cRed=%ESC%[91m"
set "cYellow=%ESC%[93m"
set "cCyan=%ESC%[96m"
set "cWhite=%ESC%[97m"
set "cGray=%ESC%[90m"
set "cBlue=%ESC%[94m"
set "cPink=%ESC%[95m"
set "cMagenta=%ESC%[35m"
set "cReset=%ESC%[0m"

REM --- 2. CAU HINH MAC DINH ---
set "CONFIG_FILE=config.ini"
set "DEFAULT_PORT=8080"
set "DEFAULT_MYSQL_PORT=3306"
set "TOMCAT_PORT=%DEFAULT_PORT%"
set "MYSQL_PORT=%DEFAULT_MYSQL_PORT%"
set "TOMCAT_HOME="
set "MYSQL_HOME="
set "MSG="
set "TITLE=FULLSTACK TOMCAT V7"

REM --- 3. LOAD CONFIG ---
if not exist "%CONFIG_FILE%" goto :FIRST_SETUP
call :LOAD_CFG
call :VAL_HOME
if !errorlevel! NEQ 0 ( set "MSG=Kiem tra lai duong dan Tomcat!" & goto :UPDATE_PATH )
call :INIT_VARS
goto :MAIN_MENU

:FIRST_SETUP
    set "MSG=Chao mung! Vui long cau hinh lan dau."
    goto :UPDATE_PATH

REM ==============================================================================
REM   MAIN MENU DASHBOARD
REM ==============================================================================
:MAIN_MENU
cls
title %TITLE%
call :CHECK_SYSTEM_STATUS

echo %cPink%    [  C Y B E R   M A N A G E R   V 7  ]    %cWhite%
echo.
echo    %cGray%TOMCAT_HOME :: %cWhite%%TOMCAT_HOME%
echo    %cGray%MYSQL_HOME  :: %cWhite%%MYSQL_HOME%
echo.
echo    %cBlue%[ STATUS MONITOR ]%cReset%
echo    %cGray%Tomcat (%TOMCAT_PORT%) :: %SERVER_STATUS%
echo    %cGray%MySQL  (%MYSQL_PORT%) :: %MYSQL_STATUS%
echo.
echo %cPink%[%cCyan% 1 %cPink%] %cWhite%Start Tomcat        %cPink%[%cCyan% 2 %cPink%] %cWhite%Stop Tomcat
echo %cPink%[%cCyan% 3 %cPink%] %cWhite%Restart Tomcat      %cPink%[%cCyan% 4 %cPink%] %cYellow%Logs Console%cWhite%
echo %cPink%[%cCyan% 5 %cPink%] %cCyan%User Manager%cGray% (admin-gui)%cWhite%
echo.
echo %cBlue%--- DATABASES (MySQL) ----------------------------------%cReset%
echo %cPink%[%cCyan%M1 %cPink%] %cWhite%Start MySQL         %cPink%[%cCyan%M2 %cPink%] %cWhite%Stop MySQL
echo %cPink%[%cCyan%M3 %cPink%] %cGreen%SQL Editor%cWhite%          %cPink%[%cCyan%M4 %cPink%] %cWhite%Restart MySQL
echo %cPink%[%cCyan%M5 %cPink%] %cCyan%Auto Setup Lab13%cWhite%    %cPink%[%cCyan%M6 %cPink%] %cCyan%Backup DB%cWhite%
echo %cPink%[%cCyan%M7 %cPink%] %cRed%Restore DB%cWhite%
echo.
echo %cBlue%--- WORKSPACE ------------------------------------------%cReset%
echo %cPink%[%cCyan% 6 %cPink%] %cWhite%New Project         %cPink%[%cCyan% 7 %cPink%] %cWhite%Scan Projects
echo %cPink%[%cCyan% 8 %cPink%] %cWhite%Open Webapps        %cPink%[%cCyan% 9 %cPink%] %cWhite%Open Localhost
echo.
echo %cBlue%--- SYSTEM ---------------------------------------------%cReset%
echo %cPink%[%cCyan% S %cPink%] %cWhite%Config Paths        %cPink%[%cCyan% D %cPink%] %cWhite%Download Tools
echo %cPink%[%cCyan% C %cPink%] %cYellow%Config Files%cWhite%        %cPink%[%cCyan% R %cPink%] %cWhite%Refresh Status
echo %cPink%[%cCyan% 0 %cPink%] %cGray%Exit%cWhite%
echo.
echo %cBlue%--------------------------------------------------------%cReset%

set "opt="
set /p "opt=> Chon chuc nang: "
REM Remove quotes if user typed them
set "opt=!opt:"=!"

REM Tomcat Actions
if "!opt!"=="1" goto :ACT_START
if "!opt!"=="2" goto :ACT_STOP
if "!opt!"=="3" goto :ACT_RESTART
if "!opt!"=="4" goto :ACT_VIEW_LOGS
if "!opt!"=="5" goto :ACT_ADD_USER
if "!opt!"=="6" goto :ACT_NEW_PROJ
if "!opt!"=="7" goto :ACT_SCAN
if "!opt!"=="8" start "" "%WEBAPPS_FOLDER%" & goto :MAIN_MENU
if "!opt!"=="9" start "" "%LOCALHOST_URL%" & goto :MAIN_MENU

REM MySQL Actions
if /I "!opt!"=="M1" goto :MYSQL_START
if /I "!opt!"=="M2" goto :MYSQL_STOP
if /I "!opt!"=="M3" goto :MYSQL_MENU
if /I "!opt!"=="M4" goto :MYSQL_RESTART
if /I "!opt!"=="M5" goto :AUTO_LAB13
if /I "!opt!"=="M6" goto :MYSQL_BACKUP
if /I "!opt!"=="M7" goto :MYSQL_RESTORE

REM System
if /I "!opt!"=="S" goto :UPDATE_PATH
if /I "!opt!"=="C" goto :CONFIG_MENU
if /I "!opt!"=="D" goto :DOWNLOAD_MENU
if /I "!opt!"=="R" goto :MAIN_MENU
if "!opt!"=="0" exit /b

echo %cRed%Lua chon khong hop le!%cWhite%
timeout /t 1 >nul
goto :MAIN_MENU

REM ==============================================================================
REM   TOMCAT EXTENSIONS
REM ==============================================================================
:ACT_ADD_USER
    cls
    echo %cCyan%--- THEM USER TOMCAT MANAGER ---%cWhite%
    echo Chuc nang nay se them user 'admin' vao tomcat-users.xml
    echo de ban truy cap: %LOCALHOST_URL%/manager/html
    echo.
    set "USER_FILE=%TOMCAT_HOME%\conf\tomcat-users.xml"
    if not exist "%USER_FILE%" ( echo %cRed%Khong tim thay file config!%cWhite% & pause & goto :MAIN_MENU )
    
    echo Sao luu file cu: tomcat-users.xml.bak
    copy /Y "%USER_FILE%" "%USER_FILE%.bak" >nul
    
    echo Dang ghi de file user mac dinh...
    (
        echo ^<?xml version="1.0" encoding="UTF-8"?^>
        echo ^<tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0"^>
        echo   ^<role rolename="manager-gui"/^>
        echo   ^<role rolename="manager-script"/^>
        echo   ^<user username="admin" password="123" roles="manager-gui,manager-script"/^>
        echo ^</tomcat-users^>
    ) > "%USER_FILE%"
    
    echo %cGreen%Da them user: admin / mat khau: 123%cWhite%
    echo Vui long Restart Tomcat de ap dung.
    pause & goto :MAIN_MENU

REM ==============================================================================
REM   MYSQL BACKUP / RESTORE
REM ==============================================================================
:MYSQL_BACKUP
    call :MYSQL_CHECK
    cls
    echo %cCyan%--- BACKUP DATABASE ---%cWhite%
    "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -e "SHOW DATABASES;"
    echo.
    set /p "dbn=> Nhap ten Database can Backup: "
    if "%dbn%"=="" goto :MAIN_MENU
    
    set "backup_file=backup_%dbn%_%random%.sql"
    echo Dang backup ra file: %cGreen%%backup_file%%cWhite%...
    
    "%MYSQL_HOME%\bin\mysqldump.exe" -u root -P %MYSQL_PORT% --databases %dbn% > "%backup_file%" 2>nul
    
    if exist "%backup_file%" (
        echo %cGreen%Backup Thanh Cong!%cWhite%
    ) else (
        echo %cRed%Backup That Bai! (Kiem tra ten DB)%cWhite%
    )
    pause & goto :MAIN_MENU

:MYSQL_RESTORE
    call :MYSQL_CHECK
    cls
    echo %cRed%--- RESTORE DATABASE ---%cWhite%
    echo WARNING: Hanh dong nay se ghi de du lieu cu.
    echo.
    dir /b *.sql
    echo.
    set /p "sqlf=> Nhap ten file .sql (Co duoi .sql): "
    if not exist "%sqlf%" ( echo %cRed%File khong ton tai!%cWhite% & pause & goto :MAIN_MENU )
    
    echo Dang Restore...
    "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% < "%sqlf%"
    
    if !errorlevel! EQU 0 ( echo %cGreen%Restore Thanh Cong!%cWhite% ) else ( echo %cRed%Co loi xay ra!%cWhite% )
    pause & goto :MAIN_MENU

REM ==============================================================================
REM   MYSQL MANAGER HANDLERS
REM ==============================================================================

:MYSQL_CHECK
    if "%MYSQL_HOME%"=="" ( echo %cRed%Chua cau hinh MySQL Home!%cWhite% & pause & goto :MAIN_MENU )
    if not exist "%MYSQL_HOME%\bin\mysql.exe" ( echo %cRed%Khong tim thay mysql.exe!%cWhite% & pause & goto :MAIN_MENU )
    exit /b

:MYSQL_START
    call :MYSQL_CHECK
    if "%MYSQL_STATUS_RAW%"=="RUNNING" ( echo %cYellow%MySQL dang chay roi!%cWhite% & pause & goto :MAIN_MENU )
    
    REM Auto Repair Config
    if not exist "!MYSQL_HOME!\my.ini" call :REPAIR_MYSQL_CONF
    
    REM Auto Init Data
    if not exist "!MYSQL_HOME!\data" call :AUTO_INIT_DATA

    echo %cGreen%Dang bat MySQL Server...%cWhite%
    
    REM Start Server
    pushd "!MYSQL_HOME!\bin" && start "MySQL Server Console" mysqld.exe --console && popd
    
    timeout /t 3 >nul
    goto :MAIN_MENU

:AUTO_INIT_DATA
    echo %cYellow%Du lieu (Data) chua ton tai. Dang khoi tao...%cWhite%
    pushd "!MYSQL_HOME!\bin"
    mysqld.exe --initialize-insecure
    popd
    echo %cGreen%Da khoi tao xong Data (Root/NoPass)%cWhite%
    exit /b

:REPAIR_MYSQL_CONF
    echo %cYellow%Phat hien thieu file config (my.ini)!%cWhite%
    echo Dang tao lai file mac dinh cho: !MYSQL_HOME!
    (
        echo [mysqld]
        echo basedir=!MYSQL_HOME:\=/!
        echo datadir=!MYSQL_HOME:\=/!/data
        echo port=%MYSQL_PORT%
        echo character-set-server=utf8mb4
        echo [client]
        echo default-character-set=utf8mb4
    ) > "!MYSQL_HOME!\my.ini"
    echo %cGreen%Da tao file my.ini xong.%cWhite%
    exit /b

:MYSQL_STOP
    call :MYSQL_CHECK
    echo %cRed%Dang tat MySQL...%cWhite%
    "%MYSQL_HOME%\bin\mysqladmin.exe" -u root -P %MYSQL_PORT% shutdown 2>nul
    if !errorlevel! NEQ 0 ( taskkill /F /IM mysqld.exe /T 2>nul )
    timeout /t 2 >nul
    goto :MAIN_MENU

:MYSQL_RESTART
    call :MYSQL_STOP
    timeout /t 2 >nul
    call :MYSQL_START
    goto :MAIN_MENU

:AUTO_LAB13
    call :MYSQL_CHECK
    cls
    echo %cCyan%--- AUTO SETUP LAB 13 ---%cWhite%
    
    set "CMD_SQL=DROP DATABASE IF EXISTS lab13_jdbc; CREATE DATABASE lab13_jdbc; USE lab13_jdbc; CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50), email VARCHAR(100)); INSERT INTO users(username, email) VALUES('admin', 'admin@gmail.com');"
    
    "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -e "!CMD_SQL!"
    
    if !errorlevel! EQU 0 (
        echo %cGreen%Tao Database va Table thanh cong!%cWhite%
        echo Added 1 user demo (admin).
    ) else (
        echo %cRed%Loi! Hay chac chan MySQL da duoc BAT (Start).%cWhite%
    )
    pause
    goto :MAIN_MENU

:MYSQL_MENU
    call :MYSQL_CHECK
    cls
    echo %cGreen%--- MYSQL QUERY MANAGER ---%cWhite%
    echo.
    echo    1. Show Databases
    echo    2. Create Database
    echo    3. Use Database & Manage Tables
    echo    4. Run Custom SQL Query
    echo    0. Quay lai
    echo.
    set "mq="
    set /p "mq=> Lua chon: "
    set "mq=!mq:"=!"
    
    if "!mq!"=="1" (
        "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -e "SHOW DATABASES;"
        pause & goto :MYSQL_MENU
    )
    if "!mq!"=="2" (
        set /p "dbn=> Nhap ten Database moi: "
        if "!dbn!"=="" ( echo Emtpy! & pause & goto :MYSQL_MENU )
        "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -e "CREATE DATABASE !dbn!;"
        echo Done. & pause & goto :MYSQL_MENU
    )
    if "!mq!"=="3" goto :MYSQL_TABLE_MENU
    if "!mq!"=="4" (
        set /p "csql=> Nhap lenh SQL: "
        if "!csql!"=="" ( echo Empty! & pause & goto :MYSQL_MENU )
        "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -e "!csql!"
        pause & goto :MYSQL_MENU
    )
    if "!mq!"=="0" goto :MAIN_MENU
    goto :MYSQL_MENU

:MYSQL_TABLE_MENU
    cls
    echo %cYellow%--- TABLE MANAGER ---%cWhite%
    set /p "use_db=> Nhap ten Database muon dung: "
    
    "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -e "USE !use_db!;" 2>nul
    if !errorlevel! NEQ 0 ( echo %cRed%Database khong ton tai!%cWhite% & pause & goto :MYSQL_MENU )

    :TABLE_LOOP
    cls
    echo Database: %cGreen%!use_db!%cWhite%
    echo.
    echo    1. Show Tables
    echo    2. Create Table
    echo    3. Select * From Table
    echo    4. Describe Table (Cau truc)
    echo    5. Drop Table
    echo    0. Quay lai
    echo.
    set /p "tq=> Lua chon: "
    
    if "%tq%"=="0" goto :MYSQL_MENU
    
    if "%tq%"=="1" (
        "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -D "!use_db!" -e "SHOW TABLES;"
        pause & goto :TABLE_LOOP
    )
    if "%tq%"=="2" (
        echo Nhap cau lenh CREATE TABLE
        set /p "ctsql=> SQL: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -D "!use_db!" -e "!ctsql!"
        pause & goto :TABLE_LOOP
    )
    if "%tq%"=="3" (
        set /p "tbl=> Ten bang: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -D "!use_db!" -e "SELECT * FROM !tbl!;"
        pause & goto :TABLE_LOOP
    )
    if "%tq%"=="4" (
        set /p "tbl=> Ten bang: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -D "!use_db!" -e "DESCRIBE !tbl!;"
        pause & goto :TABLE_LOOP
    )
    if "%tq%"=="5" (
        set /p "tbl=> Ten bang can XOA: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -P %MYSQL_PORT% -D "!use_db!" -e "DROP TABLE !tbl!;"
        echo Deleted. & pause & goto :TABLE_LOOP
    )
    goto :TABLE_LOOP

REM ==============================================================================
REM   CONFIG MANAGER (XAMPP STYLE)
REM ==============================================================================
:CONFIG_MENU
    cls
    echo %cCyan%--- SYSTEM CONFIGURATION ---%cWhite%
    echo.
    echo %cYellow%[ TOMCAT ]%cWhite%
    echo    1. server.xml       (Ports, Connectors)
    echo    2. tomcat-users.xml (Users, Roles)
    echo    3. web.xml          (Global Mappings)
    echo    4. context.xml      (Context Config)
    echo.
    echo %cYellow%[ MYSQL ]%cWhite%
    echo    5. my.ini           (MySQL Config)
    echo.
    echo    0. Back
    echo.
    set /p "cfg_opt=> Open: "
    
    if "%cfg_opt%"=="1" call :OPEN_FILE "%TOMCAT_HOME%\conf\server.xml"
    if "%cfg_opt%"=="2" call :OPEN_FILE "%TOMCAT_HOME%\conf\tomcat-users.xml"
    if "%cfg_opt%"=="3" call :OPEN_FILE "%TOMCAT_HOME%\conf\web.xml"
    if "%cfg_opt%"=="4" call :OPEN_FILE "%TOMCAT_HOME%\conf\context.xml"
    if "%cfg_opt%"=="5" call :OPEN_FILE "%MYSQL_HOME%\my.ini"
    if "%cfg_opt%"=="0" goto :MAIN_MENU
    goto :CONFIG_MENU

:OPEN_FILE
    if not exist "%~1" (
        echo %cRed%File khong ton tai: %~1%cWhite%
        pause
    ) else (
        echo Opening %~nx1...
        start "" "%~1"
    )
    exit /b

REM ==============================================================================
REM   DOWNLOAD & INSTALL HANDLERS
REM ==============================================================================
:DOWNLOAD_MENU
    cls
    echo %cCyan%--- DOWNLOAD TOOLS ---%cWhite%
    echo    1. Tai MySQL JDBC Driver (Maven)
    echo    2. Tai MySQL Server (Zip)
    echo    3. Tai Java JDK (21/8)
    echo    0. Quay lai
    set /p "dlo=> Chon: "
    if "%dlo%"=="1" goto :ACT_DL_JDBC
    if "%dlo%"=="2" goto :ACT_DL_MYSQL_SERVER
    if "%dlo%"=="3" goto :ACT_DL_JDK
    goto :MAIN_MENU

:ACT_DL_JDK
    cls
    echo %cCyan%--- TAI ORACLE JDK (LATEST) ---%cWhite%
    set /p "v=> Phien ban (17/21/25): "
    if "%v%"=="" set "v=21"
    
    set "d=C:\java"
    set /p "d=> Location (Enter=%d%): "
    set "d=!d:"=!"
    
    if not exist "!d!" mkdir "!d!"
    set "URL=https://download.oracle.com/java/!v!/latest/jdk-!v!_windows-x64_bin.zip"
    set "ZIP_FILE=!d!\jdk.zip"
    
    echo 1. Dang tai JDK !v! tu Oracle...
    powershell -Command "Start-BitsTransfer -Source '%URL%' -Destination '%ZIP_FILE%'"
    
    if not exist "!ZIP_FILE!" ( echo %cRed%Tai that bai!%cWhite% & pause & goto :MAIN_MENU )
    
    echo 2. Dang giai nen...
    powershell -Command "Expand-Archive -Path '!ZIP_FILE!' -DestinationPath '!d!' -Force"
    del "!ZIP_FILE!"
    
    echo %cGreen%Cai dat Hoan tat!%cWhite%
    echo Thu muc: !d!
    echo.
    echo %cYellow%[TIP] Set bien moi truong: setx JAVA_HOME "!d!\jdk-!v!..."%cWhite%
    pause & goto :MAIN_MENU

:ACT_DL_MYSQL_SERVER
    cls
    set "MYSQL_VER=9.4.0"
    echo %cCyan%--- TAI & CAI DAT MYSQL SERVER %MYSQL_VER% (LTS) ---%cWhite%
    echo Link: https://downloads.mysql.com/archives/get/p/23/file/mysql-%MYSQL_VER%-winx64.zip
    echo.
    set "M_ROOT=C:\mysql"
    set /p "ip=> Nhap thu muc cai (Enter = %M_ROOT%): "
    if not "%ip%"=="" set "M_ROOT=%ip%"
    set "M_ROOT=!M_ROOT:"=!"

    if exist "!M_ROOT!\bin\mysqld.exe" (
        echo %cGreen%MySQL da co tai: !M_ROOT!%cWhite%
        set "MYSQL_HOME=!M_ROOT!"
        call :SAVE_CFG "!TOMCAT_HOME!" "!TOMCAT_PORT!" "!M_ROOT!" "!MYSQL_PORT!"
        pause & goto :MAIN_MENU
    )
    if not exist "!M_ROOT!" mkdir "!M_ROOT!"
    set "ZIP_FILE=!M_ROOT!\mysql.zip"
    set "URL=https://cloud.nguyenquocanh.io.vn/mysql-%MYSQL_VER%-winx64.zip"

    echo 1. Dang tai (300MB+)...
    powershell -Command "Start-BitsTransfer -Source '%URL%' -Destination '%ZIP_FILE%'"
    
    if not exist "!ZIP_FILE!" ( echo %cRed%Tai that bai!%cWhite% & pause & goto :MAIN_MENU )

    echo 2. Dang giai nen...
    powershell -Command "Expand-Archive -Path '!ZIP_FILE!' -DestinationPath '!M_ROOT!' -Force"
    
    for /d %%D in ("!M_ROOT!\mysql-*") do (
        xcopy "%%D\*" "!M_ROOT!\" /E /H /Y /Q >nul
        rmdir /s /q "%%D"
    )
    del "!ZIP_FILE!"

    echo 3. Tao file my.ini...
    (
        echo [mysqld]
        echo basedir=!M_ROOT:\=/!
        echo datadir=!M_ROOT:\=/!/data
        echo port=3306
        echo character-set-server=utf8mb4
        echo [client]
        echo default-character-set=utf8mb4
    ) > "!M_ROOT!\my.ini"

    echo 4. Khoi tao Data (No Password)...
    pushd "!M_ROOT!\bin" && mysqld.exe --initialize-insecure && popd
    
    echo.
    echo %cYellow%Cho 20s de MySQL on dinh...%cWhite%
    timeout /t 20
    
    echo 5. Tu dong bat MySQL...
    pushd "!M_ROOT!\bin" && start "MySQL Server Console" mysqld.exe --console && popd
    
    echo %cGreen%Cai dat & Khoi dong Hoan tat!%cWhite%
    set "MYSQL_HOME=!M_ROOT!"
    call :SAVE_CFG "!TOMCAT_HOME!" "!TOMCAT_PORT!" "!M_ROOT!" "!MYSQL_PORT!"
    pause & goto :MAIN_MENU

:ACT_DL_JDBC
    cls
    echo %cCyan%--- TAI JDBC DRIVER ---%cWhite%
:ACT_DL_JDBC
    cls
    echo %cCyan%--- TAI JDBC DRIVER (MAVEN) ---%cWhite%
    set "VER=9.1.0"
    set "DL_URL=https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/!VER!/mysql-connector-j-!VER!.jar"
    set "DEST_FILE=%TOMCAT_HOME%\lib\mysql-connector-j-!VER!.jar"
    
    echo 1. Dang tai mysql-connector-j-!VER!.jar tu Maven Central...
    powershell -Command "Start-BitsTransfer -Source '%DL_URL%' -Destination '%DEST_FILE%'"
    
    if exist "%DEST_FILE%" (
        echo %cGreen%Tai thanh cong! File da luu tai:%cWhite%
        echo %DEST_FILE%
        echo.
        echo Vui long Restart Tomcat de ap dung Driver moi.
    ) else (
        echo %cRed%Tai that bai! Kiem tra lai mang.%cWhite%
    )
    
    pause & goto :MAIN_MENU

REM ==============================================================================
REM   TOMCAT HANDLERS
REM ==============================================================================

:ACT_NEW_PROJ
    cls
    echo %cCyan%--- TAO PROJECT ---%cWhite%
    set /p pName="> Ten Project: "
    if "%pName%"=="" goto :MAIN_MENU
    set "TPATH=%WEBAPPS_FOLDER%\%pName%"
    if exist "%TPATH%" goto :MAIN_MENU
    mkdir "%TPATH%\WEB-INF\classes" 2>nul
    mkdir "%TPATH%\WEB-INF\lib" 2>nul
    
    echo 1. Basic Servlet (Lab 12)
    echo 2. JDBC Template (Lab 13)
    set /p "t=> Chon: "
    
    (
        echo ^<h1^>%pName%^</h1^>
        echo ^<a href="hello"^>Test Servlet^</a^>
    ) > "%TPATH%\index.html"
    
    if "%t%"=="2" ( call :GEN_JDBC "%TPATH%" ) else ( call :GEN_BASIC "%TPATH%" "%pName%" )
    echo %cGreen%Done.%cWhite% & pause & goto :MAIN_MENU

:ACT_BUILD
    cls
    echo %cYellow%--- COMPILING ---%cWhite%
    set "PP=%WEBAPPS_FOLDER%\!SEL_P!"
    set "CP=!PP!\WEB-INF\classes"
    if not exist "!CP!" mkdir "!CP!"
    
    set "CLASSPATH=%TOMCAT_HOME%\lib\*;!PP!\WEB-INF\lib\*"
    set "SRC_LIST=!PP!\sources.txt"
    
    REM Find all Java files
    if exist "!SRC_LIST!" del "!SRC_LIST!"
    dir "!PP!" /s /b /a-d | findstr /i "\.java$" > "!SRC_LIST!"
    
    REM Check if any file found
    for %%A in ("!SRC_LIST!") do if %%~zA==0 (
        echo %cRed%Khong tim thay file .java nào!%cWhite%
        del "!SRC_LIST!"
        pause & goto :PROJ_MENU
    )
    
    echo Found sources. Compiling...
    javac -cp "!CLASSPATH!" -d "!CP!" @"!SRC_LIST!"
    
    if !errorlevel! EQU 0 ( echo %cGreen%Build Success!%cWhite% ) else ( echo %cRed%Build Failed! Check errors above.%cWhite% )
    
    del "!SRC_LIST!" >nul 2>nul
    pause & goto :PROJ_MENU

:GEN_BASIC
    (
        echo import jakarta.servlet.annotation.WebServlet;
        echo import jakarta.servlet.http.*;
        echo import java.io.IOException;
        echo @WebServlet^("/hello"^)
        echo public class HelloServlet extends HttpServlet {
        echo     protected void doGet^(HttpServletRequest req, HttpServletResponse resp^) throws IOException {
        echo         resp.getWriter^(^).println^("Hello %~2"^);
        echo     }
        echo }
    ) > "%~1\HelloServlet.java"
    exit /b

:GEN_JDBC
    (
        echo import jakarta.servlet.annotation.WebServlet;
        echo import jakarta.servlet.http.*;
        echo import java.io.*;
        echo import java.sql.*;
        echo @WebServlet^("/testdb"^)
        echo public class TestDB extends HttpServlet {
        echo     protected void doGet^(HttpServletRequest req, HttpServletResponse resp^) throws IOException {
        echo         resp.setContentType^("text/html"^);
        echo         try {
        echo             Class.forName^("com.mysql.cj.jdbc.Driver"^);
        echo             Connection conn = DriverManager.getConnection^("jdbc:mysql://localhost:%MYSQL_PORT%/lab13_jdbc", "root", ""^);
        echo             resp.getWriter^(^).println^("DB Connected!"^);
        echo             conn.close^(^);
        echo         } catch ^(Exception e^) { e.printStackTrace^(resp.getWriter^(^)^); }
        echo     }
        echo }
    ) > "%~1\TestDB.java"
    exit /b

:ACT_START
    if "%SERVER_STATUS_RAW%"=="RUNNING" ( echo %cYellow%Running!%cWhite% & pause & goto :MAIN_MENU )
    cd /d "%TOMCAT_HOME%\bin" && start "Tomcat" catalina.bat run
    timeout /t 5 >nul & goto :MAIN_MENU

:ACT_STOP
    cd /d "%TOMCAT_HOME%\bin" && call shutdown.bat
    goto :MAIN_MENU

:ACT_RESTART
    call :ACT_STOP
    timeout /t 3 >nul
    call :ACT_START
    goto :MAIN_MENU

:ACT_VIEW_LOGS
    powershell -Command "Get-Content '%TOMCAT_HOME%\logs\catalina.out' -Wait -Tail 20"
    goto :MAIN_MENU

:ACT_SCAN
    cls
    echo %cCyan%--- PROJECTS ---%cWhite%
    set "cnt=0"
    for /d %%D in ("%WEBAPPS_FOLDER%\*") do (
        set /a cnt+=1
        set "P[!cnt!]=%%~nxD"
        echo !cnt!. %%~nxD
    )
    set /p "pc=> Chon: "
    if defined P[%pc%] set "SEL_P=!P[%pc%]!" & goto :PROJ_MENU
    goto :MAIN_MENU

:PROJ_MENU
    cls
    echo %cCyan%--- PROJECT MANAGER ---%cWhite%
    echo Project: %cGreen%!SEL_P!%cWhite%
    echo.
    echo    1. Build (Compile Java)
    echo    2. Open Browser (Chrome/Edge)
    echo    3. Edit Source (VS Code)
    echo    4. Delete Project
    echo    0. Back
    echo.
    set /p "o=> Lua chon: "
    
    if "%o%"=="1" goto :ACT_BUILD
    if "%o%"=="2" start "" "%LOCALHOST_URL%/!SEL_P!" & goto :PROJ_MENU
    if "%o%"=="3" (
        where code >nul 2>nul
        if !errorlevel! EQU 0 (
            echo Opening in VS Code...
            code "%WEBAPPS_FOLDER%\!SEL_P!"
        ) else (
            echo %cYellow%VS Code khong tim thay! Opening Explorer...%cWhite%
            start "" "%WEBAPPS_FOLDER%\!SEL_P!"
            pause
        )
        goto :PROJ_MENU
    )
    if "%o%"=="4" rmdir /s /q "%WEBAPPS_FOLDER%\!SEL_P!" & goto :ACT_SCAN
    if "%o%"=="0" goto :ACT_SCAN
    goto :PROJ_MENU

REM ==============================================================================
REM   CORE FUNCTIONS
REM ==============================================================================
:CHECK_SYSTEM_STATUS
    REM Check Java
    java -version >nul 2>&1
    if !errorlevel! EQU 0 ( set "JAVA_STATUS=OK" ) else ( set "JAVA_STATUS=%cRed%MISSING (Check JAVA_HOME)%cWhite%" )
    
    REM Check Tomcat
    netstat -ano 2>nul | findstr /R /C:":%TOMCAT_PORT% .*LISTENING" >nul
    if !errorlevel! EQU 0 ( set "SERVER_STATUS=%cGreen%ONLINE%cWhite%" & set "SERVER_STATUS_RAW=RUNNING" ) else ( set "SERVER_STATUS=%cRed%OFFLINE%cWhite%" & set "SERVER_STATUS_RAW=STOPPED" )
    
    REM Check MySQL
    netstat -ano 2>nul | findstr /R /C:":%MYSQL_PORT% .*LISTENING" >nul
    if !errorlevel! EQU 0 ( set "MYSQL_STATUS=%cGreen%ONLINE%cWhite%" & set "MYSQL_STATUS_RAW=RUNNING" ) else ( set "MYSQL_STATUS=%cRed%OFFLINE%cWhite%" & set "MYSQL_STATUS_RAW=STOPPED" )
    exit /b

:LOAD_CFG
    REM Load INI file (Key=Value pairs)
    for /f "tokens=1,2 delims==" %%a in (%CONFIG_FILE%) do (
        set "KEY=%%a"
        set "VAL=%%b"
        if "!KEY!"=="TOMCAT_HOME" set "TOMCAT_HOME=!VAL!"
        if "!KEY!"=="TOMCAT_PORT" set "TOMCAT_PORT=!VAL!"
        if "!KEY!"=="MYSQL_HOME" (
            set "VAL=%%b"
            if "!VAL:~-4!"=="\bin" set "VAL=!VAL:~0,-4!"
            set "MYSQL_HOME=!VAL!"
        )
        if "!KEY!"=="MYSQL_PORT" set "MYSQL_PORT=!VAL!"
    )
    if "%TOMCAT_PORT%"=="" set "TOMCAT_PORT=%DEFAULT_PORT%"
    if "%MYSQL_PORT%"=="" set "MYSQL_PORT=%DEFAULT_MYSQL_PORT%"
    exit /b

:SAVE_CFG
    REM %1=Tomcat, %2=TPort, %3=MySQL, %4=MPort
    (
        echo TOMCAT_HOME=%~1
        echo TOMCAT_PORT=%~2
        echo MYSQL_HOME=%~3
        echo MYSQL_PORT=%~4
    ) > "%CONFIG_FILE%"
    exit /b

:VAL_HOME
    if "%TOMCAT_HOME%"=="" exit /b 1
    exit /b 0

:INIT_VARS
    set "WEBAPPS_FOLDER=%TOMCAT_HOME%\webapps"
    set "LOCALHOST_URL=http://localhost:%TOMCAT_PORT%"
    exit /b

:UPDATE_PATH
    cls
    echo %cYellow%--- CAU HINH HE THONG ---%cWhite%
    if defined MSG echo %cRed%!MSG!%cWhite%
    
    echo Hien tai:
    echo 1. Tomcat Home: %TOMCAT_HOME%
    echo 2. Tomcat Port: %TOMCAT_PORT%
    echo 3. MySQL Home:  %MYSQL_HOME%
    echo 4. MySQL Port:  %MYSQL_PORT%
    echo.
    echo Enter de bo qua, hoac nhap gia tri moi.
    
    set /p "T=> Nhap Tomcat Home: "
    set /p "TP=> Nhap Tomcat Port (Def 8080): "
    set /p "M=> Nhap MySQL Home: "
    set /p "MP=> Nhap MySQL Port (Def 3306): "
    
    if not "%T%"=="" set "TOMCAT_HOME=%T:"=%"
    if not "%TP%"=="" set "TOMCAT_PORT=%TP%"
    if not "%M%"=="" set "MYSQL_HOME=%M:"=%"
    if not "%MP%"=="" set "MYSQL_PORT=%MP%"
    
    if "%TOMCAT_PORT%"=="" set "TOMCAT_PORT=%DEFAULT_PORT%"
    if "%MYSQL_PORT%"=="" set "MYSQL_PORT=%DEFAULT_MYSQL_PORT%"
    
    call :SAVE_CFG "!TOMCAT_HOME!" "!TOMCAT_PORT!" "!MYSQL_HOME!" "!MYSQL_PORT!"
    call :INIT_VARS
    set "MSG="
    goto :MAIN_MENU
