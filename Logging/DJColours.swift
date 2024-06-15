//
//  DJColours.swift
//  DJLogging
//
//  Created by Darren Jones on 13/06/2022.
//  Copyright © 2022 Darren Jones. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
public typealias DJColor = UIColor
#elseif os(macOS)
import Cocoa
public typealias DJColor = NSColor
#elseif os(watchOS)
import WatchKit
public typealias DJColor = UIColor
#endif

public class DJColours: NSObject {
    public static let white: DJColor    = .white
    public static let red: DJColor      = DJColor(red: 250.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    public static let orange: DJColor   = DJColor(red: 250.0/255.0, green: 242.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    public static let yellow: DJColor   = DJColor(red: 250.0/255.0, green: 250.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    public static let green: DJColor    = DJColor(red: 235.0/255.0, green: 250.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    public static let blue: DJColor     = DJColor(red: 230.0/255.0, green: 238.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    public static let purple: DJColor   = DJColor(red: 233.0/255.0, green: 230.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    public static let pink: DJColor     = DJColor(red: 250.0/255.0, green: 230.0/255.0, blue: 249.0/255.0, alpha: 1.0)
}

#if os(iOS) || os(watchOS)
extension UIColor {
    var hexString: String {
        let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)!
        let colorRef = cgColorInRGB.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )

        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a * 255)))
        }

        return color
    }
}
#elseif os(macOS)
extension NSColor {
    var hexString: String {
        let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)!
        let colorRef = cgColorInRGB.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )

        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a * 255)))
        }

        return color
    }
}
#endif
