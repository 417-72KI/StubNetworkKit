import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum Host: Equatable {}

public extension Host {
    static func `is`(_ host: String,
                     file: StaticString = #file,
                     line: UInt = #line) -> some StubCondition {
        _Host.is(host, file: file, line: line)
    }
}

// MARK: -
enum _Host: StubCondition {
    case `is`(String, file: StaticString = #file, line: UInt = #line)
}

extension _Host {
    var matcher: StubMatcher{
        switch self {
        case let .is(host, file, line):
            precondition(!host.contains("/"), "The host part of an URL never contains any slash.", file: file, line: line)
            return stubMatcher({ $0.url?.host }, host, file: file, line: line)
        }
    }
}

extension _Host {
    static func == (lhs: _Host, rhs: _Host) -> Bool {
        switch (lhs, rhs) {
        case let (.is(lHost, _, _), .is(rHost, _, _)):
            return lHost == rHost
        }
    }
}
