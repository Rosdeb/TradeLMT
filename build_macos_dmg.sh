#!/bin/bash

# Exit on error
set -e

echo "Building release version of macOS app..."
flutter build macos --release

APP_NAME="raminups"
RELEASE_DIR="build/macos/Build/Products/Release"
APP_PATH="${RELEASE_DIR}/${APP_NAME}.app"
DMG_PATH="${RELEASE_DIR}/${APP_NAME}.dmg"
TEMP_DIR="build/macos/dmg_temp"

# If the exact app path is not found, search for any .app in the build directory
if [ ! -d "$APP_PATH" ]; then
    DETECTED_APP=$(find "$RELEASE_DIR" -maxdepth 1 -name "*.app" | head -n 1)
    if [ -n "$DETECTED_APP" ]; then
        APP_PATH="$DETECTED_APP"
        APP_NAME=$(basename "$APP_PATH" .app)
        DMG_PATH="${RELEASE_DIR}/${APP_NAME}.dmg"
        echo "Found app at: $APP_PATH"
    else
        echo "Error: Release app bundle (.app) not found."
        exit 1
    fi
fi

echo "Packaging ${APP_NAME}.app into ${APP_NAME}.dmg..."

# Clean up any existing temp dir or dmg
rm -rf "$TEMP_DIR"
rm -f "$DMG_PATH"

# Create temporary directory for DMG contents
mkdir -p "$TEMP_DIR"

# Copy the app to the temp directory
cp -R "$APP_PATH" "$TEMP_DIR/"

# Create a symlink to /Applications inside the temp directory
ln -s /Applications "$TEMP_DIR/Applications"

# Create the DMG
hdiutil create -volname "${APP_NAME}" -srcfolder "$TEMP_DIR" -ov -format UDZO "$DMG_PATH"

# Clean up temp directory
rm -rf "$TEMP_DIR"

echo "--------------------------------------------------------"
echo "Success! DMG created at:"
echo "$DMG_PATH"
echo "--------------------------------------------------------"
