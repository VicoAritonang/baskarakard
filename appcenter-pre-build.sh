#!/usr/bin/env bash

# Fail if any command fails
set -e
# Debug log
set -x

echo "Current OS: $(uname -a)"
echo "Current directory: $(pwd)"

# Detect OS
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    echo "Detected macOS environment"
    
    # Install OpenJDK 17 via Homebrew
    echo "Installing OpenJDK 17 via Homebrew..."
    brew tap homebrew/cask-versions
    brew install --cask temurin17
    
    # Set JAVA_HOME for macOS
    export JAVA_HOME=$(/usr/libexec/java_home -v 17)
    export PATH="${JAVA_HOME}/bin:$PATH"
else
    # Linux
    echo "Detected Linux environment"
    
    # Install OpenJDK 17
    CURRENT_DIR=$(pwd)
    wget -q https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
    tar xf openjdk-17.0.2_linux-x64_bin.tar.gz
    
    # Set JAVA_HOME with absolute path
    export JAVA_HOME="${CURRENT_DIR}/jdk-17.0.2"
    export PATH="${JAVA_HOME}/bin:$PATH"
    
    # Clean up downloaded files
    rm openjdk-17.0.2_linux-x64_bin.tar.gz
fi

# Debug information
echo "JAVA_HOME = ${JAVA_HOME}"
echo "PATH = ${PATH}"

# Verify Java installation
echo "Verifying Java installation..."
if [ ! -d "${JAVA_HOME}" ]; then
    echo "Error: JAVA_HOME directory does not exist: ${JAVA_HOME}"
    exit 1
fi

if [ ! -x "${JAVA_HOME}/bin/java" ]; then
    echo "Error: Java executable not found or not executable: ${JAVA_HOME}/bin/java"
    exit 1
fi

# Print Java version
java -version

# Make the changes persist
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    echo "export JAVA_HOME=${JAVA_HOME}" >> $HOME/.bash_profile
    echo "export PATH=${JAVA_HOME}/bin:$PATH" >> $HOME/.bash_profile
    source $HOME/.bash_profile
else
    # Linux
    echo "export JAVA_HOME=${JAVA_HOME}" >> $HOME/.bashrc
    echo "export PATH=${JAVA_HOME}/bin:$PATH" >> $HOME/.bashrc
    source $HOME/.bashrc
fi

# Create a local.properties file with sdk.dir
echo "Creating local.properties file..."
echo "sdk.dir=${ANDROID_HOME}" > android/local.properties
echo "flutter.sdk=${HOME}/flutter" >> android/local.properties

echo "Pre-build setup completed successfully" 