import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
