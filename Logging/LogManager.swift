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

public func LogMethodCall(function: String = #function, file: String = #file, line: Int = #line) {
    LogMethodCallWithUUID(nil, function: function, file: file, line: line)
}

public func LogMethodCallWithUUID(_ uuid: String?, function: String = #function, file: String = #file, line: Int = #line) {
    let lastPathComponent = URL.init(string: file)?.lastPathComponent ?? ""
    LogManager.logString("\(function) file:\(lastPathComponent) line:\(line)", uuid: uuid)
}

public func LogRequestResponse(uuid: String?, response: URLResponse?, data: Data?, error: Error?) {
    LogManager.logRequestResponse(response, data: data, error: error as NSError?, uuid: uuid)
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
     Default value is `3000000`
     */
    @objc public static var maxLogLength = 3000000
    
    // MARK: - Public methods
    
    /**
     Automatically appends app/system information to the end of the log
     
     - Returns: `NSAttributedString` of the entire log
     */
    @objc public static func logString() -> NSAttributedString {
        
        // Get the current log
        let currentLog = sharedInstance._logString!.mutableCopy() as! NSMutableAttributedString
        
        // Add the app version to end of log
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UniversalColor.myBlackColour
        ]
        currentLog.append(NSAttributedString(string: "Appname: \(appName) Version: \(appVersion) Build: \(appBuild)\n", attributes: attributes))
        currentLog.append(NSAttributedString(string: "SysInfo: \(SysInfo.sysInfo())\n"))
        
        return currentLog
    }
    
    @objc public static func logString(_ string:String, uuid:String?) {
        
        sharedInstance.checkLogLength()
        sharedInstance.logDate()
        sharedInstance.logTab()
        sharedInstance.logUUID(uuid: uuid)
        sharedInstance.logTab()
        sharedInstance.logString(string: string + "\n")
        
        if debugLogsToScreen
        {
            print("****LogManager**** \(uuid ?? "NO_UUID") \(string)")
        }
    }
    
    @objc public static func logString(_ string:String, data:Data?, uuid:String?) {
        
        sharedInstance.checkLogLength()
        sharedInstance.logDate()
        sharedInstance.logTab()
        sharedInstance.logUUID(uuid: uuid)
        sharedInstance.logTab()
        sharedInstance.logString(string: string, data: data)
        
        if debugLogsToScreen
        {
            var _data = data
            if _data == nil
            {
                _data = Data.init()
            }
            let dataMap = _data!.map { String(format: "%02x", $0)}.joined()
            print("****LogManager**** \(uuid ?? "NO_UUID") \(string) data:\(dataMap)")
        }
    }
    
    @objc public static func logRequestResponse(_ response:URLResponse?, data:Data?, error:NSError?, uuid:String?) {
        
        var underlyingError:NSError? = nil
        if error != nil
        {
            if (error!.userInfo[NSUnderlyingErrorKey] != nil)
            {
                underlyingError = error!.userInfo[NSUnderlyingErrorKey] as? NSError
                print("underlyingError: \(underlyingError!)")
            }
        }
        
        sharedInstance.checkLogLength()
        sharedInstance.logDate()
        sharedInstance.logTab()
        sharedInstance.logUUID(uuid: uuid)
        sharedInstance.logTab()

        let string = """
            Finished with status code: \(response?.getStatusCode() ?? 0)
            Response: \(response?.description ?? "")
            Error: \(error?.description ?? "")
            """ + (underlyingError != nil ? "\nUnderlyingError ":"")
            + (underlyingError != nil ? underlyingError!.description:"")
        
        sharedInstance.logString(string: string, data: data)
        
        if debugLogsToScreen
        {
            var _data = data
            if _data == nil
            {
                _data = Data.init()
            }
            let dataMap = _data!.map { String(format: "%02x", $0)}.joined()
            print("****LogManager**** \(uuid ?? "NO_UUID") \(string) data:\(dataMap)")
        }
        
    }
    
    @objc public static func clearLog() {
        sharedInstance._logString = NSMutableAttributedString.init(string: "")
    }
    
    // MARK: Private Properties
    
    private static let sharedInstance = LogManager()
    private var _logString: NSMutableAttributedString?
    
    // MARK: - Init

    // Initialization
    private override init() {
        _logString = NSMutableAttributedString.init(string: "")
        
        super.init()

        // Add the app version to logs
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        logString(string: "LogManager Start\n")
        logString(string: "Appname: \(appName) Version: \(appVersion) Build: \(appBuild)\n")
        logString(string: "SysInfo: \(SysInfo.sysInfo())\n")
    }
    
    // MARK: - Internal
    
    private func logString(string:String, colour:UniversalColor = .myBlackColour) {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: colour
        ]
        _logString?.append(NSAttributedString(string: string, attributes: attributes))
    }
    
    private func logString(string:String, data:Data?) {
        
        logString(string: string)
        
        if data != nil
        {
            let converted = String(data: data!, encoding: .utf8)
            if converted == nil
            {
                // Couldn't convert data using UTF8 (Strange!) So try another method
                let _converted = String(data: data!, encoding: .isoLatin1)
                if _converted == nil
                {
                    // Couldn't convert data using NSISOLatin (Strange!) So try another method
                    let __converted = String(data: data!, encoding: .ascii)
                    if __converted == nil
                    {
                        logString(string: "\t CANNOT CONVERT DATA TO STRING! \t\(data!)\n", colour: .myDataColour)
                    }
                    else
                    {
                        logString(string: "\t NSASCIIStringEncoding \t\(__converted!)\n", colour: .myDataColour)
                    }
                }
                else
                {
                    logString(string: "\t NSISOLatin1StringEncoding \t\(_converted!)\n", colour: .myDataColour)
                }
            }
            else
            {
                logString(string: "\t NSUTF8StringEncoding \t\(converted!)\n", colour: .myDataColour)
            }
        }
        else
        {
            logString(string: "\tnil data\n", colour: .myDataColour)
        }
    }
    
    private func logTab() {
        logString(string: "\t")
    }
    
    private func logDate() {
        logString(string: "\(Date())", colour: .myBlueColour)
    }
    
    private func logUUID(uuid: String!) {
        var _uuid = uuid
        if _uuid == nil
        {
            _uuid = "NO_UUID"
        }
        
        logString(string: "\(_uuid!)", colour: .myUUIDColour)
    }
    
    private func checkLogLength() {
        if _logString!.length > LogManager.maxLogLength
        {
            print("Log too big: \(_logString!.length)")
            _logString!.deleteCharacters(in: NSMakeRange(0, _logString!.length - LogManager.maxLogLength))
            _logString!.insert(NSAttributedString.init(string: "... LOG TRIMMED\n", attributes: [.foregroundColor: UniversalColor.myWarningColour]), at: 0)
            print("New length: \(_logString!.length)")
        }
    }
    
}

fileprivate extension URLResponse {

    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}
