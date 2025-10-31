import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import os

// based on https://github.com/417-72KI/MultipartFormDataParser/blob/main/Tests/MultipartFormDataParserTests/StubURLProtocol.swift
final class StubURLProtocol: URLProtocol {
    private static let stubs = OSAllocatedUnfairLock(initialState: [Stub]())

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            guard let response = stub(with: request)?.response(request),
                  let url = request.url else {
                throw StubError.unexpectedRequest(request)
            }
            debugLog("Stub response detected for request: \(request)")
            let (data, statusCode, headers) = try response.get()
            debugLog("""
                data: \(data.flatMap { String(data: $0, encoding: .utf8) } ?? data?.base64EncodedString() ?? "(nil)")
                status code: \(statusCode)
                """)

            guard let urlResponse = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            ) else { throw StubError.responseInitializingFailed(url, statusCode, headers) }

            client?.urlProtocol(self,
                                didReceive: urlResponse,
                                cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // no-op
    }
}

extension StubURLProtocol {
    static func register(_ stub: Stub) {
        stubs.withLock { stubs in
            stubs.append(stub)
        }
    }

    static func reset() {
        stubs.withLock {
            $0 = []
        }
    }
}

private extension StubURLProtocol {
    func stub(with request: URLRequest) -> Stub? {
        Self.stubs.withLock {
            $0.last(where: { $0.matcher(request) })
        }
    }
}
