// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
// Only for development checks
//    SwiftSetting.unsafeFlags([
//        "-Xfrontend", "-strict-concurrency=complete",
//        "-Xfrontend", "-warn-concurrency",
//        "-Xfrontend", "-enable-actor-data-race-checks",
//    ])
]

let package = Package(
    name: "FlowPilotInfoBar",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FlowPilotInfoBar",
            targets: ["FlowPilotInfoBar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cleevio/CleevioCore.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/cleevio/FlowPilot.git", .upToNextMajor(from: Version(3, 0, 0))),
        .package(url: "https://github.com/cleevio/CleevioUI.git", (Version(2, 0, 0))..<(Version(4, 0, 0)))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FlowPilotInfoBar",
            dependencies: [
                "CleevioCore",
                "FlowPilot",
                "CleevioUI"
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FlowPilotInfoBarTests",
            dependencies: ["FlowPilotInfoBar"]),
    ]
)
