// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommandPublisher",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CommandPublisher",
            targets: ["CommandPublisher"]
        ),
        .library(
            name: "CommandPublisherMock",
            targets: ["CommandPublisherMock"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.1.0"),
    ],
    targets: [
        .target(
            name: "CommandPublisher",
            dependencies: ["SwiftShell"]
        ),
        .testTarget(
            name: "CommandPublisherTests",
            dependencies: ["CommandPublisher"]
        ),
        .target(
            name: "CommandPublisherMock",
            dependencies: ["CommandPublisher"]
        ),
        .testTarget(
            name: "CommandPublisherMockTests",
            dependencies: ["CommandPublisherMock"]
        ),
    ]
)
