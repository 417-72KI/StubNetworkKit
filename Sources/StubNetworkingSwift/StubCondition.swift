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
            return NSDictionary(dictionary: expected)
                .isEqual(to: actual)
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
            return NSArray(array: expected)
                .isEqual(to: actual)
        case (nil, nil):
            return true
        default:
            return false
        }
    }
}

// MARK: - Method

public enum Method: Equatable {
    case get
    case post
    case put
    case patch
    case delete
    case head
}

extension Method: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        switch value.lowercased() {
        case "get": self = .get
        case "post": self = .post
        case "put": self = .put
        case "patch": self = .patch
        case "delete": self = .delete
        case "head": self = .head
        default: fatalError("Unexpected method: \(value)")
        }
    }
}

public extension Method {
    static func isGet(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .get, file: file, line: line)
    }
    static func isPost(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .post, file: file, line: line)
    }
    static func isPut(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .put, file: file, line: line)
    }
    static func isPatch(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .patch, file: file, line: line)
    }
    static func isDelete(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .delete, file: file, line: line)
    }
    static func isHead(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpMethod.flatMap(Self.init) }, .head, file: file, line: line)
    }
}

extension Method {
    func condition(file: StaticString = #file, line: UInt = #line) -> StubCondition {
        switch self {
        case .get: return Method.isGet(file: file, line: line)
        case .post: return Method.isPost(file: file, line: line)
        case .put: return Method.isPut(file: file, line: line)
        case .patch: return Method.isPatch(file: file, line: line)
        case .delete: return Method.isDelete(file: file, line: line)
        case .head: return Method.isHead(file: file, line: line)
        }
    }
}

// MARK: - Components
public enum Scheme {
    public static func `is`(_ scheme: String,
                            file: StaticString = #file,
                            line: UInt = #line) -> StubCondition {
        precondition(!scheme.contains("://"), "The scheme part of an URL never contains '://'.", file: file, line: line)
        precondition(!scheme.contains("/"), "The scheme part of an URL never contains any slash.", file: file, line: line)
        return stubCondition({ $0.url?.scheme }, scheme, file: file, line: line)
    }
}

public enum Host {
    public static func `is`(_ host: String,
                            file: StaticString = #file,
                            line: UInt = #line) -> StubCondition {
        precondition(!host.contains("/"), "The host part of an URL never contains any slash.", file: file, line: line)
        return stubCondition({ $0.url?.host }, host, file: file, line: line)
    }
}

public enum Path {
    public static func `is`(_ path: String,
                            file: StaticString = #file,
                            line: UInt = #line) -> StubCondition {
        stubCondition({ $0.url?.path }, path, file: file, line: line)
    }

    public static func startsWith(_ path: String,
                                  file: StaticString = #file,
                                  line: UInt = #line) -> StubCondition {
        stubCondition({ $0.url?.path.hasPrefix(path) }, true, file: file, line: line)
    }

    public static func endsWith(_ path: String,
                                file: StaticString = #file,
                                line: UInt = #line) -> StubCondition {
        stubCondition({ $0.url?.path.hasSuffix(path) }, true, file: file, line: line)
    }

    public static func matches(_ regex: NSRegularExpression,
                               file: StaticString = #file,
                               line: UInt = #line) -> StubCondition {

        stubCondition({
            guard let path = $0.url?.path,
                  let _ = regex.firstMatch(in: path, range: .init(location: 0, length: path.utf16.count)) else { return false }
            return true
        }, true, file: file, line: line)
    }

    public static func matches(_ pattern: String,
                               options: NSRegularExpression.Options = [],
                               file: StaticString = #file,
                               line: UInt = #line) -> StubCondition {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            return matches(regex, file: file, line: line)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

public enum Extension {
    public static func `is`(_ ext: String,
                            file: StaticString = #file,
                            line: UInt = #line) -> StubCondition {
        stubCondition({ $0.url?.pathExtension }, ext, file: file, line: line)
    }
}

public enum QueryParams {
    public static func contains(_ params: [URLQueryItem],
                                file: StaticString = #file,
                                line: UInt = #line) -> StubCondition {
        stubCondition({
            guard let queryItems = queryItems(from: $0) else { return false }
            return params.allSatisfy {
                guard let queryItem = queryItems.first(forName: $0.name) else { return false }
                return queryItem.value == $0.value
            }
        }, true, file: file, line: line)
    }

    public static func contains(_ params: [String: String?],
                                file: StaticString = #file,
                                line: UInt = #line) -> StubCondition {
        contains(params.map(URLQueryItem.init), file: file, line: line)
    }

    public static func contains(_ paramNames: [String],
                                file: StaticString = #file,
                                line: UInt = #line) -> StubCondition {
        stubCondition({
            guard let keys = keys(from: $0) else { return false }
            return paramNames.allSatisfy { keys.contains($0) }
        }, true, file: file, line: line)
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

public enum Header {
    public static func contains(_ name: String,
                                file: StaticString = #file,
                                line: UInt = #line) -> StubCondition {
        !stubCondition({ $0.value(forHTTPHeaderField: name) }, nil, file: file, line: line)
    }

    public static func contains(_ name: String,
                                withValue value: String,
                                file: StaticString = #file,
                                line: UInt = #line) -> StubCondition {
        stubCondition({ $0.value(forHTTPHeaderField: name) }, value, file: file, line: line)
    }
}

public enum Body {
    public static func `is`(_ body: Data,
                            file: StaticString = #file,
                            line: UInt = #line) -> StubCondition {
        stubCondition({ $0.httpBody }, body, file: file, line: line)
    }

    public static func isJson(_ jsonObject: [AnyHashable: Any],
                              file: StaticString = #file,
                              line: UInt = #line) -> StubCondition {
        stubCondition({
            guard let httpBody = $0.httpBody,
                  let jsonBody = try? JSONSerialization.jsonObject(with: httpBody) as? [AnyHashable: Any] else { return nil }
            return jsonBody
        }, jsonObject, file: file, line: line)
    }

    public static func isJson(_ jsonArray: [Any],
                              file: StaticString = #file,
                              line: UInt = #line) -> StubCondition {
        stubCondition({
            guard let httpBody = $0.httpBody,
                  let jsonBody = try? JSONSerialization.jsonObject(with: httpBody) as? [Any] else { return nil }
            return jsonBody
        }, jsonArray, file: file, line: line)
    }

    public static func isForm(_ queryItems: [URLQueryItem], file: StaticString = #file, line: UInt = #line) -> StubCondition {
        Header.contains("Content-Type",
                        withValue: "application/x-www-form-urlencoded",
                        file: file,
                        line: line)
        && stubCondition({
            guard let query = $0.httpBody
                .flatMap({ String(data: $0, encoding: .utf8) }) else { return [] }
            let items: [URLQueryItem] = {
                var comps = URLComponents()
                comps.percentEncodedQuery = query
                return comps.queryItems ?? []
            }()
            return items.sorted(by: \.name)
        }, queryItems.sorted(by: \.name), file: file, line: line)
    }

    public static func isForm(_ params: [String: String?], file: StaticString = #file, line: UInt = #line) -> StubCondition {
        isForm(params.map(URLQueryItem.init), file: file, line: line)
    }

    public static func isForm(_ queryItems: URLQueryItem..., file: StaticString = #file, line: UInt = #line) -> StubCondition {
        isForm(queryItems, file: file, line: line)
    }
}
