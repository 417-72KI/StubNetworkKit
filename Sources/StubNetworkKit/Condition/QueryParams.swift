import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum QueryParams: Equatable {}

public extension QueryParams {
    static func contains(_ items: [URLQueryItem],
                         file: StaticString = #file,
                         line: UInt = #line) -> some StubCondition {
        _QueryParams.containsItems(items, file: file, line: line)
    }

    static func contains(_ params: [String: String?],
                         file: StaticString = #file,
                         line: UInt = #line) -> some StubCondition {
        _QueryParams.containsKeysAndValues(params, file: file, line: line)
    }

    static func contains(_ paramNames: [String],
                         file: StaticString = #file,
                         line: UInt = #line) -> some StubCondition {
        _QueryParams.containsKeys(paramNames, file: file, line: line)
    }
}

extension QueryParams {
    static func queryItems(from req: URLRequest,
                           file: StaticString = #file,
                           line: UInt = #line) -> [URLQueryItem]? {
        req.url
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems
    }

    static func keys(from req: URLRequest,
                     file: StaticString = #file,
                     line: UInt = #line) -> [String]? {
        queryItems(from: req).flatMap { $0.map(\.name) }
    }
}

// MARK: -
enum _QueryParams: StubCondition {
    case containsItems([URLQueryItem], file: StaticString = #file, line: UInt = #line)
    case containsKeys([String], file: StaticString = #file, line: UInt = #line)
}

extension _QueryParams {
    static func containsKeysAndValues(_ keysAndValues: [String: String?], file: StaticString = #file, line: UInt = #line) -> Self {
        .containsItems(keysAndValues.map(URLQueryItem.init), file: file, line: line)
    }
}

extension _QueryParams {
    var matcher: StubMatcher {
        switch self {
        case let .containsItems(items, file, line):
            stubMatcher({
                guard let queryItems = queryItems(from: $0) else { return false }
                return items.allSatisfy {
                    guard let queryItem = queryItems.first(forName: $0.name) else { return false }
                    return queryItem.value == $0.value
                }
            }, true, file: file, line: line)
        case let .containsKeys(params, file, line):
            stubMatcher({
                guard let keys = keys(from: $0) else { return false }
                return params.allSatisfy { keys.contains($0) }
            }, true, file: file, line: line)
        }
    }
}

extension _QueryParams {
    static func == (lhs: _QueryParams, rhs: _QueryParams) -> Bool {
        switch (lhs, rhs) {
        case let (.containsItems(lItems, _, _), .containsItems(rItems, _, _)):
            lItems.sorted(by: \.name) == rItems.sorted(by: \.name)
        case let (.containsKeys(lKeys, _, _), .containsKeys(rKeys, _, _)):
            lKeys.sorted() == rKeys.sorted()
        default: false
        }
    }
}

private extension _QueryParams {
    func queryItems(from req: URLRequest,
                    file: StaticString = #file,
                    line: UInt = #line) -> [URLQueryItem]? {
        req.url
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems
    }

    func keys(from req: URLRequest,
              file: StaticString = #file,
              line: UInt = #line) -> [String]? {
        queryItems(from: req).flatMap { $0.map(\.name) }
    }
}

extension _QueryParams {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .containsItems(items, _, _):
            hasher.combine("containsItems")
            hasher.combine(items)
        case let .containsKeys(keys, _, _):
            hasher.combine("containsKeys")
            hasher.combine(keys)
        }
    }
}
