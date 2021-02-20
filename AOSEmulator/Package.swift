// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AOSEmulator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AOSEmulator",
            targets: ["AOSEmulator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.1.0"),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "5.0.1"),
        .package(path: "../CommandPublisher"),
        .package(path: "../CommonTests"),
    ],
    targets: [
        .target(
            name: "AOSEmulator",
            dependencies: ["SwiftShell", "SWXMLHash", "CommandPublisher"],
            exclude: ["emulator"],
            resources: [
                .copy("Resources/emulator"),
                .copy("Resources/helper.sh"),
            ]
        ),
        .testTarget(
            name: "AOSEmulatorTests",
            dependencies: ["AOSEmulator", "CommonTests"]
        ),
    ]
)
