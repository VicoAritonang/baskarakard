#!/usr/bin/env bash

# Fail if any command fails
set -e
# Debug log
set -x

echo "Post Clone Script Started"

# Install JDK 17 on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Installing JDK 17 on macOS..."
    brew tap homebrew/cask-versions
    brew install --cask temurin17
    
    export JAVA_HOME=$(/usr/libexec/java_home -v 17)
    export PATH="$JAVA_HOME/bin:$PATH"
    
    echo "JAVA_HOME=$JAVA_HOME"
    java -version
fi

# Install Flutter
echo "Installing Flutter..."
git clone -b stable https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

# Switch ke flutter stable channel
flutter channel stable
flutter doctor

echo "Flutter ter-install di `pwd`/flutter"

# Install dependencies
flutter pub get

# Pastikan Generated.xcconfig sudah dibuat
if [ ! -f ios/Flutter/Generated.xcconfig ]; then
  echo "Generated.xcconfig belum dibuat, membuat secara manual"
  
  # Dapatkan path flutter
  FLUTTER_ROOT=`pwd`/flutter
  
  # Buat file Generated.xcconfig manual
  mkdir -p ios/Flutter
  echo "// This is a generated file; do not edit or check into version control." > ios/Flutter/Generated.xcconfig
  echo "FLUTTER_ROOT=$FLUTTER_ROOT" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_APPLICATION_PATH=`pwd`" >> ios/Flutter/Generated.xcconfig
  echo "COCOAPODS_PARALLEL_CODE_SIGN=true" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_TARGET=lib/main.dart" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_BUILD_DIR=build" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_BUILD_NAME=1.0.0" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_BUILD_NUMBER=1" >> ios/Flutter/Generated.xcconfig
  echo "EXCLUDED_ARCHS=" >> ios/Flutter/Generated.xcconfig
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

# Accept licenses
echo "y" | flutter doctor --android-licenses

# Run flutter doctor
flutter doctor -v

# Verify flutter is installed
echo "Installed flutter to $HOME/flutter"

# Create local.properties file
echo "Creating local.properties file..."
echo "sdk.dir=$ANDROID_HOME" > android/local.properties
echo "flutter.sdk=$HOME/flutter" >> android/local.properties

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Copy google-services.json
echo "Copying google-services.json..."
if [ ! -f "android/app/google-services.json" ]; then
    # Decode the base64 encoded google-services.json
    if [ -n "$GOOGLE_SERVICES_JSON_BASE64" ]; then
        echo "Using GOOGLE_SERVICES_JSON_BASE64 environment variable"
        echo $GOOGLE_SERVICES_JSON_BASE64 | base64 --decode > android/app/google-services.json
    else
        echo "WARNING: No google-services.json found!"
    fi
fi

# Extract keystore from environment variable if needed
if [ -n "$KEYSTORE_BASE64" ]; then
    echo "Extracting keystore from KEYSTORE_BASE64 environment variable"
    echo $KEYSTORE_BASE64 | base64 --decode > release-keystore.jks
fi

# Build the app
echo "Building APK..."
flutter build apk --release

echo "Post Clone Script Completed Successfully" 