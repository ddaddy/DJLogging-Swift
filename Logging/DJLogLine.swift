//
//  DJLogLine.swift
//  DJLogging
//
//  Created by Darren Jones on 11/06/2022.
//  Copyright © 2022 Darren Jones. All rights reserved.
//

import Foundation

internal struct DJLogLine {
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
