import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum _PathExtension: StubConditionType {
    case `is`(String, file: StaticString = #file, line: UInt = #line)
}

extension _PathExtension {
    var condition: StubCondition{
        switch self {
        case let .is(pathExtension, file, line):
            return stubCondition({ $0.url?.pathExtension }, pathExtension, file: file, line: line)
        }
    }
}

extension _PathExtension {
    static func == (lhs: _PathExtension, rhs: _PathExtension) -> Bool {
        switch (lhs, rhs) {
        case let (.is(lPathExtension, _, _), .is(rPathExtension, _, _)):
            return lPathExtension == rPathExtension
        }
    }
}
