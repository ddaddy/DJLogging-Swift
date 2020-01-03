# DJLogging-Swift

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

DJLogging is a Swift library for iPhone / iPad and Mac. It allows you to log points in code with associated data so if a user of your app contacts you you will have more information to help.

Fully compatible with both Swift and Objective-C projects


## Integrate using Carthage

Install [Carthage](https://github.com/Carthage/Carthage#installing-carthage) if not already available 

Change to the directory of your Xcode project, and Create and Edit your Cartfile and add DJLogging:

``` bash
$ cd /path/to/MyProject
$ touch Cartfile
$ open Cartfile

github "ddaddy/DJLogging-Swift.git" ~> 1.0
```

Save and run:

``` bash
$ carthage update
```

Drop the Carthage/Build/iOS .framework in your project.

For more details on Cartage and how to use it, check the [Carthage Github](https://github.com/Carthage/Carthage) documentation


## How to Use
#### Defined methods that can be called as is
```objective-c
LogMethodCall
```	
```objective-c
LogMethodCallWithUUID(NSString *)
```	
```objective-c
LogRequestResponseWithUUID(NSString *)
```	
#### Use the Singleton to access below methods
```objective-c
[LogManager sharedInstance]
```
#### Methods
```objective-c
+ (void)logString:(NSString *)string uuid:(NSString *)uuid;
```	
```objective-c
+ (void)logString:(NSString *)string data:(NSData *)data uuid:(NSString *)uuid;
```	
```objective-c
+ (void)logRequestResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error uuid:(NSString *)uuid
```	
```objective-c
+ (void)clearLog;
```	
```objective-c
+ (NSAttributedString *)logString;
```	

## License	

Copyright (c) 2019 Darren Jones (Dappological Ltd.)
