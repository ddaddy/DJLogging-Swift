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
"""
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
\(htmlHeader)
<body>
<div id="wrapper">
\(filterForm(lines: lines))
    <table border=1>
\(lines.map({ $0.html }).joined(separator: "\n"))
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
    
    private static func filterForm(lines: [DJLogLine]) -> String {
        
        let types = lines.map({ $0.type }).uniques(by: \.id).filter({ $0.name != NewSessionLogType.shared.name })
        
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
        
        <fieldset class="uuidFilterFieldset">
            <legend>UUID Filter:</legend>
            <label for="uuidFilter" class="uuidFilterLabel" style="">
                xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
                <button type="button" id="uuidFilter" onclick="showAll()">Reset</button>
            </label>
        </fieldset>
    </form>
"""
    }
    
    private static var scripts: String {
"""
<script type="text/javascript">
    function showHideRow(row) {
        $("." + row).toggle();
    }
    function filter(uuid) {
        checkAllFilters()
        const rows = document.querySelectorAll('table tr')
        rows.forEach(row => {
            row.style.display = ($(row).find(".uuid").text().includes(uuid)) ? '' : 'none'
        })
        $(".uuidFilterLabel").html('Showing only: ' + uuid + '  <button type="button" id="uuidFilter" onclick="showAll()">Reset</button>')
        $(".uuidFilterFieldset").show()
    }
    function showAll() {
        const rows = document.querySelectorAll('table tr')
        rows.forEach(row => {
            row.style.display = ''
        })
        $(".uuidFilterFieldset").hide()
    }
    $(".uuidFilterFieldset").hide()
    $(".typeFilter").change(function() {
        showAll()
        filterTypes()
    });
    function filterTypes() {
        const rows = document.querySelectorAll('table tr')
        var checked = $(".typeFilter:checkbox:checked")
        // Disable all rows
        rows.forEach(row => { row.style.display = 'none' })
        // Loop through checked type filters
        checked.each(function() {
            rows.forEach(row => {
                if ($(row).attr("id") === $(this).attr("id")) {
                    row.style.display = ''
                }
            })
        })
    }
    function checkAllFilters() {
        $(".typeFilter:checkbox").each(function() {
            $(this).prop('checked', true)
        })
        filterTypes()
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
        text-align: left;
        border-collapse: collapse;
        color: #2E2E2E;
        border: #A4A4A4;
    }
    table td {
        width: 1px; /* min width, actually: this causes the width to fit the content */
        white-space: nowrap;
        padding: 8px;
    }
    table td.uuid {
        max-width: 130px; /* Limit the UUID row as we don't actually care what it says */
        overflow: hidden;
        text-overflow: ellipsis;
    }
    table td:last-child {
        width: 100%; /* well, it's less than 100% in the end, but this still works for me */
    }

    table .hidden_row {
        display: none;
    }
    
    table .hidden_row td {
        padding-left: 50px;
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
