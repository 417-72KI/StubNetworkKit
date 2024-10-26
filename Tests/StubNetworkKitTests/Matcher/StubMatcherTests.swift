import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
import StubNetworkKit

@Suite struct StubMatcherTests {
    init() {
        StubNetworking.option(printDebugLog: true,
                              debugConditions: true)
    }

    @Suite struct MethodIs {
        func createRequest(method: String) -> URLRequest {
            var req = URLRequest(url: URL(string: "https://foo.bar")!)
            req.httpMethod = method
            return req
        }

        @Test(arguments: [
            ("GET", true),
            ("POST", false),
            ("PUT", false),
            ("PATCH", false),
            ("DELETE", false),
            ("HEAD", false),
        ])
        func get(_ method: String, _ expected: Bool) {
            #expect(Method.isGet().matcher(createRequest(method: method)) == expected)
        }

        #if !os(watchOS)
        @Test(arguments: [
            ("GET", false),
            ("POST", true),
            ("PUT", false),
            ("PATCH", false),
            ("DELETE", false),
            ("HEAD", false),
        ])
        func post(_ method: String, _ expected: Bool) {
            #expect(Method.isPost().matcher(createRequest(method: method)) == expected)
        }
        @Test(arguments: [
            ("GET", false),
            ("POST", false),
            ("PUT", true),
            ("PATCH", false),
            ("DELETE", false),
            ("HEAD", false),
        ])
        func put(_ method: String, _ expected: Bool) {
            #expect(Method.isPut().matcher(createRequest(method: method)) == expected)
        }
        @Test(arguments: [
            ("GET", false),
            ("POST", false),
            ("PUT", false),
            ("PATCH", true),
            ("DELETE", false),
            ("HEAD", false),
        ])
        func patch(_ method: String, _ expected: Bool) {
            #expect(Method.isPatch().matcher(createRequest(method: method)) == expected)
        }
        @Test(arguments: [
            ("GET", false),
            ("POST", false),
            ("PUT", false),
            ("PATCH", false),
            ("DELETE", true),
            ("HEAD", false),
        ])
        func delete(_ method: String, _ expected: Bool) {
            #expect(Method.isDelete().matcher(createRequest(method: method)) == expected)
        }
        #endif

        @Test(arguments: [
            ("GET", false),
            ("POST", false),
            ("PUT", false),
            ("PATCH", false),
            ("DELETE", false),
            ("HEAD", true),
        ])
        func head(_ method: String, _ expected: Bool) {
            #expect(Method.isHead().matcher(createRequest(method: method)) == expected)
        }
    }

    @Test(arguments: [
        ("foo:", true),
        ("foo://", true),
        ("foo://bar/baz", true),
        ("bar://", false),
        ("bar://foo/", false),
        ("foobar://", false),
    ])
    func scheme(_ url: String, _ expected: Bool) throws {
        let matcher = Scheme.is("foo")
            .matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        ("foo:", false),
        ("foo://", false),
        ("foo://bar/baz", false),
        ("bar://foo", true),
        ("bar://foo/baz", true),
    ])
    func host(_ url: String, _ expected: Bool) throws {
        let matcher = Host.is("foo")
            .matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        ("foo:", false),
        ("foo://", false),
        ("foo://bar/baz", false),
        ("scheme://foo", false),
        ("scheme://foo/bar", false),
        ("scheme://foo/bar/baz", false),
        ("scheme://host/foo", false),
        ("scheme://host/foo/bar", false),
        ("scheme://host/foo/bar/baz", true),
        ("scheme://host/foo/bar/baz?hoge=fuga", true),
        ("scheme://host/foo/bar/baz#anchor", true),
        ("scheme://host/foo/bar/baz?hoge=fuga#anchor", true),
        ("scheme://host/foo/bar/baz/hoge", false),
        ("scheme://host/path?/foo/bar/baz/hoge", false),
        ("scheme://host/path#/foo/bar/baz/hoge", false),
    ])
    func pathIs(_ url: String, _ expected: Bool) throws {
        let matcher = Path.is("/foo/bar/baz")
            .matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        ("foo:", false),
        ("foo://", false),
        ("foo://bar/baz", false),
        ("scheme://foo", false),
        ("scheme://foo/bar", false),
        ("scheme://foo/bar/baz", false),
        ("scheme://host/foo", false),
        ("scheme://host/foo/bar", false),
        ("scheme://host/foo/bar/baz", true),
        ("scheme://host/foo/bar/baz?hoge=fuga", true),
        ("scheme://host/foo/bar/baz#anchor", true),
        ("scheme://host/foo/bar/baz?hoge=fuga#anchor", true),
        ("scheme://host/foo/bar/baz/hoge", true),
        ("scheme://host/path?/foo/bar/baz/hoge", false),
        ("scheme://host/path#/foo/bar/baz/hoge", false),
    ])
    func pathStartsWith(_ url: String, _ expected: Bool) throws {
        let matcher = Path.startsWith("/foo/bar/baz")
            .matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        ("foo:", false),
        ("foo://", false),
        ("foo://bar/baz", false),
        ("scheme://foo", false),
        ("scheme://foo/bar", false),
        ("scheme://foo/bar/baz", false),
        ("scheme://host/foo", false),
        ("scheme://host/foo/bar", false),
        ("scheme://host/foo/bar/baz", true),
        ("scheme://host/foo/bar/baz?hoge=fuga", true),
        ("scheme://host/foo/bar/baz#anchor", true),
        ("scheme://host/foo/bar/baz?hoge=fuga#anchor", true),
        ("scheme://host/foo/bar/baz/hoge", false),
        ("scheme://host/path?/foo/bar/baz/hoge", false),
        ("scheme://host/path#/foo/bar/baz/hoge", false),
    ])
    func pathEndsWith(_ url: String, _ expected: Bool) throws {
        let matcher = Path.endsWith("/foo/bar/baz")
            .matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        ("foo:", false),
        ("foo://", false),
        ("foo://bar/baz", false),
        ("scheme://foo", false),
        ("scheme://foo/bar", false),
        ("scheme://foo/bar/baz", false),
        ("scheme://host/foo", false),
        ("scheme://host/foo/bar", true),
        ("scheme://host/foo/bar/", true),
        ("scheme://host/foo/bar/baz", false),
        ("scheme://host/foo/bar/1", true),
        ("scheme://host/foo/bar/12", true),
        ("scheme://host/foo/bar/12/baz", false),
        ("scheme://host/path?/foo/bar", false),
        ("scheme://host/path?/foo/bar/", false),
        ("scheme://host/path?/foo/bar/baz", false),
        ("scheme://host/path?/foo/bar/1", false),
        ("scheme://host/path?/foo/bar/12", false),
        ("scheme://host/path?/foo/bar/12/baz", false),
    ])
    func pathMatches(_ url: String, _ expected: Bool) throws {
        let matcher = Path.matches("^/foo/bar(/[0-9]+)?$", options: .caseInsensitive)
            .matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        ("png:", false),
        ("png://", false),
        ("png://foo/bar", false),
        ("scheme://png/foo", false),
        ("scheme://host/foo/bar", false),
        ("scheme://host/foo/png", false),
        ("scheme://host/foo/bar.png", true),
        ("scheme://host/foo/bar.txt", false),
        ("scheme://host/foo/bar.png?q=1", true),
        ("scheme://host/foo/bar.txt?q=baz.png", false),
    ])
    func `extension`(_ url: String, _ expected: Bool) throws {
        let matcher = Extension.is("png")
            .matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        ("foo://bar", false),
        ("foo://bar?q=test", false),
        ("foo://bar?lang=ja", false),
        ("foo://bar?q=1&lang=ja&empty=", false),
        ("foo://bar#q=1&lang=ja&empty=&flag", false),
        ("foo://bar#lang=ja&empty=&flag&q=test", false),

        ("foo://bar?q=1&lang=ja&empty=&flag", true),
        ("foo://bar?q=2&lang=ja&empty=&flag", false),
        ("foo://bar?lang=ja&flag&empty=&q=1", true),
        ("foo://bar?q=1&lang=ja&empty=&flag#anchor", true),
        ("foo://bar?q=1&lang=ja&empty&flag", false),
        ("foo://bar?q=1&lang=ja&empty=&flag=", false),
        ("foo://bar?q=ja&lang=test&empty=&flag", false),
        ("foo://bar?q=1&lang=ja&empty=&flag&&hoge=fuga", true),
        ("foo://bar?hoge=fuga&empty=&lang=ja&flag&&q=1", true),
        ("?q=1&lang=ja&empty=&flag", true),
        ("?lang=ja&flag&empty=&q=1", true),
    ])
    func queryParamsContainsParams(_ url: String, _ expected: Bool) throws {
        let matcher = QueryParams.contains(["q": "1",
                                            "lang": "ja",
                                            "empty": "",
                                            "flag": nil,])
            .matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        ("foo://bar", false),
        ("foo://bar?q=test", false),
        ("foo://bar?lang=ja", false),
        ("foo://bar#q=1&lang=ja&empty=&flag", false),
        ("foo://bar#lang=ja&empty=&flag&q=test", false),

        ("foo://bar?q=1&lang=ja&empty=&flag", true),
        ("foo://bar?q=2&lang=ja&empty=&flag", true),
        ("foo://bar?lang=ja&flag&empty=&q=1", true),
        ("foo://bar?q=1&lang=ja&empty=&flag#anchor", true),
        ("foo://bar?q=1&lang=ja&empty&flag", true),
        ("foo://bar?q=1&lang=ja&empty=&flag=", true),
        ("foo://bar?q=ja&lang=test&empty=&flag", true),
        ("foo://bar?q=1&lang=ja&empty=&flag&&hoge=fuga", true),
        ("foo://bar?hoge=fuga&empty=&lang=ja&flag&&q=1", true),
        ("?q=1&lang=ja&empty=&flag", true),
        ("?lang=ja&flag&empty=&q=1", true),
    ])
    func queryParamsContainsParamNames(_ url: String, _ expected: Bool) throws {
        let matcher = QueryParams.contains(["q", "lang", "empty", "flag"]).matcher
        #expect(matcher(URLRequest(url: URL(string: url)!)) == expected)
    }

    @Test(arguments: [
        (true, true),
        (false, false),
    ])
    func headerContains(_ containsHeader: Bool, _ expected: Bool) throws {
        var req = URLRequest(url: URL(string: "https://foo/bar")!)
        if containsHeader {
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        #expect(Header.contains("Content-Type").matcher(req) == expected)
    }

    @Test(arguments: [
        (nil, false),
        ("application/json", true),
        ("application/javascript", false),
    ])
    func headerContainsWithValue(_ contentType: String?, _ expected: Bool) throws {
        var req = URLRequest(url: URL(string: "https://foo/bar")!)
        if let contentType = contentType {
            req.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        #expect(Header.contains("Content-Type", withValue: "application/json").matcher(req) == expected)
    }

    #if !os(watchOS)
    @Suite
    struct BodyIsString {
        @Test(arguments: [
            ("", true),
            (nil, false),
        ])
        func empty(_ value: String?, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = value?.data(using: .utf8)
            #expect(Body.is(Data("".utf8)).matcher(req) == expected)
        }

        @Test(arguments: [
            ("foo", true),
            ("bar", false),
        ])
        func notEmpty(_ value: String?, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = value?.data(using: .utf8)
            #expect(Body.is(Data("foo".utf8)).matcher(req) == expected)
        }
    }

    @Suite
    struct BodyIsJsonObject {
        @Test(arguments: [
            (#"{}"#, true),
            (#"[]"#, false),
            (#"{"foo": "bar"}"#, false),
        ])
        func empty(_ jsonString: String, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = jsonString.data(using: .utf8)
            #expect(Body.isJson([:]).matcher(req) == expected)
        }

        @Test(arguments: [
            (#"{"foo": "bar", "baz": 42, "qux": true}"#, true),
            (#"{"foo": "bar", "qux": true, "baz": 42}"#, true),
            (#"{"baz": "bar", "foo": 42, "qux": true}"#, false),
            (#"{"foo": "bar", "baz": 41, "qux": true}"#, false),
        ])
        func simpleObject(_ jsonString: String, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = jsonString.data(using: .utf8)
            #expect(Body.isJson(["foo": "bar", "baz": 42, "qux": true]).matcher(req) == expected)
        }

        @Test(arguments: [
            (#"{"foo": "bar", "baz": {"qux": true, "quux": ["spam", "ham", "eggs"]}}"#, true),
            (#"{"foo": "bar", "baz": {"quux": ["spam", "ham", "eggs"], "qux": true}}"#, true),

            (#"{"foo": "bar", "baz": {"qux": true, "quux": ["spam", "eggs", "ham"]}}"#, false),
        ])
        func complexObject(_ jsonString: String, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = jsonString.data(using: .utf8)
            #expect(Body.isJson(["foo": "bar", "baz": ["qux": true, "quux": ["spam", "ham", "eggs"] as JSONArray] as JSONObject]).matcher(req) == expected)
        }
    }

    @Suite
    struct BodyIsJsonArray {
        @Test(arguments: [
            (#"[]"#, true),
            (#"{}"#, false),
        ])
        func empty(_ jsonString: String, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = jsonString.data(using: .utf8)
            #expect(Body.isJson([]).matcher(req) == expected)
        }

        @Test(arguments: [
            (#"["foo", "bar", "baz", 42, "qux", true]"#, true),
            (#"["foo", "bar", \#n"baz", 42, "qux", true]"#, true),
            (#"["bar", "baz", 42, "qux", true]"#, false),
            (#"["bar", "foo", "baz", 42, "qux", true]"#, false),
            (#"["foo", "bar", "baz", 41, "qux", true]"#, false),
        ])
        func stringArray(_ jsonString: String, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = jsonString.data(using: .utf8)
            #expect(Body.isJson(["foo", "bar", "baz", 42, "qux", true]).matcher(req) == expected)
        }

        @Test(arguments: [
            (#"[["foo", "bar", "baz"], {"qux": true, "quux": ["spam", "ham", "eggs"]}]"#, true),
        ])
        func arrayWithMultipleObjects(_ jsonString: String, _ expected: Bool) throws {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            req.httpBody = jsonString.data(using: .utf8)
            #expect(Body.isJson([["foo", "bar", "baz"] as JSONArray, ["qux": true, "quux": ["spam", "ham", "eggs"] as JSONArray] as JSONObject]).matcher(req) == expected)
        }
    }

    @Suite
    struct BodyIsForm {
        @Test(arguments: [
            ("foo=bar&baz&qux=42", true),
        ])
        func containsFlag(_ formBody: String, _ expected: Bool) throws {
            #expect(Body.isForm(["foo": "bar", "baz": nil, "qux": "42"]).matcher(request(formBody)) == expected)
            #expect(!Body.isForm(["foo": "bar", "baz": nil, "qux": "42"]).matcher(request(formBody, addHeader: false)))
        }

        @Test(arguments: [
            ("foo=bar&baz=42&qux=true", true),
            ("foo=bar&qux=true&baz=42", true),
            ("foo=bar&baz=42", false),
        ])
        func containsOptional(_ formBody: String, _ expected: Bool) throws {
            #expect(Body.isForm(["foo": "bar" as String?, "baz": "42", "qux": "true"]).matcher(request(formBody)) == expected)
            #expect(!Body.isForm(["foo": "bar" as String?, "baz": "42", "qux": "true"]).matcher(request(formBody, addHeader: false)))
        }

        @Test(arguments: [
            ("foo=bar&baz=&qux=42", true),
        ])
        func containsEmptyString(_ formBody: String, _ expected: Bool) throws {
            #expect(Body.isForm(["foo": "bar" as String?, "baz": "", "qux": "42"]).matcher(request(formBody)) == expected)
            #expect(!Body.isForm(["foo": "bar" as String?, "baz": "", "qux": "42"]).matcher(request(formBody, addHeader: false)))
        }

        @Test(arguments: [
            ("foo=bar&baz=42&qux=true", false),
        ])
        func lackKey(_ formBody: String, _ expected: Bool) throws {
            #expect(Body.isForm(["foo": "bar" as String?, "baz": "42"]).matcher(request(formBody)) == expected)
            #expect(!Body.isForm(["foo": "bar" as String?, "baz": "42"]).matcher(request(formBody, addHeader: false)))
        }

        private func request(_ formBody: String, addHeader: Bool = true) -> URLRequest {
            var req = URLRequest(url: URL(string: "foo://bar")!)
            if addHeader {
                req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
            req.httpBody = formBody.data(using: .utf8)
            return req
        }

    }
    #endif
}
