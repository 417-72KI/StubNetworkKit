import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// based on https://github.com/417-72KI/MultipartFormDataParser/blob/main/Tests/MultipartFormDataParserTests/StubURLProtocol.swift
final class StubURLProtocol: URLProtocol {
    static var stubs: [Stub] = []

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            guard let response = stub(with: request)?.response(request),
                  let url = request.url else {
                throw StubError.unexpectedRequest(request)
            }
            switch response {
            case let .success(data, statusCode, headers):
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
            case let .failure(error):
                throw error
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // no-op
    }
}

private extension StubURLProtocol {
    func stub(with request: URLRequest) -> Stub? {
        Self.stubs
            .last(where: { $0.condition(request) })
    }
}
