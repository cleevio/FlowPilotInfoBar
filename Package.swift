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
    name: "CleevioInfoBar",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CleevioInfoBar",
            targets: ["CleevioInfoBar"]),
    ],
    dependencies: [
        .package(url: "git@gitlab.cleevio.cz:cleevio-dev-ios/CleevioCore.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "git@gitlab.cleevio.cz:cleevio-dev-ios/CleevioRouters.git", .upToNextMajor(from: "2.2.0-dev1")),
        .package(url: "git@gitlab.cleevio.cz:cleevio-dev-ios/CleevioUI.git", (Version(2, 0, 0))..<(Version(4, 0, 0)))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CleevioInfoBar",
            dependencies: [
                "CleevioCore",
                "CleevioRouters",
                "CleevioUI"
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "CleevioInfoBarTests",
            dependencies: ["CleevioInfoBar"]),
    ]
)
