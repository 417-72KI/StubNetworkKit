import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias StubCondition = (URLRequest) -> Bool

let alwaysTrue: StubCondition = { _ in true }

// MARK: - Method

public enum Method {
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
    static var isGet: StubCondition {
        { $0.httpMethod.flatMap(Self.init) == .get }
    }
    static var isPost: StubCondition {
        { $0.httpMethod.flatMap(Self.init) == .post }
    }
    static var isPut: StubCondition {
        { $0.httpMethod.flatMap(Self.init) == .put }
    }
    static var isPatch: StubCondition {
        { $0.httpMethod.flatMap(Self.init) == .patch }
    }
    static var isDelete: StubCondition {
        { $0.httpMethod.flatMap(Self.init) == .delete }
    }
    static var isHead: StubCondition {
        { $0.httpMethod.flatMap(Self.init) == .head }
    }
}

extension Method {
    var condition: StubCondition {
        switch self {
        case .get: return Method.isGet
        case .post: return Method.isPost
        case .put: return Method.isPut
        case .patch: return Method.isPatch
        case .delete: return Method.isDelete
        case .head: return Method.isHead
        }
    }
}

// MARK: - Components
public enum Scheme {
    public static func `is`(_ scheme: String, file: StaticString = #file, line: UInt = #line) -> StubCondition {
        precondition(!scheme.contains("://"), "The scheme part of an URL never contains '://'.", file: file, line: line)
        precondition(!scheme.contains("/"), "The scheme part of an URL never contains any slash.", file: file, line: line)
        return { $0.url?.scheme == scheme }
    }
}

public enum Host {
    public static func `is`(_ host: String, file: StaticString = #file, line: UInt = #line) -> StubCondition {
        precondition(!host.contains("/"), "The host part of an URL never contains any slash.", file: file, line: line)
        return { $0.url?.host == host }
    }
}

public enum Path {
    public static func `is`(_ path: String) -> StubCondition {
        { $0.url?.path == path }
    }

    public static func startsWith(_ path: String) -> StubCondition {
        { $0.url?.path.hasPrefix(path) ?? false }
    }

    public static func endsWith(_ path: String) -> StubCondition {
        { $0.url?.path.hasSuffix(path) ?? false }
    }

    public static func matches(_ regex: NSRegularExpression) -> StubCondition {
        {
            guard let path = $0.url?.path,
                  let _ = regex.firstMatch(in: path, range: .init(location: 0, length: path.utf16.count)) else { return false }
            return true
        }
    }

    public static func matches(_ pattern: String, options: NSRegularExpression.Options = []) -> StubCondition {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            return matches(regex)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

public enum Extension {
    public static func `is`(_ ext: String) -> StubCondition {
        { $0.url?.pathExtension == ext }
    }
}

public enum QueryParams {
    public static func contains(_ params: [URLQueryItem]) -> StubCondition {
        {
            guard let queryItems = queryItems(from: $0) else { return false }
            return params.allSatisfy { queryItems.first(forName: $0.name)?.value == $0.value }
        }
    }

    public static func contains(_ params: [String: String?]) -> StubCondition {
        contains(params.map(URLQueryItem.init))
    }

    public static func contains(_ paramNames: [String]) -> StubCondition {
        {
            guard let keys = keys(from: $0) else { return false }
            return paramNames.allSatisfy { keys.contains($0) }
        }
    }
}

extension QueryParams {
    static func queryItems(from req: URLRequest) -> [URLQueryItem]? {
        req.url
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems
    }

    static func keys(from req: URLRequest) -> [String]? {
        queryItems(from: req).flatMap { $0.map(\.name) }
    }
}

public enum Header {
    public static func contains(_ name: String) -> StubCondition {
        { $0.value(forHTTPHeaderField: name) != nil }
    }

    public static func contains(_ name: String, withValue value: String) -> StubCondition {
        { $0.value(forHTTPHeaderField: name) == value }
    }
}

public enum Body {
    public static func `is`(_ body: Data) -> StubCondition {
        { $0.httpBody == body }
    }

    public static func isJson(_ jsonObject: [AnyHashable: Any]) -> StubCondition {
        {
            guard let httpBody = $0.httpBody,
                  let jsonBody = try? JSONSerialization.jsonObject(with: httpBody) as? [AnyHashable: Any] else { return false }
            return NSDictionary(dictionary: jsonBody)
                .isEqual(to: jsonObject)
        }
    }

    public static func isJson(_ jsonArray: [Any]) -> StubCondition {
        {
            guard let httpBody = $0.httpBody,
                  let jsonBody = try? JSONSerialization.jsonObject(with: httpBody) as? [Any] else { return false }
            return NSArray(array: jsonBody)
                .isEqual(to: jsonArray)
        }
    }

    public static func isForm(_ queryItems: [URLQueryItem]) -> StubCondition {
        Header.contains("Content-Type",
                        withValue: "application/x-www-form-urlencoded")
        && {
            guard let query = $0.httpBody
                .flatMap({ String(data: $0, encoding: .utf8) }) else { return false }
            let items: [URLQueryItem] = {
                var comps = URLComponents()
                comps.percentEncodedQuery = query
                return comps.queryItems ?? []
            }()
            return queryItems.sorted(by: \.name) == items.sorted(by: \.name)
        }
    }

    public static func isForm(_ params: [String: String?]) -> StubCondition {
        isForm(params.map(URLQueryItem.init))
    }

    public static func isForm(_ queryItems: URLQueryItem...) -> StubCondition {
        isForm(queryItems)
    }
}
