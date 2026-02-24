# RedButtonQuit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-13%2B-blue)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)

A lightweight macOS menu bar utility for Apple Silicon that lets you **right-click the red close button** of any window to **quit the entire application** — instead of just closing that window.

## Why?

On macOS, clicking the red close button closes the window but often leaves the app running in the background. RedButtonQuit gives you a natural way to fully quit an app: just **right-click** the red button instead.

- **Left-click** the red button → closes the window (normal behavior)
- **Right-click** the red button → **quits the entire application**

## How It Works

RedButtonQuit installs a global event tap that monitors right-click events. When you right-click on a window's red close button (identified via the macOS Accessibility API as `AXCloseButton`), it sends a quit signal to the owning application. It runs silently in the menu bar with a small red circle icon.

## Requirements

- macOS 13 (Ventura) or later
- Apple Silicon Mac (arm64)
- Xcode Command Line Tools

## Installation

### 1. Install Xcode Command Line Tools (if needed)

```bash
xcode-select --install
```

### 2. Clone and build

```bash
git clone https://github.com/vovakatz/RedButtonQuit.git
cd RedButtonQuit
./build.sh
```

This compiles the app and creates `RedButtonQuit.app` in `~/Applications/`.

### 3. Run

```bash
open ~/Applications/RedButtonQuit.app
```

On first launch, macOS will prompt you to grant **Accessibility permissions**:

> **System Settings → Privacy & Security → Accessibility** → Enable **RedButtonQuit**

### 4. Auto-start on login (optional)

```bash
./install-launchagent.sh
```

This installs a LaunchAgent so RedButtonQuit starts automatically when you log in. Logs are written to `~/Library/Logs/RedButtonQuit.log`.

## Uninstall

```bash
# Stop and remove the LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.user.redbuttonquit.plist
rm ~/Library/LaunchAgents/com.user.redbuttonquit.plist

# Remove the app
rm -rf ~/Applications/RedButtonQuit.app
```

## Notes

- The app runs as a menu bar utility (no Dock icon). Click the red circle icon in the menu bar to quit.
- If Accessibility permissions aren't granted, the app will prompt you and exit.
- The app attempts a graceful quit first, falling back to force-quit if needed.

## License

This project is licensed under the [MIT License](LICENSE).
