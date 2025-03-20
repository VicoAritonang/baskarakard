# Panduan Deployment App Center

## Setup iOS

Untuk men-deploy aplikasi iOS ke App Center, ikuti langkah-langkah berikut:

### 1. Setup App Center

1. Buat akun di [App Center](https://appcenter.ms/) jika belum memilikinya
2. Buat aplikasi baru di App Center untuk platform iOS
3. App Secret sudah dikonfigurasi di project: `fd066da5-8929-4595-9e91-403c87411364`

### 2. Konfigurasi Project

File-file berikut sudah dikonfigurasi dengan benar:
- `ios/Runner/AppCenter-Config.plist` - Berisi App Secret
- `ios/Runner/AppDelegate.swift` - Inisialisasi App Center
- `ios/Podfile` - Konfigurasi CocoaPods
- `ios/Flutter/Release.xcconfig` dan `ios/Flutter/Debug.xcconfig` - Tidak memerlukan Generated.xcconfig lagi

### 3. File Build Script

File-file build script berikut telah ditambahkan ke repo:
- `appcenter-post-clone.sh` - Script yang dijalankan setelah repo di-clone
- `appcenter-post-build.sh` - Script yang dijalankan setelah build (opsional)

### 4. Setup Build Configuration di App Center

1. Connect repository:
   - Hubungkan repositori GitHub/Bitbucket/Azure DevOps Anda ke App Center
   - Pilih branch yang ingin di-build

2. Build configuration:
   - Pilih Xcode 14+ (versi terbaru yang tersedia)
   - Scheme: Runner
   - Configuration: Release
   - SDK: Latest iOS
   - Build for devices: Yes
   - Automatic signing: Yes (jika menggunakan automatic signing)
   - Increment build number: Yes

3. Build scripts:
   - Post-clone script: Pastikan path diatur ke `/appcenter-post-clone.sh`
   - Post-build script: Opsional, atur ke `/appcenter-post-build.sh` jika diperlukan

4. Distribution:
   - Release type: Store atau Ad-hoc sesuai kebutuhan
   - Destination: Pilih grup distribusi yang sesuai

### 5. Troubleshooting iOS Build

Jika build masih gagal, periksa log untuk error spesifik:

1. **Generated.xcconfig tidak ditemukan**: 
   - Script post-clone dibuat untuk mengatasi masalah ini
   - File Debug.xcconfig dan Release.xcconfig sudah dimodifikasi untuk tidak memerlukan Generated.xcconfig

2. **Cocoapods Issues**:
   - Script post-clone akan menginstall dan menjalankan pod install
   - Jika masih ada masalah, coba tambahkan langkah pod install yang terpisah

3. **Signing Issues**:
   - Konfigurasi dalam script diatur untuk non-signing build
   - Jika memerlukan signed build, tambahkan provisioning profile di App Center

## Setup Android

Android build telah sukses. Berikut pengaturan agar Android tetap berjalan lancar:

- Debug signing config digunakan untuk release build saat ini
- Keystore untuk release signing harus di-encode dengan base64 dan ditambahkan sebagai environment variable `KEY_JKS` di App Center jika diperlukan signing khusus

## Catatan Penting

- Jika ada perubahan struktur project, update script post-clone
- Pastikan versi Flutter yang digunakan dalam script kompatibel dengan project Anda 