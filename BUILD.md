# Build Instructions

This project includes build scripts for both Windows and Linux platforms.

## Prerequisites

- [Odin compiler](https://odin-lang.org/) installed and available in PATH
- [Raylib](https://www.raylib.com/) (should be available through Odin's vendor packages)

## Building

### Windows

Run the Windows build script:
```cmd
build_windows.bat
```

### Linux

Make the script executable (if not already) and run:
```bash
chmod +x build_linux.sh
./build_linux.sh
```

## Output

Both scripts will create a `bin` directory and place the compiled binary there:
- Windows: `bin/raypong.exe`
- Linux: `bin/raypong`

## Build Options

The build scripts use `-o:speed` for optimized release builds. You can modify the scripts to change build options as needed.

## Running

After building, you can run the game directly from the bin directory:

**Windows:**
```cmd
bin\raypong.exe
```

**Linux:**
```bash
./bin/raypong
```
