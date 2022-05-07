import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol StubConditionType {
    var matcher: StubMatcher { get }
}

public extension StubConditionType {
    func execute(_ req: URLRequest) -> Bool {
        matcher(req)
    }

    func execute(_ url: URL) -> Bool {
        execute(URLRequest(url: url))
    }
}

// MARK: -
public let alwaysTrue: some StubConditionType = {
    _AlwaysTrue()
}()

final class _AlwaysTrue: StubConditionType {
    fileprivate init() {}
}

extension _AlwaysTrue {
    var matcher: StubMatcher { { _ in true } }
}

// MARK: -
public let alwaysFalse: some StubConditionType = {
    _AlwaysFalse()
}()

final class _AlwaysFalse: StubConditionType {
    fileprivate init() {}
}

extension _AlwaysFalse {
    var matcher: StubMatcher { { _ in false } }
}
