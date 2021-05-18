// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnimatableStackView",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
    ],
    products: [
        .library(
            name: "AnimatableStackView",
            targets: ["AnimatableStackView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AnimatableStackView",
            dependencies: [],
            path: "AnimatableStackView/Classes",
            exclude: []),
    ]
)
