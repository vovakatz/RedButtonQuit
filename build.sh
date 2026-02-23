#!/bin/bash
set -e

echo "Building RedButtonQuit..."
cd "$(dirname "$0")"

# Build for Apple Silicon (arm64)
swift build -c release --arch arm64

# === Create .app bundle ===
APP_NAME="RedButtonQuit"
APP_BUNDLE="$HOME/Applications/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

echo "Creating app bundle at $APP_BUNDLE..."

# Clean previous bundle
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Copy binary
cp ".build/release/$APP_NAME" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

# Generate icon
echo "Generating app icon..."
swift generate-icon.swift
iconutil -c icns AppIcon.iconset -o "$RESOURCES_DIR/AppIcon.icns"
rm -rf AppIcon.iconset

# Create Info.plist
cat > "$CONTENTS/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>RedButtonQuit</string>
    <key>CFBundleDisplayName</key>
    <string>RedButtonQuit</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.redbuttonquit</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>RedButtonQuit</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo ""
echo "Built successfully!"
echo "   App bundle: $APP_BUNDLE"
echo ""
echo "Next steps:"
echo "   1. Run it:  open $APP_BUNDLE"
echo "   2. Grant Accessibility permissions when prompted"
echo "      (System Settings -> Privacy & Security -> Accessibility)"
echo "      NOTE: You may need to remove the old RedButtonQuit entry"
echo "      and add the new .app bundle."
echo "   3. Right-click any window's red close button to quit that app!"
echo ""
echo "To auto-start on login, run:"
echo "   ./install-launchagent.sh"
