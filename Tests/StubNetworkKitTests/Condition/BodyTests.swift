import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkKit

@available(watchOS, unavailable)
final class BodyTests: XCTestCase {
    private let url = URL(string: "https://localhost/foo/bar")!

    override func setUpWithError() throws {
        StubNetworking.option = .init(printDebugLog: true,
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
        request.httpBody = #"{"foo": "bar", "baz": 0}"#.data(using: .utf8)

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
        request.httpBody = #"foo=bar&baz=0&qux=%20"#.data(using: .utf8)

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
            "foo": "bar".data(using: .utf8)!,
            "baz": Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
        ])).responseJson(["status": 200])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = [
            "--\(boundary)\r\n".data(using: .utf8)!,
            "Content-Disposition: form-data; name=\"foo\"\r\n".data(using: .utf8)!,
            "\r\n".data(using: .utf8)!,
            "bar\r\n".data(using: .utf8)!,
            "--\(boundary)\r\n".data(using: .utf8)!,
            "Content-Disposition: form-data; name=\"baz\"\r\n".data(using: .utf8)!,
            "\r\n".data(using: .utf8)!,
            Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
            "\r\n".data(using: .utf8)!,
            "--\(boundary)--\r\n".data(using: .utf8)!,
        ].reduce(Data(), +)

        let response = try await defaultStubSession.data(for: request)
        XCTAssertEqual(#"{"status":200}"#, String(data: response.0, encoding: .utf8))
        XCTAssertEqual((response.1 as? HTTPURLResponse)?.statusCode, 200)
    }
}
