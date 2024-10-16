import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias StubMatcher = @Sendable (URLRequest) -> Bool

let alwaysTrueCondition: StubMatcher = { _ in true }

func stubMatcher<T: Equatable & Sendable>(_ lhs: @escaping @Sendable (URLRequest) -> T,
                               _ rhs: T,
                               file: StaticString = #file,
                               line: UInt = #line) -> StubMatcher {
    {
        dumpCondition(expected: rhs,
                      actual: lhs($0),
                      file: file,
                      line: line)
        return lhs($0) == rhs
    }
}

func stubMatcher(_ lhs: @escaping @Sendable (URLRequest) -> JSONObject?,
                 _ rhs: JSONObject?,
                 file: StaticString = #file,
                 line: UInt = #line) -> StubMatcher {
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

func stubMatcher(_ lhs: @escaping @Sendable (URLRequest) -> JSONArray?,
                 _ rhs: JSONArray?,
                 file: StaticString = #file,
                 line: UInt = #line) -> StubMatcher {
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
