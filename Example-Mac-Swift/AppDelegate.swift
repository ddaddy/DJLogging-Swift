//
//  AppDelegate.swift
//  Example-Mac-Swift
//
//  Created by Darren Jones on 02/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

import Cocoa
import DJLogging

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        LogManager.setDebugLogsToScreen(true)
        LogMethodCall(type: .ui)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

final class DJLogTypeComms: DJLogType {
    static let shared: DJLogType = DJLogTypeComms()
    let id: UUID = UUID()
    let name: String = "comms"
    let colour: DJColor = DJColours.orange
}

extension DJLogType where Self == DJLogTypeComms {
    static var comms: DJLogType { DJLogTypeComms.shared }
}

final class DJLogTypeUI: DJLogType {
    static let shared: DJLogType = DJLogTypeUI()
    let id: UUID = UUID()
    let name: String = "ui"
    let colour: DJColor = DJColours.blue
}

extension DJLogType where Self == DJLogTypeUI {
    static var ui: DJLogType { DJLogTypeUI.shared }
}
