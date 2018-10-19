// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "media-manager",
    products: [
        .library(name: "MediaManager", targets: ["MediaManager"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        .package(url: "https://github.com/LiveUI/S3.git", .branch("master"))
    ],
    targets: [
        .target(name: "MediaManager", dependencies: ["Vapor", "S3"]),
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "MediaManager", "S3"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

