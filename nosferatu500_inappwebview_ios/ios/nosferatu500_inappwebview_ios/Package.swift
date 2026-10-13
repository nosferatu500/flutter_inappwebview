// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nosferatu500_inappwebview_ios",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(name: "nosferatu500-inappwebview-ios", targets: ["nosferatu500_inappwebview_ios"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "nosferatu500_inappwebview_ios",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [ .swiftLanguageMode(.v6) ]
        )
    ]
)
