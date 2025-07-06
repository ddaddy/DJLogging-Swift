//
//  DJLogType.swift
//  DJLogging
//
//  Created by Darren Jones on 13/06/2022.
//  Copyright © 2022 Darren Jones. All rights reserved.
//

import Foundation

/**
 A protocol that defines a log type.
 
 Create a struct using this protocol. Be sure to initialise the `shared` variable to be a singleton
 then for ease of use create an extension like the following:
 ```
 struct DJLogTypeComms: DJLogType {
     static var shared: DJLogType = DJLogTypeComms()
     var id: UUID = UUID()
     var name: String = "comms"
     var colour: DJColor = DJColours.blue
 }
 
 extension DJLogType where Self == DJLogTypeComms {
     static var comms: DJLogType { DJLogTypeComms.shared }
 }
 ```
 */
public protocol DJLogType: Sendable {
    var id: UUID { get }
    var name: String { get }
    var colour: DJColor { get }
    
    static var shared: DJLogType { get }
}
extension DJLogType {
    internal var hexColour: String { colour.hexString }
}

public extension DJLogType where Self == DJLogTypeStandard {
    static var standard: DJLogType { DJLogTypeStandard.shared }
}

final public class DJLogTypeStandard: NSObject, DJLogType {
    public let id: UUID = UUID()
    public let name: String = ""
    public let colour: DJColor = DJColours.white
    
    public static let shared: DJLogType = DJLogTypeStandard()
    private override init() {}
}

/// Used to decode stored log lines
internal struct DecodedLogType: DJLogType {
    let id: UUID = UUID()
    let name: String
    let colour: DJColor
    static var shared: DJLogType { fatalError("Decoded types are not singletons") }
}
