// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AndroidEmulator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AndroidEmulator",
            targets: ["AndroidEmulator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.1.0"),
    ],
    targets: [
        .target(
            name: "AndroidEmulator",
            dependencies: ["SwiftShell"],
            exclude: ["emulator"],
            resources: [
                .copy("Resources/emulator"),
            ]
        ),
        .testTarget(
            name: "AndroidEmulatorTests",
            dependencies: ["AndroidEmulator"]
        ),
    ]
)
