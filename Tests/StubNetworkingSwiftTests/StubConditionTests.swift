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
            args(createRequest(method: "GET"), expect: true)
            args(createRequest(method: "POST"), expect: false)
            args(createRequest(method: "PUT"), expect: false)
            args(createRequest(method: "PATCH"), expect: false)
            args(createRequest(method: "DELETE"), expect: false)
            args(createRequest(method: "HEAD"), expect: false)
        }
        assert(to: Method.isPost) {
            args(createRequest(method: "GET"), expect: false)
            args(createRequest(method: "POST"), expect: true)
            args(createRequest(method: "PUT"), expect: false)
            args(createRequest(method: "PATCH"), expect: false)
            args(createRequest(method: "DELETE"), expect: false)
            args(createRequest(method: "HEAD"), expect: false)
        }
        assert(to: Method.isPut) {
            args(createRequest(method: "GET"), expect: false)
            args(createRequest(method: "POST"), expect: false)
            args(createRequest(method: "PUT"), expect: true)
            args(createRequest(method: "PATCH"), expect: false)
            args(createRequest(method: "DELETE"), expect: false)
            args(createRequest(method: "HEAD"), expect: false)
        }
        assert(to: Method.isPatch) {
            args(createRequest(method: "GET"), expect: false)
            args(createRequest(method: "POST"), expect: false)
            args(createRequest(method: "PUT"), expect: false)
            args(createRequest(method: "PATCH"), expect: true)
            args(createRequest(method: "DELETE"), expect: false)
            args(createRequest(method: "HEAD"), expect: false)
        }
        assert(to: Method.isDelete) {
            args(createRequest(method: "GET"), expect: false)
            args(createRequest(method: "POST"), expect: false)
            args(createRequest(method: "PUT"), expect: false)
            args(createRequest(method: "PATCH"), expect: false)
            args(createRequest(method: "DELETE"), expect: true)
            args(createRequest(method: "HEAD"), expect: false)
        }
        assert(to: Method.isHead) {
            args(createRequest(method: "GET"), expect: false)
            args(createRequest(method: "POST"), expect: false)
            args(createRequest(method: "PUT"), expect: false)
            args(createRequest(method: "PATCH"), expect: false)
            args(createRequest(method: "DELETE"), expect: false)
            args(createRequest(method: "HEAD"), expect: true)
        }
    }

    func testScheme() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Scheme.is("foo")
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            args("foo:", expect: true)
            args("foo://", expect: true)
            args("foo://bar/baz", expect: true)
            args("bar://", expect: false)
            args("bar://foo/", expect: false)
            args("foobar://", expect: false)
        }
    }

    func testHost() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Host.is("foo")
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            args("foo:", expect: false)
            args("foo://", expect: false)
            args("foo://bar/baz", expect: false)
            args("bar://foo", expect: true)
            args("bar://foo/baz", expect: true)
        }
    }
}
