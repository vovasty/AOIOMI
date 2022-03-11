// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayloadAddon",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "PayloadAddon",
            targets: ["PayloadAddon"]
        ),
    ],
    dependencies: [
        .package(path: "../KVStore"),
        .package(path: "../CommonUI"),
        .package(path: "../MITMProxy"),
    ],
    targets: [
        .target(
            name: "PayloadAddon",
            dependencies: ["KVStore", "MITMProxy", "CommonUI"],
            resources: [
                .copy("Resources/payloadaddon"),
            ]
        ),
    ]
)
