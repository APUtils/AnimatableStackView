// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnimatableView",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
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
            path: "AnimatableView",
            exclude: [],
            sources: ["Classes"],
            resources: [
                .process("Privacy/PrivacyInfo.xcprivacy")
            ]
        ),
    ]
)
