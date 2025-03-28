import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
import StubNetworkKit

#if !os(watchOS)
@Suite
final class BodyTests {
    private let url = URL(string: "https://localhost/foo/bar")!

    init() throws {
        StubNetworking.option(printDebugLog: true,
                              debugConditions: true)
    }

    @Test func bodyIsData() async throws {
        let data = Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        stub(Body.is(data))
            .responseJson(["status": 200])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data

        #expect(Body.is(data).matcher(request))
    }

    @Test func bodyIsJson() async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"foo": "bar", "baz": 0}"#.utf8)

        #expect(Body.isJson(["foo": "bar", "baz": 0]).matcher(request))
    }

    @Test func bodyIsForm() async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(#"foo=bar&baz=0&qux=%20"#.utf8)

        #expect(Body.isForm(["foo": "bar", "baz": "0", "qux": " "]).matcher(request))
    }

    @Test func bodyIsMultipartForm() async throws {
        #if os(Linux)
        // FIXME: There is no way to get body stream with `URLSessionUploadTask` in Linux.
        return withKnownIssue {
            Issue.record("Unsupported platform for test.")
        }
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

        #expect(Body.isMultipartForm([
            "foo": Data("bar".utf8),
            "baz": Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
        ]).matcher(request))
    }
}
#endif
