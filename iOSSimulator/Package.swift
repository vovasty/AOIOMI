// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSSimulator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "iOSSimulator",
            targets: ["iOSSimulator"]
        ),
    ],
    dependencies: [
        .package(path: "../CommandPublisher"),
    ],
    targets: [
        .target(
            name: "iOSSimulator",
            dependencies: ["CommandPublisher"],
            resources: [
                .copy("Resources/helper.sh"),
                .copy("Resources/install_cert.py"),
                .copy("Resources/iosCertTrustManager.py"),
            ]
        ),
        .testTarget(
            name: "iOSSimulatorTests",
            dependencies: ["iOSSimulator"]
        ),
    ]
)
