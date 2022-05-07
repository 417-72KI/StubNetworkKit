import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum Method: Equatable {
    case get
    case post
    case put
    case patch
    case delete
    case head
}

extension Method: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        switch value.lowercased() {
        case "get": self = .get
        case "post": self = .post
        case "put": self = .put
        case "patch": self = .patch
        case "delete": self = .delete
        case "head": self = .head
        default: fatalError("Unexpected method: \(value)")
        }
    }
}

public extension Method {
    static func isGet(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .get, file: file, line: line)
    }
    static func isPost(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .post, file: file, line: line)
    }
    static func isPut(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .put, file: file, line: line)
    }
    static func isPatch(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .patch, file: file, line: line)
    }
    static func isDelete(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .delete, file: file, line: line)
    }
    static func isHead(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .head, file: file, line: line)
    }
}

extension Method {
    func condition(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        switch self {
        case .get: return Method.isGet(file: file, line: line)
        case .post: return Method.isPost(file: file, line: line)
        case .put: return Method.isPut(file: file, line: line)
        case .patch: return Method.isPatch(file: file, line: line)
        case .delete: return Method.isDelete(file: file, line: line)
        case .head: return Method.isHead(file: file, line: line)
        }
    }
}

// MARK: -
enum _Method: StubConditionType {
    case isGet(file: StaticString = #file, line: UInt = #line)
    case isPost(file: StaticString = #file, line: UInt = #line)
    case isPut(file: StaticString = #file, line: UInt = #line)
    case isPatch(file: StaticString = #file, line: UInt = #line)
    case isDelete(file: StaticString = #file, line: UInt = #line)
    case isHead(file: StaticString = #file, line: UInt = #line)
}

extension _Method {
    var condition: StubCondition {
        switch self {
        case let .isGet(file, line):
            return stubCondition({ $0.httpMethod.flatMap(Method.init) }, .get, file: file, line: line)
        case let .isPost(file, line):
            return stubCondition({ $0.httpMethod.flatMap(Method.init) }, .post, file: file, line: line)
        case let .isPut(file, line):
            return stubCondition({ $0.httpMethod.flatMap(Method.init) }, .put, file: file, line: line)
        case let .isPatch(file, line):
            return stubCondition({ $0.httpMethod.flatMap(Method.init) }, .patch, file: file, line: line)
        case let .isDelete(file, line):
            return stubCondition({ $0.httpMethod.flatMap(Method.init) }, .delete, file: file, line: line)
        case let .isHead(file, line):
            return stubCondition({ $0.httpMethod.flatMap(Method.init) }, .head, file: file, line: line)
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
            return true
        default: return false
        }
    }
}
