// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BidirectionalMap",
    products: [
        .library(
            name: "BidirectionalMap",
            targets: ["BidirectionalMap"]
        ),
    ],
    targets: [
        .target(name: "BidirectionalMap"),
        .testTarget(
            name: "BidirectionalMapTests",
            dependencies: ["BidirectionalMap"]
        ),
    ]
)
