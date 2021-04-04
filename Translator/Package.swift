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
        .library(
            name: "TranslatorAddon",
            targets: ["TranslatorAddon"]
        ),
        .executable(name: "translate", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.2"),
        .package(path: "../MITMProxy"),
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
        .target(
            name: "TranslatorAddon",
            dependencies: ["MITMProxy"],
            resources: [
                .copy("Resources/python"),
                .process("Resources/python/libTranslator.dylib"),
            ]
        ),
        .testTarget(
            name: "TranslatorTests",
            dependencies: ["Translator"]
        ),
    ]
)
