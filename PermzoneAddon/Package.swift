// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PermzoneAddon",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "PermzoneAddon",
            targets: ["PermzoneAddon"]
        ),
    ],
    dependencies: [
        .package(path: "../KVStore"),
        .package(path: "../CommonUI"),
        .package(path: "../MITMProxyAddons"),
    ],
    targets: [
        .target(
            name: "PermzoneAddon",
            dependencies: ["KVStore", "CommonUI", "MITMProxyAddons"]
        ),
    ]
)
