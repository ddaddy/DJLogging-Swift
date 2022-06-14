//
//  DJLogTypeUI.m
//  Example-Mac-ObjC
//
//  Created by Darren Jones on 14/06/2022.
//  Copyright © 2022 Darren Jones. All rights reserved.
//

#import "DJLogTypeUI.h"

@implementation DJLogTypeUI

static DJLogTypeUI *_sharedInstance = nil;
static NSUUID *_uuid = nil;

+ (id<DJLogType> _Nonnull)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (NSUUID *)id {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _uuid = [[NSUUID alloc] init];
    });
    
    return _uuid;
}

- (NSString *)name { return @"UI"; }
- (UIColor *)colour { return [DJColours blue]; }

@end
