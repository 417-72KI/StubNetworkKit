#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkingSwift
import SwiftParamTest

final class StubCondition_ResultBuilderTests: XCTestCase {
    func testBuild() throws {
        var req = URLRequest(url: .init(string: "https://foo.bar/baz?q=1&flag")!)
        req.httpMethod = "POST"

        let condition = stubCondition {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz")
            Method.isPost()
            QueryParams.contains(["q":"1", "flag": nil])
        }
        XCTAssertTrue(condition.matcher(req))

        XCTAssertFalse(condition.matcher(URL(fileURLWithPath: "/foo/bar")))
    }

    func testBuildOptional() throws {
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
        XCTAssertTrue(condition.matcher(req))
    }

    func testBuildEither() throws {

        func test(_ method: String) -> Bool {
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
                QueryParams.contains(["q":"1", "flag": nil])
            }
            return condition.matcher(request)
        }

        assert(to: test) {
            expect("GET" ==> true)
            expect("POST" ==> true)
            expect("PUT" ==> true)
            expect("PATCH" ==> true)
            expect("DELETE" ==> true)
            expect("HEAD" ==> true)
            expect("Invalid method" ==> false)
        }
    }
}
