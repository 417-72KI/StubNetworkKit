import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkKit

#if canImport(Alamofire)
import Alamofire
#endif
#if canImport(APIKit)
import APIKit
#endif
#if canImport(Moya)
import Moya
#endif

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
final class StubNetworkKitTests: XCTestCase {
    override func setUp() {
        StubNetworking.option = .init(printDebugLog: true,
                                      debugConditions: true)
    }

    override func tearDown() {
        clearStubs()
    }

    /// Example function for basic implementation
    func testDefaultStubSession_basic() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz"))
            .responseData("Hello world!".data(using: .utf8)!)

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    /// Example function for basic implementation
    func testDefaultStubSession_basic_customResponse() async throws {
        let url = URL(string: "foo://bar/baz?q=1")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) {
            guard $0.url?.query == "q=1" else {
                return .error(.unexpectedRequest($0))
            }
            return .data("Hello world!".data(using: .utf8)!)
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
        }.responseData("Hello world!".data(using: .utf8)!)

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

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
            return .data("Hello world!".data(using: .utf8)!)
        }

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    /// Example function for using single function implementation
    func testDefaultStubSession_singleFunction() async throws {
        let url = URL(string: "foo://bar/baz")!
        stub(url: "foo://bar/baz", method: .get)
            .responseData("Hello world!".data(using: .utf8)!)

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
            .responseData("Hello world!".data(using: .utf8)!)

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
            return .json(fromFile: "Fixtures/sample", in: .module)
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
                                            "eggs"
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
            .responseData(withFilePath: "Fixtures/sample", extension: "json", in: .module)

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
                                            "eggs"
                                        ]
                                     )
                                    )
        )
    }
    // FIXME: When testing on watchOS, `StubURLProtocol.startLoading` isn't called, although `canInit` has been called.
    #if !os(watchOS)
    /// Example function for intercepting `URLSession.shared` requests
    func testSharedSession() async throws {
        registerStubForSharedSession()
        defer { unregisterStubForSharedSession() }

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz"))
            .responseData("Hello world!".data(using: .utf8)!)

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }
    #endif

    // MARK: - Alamofire
    #if canImport(Alamofire)
    func testAlamofire() async throws {
        let config = URLSessionConfiguration.af.ephemeral
        registerStub(to: config)
        let session = Session(configuration: config)

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz"))
            .responseData("Hello world!".data(using: .utf8)!)

        let result = await session.request(url)
            .serializingString()
            .response
        XCTAssertEqual(result.value, "Hello world!")
        XCTAssertEqual(result.response?.statusCode, 200)
        XCTAssertNil(result.error)
    }
    #endif

    // MARK: - APIKit
    #if canImport(APIKit)
    private struct FakeRequest: APIKit.Request {
        struct Response: Decodable {
            var status: Int
        }

        var baseURL: URL { URL(string: "foo://bar")! }
        var path: String { "/baz" }
        var method: APIKit.HTTPMethod { .get }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
            let data = try (object as? Data) ?? (try JSONSerialization.data(withJSONObject: object, options: []))
            return try JSONDecoder()
                .decode(Response.self, from: data)
        }
    }

    func testAPIKit() async throws {
        let config = URLSessionConfiguration.ephemeral
        registerStub(to: config)
        let adapter = URLSessionAdapter(configuration: config)

        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
        }.responseJson(["status": 200])

        let response = try await Session(adapter: adapter)
            .response(for: FakeRequest())
        XCTAssertEqual(response.status, 200)
    }
    #endif

    // MARK: - Moya
    #if canImport(Moya)
    private struct FakeService: TargetType {
        var baseURL: URL { URL(string: "foo://bar")! }
        var path: String { "/baz" }
        var method: Moya.Method { .get }
        var task: Task { .requestPlain }
        var headers: [String : String]? { [:] }
    }

    func testMoya() async throws {
        let config = URLSessionConfiguration.af.default
        registerStub(to: config)
        let session = Session(configuration: config)
        let provider = MoyaProvider<FakeService>(session: session)

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz"))
            .responseData("Hello world!".data(using: .utf8)!)

        let response = try await withCheckedThrowingContinuation { continuation in
            provider.request(.init()) {
                do {
                    continuation.resume(returning: try $0.get())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        XCTAssertEqual(String(data: response.data, encoding: .utf8), "Hello world!")
        XCTAssertEqual(response.statusCode, 200)
    }
    #endif
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
private extension StubNetworkKitTests {
    struct Sample: Decodable, Equatable {
        var foo: String
        var bar: Int
        var baz: Bool
        var qux: Qux

        struct Qux: Decodable, Equatable {
            var quux: String
            var corge: Decimal
            var grault: Bool
            var garply: [String]
        }
    }
}
