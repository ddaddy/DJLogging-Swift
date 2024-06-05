//
//  ViewController.m
//  Example-Mac-ObjC
//
//  Created by Darren Jones on 02/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

#import "ViewController.h"
#import <DJLogging/DJLogging.h>
#import "DJLogTypeUI.h"
#import "DJLogTypeComms.h"

@interface ViewController () <NSSharingServiceDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    // This method is called before AppDelegate's applicationDidFinishLaunching
    [LogManager setDebugLogsToScreen:YES];
    LogMethodCallWithType(DJLogTypeUI.shared)
    
    [super viewDidLoad];
    
    [self makeAWebRequest];
}

- (void)makeAWebRequest
{
    NSUUID *uuid = [NSUUID UUID];
    LogMethodCallWithUUIDAndType(uuid, DJLogTypeComms.shared)
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://venderbase.com"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        LogRequestResponseWithUUIDAndType(uuid, DJLogTypeComms.shared)
    }];
    [task resume];
}

- (IBAction)emailSupportButtonPressed:(id)sender
{
    LogMethodCall
    
    // Save HTML as temp file
    NSData *htmlData = [LogManager htmlData];
    NSURL *tempFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingFormat:@"logs.html"]];
    NSLog(@"%@", tempFile);
    
    // Check if file exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile.path] == YES)
    {
        [[NSFileManager defaultManager] removeItemAtPath:tempFile.path error:nil];
    }
    
    BOOL success = [htmlData writeToFile:tempFile.path atomically:YES];
    if (success)
    {
        // Open email with attachment
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
