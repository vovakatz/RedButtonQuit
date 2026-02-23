import Cocoa
import ApplicationServices

// MARK: - Global State (needed for C callback)
var globalEventTap: CFMachPort?

// MARK: - Event Tap Callback (must be a free C-compatible function)
func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {

    // Re-enable the tap if system disabled it
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = globalEventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passRetained(event)
    }

    guard type == .rightMouseDown else {
        return Unmanaged.passRetained(event)
    }

    let mouseLocation = event.location

    if handleRightClickOnCloseButton(at: mouseLocation) {
        return nil  // Consume the event
    }

    return Unmanaged.passRetained(event)
}

// MARK: - Accessibility Logic

func handleRightClickOnCloseButton(at point: CGPoint) -> Bool {
    var elementRef: AXUIElement?
    let systemWide = AXUIElementCreateSystemWide()

    let result = AXUIElementCopyElementAtPosition(systemWide, Float(point.x), Float(point.y), &elementRef)

    guard result == .success, let element = elementRef else {
        return false
    }

    var roleRef: CFTypeRef?
    var subroleRef: CFTypeRef?

    AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef)
    AXUIElementCopyAttributeValue(element, kAXSubroleAttribute as CFString, &subroleRef)

    let role = roleRef as? String ?? ""
    let subrole = subroleRef as? String ?? ""

    // The red close button: role = "AXButton", subrole = "AXCloseButton"
    guard role == "AXButton" && subrole == "AXCloseButton" else {
        return false
    }

    // Get the PID of the owning application
    var pid: pid_t = 0
    guard AXUIElementGetPid(element, &pid) == .success else {
        print("⚠️  Found close button but couldn't determine owning app.")
        return false
    }

    guard let app = NSRunningApplication(processIdentifier: pid) else {
        print("⚠️  No running application found for PID \(pid)")
        return false
    }

    let appName = app.localizedName ?? "PID \(pid)"
    print("🔴 Right-clicked close button → Quitting: \(appName)")

    if app.terminate() {
        print("   ✅ Quit signal sent to \(appName)")
    } else {
        print("   ⚠️  Trying force quit...")
        if app.forceTerminate() {
            print("   ✅ Force-quit \(appName)")
        } else {
            print("   ❌ Could not quit \(appName)")
        }
    }

    return true
}

// MARK: - Check Accessibility

func checkAccessibility() -> Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("""
        ╔══════════════════════════════════════════════╗
        ║          🔴 RedButtonQuit v1.0              ║
        ║  Right-click the red button to quit an app  ║
        ╚══════════════════════════════════════════════╝
        """)

        guard checkAccessibility() else {
            print("❌ Accessibility permissions required!")
            print("   → System Settings → Privacy & Security → Accessibility")
            print("   → Add this app and enable it, then relaunch.")
            NSApp.terminate(nil)
            return
        }

        setupEventTap()
        setupStatusItem()

        print("✅ Monitoring active. Right-click any red close button to quit that app.")
        print("   Use the menu bar icon to quit.\n")
    }

    private func setupEventTap() {
        let eventMask: CGEventMask = (1 << CGEventType.rightMouseDown.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: eventTapCallback,
            userInfo: nil
        ) else {
            print("❌ Failed to create event tap. Check accessibility permissions.")
            NSApp.terminate(nil)
            return
        }

        globalEventTap = tap

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = makeRedCircleIcon()
        }

        let menu = NSMenu()
        let titleItem = NSMenuItem(title: "RedButtonQuit", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func makeRedCircleIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            let circleDiameter: CGFloat = 10
            let circleRect = NSRect(
                x: (rect.width - circleDiameter) / 2,
                y: (rect.height - circleDiameter) / 2,
                width: circleDiameter,
                height: circleDiameter
            )
            let path = NSBezierPath(ovalIn: circleRect)
            NSColor.red.setFill()
            path.fill()
            return true
        }
        image.isTemplate = false  // Keep the red color, don't adapt to menu bar style
        return image
    }
}

// MARK: - Main

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
