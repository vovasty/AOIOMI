// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HTTPProxyManager",
    products: [
        .library(
            name: "HTTPProxyManager",
            targets: ["HTTPProxyManager"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "HTTPProxyManager",
            dependencies: []
        ),
        .testTarget(
            name: "HTTPProxyManagerTests",
            dependencies: ["HTTPProxyManager"]
        ),
    ]
)
