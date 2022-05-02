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

    func testDefaultStubSession() throws {
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

    // MARK: - Alamofire
    #if canImport(Alamofire)
    func testAlamofire() throws {
        let config = URLSessionConfiguration.af.default
        registerStub(to: config)
        let session = Session(configuration: config)

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let e = expectation(description: "Alamofire")
        session.request(url)
            .responseString { res in
                XCTAssertEqual(res.value, "Hello world!")
                XCTAssertEqual(res.response?.statusCode, 200)
                XCTAssertNil(res.error)
                e.fulfill()
            }.resume()
        waitForExpectations(timeout: 5)
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

    func testAPIKit() throws {
        let config = URLSessionConfiguration.ephemeral
        registerStub(to: config)
        let adapter = URLSessionAdapter(configuration: config)

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: #"{"status": 200}"#.data(using: .utf8)!)
        }

        let e = expectation(description: "APIKit")
        Session(adapter: adapter)
            .send(FakeRequest()) {
                do {
                    let response = try $0.get()
                    XCTAssertEqual(response.status, 200)
                } catch {
                    XCTFail(error.localizedDescription)
                }
                e.fulfill()
            }?
            .resume()
        waitForExpectations(timeout: 5)
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

        let e = expectation(description: "Moya")
        provider.request(.init()) {
            do {
                let response = try $0.get()
                XCTAssertEqual(String(data: response.data, encoding: .utf8), "Hello world!")
                XCTAssertEqual(response.statusCode, 200)
            } catch {
                XCTFail(error.localizedDescription)
            }
            e.fulfill()
        }
        waitForExpectations(timeout: 5)

    }
    #endif
}
