import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing

@testable import StubNetworkKit

@Suite
struct AnyStubConditionTests {

    @Test(arguments: [
        Scheme.is("https"),
        Host.is("foo.bar"),
        Path.is("/baz/qux.json"),
        Extension.is("json"),
        QueryParams.contains(["q": "quux"]),
    ] as [any StubCondition])
    func url(_ condition: any StubCondition) async throws {
        let condition = AnyStubCondition(condition)
        #expect(condition(URL(string: "https://foo.bar/baz/qux.json?q=quux")!))
    }

    private static let methods: [(String, any StubCondition)] = {
        #if os(watchOS)
        [
            ("GET", Method.isGet()),
            ("HEAD", Method.isHead()),
        ]
        #else
        [
            ("GET", Method.isGet()),
            ("POST", Method.isPost()),
            ("PUT", Method.isPut()),
            ("PATCH", Method.isPatch()),
            ("DELETE", Method.isDelete()),
            ("HEAD", Method.isHead()),
        ]
        #endif
    }()

    @Test(arguments: methods)
    func method(_ method: String, _ condition: any StubCondition) async throws {
        let url = URL(string: "https://foo.bar/baz/qux.json?q=quux")!
        #expect(AnyStubCondition(Method.isGet())(url))

        let condition = AnyStubCondition(condition)

        let request = URLRequest(url: url, method: method)
        #expect(condition(request))
    }

    @Test
    func header() async throws {
        let condition = AnyStubCondition(Header.contains("Content-Type", withValue: "application/json"))
        let url = URL(string: "https://foo.bar/baz/qux.json?q=quux")!
        #expect(!condition(url))

        let request = URLRequest(url: url, method: "GET", headers: ["Content-Type": "application/json"])
        #expect(condition(request))
    }

    @Suite
    struct body {
        private let url = URL(string: "https://foo.bar/baz/qux.json?q=quux")!

        @Test @available(watchOS, unavailable)
        func isData() async throws {
            let condition = AnyStubCondition(Body.is(Data("foobarbaz".utf8)))

            let request = URLRequest(
                url: url,
                method: "POST",
                body: "foobarbaz".data(using: .utf8)
            )
            #expect(condition(request))
        }

        @Test(arguments: [
            (#"{"foo": "bar", "baz": 1, "qux": true}"#, ["foo": "bar", "baz": 1, "qux": true]),
            ("{}", [:]),
        ] as [(String, JSONObject)]) @available(watchOS, unavailable)
        func isJsonObject(_ jsonString: String, _ jsonObject: JSONObject) async throws {
            let condition = AnyStubCondition(Body.isJson(jsonObject))

            let request = URLRequest(
                url: url,
                method: "POST",
                body: jsonString.data(using: .utf8)
            )
            #expect(condition(request), "condition: \(condition)")
        }

        @Test(arguments: [
            (#"["foo", "bar"]"#, ["foo", "bar"]),
            (#"["foo", "bar", 1, true]"#, ["foo", "bar", 1, true]),
            ("[]", []),
        ] as [(String, JSONArray)]) @available(watchOS, unavailable)
        func isJsonArray(_ jsonString: String, _ jsonArray: JSONArray) async throws {
            let condition = AnyStubCondition(Body.isJson(jsonArray))

            let request = URLRequest(
                url: url,
                method: "POST",
                body: jsonString.data(using: .utf8)
            )
            #expect(condition(request))
        }
    }

    @Suite
    struct Equaltable {
        var conditions: [any StubCondition] {
            var conditions: [any StubCondition] = [
                Scheme.is("https"),
                Host.is("foo.bar"),
                Path.is("/foo/bar"),
                Extension.is("json"),
                QueryParams.contains(["q": "quux"]),
                Method.isPost(),
                Header.contains("Content-Type", withValue: "application/json"),
            ]
            #if !os(watchOS)
            conditions.append(Body.isJson(["foo": "bar", "baz": 1]))
            #endif
            return conditions
        }

        @Test
        func match() async throws {
            let c1s = conditions.map(AnyStubCondition.init)
            let c2s = conditions.map(AnyStubCondition.init)
            #expect(c1s == c2s)
        }

        @Test
        func notMatch() async throws {
            for (i, c1) in conditions.enumerated() {
                for j in (i + 1)..<conditions.count {
                    let c2 = conditions[j]
                    #expect(AnyStubCondition(c1) != AnyStubCondition(c2))
                }
            }
        }
    }

    @Suite
    struct And {
        @Test func directly() async throws {
            let c1 = Scheme.is("https")
            let c2 = Host.is("foo.bar")

            let and1 = AnyStubCondition(c1 && c2)
            let and2 = AnyStubCondition(c2 && c1)
            #expect(and1 == and2)
        }

        @Test func leftSideTypeErased() async throws {
            let c1 = AnyStubCondition(Scheme.is("https"))
            let c2 = Host.is("foo.bar")

            let and1 = AnyStubCondition(c1 && c2)
            let and2 = AnyStubCondition(c2 && c1)

            #expect(and1 == and2)
        }

        @Test func rightSideTypeErased() async throws {
            let c1 = Scheme.is("https")
            let c2 = AnyStubCondition(Host.is("foo.bar"))

            let and1 = AnyStubCondition(c1 && c2)
            let and2 = AnyStubCondition(c2 && c1)

            #expect(and1 == and2)
        }

        @Test func bothTypeErased() async throws {
            let c1 = AnyStubCondition(Scheme.is("https"))
            let c2 = AnyStubCondition(Host.is("foo.bar"))

            let and1 = c1 && c2
            let and2 = c2 && c1

            #expect(and1 == and2)
        }
    }

    @Suite
    struct OR {
        @Test func directly() async throws {
            let c1 = Scheme.is("https")
            let c2 = Host.is("foo.bar")

            let or1 = AnyStubCondition(c1 || c2)
            let or2 = AnyStubCondition(c2 || c1)
            #expect(or1 == or2)

        }

        @Test func leftSideTypeErased() async throws {
            let c1 = AnyStubCondition(Scheme.is("https"))
            let c2 = Host.is("foo.bar")

            let or1 = AnyStubCondition(c1 || c2)
            let or2 = AnyStubCondition(c2 || c1)

            #expect(or1 == or2)
        }

        @Test func rightSideTypeErased() async throws {
            let c1 = Scheme.is("https")
            let c2 = AnyStubCondition(Host.is("foo.bar"))

            let or1 = AnyStubCondition(c1 || c2)
            let or2 = AnyStubCondition(c2 || c1)

            #expect(or1 == or2)
        }

        @Test func bothTypeErased() async throws {
            let c1 = AnyStubCondition(Scheme.is("https"))
            let c2 = AnyStubCondition(Host.is("foo.bar"))

            let or1 = c1 || c2
            let or2 = c2 || c1

            #expect(or1 == or2)
        }
    }
}
