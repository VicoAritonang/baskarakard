# Baskara Card
[![Build status](https://build.appcenter.ms/v0.1/apps/9b2fe2fc-7ab6-4be2-ace8-c7182ecd688b/branches/main/badge)](https://appcenter.ms)
Aplikasi Flutter untuk Baskara Card yang menggunakan Firebase dan QR scanner.

## Cara Build di App Center

### 1. Setup Environment Variables di App Center

Tambahkan environment variables berikut di konfigurasi build App Center:

- `KEY_PASSWORD`: Password untuk keystore (diperlukan untuk signing)
- `GOOGLE_SERVICES_JSON_BASE64`: Isi file `google-services.json` yang di-encode dengan base64
- `KEYSTORE_BASE64`: Isi file keystore yang di-encode dengan base64 (opsional)

### 2. Setup Build Scripts

App Center memiliki dukungan untuk script pre-build dan post-clone. Pastikan file berikut ada di root repository:

- `appcenter-post-clone.sh`: Script untuk setup Flutter dan build APK

### 3. Mempersiapkan File Keystore

Untuk membuat file keystore:

```bash
keytool -genkey -v -keystore release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

Setelah membuat keystore, encode sebagai base64:

```bash
base64 -i release-keystore.jks
```

Tambahkan hasil encode sebagai environment variable `KEYSTORE_BASE64` di App Center.

### 4. Mempersiapkan File google-services.json

Untuk mengkonversi file google-services.json ke base64:

```bash
base64 -i google-services.json
```

Tambahkan hasil encode sebagai environment variable `GOOGLE_SERVICES_JSON_BASE64` di App Center.

## Troubleshooting Build

Jika terjadi masalah dengan build:

1. **Java Version**: Pastikan App Center menggunakan JDK 17 (diatur dalam `appcenter-post-clone.sh`)
2. **Gradle Version**: Versi Gradle harus sesuai dengan Android Gradle Plugin
3. **Kotlin Version**: Versi Kotlin harus konsisten di semua file konfigurasi
4. **Missing google-services.json**: Tambahkan file google-services.json atau gunakan environment variable

## Konfigurasi Lokal

Untuk build lokal:

1. Install Flutter
2. Setup JDK 17
3. Run `flutter pub get`
4. Run `flutter build apk --release`
