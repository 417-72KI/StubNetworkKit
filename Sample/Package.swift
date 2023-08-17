// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StubNetworkKitSample",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "AlamofireSample",
            targets: ["AlamofireSample"]),
        .library(
            name: "APIKitSample",
            targets: ["APIKitSample"]),
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.1"),
        .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.4.0"),
    ],
    targets: [
        .target(name: "Shared"),
        .target(
            name: "AlamofireSample",
            dependencies: ["Shared", "Alamofire"]
        ),
        .target(
            name: "APIKitSample",
            dependencies: ["Shared", "APIKit"]
        ),
        .testTarget(
            name: "AlamofireSampleTests",
            dependencies: [
                "AlamofireSample",
                "StubNetworkKit",
            ],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "APIKitSampleTests",
            dependencies: [
                "APIKitSample",
                "StubNetworkKit",
            ],
            resources: [.copy("Fixtures")]
        ),
    ]
)
