// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IOSSimulator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "IOSSimulator",
            targets: ["IOSSimulator"]
        ),
    ],
    dependencies: [
        .package(path: "../CommandPublisher"),
        .package(path: "../CommonTests"),
    ],
    targets: [
        .target(
            name: "IOSSimulator",
            dependencies: ["CommandPublisher"],
            resources: [
                .copy("Resources/helper.sh"),
                .copy("Resources/install_cert.py"),
                .copy("Resources/iosCertTrustManager.py"),
            ]
        ),
        .testTarget(
            name: "IOSSimulatorTests",
            dependencies: ["IOSSimulator", "CommonTests"],
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
