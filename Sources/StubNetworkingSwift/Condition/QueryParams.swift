import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum _QueryParams: StubConditionType {
    case containsItems([URLQueryItem], file: StaticString = #file, line: UInt = #line)
    case containsKeys([String], file: StaticString = #file, line: UInt = #line)
}

extension _QueryParams {
    static func containsKeysAndValues(_ keysAndValues: [String: String?], file: StaticString = #file, line: UInt = #line) -> Self {
        .containsItems(keysAndValues.map(URLQueryItem.init), file: file, line: line)
    }
}

extension _QueryParams {
    var condition: StubCondition{
        switch self {
        case let .containsItems(items, file, line):
            return stubCondition({
                guard let queryItems = queryItems(from: $0) else { return false }
                return items.allSatisfy {
                    guard let queryItem = queryItems.first(forName: $0.name) else { return false }
                    return queryItem.value == $0.value
                }
            }, true, file: file, line: line)
        case let .containsKeys(params, file, line):
            return stubCondition({
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
            return lItems.sorted(by: \.name) == rItems.sorted(by: \.name)
        case let (.containsKeys(lKeys, _, _), .containsKeys(rKeys, _, _)):
            return lKeys.sorted() == rKeys.sorted()
        default: return false
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
