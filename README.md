# StubNetworkingSwift

[![CI](https://github.com/417-72KI/StubNetworkingSwift/actions/workflows/ci.yml/badge.svg)](https://github.com/417-72KI/StubNetworkingSwift/actions/workflows/ci.yml)
[![GitHub release](https://img.shields.io/github/release/417-72KI/StubNetworkingSwift/all.svg)](https://github.com/417-72KI/StubNetworkingSwift/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F417-72KI%2FStubNetworkingSwift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/417-72KI/StubNetworkingSwift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F417-72KI%2FStubNetworkingSwift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/417-72KI/StubNetworkingSwift)
[![CocoaPods Version](http://img.shields.io/cocoapods/v/StubNetworkingSwift.svg?style=flat)](http://cocoapods.org/pods/StubNetworkingSwift)
[![CocoaPods Platform](http://img.shields.io/cocoapods/p/StubNetworkingSwift.svg?style=flat)](http://cocoapods.org/pods/StubNetworkingSwift)
[![GitHub license](https://img.shields.io/github/license/417-72KI/StubNetworkingSwift)](https://github.com/417-72KI/StubNetworkingSwift/blob/main/LICENSE)

**100% pure Swift** library to stub network requests.

**100% pure Swift** means, 
- No more Objective-C API
- Testable also in other than Apple platform (e.g. Linux)

## Installation
### Swift Package Manager(recommended)

```swift:Package.swift
.package(url: "https://github.com/417-72KI/StubNetworkingSwift.git", from: "0.0.2"),
```

### CocoaPods
```ruby:Podfile
pod 'StubNetworkingSwift'
```

## Preparation
**Pure Swift** is not supporting *method-swizzling*, therefore you have to enable stub explicitly.

If you are using `URLSession.shared` only, you can call `registerStubForSharedSession()` to enable stubs.

Otherwise, you should inject `URLSessionConfiguration` instance that stub is registered.

Sample codes with using `Alamofire`, `APIKit` or `Moya` exist as test-cases in [StubNetworkingSwiftTests.swift](https://github.com/417-72KI/StubNetworkingSwift/blob/main/Tests/StubNetworkingSwiftTests/StubNetworkingSwiftTests.swift).

## Example
### Basic

```swift
stub(Scheme.is("https") && Host.is("foo") && Path.is("/bar")) { _ in
    .json(["message": "Hello world!"])
}
```

### Using Result builder
```swift
stub {
    Scheme.is("https")
    Host.is("foo")
    Path.is("/bar")
    Method.isGet()
} withResponse: { _ in .json(["message": "Hello world!"]) }
```

### Function chain
```swift
stub()
    .scheme("https")
    .host("foo")
    .path("/bar")
    .method(.get)
    .responseJson(["message": "Hello world!"])
```

### More examples
If you are looking for more examples, look at [StubNetworkingSwiftTests.swift](https://github.com/417-72KI/StubNetworkingSwift/blob/main/Tests/StubNetworkingSwiftTests/StubNetworkingSwiftTests.swift).
