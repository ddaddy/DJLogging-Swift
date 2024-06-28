// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DJLogging",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DJLogging",
            targets: ["DJLogging"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DJLogging",
            path: "Logging/",
            exclude: [
                "../Example-iOS-Swift/",
                "../Example-Mac-Swift/"
            ],
            sources: ["../Logging/"],
            swiftSettings: [
                .swiftLanguageVersion(.v6)
            ]
        )
    ]
)
