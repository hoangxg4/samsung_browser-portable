# 🌐 Samsung Browser Portable (Windows)

Phiên bản **Samsung Internet Browser** dành cho máy tính (Windows), được đóng gói dưới dạng **Portable** (không cần cài đặt), tích hợp các công cụ tối ưu hiệu năng và bảo mật.

---

## ✨ Tính năng nổi bật

- 🚀 **Portable 100%**: Toàn bộ dữ liệu người dùng (Bookmark, mật khẩu, lịch sử) lưu tại thư mục `Data`. Không để lại rác trong hệ thống.
- 🛠️ **Chrome++ Tích hợp**: Hỗ trợ tinh chỉnh hệ thống, chặn quảng cáo và tối ưu nhân Chromium.
- 🎬 **Widevine DRM**: Hỗ trợ xem nội dung bản quyền độ phân giải cao (Netflix, Disney+, Spotify, HBO Max...).
- 🛡️ **Privacy Debloat**: Loại bỏ các dịch vụ theo dõi (Telemetries), AI không cần thiết và thu thập dữ liệu ẩn từ Google/Samsung.
- ⚡ **Cloudflare Gateway**: Tích hợp sẵn DoH Cloudflare để tăng tốc truy cập và bảo mật kết nối.

---

## 📥 Tải về

Bạn luôn có thể tải phiên bản mới nhất tại:
👉 **[Samsung Browser Releases](https://github.com/hoangxg4/samsung_browser-portable/releases)**

---

## 🚀 Hướng dẫn sử dụng

1. **Tải file**: Chọn bản `SamsungBrowser-X.X.X.X.zip` mới nhất.
2. **Giải nén**: Giải nén file ZIP vào một thư mục bất kỳ (ví dụ: `D:\Browsers\`).
3. **Sử dụng**: 
   - Vào thư mục `Samsung_Browser`.
   - Chạy **`samsunginternet.exe`** để bắt đầu lướt web.

> [!TIP]
> **Để đặt làm trình duyệt mặc định:** Chạy file `default-apps-multi-profile.bat` bằng quyền **Admin** và làm theo hướng dẫn trên màn hình.

---

## 📂 Danh sách các file quan trọng

| File | Chức năng |
| :--- | :--- |
| `Samsung_Browser/` | Thư mục chứa lõi trình duyệt và các file thực thi. |
| `default-apps-multi-profile.bat` | Đăng ký trình duyệt với Windows (Default Browser). |
| `update.bat` | Tự động kiểm tra và cập nhật lên phiên bản mới nhất từ GitHub. |
| `chrome++.ini` | Cấu hình chuyên sâu cho nhân Chrome++. |
| `debloater.reg` | File Registry tối ưu chính sách bảo mật và hiệu năng (Tùy chọn). |
| `Data/` | Nơi lưu trữ toàn bộ dữ liệu cá nhân của bạn. |

---

## 🔄 Cập nhật

Để cập nhật phiên bản mới mà không mất dữ liệu:
1. Chạy file **`update.bat`** bên trong thư mục trình duyệt.
2. Script sẽ tự động tải bản mới nhất, ghi đè lõi trình duyệt nhưng **giữ lại** thư mục `Data` (Bookmark/Pass) và các file cấu hình cá nhân của bạn.

---

## 🤝 Credits

Dự án này được phát triển dựa trên nỗ lực của cộng đồng:
- **[chromium-hibbiki-portable](https://github.com/bibicadotnet/chromium-hibbiki-portable)** - Nguồn cảm hứng và cấu trúc Portable.
- **[hoangxg4/samsung_browser-offline-installer](https://github.com/hoangxg4/samsung_browser-offline-installer)** - Bộ cài Offline chính thức.
- **[GreenZero](https://github.com/Bush2021/chrome_plus)** - Tác giả của Chrome++.

---
*Phát triển và bảo trì bởi **CezDev Bot** & **hoangxg4***.
