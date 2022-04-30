import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class Stub {
    typealias Response = (URLRequest) -> StubResponse

    private(set) var condition: StubCondition
    private(set) var response: Response

    init(condition: @escaping StubCondition = alwaysTrue,
         response: @escaping Response = errorResponse(.unimplemented)) {
        self.condition = condition
        self.response = response
    }
}

// MARK: - Method chain builders
@discardableResult
public func stub(url: URL? = nil, method: Method? = nil) -> Stub {
    let condition = stub {
        if let url = url {
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let scheme = comps?.scheme {
                Scheme.is(scheme)
            }
            if let host = comps?.host {
                Host.is(host)
            }
            if let path = comps?.path {
                Path.is(path)
            }
            if let queryItems = comps?.queryItems {
                QueryParams.contains(queryItems)
            }
        }
        if let method = method {
            method.condition
        }
    }
    return Stub(condition: condition)
}

@discardableResult
public func stub(urlString: String? = nil, method: Method? = nil) -> Stub {
    stub(url: urlString.flatMap(URL.init), method: method)
}

// MARK: Scheme
public extension Stub {
    @discardableResult
    func scheme(_ scheme: String) -> Self {
        condition &&= Scheme.is(scheme)
        return self
    }
}

// MARK: Host
public extension Stub {
    @discardableResult
    func host(_ host: String) -> Self {
        condition &&= Host.is(host)
        return self
    }
}

// MARK: Path
public extension Stub {
    @discardableResult
    func path(_ path: String) -> Self {
        condition &&= Path.is(path)
        return self
    }
}

// MARK: PathExtension
public extension Stub {
    @discardableResult
    func pathExtension(_ ext: String) -> Self {
        condition &&= Extension.is(ext)
        return self
    }
}

// MARK: Method
public extension Stub {
    @discardableResult
    func method(_ method: Method) -> Self {
        condition &&= method.condition
        return self
    }
}

// MARK: QueryParams
public extension Stub {
    @discardableResult
    func queryParamsAndValues(_ queryParams: [String: String?]) -> Self {
        condition &&= QueryParams.contains(queryParams)
        return self
    }

    @discardableResult
    func queryItems(_ queryItems: [URLQueryItem]) -> Self {
        condition &&= QueryParams.contains(queryItems)
        return self
    }

    @discardableResult
    func queryParams(_ queryParams: [String]) -> Self {
        condition &&= QueryParams.contains(queryParams)
        return self
    }
}

// MARK: Header
public extension Stub {
    @discardableResult
    func header(_ name: String) -> Self {
        condition &&= Header.contains(name)
        return self
    }

    @discardableResult
    func header(_ name: String, value: String) -> Self {
        condition &&= Header.contains(name, withValue: value)
        return self
    }
}

// MARK: Body
public extension Stub {
    @discardableResult
    func body(_ body: Data) -> Self {
        condition &&= Body.is(body)
        return self
    }

    @discardableResult
    func jsonBody(_ jsonObject: [AnyHashable: Any]) -> Self {
        condition &&= Body.isJson(jsonObject)
        return self
    }

    @discardableResult
    func jsonBody(_ jsonArray: [Any]) -> Self {
        condition &&= Body.isJson(jsonArray)
        return self
    }

    @discardableResult
    func formBody(_ queryItems: [URLQueryItem]) -> Self {
        condition &&= Body.isForm(queryItems)
        return self
    }

    @discardableResult
    func formBody(_ queryItems: [String: String?]) -> Self {
        condition &&= Body.isForm(queryItems)
        return self
    }

    @discardableResult
    func formBody(_ queryItems: URLQueryItem...) -> Self {
        formBody(queryItems)
    }
}

// MARK: -
func errorResponse(_ error: StubError) -> Stub.Response {
    { _ in .failure(error) }
}
