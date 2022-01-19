// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SwiftGenerator",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", branch: "main"),
        .package(url: "https://github.com/jpsim/Yams.git", branch: "main"),
        .package(url: "https://github.com/hooliooo/CodeBuilder.git", from: "0.2.4"),
        .package(url: "https://github.com/mattpolzin/OpenAPIKit.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .executableTarget(
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
