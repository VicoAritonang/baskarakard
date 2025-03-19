#!/usr/bin/env bash

# Fail if any command fails
set -e
# Debug log
set -x

# Get the absolute path
CURRENT_DIR=$(pwd)

# Install OpenJDK 17
wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
tar xf openjdk-17.0.2_linux-x64_bin.tar.gz

# Set JAVA_HOME with absolute path
export JAVA_HOME="${CURRENT_DIR}/jdk-17.0.2"
export PATH="${JAVA_HOME}/bin:$PATH"

# Debug information
echo "Current directory = ${CURRENT_DIR}"
echo "JAVA_HOME = ${JAVA_HOME}"
echo "PATH = ${PATH}"
java -version

# Verify Java installation
if [ ! -d "${JAVA_HOME}" ]; then
    echo "Error: JAVA_HOME directory does not exist: ${JAVA_HOME}"
    exit 1
fi

if [ ! -x "${JAVA_HOME}/bin/java" ]; then
    echo "Error: Java executable not found or not executable: ${JAVA_HOME}/bin/java"
    exit 1
fi

# Clean up downloaded files
rm openjdk-17.0.2_linux-x64_bin.tar.gz

# Make the changes persist
echo "export JAVA_HOME=${JAVA_HOME}" >> $HOME/.bashrc
echo "export PATH=${JAVA_HOME}/bin:$PATH" >> $HOME/.bashrc
source $HOME/.bashrc 