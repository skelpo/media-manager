// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "media-manager",
    products: [
        .library(name: "App", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/skelpo/S3Storage.git", from: "1.0.0-alpha"),
        .package(url: "https://github.com/skelpo/Storage.git", from: "1.0.0-alpha"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Storage", "S3Storage"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

