//
//  AppDelegate.m
//  Example-Mac-ObjC
//
//  Created by Darren Jones on 02/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

#import "AppDelegate.h"
#import <DJLogging/DJLogging.h>
#import "DJLogTypeUI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    LogManager.debugLogsToScreen = YES;
    LogMethodCallWithType(DJLogTypeUI.shared)
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


@end
