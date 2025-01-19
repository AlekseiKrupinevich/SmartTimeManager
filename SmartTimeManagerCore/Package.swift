// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SmartTimeManagerCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SmartTimeManagerCore",
            targets: ["SmartTimeManagerCore"]
        )
    ],
    targets: [
        .target(name: "SmartTimeManagerCore")
    ]
)
