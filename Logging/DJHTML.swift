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
            <button type="button" class="sessionJSONButton" onclick="copySessionCommsJSON()">Copy JSON</button>
            <button type="button" class="sessionJSONButton" onclick="viewSessionCommsJSON()">View JSON</button>
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
    <div id="sessionJSONModal" onclick="hideSessionCommsJSON(event)">
        <div id="sessionJSONPanel" onclick="event.stopPropagation()">
            <button type="button" id="sessionJSONCloseButton" onclick="hideSessionCommsJSON()">Close</button>
            <pre id="sessionJSONOutput"></pre>
        </div>
    </div>
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
    function sessionCommsJSON() {
        return JSON.stringify(sessionComms(), null, 2)
    }
    function copySessionCommsJSON() {
        const selectedSession = $("#sessionFilter").val()
        if (selectedSession === "all") {
            alert("Select a single session first.")
            return
        }
        copyText(sessionCommsJSON())
        const buttons = $(".sessionJSONButton")
        const original = buttons.first().text()
        buttons.first().text("Copied")
        setTimeout(function() { buttons.first().text(original) }, 1200)
    }
    function viewSessionCommsJSON() {
        const selectedSession = $("#sessionFilter").val()
        if (selectedSession === "all") {
            alert("Select a single session first.")
            return
        }
        $("#sessionJSONOutput").text(sessionCommsJSON())
        $("#sessionJSONModal").show()
    }
    function hideSessionCommsJSON() {
        $("#sessionJSONModal").hide()
    }
    function sessionComms() {
        const selectedSession = $("#sessionFilter").val()
        const sessionTitle = $("#sessionFilter option:selected").text()
        const comms = []
        
        $("table tr.expandable").each(function() {
            const row = $(this)
            if (selectedSession !== "all" && String(row.data("session")) !== selectedSession) {
                return
            }
            
            const details = rowDetails(row)
            const requestURLText = firstDetailValue(details, "Request URL")
            const urlText = requestURLText || firstDetailValue(details, "URL")
            const requestMethod = firstDetailValue(details, "Request method")
            const requestBody = firstDetailValue(details, "Request body")
            const statusText = firstDetailValue(details, "Status code")
            const responseBody = firstDetailValue(details, "Response body")
            if (!urlText && !statusText && responseBody === undefined) {
                return
            }
            
            comms.push({
                endpoint: endpointFromURL(urlText),
                url: urlText || null,
                method: requestMethod || null,
                sentParams: sentParams(urlText, requestBody),
                statusCode: statusText !== undefined ? Number(statusText) : null,
                responseJSONPayload: parsedJSON(responseBody),
                responsePayload: responseBody !== undefined ? responseBody : null
            })
        })
        
        return {
            session: {
                index: Number(selectedSession),
                title: sessionTitle
            },
            comms: comms
        }
    }
    function rowDetails(row) {
        const rowID = row.find(".chevron").data("row")
        if (!rowID) { return [] }
        return $("tr." + rowID + " .logPayload").map(function() {
            return this.innerText
        }).get()
    }
    function firstDetailValue(details, label) {
        const prefix = label + ":"
        const detail = details.find(function(value) {
            return value.indexOf(prefix) === 0
        })
        if (detail === undefined) { return undefined }
        return detail.substring(prefix.length).trim()
    }
    function endpointFromURL(urlText) {
        if (!urlText) { return null }
        try {
            const url = new URL(urlText)
            return url.origin + url.pathname
        } catch (error) {
            return urlText
        }
    }
    function paramsFromURL(urlText) {
        const params = {}
        if (!urlText) { return params }
        try {
            const url = new URL(urlText)
            url.searchParams.forEach(function(value, key) {
                if (params[key] === undefined) {
                    params[key] = value
                } else if (Array.isArray(params[key])) {
                    params[key].push(value)
                } else {
                    params[key] = [params[key], value]
                }
            })
        } catch (error) {}
        return params
    }
    function sentParams(urlText, requestBody) {
        const params = paramsFromURL(urlText)
        const bodyParams = paramsFromBody(requestBody)
        Object.keys(bodyParams).forEach(function(key) {
            if (params[key] === undefined) {
                params[key] = bodyParams[key]
            } else {
                params[key] = {
                    query: params[key],
                    body: bodyParams[key]
                }
            }
        })
        return params
    }
    function paramsFromBody(requestBody) {
        if (requestBody === undefined || requestBody === null || requestBody === "") { return {} }
        const json = parsedJSON(requestBody)
        if (json !== null) {
            if (typeof json === "object" && !Array.isArray(json)) { return json }
            return { body: json }
        }
        
        const params = {}
        try {
            if (requestBody.indexOf("=") >= 0) {
                const searchParams = new URLSearchParams(requestBody)
                searchParams.forEach(function(value, key) {
                    params[key] = value
                })
                if (Object.keys(params).length > 0) { return params }
            }
        } catch (error) {}
        
        return { body: requestBody }
    }
    function parsedJSON(payload) {
        if (payload === undefined || payload === null || payload === "") { return null }
        try {
            return JSON.parse(payload)
        } catch (error) {
            return null
        }
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
    .copyURLButton,
    .sessionJSONButton,
    #sessionJSONCloseButton {
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
    .copyURLButton:hover,
    .sessionJSONButton:hover,
    #sessionJSONCloseButton:hover {
        background: #ECECEC;
        border-color: #7A7A7A;
    }
    .copyLogButton:active,
    .copyURLButton:active,
    .sessionJSONButton:active,
    #sessionJSONCloseButton:active {
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
    .sessionJSONButton {
        margin: 18px 4px;
    }
    
    .logPayload {
        white-space: pre-wrap;
        word-break: break-word;
        overflow-wrap: anywhere;
    }
    #sessionJSONModal {
        display: none;
        position: fixed;
        inset: 0;
        z-index: 1000;
        background: rgba(0, 0, 0, 0.35);
        padding: 32px;
    }
    #sessionJSONPanel {
        box-sizing: border-box;
        width: 100%;
        height: 100%;
        background: #FFFFFF;
        border: 1px solid #A4A4A4;
        border-radius: 4px;
        padding: 16px;
        overflow: auto;
    }
    #sessionJSONCloseButton {
        float: right;
        margin-bottom: 12px;
    }
    #sessionJSONOutput {
        clear: both;
        margin: 0;
        white-space: pre-wrap;
        word-break: break-word;
        overflow-wrap: anywhere;
        font-family: Menlo, Consolas, monospace;
        font-size: 12px;
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
