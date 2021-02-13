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
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "5.0.1"),

    ],
    targets: [
        .target(
            name: "HTTPProxyManager",
            dependencies: ["SWXMLHash"]
        ),
        .testTarget(
            name: "HTTPProxyManagerTests",
            dependencies: ["HTTPProxyManager"],
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
