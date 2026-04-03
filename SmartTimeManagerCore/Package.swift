// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SmartTimeManagerCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "SmartTimeManagerCore",
            targets: ["SmartTimeManagerCore"]
        )
    ],
    targets: [
        .target(
            name: "SmartTimeManagerCore",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
