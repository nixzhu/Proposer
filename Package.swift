// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Proposer",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(name: "Proposer",  targets: ["Proposer"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Proposer", path: "Proposer")
    ],
    swiftLanguageVersions: [.v5]
)
