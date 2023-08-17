import XCTest
import StubNetworkKit
import APIKit

@testable import APIKitSample

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
