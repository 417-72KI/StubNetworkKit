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

    func testPathIs() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Path.is("/foo/bar/baz")
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            expect("foo:" ==> false)
            expect("foo://" ==> false)
            expect("foo://bar/baz" ==> false)
            expect("scheme://foo" ==> false)
            expect("scheme://foo/bar" ==> false)
            expect("scheme://foo/bar/baz" ==> false)
            expect("scheme://host/foo" ==> false)
            expect("scheme://host/foo/bar" ==> false)
            expect("scheme://host/foo/bar/baz" ==> true)
            expect("scheme://host/foo/bar/baz?hoge=fuga" ==> true)
            expect("scheme://host/foo/bar/baz#anchor" ==> true)
            expect("scheme://host/foo/bar/baz?hoge=fuga#anchor" ==> true)
            expect("scheme://host/foo/bar/baz/hoge" ==> false)
            expect("scheme://host/path?/foo/bar/baz/hoge" ==> false)
            expect("scheme://host/path#/foo/bar/baz/hoge" ==> false)
        }
    }

    func testPathStartsWith() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Path.startsWith("/foo/bar/baz")
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            expect("foo:" ==> false)
            expect("foo://" ==> false)
            expect("foo://bar/baz" ==> false)
            expect("scheme://foo" ==> false)
            expect("scheme://foo/bar" ==> false)
            expect("scheme://foo/bar/baz" ==> false)
            expect("scheme://host/foo" ==> false)
            expect("scheme://host/foo/bar" ==> false)
            expect("scheme://host/foo/bar/baz" ==> true)
            expect("scheme://host/foo/bar/baz?hoge=fuga" ==> true)
            expect("scheme://host/foo/bar/baz#anchor" ==> true)
            expect("scheme://host/foo/bar/baz?hoge=fuga#anchor" ==> true)
            expect("scheme://host/foo/bar/baz/hoge" ==> true)
            expect("scheme://host/path?/foo/bar/baz/hoge" ==> false)
            expect("scheme://host/path#/foo/bar/baz/hoge" ==> false)
        }
    }

    func testPathEndsWith() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Path.endsWith("/foo/bar/baz")
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            expect("foo:" ==> false)
            expect("foo://" ==> false)
            expect("foo://bar/baz" ==> false)
            expect("scheme://foo" ==> false)
            expect("scheme://foo/bar" ==> false)
            expect("scheme://foo/bar/baz" ==> false)
            expect("scheme://host/foo" ==> false)
            expect("scheme://host/foo/bar" ==> false)
            expect("scheme://host/foo/bar/baz" ==> true)
            expect("scheme://host/foo/bar/baz?hoge=fuga" ==> true)
            expect("scheme://host/foo/bar/baz#anchor" ==> true)
            expect("scheme://host/foo/bar/baz?hoge=fuga#anchor" ==> true)
            expect("scheme://host/foo/bar/baz/hoge" ==> false)
            expect("scheme://host/path?/foo/bar/baz/hoge" ==> false)
            expect("scheme://host/path#/foo/bar/baz/hoge" ==> false)
        }
    }

    func testPathMatches() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Path.matches("^/foo/bar(/[0-9]+)?$", options: .caseInsensitive)
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            expect("foo:" ==> false)
            expect("foo://" ==> false)
            expect("foo://bar/baz" ==> false)
            expect("scheme://foo" ==> false)
            expect("scheme://foo/bar" ==> false)
            expect("scheme://foo/bar/baz" ==> false)
            expect("scheme://host/foo" ==> false)
            expect("scheme://host/foo/bar" ==> true)
            expect("scheme://host/foo/bar/" ==> true)
            expect("scheme://host/foo/bar/baz" ==> false)
            expect("scheme://host/foo/bar/1" ==> true)
            expect("scheme://host/foo/bar/12" ==> true)
            expect("scheme://host/foo/bar/12/baz" ==> false)
            expect("scheme://host/path?/foo/bar" ==> false)
            expect("scheme://host/path?/foo/bar/" ==> false)
            expect("scheme://host/path?/foo/bar/baz" ==> false)
            expect("scheme://host/path?/foo/bar/1" ==> false)
            expect("scheme://host/path?/foo/bar/12" ==> false)
            expect("scheme://host/path?/foo/bar/12/baz" ==> false)
        }
    }

    func testExtension() throws {
        func actual(_ url: String) -> Bool {
            let matcher = Extension.is("png")
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual) {
            expect("png:" ==> false)
            expect("png://" ==> false)
            expect("png://foo/bar" ==> false)
            expect("scheme://png/foo" ==> false)
            expect("scheme://host/foo/bar" ==> false)
            expect("scheme://host/foo/png" ==> false)
            expect("scheme://host/foo/bar.png" ==> true)
            expect("scheme://host/foo/bar.txt" ==> false)
            expect("scheme://host/foo/bar.png?q=1" ==> true)
            expect("scheme://host/foo/bar.txt?q=baz.png" ==> false)
        }
    }

    func testQueryParamsContainsParams() throws {
        func actual(_ url: String) -> Bool {
            let matcher = QueryParams.contains(["q": "1",
                                                "lang": "ja",
                                                "empty": "",
                                                "flag": nil])
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual(_:)) {
            expect("foo://bar" ==> false)
            expect("foo://bar?q=test" ==> false)
            expect("foo://bar?lang=ja" ==> false)
            expect("foo://bar#q=1&lang=ja&empty=&flag" ==> false)
            expect("foo://bar#lang=ja&empty=&flag&q=test" ==> false)

            expect("foo://bar?q=1&lang=ja&empty=&flag" ==> true)
            expect("foo://bar?q=2&lang=ja&empty=&flag" ==> false)
            expect("foo://bar?lang=ja&flag&empty=&q=1" ==> true)
            expect("foo://bar?q=1&lang=ja&empty=&flag#anchor" ==> true)
            expect("foo://bar?q=1&lang=ja&empty&flag" ==> false)
            expect("foo://bar?q=1&lang=ja&empty=&flag=" ==> false)
            expect("foo://bar?q=ja&lang=test&empty=&flag" ==> false)
            expect("foo://bar?q=1&lang=ja&empty=&flag&&hoge=fuga" ==> true)
            expect("foo://bar?hoge=fuga&empty=&lang=ja&flag&&q=1" ==> true)
            expect("?q=1&lang=ja&empty=&flag" ==> true)
            expect("?lang=ja&flag&empty=&q=1" ==> true)
        }
    }

    func testQueryParamsContainsParamNames() throws {
        func actual(_ url: String) -> Bool {
            let matcher = QueryParams.contains(["q", "lang", "empty", "flag"])
            return matcher(URLRequest(url: URL(string: url)!))
        }

        assert(to: actual(_:)) {
            expect("foo://bar" ==> false)
            expect("foo://bar?q=test" ==> false)
            expect("foo://bar?lang=ja" ==> false)
            expect("foo://bar#q=1&lang=ja&empty=&flag" ==> false)
            expect("foo://bar#lang=ja&empty=&flag&q=test" ==> false)

            expect("foo://bar?q=1&lang=ja&empty=&flag" ==> true)
            expect("foo://bar?q=2&lang=ja&empty=&flag" ==> true)
            expect("foo://bar?lang=ja&flag&empty=&q=1" ==> true)
            expect("foo://bar?q=1&lang=ja&empty=&flag#anchor" ==> true)
            expect("foo://bar?q=1&lang=ja&empty&flag" ==> true)
            expect("foo://bar?q=1&lang=ja&empty=&flag=" ==> true)
            expect("foo://bar?q=ja&lang=test&empty=&flag" ==> true)
            expect("foo://bar?q=1&lang=ja&empty=&flag&&hoge=fuga" ==> true)
            expect("foo://bar?hoge=fuga&empty=&lang=ja&flag&&q=1" ==> true)
            expect("?q=1&lang=ja&empty=&flag" ==> true)
            expect("?lang=ja&flag&empty=&q=1" ==> true)
        }
    }

    func testHeaderContains() throws {
        func request(_ containsHeader: Bool) -> URLRequest {
            var req = URLRequest(url: URL(string: "https://foo/bar")!)
            if containsHeader {
                req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            return req
        }

        assert(to: Header.contains("Content-Type")) {
            expect(request(true) ==> true)
            expect(request(false) ==> false)
        }
    }

    func testHeaderContainsWithValue() throws {
        func request(_ contentType: String?) -> URLRequest {
            var req = URLRequest(url: URL(string: "https://foo/bar")!)
            if let contentType = contentType {
                req.addValue(contentType, forHTTPHeaderField: "Content-Type")
            }
            return req
        }

        assert(to: Header.contains("Content-Type", withValue: "application/json")) {
            expect(request(nil) ==> false)
            expect(request("application/json") ==> true)
            expect(request("application/javascript") ==> false)
        }
    }

    func testBodyIs() throws {
        func request(_ body: String?) -> URLRequest {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = body?.data(using: .utf8)
            return req
        }

        assert(to: Body.is(_:)) {
            expect(("".data(using: .utf8)!, request("")) ==> true)
            expect(("foo".data(using: .utf8)!, request("foo")) ==> true)
            expect(("".data(using: .utf8)!, request(nil)) ==> false)
            expect(("foo".data(using: .utf8)!, request("bar")) ==> false)
        }
    }

    func testBodyIsJsonObject() throws {
        func request(_ jsonString: String) -> URLRequest {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = jsonString.data(using: .utf8)
            return req
        }

        assert(to: Body.isJson(_:)) {
            expect(([:], request(#"{}"#)) ==> true)
            expect(([AnyHashable("foo"): "bar", "baz": 42, "qux": true], request(#"{"foo": "bar", "baz": 42, "qux": true}"#)) ==> true)
            expect(([AnyHashable("foo"): "bar", "qux": true, "baz": 42], request(#"{"foo": "bar", "baz": 42, "qux": true}"#)) ==> true)
            expect(([AnyHashable("foo"): "bar", "baz": ["qux": true, "quux": ["spam", "ham", "eggs"]]], request(#"{"foo": "bar", "baz": {"qux": true, "quux": ["spam", "ham", "eggs"]}}"#)) ==> true)
            expect(([AnyHashable("foo"): "bar", "baz": ["quux": ["spam", "ham", "eggs"], "qux": true]], request(#"{"foo": "bar", "baz": {"qux": true, "quux": ["spam", "ham", "eggs"]}}"#)) ==> true)

            expect(([:], request(#"[]"#)) ==> false)
            expect(([:], request(#"{"foo": "bar"}"#)) ==> false)
            expect(([AnyHashable("foo"): "bar", "baz": 42, "qux": true], request(#"{"baz": "bar", "foo": 42, "qux": true}"#)) ==> false)
            expect(([AnyHashable("foo"): "bar", "baz": 42, "qux": true], request(#"{"foo": "bar", "baz": 41, "qux": true}"#)) ==> false)
            expect(([AnyHashable("foo"): "bar", "baz": ["qux": true, "quux": ["spam", "ham", "eggs"]]], request(#"{"foo": "bar", "baz": {"qux": true, "quux": ["spam", "eggs", "ham"]}}"#)) ==> false)
        }
    }

    func testBodyIsJsonArray() throws {
        func request(_ jsonString: String) -> URLRequest {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = jsonString.data(using: .utf8)
            return req
        }

        assert(to: Body.isJson(_:)) {
            expect(([], request(#"[]"#)) ==> true)
            expect((["foo", "bar", "baz", 42, "qux", true], request(#"["foo", "bar", "baz", 42, "qux", true]"#)) ==> true)
            expect((["foo", "bar", "baz", 42, "qux", true], request(#"["foo", "bar", \#n"baz", 42, "qux", true]"#)) ==> true)
            expect(([["foo", "bar", "baz"], ["qux": true, "quux": ["spam", "ham", "eggs"]]], request(#"[["foo", "bar", "baz"], {"qux": true, "quux": ["spam", "ham", "eggs"]}]"#)) ==> true)

            expect(([], request(#"{}"#)) ==> false)
            expect((["bar", 42], request(#"["foo", "bar", 42]"#)) ==> false)
            expect((["bar", "foo", 42], request(#"["foo", "bar", 42]"#)) ==> false)
            expect((["foo", "qux", 42], request(#"["foo", "bar", 42]"#)) ==> false)
        }
    }

    func testBodyIsForm() throws {
        func request(_ formBody: String, addHeader: Bool = true) -> URLRequest {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            if addHeader {
                req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
            req.httpBody = formBody.data(using: .utf8)
            return req
        }


        assert(to: Body.isForm(_:)) {
            expect((["foo": "bar", "baz": nil, "qux": "42"], request("foo=bar&baz&qux=42")) ==> true)
            expect((["foo": "bar" as String?, "baz": "", "qux": "42"], request("foo=bar&baz=&qux=42")) ==> true)
            expect((["foo": "bar" as String?, "baz": "42", "qux": "true"], request("foo=bar&baz=42&qux=true")) ==> true)
            expect((["foo": "bar" as String?, "baz": "42", "qux": "true"], request("foo=bar&qux=true&baz=42")) ==> true)

            expect((["foo": "bar" as String?, "baz": "42", "qux": "true"], request("foo=bar&baz=42&qux=true", addHeader: false)) ==> false)
            expect((["foo": "bar" as String?, "baz": "42"], request("foo=bar&baz=42&qux=true")) ==> false)
            expect((["foo": "bar" as String?, "baz": "42", "qux": "true"], request("foo=bar&baz=42")) ==> false)
        }
    }
}
