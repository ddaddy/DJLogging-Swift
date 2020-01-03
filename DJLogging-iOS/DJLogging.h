//
//  DJLogging.h
//  DJLogging
//
//  Created by Darren Jones on 01/01/2020.
//  Copyright © 2020 Darren Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DJLogging.
FOUNDATION_EXPORT double DJLoggingVersionNumber;

//! Project version string for DJLogging.
FOUNDATION_EXPORT const unsigned char DJLoggingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DJLogging/PublicHeader.h>

#define LogMethodCall LogMethodCallWithUUID(nil);
#define LogMethodCallWithUUID(x) [LogManager logStringWithString:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] uuid:(x)];
#define LogRequestResponseWithUUID(x) [LogManager logRequestResponseWithResponse:response data:data error:error uuid:(x)];
