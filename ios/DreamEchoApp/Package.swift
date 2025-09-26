// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DreamEchoApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "DreamEchoApp", targets: ["DreamEchoApp"])
    ],
    targets: [
        .target(name: "DreamEchoApp", path: "Sources"),
        .testTarget(name: "DreamEchoAppTests", dependencies: ["DreamEchoApp"], path: "Tests")
    ]
)
