// swift-tools-version: 5.8
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

// MARK: - Upcoming feature flags for Swift 6
package.targets.forEach {
    $0.swiftSettings = [
        // .forwardTrailingClosures,
        .existentialAny,
        .bareSlashRegexLiterals,
        .conciseMagicFile,
        // TODO: enable when 5.8 dropped
        // .importObjcForwardDeclarations,
        // .disableOutwardActorInference,
        // .deprecateApplicationMain,
        // .isolatedDefaultValues,
        // .globalConcurrency,
    ]
}

// ref: https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet
private extension SwiftSetting {
    static let forwardTrailingClosures: Self = .enableUpcomingFeature("ForwardTrailingClosures")              // SE-0286, Swift 5.3,  SwiftPM 5.8+
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                                // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let bareSlashRegexLiterals: Self = .enableUpcomingFeature("BareSlashRegexLiterals")                // SE-0354, Swift 5.7,  SwiftPM 5.8+
    static let conciseMagicFile: Self = .enableUpcomingFeature("ConciseMagicFile")                            // SE-0274, Swift 5.8,  SwiftPM 5.8+
    static let importObjcForwardDeclarations: Self = .enableUpcomingFeature("ImportObjcForwardDeclarations")  // SE-0384, Swift 5.9,  SwiftPM 5.9+
    static let disableOutwardActorInference: Self = .enableUpcomingFeature("DisableOutwardActorInference")    // SE-0401, Swift 5.9,  SwiftPM 5.9+
    static let deprecateApplicationMain: Self = .enableUpcomingFeature("DeprecateApplicationMain")            // SE-0383, Swift 5.10, SwiftPM 5.10+
    static let isolatedDefaultValues: Self = .enableUpcomingFeature("IsolatedDefaultValues")                  // SE-0411, Swift 5.10, SwiftPM 5.10+
    static let globalConcurrency: Self = .enableUpcomingFeature("GlobalConcurrency")                          // SE-0412, Swift 5.10, SwiftPM 5.10+
}

// MARK: - Enabling Complete Concurrency Checking for Swift 6
// ref: https://www.swift.org/documentation/concurrency/
package.targets.forEach {
    var settings = $0.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency"))
    $0.swiftSettings = settings
}
