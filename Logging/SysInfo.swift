//
//  SysInfo.swift
//  DJLogging
//
//  Created by Darren Jones on 01/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)

#endif

internal class SysInfo {
    
    internal static func sysInfo() -> String {
        #if os(iOS)
        return "\(UIDevice.current.systemName)/\(UIDevice.current.systemVersion) (\(machineModel()))"
        #elseif os(macOS)
        let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        return "MacOS/\(operatingSystemVersion) (\(machineModel()))"
        #endif
    }
    
    private static func machineModel() -> String {
        #if os(iOS)
        return UIDevice.current.modelName
        #elseif os(macOS)
        return modelIdentifier() ?? "Unknown"
        #endif
    }
    
    #if os(macOS)
    static private func modelIdentifier() -> String? {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        defer { IOObjectRelease(service) }
        
        var modelIdentifier: String?

        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            if let modelIdentifierCString = String(data: modelData, encoding: .utf8)?.cString(using: .utf8) {
                modelIdentifier = String(cString: modelIdentifierCString)
            }
        }

        IOObjectRelease(service)
        return modelIdentifier
    }
    #endif
}

#if os(iOS)
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
#endif
