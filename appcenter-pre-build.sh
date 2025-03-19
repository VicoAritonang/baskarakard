#!/usr/bin/env bash

# Fail if any command fails
set -e
# Debug log
set -x

# Install OpenJDK 17
wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
tar xf openjdk-17.0.2_linux-x64_bin.tar.gz

# Set JAVA_HOME
export JAVA_HOME=$PWD/jdk-17.0.2
export PATH=$JAVA_HOME/bin:$PATH

# Debug information
echo "JAVA_HOME = $JAVA_HOME"
echo "PATH = $PATH"
java -version

# Clean up downloaded files
rm openjdk-17.0.2_linux-x64_bin.tar.gz 