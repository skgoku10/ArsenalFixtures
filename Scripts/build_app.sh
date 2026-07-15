#!/bin/bash
# Builds ArsenalFixtures.app, a proper double-clickable macOS app bundle,
# from the Swift package. Run from anywhere; paths are relative to this script.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="ArsenalFixtures"
BUILD_CONFIG="release"
APP_BUNDLE="$ROOT_DIR/$APP_NAME.app"

echo "Building $APP_NAME ($BUILD_CONFIG)..."
cd "$ROOT_DIR"
swift build -c "$BUILD_CONFIG"

BIN_PATH="$ROOT_DIR/.build/$BUILD_CONFIG/$APP_NAME"
if [ ! -f "$BIN_PATH" ]; then
  echo "Build output not found at $BIN_PATH" >&2
  exit 1
fi

echo "Packaging $APP_BUNDLE..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
cp "$BIN_PATH" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Arsenal Fixtures</string>
    <key>CFBundleDisplayName</key>
    <string>Arsenal Fixtures</string>
    <key>CFBundleIdentifier</key>
    <string>com.arsenalfixtures.app</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>For personal use.</string>
</dict>
</plist>
PLIST

echo "Done: $APP_BUNDLE"
echo "Move it to /Applications and double-click to launch, e.g.:"
echo "  cp -r \"$APP_BUNDLE\" /Applications/"
