#!/bin/bash
set -e

APP_BUNDLE="$HOME/Applications/RedButtonQuit.app"
BINARY="$APP_BUNDLE/Contents/MacOS/RedButtonQuit"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.user.redbuttonquit.plist"
PLIST_PATH="$PLIST_DIR/$PLIST_NAME"

if [ ! -f "$BINARY" ]; then
    echo "App bundle not found. Run ./build.sh first."
    exit 1
fi

mkdir -p "$PLIST_DIR"

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.redbuttonquit</string>
    <key>ProgramArguments</key>
    <array>
        <string>${BINARY}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${HOME}/Library/Logs/RedButtonQuit.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/Library/Logs/RedButtonQuit.log</string>
</dict>
</plist>
EOF

# Load the agent
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo "LaunchAgent installed and started!"
echo "   RedButtonQuit will now start automatically on login."
echo ""
echo "   To stop:    launchctl unload $PLIST_PATH"
echo "   To remove:  rm $PLIST_PATH"
echo "   Logs:       $HOME/Library/Logs/RedButtonQuit.log"
