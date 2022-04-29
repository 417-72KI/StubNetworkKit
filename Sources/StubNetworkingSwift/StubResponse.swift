import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct StubResponse {
    public let data: Data?
    public let urlResponse: URLResponse?

    public let error: Error?
}

public extension StubResponse {
    init(error: Error) {
        data = nil
        urlResponse = nil
        self.error = error
    }
}
