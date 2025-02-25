// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "DYD",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "DYD",
            targets: ["DYD"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "DYD",
            dependencies: ["Kingfisher"])
    ]
)
