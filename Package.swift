// swift-tools-version: 5.4
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
    name: "StubNetworkingSwift",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .watchOS(.v5),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "StubNetworkingSwift",
            targets: ["StubNetworkingSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/YusukeHosonuma/SwiftParamTest.git", from: "2.2.0"),
    ] + testDependencies,
    targets: [
        .target(
            name: "StubNetworkingSwift",
            dependencies: []
        ),
        .testTarget(
            name: "StubNetworkingSwiftTests",
            dependencies: [
                "StubNetworkingSwift",
                "SwiftParamTest",
            ] + testTargetDependencies,
            resources: [.copy("Fixtures")]
        ),
    ]
)
