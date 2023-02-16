// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "BareBones",
    platforms: [.macOS(.v11), .iOS(.v13)],
    products: [
        .library(name: "BareBones", targets: ["BareBones"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "BareBones"),
        .testTarget(name: "BareBonesTests", dependencies: ["BareBones"])
    ]
)
