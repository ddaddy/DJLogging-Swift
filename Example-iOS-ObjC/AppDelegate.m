//
//  AppDelegate.m
//  Example-iOS-ObjC
//
//  Created by Darren Jones on 02/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

#import "AppDelegate.h"
#import <DJLogging/DJLogging.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LogManager.debugLogsToScreen = YES;
    LogMethodCall
    
    return YES;
}


@end
