#!/usr/bin/env bash
set -e # exit on first error
set -x # echo all commands for debugging

echo "Post-build script executed"

# Jika build berhasil, Anda bisa melakukan tindakan tambahan di sini
# Misalnya, notifikasi ke Slack, atau custom tasks lainnya

# Path output build
BUILD_OUTPUT_PATH="ios/build/ArchiveIntermediates/Runner/IPA"

# Tampilkan isi direktori build untuk debugging
echo "Build output contents:"
ls -la $BUILD_OUTPUT_PATH 2>/dev/null || echo "Build output directory not found" 