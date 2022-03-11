// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Translator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Translator",
            type: .dynamic,
            targets: ["CAPI"]
        ),
        .executable(name: "translate", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.2"),
    ],
    targets: [
        .target(
            name: "CAPI",
            dependencies: ["Translator"]
        ),
        .target(
            name: "Translator",
            dependencies: ["PrivateAPI", "SwiftSoup"]
        ),
        .target(
            name: "PrivateAPI",
            dependencies: []
        ),
        .target(
            name: "App",
            dependencies: ["Translator"]
        ),
        .testTarget(
            name: "TranslatorTests",
            dependencies: ["Translator"]
        ),
    ]
)
