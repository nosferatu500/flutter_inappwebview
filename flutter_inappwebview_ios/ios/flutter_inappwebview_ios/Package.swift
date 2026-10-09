// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_inappwebview_ios",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(name: "flutter-inappwebview-ios", targets: ["flutter_inappwebview_ios"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_inappwebview_ios",
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
