#if canImport(APIKit)
import XCTest
import StubNetworkKit
import APIKit

final class APIKitSampleTests: XCTestCase {
    func testFetch() async throws {
        let config = URLSessionConfiguration.ephemeral
        registerStub(to: config)
        let adapter = URLSessionAdapter(configuration: config)

        stub {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz/qux")
        }.responseData(withFilePath: "Fixtures/sample",
                       extension: "json",
                       in: .module)

        let sample = APIKitSample(Session(adapter: adapter))
        let result = try await sample.fetch()
        XCTAssertEqual(result.foo, "hoge")
        XCTAssertEqual(result.bar, 42)
        XCTAssertTrue(result.baz)
        let child = result.qux
        XCTAssertEqual(child.quux, "fuga")
        XCTAssertEqual(child.corge, 3.14, accuracy: 0.01)
        XCTAssertFalse(child.grault)
        XCTAssertEqual(child.garply, ["spam", "ham", "eggs"])
    }
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
#endif
