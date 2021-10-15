// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTTPProxyManager",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "HTTPProxyManager",
            targets: ["HTTPProxyManager"]
        ),
    ],
    dependencies: [
        .package(path: "../MITMProxy"),
        .package(path: "../CharlesProxy"),
    ],
    targets: [
        .target(
            name: "HTTPProxyManager",
            dependencies: ["MITMProxy", "CharlesProxy"]
        ),
    ]
)
