#if canImport(Alamofire)
import XCTest
import StubNetworkKit
import Alamofire

final class AlamofireSampleTests: XCTestCase {
    private var client: AlamofireSample!

    override func setUpWithError() throws {
        let config = URLSessionConfiguration.af.ephemeral
        registerStub(to: config)
        client = AlamofireSample(Session(configuration: config))
    }

    override func tearDownWithError() throws {
        clearStubs()
    }

    func testFetch() async throws {
        stub {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz")
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

    func testMultipartForm() async throws {
        stub {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz")
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
}

private final class AlamofireSample {
    private let session: Session

    init(_ session: Session = .default) {
        self.session = session
    }
}

extension AlamofireSample {
    func fetch() async throws -> SampleEntity {
        let url = URL(string: "https://foo.bar/baz")!
        return try await session.request(url)
            .serializingDecodable(SampleEntity.self)
            .response
            .result
            .get()
    }

    func form() async throws -> SampleEntity {
        try await session.upload(
            multipartFormData: { formData in
                formData.append("fuga".data(using: .utf8)!, withName: "hoge")
                formData.append("hogera".data(using: .utf8)!, withName: "piyo")
            },
            with: URLRequest(url: URL(string: "https://foo.bar/baz")!)
        )
        .serializingDecodable(SampleEntity.self)
        .response
        .result
        .get()
    }
}
#endif
