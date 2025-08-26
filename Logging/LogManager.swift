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
import AppKit
#endif
import CryptoKit

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
    LogManager.logRequestResponse(response, data: data, error: error, uuid: uuid, type: type)
}

public final class LogManager: @unchecked Sendable {
    
    // MARK: - Public Properties
    
    /**
     Override to print logs to debug console as they are recorded
     */
    private var debugLogsToScreen = false
    
    public static func setDebugLogsToScreen(_ debug: Bool) {
        shared.debugLogsToScreen = debug
    }
    
    /**
     Override to change the maximum log length.
     Default value is `1000`
     */
    private var maxLogLength = 1000
    
    public static func setMaxLogLength(_ length: Int) {
        shared.maxLogLength = length
    }
    
    // MARK: - Public methods
    public static func logString(_ title: String, uuid: UUID? = nil, type: DJLogType = .standard) {
        log(title, log: nil, uuid: uuid, type: type)
    }
    
    public static func log(_ title: String, log: String?, uuid: UUID?, type: DJLogType = .standard) {
        
        shared.log(title, log: log, uuid: uuid, type: type)
    }
    
    public static func log(_ title: String, logs: [String], uuid: UUID?, type: DJLogType = .standard) {
        
        shared.log(title, logs: logs, uuid: uuid, type: type)
    }
    
    public static func logRequestResponse(_ response: URLResponse?, data: Data?, error: Error?, uuid: UUID?, type: DJLogType = .standard) {
        
        shared.logRequestResponse(response, data: data, error: error, uuid: uuid, type: type)
    }
    
    /**
     Generates a complete HTML string of the logs
     
     Automatically appends app/system information to the end of the log
     
     - Returns: `String` of the entire log in html format
     */
    @MainActor
    public static func htmlString() -> String {
        
        // Get the current logs
        var currentLogs = shared._logs
        // Add the app info to logs
        let appInfo = shared.appInfo
        currentLogs.append(DJLogLine(uuid: nil, title: "LogManager End", logs: appInfo))
        
        return DJHTML.html(from: currentLogs)
    }
    
    /**
     Generates a complete HTML string of the logs and converts it to `Data` ready to be emailed
     
     Automatically appends app/system information to the end of the log
     
     - Returns: `Data` of the entire log in html format
     */
    @MainActor
    public static func htmlData() -> Data? {
        
        let log = LogManager.htmlString();
        return log.data(using: .utf8, allowLossyConversion: true)
    }
    
    /**
     Generates an encrypted file of the `htmlData` log that can be opened by the `LogViewer`
     */
    @available(iOS 13.0, macOS 10.15, *)
    @MainActor
    public static func encryptedData() -> Data? {
        
        let logData = LogManager.htmlData() ?? Data()
        let key = SymmetricKey(data: SHA256.hash(data: "DJLogViewer".data(using: .utf8)!))
        let sealedBox = try! ChaChaPoly.seal(logData, using: key).combined
        return sealedBox
    }
    
    public static func printLogs() {
        
        let logs = shared._logs
        logs.forEach { log in
            print(log.title)
            if let logs = log.logs {
                print(logs.joined(separator: "\n"))
            }
        }
    }
    
    @MainActor
    public static func clearLog() {
        
        shared.serialQueue.async {
            shared._logs = []
            let appInfo = DispatchQueue.main.sync {
                shared.appInfo // Incorrect warning in Swift 5, compiles fine in Swift 6
            }
            shared.appendToLog(DJLogLine(uuid: nil, title: "LogManager Start (after clearLog)", logs: appInfo))
        }
    }
    
    // MARK: - Private Properties
    public static let shared = LogManager()
    private var _logs: [DJLogLine] = []
    private let serialQueue = DispatchQueue(label: "DJLoggingSerialQueue")
    
    // MARK: - Persistence
    private let logDirectoryURL: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = caches.appendingPathComponent("DJLogs", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()
    
    private var logFileURL: URL { logDirectoryURL.appendingPathComponent("active.log") }
    
    /// Flush in–memory buffer to disk every `flushInterval` seconds **or**
    /// when `pendingFlushCount` reaches this threshold.
    private let flushInterval: TimeInterval = 5.0
    private let flushLineThreshold = 10
    
    /// Lines waiting to be persisted.
    private var pendingFlushCount = 0
    private var lastFlush = Date()
    
    // MARK: - Init
    private init() {
        // ⚠️ Don’t synchronously read from disk on first use.
        // We start a new session immediately, then load the previous session logs
        // on a background thread and prepend them once ready.

        // Start this session right away (keeps first log calls snappy at launch)
        // Add the app info to logs at the beggining of the log array
        serialQueue.async {
            // Insert explicit session separator.
            let sessionLine = DJLogLine(uuid: nil,
                                        title: "===== NEW SESSION \(Date().localFormat()) =====",
                                        log: nil, type: NewSessionLogType.shared)
            self.appendToLog(sessionLine)
            
            let appInfo = DispatchQueue.main.sync {
                self.appInfo // Incorrect warning in Swift 5, compiles fine in Swift 6
            }
            self.appendToLog(DJLogLine(uuid: nil, title: "LogManager Start", logs: appInfo))
        }
        
        // Load previous session in the background and prepend when done
        DispatchQueue.global(qos: .utility).async { [logFileURL] in
            if let data = try? Data(contentsOf: logFileURL) {
                let lines = data.split(separator: UInt8(ascii: "\n"))
                let previous = lines.compactMap { try? JSONDecoder().decode(DJLogLine.self, from: Data($0)) }
                self.serialQueue.async {
                    // Prepend previous logs at index 0, so they appear before this session’s header
                    self._logs.insert(contentsOf: previous, at: 0)
                }
            }
        }
        
        installTerminationObserver()
    }
    
    private func installTerminationObserver() {
#if os(iOS) || os(tvOS) || os(watchOS)
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil) { [weak self] _ in
            self?.handleTermination()
        }
#elseif os(macOS)
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: nil) { [weak self] _ in
            self?.handleTermination()
        }
#endif
    }
    
    private func handleTermination() {
        serialQueue.sync {
            pendingFlushCount = 0
            persistToDisk()
        }
    }
    
    // MARK: - Internal
    @MainActor
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
    
    public func log(_ title: String, code: Int? = nil, log: String?, uuid: UUID?, type: DJLogType = .standard) {
        serialQueue.async {
            let logLine = DJLogLine(uuid: uuid, code: code, title: title, log: log, type: type)
            self.appendToLog(logLine)
        }
    }
    
    private func log(_ title: String, code: Int? = nil, logs: [String], uuid: UUID?, type: DJLogType = .standard) {
        serialQueue.async {
            let logLine = DJLogLine(uuid: uuid, code: code, title: title, logs: logs, type: type)
            self.appendToLog(logLine)
        }
    }
    
    private func logRequestResponse(_ response: URLResponse?, data: Data?, error: Error?, uuid: UUID?, type: DJLogType = .standard) {
        
        var underlyingError: NSError? = nil
        if let error = error as? NSError {
            if (error.userInfo[NSUnderlyingErrorKey] != nil) {
                underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError
            }
        }
        
        let logs = [
            "Response: \(response?.description ?? "")",
            "Error: \(error?.localizedDescription ?? "")",
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
        if code == nil, let error = error as? NSError {
            code = error.code
        } else {
            if let code, 200...299 ~= code {
                title = "✅ \(title ?? "")"
            } else {
                title = "⚠️ \(title ?? "")"
            }
        }
        
        log(title ?? "", code: code, logs: logs, uuid: uuid, type: type)
    }
}

private extension LogManager {
    
    /**
     This is the internal function that appends log lines to the log array. It must only ever be called from the private serialQueue so everything is recorded in order.
     */
    func appendToLog(_ logLine: DJLogLine) {
        
        if #available(macOS 10.12, *) {
            dispatchPrecondition(condition: .onQueue(serialQueue)) // make sure caller used correct queue
        }
        
        _logs.append(logLine)
        pendingFlushCount += 1
        if pendingFlushCount == 1 {
            // Only need to disable this once we have 1 log not written to disk
            enableSuddenTermination(false)
        }
        
        if self.debugLogsToScreen == true {
            print("****LogManager**** \(logLine.uuid?.uuidString ?? "") \t\(logLine.title) \((logLine.logs != nil) ? "\n\t\(logLine.logs!)" : "")")
        }
        
        checkLogLength()
        
        // ── Persistence logic ──
        let now = Date()
        if pendingFlushCount >= flushLineThreshold || now.timeIntervalSince(lastFlush) >= flushInterval {
            pendingFlushCount = 0
            lastFlush = now
            persistToDisk()
        }
    }
    
    func checkLogLength() {
        
        if #available(macOS 10.12, *) {
            dispatchPrecondition(condition: .onQueue(serialQueue)) // make sure caller used correct queue
        }
        
        if _logs.count > maxLogLength {
            if debugLogsToScreen == true {
                print("Log too big: \(_logs.count) so trimming.")
            }
            _logs.remove(at: 0)
        }
    }
    
    // MARK: - Persistence helpers
    private func persistToDisk() {
        // Encode every log line to JSON and join with a single newline.
        let byteSequences = _logs.compactMap { try? JSONEncoder().encode($0) }
        let joinedBytes = byteSequences.joined(separator: Data([0x0A])) // newline
        let data = Data(joinedBytes)        // materialise the lazy sequence
        try? data.write(to: logFileURL, options: .atomic)
        if self.debugLogsToScreen == true {
            print("Saved logs to disk:", logFileURL)
        }
        
        enableSuddenTermination(true)
    }
    
#if os(macOS)
    /// Enable/Disable the sudden termination ability of a macOS app.
    ///
    /// If the app has defined in it's `Info.plist`:
    /// ```
    /// Application can be killed immediately when user is shutting down or logging out
    /// ```
    /// then we need to disable it in order to receive `willTerminateNotification`.
    ///
    /// We then re-enable it when we're in a state that doesn't require us to need `willTerminateNotification`.
    private func enableSuddenTermination(_ enable: Bool) {
        if Self.supportsSuddenTermination {
            if enable {
                // Safe to kill again
                ProcessInfo.processInfo.enableSuddenTermination()
            } else {
                ProcessInfo.processInfo.disableSuddenTermination()
            }
        }
    }
    
    /// Indicates whether the host app opted in to sudden‑termination via Info.plist
    private static let supportsSuddenTermination: Bool = {
        if let flag = Bundle.main.object(forInfoDictionaryKey: "NSSupportsSuddenTermination") as? Bool {
            return flag
        } else {
            return true
        }
    }()
#else
    /// Does nothing
    private func enableSuddenTermination(_ enable: Bool) {}
#endif
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
