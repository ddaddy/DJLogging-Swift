//
//  AppDelegate.swift
//  Example-iOS
//
//  Created by Darren Jones on 01/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

import UIKit
import DJLogging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        LogManager.debugLogsToScreen = true
        LogMethodCall(type: .ui)
        
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
