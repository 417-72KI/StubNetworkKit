# StubNetworkKit

[![CI](https://github.com/417-72KI/StubNetworkKit/actions/workflows/ci.yml/badge.svg)](https://github.com/417-72KI/StubNetworkKit/actions/workflows/ci.yml)
[![GitHub release](https://img.shields.io/github/release/417-72KI/StubNetworkKit/all.svg)](https://github.com/417-72KI/StubNetworkKit/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F417-72KI%2FStubNetworkKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/417-72KI/StubNetworkKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F417-72KI%2FStubNetworkKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/417-72KI/StubNetworkKit)
[![CocoaPods Version](http://img.shields.io/cocoapods/v/StubNetworkKit.svg?style=flat)](http://cocoapods.org/pods/StubNetworkKit)
[![CocoaPods Platform](http://img.shields.io/cocoapods/p/StubNetworkKit.svg?style=flat)](http://cocoapods.org/pods/StubNetworkKit)
[![GitHub license](https://img.shields.io/github/license/417-72KI/StubNetworkKit)](https://github.com/417-72KI/StubNetworkKit/blob/main/LICENSE)

**100% pure Swift** library to stub network requests.

**100% pure Swift** means, 
- No more Objective-C API
- Testable also in other than Apple platform (e.g. Linux)

## Installation
### Swift Package Manager(recommended)

```swift:Package.swift
.package(url: "https://github.com/417-72KI/StubNetworkKit.git", from: "0.2.0"),
```

### CocoaPods
```ruby:Podfile
pod 'StubNetworkKit'
```

## Preparation
**Pure Swift** is not supporting *method-swizzling*, therefore you have to enable stub explicitly.

If you are using `URLSession.shared` only, you can call `registerStubForSharedSession()` to enable stubs.

Otherwise, you should inject `URLSessionConfiguration` instance that stub is registered.

Sample codes with using `Alamofire`, `APIKit` or `Moya` exist as test-cases in [StubNetworkKitTests.swift](https://github.com/417-72KI/StubNetworkKit/blob/main/Tests/StubNetworkKitTests/StubNetworkKitTests.swift).

## Example
### Basic

```swift
stub(Scheme.is("https") && Host.is("foo") && Path.is("/bar"))
    .responseJson(["message": "Hello world!"])
```

#### Switch response with conditional branches in request.

```swift
stub(Scheme.is("https") && Host.is("foo") && Path.is("/bar")) { request in
    guard request.url?.query == "q=1" else {
        return .error(.unexpectedRequest($0))
    }
    return .json(["message": "Hello world!"])
}
```

### Using Result builder
```swift
stub {
    Scheme.is("https")
    Host.is("foo")
    Path.is("/bar")
    Method.isGet()
}.responseJson(["message": "Hello world!"])
```

#### Switch response with conditional branches in request.

```swift
stub {
    Scheme.is("https")
    Host.is("foo")
    Path.is("/bar")
    Method.isGet()
} withResponse: { request in
    guard request.url?.query == "q=1" else {
        return .error(.unexpectedRequest($0))
    }
    return .json(["message": "Hello world!"]) 
}
```

### 
```swift
stub(url: "foo://bar/baz", method: .get)
    .responseData("Hello world!".data(using: .utf8)!)
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
If you are looking for more examples, look at [StubNetworkKitTests.swift](https://github.com/417-72KI/StubNetworkKit/blob/main/Tests/StubNetworkKitTests/StubNetworkKitTests.swift).
