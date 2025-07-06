//
//  DJLogLine.swift
//  DJLogging
//
//  Created by Darren Jones on 11/06/2022.
//  Copyright © 2022 Darren Jones. All rights reserved.
//

import Foundation

internal struct DJLogLine : Sendable, Codable {
    let id: UUID = UUID()
    var type: DJLogType
    let date: Date
    let uuid: UUID?
    let code: Int?
    let title: String
    var logs: [String]? = nil
    
    init(date: Date = Date(), uuid: UUID?, code: Int? = nil, title: String, log: String?, type: DJLogType = .standard) {
        self.type = type
        self.date = date
        self.uuid = uuid
        self.code = code
        self.title = title
        if let log = log {
            logs = [log]
        }
    }
    
    init(date: Date = Date(), uuid: UUID?, code: Int? = nil, title: String, logs: [String], type: DJLogType = .standard) {
        self.type = type
        self.date = date
        self.uuid = uuid
        self.code = code
        self.title = title
        self.logs = logs
    }
    
    internal var html: String {
"""
<tr\(rowType)\(expandClick)>
    <td>\((logs != nil) ? ">" : "")</td>
    <td class="date">\(date)</td>
    <td class="type">\(type.name)</td>
    <td class="uuid"\(filterClick)>\(uuid?.uuidString ?? "")</td>
    <td class="code">\(code != nil ? String(describing: code!) : "")</td>
    <td class="title">\(title.cleanHTML())</td>
</tr>
\((logs != nil) ? hiddenRows : "")
"""
    }
    
    private var rowType: String { " id=\"\(type.id)\" style=\"background-color: \(type.hexColour);\"" }
    private var filterClick: String { (uuid != nil) ? " onclick=\"filter('\(uuid!.uuidString)')\"" : "" }
    private var expandClick: String { (logs != nil) ? " class=\"expandable\" onclick=\"showHideRow('\(id.uuidString)');\"" : ""}
    private var hiddenRows: String { logs?.map({ $0.hiddenRow(id: id) }).joined(separator: "\n") ?? "" }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case date, uuid, code, title, logs
        case typeName, typeRGBA
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(code, forKey: .code)
        try container.encode(title, forKey: .title)
        try container.encode(logs, forKey: .logs)
        try container.encode(type.name, forKey: .typeName)
        
        guard let rgba = type.colour.rgbaComponents() else {
            throw EncodingError.invalidValue(type.colour, EncodingError.Context(codingPath: encoder.codingPath,
                                                                                debugDescription: "Colour not convertible to sRGBA RGBA"))
        }
        try container.encode(rgba, forKey: .typeRGBA)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date    = try container.decode(Date.self, forKey: .date)
        uuid    = try container.decodeIfPresent(UUID.self, forKey: .uuid)
        code    = try container.decodeIfPresent(Int.self, forKey: .code)
        title   = try container.decode(String.self, forKey: .title)
        logs    = try container.decodeIfPresent([String].self, forKey: .logs)
        
        let typeName    = try container.decode(String.self, forKey: .typeName)
        let typeRGBA    = try container.decode([CGFloat].self, forKey: .typeRGBA)
        guard typeRGBA.count == 4 else { throw DecodingError.dataCorruptedError(forKey: .typeRGBA, in: container, debugDescription: "RGBA array must have four components") }
        let colour      = DJColor(red: typeRGBA[0], green: typeRGBA[1], blue: typeRGBA[2], alpha: typeRGBA[3])
        type            = DecodedLogType(name: typeName, colour: colour)
    }
}

private extension String {
    
    func cleanHTML() -> String {
        self
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: "    ", with: "&emsp;")
            .replacingOccurrences(of: "\n", with: "<br />")
    }
    
    func hiddenRow(id: UUID) -> String {
"""
<tr class="hidden_row \(id.uuidString)">
    <td colspan=7>
        \(self.cleanHTML())
    </td>
</tr>
"""
    }
}
