#!/bin/bash
# Build script for Linux
# Creates binary output in bin directory

echo "Building raypong for Linux..."

# Create bin directory if it doesn't exist
mkdir -p bin

# Clean previous build
rm -f bin/raypong

# Build the project
odin build . -out:bin/raypong -o:speed

if [ $? -eq 0 ]; then
    echo "Build successful! Binary created at bin/raypong"
    # Make the binary executable
    chmod +x bin/raypong
else
    echo "Build failed!"
    exit 1
fi
