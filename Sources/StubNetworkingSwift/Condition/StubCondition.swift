import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias StubCondition = (URLRequest) -> Bool

let alwaysTrue: StubCondition = { _ in true }

func stubCondition<T: Equatable>(_ lhs: @escaping (URLRequest) -> T,
                                 _ rhs: T,
                                 file: StaticString = #file,
                                 line: UInt = #line) -> StubCondition {
    {
        dumpCondition(expected: rhs,
                      actual: lhs($0),
                      file: file,
                      line: line)
        return lhs($0) == rhs
    }
}

func stubCondition(_ lhs: @escaping (URLRequest) -> [AnyHashable: Any]?,
                   _ rhs: [AnyHashable: Any]?,
                   file: StaticString = #file,
                   line: UInt = #line) -> StubCondition {
    {
        dumpCondition(expected: rhs,
                      actual: lhs($0),
                      file: file,
                      line: line)
        switch (rhs, lhs($0)) {
        case let (expected?, actual?):
            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            return NSDictionary(dictionary: expected)
                .isEqual(to: actual)
            #else
            // MEMO: In Linux, `NSDictionary.isEqual` returns unexpected result.
            let expected = try? JSONSerialization.data(withJSONObject: expected, options: [.fragmentsAllowed, .withoutEscapingSlashes, .sortedKeys])
            let actual = try? JSONSerialization.data(withJSONObject: actual, options: [.fragmentsAllowed, .withoutEscapingSlashes, .sortedKeys])
            return expected == actual
            #endif
        case (nil, nil):
            return true
        default:
            return false
        }
    }
}

func stubCondition(_ lhs: @escaping (URLRequest) -> [Any]?,
                   _ rhs: [Any]?,
                   file: StaticString = #file,
                   line: UInt = #line) -> StubCondition {
    {
        dumpCondition(expected: rhs,
                      actual: lhs($0),
                      file: file,
                      line: line)
        switch (rhs, lhs($0)) {
        case let (expected?, actual?):
            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            return NSArray(array: expected)
                .isEqual(to: actual)
            #else
            let expected = try? JSONSerialization.data(withJSONObject: expected, options: [.fragmentsAllowed, .withoutEscapingSlashes, .sortedKeys])
            let actual = try? JSONSerialization.data(withJSONObject: actual, options: [.fragmentsAllowed, .withoutEscapingSlashes, .sortedKeys])
            return expected == actual
            #endif
        case (nil, nil):
            return true
        default:
            return false
        }
    }
}
