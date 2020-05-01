// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftGenerator",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/hooliooo/CodeBuilder.git", from: "0.2.4"),
        .package(url: "https://github.com/mattpolzin/OpenAPIKit.git", from: "0.29.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "generator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "CodeBuilder", package: "CodeBuilder"),
                .product(name: "OpenAPIKit", package: "OpenAPIKit")
            ]
        ),
        .testTarget(
            name: "GeneratorTests",
            dependencies: [
                "generator"
            ]
        ),
    ]
)
