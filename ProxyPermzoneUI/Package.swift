// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProxyPermzoneUI",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "ProxyPermzoneUI",
            targets: ["ProxyPermzoneUI"]
        ),
    ],
    dependencies: [
        .package(path: "../KVStore"),
        .package(path: "../CommonUI"),
        .package(path: "../MITMProxyAddons"),
    ],
    targets: [
        .target(
            name: "ProxyPermzoneUI",
            dependencies: ["KVStore", "CommonUI", "MITMProxyAddons"]
        ),
        .testTarget(
            name: "ProxyPermzoneUITests",
            dependencies: ["ProxyPermzoneUI"]
        ),
    ]
)
