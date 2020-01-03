//
//  ViewController.m
//  Example-iOS-ObjC
//
//  Created by Darren Jones on 02/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

#import "ViewController.h"
#import <DJLogging/DJLogging.h>
@import MessageUI;

@interface ViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    LogMethodCall
    
    [super viewDidLoad];
    
    [self makeAWebRequest];
}

- (void)makeAWebRequest
{
    NSString *stringUUID = [[NSUUID UUID] UUIDString];
    LogMethodCallWithUUID(stringUUID)
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://venderbase.com"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        LogRequestResponseWithUUID(stringUUID)
    }];
    [task resume];
}

- (IBAction)emailSupportButtonPressed:(id)sender
{
    LogMethodCall
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer setMailComposeDelegate:self];
        
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        [mailer setSubject:[NSString stringWithFormat:@"%@ Support Request (iOS)", appName]];
        NSArray *toRecipients = [NSArray arrayWithObject:@"add.support.email@here.com"];
        [mailer setToRecipients:toRecipients];
        
        // Fetch the log
        NSData *logData = [self htmlLogFile];
        
        // Attach the HTML log
        [mailer addAttachmentData:logData mimeType:@"text/html" fileName:@"log.html"];
        
        // Present new email composer
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        // If we cannot send mail (eg. Simulator) then dump the log to NSLog
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                 message:NSLocalizedString(@"Your device doesn't support sending email", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"%@", [LogManager logString].string);
        NSString *htmlString = [[NSString alloc] initWithData:[self htmlLogFile] encoding:NSUTF8StringEncoding];
        NSLog(@"%@", htmlString);
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 Converts the log string into HTML data
 
 - Returns: A new `Data` object
 */
- (NSData *)htmlLogFile
{
    NSAttributedString *log = [LogManager logString];
    
    // Save log as HTML file
    NSData *logData = [log dataFromRange:NSMakeRange(0, log.length)
                      documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                   error:nil];
    
    return logData;
}

@end
