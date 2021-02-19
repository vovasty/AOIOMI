// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CommonTests",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CommonTests",
            targets: ["CommonTests"]
        ),
    ],
    dependencies: [
        .package(path: "../CommandPublisher"),
    ],
    targets: [
        .target(
            name: "CommonTests",
            dependencies: [.product(name: "CommandPublisherMock", package: "CommandPublisher")],
            resources: [
                .copy("Resources"),
            ]
        ),
        .testTarget(
            name: "CommonTestsTests",
            dependencies: ["CommonTests"]
        ),
    ]
)
