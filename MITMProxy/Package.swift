// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MITMProxy",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "MITMProxy",
            targets: ["MITMProxy"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.1.0"),
    ],
    targets: [
        .target(
            name: "MITMProxy",
            dependencies: ["SwiftShell"],
            resources: [
                .copy("Resources/mitmproxy/mitmweb"),
                .copy("Resources/scripts/kill-orphan.sh"),
                .process("mitmweb"),
                .process("kill-orphan.sh"),
            ]
        ),
        .testTarget(
            name: "MITMProxyTests",
            dependencies: ["MITMProxy"]
        ),
    ]
)
