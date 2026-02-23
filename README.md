# 🔴 RedButtonQuit

A lightweight macOS utility for Apple Silicon that lets you **right-click the red close button** of any window to **quit the entire application** (instead of just closing that window).

## How It Works

The app installs a global event tap that monitors right-click events. When you right-click on a window's red close button (identified via the macOS Accessibility API as `AXCloseButton`), it sends a quit signal to the owning application.

- **Left-click** the red button → closes the window (normal behavior)
- **Right-click** the red button → **quits the entire application**

## Requirements

- macOS 13 (Ventura) or later
- Apple Silicon Mac (arm64)
- Swift 5.9+ (included with Xcode or Xcode Command Line Tools)

## Installation

### 1. Install Xcode Command Line Tools (if not already installed)

```bash
xcode-select --install
```

### 2. Build

```bash
chmod +x build.sh
./build.sh
```

This compiles the app and places the binary at `~/.local/bin/RedButtonQuit`.

### 3. Run

```bash
~/.local/bin/RedButtonQuit
```

On first launch, macOS will prompt you to grant **Accessibility permissions**:

> **System Settings → Privacy & Security → Accessibility**

Add and enable `RedButtonQuit` (or Terminal, if running from Terminal).

### 4. (Optional) Auto-Start on Login

```bash
chmod +x install-launchagent.sh
./install-launchagent.sh
```

This installs a LaunchAgent so RedButtonQuit starts automatically when you log in.

## Uninstall

```bash
# Stop and remove the LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.user.redbuttonquit.plist
rm ~/Library/LaunchAgents/com.user.redbuttonquit.plist

# Remove the binary
rm ~/.local/bin/RedButtonQuit
```

## Notes

- The app runs silently in the background and logs activity to the terminal (or `~/Library/Logs/RedButtonQuit.log` if using the LaunchAgent).
- If running from Terminal, you need to grant Accessibility permissions to **Terminal.app** (or your terminal emulator like iTerm2).
- If running as a standalone binary, grant permissions to the binary itself.
- `Ctrl+C` stops the app when running in a terminal.
