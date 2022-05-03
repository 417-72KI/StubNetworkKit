import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkingSwift

#if canImport(Alamofire)
import Alamofire
#endif
#if canImport(APIKit)
import APIKit
#endif
#if canImport(Moya)
import Moya
#endif

final class StubNetworkingSwiftTests: XCTestCase {
    override func setUp() {
        StubNetworking.option = .init(printDebugLog: true,
                                      debugConditions: true)
    }

    override func tearDown() {
        clearStubs()
    }

    func testDefaultStubSession_basic() throws {
        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let e = expectation(description: "URLSession")
        defaultStubSession.dataTask(with: url) { data, response, error in
            XCTAssertEqual(data.flatMap({ String(data: $0, encoding: .utf8) }), "Hello world!")
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertNil(error)
            e.fulfill()
        }.resume()
        waitForExpectations(timeout: 5)
    }

    func testDefaultStubSession_resultBuilder() throws {
        let url = URL(string: "foo://bar/baz")!

        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isGet()
        } withResponse: { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let e = expectation(description: "URLSession")
        defaultStubSession.dataTask(with: url) { data, response, error in
            XCTAssertEqual(data.flatMap({ String(data: $0, encoding: .utf8) }), "Hello world!")
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertNil(error)
            e.fulfill()
        }.resume()
        waitForExpectations(timeout: 5)
    }

    // FIXME: When testing on watchOS, `StubURLProtocol.startLoading` isn't called, although `canInit` has been called.
    #if !os(watchOS)
    func testSharedSession() throws {
        registerStubForSharedSession()
        defer { unregisterStubForSharedSession() }

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let e = expectation(description: "URLSession")
        URLSession.shared.dataTask(with: url) { data, response, error in
            XCTAssertEqual(data.flatMap({ String(data: $0, encoding: .utf8) }), "Hello world!")
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertNil(error)
            e.fulfill()
        }.resume()
        waitForExpectations(timeout: 5)
    }
    #endif

    #if compiler(>=5.6) && canImport(_Concurrency)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func testDefaultStubSessionWithConcurrency() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let (data, response) = try await defaultStubSession.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }

    #if !os(watchOS)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
    func testSharedSessionWithConcurrency() async throws {
        registerStubForSharedSession()
        defer { unregisterStubForSharedSession() }

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Hello world!")
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }
    #endif
    #endif

    // MARK: - Alamofire
    #if canImport(Alamofire)
    func testAlamofire() throws {
        let config = URLSessionConfiguration.af.ephemeral
        registerStub(to: config)
        let session = Session(configuration: config)

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        var result: AFDataResponse<String>!
        let e = expectation(description: "Alamofire")
        session.request(url)
            .responseString {
                result = $0
                e.fulfill()
            }.resume()
        waitForExpectations(timeout: 5)

        XCTAssertEqual(result?.value, "Hello world!")
        XCTAssertEqual(result?.response?.statusCode, 200)
        XCTAssertNil(result?.error)
    }

    #if compiler(>=5.6) && canImport(_Concurrency)
    func testAlamofireWithConcurrency() async throws {
        let config = URLSessionConfiguration.af.ephemeral
        registerStub(to: config)
        let session = Session(configuration: config)

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let request = session.request(url)
        let result = await request
            .serializingString()
            .response
        XCTAssertEqual(result.value, "Hello world!")
        XCTAssertEqual(result.response?.statusCode, 200)
        XCTAssertNil(result.error)
    }
    #endif
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

    func testAPIKit() throws {
        let config = URLSessionConfiguration.ephemeral
        registerStub(to: config)
        let adapter = URLSessionAdapter(configuration: config)

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: #"{"status": 200}"#.data(using: .utf8)!)
        }
        var result: Result<FakeRequest.Response, SessionTaskError>!
        let e = expectation(description: "APIKit")
        Session(adapter: adapter)
            .send(FakeRequest()) {
                result = $0
                e.fulfill()
            }?
            .resume()
        waitForExpectations(timeout: 5)

        let response = try XCTUnwrap(result).get()
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

    func testMoya() throws {
        let config = URLSessionConfiguration.af.default
        registerStub(to: config)
        let session = Session(configuration: config)
        let provider = MoyaProvider<FakeService>(session: session)

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        var result: Result<Response, MoyaError>!
        let e = expectation(description: "Moya")
        provider.request(.init()) {
            result = $0
            e.fulfill()
        }
        waitForExpectations(timeout: 5)

        let response = try XCTUnwrap(result).get()
        XCTAssertEqual(String(data: response.data, encoding: .utf8), "Hello world!")
        XCTAssertEqual(response.statusCode, 200)
    }
    #endif
}
