@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==============================================================================
REM   TOMCAT MANAGER - FULLSTACK EDITION
REM   Author      : NQA TECH
REM   Version     : 10.0.0 (Cyber Neon)
REM   Description :
REM     1. Quan ly Tomcat Server (Start/Stop/Restart/Logs/User Config)
REM     2. Quan ly MySQL Database (Start/Stop/Backup/Restore/Query)
REM     3. Tu dong hoa Project Java Web (Create/Build Servlet/JDBC)
REM     4. Quan ly moi truong (Paths/Ports/JDK/Download Tools)
REM   Config      : config.ini (nam canh file script)
REM
REM   Quy uoc code:
REM     - :ACT_* / :*_MENU  la man hinh, nhay bang GOTO va ket thuc bang GOTO.
REM     - :FN_* / :NEED_*   la ham, goi bang CALL va LUON tra ve bang EXIT /B.
REM       (Khong GOTO ra khoi ham - tranh loi call stack cua cac ban cu.)
REM     - Khong dung dau cham than trong chuoi echo (EnableDelayedExpansion).
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
set "cReset=%ESC%[0m"

REM --- 2. CAU HINH MAC DINH ---
set "APP_VER=10.0.0"
set "TITLE=FULLSTACK TOMCAT V%APP_VER%"
set "APP_DIR=%~dp0"
set "CONFIG_FILE=%APP_DIR%config.ini"
set "BACKUP_DIR=%APP_DIR%backups"
set "DEFAULT_PORT=8080"
set "DEFAULT_MYSQL_PORT=3306"
set "TOMCAT_PORT=%DEFAULT_PORT%"
set "MYSQL_PORT=%DEFAULT_MYSQL_PORT%"
set "TOMCAT_HOME="
set "MYSQL_HOME="
set "CFG_JAVA_HOME="
set "MSG="
set "ORIG_PATH=%PATH%"

REM Phien ban mac dinh cho menu Download
set "DL_TOMCAT_VER=10.1.60"
set "DL_MYSQL_VER=9.4.0"
set "DL_JDBC_VER=9.1.0"
set "DL_JDK_VER=21"

REM Bo ky tu hop le (dung cho kiem tra input)
set "CS_NUM=0123456789"
set "CS_ID=0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

REM --- 3. LOAD CONFIG ---
if exist "%CONFIG_FILE%" call :FN_LOAD_CFG
if not defined TOMCAT_HOME if defined CATALINA_HOME if exist "%CATALINA_HOME%\bin\catalina.bat" set "TOMCAT_HOME=%CATALINA_HOME%"
call :FN_INIT_VARS
if not exist "!TOMCAT_HOME!\bin\catalina.bat" (
    set "MSG=Chao mung. Hay cau hinh Tomcat Home - hoac Enter bo qua roi bam D de tai Tomcat."
    goto :UPDATE_PATH
)
goto :MAIN_MENU

REM ==============================================================================
REM   MAIN MENU DASHBOARD
REM ==============================================================================
:MAIN_MENU
cls
title %TITLE%
call :FN_CHECK_STATUS

echo %cPink%    [  C Y B E R   M A N A G E R   V %APP_VER%  ]    %cWhite%
echo.
echo    %cGray%TOMCAT_HOME :: %cWhite%!TOMCAT_HOME!
echo    %cGray%MYSQL_HOME  :: %cWhite%!MYSQL_HOME!
echo    %cGray%JAVA        :: !JAVA_STATUS!
echo.
echo    %cBlue%[ STATUS MONITOR ]%cReset%
echo    %cGray%Tomcat (%TOMCAT_PORT%) :: %SERVER_STATUS%
echo    %cGray%MySQL  (%MYSQL_PORT%) :: %MYSQL_STATUS%
echo.
echo %cPink%[%cCyan% 1 %cPink%] %cWhite%Start Tomcat        %cPink%[%cCyan% 2 %cPink%] %cWhite%Stop Tomcat
echo %cPink%[%cCyan% 3 %cPink%] %cWhite%Restart Tomcat      %cPink%[%cCyan% 4 %cPink%] %cYellow%Logs Console%cWhite%
echo %cPink%[%cCyan% 5 %cPink%] %cCyan%User Manager%cGray% (manager-gui)%cWhite%
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
if defined MSG echo %cYellow%!MSG!%cWhite%
set "MSG="

call :FN_ASK opt "> Chon chuc nang: "

REM Input rong lien tuc (stdin bi dong/redirect het du lieu) thi thoat thay vi lap vo han
if defined opt ( set /a EMPTY_COUNT=0 ) else ( set /a EMPTY_COUNT+=1 )
if !EMPTY_COUNT! GEQ 30 goto :QUIT
if not defined opt goto :MAIN_MENU

REM Tomcat Actions
if "!opt!"=="1" goto :ACT_START
if "!opt!"=="2" goto :ACT_STOP
if "!opt!"=="3" goto :ACT_RESTART
if "!opt!"=="4" goto :ACT_VIEW_LOGS
if "!opt!"=="5" goto :ACT_ADD_USER
if "!opt!"=="6" goto :ACT_NEW_PROJ
if "!opt!"=="7" goto :ACT_SCAN
if "!opt!"=="8" goto :ACT_OPEN_WEBAPPS
if "!opt!"=="9" start "" "!LOCALHOST_URL!" & goto :MAIN_MENU

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
if "!opt!"=="0" goto :QUIT

set "MSG=Lua chon khong hop le."
goto :MAIN_MENU

:QUIT
    endlocal
    exit /b 0

REM ==============================================================================
REM   TOMCAT HANDLERS
REM ==============================================================================
:ACT_START
    call :NEED_TOMCAT || goto :MAIN_MENU
    call :FN_TOMCAT_START
    goto :MAIN_MENU

:ACT_STOP
    call :NEED_TOMCAT || goto :MAIN_MENU
    call :FN_TOMCAT_STOP
    goto :MAIN_MENU

:ACT_RESTART
    call :NEED_TOMCAT || goto :MAIN_MENU
    call :FN_TOMCAT_STOP
    if errorlevel 1 goto :MAIN_MENU
    call :FN_TOMCAT_START
    goto :MAIN_MENU

:ACT_OPEN_WEBAPPS
    call :NEED_TOMCAT || goto :MAIN_MENU
    start "" "!WEBAPPS_FOLDER!"
    goto :MAIN_MENU

:FN_TOMCAT_START
    call :FN_PORT_UP %TOMCAT_PORT%
    if not errorlevel 1 (
        set "MSG=Port %TOMCAT_PORT% dang duoc su dung - Tomcat da chay roi."
        exit /b 0
    )
    if not defined JAVA_VER (
        echo %cRed%Khong tim thay Java. Bam D de tai JDK hoac S de khai bao JAVA_HOME.%cWhite%
        pause
        exit /b 1
    )
    echo %cGreen%Dang bat Tomcat...%cWhite%
    start "Tomcat %TOMCAT_PORT%" /D "!TOMCAT_HOME!\bin" "!TOMCAT_HOME!\bin\catalina.bat" run
    call :FN_WAIT_PORT %TOMCAT_PORT% UP 40
    if errorlevel 1 (
        set "MSG=Tomcat chua mo port %TOMCAT_PORT% sau 40s - xem cua so Tomcat hoac Logs [4]."
        exit /b 1
    )
    set "MSG=Tomcat da san sang: !LOCALHOST_URL!"
    exit /b 0

:FN_TOMCAT_STOP
    call :FN_PORT_UP %TOMCAT_PORT%
    if errorlevel 1 (
        set "MSG=Tomcat khong chay."
        exit /b 0
    )
    echo %cRed%Dang tat Tomcat...%cWhite%
    call "!TOMCAT_HOME!\bin\shutdown.bat" >nul 2>&1
    call :FN_WAIT_PORT %TOMCAT_PORT% DOWN 15
    if not errorlevel 1 (
        set "MSG=Da tat Tomcat."
        exit /b 0
    )
    call :FN_PID_ON_PORT %TOMCAT_PORT%
    echo %cYellow%Port %TOMCAT_PORT% van dang mo boi PID !PORT_PID!.%cWhite%
    call :FN_CONFIRM "Buoc dung tien trinh nay"
    if errorlevel 1 (
        set "MSG=Tomcat van dang chay."
        exit /b 1
    )
    taskkill /PID !PORT_PID! /T /F >nul 2>&1
    call :FN_WAIT_PORT %TOMCAT_PORT% DOWN 5
    if errorlevel 1 (
        set "MSG=Khong dung duoc tien trinh PID !PORT_PID!."
        exit /b 1
    )
    set "MSG=Da buoc dung Tomcat."
    exit /b 0

:ACT_VIEW_LOGS
    call :NEED_TOMCAT || goto :MAIN_MENU
    REM Tren Windows khong co catalina.out - lay file catalina.<ngay>.log moi nhat
    set "TM_LOG="
    for /f "delims=" %%f in ('dir /b /a-d /o-d "!TOMCAT_HOME!\logs\catalina*.log" 2^>nul') do if not defined TM_LOG set "TM_LOG=!TOMCAT_HOME!\logs\%%f"
    if not defined TM_LOG (
        set "MSG=Chua co file log nao trong thu muc logs - hay Start Tomcat truoc."
        goto :MAIN_MENU
    )
    cls
    echo %cCyan%--- LOG: !TM_LOG! ---%cWhite%
    echo %cGray%Bam Ctrl+C roi chon N de quay lai menu.%cWhite%
    echo.
    powershell -NoProfile -Command "Get-Content -LiteralPath $env:TM_LOG -Tail 40 -Wait"
    goto :MAIN_MENU

:ACT_ADD_USER
    call :NEED_TOMCAT || goto :MAIN_MENU
    cls
    echo %cCyan%--- THEM USER TOMCAT MANAGER ---%cWhite%
    echo Them/cap nhat 1 user co quyen manager-gui trong tomcat-users.xml
    echo de truy cap: !LOCALHOST_URL!/manager/html
    echo Cac user khac trong file duoc giu nguyen.
    echo.
    set "TM_FILE=!TOMCAT_HOME!\conf\tomcat-users.xml"
    if not exist "!TM_FILE!" (
        set "MSG=Khong tim thay tomcat-users.xml."
        goto :MAIN_MENU
    )
    call :FN_ASK TM_USER "> Username (Enter = admin): "
    if not defined TM_USER set "TM_USER=admin"
    call :FN_IS_ID TM_USER
    if errorlevel 1 (
        set "MSG=Username chi gom chu, so va dau gach duoi."
        goto :MAIN_MENU
    )
    REM Doc tho (khong bo nhay kep) de khong am tham doi mat khau nguoi dung nhap
    set "TM_PASS="
    set /p "TM_PASS=> Password (chu/so/_ , khong de trong): "
    call :FN_IS_ID TM_PASS
    if errorlevel 1 (
        set "MSG=Password khong hop le - chi gom chu, so va dau gach duoi."
        goto :MAIN_MENU
    )

    copy /Y "!TM_FILE!" "!TM_FILE!.bak" >nul
    powershell -NoProfile -Command "$ErrorActionPreference='Stop'; $p=$env:TM_FILE; $x=New-Object System.Xml.XmlDocument; $x.PreserveWhitespace=$true; $x.Load($p); $r=$x.DocumentElement; $ns=$r.NamespaceURI; $nl=[Environment]::NewLine; if(-not ($r.ChildNodes | Where-Object { $_.NodeType -eq 'Element' -and $_.LocalName -eq 'role' -and $_.GetAttribute('rolename') -eq 'manager-gui' })){ $e=$x.CreateElement('role',$ns); $e.SetAttribute('rolename','manager-gui'); [void]$r.AppendChild($x.CreateWhitespace('  ')); [void]$r.AppendChild($e); [void]$r.AppendChild($x.CreateWhitespace($nl)) }; @($r.ChildNodes | Where-Object { $_.NodeType -eq 'Element' -and $_.LocalName -eq 'user' -and $_.GetAttribute('username') -eq $env:TM_USER }) | ForEach-Object { [void]$r.RemoveChild($_) }; $u=$x.CreateElement('user',$ns); $u.SetAttribute('username',$env:TM_USER); $u.SetAttribute('password',$env:TM_PASS); $u.SetAttribute('roles','manager-gui'); [void]$r.AppendChild($x.CreateWhitespace('  ')); [void]$r.AppendChild($u); [void]$r.AppendChild($x.CreateWhitespace($nl)); $w=New-Object System.IO.StreamWriter($p,$false,(New-Object System.Text.UTF8Encoding($false))); $x.Save($w); $w.Close()"
    if errorlevel 1 (
        copy /Y "!TM_FILE!.bak" "!TM_FILE!" >nul
        echo %cRed%Khong sua duoc file - da khoi phuc ban goc.%cWhite%
    ) else (
        echo %cGreen%Da luu user: !TM_USER!  [ban cu: tomcat-users.xml.bak]%cWhite%
        echo Hay Restart Tomcat de ap dung.
    )
    set "TM_PASS="
    pause
    goto :MAIN_MENU

REM ==============================================================================
REM   PROJECT WORKSPACE
REM ==============================================================================
:ACT_NEW_PROJ
    call :NEED_TOMCAT || goto :MAIN_MENU
    cls
    echo %cCyan%--- TAO PROJECT ---%cWhite%
    call :FN_ASK pName "> Ten Project (chu/so/_): "
    if not defined pName goto :MAIN_MENU
    call :FN_IS_ID pName
    if errorlevel 1 (
        set "MSG=Ten project chi gom chu, so va dau gach duoi."
        goto :MAIN_MENU
    )
    set "TPATH=!WEBAPPS_FOLDER!\!pName!"
    if exist "!TPATH!" (
        set "MSG=Project '!pName!' da ton tai."
        goto :MAIN_MENU
    )

    echo.
    echo    1. Basic Servlet (Lab 12)
    echo    2. JDBC Template (Lab 13)
    call :FN_ASK t "> Chon template (Enter = 1): "

    mkdir "!TPATH!\WEB-INF\classes" 2>nul
    mkdir "!TPATH!\WEB-INF\lib" 2>nul
    mkdir "!TPATH!\WEB-INF\src" 2>nul
    if not exist "!TPATH!\WEB-INF\src" (
        set "MSG=Khong tao duoc thu muc project - kiem tra quyen ghi vao webapps."
        goto :MAIN_MENU
    )

    set "TLINK=hello"
    if "!t!"=="2" set "TLINK=testdb"
    > "!TPATH!\index.html" (
        echo ^<html^>^<head^>^<meta charset="UTF-8"^>^<title^>!pName!^</title^>^</head^>
        echo ^<body^>
        echo ^<h1^>!pName!^</h1^>
        echo ^<a href="!TLINK!"^>Test Servlet /!TLINK!^</a^>
        echo ^</body^>^</html^>
    )

    REM Source dat trong WEB-INF\src de Tomcat khong public file .java ra ngoai
    if "!t!"=="2" ( call :FN_GEN_JDBC "!TPATH!\WEB-INF\src" ) else ( call :FN_GEN_BASIC "!TPATH!\WEB-INF\src" "!pName!" )
    echo.
    echo %cGreen%Da tao project tai: !TPATH!%cWhite%
    echo Servlet API: %SERVLET_PKG%.servlet  -  Source: WEB-INF\src
    echo Buoc tiep: [7] Scan Projects, chon project, Build.
    pause
    goto :MAIN_MENU

:FN_GEN_BASIC
    > "%~1\HelloServlet.java" (
        echo import %SERVLET_PKG%.servlet.annotation.WebServlet;
        echo import %SERVLET_PKG%.servlet.http.*;
        echo import java.io.IOException;
        echo.
        echo @WebServlet^("/hello"^)
        echo public class HelloServlet extends HttpServlet {
        echo     @Override
        echo     protected void doGet^(HttpServletRequest req, HttpServletResponse resp^) throws IOException {
        echo         resp.setContentType^("text/html; charset=UTF-8"^);
        echo         resp.getWriter^(^).println^("Hello %~2"^);
        echo     }
        echo }
    )
    exit /b 0

:FN_GEN_JDBC
    > "%~1\TestDB.java" (
        echo import %SERVLET_PKG%.servlet.annotation.WebServlet;
        echo import %SERVLET_PKG%.servlet.http.*;
        echo import java.io.*;
        echo import java.sql.*;
        echo.
        echo @WebServlet^("/testdb"^)
        echo public class TestDB extends HttpServlet {
        echo     private static final String URL = "jdbc:mysql://localhost:%MYSQL_PORT%/lab13_jdbc";
        echo.
        echo     @Override
        echo     protected void doGet^(HttpServletRequest req, HttpServletResponse resp^) throws IOException {
        echo         resp.setContentType^("text/html; charset=UTF-8"^);
        echo         PrintWriter out = resp.getWriter^(^);
        echo         try {
        echo             Class.forName^("com.mysql.cj.jdbc.Driver"^);
        echo             try ^(Connection conn = DriverManager.getConnection^(URL, "root", ""^);
        echo                  Statement st = conn.createStatement^(^);
        echo                  ResultSet rs = st.executeQuery^("SELECT id, username, email FROM users"^)^) {
        echo                 out.println^("DB Connected."^);
        echo                 out.println^("<ul>"^);
        echo                 while ^(rs.next^(^)^) {
        echo                     out.println^("<li>" + rs.getInt^(1^) + " - " + rs.getString^(2^) + " - " + rs.getString^(3^) + "</li>"^);
        echo                 }
        echo                 out.println^("</ul>"^);
        echo             }
        echo         } catch ^(Exception e^) {
        echo             e.printStackTrace^(out^);
        echo         }
        echo     }
        echo }
    )
    exit /b 0

:ACT_SCAN
    call :NEED_TOMCAT || goto :MAIN_MENU
    cls
    echo %cCyan%--- PROJECTS ---%cWhite%
    echo.
    set /a cnt=0
    for /d %%D in ("!WEBAPPS_FOLDER!\*") do (
        set /a cnt+=1
        set "P[!cnt!]=%%~nxD"
        echo    !cnt!. %%~nxD
    )
    if !cnt! EQU 0 (
        set "MSG=Chua co project nao trong webapps."
        goto :MAIN_MENU
    )
    echo.
    echo    0. Quay lai
    echo.
    call :FN_ASK pc "> Chon: "
    call :FN_IS_NUM pc
    if errorlevel 1 goto :MAIN_MENU
    if !pc! LSS 1 goto :MAIN_MENU
    if !pc! GTR !cnt! goto :MAIN_MENU
    set "SEL_P=!P[%pc%]!"
    goto :PROJ_MENU

:PROJ_MENU
    if not defined SEL_P goto :ACT_SCAN
    if not exist "!WEBAPPS_FOLDER!\!SEL_P!\" goto :ACT_SCAN
    cls
    echo %cCyan%--- PROJECT MANAGER ---%cWhite%
    echo Project: %cGreen%!SEL_P!%cWhite%
    echo.
    echo    1. Build (Compile Java)
    echo    2. Open Browser
    echo    3. Edit Source (VS Code / Explorer)
    echo    4. Delete Project
    echo    0. Back
    echo.
    call :FN_ASK o "> Lua chon: "

    if "!o!"=="1" goto :ACT_BUILD
    if "!o!"=="2" goto :ACT_OPEN_PROJ
    if "!o!"=="3" goto :ACT_EDIT_PROJ
    if "!o!"=="4" goto :ACT_DEL_PROJ
    if "!o!"=="0" goto :ACT_SCAN
    goto :PROJ_MENU

:ACT_OPEN_PROJ
    if /I "!SEL_P!"=="ROOT" ( start "" "!LOCALHOST_URL!/" ) else ( start "" "!LOCALHOST_URL!/!SEL_P!/" )
    goto :PROJ_MENU

:ACT_EDIT_PROJ
    call :FN_OPEN_EDITOR "!WEBAPPS_FOLDER!\!SEL_P!"
    goto :PROJ_MENU

:ACT_DEL_PROJ
    echo.
    echo %cRed%Xoa vinh vien: !WEBAPPS_FOLDER!\!SEL_P!%cWhite%
    call :FN_CONFIRM "Ban chac chan muon xoa"
    if errorlevel 1 goto :PROJ_MENU
    rmdir /s /q "!WEBAPPS_FOLDER!\!SEL_P!"
    set "SEL_P="
    goto :ACT_SCAN

:ACT_BUILD
    cls
    echo %cYellow%--- BUILD: !SEL_P! ---%cWhite%
    where javac >nul 2>&1
    if errorlevel 1 (
        echo %cRed%Khong tim thay javac - can JDK. Bam D de tai JDK hoac S de khai bao JAVA_HOME.%cWhite%
        pause
        goto :PROJ_MENU
    )
    set "PP=!WEBAPPS_FOLDER!\!SEL_P!"
    set "OUT_DIR=!PP!\WEB-INF\classes"
    if not exist "!OUT_DIR!" mkdir "!OUT_DIR!"

    REM Gom tat ca file .java vao argfile cua javac.
    REM Duong dan duoc boc nhay kep + doi \ thanh / de chay duoc voi thu muc co khoang trang.
    set "SRC_LIST=%TEMP%\tm_sources_%RANDOM%.txt"
    set /a SRC_COUNT=0
    pushd "!PP!"
    > "!SRC_LIST!" (
        for /r %%F in (*.java) do (
            set "f=%%F"
            echo "!f:\=/!"
            set /a SRC_COUNT+=1
        )
    )
    popd

    if !SRC_COUNT! EQU 0 (
        del "!SRC_LIST!" >nul 2>&1
        echo %cRed%Khong tim thay file .java nao trong project.%cWhite%
        pause
        goto :PROJ_MENU
    )

    echo Tim thay !SRC_COUNT! file .java. Dang compile...
    echo.
    javac -encoding UTF-8 -cp "!TOMCAT_HOME!\lib\*;!PP!\WEB-INF\lib\*" -d "!OUT_DIR!" "@!SRC_LIST!"
    set "BUILD_RC=!errorlevel!"
    del "!SRC_LIST!" >nul 2>&1
    echo.
    if "!BUILD_RC!"=="0" (
        echo %cGreen%Build Success. Restart Tomcat [3] de nap class moi.%cWhite%
    ) else (
        echo %cRed%Build Failed. Xem loi phia tren.%cWhite%
    )
    pause
    goto :PROJ_MENU

REM ==============================================================================
REM   MYSQL SERVER
REM ==============================================================================
:MYSQL_START
    call :NEED_MYSQL || goto :MAIN_MENU
    call :FN_MYSQL_START
    goto :MAIN_MENU

:MYSQL_STOP
    call :NEED_MYSQL || goto :MAIN_MENU
    call :FN_MYSQL_STOP
    goto :MAIN_MENU

:MYSQL_RESTART
    call :NEED_MYSQL || goto :MAIN_MENU
    call :FN_MYSQL_STOP
    if errorlevel 1 goto :MAIN_MENU
    call :FN_MYSQL_START
    goto :MAIN_MENU

:FN_MYSQL_START
    call :FN_PORT_UP %MYSQL_PORT%
    if not errorlevel 1 (
        set "MSG=Port %MYSQL_PORT% dang duoc su dung - MySQL da chay roi."
        exit /b 0
    )
    if not exist "!MYSQL_HOME!\my.ini" call :FN_MYSQL_WRITE_INI "!MYSQL_HOME!"
    if not exist "!MYSQL_HOME!\data\" call :FN_MYSQL_INIT "!MYSQL_HOME!"
    if errorlevel 1 (
        set "MSG=Khoi tao du lieu MySQL that bai."
        exit /b 1
    )
    echo %cGreen%Dang bat MySQL Server...%cWhite%
    start "MySQL Server %MYSQL_PORT%" /D "!MYSQL_HOME!\bin" "!MYSQL_HOME!\bin\mysqld.exe" --defaults-file="!MYSQL_HOME!\my.ini" --port=%MYSQL_PORT% --console
    call :FN_WAIT_PORT %MYSQL_PORT% UP 40
    if errorlevel 1 (
        set "MSG=MySQL chua mo port %MYSQL_PORT% sau 40s - xem cua so MySQL Server."
        exit /b 1
    )
    set "MSG=MySQL da san sang tren port %MYSQL_PORT%."
    exit /b 0

:FN_MYSQL_STOP
    call :FN_PORT_UP %MYSQL_PORT%
    if errorlevel 1 (
        set "MSG=MySQL khong chay."
        exit /b 0
    )
    echo %cRed%Dang tat MySQL...%cWhite%
    "!MYSQL_HOME!\bin\mysqladmin.exe" -u root -P %MYSQL_PORT% --protocol=TCP shutdown 2>nul
    call :FN_WAIT_PORT %MYSQL_PORT% DOWN 15
    if not errorlevel 1 (
        set "MSG=Da tat MySQL."
        exit /b 0
    )
    REM Chi buoc dung dung tien trinh mysqld dang giu port nay (khong dung den MySQL khac, vd XAMPP)
    call :FN_PID_ON_PORT %MYSQL_PORT%
    tasklist /FI "PID eq !PORT_PID!" 2>nul | findstr /I "mysqld" >nul
    if errorlevel 1 (
        set "MSG=Port %MYSQL_PORT% dang bi giu boi tien trinh khac [PID !PORT_PID!] - khong tu dong dung."
        exit /b 1
    )
    taskkill /PID !PORT_PID! /T /F >nul 2>&1
    call :FN_WAIT_PORT %MYSQL_PORT% DOWN 5
    if errorlevel 1 (
        set "MSG=Khong dung duoc MySQL [PID !PORT_PID!]."
        exit /b 1
    )
    set "MSG=Da buoc dung MySQL."
    exit /b 0

:FN_MYSQL_WRITE_INI
    REM %1 = MySQL root
    set "_mr=%~1"
    echo %cYellow%Dang tao file my.ini mac dinh...%cWhite%
    > "!_mr!\my.ini" (
        echo [mysqld]
        echo basedir=!_mr:\=/!
        echo datadir=!_mr:\=/!/data
        echo port=%MYSQL_PORT%
        echo character-set-server=utf8mb4
        echo [client]
        echo port=%MYSQL_PORT%
        echo default-character-set=utf8mb4
    )
    exit /b 0

:FN_MYSQL_INIT
    REM %1 = MySQL root. Tao data dir voi user root khong mat khau.
    echo %cYellow%Thu muc data chua ton tai. Dang khoi tao, co the mat 20-60s...%cWhite%
    "%~1\bin\mysqld.exe" --defaults-file="%~1\my.ini" --initialize-insecure --console
    if errorlevel 1 exit /b 1
    echo %cGreen%Da khoi tao xong data [root / khong mat khau].%cWhite%
    exit /b 0

REM ==============================================================================
REM   MYSQL BACKUP / RESTORE / LAB
REM ==============================================================================
:MYSQL_BACKUP
    call :NEED_MYSQL_UP || goto :MAIN_MENU
    cls
    echo %cCyan%--- BACKUP DATABASE ---%cWhite%
    %MYSQL_CLI% -e "SHOW DATABASES;"
    echo.
    call :FN_ASK dbn "> Nhap ten Database can Backup: "
    if not defined dbn goto :MAIN_MENU
    call :FN_IS_ID dbn
    if errorlevel 1 (
        set "MSG=Ten database khong hop le."
        goto :MAIN_MENU
    )
    if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
    call :FN_TIMESTAMP
    set "backup_file=%BACKUP_DIR%\!dbn!_!TS!.sql"
    echo Dang backup ra file: %cGreen%!backup_file!%cWhite%

    "!MYSQL_HOME!\bin\mysqldump.exe" -u root -P %MYSQL_PORT% --protocol=TCP --databases !dbn! --result-file="!backup_file!"
    if errorlevel 1 (
        del "!backup_file!" >nul 2>&1
        echo %cRed%Backup that bai. Kiem tra lai ten database.%cWhite%
    ) else (
        echo %cGreen%Backup thanh cong.%cWhite%
    )
    pause
    goto :MAIN_MENU

:MYSQL_RESTORE
    call :NEED_MYSQL_UP || goto :MAIN_MENU
    cls
    echo %cRed%--- RESTORE DATABASE ---%cWhite%
    echo WARNING: Hanh dong nay se ghi de du lieu cu.
    echo Thu muc backup: %BACKUP_DIR%
    echo.
    dir /b /o-d "%BACKUP_DIR%\*.sql" 2>nul
    echo.
    call :FN_ASK sqlf "> Nhap ten file .sql (hoac duong dan day du): "
    if not defined sqlf goto :MAIN_MENU
    if exist "%BACKUP_DIR%\!sqlf!" set "sqlf=%BACKUP_DIR%\!sqlf!"
    if not exist "!sqlf!" (
        set "MSG=File khong ton tai: !sqlf!"
        goto :MAIN_MENU
    )
    call :FN_CONFIRM "Restore tu file nay va ghi de du lieu hien co"
    if errorlevel 1 goto :MAIN_MENU

    echo Dang Restore...
    %MYSQL_CLI% < "!sqlf!"
    if errorlevel 1 ( echo %cRed%Co loi xay ra.%cWhite% ) else ( echo %cGreen%Restore thanh cong.%cWhite% )
    pause
    goto :MAIN_MENU

:AUTO_LAB13
    call :NEED_MYSQL_UP || goto :MAIN_MENU
    cls
    echo %cCyan%--- AUTO SETUP LAB 13 ---%cWhite%
    echo Se XOA va tao lai database lab13_jdbc, bang users, 1 user demo.
    call :FN_CONFIRM "Tiep tuc"
    if errorlevel 1 goto :MAIN_MENU

    %MYSQL_CLI% -e "DROP DATABASE IF EXISTS lab13_jdbc; CREATE DATABASE lab13_jdbc CHARACTER SET utf8mb4; USE lab13_jdbc; CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50), email VARCHAR(100)); INSERT INTO users(username, email) VALUES('admin', 'admin@gmail.com');"
    if errorlevel 1 (
        echo %cRed%Loi khi tao database.%cWhite%
    ) else (
        echo %cGreen%Tao Database va Table thanh cong. Da them 1 user demo [admin].%cWhite%
    )
    pause
    goto :MAIN_MENU

REM ==============================================================================
REM   MYSQL QUERY MANAGER
REM ==============================================================================
:MYSQL_MENU
    call :NEED_MYSQL_UP || goto :MAIN_MENU
    cls
    echo %cGreen%--- MYSQL QUERY MANAGER ---%cWhite%
    echo.
    echo    1. Show Databases
    echo    2. Create Database
    echo    3. Use Database ^& Manage Tables
    echo    4. Run Custom SQL Query
    echo    0. Quay lai
    echo.
    call :FN_ASK mq "> Lua chon: "
    if "!mq!"=="1" goto :SQL_SHOW_DB
    if "!mq!"=="2" goto :SQL_CREATE_DB
    if "!mq!"=="3" goto :MYSQL_TABLE_MENU
    if "!mq!"=="4" goto :SQL_CUSTOM
    if "!mq!"=="0" goto :MAIN_MENU
    goto :MYSQL_MENU

:SQL_SHOW_DB
    %MYSQL_CLI% -e "SHOW DATABASES;"
    pause
    goto :MYSQL_MENU

:SQL_CREATE_DB
    call :FN_ASK dbn "> Nhap ten Database moi: "
    call :FN_IS_ID dbn
    if errorlevel 1 (
        echo %cRed%Ten database chi gom chu, so va dau gach duoi.%cWhite%
        pause
        goto :MYSQL_MENU
    )
    %MYSQL_CLI% -e "CREATE DATABASE `!dbn!` CHARACTER SET utf8mb4;"
    if not errorlevel 1 echo %cGreen%Da tao database !dbn!.%cWhite%
    pause
    goto :MYSQL_MENU

:SQL_CUSTOM
    REM Ghi cau lenh ra file tam roi nap qua stdin - khong vo lenh khi SQL chua nhay kep
    set "csql="
    set /p "csql=> Nhap lenh SQL: "
    if not defined csql goto :MYSQL_MENU
    set "SQL_TMP=%TEMP%\tm_query_%RANDOM%.sql"
    > "!SQL_TMP!" echo(!csql!
    %MYSQL_CLI% --table < "!SQL_TMP!"
    del "!SQL_TMP!" >nul 2>&1
    pause
    goto :MYSQL_MENU

:MYSQL_TABLE_MENU
    cls
    echo %cYellow%--- TABLE MANAGER ---%cWhite%
    call :FN_ASK use_db "> Nhap ten Database muon dung: "
    call :FN_IS_ID use_db
    if errorlevel 1 goto :MYSQL_MENU
    %MYSQL_CLI% -e "USE `!use_db!`;" 2>nul
    if errorlevel 1 (
        echo %cRed%Database khong ton tai.%cWhite%
        pause
        goto :MYSQL_MENU
    )

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
    call :FN_ASK tq "> Lua chon: "
    if "!tq!"=="0" goto :MYSQL_MENU
    if "!tq!"=="1" goto :TBL_SHOW
    if "!tq!"=="2" goto :TBL_CREATE
    if "!tq!"=="3" goto :TBL_SELECT
    if "!tq!"=="4" goto :TBL_DESC
    if "!tq!"=="5" goto :TBL_DROP
    goto :TABLE_LOOP

:TBL_SHOW
    %MYSQL_CLI% -D "!use_db!" -e "SHOW TABLES;"
    pause
    goto :TABLE_LOOP

:TBL_CREATE
    echo Nhap cau lenh CREATE TABLE
    set "ctsql="
    set /p "ctsql=> SQL: "
    if not defined ctsql goto :TABLE_LOOP
    set "SQL_TMP=%TEMP%\tm_query_%RANDOM%.sql"
    > "!SQL_TMP!" echo(!ctsql!
    %MYSQL_CLI% -D "!use_db!" < "!SQL_TMP!"
    del "!SQL_TMP!" >nul 2>&1
    pause
    goto :TABLE_LOOP

:TBL_SELECT
    call :FN_ASK_TABLE || goto :TABLE_LOOP
    %MYSQL_CLI% -D "!use_db!" -e "SELECT * FROM `!tbl!` LIMIT 200;"
    pause
    goto :TABLE_LOOP

:TBL_DESC
    call :FN_ASK_TABLE || goto :TABLE_LOOP
    %MYSQL_CLI% -D "!use_db!" -e "DESCRIBE `!tbl!`;"
    pause
    goto :TABLE_LOOP

:TBL_DROP
    call :FN_ASK_TABLE || goto :TABLE_LOOP
    call :FN_CONFIRM "Xoa vinh vien bang !tbl!"
    if errorlevel 1 goto :TABLE_LOOP
    %MYSQL_CLI% -D "!use_db!" -e "DROP TABLE `!tbl!`;"
    if not errorlevel 1 echo %cGreen%Da xoa bang !tbl!.%cWhite%
    pause
    goto :TABLE_LOOP

:FN_ASK_TABLE
    call :FN_ASK tbl "> Ten bang: "
    call :FN_IS_ID tbl
    if errorlevel 1 (
        echo %cRed%Ten bang chi gom chu, so va dau gach duoi.%cWhite%
        pause
        exit /b 1
    )
    exit /b 0

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
    echo %cYellow%[ TOOL ]%cWhite%
    echo    6. config.ini       (Cau hinh cua tool nay)
    echo.
    echo    0. Back
    echo.
    call :FN_ASK cfg_opt "> Open: "

    if "!cfg_opt!"=="1" call :FN_OPEN_FILE "!TOMCAT_HOME!\conf\server.xml"
    if "!cfg_opt!"=="2" call :FN_OPEN_FILE "!TOMCAT_HOME!\conf\tomcat-users.xml"
    if "!cfg_opt!"=="3" call :FN_OPEN_FILE "!TOMCAT_HOME!\conf\web.xml"
    if "!cfg_opt!"=="4" call :FN_OPEN_FILE "!TOMCAT_HOME!\conf\context.xml"
    if "!cfg_opt!"=="5" call :FN_OPEN_FILE "!MYSQL_HOME!\my.ini"
    if "!cfg_opt!"=="6" call :FN_OPEN_FILE "!CONFIG_FILE!"
    if "!cfg_opt!"=="0" goto :MAIN_MENU
    goto :CONFIG_MENU

:FN_OPEN_FILE
    if not exist "%~1" (
        echo %cRed%File khong ton tai: %~1%cWhite%
        pause
        exit /b 1
    )
    call :FN_OPEN_EDITOR "%~1"
    exit /b 0

:FN_OPEN_EDITOR
    REM %1 = file hoac thu muc. Uu tien VS Code; khong co thi Notepad (file) / Explorer (thu muc).
    REM "code" la file .cmd nen bat buoc phai CALL, neu khong script se thoat luon.
    where code >nul 2>&1
    if not errorlevel 1 (
        call code "%~1"
        exit /b 0
    )
    if exist "%~1\" ( start "" "%~1" ) else ( start "" notepad.exe "%~1" )
    exit /b 0

REM ==============================================================================
REM   DOWNLOAD & INSTALL HANDLERS
REM ==============================================================================
:DOWNLOAD_MENU
    cls
    echo %cCyan%--- DOWNLOAD TOOLS ---%cWhite%
    echo.
    echo    1. MySQL JDBC Driver %DL_JDBC_VER%   (Maven Central)
    echo    2. MySQL Server %DL_MYSQL_VER%        (cdn.mysql.com, ~300MB)
    echo    3. Oracle JDK                (download.oracle.com)
    echo    4. Apache Tomcat             (archive.apache.org)
    echo    0. Quay lai
    echo.
    call :FN_ASK dlo "> Chon: "
    if "!dlo!"=="1" goto :ACT_DL_JDBC
    if "!dlo!"=="2" goto :ACT_DL_MYSQL_SERVER
    if "!dlo!"=="3" goto :ACT_DL_JDK
    if "!dlo!"=="4" goto :ACT_DL_TOMCAT
    goto :MAIN_MENU

:ACT_DL_JDBC
    call :NEED_TOMCAT || goto :MAIN_MENU
    cls
    echo %cCyan%--- TAI JDBC DRIVER (MAVEN) ---%cWhite%
    set "TM_URL=https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/%DL_JDBC_VER%/mysql-connector-j-%DL_JDBC_VER%.jar"
    set "TM_DEST=!TOMCAT_HOME!\lib\mysql-connector-j-%DL_JDBC_VER%.jar"
    echo Dang tai mysql-connector-j-%DL_JDBC_VER%.jar vao thu muc lib cua Tomcat...
    call :FN_DOWNLOAD
    if errorlevel 1 (
        echo %cRed%Tai that bai. Kiem tra lai mang va quyen ghi vao thu muc Tomcat.%cWhite%
    ) else (
        echo %cGreen%Tai thanh cong: !TM_DEST!%cWhite%
        echo Driver dung chung cho moi project. Hay Restart Tomcat de ap dung.
    )
    pause
    goto :MAIN_MENU

:ACT_DL_TOMCAT
    cls
    echo %cCyan%--- TAI APACHE TOMCAT ---%cWhite%
    echo Tomcat 10.1 can Java 11+, Tomcat 11 can Java 17+, Tomcat 9 dung javax.servlet.
    echo.
    call :FN_ASK tv "> Phien ban (Enter = %DL_TOMCAT_VER%): "
    if not defined tv set "tv=%DL_TOMCAT_VER%"
    call :FN_IS_VER tv
    if errorlevel 1 (
        set "MSG=Phien ban khong hop le - vi du: 10.1.60"
        goto :MAIN_MENU
    )
    for /f "delims=." %%m in ("!tv!") do set "tmaj=%%m"

    call :FN_ASK TM_DIR "> Thu muc cai (Enter = C:\tomcat): "
    if not defined TM_DIR set "TM_DIR=C:\tomcat"
    if exist "!TM_DIR!\bin\catalina.bat" (
        echo %cGreen%Tomcat da co san tai: !TM_DIR! - cap nhat cau hinh.%cWhite%
        goto :ACT_DL_TOMCAT_DONE
    )
    if not exist "!TM_DIR!" mkdir "!TM_DIR!"
    set "TM_URL=https://archive.apache.org/dist/tomcat/tomcat-!tmaj!/v!tv!/bin/apache-tomcat-!tv!-windows-x64.zip"
    set "TM_DEST=!TM_DIR!\tomcat.zip"

    echo 1. Dang tai Tomcat !tv!...
    call :FN_DOWNLOAD
    if errorlevel 1 (
        echo %cRed%Tai that bai. Kiem tra mang hoac so phien ban.%cWhite%
        pause
        goto :MAIN_MENU
    )
    echo 2. Dang giai nen...
    call :FN_UNZIP_FLAT
    del "!TM_DEST!" >nul 2>&1
    if not exist "!TM_DIR!\bin\catalina.bat" (
        echo %cRed%Giai nen that bai.%cWhite%
        pause
        goto :MAIN_MENU
    )
    echo %cGreen%Cai dat Tomcat hoan tat.%cWhite%

:ACT_DL_TOMCAT_DONE
    set "TOMCAT_HOME=!TM_DIR!"
    call :FN_SAVE_CFG
    call :FN_INIT_VARS
    pause
    goto :MAIN_MENU

:ACT_DL_JDK
    cls
    echo %cCyan%--- TAI ORACLE JDK (LATEST) ---%cWhite%
    call :FN_ASK v "> Phien ban 21 hoac 25 (Enter = %DL_JDK_VER%): "
    if not defined v set "v=%DL_JDK_VER%"
    call :FN_IS_NUM v
    if errorlevel 1 (
        set "MSG=Phien ban JDK khong hop le."
        goto :MAIN_MENU
    )
    call :FN_ASK TM_DIR "> Thu muc cai (Enter = C:\java\jdk-!v!): "
    if not defined TM_DIR set "TM_DIR=C:\java\jdk-!v!"
    if exist "!TM_DIR!\bin\javac.exe" (
        echo %cGreen%JDK da co san tai: !TM_DIR! - cap nhat cau hinh.%cWhite%
        goto :ACT_DL_JDK_DONE
    )
    if not exist "!TM_DIR!" mkdir "!TM_DIR!"
    set "TM_URL=https://download.oracle.com/java/!v!/latest/jdk-!v!_windows-x64_bin.zip"
    set "TM_DEST=!TM_DIR!\jdk.zip"

    echo 1. Dang tai JDK !v! tu Oracle (~200MB)...
    call :FN_DOWNLOAD
    if errorlevel 1 (
        echo %cRed%Tai that bai. Oracle chi con link "latest" cho JDK 21 va 25.%cWhite%
        pause
        goto :MAIN_MENU
    )
    echo 2. Dang giai nen...
    call :FN_UNZIP_FLAT
    del "!TM_DEST!" >nul 2>&1
    if not exist "!TM_DIR!\bin\javac.exe" (
        echo %cRed%Giai nen that bai.%cWhite%
        pause
        goto :MAIN_MENU
    )
    echo %cGreen%Cai dat JDK hoan tat.%cWhite%

:ACT_DL_JDK_DONE
    REM Luu vao config.ini - tool tu dung JDK nay, khong sua bien moi truong cua may
    set "CFG_JAVA_HOME=!TM_DIR!"
    call :FN_SAVE_CFG
    call :FN_INIT_VARS
    echo Tool se dung JDK nay: !TM_DIR!
    echo %cYellow%[TIP] Muon dung cho ca may: setx JAVA_HOME "!TM_DIR!"%cWhite%
    pause
    goto :MAIN_MENU

:ACT_DL_MYSQL_SERVER
    cls
    echo %cCyan%--- TAI ^& CAI DAT MYSQL SERVER %DL_MYSQL_VER% ---%cWhite%
    echo.
    call :FN_ASK TM_DIR "> Thu muc cai (Enter = C:\mysql): "
    if not defined TM_DIR set "TM_DIR=C:\mysql"

    if exist "!TM_DIR!\bin\mysqld.exe" (
        echo %cGreen%MySQL da co san tai: !TM_DIR! - cap nhat cau hinh.%cWhite%
        goto :ACT_DL_MYSQL_DONE
    )
    if not exist "!TM_DIR!" mkdir "!TM_DIR!"
    for /f "tokens=1,2 delims=." %%a in ("%DL_MYSQL_VER%") do set "MYSQL_SERIES=%%a.%%b"
    set "TM_URL=https://cdn.mysql.com/archives/mysql-!MYSQL_SERIES!/mysql-%DL_MYSQL_VER%-winx64.zip"
    set "TM_DEST=!TM_DIR!\mysql.zip"

    echo 1. Dang tai (300MB+)...
    call :FN_DOWNLOAD
    if errorlevel 1 (
        echo %cRed%Tai that bai. Kiem tra lai mang.%cWhite%
        pause
        goto :MAIN_MENU
    )
    echo 2. Dang giai nen...
    call :FN_UNZIP_FLAT
    del "!TM_DEST!" >nul 2>&1
    if not exist "!TM_DIR!\bin\mysqld.exe" (
        echo %cRed%Giai nen that bai.%cWhite%
        pause
        goto :MAIN_MENU
    )
    echo 3. Tao file my.ini...
    call :FN_MYSQL_WRITE_INI "!TM_DIR!"
    echo 4. Khoi tao Data...
    call :FN_MYSQL_INIT "!TM_DIR!"
    if errorlevel 1 (
        echo %cRed%Khoi tao data that bai.%cWhite%
        pause
        goto :MAIN_MENU
    )
    echo %cGreen%Cai dat MySQL hoan tat. Bam M1 o menu chinh de bat server.%cWhite%

:ACT_DL_MYSQL_DONE
    set "MYSQL_HOME=!TM_DIR!"
    call :FN_SAVE_CFG
    call :FN_INIT_VARS
    pause
    goto :MAIN_MENU

:FN_DOWNLOAD
    REM Input: TM_URL, TM_DEST. Dung curl cua Windows (co san tu Windows 10 1803), khong co thi BITS.
    REM Goi thang ban trong System32 de khong dinh curl/tar cua Git hay MSYS nam trong PATH.
    if exist "!TM_DEST!" del /q "!TM_DEST!"
    if not exist "%SystemRoot%\System32\curl.exe" goto :FN_DOWNLOAD_BITS
    "%SystemRoot%\System32\curl.exe" -fL --retry 2 -o "!TM_DEST!" "!TM_URL!"
    if errorlevel 1 (
        if exist "!TM_DEST!" del /q "!TM_DEST!"
        exit /b 1
    )
    exit /b 0
:FN_DOWNLOAD_BITS
    powershell -NoProfile -Command "Start-BitsTransfer -Source $env:TM_URL -Destination $env:TM_DEST"
    if exist "!TM_DEST!" exit /b 0
    exit /b 1

:FN_UNZIP_FLAT
    REM Input: TM_DEST (file zip), TM_DIR (thu muc dich).
    REM Giai nen va bo thu muc goc trong zip (vd apache-tomcat-x.y.z\) de noi dung nam thang trong TM_DIR.
    if not exist "%SystemRoot%\System32\tar.exe" goto :FN_UNZIP_PS
    "%SystemRoot%\System32\tar.exe" -xf "!TM_DEST!" -C "!TM_DIR!" --strip-components=1
    exit /b
:FN_UNZIP_PS
    set "TM_TMP=!TM_DIR!\_tm_extract"
    powershell -NoProfile -Command "Expand-Archive -LiteralPath $env:TM_DEST -DestinationPath $env:TM_TMP -Force"
    if errorlevel 1 (
        rmdir /s /q "!TM_TMP!" 2>nul
        exit /b 1
    )
    for /d %%D in ("!TM_TMP!\*") do robocopy "%%D" "!TM_DIR!" /E /MOVE /NFL /NDL /NJH /NJS /NP >nul
    rmdir /s /q "!TM_TMP!" 2>nul
    exit /b 0

REM ==============================================================================
REM   CONFIG PATHS
REM ==============================================================================
:UPDATE_PATH
    cls
    echo %cYellow%--- CAU HINH HE THONG ---%cWhite%
    if defined MSG echo %cRed%!MSG!%cWhite%
    set "MSG="
    echo.
    echo Hien tai:
    echo    1. Tomcat Home: !TOMCAT_HOME!
    echo    2. Tomcat Port: %TOMCAT_PORT%
    echo    3. MySQL Home:  !MYSQL_HOME!
    echo    4. MySQL Port:  %MYSQL_PORT%
    echo    5. Java Home:   !CFG_JAVA_HOME!  %cGray%[trong = dung Java cua he thong]%cWhite%
    echo.
    echo Enter de giu nguyen, hoac nhap gia tri moi. Nhap dau - de xoa gia tri.
    echo.
    call :FN_ASK T "> Tomcat Home: "
    call :FN_ASK TP "> Tomcat Port: "
    call :FN_ASK M "> MySQL Home: "
    call :FN_ASK MP "> MySQL Port: "
    call :FN_ASK J "> Java Home: "

    if defined T set "TOMCAT_HOME=!T!"
    if defined M set "MYSQL_HOME=!M!"
    if defined J set "CFG_JAVA_HOME=!J!"
    if "!T!"=="-" set "TOMCAT_HOME="
    if "!M!"=="-" set "MYSQL_HOME="
    if "!J!"=="-" set "CFG_JAVA_HOME="

    if defined TP (
        call :FN_IS_NUM TP
        if errorlevel 1 ( set "MSG=Tomcat Port phai la so - giu gia tri cu." ) else ( set "TOMCAT_PORT=!TP!" )
    )
    if defined MP (
        call :FN_IS_NUM MP
        if errorlevel 1 ( set "MSG=MySQL Port phai la so - giu gia tri cu." ) else ( set "MYSQL_PORT=!MP!" )
    )

    call :FN_NORMALIZE_PATHS
    call :FN_SAVE_CFG
    call :FN_INIT_VARS
    if defined TOMCAT_HOME if not exist "!TOMCAT_HOME!\bin\catalina.bat" set "MSG=Canh bao: khong thay bin\catalina.bat trong Tomcat Home."
    if defined CFG_JAVA_HOME if not exist "!CFG_JAVA_HOME!\bin\java.exe" set "MSG=Canh bao: khong thay bin\java.exe trong Java Home."
    goto :MAIN_MENU

REM ==============================================================================
REM   CORE FUNCTIONS
REM ==============================================================================
:NEED_TOMCAT
    if exist "!TOMCAT_HOME!\bin\catalina.bat" exit /b 0
    set "MSG=Chua cau hinh dung Tomcat Home - bam S de cau hinh hoac D de tai Tomcat."
    exit /b 1

:NEED_MYSQL
    if not defined MYSQL_HOME (
        set "MSG=Chua cau hinh MySQL Home - bam S de cau hinh hoac D de tai MySQL."
        exit /b 1
    )
    if not exist "!MYSQL_HOME!\bin\mysqld.exe" (
        set "MSG=Khong tim thay bin\mysqld.exe trong MySQL Home."
        exit /b 1
    )
    exit /b 0

:NEED_MYSQL_UP
    call :NEED_MYSQL || exit /b 1
    call :FN_PORT_UP %MYSQL_PORT%
    if errorlevel 1 (
        set "MSG=MySQL chua chay - bam M1 de bat."
        exit /b 1
    )
    exit /b 0

:FN_CHECK_STATUS
    call :FN_PORT_UP %TOMCAT_PORT%
    if errorlevel 1 ( set "SERVER_STATUS=%cRed%OFFLINE%cWhite%" ) else ( set "SERVER_STATUS=%cGreen%ONLINE%cWhite%" )
    call :FN_PORT_UP %MYSQL_PORT%
    if errorlevel 1 ( set "MYSQL_STATUS=%cRed%OFFLINE%cWhite%" ) else ( set "MYSQL_STATUS=%cGreen%ONLINE%cWhite%" )
    exit /b 0

:FN_PORT_UP
    REM %1 = port. errorlevel 0 neu co tien trinh dang LISTENING.
    netstat -ano 2>nul | findstr /R /C:":%~1 .*LISTENING" >nul
    exit /b

:FN_PID_ON_PORT
    set "PORT_PID="
    for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr /R /C:":%~1 .*LISTENING"') do if not defined PORT_PID set "PORT_PID=%%p"
    exit /b 0

:FN_WAIT_PORT
    REM %1 = port, %2 = UP hoac DOWN, %3 = so giay toi da. errorlevel 1 neu het gio.
    set /a _w=0
:FN_WAIT_PORT_LOOP
    call :FN_PORT_UP %~1
    if errorlevel 1 ( if /I "%~2"=="DOWN" exit /b 0 ) else ( if /I "%~2"=="UP" exit /b 0 )
    if !_w! GEQ %~3 exit /b 1
    set /a _w+=1
    <nul set /p "=."
    call :FN_SLEEP 1
    goto :FN_WAIT_PORT_LOOP

:FN_SLEEP
    timeout /t %~1 /nobreak >nul 2>&1 || ping -n %~1 -w 1000 127.0.0.1 >nul
    exit /b 0

:FN_ASK
    REM %1 = ten bien, %2 = prompt. Xoa gia tri cu (tranh Enter lap lai lua chon truoc) va bo dau nhay kep.
    set "%~1="
    set /p "%~1=%~2"
    if defined %~1 set "%~1=!%~1:"=!"
    exit /b 0

:FN_CONFIRM
    set "_yn="
    set /p "_yn=%~1? [y/N]: "
    if /I "!_yn!"=="Y" exit /b 0
    exit /b 1

:FN_IS_NUM
    REM %1 = ten bien. errorlevel 0 neu gia tri chi gom chu so.
    if not defined %~1 exit /b 1
    for /f "eol=0 delims=%CS_NUM%" %%c in ("!%~1!") do exit /b 1
    exit /b 0

:FN_IS_ID
    REM %1 = ten bien. errorlevel 0 neu gia tri chi gom chu, so, dau gach duoi.
    if not defined %~1 exit /b 1
    for /f "eol=0 delims=%CS_ID%" %%c in ("!%~1!") do exit /b 1
    exit /b 0

:FN_IS_VER
    REM %1 = ten bien. errorlevel 0 neu gia tri chi gom chu so va dau cham.
    if not defined %~1 exit /b 1
    for /f "eol=0 delims=%CS_NUM%." %%c in ("!%~1!") do exit /b 1
    exit /b 0

:FN_TIMESTAMP
    set "TS=%RANDOM%"
    for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%t"
    exit /b 0

:FN_LOAD_CFG
    REM Doc file INI dang KEY=VALUE. Dong bat dau bang # la comment.
    for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%CONFIG_FILE%") do (
        if /I "%%a"=="TOMCAT_HOME" set "TOMCAT_HOME=%%b"
        if /I "%%a"=="TOMCAT_PORT" set "TOMCAT_PORT=%%b"
        if /I "%%a"=="MYSQL_HOME" set "MYSQL_HOME=%%b"
        if /I "%%a"=="MYSQL_PORT" set "MYSQL_PORT=%%b"
        if /I "%%a"=="JAVA_HOME" set "CFG_JAVA_HOME=%%b"
    )
    call :FN_IS_NUM TOMCAT_PORT
    if errorlevel 1 set "TOMCAT_PORT=%DEFAULT_PORT%"
    call :FN_IS_NUM MYSQL_PORT
    if errorlevel 1 set "MYSQL_PORT=%DEFAULT_MYSQL_PORT%"
    call :FN_NORMALIZE_PATHS
    exit /b 0

:FN_NORMALIZE_PATHS
    REM Bo dau \ cuoi; chap nhan ca truong hop nguoi dung tro thang vao thu muc bin
    for %%V in (TOMCAT_HOME MYSQL_HOME CFG_JAVA_HOME) do (
        if defined %%V if "!%%V:~-1!"=="\" set "%%V=!%%V:~0,-1!"
        if defined %%V if /I "!%%V:~-4!"=="\bin" set "%%V=!%%V:~0,-4!"
    )
    exit /b 0

:FN_SAVE_CFG
    > "%CONFIG_FILE%" (
        echo # TomCat Manager config - KEY=VALUE
        echo TOMCAT_HOME=!TOMCAT_HOME!
        echo TOMCAT_PORT=!TOMCAT_PORT!
        echo MYSQL_HOME=!MYSQL_HOME!
        echo MYSQL_PORT=!MYSQL_PORT!
        echo JAVA_HOME=!CFG_JAVA_HOME!
    )
    exit /b 0

:FN_INIT_VARS
    set "WEBAPPS_FOLDER=!TOMCAT_HOME!\webapps"
    set "LOCALHOST_URL=http://localhost:!TOMCAT_PORT!"
    set MYSQL_CLI="!MYSQL_HOME!\bin\mysql.exe" -u root -P !MYSQL_PORT! --protocol=TCP

    REM Ep Tomcat scripts dung dung ban Tomcat da cau hinh (ke ca khi may co CATALINA_HOME khac)
    if defined TOMCAT_HOME (
        set "CATALINA_HOME=!TOMCAT_HOME!"
        set "CATALINA_BASE=!TOMCAT_HOME!"
    )

    REM JAVA_HOME trong config.ini chi ap dung cho phien chay cua tool
    set "PATH=!ORIG_PATH!"
    if defined CFG_JAVA_HOME if exist "!CFG_JAVA_HOME!\bin\java.exe" (
        set "JAVA_HOME=!CFG_JAVA_HOME!"
        set "PATH=!CFG_JAVA_HOME!\bin;!ORIG_PATH!"
    )

    set "JAVA_VER="
    for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /I /C:" version "') do if not defined JAVA_VER set "JAVA_VER=%%~v"
    if defined JAVA_VER ( set "JAVA_STATUS=%cWhite%!JAVA_VER!" ) else ( set "JAVA_STATUS=%cRed%MISSING - bam D de tai JDK%cWhite%" )

    REM Tomcat 9 tro xuong dung javax.servlet, Tomcat 10+ dung jakarta.servlet
    set "SERVLET_PKG=jakarta"
    set "TOMCAT_VER="
    if exist "!TOMCAT_HOME!\RELEASE-NOTES" for /f "tokens=4" %%v in ('findstr /C:"Apache Tomcat Version" "!TOMCAT_HOME!\RELEASE-NOTES"') do if not defined TOMCAT_VER set "TOMCAT_VER=%%v"
    if defined TOMCAT_VER for /f "delims=." %%m in ("!TOMCAT_VER!") do if %%m LSS 10 set "SERVLET_PKG=javax"
    exit /b 0
