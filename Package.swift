// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isRelease = false

let testDependencies: [Package.Dependency] = isRelease ? [] : [
    .package(url: "https://github.com/YusukeHosonuma/SwiftParamTest.git", from: "2.2.1")
]

let testTarget: [Target] = isRelease ? [] : [
    .testTarget(
        name: "StubNetworkKitTests",
        dependencies: ["StubNetworkKit", "SwiftParamTest"],
        resources: [.copy("Fixtures")]
    )
]

let package = Package(
    name: "StubNetworkKit",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .watchOS(.v6),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "StubNetworkKit",
            targets: ["StubNetworkKit"]),
    ],
    dependencies: testDependencies,
    targets: [
        .target(
            name: "StubNetworkKit",
            dependencies: []
        ),
    ] + testTarget
)
