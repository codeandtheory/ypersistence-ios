// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "YPersistence",
    products: [
        .library(
            name: "YPersistence",
            targets: ["YPersistence"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "YPersistence",
            dependencies: []
        ),
        .testTarget(
            name: "YPersistenceTests",
            dependencies: ["YPersistence"]
        )
    ]
)
