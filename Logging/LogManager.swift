//
//  LogManager.swift
//  DJLogging-iOS
//
//  Created by Darren Jones on 01/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)

#endif

public func LogMethodCall(function: String = #function, file: String = #file, line: Int = #line, type: DJLogType = .standard) {
    LogMethodCall(nil, function: function, file: file, line: line, type: type)
}

public func LogMethodCall(function: String = #function, file: String = #file, line: Int = #line, _ param: String? = nil, type: DJLogType = .standard) {
    if let param = param {
        LogMethodCall(nil, function: function, file: file, line: line, logs: [param], type: type)
    } else {
        LogMethodCall(nil, function: function, file: file, line: line, type: type)
    }
}

public func LogMethodCall(function: String = #function, file: String = #file, line: Int = #line, _ param: Double? = nil, type: DJLogType = .standard) {
    if let param = param {
        LogMethodCall(nil, function: function, file: file, line: line, logs: [String(param)], type: type)
    } else {
        LogMethodCall(nil, function: function, file: file, line: line, type: type)
    }
}

public func LogMethodCall(function: String = #function, file: String = #file, line: Int = #line, _ param: Int? = nil, type: DJLogType = .standard) {
    if let param = param {
        LogMethodCall(nil, function: function, file: file, line: line, logs: [String(param)], type: type)
    } else {
        LogMethodCall(nil, function: function, file: file, line: line, type: type)
    }
}

public func LogMethodCall(_ uuid: UUID?, function: String = #function, file: String = #file, line: Int = #line, type: DJLogType = .standard) {
    let lastPathComponent = URL.init(fileURLWithPath: file).lastPathComponent
    LogManager.log("\(function) file:\(lastPathComponent) line:\(line)", log: nil, uuid: uuid, type: type)
}

public func LogMethodCall(_ uuid: UUID?, function: String = #function, file: String = #file, line: Int = #line, logs: [String], type: DJLogType = .standard) {
    let lastPathComponent = URL.init(fileURLWithPath: file).lastPathComponent
    LogManager.log("\(function) file:\(lastPathComponent) line:\(line)", logs: logs, uuid: uuid, type: type)
}

public func LogRequestResponse(uuid: UUID?, response: URLResponse?, data: Data?, error: Error?, type: DJLogType = .standard) {
    LogManager.logRequestResponse(response, data: data, error: error as NSError?, uuid: uuid, type: type)
}

@objc(LogManager)
public class LogManager: NSObject {
    
    // MARK: - Public Properties
    
    /**
     Override to print logs to debug console as they are recorded
     */
    @objc public static var debugLogsToScreen = false
    
    /**
     Override to change the maximum log length.
     Default value is `1000`
     */
    @objc public static var maxLogLength = 1000
    
    // MARK: - Public methods
    public static func logString(_ title: String, uuid: UUID? = nil, type: DJLogType = .standard) {
        log(title, log: nil, uuid: uuid, type: type)
    }
    
    @objc(logTitle:log:uuid:type:)
    public static func log(_ title: String, log: String?, uuid: UUID?, type: DJLogType = .standard) {
        
        sharedInstance.log(title, log: log, uuid: uuid, type: type)
    }
    
    public static func log(_ title: String, logs: [String], uuid: UUID?, type: DJLogType = .standard) {
        
        sharedInstance.log(title, logs: logs, uuid: uuid, type: type)
    }
    
    @objc
    public static func logRequestResponse(_ response: URLResponse?, data: Data?, error: NSError?, uuid: UUID?, type: DJLogType = .standard) {
        
        sharedInstance.logRequestResponse(response, data: data, error: error, uuid: uuid, type: type)
    }
    
    /**
     Generates a complete HTML string of the logs
     
     Automatically appends app/system information to the end of the log
     
     - Returns: `String` of the entire log in html format
     */
    @objc public static func htmlString() -> String {
        
        // Add the app info to logs
        var currentLogs = sharedInstance._logs
        currentLogs.append(DJLogLine(uuid: nil, title: "LogManager End", logs: sharedInstance.appInfo))
        
        return DJHTML.html(from: currentLogs)
    }
    
    /**
     Generates a complete HTML string of the logs and converts it to `Data` ready to be emailed
     
     Automatically appends app/system information to the end of the log
     
     - Returns: `Data` of the entire log in html format
     */
    @objc public static func htmlData() -> Data? {
        
        let log = LogManager.htmlString();
        return log.data(using: .utf8, allowLossyConversion: true)
    }
    
    @objc public static func printLogs() {
        
        let logs = sharedInstance._logs
        logs.forEach { log in
            print(log.title)
            if let logs = log.logs {
                print(logs.joined(separator: "\n"))
            }
        }
    }
    
    @objc public static func clearLog() {
        
        sharedInstance.serialQueue.async {
            sharedInstance._logs = []
        }
    }
    
    // MARK: - Private Properties
    private static let sharedInstance = LogManager()
    private var _logs: [DJLogLine] = []
    private let serialQueue = DispatchQueue(label: "DJLoggingSerialQueue")
    
    // MARK: - Init
    private override init() {
        super.init()

        // Add the app info to logs
        log("LogManager Start", logs: appInfo, uuid: nil)
    }
    
    // MARK: - Internal
    private var appInfo: [String] {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        return ["Appname: \(appName) Version: \(appVersion) Build: \(appBuild)",
                "SysInfo: \(SysInfo.sysInfo())",
                "Time/Date: \(Date().localFormat())",
                "Timezone: \(TimeZone.current.description)",
                "Memory Use: \(SysInfo.memoryUse())"]
    }
    
    private func log(_ title: String, code: Int? = nil, log: String?, uuid: UUID?, type: DJLogType = .standard) {
        serialQueue.async {
            let logLine = DJLogLine(uuid: uuid, code: code, title: title, log: log, type: type)
            self._logs.append(logLine)
            
            self.checkLogLength()
            
            if Self.debugLogsToScreen == true {
                print("****LogManager**** \(uuid?.uuidString ?? "") \t\(title) \t\(log ?? "")")
            }
        }
    }
    
    private func log(_ title: String, code: Int? = nil, logs: [String], uuid: UUID?, type: DJLogType = .standard) {
        serialQueue.async {
            let logLine = DJLogLine(uuid: uuid, code: code, title: title, logs: logs, type: type)
            self._logs.append(logLine)
            
            self.checkLogLength()
            
            if Self.debugLogsToScreen == true {
                print("****LogManager**** \(uuid?.uuidString ?? "") \t\(title) \n\(logs)")
            }
        }
    }
    
    private func logRequestResponse(_ response: URLResponse?, data: Data?, error: NSError?, uuid: UUID?, type: DJLogType = .standard) {
        
        var underlyingError: NSError? = nil
        if let error = error {
            if (error.userInfo[NSUnderlyingErrorKey] != nil) {
                underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError
            }
        }
        
        let logs = [
            "Response: \(response?.description ?? "")",
            "Error: \(error?.description ?? "")",
            "UnderlyingError: \(underlyingError?.description ?? "")",
            "Data: \(String(describing: data))",
            "Decoded: \(data?.string ?? "")"
        ]
        
        var title = response?.url?.absoluteString
        if let error = error as? URLError {
            
            var reason = ""
            switch error.code {
            case .timedOut:
                reason = "timeout"
            case .cancelled:
                reason = "cancelled"
            case .badURL:
                reason = "badURL"
            case .networkConnectionLost:
                reason = "networkConnectionLost"
            case .notConnectedToInternet:
                reason = "notConnectedToInternet"
            case .cannotParseResponse:
                reason = "cannotParseResponse"
            case .secureConnectionFailed:
                reason = "secureConnectionFailed"
            default:
                reason = "\(error.code.rawValue)"
            }
            
            title = "⛔️ Error❗️ \(reason) \(error.failureURLString ?? "")"
        }
        
        var code = response?.getStatusCode()
        if code == nil,
           let error = error {
            code = error.code
        } else {
            if code == 200 {
                title = "✅ \(title ?? "")"
            } else {
                title = "⚠️ \(title ?? "")"
            }
        }
        
        log(title ?? "", code: code, logs: logs, uuid: uuid, type: type)
    }
    
    private func checkLogLength() {
        
        if _logs.count > Self.maxLogLength {
            if Self.debugLogsToScreen == true {
                print("Log too big: \(_logs.count) so trimming.")
            }
            _logs.remove(at: 0)
        }
    }
    
}

// MARK: - Helpers
fileprivate extension URLResponse {

    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}

fileprivate extension Date {
    
    func localFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter.string(from: self)
    }
}

fileprivate extension Data {
    
    var string: String {
        
        if let converted = String(data: self, encoding: .utf8) {
            return converted
        } else if let converted = String(data: self, encoding: .isoLatin1) {
            // Couldn't convert data using UTF8 (Strange!) So try another method
            return "NSISOLatin1StringEncoding \t\(converted)"
        } else if let converted = String(data: self, encoding: .ascii) {
            // Couldn't convert data using NSISOLatin (Strange!) So try another method
            return "NSASCIIStringEncoding \t\(converted)"
        } else {
            return "CANNOT CONVERT DATA TO STRING! \t\(self)"
        }
    }
}
