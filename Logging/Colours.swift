//
//  Colours.swift
//  DJLogging
//
//  Created by Darren Jones on 01/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

#if os(iOS)
import UIKit
typealias UniversalColor = UIColor
#elseif os(macOS)
import Cocoa
typealias UniversalColor = NSColor
#endif

internal extension UniversalColor {
    class var myBlueColour: UniversalColor {
        return .blue
    }

    class var myBlackColour: UniversalColor {
        return .black
    }
    
    class var myDataColour: UniversalColor {
        return UniversalColor(red: 51.0/255.0, green:204.0/255.0, blue:0.0/255.0, alpha:1.0)
    }
    
    class var myUUIDColour: UniversalColor {
        return UniversalColor(red: 255.0/255.0, green:0.0/255.0, blue:191.0/255.0, alpha:1.0)
    }
    
    class var myWarningColour: UniversalColor {
        return .red;
    }
}
