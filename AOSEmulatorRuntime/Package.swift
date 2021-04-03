// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AOSEmulatorRuntime",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AOSEmulatorRuntime",
            targets: ["AOSEmulatorRuntime"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.1.0"),
    ],
    targets: [
        .target(
            name: "AOSEmulatorRuntime",
            dependencies: ["SwiftShell"],
            resources: [
                .copy("Resources/helper.sh"),
                .copy("Resources/jdk"),
                .copy("Resources/commandlinetools.zip"),
            ]
        ),
        .testTarget(
            name: "AOSEmulatorRuntimeTests",
            dependencies: ["AOSEmulatorRuntime"]
        ),
    ]
)
