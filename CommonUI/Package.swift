// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CommonUI",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CommonUI",
            targets: ["CommonUI"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CommonUI",
            dependencies: []
        ),
    ]
)
