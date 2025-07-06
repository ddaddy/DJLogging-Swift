# DJLogging-Swift

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

DJLogging is a Swift library for iPhone / iPad and Mac. It allows you to log points in code with associated data so if a user of your app contacts you you will have more information to help.

Logs are stored in a file and persist across app launches.

Use my [iOS LogViewer](https://github.com/ddaddy/LogViewer) app to easily read the logs on an iOS device

![Screenshot](screenshot1.png) ![Screenshot](screenshot2.png)

## Integrate using SPM

Simply use SPM to add the package `ddaddy/DJLogging-Swift.git`


## How to Use - Swift
#### Defined methods that can be called as is:
```swift
LogMethodCall(type: DJLogType = .standard)
```
```swift
LogMethodCall(_ param: String? = nil, type: DJLogType = .standard)
LogMethodCall(_ param: Double? = nil, type: DJLogType = .standard)
LogMethodCall(_ param: Int? = nil, type: DJLogType = .standard)
```
```swift
LogMethodCall(_ uuid: UUID?, type: DJLogType = .standard)
LogMethodCall(_ uuid: UUID?, logs: [String], type: DJLogType = .standard)
```
```swift
LogRequestResponse(uuid: UUID?, response: URLResponse?, data: Data?, error: Error?, type: DJLogType = .standard)
```

#### Methods
```swift
func htmlString() -> String
func htmlData() -> Data
func clearLog()
```

### Define your own log types
```swift
class DJLogTypeComms: DJLogType {
    static var shared: DJLogType = DJLogTypeComms()
    var name: String = "comms"
    var colour: DJColor = DJColours.orange
}

extension DJLogType where Self == DJLogTypeComms {
    static var comms: DJLogType { DJLogTypeComms.shared }
}
```

## License	

Copyright (c) 2019 Darren Jones (Dappological Ltd.)
