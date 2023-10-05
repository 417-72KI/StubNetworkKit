// swift-tools-version: 5.7
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
        .package(url: "https://github.com/YusukeHosonuma/SwiftParamTest.git", from: "2.2.1"),
    ]
    if isObjcAvailable {
        dependencies += [
            .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.3.0"),
        ]
    }
    return dependencies
}()
let testTargetDependencies: [Target.Dependency] = {
    if isRelease { return [] }
    var dependencies: [Target.Dependency] = [
        "SwiftParamTest",
        "Alamofire",
    ]
    if isObjcAvailable {
        dependencies += [
            "APIKit",
        ]
    }
    return dependencies
}()
let testTarget: [Target] = isRelease ? [] : [
    .testTarget(
        name: "StubNetworkKitTests",
        dependencies: ["StubNetworkKit"] + testTargetDependencies,
        resources: [.copy("Fixtures")]
    )
]

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
        .package(url: "https://github.com/417-72KI/MultipartFormDataParser.git", from: "2.1.1")
    ] + testDependencies,
    targets: [
        .target(
            name: "StubNetworkKit",
            dependencies: ["MultipartFormDataParser"]
        ),
    ] + testTarget
)
