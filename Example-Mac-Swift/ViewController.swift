//
//  ViewController.swift
//  Example-Mac-Swift
//
//  Created by Darren Jones on 02/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

import Cocoa
import DJLogging

class ViewController: NSViewController, NSSharingServiceDelegate {

    override func viewDidLoad() {
        
        LogManager.setDebugLogsToScreen(true)
        
        LogMethodCall(type: .ui)
        
        super.viewDidLoad()
        
        makeAWebRequest(url: URL(string: "https://venderbase.com")!)
        makeAWebRequest(url: URL(string: "https://somethingnotvalidxxx.com")!)
    }
    
    func makeAWebRequest(url: URL) {
        let uuid = UUID()
        LogMethodCall(uuid, type: .comms)
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            LogRequestResponse(uuid: uuid, response: response, data: data, error: error, type: .comms)
        }
        task.resume()
    }

    @IBAction func emailSupportButtonPressed(_ sender: Any) {
        
        LogMethodCall(type: .ui)
        
        // Save HTML as temp file
        let htmlData = LogManager.htmlData() ?? Data()
        let tempFile = NSTemporaryDirectory().appending("logs.html")
        print(tempFile)
        
        do {
            let fileManager = FileManager.default

            // Check if file exists
            if fileManager.fileExists(atPath: tempFile)
            {
                // Delete file
                try fileManager.removeItem(atPath: tempFile)
            } else {
                print("File does not exist")
            }
            
            let tempFileURL = URL(fileURLWithPath: tempFile)
            try htmlData.write(to: tempFileURL)
            
            emailSupportWithAttachment(tempFileURL)

        }
        catch let error as NSError {
            print("An error took place: \(error)")
            
            displayModalAlertWithTitle("Error", message: "Failed to attach logs to email", buttonTitle: "OK", alertStyle: .informational)
            
            emailSupportWithAttachment(nil)
        }
    }
    
    // MARK: - NSSharingService - Email
    
    func emailSupportWithAttachment(_ attachment:URL?) {
        
        let to = "add.support.email@here.com"
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
        let subject = "\(appName ?? "") Support Request (MacOS)"
        let body = "\n\n\n\n"
        
        let sharingService = NSSharingService.init(named: .composeEmail)
        sharingService?.recipients = [to]
        sharingService?.subject = subject
        sharingService?.delegate = self
        
        if attachment != nil
        {
            sharingService?.perform(withItems: [body, attachment!])
        }
        else
        {
            sharingService?.perform(withItems: [body])
        }
    }
    
    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
        
        displayModalAlertWithTitle("Error", message: "Failed to open mail composer", buttonTitle: "OK", alertStyle: .informational)
    }
     
     // MARK: - NSAlert

    func displayModalAlertWithTitle(_ title:String, message:String, buttonTitle:String, alertStyle:NSAlert.Style) {
        
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.addButton(withTitle: buttonTitle)
            alert.alertStyle = alertStyle
            alert.runModal()
        }
    }
    
}

