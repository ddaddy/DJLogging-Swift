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
#define LogMethodCallWithType(t) LogMethodCallWithUUIDAndType(nil, t);
#define LogMethodCallWithUUID(x) [LogManager logTitle:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] log:nil uuid:(x) type: DJLogTypeStandard.shared];
#define LogMethodCallWithUUIDAndType(x, t) [LogManager logTitle:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] log:nil uuid:(x) type: (t)];
#define LogRequestResponseWithUUID(x) [LogManager logRequestResponse:response data:data error:error uuid:(x) type:DJLogTypeStandard.shared];
#define LogRequestResponseWithUUIDAndType(x, t) [LogManager logRequestResponse:response data:data error:error uuid:(x) type:(t)];
