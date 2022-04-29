import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// based on https://github.com/417-72KI/MultipartFormDataParser/blob/main/Tests/MultipartFormDataParserTests/StubURLProtocol.swift
final class StubURLProtocol: URLProtocol {
    typealias Stub = (StubCondition, (URLRequest) -> StubResponse)

    static var stubs: [Stub] = [] {
        didSet {
            print(stubs)
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            guard let stubResponse = Self.stubs
                .last(where: { $0.0(request) })?.1(request) else {
                throw StubError.unexpectedRequest(request)
            }
            let data = stubResponse.data
            guard let response = stubResponse.urlResponse else {
                throw StubError.unimplemented
            }

            client?.urlProtocol(self,
                                didReceive: response,
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

}
