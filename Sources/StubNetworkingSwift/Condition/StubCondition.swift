import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol StubCondition {
    var matcher: StubMatcher { get }
}

public extension StubCondition {
    func matcher(_ url: URL) -> Bool {
        matcher(URLRequest(url: url))
    }
}

// MARK: -
public let alwaysTrue: some StubCondition = {
    _AlwaysTrue()
}()

final class _AlwaysTrue: StubCondition {
    fileprivate init() {}
}

extension _AlwaysTrue {
    var matcher: StubMatcher { { _ in true } }
}

// MARK: -
public let alwaysFalse: some StubCondition = {
    _AlwaysFalse()
}()

final class _AlwaysFalse: StubCondition {
    fileprivate init() {}
}

extension _AlwaysFalse {
    var matcher: StubMatcher { { _ in false } }
}
