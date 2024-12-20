import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum Extension: Equatable {}

public extension Extension {
    static func `is`(_ ext: String,
                     file: StaticString = #file,
                     line: UInt = #line) -> some StubCondition {
        _PathExtension.is(ext, file: file, line: line)
    }
}

// MARK: -
enum _PathExtension: StubCondition {
    case `is`(String, file: StaticString = #file, line: UInt = #line)
}

extension _PathExtension {
    var matcher: StubMatcher {
        switch self {
        case let .is(pathExtension, file, line):
            stubMatcher({ $0.url?.pathExtension }, pathExtension, file: file, line: line)
        }
    }
}

extension _PathExtension {
    static func == (lhs: _PathExtension, rhs: _PathExtension) -> Bool {
        switch (lhs, rhs) {
        case let (.is(lPathExtension, _, _), .is(rPathExtension, _, _)):
            lPathExtension == rPathExtension
        }
    }
}

extension _PathExtension {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .is(value, _, _):
            hasher.combine("is")
            hasher.combine(value)
        }
    }
}
