import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkKit

final class StubNetworkKitTests: XCTestCase {
    override func setUp() {
        StubNetworking.option(printDebugLog: true,
                              debugConditions: true)
    }

    override func tearDown() {
        clearStubs()
    }

    /// Example function for basic implementation
    func testDefaultStubSession_basic() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz"))
            .responseData(Data("Hello world!".utf8))

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    #if !os(watchOS)
    /// Example function for basic implementation
    @available(watchOS, unavailable)
    func testDefaultStubSession_basic_post() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz") && Method.isPost() && Body.isJson(["key": "world"]))
            .responseData(Data("Hello world!".utf8))

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"key": "world"}"#.utf8)

        let (data, response) = try await defaultStubSession.data(for: request)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }
    #endif

    /// Example function for basic implementation
    func testDefaultStubSession_basic_customResponse() async throws {
        let url = URL(string: "foo://bar/baz?q=1")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) {
            guard $0.url?.query == "q=1" else {
                return .error(.unexpectedRequest($0))
            }
            return .data(Data("Hello world!".utf8))
        }

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    /// Example function for using Result Builder implementation
    func testDefaultStubSession_resultBuilder() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isGet()
        }.responseData(Data("Hello world!".utf8))

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    #if !os(watchOS)
    /// Example function for using Result Builder implementation
    @available(watchOS, unavailable)
    func testDefaultStubSession_resultBuilder_post() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isPost()
            Body.isJson(["key": "world"])
        }.responseData(Data("Hello world!".utf8))

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"key": "world"}"#.utf8)

        let (data, response) = try await defaultStubSession.data(for: request)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }
    #endif

    /// Example function for using Result Builder implementation
    func testDefaultStubSession_resultBuilder_customResponse() async throws {
        let url = URL(string: "foo://bar/baz?q=1")!

        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isGet()
        } withResponse: {
            guard $0.url?.query == "q=1" else {
                return .error(.unexpectedRequest($0))
            }
            return .data(Data("Hello world!".utf8))
        }

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    /// Example function for using single function implementation
    func testDefaultStubSession_singleFunction() async throws {
        let url = URL(string: "foo://bar/baz")!
        stub(url: "foo://bar/baz", method: .get)
            .responseData(Data("Hello world!".utf8))

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    /// Example function for using function-chain implementation
    func testDefaultStubSession_functionChaining() async throws {
        let url = URL(string: "foo://bar/baz")!
        stub()
            .scheme("foo")
            .host("bar")
            .path("/baz")
            .method(.get)
            .responseData(Data("Hello world!".utf8))

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    /// Example function for using fixture response.
    func testDefaultStubSession_fixture() async throws {
        let url = URL(string: "foo://bar/baz?q=1")!
        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isGet()
        } withResponse: {
            guard $0.url?.query == "q=1" else {
                return .error(.unexpectedRequest($0))
            }
            return .json(fromFile: "_Fixtures/sample", in: .module)
        }

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)

        let actual = try JSONDecoder()
            .decode(Sample.self, from: data)
        XCTAssertEqual(actual, .init(foo: "hoge",
                                     bar: 42,
                                     baz: true,
                                     qux: .init(
                                        quux: "fuga",
                                        corge: 3.14,
                                        grault: false,
                                        garply: [
                                            "spam",
                                            "ham",
                                            "eggs",
                                        ]
                                     )
                                    )
        )
    }

    /// Example function for using function-chain implementation and fixture response.
    func testDefaultStubSession_functionChaining_fixture() async throws {
        let url = URL(string: "foo://bar/baz")!
        stub()
            .scheme("foo")
            .host("bar")
            .path("/baz")
            .method(.get)
            .responseData(withFilePath: "_Fixtures/sample", extension: "json", in: .module)

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)

        let actual = try JSONDecoder()
            .decode(Sample.self, from: data)
        XCTAssertEqual(actual, .init(foo: "hoge",
                                     bar: 42,
                                     baz: true,
                                     qux: .init(
                                        quux: "fuga",
                                        corge: 3.14,
                                        grault: false,
                                        garply: [
                                            "spam",
                                            "ham",
                                            "eggs",
                                        ]
                                     )
                                    )
        )
    }

    /// Example function for intercepting `URLSession.shared` requests
    @available(watchOS 9, *)
    func testSharedSession() async throws {
        registerStubForSharedSession()
        defer { unregisterStubForSharedSession() }

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz"))
            .responseData(Data("Hello world!".utf8))

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }
}

private extension StubNetworkKitTests {
    struct Sample: Decodable, Equatable, Sendable {
        var foo: String
        var bar: Int
        var baz: Bool
        var qux: Qux
    }
}

private extension StubNetworkKitTests.Sample {
    struct Qux: Decodable, Equatable, Sendable {
        var quux: String
        var corge: Decimal
        var grault: Bool
        var garply: [String]
    }
}
