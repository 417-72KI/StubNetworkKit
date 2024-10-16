import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
import StubNetworkKit

@Suite struct StubCondition_ResultBuilderTests {
    #if !os(watchOS)
    @Test
    func build() throws {
        var req = URLRequest(url: .init(string: "https://foo.bar/baz?q=1&flag")!)
        req.httpMethod = "POST"

        let condition = stubCondition {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz")
            Method.isPost()
            QueryParams.contains(["q": "1", "flag": nil])
        }
        #expect(condition.matcher(req))

        #expect(!condition.matcher(URL(fileURLWithPath: "/foo/bar")))
    }
    #endif

    @Test func buildOptional() throws {
        let comps = URLComponents(string: "https://foo.bar/baz?q=1&flag")
        let req = URLRequest(url: comps!.url!)

        let condition = stubCondition {
            if let scheme = comps?.scheme {
                Scheme.is(scheme)
            }
            if let host = comps?.host {
                Host.is(host)
            }
            if let path = comps?.path {
                Path.is(path)
            }
            Method.isGet()
            if let queryItems = comps?.queryItems {
                QueryParams.contains(queryItems)
            }
        }
        #expect(condition.matcher(req))
    }

    #if !os(watchOS)
    @Test(arguments: [
        ("GET", true),
        ("POST", true),
        ("PUT", true),
        ("PATCH", true),
        ("DELETE", true),
        ("HEAD", true),
        ("Invalid method", false),
    ])
    func buildEither(_ method: String, _ expected: Bool) throws {
        var request = URLRequest(url: .init(string: "https://foo.bar/baz?q=1&flag")!)
        request.httpMethod = method
        let condition = stubCondition {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz")
            switch method {
            case "GET": Method.isGet()
            case "POST": Method.isPost()
            case "PUT": Method.isPut()
            case "PATCH": Method.isPatch()
            case "DELETE": Method.isDelete()
            case "HEAD": Method.isHead()
            default: alwaysFalse
            }
            QueryParams.contains(["q": "1", "flag": nil])
        }
        #expect(condition.matcher(request) == expected)
    }
    #endif
}
