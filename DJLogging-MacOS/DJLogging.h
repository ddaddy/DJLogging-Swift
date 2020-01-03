//
//  DJLogging_MacOS.h
//  DJLogging-MacOS
//
//  Created by Darren Jones on 02/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DJLogging_MacOS.
FOUNDATION_EXPORT double DJLogging_MacOSVersionNumber;

//! Project version string for DJLogging_MacOS.
FOUNDATION_EXPORT const unsigned char DJLogging_MacOSVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DJLogging_MacOS/PublicHeader.h>

#define LogMethodCall LogMethodCallWithUUID(nil);
#define LogMethodCallWithUUID(x) [LogManager logString:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] uuid:(x)];
#define LogRequestResponseWithUUID(x) [LogManager logRequestResponse:response data:data error:error uuid:(x)];
