@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - FULLSTACK V8 (MySQL + Tomcat)
REM   Author: Nguyen Quoc Anh (NQA TECH) & Gemini
REM   Description: Support Lab 12 (Servlet) & Lab 13 (JDBC/MySQL)
REM ==============================================================================

REM --- 1. KHOI TAO MA MAU (ANSI COLORS) ---
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "cGreen=%ESC%[92m"
set "cRed=%ESC%[91m"
set "cYellow=%ESC%[93m"
set "cCyan=%ESC%[96m"
set "cWhite=%ESC%[0m"
set "cGray=%ESC%[90m"
set "cBlue=%ESC%[94m"

REM --- 2. CAU HINH MAC DINH ---
set "CONFIG_FILE=data.json"
set "DEFAULT_PORT=8080"
set "TOMCAT_PORT=%DEFAULT_PORT%"
set "TOMCAT_HOME="
set "MYSQL_HOME="
set "MSG="

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
call :CHECK_SYSTEM_STATUS

echo %cBlue%============================================================%cWhite%
echo    FULLSTACK TOMCAT V8 %cYellow%(Tomcat + MySQL Manager)%cWhite%
echo %cBlue%============================================================%cWhite%
echo.
echo    %cGray%Tomcat Home:%cWhite% %TOMCAT_HOME%
echo    %cGray%MySQL Home: %cWhite% %MYSQL_HOME%
echo.
echo    STATUS: Tomcat (8080): %SERVER_STATUS%
echo            MySQL  (3306): %MYSQL_STATUS%
echo.
echo %cGray%--- TOMCAT SERVER ------------------------------------------%cWhite%
echo    1. Start Tomcat            2. Stop Tomcat
echo    3. Restart Tomcat          4. %cYellow%Xem Logs Tomcat%cWhite%
echo.
echo %cGray%--- MYSQL DATABASE -----------------------------------------%cWhite%
echo    M1. Start MySQL            M2. Stop MySQL
echo    M3. %cGreen%Quan ly CSDL (SQL Menu)%cWhite%  M4. Restart MySQL
echo    M5. %cCyan%Auto Setup Lab 13 DB%cWhite% (Tao db/table Users)
echo.
echo %cGray%--- PROJECT----------------------------------------%cWhite%
echo    5. Tao Project (Servlet/JDBC)  6. Quan ly Project
echo    7. Mo Webapps                  8. Mo Localhost
echo.
echo %cGray%--- DOWNLOAD SETUP---------------------------------------%cWhite%
echo    D1. %cCyan%Tai MySQL JDBC Driver%cWhite% (cho Tomcat Lib)
echo    D2. %cCyan%Tai va Cai MySQL Server%cWhite% (Zip 9.4.0)
echo    9.  Cau hinh Path              0. Thoat
echo.
echo %cGray%------------------------------------------------------------%cWhite%

set "opt="
set /p "opt=> Chon chuc nang: "

REM Tomcat Actions
if "%opt%"=="1" goto :ACT_START
if "%opt%"=="2" goto :ACT_STOP
if "%opt%"=="3" goto :ACT_RESTART
if "%opt%"=="4" goto :ACT_VIEW_LOGS
if "%opt%"=="5" goto :ACT_NEW_PROJ
if "%opt%"=="6" goto :ACT_SCAN
if "%opt%"=="7" start "" "%WEBAPPS_FOLDER%" & goto :MAIN_MENU
if "%opt%"=="8" start "" "%LOCALHOST_URL%" & goto :MAIN_MENU
if "%opt%"=="9" goto :UPDATE_PATH
if "%opt%"=="0" exit /b

REM MySQL Actions
if /I "%opt%"=="M1" goto :MYSQL_START
if /I "%opt%"=="M2" goto :MYSQL_STOP
if /I "%opt%"=="M3" goto :MYSQL_MENU
if /I "%opt%"=="M4" goto :MYSQL_RESTART
if /I "%opt%"=="M5" goto :AUTO_LAB13

REM Download Actions
if /I "%opt%"=="D1" goto :ACT_DL_JDBC
if /I "%opt%"=="D2" goto :ACT_DL_MYSQL_SERVER

echo %cRed%Lua chon khong hop le!%cWhite%
timeout /t 1 >nul
goto :MAIN_MENU

REM ==============================================================================
REM   MYSQL MANAGER HANDLERS
REM ==============================================================================

:MYSQL_CHECK
    if "%MYSQL_HOME%"=="" ( echo %cRed%Chua cau hinh MySQL Home! Vui long tai MySQL truoc.%cWhite% & pause & goto :MAIN_MENU )
    if not exist "%MYSQL_HOME%\bin\mysql.exe" ( echo %cRed%Khong tim thay mysql.exe!%cWhite% & pause & goto :MAIN_MENU )
    exit /b

:MYSQL_START
    call :MYSQL_CHECK
    if "%MYSQL_STATUS_RAW%"=="RUNNING" ( echo %cYellow%MySQL dang chay roi!%cWhite% & pause & goto :MAIN_MENU )
    echo %cGreen%Dang bat MySQL Server...%cWhite%
    start "MySQL Server" /min "%MYSQL_HOME%\bin\mysqld.exe" --console
    timeout /t 3 >nul
    goto :MAIN_MENU

:MYSQL_STOP
    call :MYSQL_CHECK
    echo %cRed%Dang tat MySQL...%cWhite%
    "%MYSQL_HOME%\bin\mysqladmin.exe" -u root shutdown 2>nul
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
    echo Lenh nay se thuc hien [cite: 260-267]:
    echo 1. DROP database lab13_jdbc (neu co).
    echo 2. CREATE database lab13_jdbc.
    echo 3. CREATE table users (id, username, email).
    echo.
    pause
    
    set "CMD_SQL=DROP DATABASE IF EXISTS lab13_jdbc; CREATE DATABASE lab13_jdbc; USE lab13_jdbc; CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50), email VARCHAR(100));"
    
    "%MYSQL_HOME%\bin\mysql.exe" -u root -e "!CMD_SQL!"
    
    if !errorlevel! EQU 0 (
        echo %cGreen%Tao Database va Table thanh cong!%cWhite%
        echo Bay gio ban co the chay Project Lab 13.
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
    set /p "mq=> Lua chon: "
    
    if "%mq%"=="1" (
        "%MYSQL_HOME%\bin\mysql.exe" -u root -e "SHOW DATABASES;"
        pause & goto :MYSQL_MENU
    )
    if "%mq%"=="2" (
        set /p "dbn=> Nhap ten Database moi: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -e "CREATE DATABASE !dbn!;"
        echo Done. & pause & goto :MYSQL_MENU
    )
    if "%mq%"=="3" goto :MYSQL_TABLE_MENU
    if "%mq%"=="4" (
        set /p "csql=> Nhap lenh SQL: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -e "!csql!"
        pause & goto :MYSQL_MENU
    )
    if "%mq%"=="0" goto :MAIN_MENU
    goto :MYSQL_MENU

:MYSQL_TABLE_MENU
    cls
    echo %cYellow%--- TABLE MANAGER ---%cWhite%
    set /p "use_db=> Nhap ten Database muon dung: "
    
    REM Check DB exist
    "%MYSQL_HOME%\bin\mysql.exe" -u root -e "USE !use_db!;" 2>nul
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
    
    if "%tq%"=="1" (
        "%MYSQL_HOME%\bin\mysql.exe" -u root -D "!use_db!" -e "SHOW TABLES;"
        pause & goto :TABLE_LOOP
    )
    if "%tq%"=="2" (
        echo Nhap cau lenh CREATE TABLE (VD: CREATE TABLE test(id int); )
        set /p "ctsql=> SQL: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -D "!use_db!" -e "!ctsql!"
        pause & goto :TABLE_LOOP
    )
    if "%tq%"=="3" (
        set /p "tbl=> Ten bang: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -D "!use_db!" -e "SELECT * FROM !tbl!;"
        pause & goto :TABLE_LOOP
    )
    if "%tq%"=="4" (
        set /p "tbl=> Ten bang: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -D "!use_db!" -e "DESCRIBE !tbl!;"
        pause & goto :TABLE_LOOP
    )
    if "%tq%"=="5" (
        set /p "tbl=> Ten bang can XOA: "
        "%MYSQL_HOME%\bin\mysql.exe" -u root -D "!use_db!" -e "DROP TABLE !tbl!;"
        echo Deleted. & pause & goto :TABLE_LOOP
    )
    if "%tq%"=="0" goto :MYSQL_MENU
    goto :TABLE_LOOP

REM ==============================================================================
REM   DOWNLOAD & INSTALL HANDLERS
REM ==============================================================================

:ACT_DL_MYSQL_SERVER
    cls
    echo %cCyan%--- TAI & CAI DAT MYSQL SERVER 9.4.0 ---%cWhite%
    echo Link: https://downloads.mysql.com/archives/get/p/23/file/mysql-9.4.0-winx64.zip
    echo.
    
    set "M_ROOT=C:\mysql"
    set /p "ip=> Nhap thu muc cai (Enter = C:\mysql): "
    if not "%ip%"=="" set "M_ROOT=%ip%"
    set "M_ROOT=!M_ROOT:"=!"

    if exist "!M_ROOT!\bin\mysqld.exe" (
        echo %cGreen%MySQL da co tai: !M_ROOT!%cWhite%
        set "MYSQL_HOME=!M_ROOT!"
        call :SAVE_CFG "%TOMCAT_HOME%" "%TOMCAT_PORT%" "!M_ROOT!"
        pause & goto :MAIN_MENU
    )

    if not exist "!M_ROOT!" mkdir "!M_ROOT!"
    set "ZIP_FILE=!M_ROOT!\mysql.zip"
    set "URL=https://downloads.mysql.com/archives/get/p/23/file/mysql-9.4.0-winx64.zip"

    echo 1. Dang tai (300MB+)...
    powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP_FILE%'"
    
    if not exist "!ZIP_FILE!" ( echo %cRed%Tai that bai!%cWhite% & pause & goto :MAIN_MENU )

    echo 2. Dang giai nen...
    powershell -Command "Expand-Archive -Path '!ZIP_FILE!' -DestinationPath '!M_ROOT!' -Force"
    
    REM Move files from subfolder
    for /d %%D in ("!M_ROOT!\mysql-*") do (
        xcopy "%%D\*" "!M_ROOT!\" /E /H /Y /Q >nul
        rmdir /s /q "%%D"
    )
    del "!ZIP_FILE!"

    echo 3. Tao file my.ini...
    (
        echo [mysqld]
        echo basedir=!M_ROOT:/=\!
        echo datadir=!M_ROOT:/=\!\data
        echo port=3306
        echo character-set-server=utf8mb4
        echo [client]
        echo default-character-set=utf8mb4
    ) > "!M_ROOT!\my.ini"

    echo 4. Khoi tao Data (No Password)...
    "!M_ROOT!\bin\mysqld.exe" --initialize-insecure

    echo %cGreen%Cai dat Hoan tat!%cWhite%
    set "MYSQL_HOME=!M_ROOT!"
    call :SAVE_CFG "%TOMCAT_HOME%" "%TOMCAT_PORT%" "!M_ROOT!"
    pause & goto :MAIN_MENU

:ACT_DL_JDBC
    cls
    echo %cCyan%--- TAI JDBC DRIVER ---%cWhite%
    REM Su dung Maven link truc tiep de dam bao tool chay tu dong duoc (vi link web mysql can login/click)
    set "DL_URL=https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.2.0/mysql-connector-j-9.2.0.jar"
    set "OUT_FILE=%TOMCAT_HOME%\lib\mysql-connector-j-9.2.0.jar"
    
    echo Tai tu Maven Central (Ban moi nhat 9.2.0)...
    powershell -Command "Invoke-WebRequest -Uri '%DL_URL%' -OutFile '%OUT_FILE%'"
    
    if exist "%OUT_FILE%" (
        echo %cGreen%Tai thanh cong! Vui long Restart Tomcat.%cWhite%
    ) else (
        echo %cRed%Tai that bai.%cWhite%
    )
    pause & goto :MAIN_MENU

REM ==============================================================================
REM   TOMCAT HANDLERS (GIU NGUYEN TU V7)
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
    for /f "delims=" %%f in ('dir "!PP!" /s /b /a-d ^| findstr /i "\.java$"') do (
        echo .. %%~nxf
        javac -cp "!CLASSPATH!" -d "!CP!" "%%f"
    )
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
        echo             Connection conn = DriverManager.getConnection^("jdbc:mysql://localhost:3306/lab13_jdbc", "root", ""^);
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
    echo Prj: %cGreen%!SEL_P!%cWhite%
    echo 1. Build  2. Browser  3. Edit  4. Delete  0. Back
    set /p "o=> : "
    if "%o%"=="1" goto :ACT_BUILD
    if "%o%"=="2" start "" "%LOCALHOST_URL%/!SEL_P!" & goto :PROJ_MENU
    if "%o%"=="3" call code "%WEBAPPS_FOLDER%\!SEL_P!" & goto :PROJ_MENU
    if "%o%"=="4" rmdir /s /q "%WEBAPPS_FOLDER%\!SEL_P!" & goto :ACT_SCAN
    if "%o%"=="0" goto :ACT_SCAN
    goto :PROJ_MENU

REM ==============================================================================
REM   CORE FUNCTIONS
REM ==============================================================================

:CHECK_SYSTEM_STATUS
    REM Check Java
    if "%JAVA_HOME%"=="" ( set "JAVA_STATUS=MISSING" ) else ( set "JAVA_STATUS=OK" )
    
    REM Check Tomcat
    netstat -ano | findstr /R /C:":%TOMCAT_PORT% .*LISTENING" >nul
    if !errorlevel! EQU 0 ( set "SERVER_STATUS=%cGreen%ONLINE%cWhite%" & set "SERVER_STATUS_RAW=RUNNING" ) else ( set "SERVER_STATUS=%cRed%OFFLINE%cWhite%" & set "SERVER_STATUS_RAW=STOPPED" )
    
    REM Check MySQL
    netstat -ano | findstr /R /C:":3306 .*LISTENING" >nul
    if !errorlevel! EQU 0 ( set "MYSQL_STATUS=%cGreen%ONLINE%cWhite%" & set "MYSQL_STATUS_RAW=RUNNING" ) else ( set "MYSQL_STATUS=%cRed%OFFLINE%cWhite%" & set "MYSQL_STATUS_RAW=STOPPED" )
    exit /b

:LOAD_CFG
    for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "try {(Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json).TOMCAT_HOME} catch {}"`) do set "TOMCAT_HOME=%%A"
    for /f "usebackq delims=" %%B in (`powershell -NoProfile -Command "try {(Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json).MYSQL_HOME} catch {}"`) do set "MYSQL_HOME=%%B"
    exit /b

:SAVE_CFG
    REM %1=Tomcat, %2=Port, %3=MySQL
    powershell -NoProfile -Command "$d = @{ TOMCAT_HOME = '%~1'; TOMCAT_PORT = '%~2'; MYSQL_HOME = '%~3' }; $d | ConvertTo-Json | Set-Content '%CONFIG_FILE%'"
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
    echo %cYellow%--- SETUP PATHS ---%cWhite%
    if defined MSG echo %cRed%!MSG!%cWhite%
    
    echo Hien tai:
    echo Tomcat: %TOMCAT_HOME%
    echo MySQL:  %MYSQL_HOME%
    echo.
    set /p "T=> Nhap lai Tomcat Home (Enter de giu nguyen): "
    set /p "M=> Nhap lai MySQL Home (Enter de giu nguyen): "
    
    if not "%T%"=="" set "TOMCAT_HOME=%T:"=%"
    if not "%M%"=="" set "MYSQL_HOME=%M:"=%"
    
    call :SAVE_CFG "!TOMCAT_HOME!" "%DEFAULT_PORT%" "!MYSQL_HOME!"
    call :INIT_VARS
    set "MSG="
    goto :MAIN_MENU