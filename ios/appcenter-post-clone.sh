#!/usr/bin/env bash
# Pastikan script berjalan dari root project
cd ..

# Gagal jika ada perintah yang gagal
set -e
# Debug log
set -x

# Clone flutter repo
git clone -b stable https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

# Switch ke flutter stable channel
flutter channel stable
flutter doctor

echo "Flutter ter-install di `pwd`/flutter"

# Jalankan flutter pub get untuk menghasilkan Generated.xcconfig
flutter pub get

# Pastikan Generated.xcconfig sudah dibuat
if [ ! -f ios/Flutter/Generated.xcconfig ]; then
  echo "Generated.xcconfig belum dibuat, menjalankan pub get ulang"
  flutter pub get
fi

# Periksa lagi dan pastikan file ada
if [ ! -f ios/Flutter/Generated.xcconfig ]; then
  echo "Membuat Generated.xcconfig secara manual"
  
  # Dapatkan path flutter
  FLUTTER_ROOT=`pwd`/flutter
  
  # Buat file Generated.xcconfig manual
  echo "// This is a generated file; do not edit or check into version control." > ios/Flutter/Generated.xcconfig
  echo "FLUTTER_ROOT=$FLUTTER_ROOT" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_APPLICATION_PATH=`pwd`" >> ios/Flutter/Generated.xcconfig
  echo "COCOAPODS_PARALLEL_CODE_SIGN=true" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_TARGET=lib/main.dart" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_BUILD_DIR=build" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_BUILD_NAME=1.0.0" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_BUILD_NUMBER=1" >> ios/Flutter/Generated.xcconfig
  echo "EXCLUDED_ARCHS=arm64" >> ios/Flutter/Generated.xcconfig
  echo "DART_OBFUSCATION=false" >> ios/Flutter/Generated.xcconfig
  echo "TRACK_WIDGET_CREATION=true" >> ios/Flutter/Generated.xcconfig
  echo "TREE_SHAKE_ICONS=false" >> ios/Flutter/Generated.xcconfig
  echo "PACKAGE_CONFIG=.dart_tool/package_config.json" >> ios/Flutter/Generated.xcconfig
fi

# Install CocoaPods
sudo gem install cocoapods

# Build iOS
cd ios
# Pastikan podfile ada dan diperbarui
pod install || pod install --repo-update

# Kembali ke direktori utama
cd ..

# Setup untuk XCode build
flutter build ios --release --no-codesign 