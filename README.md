# README – RunTomCat.bat

## Mô tả
`RunTomCat.bat` là script hỗ trợ quản lý Apache Tomcat trên Windows thông qua menu CLI. File cho phép start, stop, restart Tomcat và mở nhanh thư mục `webapps` hoặc trang `localhost`.

## Cấu hình
Cập nhật lại đường dẫn Tomcat trước khi chạy:
 - SET TOMCAT_HOME=C:\tomcat
 - SET WEBAPPS_FOLDER=%TOMCAT_HOME%\webapps
 - SET LOCALHOST_URL=http://localhost:8080

Tomcat phải có sẵn thư mục `bin` chứa `startup.bat` và `shutdown.bat`.

## Sử dụng
Chạy file và chọn chức năng trong menu:
- 1: Khởi động Tomcat  
- 2: Dừng Tomcat  
- 3: Khởi động lại Tomcat  
- 4: Mở thư mục webapps  
- 5: Mở localhost  

Script thực thi trực tiếp và dừng lại để người dùng xem trạng thái.

## Hoạt động nội bộ
Start:
```
call "%TOMCAT_HOME%\bin\startup.bat"
```
Stop:
```
call "%TOMCAT_HOME%\bin\shutdown.bat"
```
Restart: shutdown → pause → startup.
Mở thư mục:
```
start "" "%WEBAPPS_FOLDER%"
```
Mở trình duyệt:
```
start "" "%LOCALHOST_URL%"
```


## Lưu ý
- Nếu Tomcat chạy dạng Windows Service, script sẽ không can thiệp được.  
- Khi đổi port trong `server.xml`, cần chỉnh lại `LOCALHOST_URL`.  
- Khuyến nghị dùng trong môi trường phát triển hoặc test.

## Author 
- Nguyễn Quốc Anh 
