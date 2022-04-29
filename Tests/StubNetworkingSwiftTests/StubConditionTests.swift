import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkingSwift
import SwiftParamTest

final class StubConditionTests: XCTestCase {
    override func setUp() {
        ParameterizedTest.option = ParameterizedTest.Option(
            traceTable: .markdown,
            saveTableToAttachement: .markdown
        )
    }

    func testMethod() throws {
        func createRequest(method: String) -> URLRequest {
            var req = URLRequest(url: URL(string: "https://foo.bar")!)
            req.httpMethod = method
            return req
        }
        assert(to: Method.isGet) {
            expect(createRequest(method: "GET") ==> true)
            expect(createRequest(method: "POST") ==> false)
            expect(createRequest(method: "PUT") ==> false)
            expect(createRequest(method: "PATCH") ==> false)
            expect(createRequest(method: "DELETE") ==> false)
            expect(createRequest(method: "HEAD") ==> false)
        }
        assert(to: Method.isPost) {
            expect(createRequest(method: "GET") ==> false)
            expect(createRequest(method: "POST") ==> true)
            expect(createRequest(method: "PUT") ==> false)
            expect(createRequest(method: "PATCH") ==> false)
            expect(createRequest(method: "DELETE") ==> false)
            expect(createRequest(method: "HEAD") ==> false)
        }
        assert(to: Method.isPut) {
            expect(createRequest(method: "GET") ==> false)
            expect(createRequest(method: "POST") ==> false)
            expect(createRequest(method: "PUT") ==> true)
            expect(createRequest(method: "PATCH") ==> false)
            expect(createRequest(method: "DELETE") ==> false)
            expect(createRequest(method: "HEAD") ==> false)
        }
        assert(to: Method.isPatch) {
            expect(createRequest(method: "GET") ==> false)
            expect(createRequest(method: "POST") ==> false)
            expect(createRequest(method: "PUT") ==> false)
            expect(createRequest(method: "PATCH") ==> true)
            expect(createRequest(method: "DELETE") ==> false)
            expect(createRequest(method: "HEAD") ==> false)
        }
        assert(to: Method.isDelete) {
            expect(createRequest(method: "GET") ==> false)
            expect(createRequest(method: "POST") ==> false)
            expect(createRequest(method: "PUT") ==> false)
            expect(createRequest(method: "PATCH") ==> false)
            expect(createRequest(method: "DELETE") ==> true)
            expect(createRequest(method: "HEAD") ==> false)
        }
        assert(to: Method.isHead) {
            expect(createRequest(method: "GET") ==> false)
            expect(createRequest(method: "POST") ==> false)
            expect(createRequest(method: "PUT") ==> false)
            expect(createRequest(method: "PATCH") ==> false)
            expect(createRequest(method: "DELETE") ==> false)
            expect(createRequest(method: "HEAD") ==> true)
        }
    }

    func testScheme() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Scheme.is("foo")
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            expect("foo:" ==> true)
            expect("foo://" ==> true)
            expect("foo://bar/baz" ==> true)
            expect("bar://" ==> false)
            expect("bar://foo/" ==> false)
            expect("foobar://" ==> false)
        }
    }

    func testHost() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Host.is("foo")
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            expect("foo:" ==> false)
            expect("foo://" ==> false)
            expect("foo://bar/baz" ==> false)
            expect("bar://foo" ==> true)
            expect("bar://foo/baz" ==> true)
        }
    }
}
