import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum Body: Equatable {}

public extension Body {
    static func `is`(_ body: Data,
                     file: StaticString = #file,
                     line: UInt = #line) -> some StubConditionType {
        _Body.isData(body, file: file, line: line)
    }

    static func isJson(_ jsonObject: [AnyHashable: Any],
                       file: StaticString = #file,
                       line: UInt = #line) -> some StubConditionType {
        _Body.isJsonObject(jsonObject, file: file, line: line)
    }

    static func isJson(_ jsonArray: [Any],
                       file: StaticString = #file,
                       line: UInt = #line) -> some StubConditionType {
        _Body.isJsonArray(jsonArray)
    }

    static func isForm(_ queryItems: [URLQueryItem], file: StaticString = #file, line: UInt = #line) -> some StubConditionType {
        _Body.isForm(queryItems, file: file, line: line)
    }

    static func isForm(_ params: [String: String?], file: StaticString = #file, line: UInt = #line) -> some StubConditionType {
        _Body.isForm(params, file: file, line: line)
    }

    static func isForm(_ queryItems: URLQueryItem..., file: StaticString = #file, line: UInt = #line) -> some StubConditionType {
        _Body.isForm(queryItems, file: file, line: line)
    }
}

// MARK: -
enum _Body: StubConditionType {
    case isData(Data, file: StaticString = #file, line: UInt = #line)
    case isJsonObject([AnyHashable: Any], file: StaticString = #file, line: UInt = #line)
    case isJsonArray([Any], file: StaticString = #file, line: UInt = #line)
    case isForm([URLQueryItem], file: StaticString = #file, line: UInt = #line)
}

extension _Body {
    static func isForm(_ paramsAndValues: [String: String?], file: StaticString = #file, line: UInt = #line) -> Self {
        .isForm(paramsAndValues.map(URLQueryItem.init), file: file, line: line)
    }

    static func isForm(_ queryItems: URLQueryItem..., file: StaticString = #file, line: UInt = #line) -> Self {
        isForm(queryItems, file: file, line: line)
    }
}

extension _Body {
    var matcher: StubMatcher {
        switch self {
        case let .isData(body, file, line):
            return stubMatcher({ $0.httpBody }, body, file: file, line: line)
        case let .isJsonObject(jsonObject, file, line):
            return stubMatcher({
                guard let httpBody = $0.httpBody,
                      let jsonBody = try? JSONSerialization.jsonObject(with: httpBody) as? [AnyHashable: Any] else { return nil }
                return jsonBody
            }, jsonObject, file: file, line: line)
        case let .isJsonArray(jsonArray, file, line):
            return stubMatcher({
                guard let httpBody = $0.httpBody,
                      let jsonBody = try? JSONSerialization.jsonObject(with: httpBody) as? [Any] else { return nil }
                return jsonBody
            }, jsonArray, file: file, line: line)
        case let .isForm(queryItems, file, line):
            return stubMatcher({ $0.formBody?.sorted(by: \.name) }, queryItems.sorted(by: \.name), file: file, line: line)
        }
    }
}

extension _Body {
    static func == (lhs: _Body, rhs: _Body) -> Bool {
        switch (lhs, rhs) {
        case let (.isData(lData, _, _), .isData(rData, _, _)):
            return lData == rData
        case let (.isJsonObject(lJson, _, _), .isJsonObject(rJson, _, _)):
            return NSDictionary(dictionary: lJson)
                .isEqual(to: rJson)
        case let (.isJsonArray(lJson, _, _), .isJsonArray(rJson, _, _)):
            return NSArray(array: lJson)
                .isEqual(to: rJson)
        case let (.isForm(lItems, _, _), .isForm(rItems, _, _)):
            return lItems.sorted(by: \.name) == rItems.sorted(by: \.name)
        default: return false
        }
    }
}

// MARK: -
private extension URLRequest {
    var formBody: [URLQueryItem]? {
        guard case "application/x-www-form-urlencoded" = value(forHTTPHeaderField: "Content-Type") else { return nil }
        guard let query = httpBody
            .flatMap({ String(data: $0, encoding: .utf8) }) else { return nil }
        var comps = URLComponents()
        comps.percentEncodedQuery = query
        return comps.queryItems
    }
}
