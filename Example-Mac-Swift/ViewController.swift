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

        LogMethodCall()
        
        super.viewDidLoad()
        
        makeAWebRequest()
    }
    
    func makeAWebRequest() {
        let stringUUID = UUID().uuidString
        LogMethodCallWithUUID(stringUUID)
        
        let request = URLRequest(url: URL(string: "https://venderbase.com")!)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            LogRequestResponse(uuid: stringUUID, response: response, data: data, error: error)
        }
        task.resume()
    }

    @IBAction func emailSupportButtonPressed(_ sender: Any) {
        
        LogMethodCall()
        
        // Save HTML as temp file
        let htmlData = htmlLogFile()
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
    
    /**
     Converts the log string into HTML data
     
     - Returns: A new `Data` object
     */
    func htmlLogFile() -> Data {
        let log = LogManager.logString();
        let htmlData = try? log.data(from: .init(location: 0, length: log.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
        return htmlData ?? Data.init()
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

