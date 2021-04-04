// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MITMProxyAddons",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "MITMProxyAddons",
            targets: ["MITMProxyAddons"]
        ),
    ],
    dependencies: [
        .package(path: "../MITMProxy"),
    ],
    targets: [
        .target(
            name: "MITMProxyAddons",
            dependencies: ["MITMProxy"],
            resources: [
                .copy("Resources/python"),
            ]
        ),
        .testTarget(
            name: "MITMProxyAddonsTests",
            dependencies: ["MITMProxyAddons"]
        ),
    ]
)
