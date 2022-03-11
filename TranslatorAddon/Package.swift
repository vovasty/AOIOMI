// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TranslatorAddon",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "TranslatorAddon",
            targets: ["TranslatorAddon"]
        ),
    ],
    dependencies: [
        .package(path: "../KVStore"),
        .package(path: "../CommonUI"),
        .package(path: "../MITMProxy"),
        .package(url: "https://github.com/sunshinejr/SwiftyUserDefaults", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "TranslatorAddon",
            dependencies: ["KVStore", "CommonUI", "MITMProxy", "SwiftyUserDefaults"],
            resources: [
                .copy("Resources/translatoraddon"),
                .process("Resources/translatoraddon/libTranslator.dylib"),
            ]
        ),
    ]
)
