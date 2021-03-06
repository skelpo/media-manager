// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "media-manager",
    products: [
        .library(name: "App", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/skelpo/S3Storage.git", from: "0.1.0"),
        .package(url: "https://github.com/skelpo/Storage.git", from: "0.1.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor-community/vapor-ext.git", from: "0.1.0"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "ServiceExt", "Storage", "S3Storage"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

