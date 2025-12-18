# 🚀 Apache Tomcat Manager – Fullstack Edition (v5.2)

**Apache Tomcat Manager CLI** là một công cụ mạnh mẽ, gọn nhẹ dành cho lập trình viên **Java Fullstack**. Công cụ hỗ trợ tự động hóa toàn bộ quy trình từ cài đặt môi trường, quản lý Server cho đến biên dịch (Build) các **Java Servlet** mà không cần sử dụng các IDE nặng nề như IntelliJ Ultimate hay Eclipse.

---

## ✨ Tính Năng Nổi Bật

### 1. Quản Lý Server Toàn Diện

- **Start / Stop / Restart**: Điều khiển Tomcat nhanh gọn chỉ bằng phím số.
- **Auto-Detect Status**: Tự động kiểm tra trạng thái Online/Offline của Server dựa trên Port.
- **Log Monitor**: Theo dõi log chạy của Server trong cửa sổ riêng biệt.

### 2. Selective Build System (Mới v5.2) 🛠️

- **Biên dịch tùy chọn**: Chỉ build đúng file `.java` vừa chỉnh sửa, không cần build lại toàn bộ project.
- **Build All**: Biên dịch toàn bộ source chỉ với phím **A**.
- **Smart Javac**: Tự động nhận diện `JAVA_HOME`, xử lý triệt để lỗi *"javac is not recognized"*.
- **UTF-8 Encoding**: Đảm bảo source code có tiếng Việt không bị lỗi font sau khi biên dịch.

### 3. Xác Nhận An Toàn (Smart Confirmation) 🛡️

- **y/N Dialog**: Hộp thoại xác nhận trước các thao tác quan trọng (Stop, Restart, Build hàng loạt).
- **Case-Insensitive**: Chấp nhận cả `y` và `Y`, thao tác nhanh và linh hoạt.

### 4. Khởi Tạo Cấu Trúc Tự Động

- Tự động sinh cấu trúc chuẩn **Servlet/JSP**: `WEB-INF`, `classes`, `lib`.
- Tạo sẵn `index.jsp` và cấu hình cơ bản để chạy ngay.

---

## 🛠 Yêu Cầu Hệ Thống

- **Hệ điều hành**: Windows 10 / 11
- **Java JDK**: Đã cấu hình biến môi trường `JAVA_HOME`
- **Apache Tomcat**: 9 / 10 / 11 (tự động tải nếu chưa có)

---

## 🚀 Hướng Dẫn Sử Dụng

### 1. Khởi động

```bat
TomCatMenuV5.bat
```

### 2. Cấu hình lần đầu

- Nhập đường dẫn Tomcat hiện có **hoặc**
- Chọn tải Tomcat tự động theo hướng dẫn trong menu

### 3. Biên dịch Java Servlet

1. Nhấn **5** – Quản lý Project
2. Chọn Project cần thao tác
3. Nhấn **2** – Build Java Servlet
4. Chọn số thứ tự file `.java` cần build

### 4. Kiểm tra kết quả

- File `.class` sẽ được tự động copy vào:

```
WEB-INF/classes
```

---

## 📂 Cấu Trúc Project Chuẩn

```text
webapps/
└── YourProject/
    ├── WEB-INF/
    │   ├── classes/    # File thực thi (.class)
    │   ├── lib/        # Thư viện bổ sung (.jar)
    │   └── web.xml     # Cấu hình Deployment
    └── index.jsp       # Giao diện Web
```

---

## 📦 Hợp Tác & Góp Ý

Dự án được xây dựng với mục tiêu hỗ trợ cộng đồng học tập **Java Web** theo hướng thực tế, nhẹ, và dễ triển khai.

Mọi đóng góp về tính năng mới, cải tiến hoặc báo lỗi vui lòng liên hệ qua repository.

---

## 👤 Tác Giả

**Nguyễn Quốc Anh (NQA TECH)**  
Gemini AI Assistant

Chúc bạn có những trải nghiệm lập trình hiệu quả và thú vị cùng Apache Tomcat Manager CLI 🚀

