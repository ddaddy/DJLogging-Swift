//
//  HTML.swift
//  DJLogging
//
//  Created by Darren Jones on 11/06/2022.
//  Copyright © 2022 Darren Jones. All rights reserved.
//

import Foundation

internal struct DJHTML {
    
    static func html(from lines: [DJLogLine]) -> String {
        let sessions = sessionOptions(from: lines)
        let tableRows = tableHTML(from: lines)
        
return """
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
\(htmlHeader)
<body>
<div id="wrapper">
\(filterForm(lines: lines, sessions: sessions))
    <table border=1>
\(tableRows)
    </table>
</div>
</body>
\(scripts)
</html>
"""
    }
    
    private static var htmlHeader: String {
"""
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<title></title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.2/js/bootstrap.min.js"></script>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.2/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="https://use.fontawesome.com/releases/v5.6.3/css/all.css">
\(cssStyle)
</head>
"""
    }
    
    private static func filterForm(lines: [DJLogLine], sessions: [SessionOption]) -> String {
        
        let types = lines.map({ $0.type }).uniques(by: \.id)
        
        return
"""
    <form class="row-fluid well">
        <fieldset id="filterList">
            <legend>Filter</legend>
\(types.map({
"""
            <label for="\($0.id)" style=\"background-color: \($0.hexColour);\">
                <input type="checkbox" id="\($0.id)" class="typeFilter" checked />\(($0.name == "" ? "standard" : $0.name))
            </label>
"""
 }).joined(separator: "\n"))
        </fieldset>
        
        <fieldset id="sessionFilterFieldset">
            <legend>Session:</legend>
            <select id="sessionFilter" onchange="applyFilters()">
                <option value="all">All sessions</option>
\(sessions.map({ "                <option value=\"\($0.index)\">\($0.title.cleanHTML())</option>" }).joined(separator: "\n"))
            </select>
        </fieldset>
        
        <fieldset class="uuidFilterFieldset">
            <legend>UUID Filter:</legend>
            <label for="uuidFilter" class="uuidFilterLabel" style="">
                xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
                <button type="button" id="uuidFilter" onclick="showAll()">Reset</button>
            </label>
            <input type="hidden" id="activeUUIDFilter" value="" />
        </fieldset>
    </form>
"""
    }
    
    private struct SessionOption {
        let index: Int
        let title: String
    }
    
    private static func sessionOptions(from lines: [DJLogLine]) -> [SessionOption] {
        var sessions: [SessionOption] = []
        var currentSession = 0
        
        lines.forEach { line in
            guard isNewSession(line) else { return }
            currentSession += 1
            sessions.append(SessionOption(index: currentSession, title: sessionTitle(from: line.title)))
        }
        
        return sessions
    }
    
    private static func tableHTML(from lines: [DJLogLine]) -> String {
        var currentSession = 0
        return lines.map { line in
            if isNewSession(line) {
                currentSession += 1
            }
            return line.html(session: currentSession)
        }.joined(separator: "\n")
    }
    
    private static func isNewSession(_ line: DJLogLine) -> Bool {
        line.type.name == NewSessionLogType.shared.name || line.title.hasPrefix("===== NEW SESSION")
    }
    
    private static func sessionTitle(from title: String) -> String {
        title
            .replacingOccurrences(of: "=====", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static var scripts: String {
"""
<script type="text/javascript">
    function showHideRow(row) {
        const rows = $("." + row)
        rows.toggle()
        const expanded = rows.first().is(":visible")
        $('.chevron[data-row="' + row + '"]').text(expanded ? "\\u25BE" : "\\u25B8")
    }
    function filter(uuid) {
        $("#activeUUIDFilter").val(uuid)
        applyFilters()
        $(".uuidFilterLabel").html('Showing only: ' + uuid + '  <button type="button" id="uuidFilter" onclick="showAll()">Reset</button>')
        $(".uuidFilterFieldset").show()
    }
    function showAll() {
        $("#activeUUIDFilter").val("")
        $("#sessionFilter").val("all")
        $(".typeFilter:checkbox").each(function() {
            $(this).prop('checked', true)
        })
        $(".uuidFilterFieldset").hide()
        applyFilters()
    }
    $(".uuidFilterFieldset").hide()
    $(".typeFilter").change(function() {
        $("#activeUUIDFilter").val("")
        $(".uuidFilterFieldset").hide()
        applyFilters()
    });
    function applyFilters() {
        const rows = document.querySelectorAll('table tr')
        const checkedTypes = $(".typeFilter:checkbox:checked").map(function() { return $(this).attr("id") }).get()
        const selectedSession = $("#sessionFilter").val()
        const uuid = $("#activeUUIDFilter").val()
        
        rows.forEach(row => {
            const jqRow = $(row)
            const isHiddenRow = jqRow.hasClass("hidden_row")
            const sessionMatches = selectedSession === "all" || jqRow.data("session") == selectedSession
            const typeMatches = isHiddenRow || checkedTypes.includes(jqRow.attr("id"))
            const uuidMatches = uuid === "" || jqRow.find(".uuid").text().includes(uuid)
            row.style.display = (!isHiddenRow && sessionMatches && typeMatches && uuidMatches) ? '' : 'none'
        })
        $(".chevron").text(function() { return $(this).data("row") ? "\\u25B8" : "" })
    }
    function checkAllFilters() {
        $(".typeFilter:checkbox").each(function() {
            $(this).prop('checked', true)
        })
        applyFilters()
    }
    function copyLogPayload(button) {
        const payload = cleanCopiedPayload($(button).siblings(".logPayload")[0].innerText)
        copyText(payload)
        const original = button.innerText
        button.innerText = "Copied"
        setTimeout(function() { button.innerText = original }, 1200)
    }
    function copyURL(button) {
        copyText(button.dataset.url)
        const original = button.innerText
        button.innerText = "Copied"
        setTimeout(function() { button.innerText = original }, 1200)
    }
    function copyText(text) {
        if (navigator.clipboard) {
            navigator.clipboard.writeText(text)
        } else {
            const textArea = document.createElement("textarea")
            textArea.value = text
            document.body.appendChild(textArea)
            textArea.select()
            document.execCommand("copy")
            document.body.removeChild(textArea)
        }
    }
    function cleanCopiedPayload(payload) {
        return payload.replace(/^\\s*(Response body|Raw data|URL):\\s*/, "")
    }
</script>
"""
    }
    
    private static var cssStyle: String {
"""
<style>
    body {
        padding: 0px;
        text-align: left;
        width: 100%;
        font-family: "Myriad Pro",
            "Helvetica Neue", Helvetica, Arial, Sans-Serif;
    }

    table {
        width: 100%;
        max-width: 100%;
        table-layout: fixed;
        text-align: left;
        border-collapse: collapse;
        color: #2E2E2E;
        border: #A4A4A4;
    }
    table td {
        width: 1px;
        white-space: nowrap;
        padding: 8px;
        vertical-align: top;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    table td.chevron {
        width: 24px;
        padding-left: 6px;
        padding-right: 4px;
        text-align: center;
    }
    table td.date {
        width: 210px;
    }
    table td.type {
        width: 120px;
    }
    table td.uuid {
        width: 150px;
        max-width: 130px; /* Limit the UUID row as we don't actually care what it says */
        overflow: hidden;
        text-overflow: ellipsis;
    }
    table td.code {
        width: 60px;
    }
    table td.title {
        white-space: normal;
        word-break: break-word;
        overflow-wrap: anywhere;
    }
    table td:last-child {
        width: 100%; /* well, it's less than 100% in the end, but this still works for me */
    }

    table .hidden_row {
        display: none;
    }
    
    table .hidden_row td {
        padding-left: 50px;
        white-space: normal;
        overflow: visible;
        text-overflow: clip;
    }

    table tr:hover {
        background-color: #F2F2F2;
    }

    table tr.expandable {
        background-color: rgb(228, 231, 217);
    }

    fieldset {
        border: none;
        height: 70px;
    }

    fieldset:before {
        content: '';
        display: inline-block;
        vertical-align: middle;
        height: 100%;
        width: 0;
    }

    legend {
        height: 100%;
        line-height: 70px;
        width: 150px;
        text-align: center;
        float: left;
    }

    label {
        padding: 5px 10px;
    }

    input[type=checkbox] {
        margin: 0 10px;
    }
    #sessionFilter {
        max-width: 360px;
        margin: 18px 10px;
        padding: 4px 8px;
    }
    
    .copyLogButton,
    .copyURLButton {
        appearance: none;
        border: 1px solid #A4A4A4;
        border-radius: 4px;
        background: #F8F8F8;
        color: #2E2E2E;
        cursor: pointer;
        font: inherit;
        font-size: 12px;
        line-height: 1.2;
        padding: 3px 7px;
    }
    .copyLogButton:hover,
    .copyURLButton:hover {
        background: #ECECEC;
        border-color: #7A7A7A;
    }
    .copyLogButton:active,
    .copyURLButton:active {
        background: #E0E0E0;
    }
    .copyLogButton {
        display: inline-block;
        margin-bottom: 8px;
    }
    .copyURLButton {
        margin-right: 6px;
        vertical-align: 1px;
        white-space: nowrap;
    }
    
    .logPayload {
        white-space: pre-wrap;
        word-break: break-word;
        overflow-wrap: anywhere;
    }
</style>
"""
    }
}

private extension Array {
    
    /**
     Filters an array to return one of each item where the keyPath elements are unique
     - Parameters:
     - keyPath: The keypath to filter
     
     Example:
     ```
     struct Person {
         let firstName: String
         let surname: String
     }
     let array = [
         Person(firstName: "Darren", surname: "Jones"),
         Person(firstName: "Jenny", surname: "Jones"),
         Person(firstName: "Mark", surname: "Chadwick")
     ]
     
     let filtered = array.uniques(by: \.surname)
     
     // [{firstName "Darren", surname "Jones"}, {firstName "Mark", surname "Chadwick"}]
     ```
     */
    func uniques<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return reduce([]) { result, element in
            let alreadyExists = (result.contains(where: { $0[keyPath: keyPath] == element[keyPath: keyPath] }))
            return alreadyExists ? result : result + [element]
        }
    }
}

private extension String {
    
    func cleanHTML() -> String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
