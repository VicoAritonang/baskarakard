# Panduan Deployment App Center

## Setup iOS

Untuk men-deploy aplikasi iOS ke App Center, ikuti langkah-langkah berikut:

### 1. Setup App Center

1. Buat akun di [App Center](https://appcenter.ms/) jika belum memilikinya
2. Buat aplikasi baru di App Center untuk platform iOS
3. Catat App Secret yang diberikan oleh App Center

### 2. Konfigurasi Project

1. Ganti `YOUR_IOS_APP_SECRET_HERE` di file `ios/Runner/AppCenter-Config.plist` dengan App Secret Anda
2. Ganti string kosong di `AppCenter.start(withAppSecret: "", services: [` pada `ios/Runner/AppDelegate.swift` dengan App Secret Anda
3. Pastikan Anda memiliki alamat email Apple Developer yang terdaftar
4. Upload file provisioning profile (jika diperlukan) melalui dashboard App Center

### 3. Setup Build Configuration di App Center

1. Hubungkan repositori GitHub/Bitbucket/Azure DevOps Anda ke App Center
2. Pilih branch yang ingin di-build
3. Konfigurasikan build dengan:
   - Pilih tipe signing "Ad hoc"
   - Aktifkan opsi "Automatically increment build number"
   - Pilih distribusi release ke grup yang diinginkan

### 4. File Konfigurasi yang Telah Dibuat

- `ios/appcenter-post-clone.sh`: Script yang dijalankan setelah repo di-clone di App Center
- `ios/Runner/AppCenter-Config.plist`: Konfigurasi App Center untuk iOS
- `ios/Podfile`: File CocoaPods untuk dependensi iOS

## Setup Android

Untuk Android, pastikan file berikut sudah dikonfigurasi dengan benar:

- `android/app/appcenter-post-clone.sh`: Script yang dijalankan setelah repo di-clone di App Center
- `android/app/build.gradle`: Pastikan menggunakan signing config yang benar

### Catatan Penting

- Keystore untuk release signing harus di-encode dengan base64 dan ditambahkan sebagai environment variable `KEY_JKS` di App Center
- Untuk debug build, tidak diperlukan keystore khusus dan akan menggunakan debug keystore

## Troubleshooting

Jika mengalami masalah saat build:

1. Pastikan semua script post-clone memiliki permission eksekusi (executable)
2. Periksa log build di App Center untuk detail error yang lebih spesifik
3. Pastikan versi Flutter yang di-clone di script post-clone kompatibel dengan project Anda
4. Jika ada error CocoaPods, coba hapus Pod lockfile dan jalankan `pod install` ulang 