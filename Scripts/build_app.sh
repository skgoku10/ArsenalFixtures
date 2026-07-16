#!/bin/bash
# Builds ArsenalFixtures.app, a proper double-clickable macOS app bundle,
# from the Swift package. Run from anywhere; paths are relative to this script.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="ArsenalFixtures"
BUILD_CONFIG="release"
APP_BUNDLE="$ROOT_DIR/$APP_NAME.app"
ICON_SOURCE="$ROOT_DIR/AppIcon.png"

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

# Drop a 1024x1024 PNG at AppIcon.png (project root) to have it baked in here.
# macOS derives every smaller size (down to 16x16) from that one master image.
ICON_PLIST_ENTRY=""
if [ -f "$ICON_SOURCE" ]; then
  echo "Building app icon from $ICON_SOURCE..."
  ICONSET_DIR="$ROOT_DIR/.build/AppIcon.iconset"
  rm -rf "$ICONSET_DIR"
  mkdir -p "$ICONSET_DIR"

  sips -z 16 16     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16.png"      >/dev/null
  sips -z 32 32     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16@2x.png"   >/dev/null
  sips -z 32 32     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32.png"      >/dev/null
  sips -z 64 64     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32@2x.png"   >/dev/null
  sips -z 128 128   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128.png"    >/dev/null
  sips -z 256 256   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
  sips -z 256 256   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256.png"    >/dev/null
  sips -z 512 512   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
  sips -z 512 512   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512.png"    >/dev/null
  sips -z 1024 1024 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null

  mkdir -p "$APP_BUNDLE/Contents/Resources"
  iconutil -c icns "$ICONSET_DIR" -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
  rm -rf "$ICONSET_DIR"
  ICON_PLIST_ENTRY="    <key>CFBundleIconFile</key>
    <string>AppIcon.icns</string>"
else
  echo "No AppIcon.png found at $ICON_SOURCE — building with the default icon."
fi

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
$ICON_PLIST_ENTRY
</dict>
</plist>
PLIST

echo "Done: $APP_BUNDLE"
echo "Move it to /Applications and double-click to launch, e.g.:"
echo "  cp -r \"$APP_BUNDLE\" /Applications/"
