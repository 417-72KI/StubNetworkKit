import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// An opaque type which represents a stub condition.
public protocol StubCondition: Sendable, Hashable {
    var matcher: StubMatcher { get }
}

public extension StubCondition {
    func matcher(_ url: URL) -> Bool {
        matcher(URLRequest(url: url))
    }
}

extension StubCondition {
    func callAsFunction(_ url: URL) -> Bool {
        matcher(url)
    }
}

// MARK: -
/// A singleton object used to represent a stub-condition which always returns `true`.
public let alwaysTrue: some StubCondition = {
    _AlwaysTrue()
}()

final class _AlwaysTrue: StubCondition {
    fileprivate init() {}
}

extension _AlwaysTrue {
    var matcher: StubMatcher { { _ in true } }
}

extension _AlwaysTrue {
    static func == (lhs: _AlwaysTrue, rhs: _AlwaysTrue) -> Bool {
        true
    }
}

extension _AlwaysTrue {
    func hash(into hasher: inout Hasher) {
        hasher.combine(true)
    }
}

// MARK: -
/// A singleton object used to represent a stub-condition which always returns `false`.
public let alwaysFalse: some StubCondition = {
    _AlwaysFalse()
}()

final class _AlwaysFalse: StubCondition {
    fileprivate init() {}
}

extension _AlwaysFalse {
    var matcher: StubMatcher { { _ in false } }
}

extension _AlwaysFalse {
    static func == (lhs: _AlwaysFalse, rhs: _AlwaysFalse) -> Bool {
        true
    }
}

extension _AlwaysFalse {
    func hash(into hasher: inout Hasher) {
        hasher.combine(false)
    }
}
