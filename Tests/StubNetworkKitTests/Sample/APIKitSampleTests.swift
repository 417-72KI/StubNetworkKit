#if canImport(APIKit)
import XCTest
import StubNetworkKit
import APIKit

final class APIKitSampleTests: XCTestCase {
    private var client: APIKitSample!

    override func setUpWithError() throws {
        let config = URLSessionConfiguration.ephemeral
        registerStub(to: config)
        let adapter = URLSessionAdapter(configuration: config)
        client = APIKitSample(Session(adapter: adapter))
    }

    override func tearDownWithError() throws {
        clearStubs()
    }

    func testFetch() async throws {
        stub {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz/qux")
        }.responseData(withFilePath: "Fixtures/sample",
                       extension: "json",
                       in: .module)

        let result = try await client.fetch()
        XCTAssertEqual(result.foo, "hoge")
        XCTAssertEqual(result.bar, 42)
        XCTAssertTrue(result.baz)
        let child = result.qux
        XCTAssertEqual(child.quux, "fuga")
        XCTAssertEqual(child.corge, 3.14, accuracy: 0.01)
        XCTAssertFalse(child.grault)
        XCTAssertEqual(child.garply, ["spam", "ham", "eggs"])
    }

    // FIXME: When testing on watchOS, `StubURLProtocol.startLoading` isn't called, although `canInit` has been called.
    #if !os(watchOS)
    func testMultipartForm() async throws {
        stub {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz/qux")
            Body.isMultipartForm([
                "hoge": "fuga".data(using: .utf8)!,
                "piyo": "hogera".data(using: .utf8)!,
            ])
        }.responseData(withFilePath: "Fixtures/sample",
                       extension: "json",
                       in: .module)

        let result = try await client.form()
        XCTAssertEqual(result.foo, "hoge")
        XCTAssertEqual(result.bar, 42)
        XCTAssertTrue(result.baz)
        let child = result.qux
        XCTAssertEqual(child.quux, "fuga")
        XCTAssertEqual(child.corge, 3.14, accuracy: 0.01)
        XCTAssertFalse(child.grault)
        XCTAssertEqual(child.garply, ["spam", "ham", "eggs"])
    }
    #endif
}

private final class APIKitSample {
    private let session: Session

    init(_ session: Session = .shared) {
        self.session = session
    }
}

extension APIKitSample {
    func fetch() async throws -> SampleEntity {
        try await session.response(for: SampleRequest())
    }

    func form() async throws -> SampleEntity {
        try await session.response(for: SampleFormRequest())
    }
}

struct SampleRequest: Request {
    typealias Response = SampleEntity

    var baseURL: URL { URL(string: "https://foo.bar")! }
    var path: String { "/baz/qux" }
    var method: HTTPMethod { .get }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> SampleEntity {
        let data = try (object as? Data) ?? (try JSONSerialization.data(withJSONObject: object, options: []))
        return try JSONDecoder()
            .decode(Response.self, from: data)
    }
}

struct SampleFormRequest: Request {
    typealias Response = SampleEntity

    var baseURL: URL { URL(string: "https://foo.bar")! }
    var path: String { "/baz/qux" }
    var method: HTTPMethod { .post }
    var bodyParameters: BodyParameters? {
        MultipartFormDataBodyParameters(parts: [
            .init(data: "fuga".data(using: .utf8)!, name: "hoge"),
            .init(data: "hogera".data(using: .utf8)!, name: "piyo")
        ])
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> SampleEntity {
        let data = try (object as? Data) ?? (try JSONSerialization.data(withJSONObject: object, options: []))
        return try JSONDecoder()
            .decode(Response.self, from: data)
    }
}
#endif
