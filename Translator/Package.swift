// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Translator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
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
        .testTarget(
            name: "TranslatorTests",
            dependencies: ["Translator"]
        ),
        .target(
            name: "App",
            dependencies: ["Translator"]
        ),
    ]
)
