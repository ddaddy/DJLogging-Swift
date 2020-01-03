//
//  SupportMenuController.m
//  VAT Bridge
//
//  Created by Darren Jones on 26/03/2019.
//  Copyright © 2019 Dappological Ltd. All rights reserved.
//

#import "SupportMenuController.h"
@import Cocoa;
#import <DJLogging/DJLogging.h>

@interface SupportMenuController () <NSSharingServiceDelegate>
@property (weak) IBOutlet NSMenu *supportTopMenu;
@property (weak) IBOutlet NSMenuItem *emailSupportWithLogsMenuItem;
@end

@implementation SupportMenuController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self displayLicenseMenuItems];
}

#pragma mark - Menu Items

- (void)displayLicenseMenuItems
{
    self.supportTopMenu.title = @"Support";
}

- (IBAction)emailSupportPressed:(id)sender
{
    [self emailSupportWithLogsPressed:sender];
}

- (void)emailSupportWithLogsPressed:(id)sender
{
    NSAttributedString *log = [LogManager logString];
    NSData *logData = [log dataFromRange:NSMakeRange(0, log.length)
                      documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                   error:nil];
    
    NSURL *tempFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingFormat:@"logs.html"]];
    NSLog(@"%@", tempFile);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile.path] == YES)
    {
        [[NSFileManager defaultManager] removeItemAtPath:tempFile.path error:nil];
    }
    
    BOOL success = [logData writeToFile:tempFile.path atomically:YES];
    if (success)
    {
        [self emailSupportWithAttachment:tempFile];
    }
    else
    {
        [self displayModalAlertWithTitle:@"Error"
                                 message:@"Failed to attach logs to email"
                             buttonTitle:@"OK"
                              alertStyle:NSAlertStyleInformational];
        
        [self emailSupportWithAttachment:nil];
    }
}

#pragma mark - NSSharingService - Email

- (void)emailSupportWithAttachment:(NSURL *)attachment
{
    NSString *to = @"add.support.email@here.com";
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *subject = [NSString stringWithFormat:@"%@ Support Request (MacOS)", appName];
    NSString *body = @"\n\n\n\n";
    
    NSSharingService *sharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
    [sharingService setRecipients:@[to]];
    [sharingService setSubject:subject];
    sharingService.delegate = self;
    
    if (attachment)
    {
        [sharingService performWithItems:@[body, attachment]];
    }
    else
    {
        [sharingService performWithItems:@[body]];
    }
}

- (void)sharingService:(NSSharingService *)sharingService didFailToShareItems:(NSArray *)items error:(NSError *)error
{
    [self displayModalAlertWithTitle:@"Error"
                             message:@"Failed to open mail composer"
                         buttonTitle:@"OK"
                          alertStyle:NSAlertStyleInformational];
}

#pragma mark - NSAlert

- (void)displayModalAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle alertStyle:(NSAlertStyle)alertStyle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:title];
        [alert setInformativeText:message];
        [alert addButtonWithTitle:buttonTitle];
        [alert setAlertStyle:alertStyle];
        [alert runModal];
    });
}

@end
