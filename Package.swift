// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnimatableView",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
    ],
    products: [
        .library(
            name: "AnimatableView",
            targets: ["AnimatableView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/anton-plebanovich/RoutableLogger.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "AnimatableView",
            dependencies: [
                .product(name: "RoutableLogger", package: "RoutableLogger"),
            ],
            path: "AnimatableView/Classes",
            exclude: []),
    ]
)
