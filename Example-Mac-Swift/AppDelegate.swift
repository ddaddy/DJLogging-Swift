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
        
        LogManager.debugLogsToScreen = true
        LogMethodCall(type: .ui)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

class DJLogTypeComms: DJLogType {
    static var shared: DJLogType = DJLogTypeComms()
    var id: UUID = UUID()
    var name: String = "comms"
    var colour: DJColor = DJColours.orange
}

extension DJLogType where Self == DJLogTypeComms {
    static var comms: DJLogType { DJLogTypeComms.shared }
}

class DJLogTypeUI: DJLogType {
    static var shared: DJLogType = DJLogTypeUI()
    var id: UUID = UUID()
    var name: String = "ui"
    var colour: DJColor = DJColours.blue
}

extension DJLogType where Self == DJLogTypeUI {
    static var ui: DJLogType { DJLogTypeUI.shared }
}
