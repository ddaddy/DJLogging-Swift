//
//  AppDelegate.swift
//  Example-iOS
//
//  Created by Darren Jones on 01/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

import UIKit
import DJLogging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        LogManager.setDebugLogsToScreen(true)
        LogMethodCall(type: .ui)
        
        return true
    }
}

final class DJLogTypeComms: DJLogType {
    static let shared: DJLogType = DJLogTypeComms()
    let name: String = "comms"
    let colour: DJColor = DJColours.orange
}

extension DJLogType where Self == DJLogTypeComms {
    static var comms: DJLogType { DJLogTypeComms.shared }
}

final class DJLogTypeUI: DJLogType {
    static let shared: DJLogType = DJLogTypeUI()
    let name: String = "ui"
    let colour: DJColor = DJColours.blue
}

extension DJLogType where Self == DJLogTypeUI {
    static var ui: DJLogType { DJLogTypeUI.shared }
}
