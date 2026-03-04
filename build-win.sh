#!/usr/bin/env bash

set -e

OUT_DIR="release"

echo "Cleaning previous build..."
make distclean > /dev/null 2>&1 || true
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

echo "Running autoreconf..."
autoreconf -i

echo "Configuring..."
CFLAGS="-O2 -Wall -std=gnu99 -fgnu89-inline -fcommon" \
./configure

echo "Building..."
make -j$(nproc)

if [ ! -f sgminer.exe ]; then
    echo "Error: sgminer.exe not found"
    exit 1
fi

echo "Stripping executable..."
strip -s sgminer.exe

echo "Copying executable..."
cp sgminer.exe "$OUT_DIR/"

echo "Copying required MinGW DLLs..."
DLLS=$(ldd sgminer.exe | grep "/mingw64/bin" | awk '{print $3}' | sort -u)

if [ -n "$DLLS" ]; then
    echo "$DLLS" | xargs -I{} cp -v "{}" "$OUT_DIR/"
fi

echo "Copying kernel folder..."
if [ -d kernel ]; then
    cp -rv kernel "$OUT_DIR/"
else
    echo "Warning: kernel folder not found!"
fi

echo "Done. Fresh release folder ready."