#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkingSwift
import SwiftParamTest

final class StubTests: XCTestCase {
    override func setUp() {
        ParameterizedTest.option = ParameterizedTest.Option(
            traceTable: .markdown,
            saveTableToAttachement: .markdown
        )
        StubNetworking.option = .init(printDebugLog: true)
    }

    func testStub() throws {
        assert(to: stub(url: "https://foo.bar/baz")) {
            expect(URL(string: "https://foo.bar/baz?q=1&empty=&flag")! ==> true)
            expect(URL(string: "https://foo.bar/baz")! ==> true)
        }

        assert(to: stub(url: "https://foo.bar/baz?q=1&empty=&flag")) {
            expect(URL(string: "https://foo.bar/baz?q=1&empty=&flag")! ==> true)
            expect(URL(string: "https://foo.bar/baz")! ==> false)
        }

        assert(to: stub(url: "https://foo.bar/baz", method: .post)) {
            expect((URL(string: "https://foo.bar/baz")!, .get) ==> false)
            expect((URL(string: "https://foo.bar/baz")!, .post) ==> true)
        }
    }

    func testStubWithMethodChainBuilders() throws {
        let condition1 = stub()
            .scheme("https")
            .host("foo.bar")
            .path("/baz")
            .method(.get)
            .queryParams(["q": "1", "empty": "", "flag": nil])
        assert(to: condition1) {
            expect(URL(string: "https://foo.bar/baz?q=1&empty=&flag")! ==> true)
            expect(URL(string: "https://foo.bar/baz")! ==> false)
        }

        let condition2 = stub()
            .scheme("https")
            .host("foo.bar")
            .path("/baz")
            .method(.post)
            .jsonBody(["q": 1, "lang": "ja", "flag": true])

        var request = URLRequest(url: URL(string: "https://foo.bar/baz")!)
        request.httpMethod = "POST"
        request.httpBody = #"{"q": 1, "lang": "ja", "flag": true}"#.data(using: .utf8)

        assert(to: condition2) {
            expect(request ==> true)
            expect((URL(string: "https://foo.bar/baz?q=1&empty=&flag")!, Method.post) ==> false)
            expect(URL(string: "https://foo.bar/baz?q=1&empty=&flag")! ==> false)
            expect(URL(string: "https://foo.bar/baz")! ==> false)
        }

    }
}
