// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "ProxyAddon",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "ProxyAddon",
            targets: ["ProxyAddon"]
        ),
    ],
    dependencies: [
        .package(path: "../MITMProxy"),
        .package(path: "../CommonUI"),
        .package(url: "https://github.com/sunshinejr/SwiftyUserDefaults", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "ProxyAddon",
            dependencies: ["MITMProxy", "CommonUI", "SwiftyUserDefaults"]
        ),
    ]
)
