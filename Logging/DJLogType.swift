//
//  DJLogType.swift
//  DJLogging
//
//  Created by Darren Jones on 13/06/2022.
//  Copyright © 2022 Darren Jones. All rights reserved.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

/**
 A protocol that defines a log type.
 
 Create a struct using this protocol. Be sure to initialise the `shared` variable to be a singleton
 then for ease of use create an extension like the following:
 ```
 struct DJLogTypeComms: DJLogType {
     static var shared: DJLogType = DJLogTypeComms()
     var name: String = "comms"
     var colour: DJColor = DJColours.blue
 }
 
 extension DJLogType where Self == DJLogTypeComms {
     static var comms: DJLogType { DJLogTypeComms.shared }
 }
 ```
 */
public protocol DJLogType: Sendable {
    var name: String { get }
    var colour: DJColor { get }
    
    static var shared: DJLogType { get }
}
extension DJLogType {
    /// Deterministic UUID derived from the type's `name`.
    internal var id: UUID { uuidV5(namespace: DJLogTypeNamespace, name: name) }
    internal var hexColour: String { colour.hexString }
}

// MARK: - Provided standard log type
public extension DJLogType where Self == DJLogTypeStandard {
    static var standard: DJLogType { DJLogTypeStandard.shared }
}

final public class DJLogTypeStandard: DJLogType {
    public let name: String = ""
    public let colour: DJColor = DJColours.white
    
    public static let shared: DJLogType = DJLogTypeStandard()
}

/// Used to decode stored log lines
internal struct DecodedLogType: DJLogType {
    let name: String
    let colour: DJColor
    static var shared: DJLogType { fatalError("Decoded types are not singletons") }
}

// MARK: - Make sure we always have the same UUID for a type
// RFC-4122 namespace for DJLogging log-types.
// Pick any fixed UUID *once*; don’t ever change it afterwards
private let DJLogTypeNamespace = UUID(uuidString: "8E8AE4C2-0EAD-2493-90F0-3F26366C6349")!

/// SHA-1 / SHA-256 based UUID-v5 generator
private func uuidV5(namespace: UUID, name: String) -> UUID {
    guard #available(macOS 10.15, iOS 13.0, *) else { return UUID() }
    var hasher = SHA256()
    withUnsafeBytes(of: namespace.uuid) { hasher.update(bufferPointer: $0) }
    hasher.update(data: Data(name.utf8))
    let digest = hasher.finalize()           // 32 bytes; we need only the first 16
    let bytes  = Array(digest.prefix(16))

    // Copy into tuple and patch version / variant bits
    var uuid = (
        bytes[0], bytes[1], bytes[2], bytes[3],
        bytes[4], bytes[5],
        bytes[6], bytes[7],
        bytes[8], bytes[9],
        bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
    )
    uuid.6  = (uuid.6  & 0x0F) | 0x50    // version 5
    uuid.8  = (uuid.8  & 0x3F) | 0x80    // RFC 4122 variant

    return UUID(uuid: uuid)
}
