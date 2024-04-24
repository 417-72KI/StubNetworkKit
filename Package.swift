// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isRelease = true

let isObjcAvailable: Bool = {
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    return true
    #else
    return false
    #endif
}()

let package = Package(
    name: "StubNetworkKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "StubNetworkKit",
            targets: ["StubNetworkKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/417-72KI/MultipartFormDataParser.git", from: "2.2.1")
    ],
    targets: [
        .target(
            name: "StubNetworkKit",
            dependencies: ["MultipartFormDataParser"]
        ),
    ]
)

if !isRelease {
    package.dependencies.append(contentsOf: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftParamTest.git", from: "2.2.1"),
    ])
    if isObjcAvailable {
        package.dependencies.append(contentsOf: [
            .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.4.0"),
        ])
    }

    let testTarget = Target.testTarget(
        name: "StubNetworkKitTests",
        dependencies: [
            "StubNetworkKit",
            "SwiftParamTest",
            "Alamofire",
        ],
        resources: [.copy("_Fixtures")]
    )
    if isObjcAvailable {
        testTarget.dependencies.append(contentsOf: [
            "APIKit",
        ])
    }
    package.targets.append(testTarget)
}
