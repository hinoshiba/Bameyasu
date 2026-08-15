#!/usr/bin/env swift
import AppKit
import ImageIO
import UniformTypeIdentifiers

let size = CGSize(width: 1024, height: 1024)
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(
    data: nil,
    width: 1024,
    height: 1024,
    bitsPerComponent: 8,
    bytesPerRow: 4096,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
    fatalError("Unable to create drawing context")
}

let canvas = CGRect(origin: .zero, size: size)
let colors = [
    NSColor(red: 0.94, green: 0.34, blue: 0.14, alpha: 1).cgColor,
    NSColor(red: 1.00, green: 0.72, blue: 0.19, alpha: 1).cgColor
] as CFArray
let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
context.setFillColor(NSColor(red: 0.97, green: 0.48, blue: 0.14, alpha: 1).cgColor)
context.fill(canvas)
context.drawLinearGradient(
    gradient,
    start: CGPoint(x: 110, y: 120),
    end: CGPoint(x: 900, y: 930),
    options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
)

context.setFillColor(NSColor(red: 0.075, green: 0.063, blue: 0.055, alpha: 0.96).cgColor)
context.fillEllipse(in: CGRect(x: 196, y: 196, width: 632, height: 632))

context.setStrokeColor(NSColor.white.withAlphaComponent(0.16).cgColor)
context.setLineWidth(5)
context.strokeEllipse(in: CGRect(x: 221, y: 221, width: 582, height: 582))

let dotCenters = [
    CGPoint(x: 512, y: 277), CGPoint(x: 747, y: 512),
    CGPoint(x: 512, y: 747), CGPoint(x: 277, y: 512)
]
for point in dotCenters {
    context.setFillColor(NSColor(red: 1, green: 0.72, blue: 0.19, alpha: 1).cgColor)
    context.fillEllipse(in: CGRect(x: point.x - 24, y: point.y - 24, width: 48, height: 48))
}

context.setStrokeColor(NSColor.white.cgColor)
context.setLineWidth(72)
context.setLineCap(.round)
context.setLineJoin(.round)
context.beginPath()
context.move(to: CGPoint(x: 342, y: 515))
context.addLine(to: CGPoint(x: 462, y: 394))
context.addLine(to: CGPoint(x: 696, y: 636))
context.strokePath()

guard let icon = context.makeImage() else {
    fatalError("Unable to encode icon")
}

let output = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Bameyasu/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
guard let destination = CGImageDestinationCreateWithURL(
    output as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
) else {
    fatalError("Unable to create PNG destination")
}
CGImageDestinationAddImage(destination, icon, nil)
guard CGImageDestinationFinalize(destination) else {
    fatalError("Unable to write icon")
}
print(output.path)
