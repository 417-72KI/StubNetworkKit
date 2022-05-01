import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Setup stub

public var defaultStubSession: URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    registerStub(to: configuration)
    return URLSession(configuration: configuration)
}

public func registerStub(to configuration: URLSessionConfiguration) {
    configuration.protocolClasses = [StubURLProtocol.self]
}

/// Handle all requests via `URLSession.shared`
public func registerStubForSharedSession() {
    assert(URLProtocol.registerClass(StubURLProtocol.self))
}

public func unregisterStubForSharedSession() {
    URLProtocol.unregisterClass(StubURLProtocol.self)
}

// MARK: - stub response
public func stub(_ condition: @escaping StubCondition,
                 withResponse stubResponse: @escaping (URLRequest) -> StubResponse) {
    StubURLProtocol.stubs
        .append(.init(condition: condition, response: stubResponse))
}
