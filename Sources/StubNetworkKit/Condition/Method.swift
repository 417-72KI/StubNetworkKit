import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum Method: Equatable, Sendable {
    case get
    case post
    case put
    case patch
    case delete
    case head
}

extension Method: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = switch value.lowercased() {
        case "get": .get
        case "post": .post
        case "put": .put
        case "patch": .patch
        case "delete": .delete
        case "head": .head
        default: fatalError("Unexpected method: \(value)")
        }
    }
}

public extension Method {
    static func isGet(file: StaticString = #file, line: UInt = #line) -> some StubCondition {
        _Method.isGet(file: file, line: line)
    }

    @available(watchOS, unavailable, message: "Intercepting POST request is not available in watchOS")
    static func isPost(file: StaticString = #file, line: UInt = #line) -> some StubCondition {
        _Method.isPost(file: file, line: line)
    }

    @available(watchOS, unavailable, message: "Intercepting PUT request is not available in watchOS")
    static func isPut(file: StaticString = #file, line: UInt = #line) -> some StubCondition {
        _Method.isPut(file: file, line: line)
    }

    @available(watchOS, unavailable, message: "Intercepting PATCH request is not available in watchOS")
    static func isPatch(file: StaticString = #file, line: UInt = #line) -> some StubCondition {
        _Method.isPatch(file: file, line: line)
    }

    @available(watchOS, unavailable, message: "Intercepting DELETE request is not available in watchOS")
    static func isDelete(file: StaticString = #file, line: UInt = #line) -> some StubCondition {
        _Method.isDelete(file: file, line: line)
    }

    static func isHead(file: StaticString = #file, line: UInt = #line) -> some StubCondition {
        _Method.isHead(file: file, line: line)
    }
}

extension Method {
    func condition(file: StaticString = #file, line: UInt = #line) -> some StubCondition {
        switch self {
        case .get: _Method.isGet(file: file, line: line)
        case .post: _Method.isPost(file: file, line: line)
        case .put: _Method.isPut(file: file, line: line)
        case .patch: _Method.isPatch(file: file, line: line)
        case .delete: _Method.isDelete(file: file, line: line)
        case .head: _Method.isHead(file: file, line: line)
        }
    }
}

// MARK: -
enum _Method: StubCondition {
    case isGet(file: StaticString = #file, line: UInt = #line)
    case isPost(file: StaticString = #file, line: UInt = #line)
    case isPut(file: StaticString = #file, line: UInt = #line)
    case isPatch(file: StaticString = #file, line: UInt = #line)
    case isDelete(file: StaticString = #file, line: UInt = #line)
    case isHead(file: StaticString = #file, line: UInt = #line)
}

extension _Method {
    var matcher: StubMatcher {
        switch self {
        case let .isGet(file, line):
            stubMatcher({ $0.httpMethod.flatMap(Method.init) }, .get, file: file, line: line)
        case let .isPost(file, line):
            stubMatcher({ $0.httpMethod.flatMap(Method.init) }, .post, file: file, line: line)
        case let .isPut(file, line):
            stubMatcher({ $0.httpMethod.flatMap(Method.init) }, .put, file: file, line: line)
        case let .isPatch(file, line):
            stubMatcher({ $0.httpMethod.flatMap(Method.init) }, .patch, file: file, line: line)
        case let .isDelete(file, line):
            stubMatcher({ $0.httpMethod.flatMap(Method.init) }, .delete, file: file, line: line)
        case let .isHead(file, line):
            stubMatcher({ $0.httpMethod.flatMap(Method.init) }, .head, file: file, line: line)
        }
    }
}

extension _Method {
    static func == (lhs: _Method, rhs: _Method) -> Bool {
        switch (lhs, rhs) {
        case (.isGet, .isGet),
             (.isPost, .isPost),
             (.isPut, .isPut),
             (.isPatch, .isPatch),
             (.isDelete, .isDelete),
             (.isHead, .isHead):
            true
        default: false
        }
    }
}

extension _Method {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .isGet: hasher.combine("get")
        case .isPost: hasher.combine("post")
        case .isPut: hasher.combine("put")
        case .isPatch: hasher.combine("patch")
        case .isDelete: hasher.combine("delete")
        case .isHead: hasher.combine("head")
        }
    }
}
