# 🚀 Apache Tomcat Manager CLI

**Apache Tomcat Manager CLI** là một công cụ tự động hóa mạnh mẽ dành cho môi trường Windows, được viết bằng **Batch Script** kết hợp **PowerShell**. Công cụ này giải quyết các vấn đề tốn thời gian khi làm việc với Java Web: tải server, cấu hình biến môi trường thủ công, và quản lý vòng đời (lifecycle) của Tomcat Server.

Dự án hướng tới việc tối ưu hóa quy trình phát triển (DevOps local) cho các lập trình viên Java, giúp việc khởi tạo và quản lý môi trường diễn ra chỉ với vài phím bấm.

---

## ✨ Tính Năng Nổi Bật

### 1. Quản Lý Server Toàn Diện (Server Lifecycle)
* **Start/Stop/Restart:** Thao tác bật, tắt và khởi động lại Tomcat nhanh chóng thông qua Menu CLI.
* **Smart Logging:** Khi Start server, cửa sổ Log (Console) được tách riêng biệt, giúp giữ giao diện quản lý sạch sẽ và không bị trôi dòng lệnh.
* **Live Status:** Hiển thị trạng thái Server **(Online/Offline)** theo thời gian thực ngay trên Menu với màu sắc trực quan (ANSI Colors).

### 2. Tự Động Hóa Cài Đặt (Auto-Provisioning)
* **Auto-Download:** Tích hợp tính năng tải xuống các phiên bản Tomcat (11, 10, 9, 8) trực tiếp từ máy chủ Apache.
* **Auto-Extract & Setup:** Tự động giải nén và thiết lập cấu trúc thư mục mà không cần người dùng can thiệp thủ công.
* **Smart Config:** Tự động phát hiện và tạo file cấu hình `data.json`. Nếu đường dẫn sai hoặc chưa có, tool sẽ hướng dẫn thiết lập lại (Self-healing).

### 3. Tăng Tốc Quy Trình Phát Triển (Productivity)
* **Project Scaffolding:** Hỗ trợ tạo nhanh cấu trúc dự án mới và file `index.jsp` mẫu ngay trong thư mục `webapps`.
* **Quick Access:** Phím tắt để mở nhanh thư mục mã nguồn (`webapps`) hoặc trình duyệt (`localhost`) để kiểm tra sản phẩm.

---

## 🛠️ Cơ Chế Hoạt Động & Công Nghệ

Dự án sử dụng các kỹ thuật scripting thuần túy của Windows, đảm bảo tính tương thích cao mà không cần cài đặt phần mềm thứ 3:

* **Ngôn ngữ:** Batch Script (`.bat`), PowerShell (xử lý JSON, Download), VBScript (phụ trợ).
* **Cấu hình:** Sử dụng `data.json` để lưu trữ biến môi trường (`TOMCAT_HOME`, `PORT`) thay vì hardcode trong script, giúp dễ dàng chia sẻ và tùy chỉnh.
* **Core Logic:**
    * Wrapper cho các file `startup.bat` và `shutdown.bat` gốc của Tomcat.
    * Kiểm tra port và process ID để xác định trạng thái Server.

---

## 📋 Yêu Cầu Hệ Thống

* **OS:** Windows 10/11 (hoặc các bản Windows cũ hơn có hỗ trợ PowerShell).
* **Environment:** Máy cần cài đặt sẵn **Java (JDK/JRE)** và cấu hình biến `JAVA_HOME`.

---

## 📖 Hướng Dẫn Sử Dụng Nhanh

1.  **Cài đặt:** Tải file `TomcatManager.bat` về máy (Portable, không cần cài đặt).
2.  **Khởi chạy:** Double-click file để chạy.
3.  **Setup lần đầu:**
    * Nếu đã có Tomcat: Nhập đường dẫn thư mục vào tool.
    * Nếu chưa có: Chọn **Option 9** để tool tự tải và cài đặt phiên bản Tomcat mới nhất.
4.  **Điều khiển:** Sử dụng các phím số trên Menu để quản lý:
    * `[1-3]`: Điều khiển Server.
    * `[4]`: Tạo dự án mới.
    * `[5-6]`: Mở thư mục hoặc trình duyệt.
    * `[7]`: Cấu hình lại (Đổi Port, đổi đường dẫn).

---
### 1. Menu Chính (Main Dashboard)
Giao diện trực quan với màu sắc, hiển thị trạng thái Server và các thông tin cấu hình quan trọng ngay lập tức.

```text
============================================================
   APACHE TOMCAT MANAGER (v3.2 - Multi Java)
============================================================

   Tomcat Home: D:\Tools\apache-tomcat-10.1.34
   Tomcat Port: 8080
   Java Home:   C:\Java\jdk-21 [OK]

   STATUS: [  ONLINE  ]  Server is running on port 8080

------------------------------------------------------------

   1. Bat Server (Start)
   2. Tat Server (Stop)
   3. Khoi dong lai (Restart)

   4. Tao Project moi
   5. Quet va Mo Project (Scan Webapps)
   6. Mo thu muc Webapps
   7. Mo Localhost (Root)
   8. Cau hinh lai duong dan Tomcat
   9. Download va Cai dat Tomcat (Moi)

   J. Download va Cai dat Oracle JDK (Tuy chon)
   0. Thoat

------------------------------------------------------------
> Chon chuc nang [0-9, J]: _
```
## ⚠️ Troubleshooting (Xử lý sự cố thường gặp)

* **Lỗi "Port already in use":** Do Tomcat đang chạy ngầm hoặc port mặc định (8080) bị chiếm dụng. -> Sử dụng chức năng **Config (7)** để đổi Port hoặc **Stop (2)** để dừng tiến trình cũ.
* **Lỗi hiển thị màu:** Một số terminal cũ (cmd trên Win 7) không hỗ trợ ANSI color -> Chức năng vẫn hoạt động nhưng giao diện sẽ ở dạng text thuần.

---

**Author:** Nguyễn Quốc Anh (Fullstack Developer)
*Dự án được xây dựng với mục đích học tập và chia sẻ cộng đồng.*
