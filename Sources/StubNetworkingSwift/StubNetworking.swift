import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class StubNetworking {
    private init() {}

    public static var option = defaultOption
}

public extension StubNetworking {
    struct Option {
        public var printDebugLog: Bool

        public init(printDebugLog: Bool) {
            self.printDebugLog = printDebugLog
        }
    }
}

extension StubNetworking {
    static let defaultOption = Option(printDebugLog: false,
                                      debugConditions: false)
}

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

// MARK: - logger
func debugLog(_ message: String) {
    guard StubNetworking.option.printDebugLog else { return }

    print("\u{001B}[33m[\(String(describing: StubNetworking.self))] \(message)\u{001B}[m")
}

func dumpCondition<T: Equatable>(expected: T?,
                                 actual: T?,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
    guard StubNetworking.option.debugConditions else { return }
    let file = file.description.split(separator: "/").last!
    let expected = unwrap(expected)
    let actual = unwrap(actual)
    let result = (expected == actual)
    print("\u{001B}[\(result ? 32 : 31)m[\(file):L\(line)] expected: \(expected), actual: \(actual)\u{001B}[m")
}

private func unwrap<T: Equatable>(_ value: T?) -> String {
    let pattern = #"Optional\((.+)\)"#
    return String(describing: value)
        .replacingOccurrences(of: pattern,
                              with: "$1",
                              options: .regularExpression,
                              range: nil)
        .replacingOccurrences(of: pattern,
                              with: "$1",
                              options: .regularExpression,
                              range: nil)
}
