import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum Path: Equatable {}

public extension Path {
    static func `is`(_ path: String,
                     file: StaticString = #file,
                     line: UInt = #line) -> some StubCondition {
        _Path.is(path, file: file, line: line)
    }

    static func startsWith(_ path: String,
                           file: StaticString = #file,
                           line: UInt = #line) -> some StubCondition {
        _Path.startsWith(path, file: file, line: line)
    }

    static func endsWith(_ path: String,
                         file: StaticString = #file,
                         line: UInt = #line) -> some StubCondition {
        _Path.endsWith(path, file: file, line: line)
    }

    static func matches(_ pattern: String,
                        options: NSRegularExpression.Options = [],
                        file: StaticString = #file,
                        line: UInt = #line) -> some StubCondition {
        _Path.matches(pattern, options: options, file: file, line: line)
    }
}

// MARK: -
private enum _Path: StubCondition {
    case `is`(String, file: StaticString = #file, line: UInt = #line)
    case startsWith(String, file: StaticString = #file, line: UInt = #line)
    case endsWith(String, file: StaticString = #file, line: UInt = #line)
    case matches(String, options: NSRegularExpression.Options = [], file: StaticString = #file, line: UInt = #line)
}

extension _Path {
    var matcher: StubMatcher{
        switch self {
        case let .is(path, file, line):
            return stubMatcher({ $0.url?.path }, path, file: file, line: line)
        case let .startsWith(path, file, line):
            return stubMatcher({ $0.url?.path.hasPrefix(path) }, true, file: file, line: line)
        case let .endsWith(path, file, line):
            return stubMatcher({ $0.url?.path.hasSuffix(path) }, true, file: file, line: line)
        case let .matches(pattern, options, file, line):
            let regex = try! NSRegularExpression(pattern: pattern, options: options)
            return stubMatcher({
                guard let path = $0.url?.path,
                      let _ = regex.firstMatch(in: path, range: .init(location: 0, length: path.utf16.count)) else { return false }
                return true
            }, true, file: file, line: line)
        }
    }
}

extension _Path {
    static func == (lhs: _Path, rhs: _Path) -> Bool {
        switch (lhs, rhs) {
        case let (.is(lPath, _, _), .is(rPath, _, _)):
            return lPath == rPath
        case let (.startsWith(lPath, _, _), .startsWith(rPath, _, _)):
            return lPath == rPath
        case let (.endsWith(lPath, _, _), .endsWith(rPath, _, _)):
            return lPath == rPath
        case let (.matches(lPattern, _, _, _), .matches(rPattern, _, _, _)):
            return lPattern == rPattern
        default: return false
        }
    }
}
