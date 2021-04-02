// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CharlesProxy",
    products: [
        .library(
            name: "CharlesProxy",
            targets: ["CharlesProxy"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "5.0.1"),

    ],
    targets: [
        .target(
            name: "CharlesProxy",
            dependencies: ["SWXMLHash"]
        ),
        .testTarget(
            name: "CharlesProxyTests",
            dependencies: ["CharlesProxy"],
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
