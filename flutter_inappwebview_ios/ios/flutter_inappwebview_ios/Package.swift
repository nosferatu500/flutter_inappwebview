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
    targets: [
        .target(
            name: "flutter_inappwebview_ios",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [ .swiftLanguageMode(.v6) ]
        )
    ]
)
