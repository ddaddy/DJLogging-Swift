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

#elseif os(watchOS)
import WatchKit
#endif

internal class SysInfo {
    
    internal static func sysInfo() -> String {
        #if os(iOS)
        return "\(UIDevice.current.systemName)/\(UIDevice.current.systemVersion) (\(machineModel()))"
        #elseif os(macOS)
        let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        return "MacOS/\(operatingSystemVersion) (\(machineModel()))"
        #elseif os(watchOS)
        return "\(WKInterfaceDevice.current().systemName)/\(WKInterfaceDevice.current().systemVersion) (\(machineModel()))"
        #endif
    }
    
    private static func machineModel() -> String {
        #if os(iOS)
        return UIDevice.current.modelName
        #elseif os(macOS)
        return modelIdentifier() ?? "Unknown"
        #elseif os(watchOS)
        return WKInterfaceDevice.current().model
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
    
    internal static func memoryUse() -> String {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        guard let offset = MemoryLayout.offset(of: \task_vm_info_data_t.min_address) else {return "N/A"}
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(offset / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
        else { return "N/A" }
        
        let usedBytes = Float(info.phys_footprint)
        let usedBytesInt: UInt64 = UInt64(usedBytes)
        let usedMB = usedBytesInt / 1024 / 1024
        let usedMBAsString: String = "\(usedMB) MB"
        return usedMBAsString
    }
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
