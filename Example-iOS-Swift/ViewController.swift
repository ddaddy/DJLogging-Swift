//
//  ViewController.swift
//  Example-iOS
//
//  Created by Darren Jones on 01/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

import UIKit
import MessageUI
import DJLogging

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        
        LogMethodCall(type: .ui)
        
        super.viewDidLoad()
        
        makeAWebRequest()
    }
    
    func makeAWebRequest() {
        let uuid = UUID()
        LogMethodCall(uuid, type: .comms)
        
        let request = URLRequest(url: URL(string: "https://venderbase.com")!)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            LogRequestResponse(uuid: uuid, response: response, data: data, error: error, type: .comms)
        }
        task.resume()
    }
    
    @IBAction func emailSupportButtonPressed(_ sender: Any) {
        
        LogMethodCall(type: .ui)
        
        if MFMailComposeViewController.canSendMail()
        {
            let mailComposeViewController = configuredMailComposeViewController()
            
            // Present new email composer
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            // If we cannot send mail (eg. Simulator) then dump the log to Debug
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                                    message: NSLocalizedString("Your device doesn't support sending email", comment: ""),
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                             style: .cancel,
                                             handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            LogManager.printLogs()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailer = MFMailComposeViewController()
        mailer.mailComposeDelegate = self;
        
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
        mailer.setSubject("\(appName ?? "") Support Request (iOS)")
        mailer.setToRecipients(["add.support.email@here.com"])
        
        // Convert log to HTML and attach file to email
        let htmlData = LogManager.htmlData() ?? Data()
        mailer.addAttachmentData(htmlData, mimeType: "text/html", fileName: "log.html")
        
        return mailer
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("Mail cancelled: you cancelled the operation and no email message was queued.")
            
        case .saved:
            print("Mail saved: you saved the email message in the drafts folder.")
            
        case .sent:
            print("Mail send: the email message is queued in the outbox. It is ready to send.")
            
        case .failed:
            print("Mail failed: the email message was not saved or queued, possibly due to an error.")
            
        default:
            print("Mail not sent.")
        }
        
        // Remove the mail view
        self.dismiss(animated: true, completion: nil)
    }
    
}

