import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum Header: Equatable {}

public extension Header {
    static func contains(_ name: String,
                         file: StaticString = #file,
                         line: UInt = #line) -> some StubCondition {
        _Header.containsFieldName(name, file: file, line: line)
    }
    
    static func contains(_ name: String,
                         withValue value: String,
                         file: StaticString = #file,
                         line: UInt = #line) -> some StubCondition {
        _Header.containsFieldNameWithValue(name, value: value, file: file, line: line)
    }
}

// MARK: -
enum _Header: StubCondition {
    case containsFieldName(String, file: StaticString = #file, line: UInt = #line)
    case containsFieldNameWithValue(String, value: String, file: StaticString = #file, line: UInt = #line)
}

extension _Header {
    var matcher: StubMatcher{
        switch self {
        case let .containsFieldName(field, file, line):
            return !stubMatcher({ $0.value(forHTTPHeaderField: field) }, nil, file: file, line: line)
        case let .containsFieldNameWithValue(field, value, file, line):
            return stubMatcher({ $0.value(forHTTPHeaderField: field) }, value, file: file, line: line)
        }
    }
}

extension _Header {
    static func == (lhs: _Header, rhs: _Header) -> Bool {
        switch (lhs, rhs) {
        case let (.containsFieldName(lField, _, _), .containsFieldName(rField, _, _)):
            return lField == rField
        case let (.containsFieldNameWithValue(lField, lValue, _, _), .containsFieldNameWithValue(rField, rValue, _, _)):
            return lField == rField && lValue == rValue
        default: return false
        }
    }
}
