// swift-tools-version: 5.9
// Copyright (c) 2026 Jiejing Zhang.

import PackageDescription

let package = Package(
    name: "halloween",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "halloween", targets: ["halloween"]),
    ],
    targets: [
        // The page, the little server that hands it out, and the bits that
        // find or start tempo9.  A library so the tests can reach it.
        .target(name: "HalloweenKit"),
        .executableTarget(name: "halloween", dependencies: ["HalloweenKit"]),
        .testTarget(name: "HalloweenKitTests", dependencies: ["HalloweenKit"]),
    ]
)
