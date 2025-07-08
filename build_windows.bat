@echo off
REM Build script for Windows
REM Creates binary output in bin directory

echo Building raypong for Windows...

REM Create bin directory if it doesn't exist
if not exist "bin" mkdir bin

REM Clean previous build
if exist "bin\raypong.exe" del "bin\raypong.exe"

REM Build the project
odin build . -out:bin/raypong.exe -o:speed

if %ERRORLEVEL% EQU 0 (
    echo Build successful! Binary created at bin\raypong.exe
) else (
    echo Build failed!
    exit /b 1
)
