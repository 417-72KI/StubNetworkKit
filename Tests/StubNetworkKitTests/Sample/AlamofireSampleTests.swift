import XCTest
import StubNetworkKit
import Alamofire

final class AlamofireSampleTests: XCTestCase {
    func testFetch() async throws {
        let config = URLSessionConfiguration.af.ephemeral
        registerStub(to: config)

        stub {
            Scheme.is("https")
            Host.is("foo.bar")
            Path.is("/baz")
        }.responseData(withFilePath: "Fixtures/sample",
                       extension: "json",
                       in: .module)

        let sample = AlamofireSample(Session(configuration: config))
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
}
