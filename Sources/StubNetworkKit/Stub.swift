import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class Stub: @unchecked Sendable {
    typealias Response = @Sendable (URLRequest) -> StubResponse

    /// Matcher to judge if use stub response.
    private(set) var matcher: StubMatcher
    /// Stub response to return.
    private(set) var response: Response

    init(matcher: @escaping StubMatcher = alwaysTrueCondition,
         response: @escaping Response = errorResponse(.unimplemented)) {
        self.matcher = matcher
        self.response = response
    }
}

extension Stub {
    convenience init(condition: any StubCondition = alwaysTrue,
                     response: @escaping Response = errorResponse(.unimplemented)) {
        self.init(matcher: condition.matcher, response: response)
    }
}

// MARK: - Basic builder
/// Create and register new stub.
/// - Parameters:
///   - matcher: Matcher to judge if use stub response.
///   - stubResponse: Stub response to return
/// - Returns: Created stub object.
@discardableResult
public func stub(_ matcher: @escaping StubMatcher,
                 withResponse stubResponse: @escaping @Sendable (URLRequest) -> StubResponse) -> Stub {
    let stub = Stub(matcher: matcher,
                    response: stubResponse)
    StubURLProtocol.register(stub)
    return stub
}

/// Create and register new stub.
///
/// Note that response is unregistered, and needs calling `.responseData/Json`.
/// - Parameters:
///   - matcher: Matcher to judge if use stub response.
/// - Returns: Created stub object.
@discardableResult
public func stub(_ matcher: @escaping StubMatcher) -> Stub {
    stub(matcher, withResponse: errorResponse(.unimplemented))
}

/// Create and register new stub.
/// - Parameters:
///   - matcher: Matcher to judge if use stub response.
///   - stubResponse: Stub response to return
/// - Returns: Created stub object.
@discardableResult
public func stub(_ condition: any StubCondition,
                 withResponse stubResponse: @escaping @Sendable (URLRequest) -> StubResponse) -> Stub {
    let stub = Stub(matcher: condition.matcher,
                    response: stubResponse)
    StubURLProtocol.register(stub)
    return stub
}

/// Create and register new stub.
///
/// Note that response is unregistered, and needs calling `.responseData/Json`.
/// - Parameters:
///   - matcher: Matcher to judge if use stub response.
/// - Returns: Created stub object.
@discardableResult
public func stub(_ condition: any StubCondition) -> Stub {
    stub(condition, withResponse: errorResponse(.unimplemented))
}

/// Clear all registered stubs.
public func clearStubs() {
    StubURLProtocol.reset()
}

// MARK: - Method chain builders
/// Create and register new stub.
/// - Parameters:
///   - url: URL to match
///   - method: Method to match
/// - Returns: created stub object.
@discardableResult
public func stub(url: URL? = nil,
                 method: Method? = nil,
                 file: StaticString = #file,
                 line: UInt = #line) -> Stub {
    let condition = stubCondition {
        if let url = url {
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let scheme = comps?.scheme {
                Scheme.is(scheme, file: file, line: line)
            }
            if let host = comps?.host {
                Host.is(host, file: file, line: line)
            }
            if let path = comps?.path {
                Path.is(path, file: file, line: line)
            }
            if let queryItems = comps?.queryItems {
                QueryParams.contains(queryItems, file: file, line: line)
            }
        }
        if let method = method {
            method.condition(file: file, line: line)
        }
    }
    let stub = Stub(condition: condition)
    StubURLProtocol.register(stub)
    return stub
}

/// Create and register new stub.
/// - Parameters:
///   - url: URL string to match
///   - method: Method to match
/// - Returns: created stub object.
@discardableResult
public func stub(url: String,
                 method: Method? = nil,
                 file: StaticString = #file,
                 line: UInt = #line) -> Stub {
    stub(url: URL(string: url), method: method, file: file, line: line)
}

// MARK: Scheme
public extension Stub {
    /// Add scheme matcher.
    /// - Parameters:
    ///   - scheme: Scheme to match
    /// - Returns: self
    @discardableResult
    func scheme(_ scheme: String,
                file: StaticString = #file,
                line: UInt = #line) -> Self {
        matcher &&= Scheme.is(scheme, file: file, line: line).matcher
        return self
    }
}

// MARK: Host
public extension Stub {
    /// Add host matcher.
    /// - Parameters:
    ///   - host: Host to match
    /// - Returns: self
    @discardableResult
    func host(_ host: String,
              file: StaticString = #file,
              line: UInt = #line) -> Self {
        matcher &&= Host.is(host, file: file, line: line).matcher
        return self
    }
}

// MARK: Path
public extension Stub {
    /// Add path matcher.
    /// - Parameters:
    ///   - path: Path to match
    /// - Returns: self
    @discardableResult
    func path(_ path: String,
              file: StaticString = #file,
              line: UInt = #line) -> Self {
        matcher &&= Path.is(path, file: file, line: line).matcher
        return self
    }
}

// MARK: PathExtension
public extension Stub {
    /// Add path extension (e.g. `.json`, `.png`) matcher.
    /// - Parameters:
    ///   - ext: Path extension to match
    /// - Returns: self
    @discardableResult
    func pathExtension(_ ext: String,
                       file: StaticString = #file,
                       line: UInt = #line) -> Self {
        matcher &&= Extension.is(ext, file: file, line: line).matcher
        return self
    }
}

// MARK: Method
public extension Stub {
    /// Add method matcher.
    /// - Parameters:
    ///   - method: Method to match
    /// - Returns: self
    @discardableResult
    func method(_ method: Method,
                file: StaticString = #file,
                line: UInt = #line) -> Self {
        matcher &&= method.condition(file: file, line: line).matcher
        return self
    }
}

// MARK: QueryParams
public extension Stub {
    /// Add query params matcher.
    /// - Parameters:
    ///   - queryParams: Name-value pairs to match
    /// - Returns: self
    @discardableResult
    func queryParams(_ queryParams: [String: String?],
                     file: StaticString = #file,
                     line: UInt = #line) -> Self {
        matcher &&= QueryParams.contains(queryParams, file: file, line: line).matcher
        return self
    }

    /// Add query params matcher.
    /// - Parameters:
    ///   - queryItems: `URLQueryItem` list to match
    /// - Returns: self
    @discardableResult
    func queryItems(_ queryItems: [URLQueryItem],
                    file: StaticString = #file,
                    line: UInt = #line) -> Self {
        matcher &&= QueryParams.contains(queryItems, file: file, line: line).matcher
        return self
    }

    /// Add query params matcher.
    ///
    /// This matcher only tests if param-names exist.
    /// - Parameters:
    ///   - host: Param names to match
    /// - Returns: self
    @discardableResult
    func queryParams(_ queryParams: [String],
                     file: StaticString = #file,
                     line: UInt = #line) -> Self {
        matcher &&= QueryParams.contains(queryParams, file: file, line: line).matcher
        return self
    }
}

// MARK: Header
public extension Stub {
    @discardableResult
    func header(_ name: String,
                file: StaticString = #file,
                line: UInt = #line) -> Self {
        matcher &&= Header.contains(name, file: file, line: line).matcher
        return self
    }

    @discardableResult
    func header(_ name: String,
                value: String,
                file: StaticString = #file,
                line: UInt = #line) -> Self {
        matcher &&= Header.contains(name, withValue: value, file: file, line: line).matcher
        return self
    }
}

// MARK: Body
@available(watchOS, unavailable, message: "Intercepting POST request is not available in watchOS")
public extension Stub {
    @discardableResult
    func body(_ body: Data,
              file: StaticString = #file,
              line: UInt = #line) -> Self {
        matcher &&= Body.is(body, file: file, line: line).matcher
        return self
    }

    @discardableResult
    func jsonBody(_ jsonObject: JSONObject,
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        matcher &&= Body.isJson(jsonObject, file: file, line: line).matcher
        return self
    }

    @discardableResult
    func jsonBody(_ jsonArray: JSONArray,
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        matcher &&= Body.isJson(jsonArray, file: file, line: line).matcher
        return self
    }

    @discardableResult
    func formBody(_ queryItems: [URLQueryItem],
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        matcher &&= Body.isForm(queryItems, file: file, line: line).matcher
        return self
    }

    @discardableResult
    func formBody(_ queryItems: [String: String?],
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        matcher &&= Body.isForm(queryItems, file: file, line: line).matcher
        return self
    }

    @discardableResult
    func formBody(_ queryItems: URLQueryItem...,
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        formBody(queryItems, file: file, line: line)
    }
}

// MARK: - Return values
public extension Stub {
    @discardableResult
    func responseData(_ data: Data, statusCode: Int = 200, headers: [String: String]? = nil) -> Self {
        response = successResponse(data, statusCode: statusCode, headers: headers)
        return self
    }

    @discardableResult
    func responseJson(_ jsonObject: JSONObject, statusCode: Int = 200) -> Self {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject,
                                                  options: .sortedKeys)
            response = successResponse(data,
                                       statusCode: statusCode,
                                       headers: ["Content-Type": "application/json"])

        } catch {
            response = errorResponse(.unexpectedError(error))
        }
        return self
    }

    @discardableResult
    func responseJson(_ jsonArray: JSONArray, statusCode: Int = 200) -> Self {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray,
                                                  options: .sortedKeys)
            response = successResponse(data,
                                       statusCode: statusCode,
                                       headers: ["Content-Type": "application/json"])

        } catch {
            response = errorResponse(.unexpectedError(error))
        }
        return self
    }

    @discardableResult
    func responseData(withFilePath filePath: String,
                      extension ext: String? = nil,
                      in bundle: Bundle = .main,
                      headers: [String: String]? = nil) -> Self {
        let url = StubResponse.url(forResource: filePath,
                                   withExtension: ext,
                                   in: bundle)
        do {
            let data = try Data(contentsOf: url)
            response = successResponse(data)
        } catch {
            response = errorResponse(.unexpectedError(error))
        }
        return self
    }
}

// MARK: -
func successResponse(_ data: Data?, statusCode: Int = 200, headers: [String: String]? = nil) -> Stub.Response {
    { _ in .success(data: data, statusCode: statusCode, headers: headers) }
}

func errorResponse(_ error: StubError) -> Stub.Response {
    { _ in .failure(error) }
}
