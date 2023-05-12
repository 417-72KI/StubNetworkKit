// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isRelease = false

let isObjcAvailable: Bool = {
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        return true
    #else
        return false
    #endif
}()

let testDependencies: [Package.Dependency] = {
    if isRelease { return [] }
    var dependencies: [Package.Dependency] = [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
    ]
    if isObjcAvailable {
        dependencies += [
            .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.3.0"),
            .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        ]
    }
    return dependencies
}()
let testTargetDependencies: [Target.Dependency] = {
    if isRelease { return [] }
    var dependencies: [Target.Dependency] = [
        "Alamofire",
    ]
    if isObjcAvailable {
        dependencies += [
            "APIKit",
            "Moya",
        ]
    }
    return dependencies
}()

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
    dependencies: [
        .package(url: "https://github.com/YusukeHosonuma/SwiftParamTest.git", from: "2.2.1"),
    ] + testDependencies,
    targets: [
        .target(
            name: "StubNetworkKit",
            dependencies: []
        ),
        .testTarget(
            name: "StubNetworkKitTests",
            dependencies: [
                "StubNetworkKit",
                "SwiftParamTest",
            ] + testTargetDependencies,
            resources: [.copy("Fixtures")]
        ),
    ]
)
