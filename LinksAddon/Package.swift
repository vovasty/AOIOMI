// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "LinksAddon",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "LinksAddon",
            targets: ["LinksAddon"]
        ),
    ],
    dependencies: [
        .package(path: "../CommandPublisher"),
        .package(path: "../IOSSimulator"),
        .package(path: "../AOSEmulator"),
        .package(url: "https://github.com/AlwaysRightInstitute/mustache", from: "1.0.1"),
        .package(path: "../KVStore"),
        .package(path: "../CommonUI"),
    ],
    targets: [
        .target(
            name: "LinksAddon",
            dependencies: ["mustache", "KVStore", "CommandPublisher", "IOSSimulator", "CommonUI", "AOSEmulator"]
        ),
        .testTarget(
            name: "LinksAddonTests",
            dependencies: ["LinksAddon"]
        ),
    ]
)
