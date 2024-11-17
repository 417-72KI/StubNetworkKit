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
enum _Path: StubCondition {
    case `is`(String, file: StaticString = #file, line: UInt = #line)
    case startsWith(String, file: StaticString = #file, line: UInt = #line)
    case endsWith(String, file: StaticString = #file, line: UInt = #line)
    case matches(String, options: NSRegularExpression.Options = [], file: StaticString = #file, line: UInt = #line)
}

extension _Path {
    var matcher: StubMatcher {
        switch self {
        case let .is(path, file, line):
            stubMatcher({ $0.url?.path }, path, file: file, line: line)
        case let .startsWith(path, file, line):
            stubMatcher({ $0.url?.path.hasPrefix(path) }, true, file: file, line: line)
        case let .endsWith(path, file, line):
            stubMatcher({ $0.url?.path.hasSuffix(path) }, true, file: file, line: line)
        case let .matches(pattern, options, file, line):
            stubMatcher({
                let regex = try! NSRegularExpression(pattern: pattern, options: options)
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
            lPath == rPath
        case let (.startsWith(lPath, _, _), .startsWith(rPath, _, _)):
            lPath == rPath
        case let (.endsWith(lPath, _, _), .endsWith(rPath, _, _)):
            lPath == rPath
        case let (.matches(lPattern, _, _, _), .matches(rPattern, _, _, _)):
            lPattern == rPattern
        default: false
        }
    }
}

extension _Path {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .is(string, _, _):
            hasher.combine("is")
            hasher.combine(string)
        case let .startsWith(string, _, _):
            hasher.combine("startsWith")
            hasher.combine(string)
        case let .endsWith(string, _, _):
            hasher.combine("endsWith")
            hasher.combine(string)
        case let .matches(string, options, _, _):
            hasher.combine("matches")
            hasher.combine(string)
            hasher.combine(options.rawValue)
        }
    }
}
