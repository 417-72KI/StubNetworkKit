import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkKit

#if !os(watchOS)
@available(watchOS, unavailable)
final class BodyTests: XCTestCase {
    private let url = URL(string: "https://localhost/foo/bar")!

    override func setUpWithError() throws {
        StubNetworking.option(printDebugLog: true,
                              debugConditions: true)
    }

    override func tearDownWithError() throws {
        clearStubs()
    }

    func testIs() async throws {
        let data = Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        stub(Body.is(data))
            .responseJson(["status": 200])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data

        let response = try await defaultStubSession.data(for: request)
        XCTAssertEqual(#"{"status":200}"#, String(data: response.0, encoding: .utf8))
        XCTAssertEqual((response.1 as? HTTPURLResponse)?.statusCode, 200)
    }

    func testIsJson() async throws {
        stub(Body.isJson(["foo": "bar", "baz": 0]))
            .responseJson(["status": 200])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"foo": "bar", "baz": 0}"#.utf8)

        let response = try await defaultStubSession.data(for: request)
        XCTAssertEqual(#"{"status":200}"#, String(data: response.0, encoding: .utf8))
        XCTAssertEqual((response.1 as? HTTPURLResponse)?.statusCode, 200)
    }

    func testIsForm() async throws {
        stub(Body.isForm(["foo": "bar", "baz": "0", "qux": " "]))
            .responseJson(["status": 200])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(#"foo=bar&baz=0&qux=%20"#.utf8)

        let response = try await defaultStubSession.data(for: request)
        XCTAssertEqual(#"{"status":200}"#, String(data: response.0, encoding: .utf8))
        XCTAssertEqual((response.1 as? HTTPURLResponse)?.statusCode, 200)
    }

    func testIsMultipartForm() async throws {
        #if os(Linux)
        // FIXME: There is no way to get body stream with `URLSessionUploadTask` in Linux.
        try XCTSkipIf(true, "Unsupported platform for test.")
        #endif

        stub(Body.isMultipartForm([
            "foo": Data("bar".utf8),
            "baz": Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
        ])).responseJson(["status": 200])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = [
            Data("--\(boundary)\r\n".utf8),
            Data("Content-Disposition: form-data; name=\"foo\"\r\n".utf8),
            Data("\r\n".utf8),
            Data("bar\r\n".utf8),
            Data("--\(boundary)\r\n".utf8),
            Data("Content-Disposition: form-data; name=\"baz\"\r\n".utf8),
            Data("\r\n".utf8),
            Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
            Data("\r\n".utf8),
            Data("--\(boundary)--\r\n".utf8),
        ].reduce(Data(), +)

        let response = try await defaultStubSession.data(for: request)
        XCTAssertEqual(#"{"status":200}"#, String(data: response.0, encoding: .utf8))
        XCTAssertEqual((response.1 as? HTTPURLResponse)?.statusCode, 200)
    }
}
#endif
