#!/usr/bin/env swift
import Cocoa

// Generate a red button icon for RedButtonQuit
// Draws a macOS-style red close button with an X

func createIcon(size: Int) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext
    let s = CGFloat(size)
    let padding = s * 0.08
    let circleRect = CGRect(x: padding, y: padding, width: s - padding * 2, height: s - padding * 2)

    // Shadow
    ctx.setShadow(offset: CGSize(width: 0, height: -s * 0.02), blur: s * 0.06,
                  color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.4))

    // Red gradient circle
    ctx.saveGState()
    let path = CGPath(ellipseIn: circleRect, transform: nil)
    ctx.addPath(path)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(red: 1.0, green: 0.35, blue: 0.34, alpha: 1.0),  // lighter red top
        CGColor(red: 0.92, green: 0.22, blue: 0.21, alpha: 1.0), // main red
        CGColor(red: 0.75, green: 0.12, blue: 0.12, alpha: 1.0), // darker red bottom
    ] as CFArray
    let locations: [CGFloat] = [0.0, 0.5, 1.0]

    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
        ctx.drawLinearGradient(gradient,
                              start: CGPoint(x: s / 2, y: s - padding),
                              end: CGPoint(x: s / 2, y: padding),
                              options: [])
    }
    ctx.restoreGState()

    // Subtle inner highlight (top)
    ctx.saveGState()
    let highlightRect = circleRect.insetBy(dx: s * 0.04, dy: s * 0.04)
    let highlightPath = CGPath(ellipseIn: highlightRect, transform: nil)
    ctx.addPath(highlightPath)
    ctx.clip()
    let highlightColors = [
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3),
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0),
    ] as CFArray
    let highlightLocs: [CGFloat] = [0.0, 1.0]
    if let hGrad = CGGradient(colorsSpace: colorSpace, colors: highlightColors, locations: highlightLocs) {
        ctx.drawLinearGradient(hGrad,
                              start: CGPoint(x: s / 2, y: s - padding),
                              end: CGPoint(x: s / 2, y: s / 2),
                              options: [])
    }
    ctx.restoreGState()

    // Draw X mark
    ctx.setShadow(offset: .zero, blur: 0) // clear shadow for X
    let xCenter = CGPoint(x: s / 2, y: s / 2)
    let xSize = s * 0.18
    let lineWidth = s * 0.06

    ctx.setStrokeColor(CGColor(red: 0.35, green: 0.05, blue: 0.05, alpha: 0.8))
    ctx.setLineWidth(lineWidth)
    ctx.setLineCap(.round)

    // line 1: top-left to bottom-right
    ctx.move(to: CGPoint(x: xCenter.x - xSize, y: xCenter.y + xSize))
    ctx.addLine(to: CGPoint(x: xCenter.x + xSize, y: xCenter.y - xSize))
    ctx.strokePath()

    // line 2: top-right to bottom-left
    ctx.move(to: CGPoint(x: xCenter.x + xSize, y: xCenter.y + xSize))
    ctx.addLine(to: CGPoint(x: xCenter.x - xSize, y: xCenter.y - xSize))
    ctx.strokePath()

    img.unlockFocus()
    return img
}

func savePNG(_ image: NSImage, to path: String, pixelSize: Int) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: pixelSize, height: pixelSize)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize))
    NSGraphicsContext.restoreGraphicsState()

    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: path))
}

// Create iconset directory
let iconsetDir = "AppIcon.iconset"
let fm = FileManager.default
try? fm.removeItem(atPath: iconsetDir)
try! fm.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

// Required icon sizes for macOS .icns
let sizes: [(name: String, pixels: Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

let icon = createIcon(size: 1024)

for entry in sizes {
    let path = "\(iconsetDir)/\(entry.name).png"
    savePNG(icon, to: path, pixelSize: entry.pixels)
}

print("Generated iconset at \(iconsetDir)/")
print("Run: iconutil -c icns \(iconsetDir)")
