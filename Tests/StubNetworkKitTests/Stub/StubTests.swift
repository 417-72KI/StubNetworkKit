import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import StubNetworkKit

@Suite
struct StubTests {
    init() {
        StubNetworking.option(printDebugLog: true,
                              debugConditions: true)
    }

    @Suite
    struct Stub {
        @Test(arguments: [
            "https://foo.bar/baz?q=1&empty=&flag",
            "https://foo.bar/baz",
        ])
        func simple(_ url: String) throws {
            let req = URLRequest(url: URL(string: url)!)
            #expect(stub(url: "https://foo.bar/baz").matcher(req))
        }

        @Test(arguments: [
            ("https://foo.bar/baz?q=1&empty=&flag", true),
            ("https://foo.bar/baz", false),
        ])
        func containsQuery(_ url: String, _ expected: Bool) throws {
            let req = URLRequest(url: URL(string: url)!)
            #expect(stub(url: "https://foo.bar/baz?q=1&empty=&flag").matcher(req) == expected)
         }

        @Test(arguments: [
            ("GET", false),
            ("POST", true),
            ("PUT", false),
            ("PATCH", false),
            ("DELETE", false),
            ("HEAD", false),
        ])
        func compareMethod(_ method: String, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "https://foo.bar/baz")!)
            req.httpMethod = method
            #expect(stub(url: "https://foo.bar/baz", method: .post).matcher(req) == expected)
        }
    }

    @Suite
    struct StubWithMethodChainBuilders {
        @Test(arguments: [
            ("https://foo.bar/baz?q=1&empty=&flag", true),
            ("https://foo.bar/baz", false),
        ])
        func getRequest(_ url: String, _ expected: Bool) throws {
            let condition = stub()
                .scheme("https")
                .host("foo.bar")
                .path("/baz")
                .method(.get)
                .queryParams(["q": "1", "empty": "", "flag": nil])

            let req = URLRequest(url: URL(string: url)!)
            #expect(condition.matcher(req) == expected)
        }

        #if !os(watchOS)
        @Test
        func validPostRequest() throws {
            let condition = stub()
                .scheme("https")
                .host("foo.bar")
                .path("/baz")
                .method(.post)
                .jsonBody(["q": 1, "lang": "ja", "flag": true])

            var req = URLRequest(url: URL(string: "https://foo.bar/baz")!)
            req.httpMethod = "POST"
            req.httpBody = #"{"q": 1, "lang": "ja", "flag": true}"#.data(using: .utf8)

            #expect(condition.matcher(req))
        }

        @Test(arguments: [
            ("https://foo.bar/baz?q=1&empty=&flag", "POST"),
            ("https://foo.bar/baz?q=1&empty=&flag", "GET"),
            ("https://foo.bar/baz", "GET"),
        ])
        func invalidPostRequest(_ url: String, _ method: String) throws {
            let condition = stub()
                .scheme("https")
                .host("foo.bar")
                .path("/baz")
                .method(.post)
                .jsonBody(["q": 1, "lang": "ja", "flag": true])

            var req = URLRequest(url: URL(string: "https://foo.bar/baz")!)
            req.httpMethod = method
            if req.httpMethod == "GET" {
                req.httpBody = Data(#"{"q": 1, "lang": "ja", "flag": true}"#.utf8)
            }

            #expect(!condition.matcher(req))
        }
        #endif
    }
}
