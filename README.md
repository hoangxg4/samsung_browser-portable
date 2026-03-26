# Samsung Browser Portable

Samsung Browser Portable là phiên bản di động của Samsung Internet Browser, được tùy chỉnh với Chrome++ và Widevine DRM, dựa trên cấu trúc của Chromium Hibbiki Portable.

## Tính năng

- **Samsung Internet Browser**: Trình duyệt của Samsung với giao diện đẹp và mượt mà
- **Chrome++**: Tính năng mở rộng cho trình duyệt Chromium
- **Widevine DRM**: Hỗ trợ Netflix, Disney+, Spotify, Amazon Prime Video
- **Portable**: Dữ liệu được lưu trữ cục bộ, có thể mang theo
- **Debloat**: Tối ưu hiệu năng, tăng quyền riêng tư
- **Auto Update**: Tự động cập nhật phiên bản mới
- **Hỗ trợ MV2**: Tiếp tục hỗ trợ tiện ích Manifest V2

## Hướng dẫn cài đặt

### Bước 1: Tải và cài đặt

Chạy `build.bat` để tải và cài đặt Samsung Browser.

```batch
build.bat
```

Script sẽ:
1. Tải Samsung Browser Offline từ GitHub
2. Giải nén các file cần thiết
3. Cài đặt Widevine DRM
4. Tạo shortcut khởi động

### Bước 2: Khởi động trình duyệt

Sau khi cài đặt, bạn có thể:
- Chạy `SamsungBrowser.lnk` (shortcut)
- Hoặc chạy trực tiếp `Chrome-bin\samsunginternet.exe` với tham số:
  ```
  --user-data-dir="Data" --cache-dir="Cache"
  ```

## Các file và công dụng

| File | Mô tả |
|------|-------|
| `build.bat` | Tải và cài đặt Samsung Browser lần đầu |
| `update.bat` | Cập nhật lên phiên bản mới nhất |
| `install-widevine.bat` | Cài đặt/tái cài Widevine DRM |
| `default-apps.bat` | Đặt làm trình duyệt mặc định |
| `chrome++.ini` | Cấu hình Chrome++ |
| `debloater.reg` | Tối ưu hóa Registry (chạy bằng quản trị viên) |
| `SamsungBrowser.lnk` | Shortcut khởi động nhanh |

## Cấu trúc thư mục

```
SamsungBrowser-Portable/
├── SamsungBrowser.lnk      # Shortcut khởi động
├── build.bat               # Script cài đặt
├── update.bat              # Script cập nhật
├── install-widevine.bat    # Script cài Widevine
├── default-apps.bat       # Script đặt mặc định
├── chrome++.ini           # Cấu hình Chrome++
├── debloater.reg          # Registry debloat
├── version.txt            # Phiên bản hiện tại
├── index.html             # Trang thông tin
├── Chrome-bin/            # Thư mục trình duyệt
│   ├── samsunginternet.exe
│   └── ...
├── Data/                  # Dữ liệu người dùng (profile)
├── Cache/                 # Thư mục cache
└── WidevineCdm/           # Widevine DRM (gốc)
```

## Cập nhật

Để cập nhật lên phiên bản mới:

```batch
update.bat
```

**Lưu ý**: Dữ liệu người dùng trong thư mục `Data/` sẽ được giữ nguyên sau khi cập nhật.

## Gỡ bỏ

Để gỡ bỏ, chỉ cần xóa toàn bộ thư mục `SamsungBrowser-Portable/`.

## Yêu cầu

- Windows 10/11 (64-bit)
- 7-Zip để giải nén file .7z (nếu cần)

## Credits

- **Chromium Hibbiki**: [bibicadotnet/chromium-hibbiki-portable](https://github.com/bibicadotnet/chromium-hibbiki-portable)
- **Samsung Browser Offline**: [hoangxg4/samsung_browser-offline-installer](https://github.com/hoangxg4/samsung_browser-offline-installer)
- **Chrome++**: [Bush2021/chrome_plus](https://github.com/Bush2021/chrome_plus)

## License

GNU General Public License v3.0 - Xem file LICENSE để biết thêm chi tiết.
