# 🚀 Apache Tomcat Manager – Fullstack Edition (v9)

**Apache Tomcat Manager CLI v9** (Cyber Neon Ultra) là phiên bản hoàn thiện nhất, tập trung vào **độ ổn định tuyệt đối (Robustness)** và trải nghiệm người dùng.

---

## ✨ Tính Năng Mới (Update v9)

### 💎 Độ Ổn Định & Tự Động Hóa (Stability)
-   **Smart MySQL Start**: Tự động phát hiện lỗi thiếu Data hoặc thiếu Config.
    -   *Missing Data?* -> Tự động chạy `initialize-insecure`.
    -   *Missing my.ini?* -> Tự động tạo lại file config chuẩn.
    -   **Kết quả**: Không bao giờ bị crash hoặc tắt tool đột ngột.
-   **Bulk Build System**: Cơ chế Build mới (`javac @sources.txt`) giúp compile dự án lớn siêu tốc, không lo lỗi phụ thuộc file.
-   **Crash Config Fix**: Tích hợp `pushd/popd` để xử lý đường dẫn an toàn, không bị lỗi "Can't change dir" khi tên user có khoảng trắng.

### 🎨 Giao Diện & Tiện Ích (UX)
-   **Project Menu 2.0**: Giao diện quản lý Project dạng danh sách dọc, trực quan.
-   **Smart Editor**: Tự động phát hiện **VS Code**:
    -   Nếu có: Mở project bằng VS Code.
    -   Nếu không: Mở Explorer (Sẵn sàng cho Notepad/IntelliJ).
-   **Config Manager**: Menu cấu hình XAMPP-style (Phím **C**) để sửa `server.xml`, `my.ini` nhanh.

### 🚀 Hệ Thống Core
-   **BitsTransfer**: Tải MySQL/JDBC bằng giao thức native của Windows (Nhanh, không cần User-Agent).
-   **Cloud Mirror**: Server tải MySQL riêng (`cloud.nguyenquocanh.io.vn`) đảm bảo tốc độ cao.

---

## 🛠 Yêu Cầu Hệ Thống

-   **OS**: Windows 10 / 11
-   **Java**: JDK 8+ (Đã cài biến môi trường `JAVA_HOME`)
-   **Tomcat**: Tự động tải hoặc dùng bản có sẵn.
-   **MySQL**: Tự động tải bản Portable 9.4.0 (Nếu chưa có).

---

## 🚀 Hướng Dẫn Sử Dụng

### 1. Khởi động
Chạy file `TomCatMenuV7.cmd` (v9 Core) để vào menu chính.

### 2. Menu Chức Năng (KeyMap)

#### Hệ Thống
-   **[S] Config Paths**: Cấu hình đường dẫn/Port.
-   **[C] Config Files**: Mở nhanh các file cấu hình.
-   **[R] Refresh**: Làm mới trạng thái Server.
-   **[D] Download**: Tải MySQL / JDBC Driver.

#### Tomcat Server
-   **[1] Start**: Bật Server.
-   **[2] Stop**: Tắt Server.
-   **[4] Logs**: Xem log console.
-   **[5] User Manager**: Thêm user admin vào `tomcat-users.xml`.

#### MySQL Database (Smart Mode)
-   **[M1] Start**: Bật MySQL (Tự động Init/Repair nếu cần).
-   **[M5] Auto Lab 13**: Tạo DB `lab13_jdbc` và bảng `users`.
-   **[M6] Backup DB**: Xuất file `.sql`.
-   **[M7] Restore DB**: Nhập dữ liệu từ file `.sql`.

#### Project Workspace
-   **[6] New Project**: Tạo Project mới (Servlet/JDBC Template).
-   **[7] Scan Projects**: Quản lý Project (Build, Edit VSCode, Browser).

---

## � Kịch Bản Mẫu (Step-by-Step)

Quy trình chuẩn để làm bài Lab (VD: Lab 13 - JDBC):

**B1: Chuẩn bị môi trường**
1.  Chọn **[D] Download** -> Tải MySQL (2) và JDBC Driver (1).
2.  Chọn **[M1] Start MySQL**. (Lần đầu sẽ mất 20s để Init).
3.  Chọn **[M5] Auto Setup Lab13** -> Tạo sẵn database `lab13_jdbc` và bảng `users`.

**B2: Tạo Project**
1.  Chọn **[6] New Project** -> Nhập tên (VD: `Lab13`).
2.  Chọn Template **2. JDBC Template**.
    -   *Script sẽ tự copy thư viện mysql-connector.jar vào lib cho bạn.*

**B3: Code & Build**
1.  Chọn **[7] Scan Projects** -> Chọn `Lab13`.
2.  Chọn **[3] Edit Source** (Mở VS Code). Sửa file `TestDB.java`.
3.  Quay lại menu, Chọn **[1] Build**. (Chờ báo *Build Success*).

**B4: Chạy thử**
1.  Về Menu chính, chọn **[3] Restart Tomcat**.
2.  Vào lại **[7] Scan** -> `Lab13` -> **[2] Open Browser**.
3.  Thêm `/testdb` vào link trên trình duyệt để test kết nối.

---

## �🔧 Troubleshooting (Sửa lỗi thường gặp)

**1. Lỗi "Can't change dir" khi start MySQL?**
-   **Đã Fix ở v9**: Script tự động xử lý đường dẫn có dấu cách.

**2. Tool bị tắt khi ấn Start MySQL?**
-   **Đã Fix ở v9**: Script đã tách logic Auto-Init ra khỏi khối lệnh gây lỗi.

---

## 👤 Tác Giả & Phiên Bản

**Phát triển bởi**: Nguyễn Quốc Anh (NQA TECH) & Gemini AI
**Phiên bản hiện tại**: 9.0.0 (Cyber Neon Ultra)
**Update**: 19/12/2025
