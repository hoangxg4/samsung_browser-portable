import requests
import json
import urllib3
import uuid
import os
import zipfile
import sys
import subprocess
import shutil

# Tắt cảnh báo bảo mật SSL
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def get_samsung_version():
    """Lấy phiên bản mới nhất từ Samsung server"""
    url = "https://update.internet.apps.samsung.com/service/update2/json"
    req_id = f"{{{uuid.uuid4()}}}"
    sess_id = f"{{{uuid.uuid4()}}}"

    headers = {
        "Content-Type": "application/json",
        "User-Agent": "SamsungInternetUpdater 143.0.0.8",
        "X-Goog-Update-AppId": "ohpjbciplfdockeiligelcjnkiejldpn",
        "X-Goog-Update-Interactivity": "fg",
        "X-Goog-Update-Updater": "updater-143.0.7499.194"
    }

    payload = {
        "request": {
            "@os": "win",
            "@updater": "updater",
            "acceptformat": "crx3,download,puff,run,xz,zucc",
            "apps": [{
                "appid": "ohpjbciplfdockeiligelcjnkiejldpn",
                "enabled": True,
                "installdate": -1,
                "installsource": "taggedmi",
                "updatecheck": {"sameversionupdate": True},
                "version": "0.0.0.0"
            }],
            "arch": "x64",
            "dedup": "cr",
            "domainjoined": False,
            "hw": {"avx": True, "physmemory": 16, "sse": True, "sse2": True, "sse3": True, "sse41": True, "sse42": True, "ssse3": True},
            "ismachine": True,
            "os": {"arch": "x86_64", "platform": "Windows", "version": "10.0.26200.8037"},
            "prodversion": "143.0.7499.194",
            "protocol": "4.0",
            "requestid": req_id,
            "sessionid": sess_id,
            "updaterversion": "143.0.7499.194"
        }
    }

    try:
        response = requests.post(url, headers=headers, json=payload, verify=False, timeout=30)
        response.raise_for_status()

        raw_text = response.text
        if raw_text.startswith(")]}'"):
            raw_text = raw_text[4:].strip()

        data = json.loads(raw_text)
        app = data.get('response', {}).get('apps', [])[0]

        if 'updatecheck' in app and app['updatecheck'].get('status') == 'ok':
            update_info = app['updatecheck']['pipelines'][0]['operations'][0]
            new_version = app['updatecheck']['nextversion']
            download_url = update_info['urls'][0]['url']
            file_size = update_info['size']
            return new_version, download_url, file_size
    except Exception as e:
        print(f"❌ Lỗi khi lấy thông tin từ Samsung: {e}")
    
    return None, None, None

def auto_update_samsung_browser():
    # 1. Đọc phiên bản hiện tại
    current_version = ""
    if os.path.exists("version.txt"):
        with open("version.txt", "r", encoding="utf-8") as f:
            current_version = f.read().strip()

    print(f"🔍 Đang kiểm tra bản cập nhật...")
    print(f"   Phiên bản hiện tại: {current_version if current_version else 'Chưa có'}")

    # 2. Lấy phiên bản mới
    new_version, download_url, file_size = get_samsung_version()
    
    if not new_version:
        print("❌ Không thể lấy thông tin phiên bản mới")
        return False

    print(f"🚀 PHÁT HIỆN BẢN MỚI: v{new_version}")
    print(f"🔗 Link tải: {download_url}")
    print(f"📦 Kích thước: {file_size // (1024*1024)} MB")

    # 3. So sánh phiên bản
    gh_output = os.environ.get('GITHUB_OUTPUT')
    
    if new_version == current_version:
        print(f"✅ Phiên bản v{new_version} đang là mới nhất!")
        if gh_output:
            with open(gh_output, 'a') as f:
                f.write("update_found=false\n")
        return False

    # 4. Tải file
    print(f"\n📥 Đang tải bộ cài...")
    filename = f"SamsungInternet_Offline_v{new_version}.zip"
    
    with requests.get(download_url, stream=True) as r:
        r.raise_for_status()
        with open(filename, 'wb') as f:
            dl = 0
            for chunk in r.iter_content(chunk_size=1024*1024): 
                if chunk:
                    f.write(chunk)
                    dl += len(chunk)
                    done = int(50 * dl / file_size)
                    sys.stdout.write(f"\rTiến trình: [{'█' * done}{'.' * (50-done)}] {dl//(1024*1024)}MB / {file_size//(1024*1024)}MB")
                    sys.stdout.flush()

    print(f"\n✅ Tải hoàn tất!")

    # 5. Giải nén
    print(f"\n📦 Đang giải nén...")
    extract_folder = f"Samsung_Installer_v{new_version}"
    
    if os.path.exists(extract_folder):
        shutil.rmtree(extract_folder)
    os.makedirs(extract_folder)

    with zipfile.ZipFile(filename, 'r') as zip_ref:
        zip_ref.extractall(extract_folder)
    
    # Tìm mini_installer.exe
    mini_installer = None
    for root, dirs, files in os.walk(extract_folder):
        for file in files:
            if file == "mini_installer.exe":
                mini_installer = os.path.join(root, file)
                break
    
    if not mini_installer:
        print("❌ Không tìm thấy mini_installer.exe")
        return False
    
    print(f"✅ Tìm thấy: mini_installer.exe")

    # 6. Giải nén mini_installer (chứa samsunginternet.7z)
    print(f"📦 Đang giải nén mini_installer...")
    
    # Chạy silent extraction
    temp_dir = "temp_extract"
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    os.makedirs(temp_dir)
    
    try:
        # Thử với 7-Zip nếu có
        sevenzip = "C:\\Program Files\\7-Zip\\7z.exe"
        if not os.path.exists(sevenzip):
            sevenzip = "C:\\Program Files (x86)\\7-Zip\\7z.exe"
        
        if os.path.exists(sevenzip):
            subprocess.run([sevenzip, 'x', mini_installer, f'-o{temp_dir}', '-y'], 
                         capture_output=True, timeout=120)
        else:
            # Chạy trực tiếp installer
            subprocess.run([mini_installer, f'/s /d"{temp_dir}"'], 
                         capture_output=True, timeout=120)
    except Exception as e:
        print(f"⚠️ Lỗi giải nén installer: {e}")
    
    # Tìm samsunginternet.7z
    seven_zip = None
    for root, dirs, files in os.walk(temp_dir):
        for file in files:
            if file == "samsunginternet.7z":
                seven_zip = os.path.join(root, file)
                break
    
    if not seven_zip:
        # Thử tìm trong thư mục khác
        for root, dirs, files in os.walk(extract_folder):
            for file in files:
                if file.endswith(".7z"):
                    seven_zip = os.path.join(root, file)
                    break
    
    if not seven_zip:
        print("❌ Không tìm thấy samsunginternet.7z")
        return False
    
    print(f"✅ Tìm thấy: samsunginternet.7z")

    # 7. Giải nén samsunginternet.7z -> Chrome-bin
    print(f"📦 Đang giải nén samsunginternet.7z...")
    
    chrome_bin = "Chrome-bin"
    if os.path.exists(chrome_bin):
        shutil.rmtree(chrome_bin)
    os.makedirs(chrome_bin)
    
    if os.path.exists(sevenzip):
        subprocess.run([sevenzip, 'x', seven_zip, f'-o{chrome_bin}', '-y'], 
                       capture_output=True, timeout=300)
    else:
        print("❌ Cần cài đặt 7-Zip để giải nén .7z")
        return False

    # 8. Kiểm tra kết quả
    exe_files = []
    for root, dirs, files in os.walk(chrome_bin):
        for file in files:
            if file.endswith(".exe") and "samsung" in file.lower():
                exe_files.append(os.path.join(root, file))
    
    if exe_files:
        print(f"✅ Tìm thấy: {os.path.basename(exe_files[0])}")
    else:
        print("⚠️ Không tìm thấy samsunginternet.exe")

    # 9. Cleanup
    os.remove(filename)
    shutil.rmtree(extract_folder)
    shutil.rmtree(temp_dir)

    # 10. Lưu phiên bản
    with open("version.txt", "w", encoding="utf-8") as f:
        f.write(new_version)

    print(f"\n🎉 HOÀN TẤT!")
    print(f"   Phiên bản: {new_version}")
    print(f"   Thư mục: Chrome-bin/")

    # Lưu output cho GitHub Actions
    if gh_output:
        with open(gh_output, 'a') as f:
            f.write("update_found=true\n")
            f.write(f"version={new_version}\n")

    return True

if __name__ == "__main__":
    success = auto_update_samsung_browser()
    sys.exit(0 if success else 1)
