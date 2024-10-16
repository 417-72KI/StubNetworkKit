import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum Scheme: Equatable {}

public extension Scheme {
    static func `is`(_ scheme: String,
                     file: StaticString = #file,
                     line: UInt = #line) -> some StubCondition {
        _Scheme.is(scheme, file: file, line: line)
    }
}

// MARK: -
private enum _Scheme: StubCondition {
    case `is`(String, file: StaticString = #file, line: UInt = #line)
}

extension _Scheme {
    var matcher: StubMatcher{
        switch self {
        case let .is(scheme, file, line):
            precondition(!scheme.contains("://"), "The scheme part of an URL never contains '://'.", file: file, line: line)
            precondition(!scheme.contains("/"), "The scheme part of an URL never contains any slash.", file: file, line: line)
            return stubMatcher({ $0.url?.scheme }, scheme, file: file, line: line)
        }
    }
}

extension _Scheme {
    static func == (lhs: _Scheme, rhs: _Scheme) -> Bool {
        switch (lhs, rhs) {
        case let (.is(lScheme, _, _), .is(rScheme, _, _)):
            return lScheme == rScheme
        }
    }
}
