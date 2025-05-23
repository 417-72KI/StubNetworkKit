import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum StubError: LocalizedError {
    case unexpectedRequest(URLRequest)
    case responseInitializingFailed(URL, Int, [String: String]?)
    case unimplemented
    case unexpectedError(any Error)
}

extension StubError {
    public var errorDescription: String? {
        switch self {
        case let .unexpectedRequest(req):
            "Unexpected request: \(req)"
        case let .responseInitializingFailed(url, statusCode, headers):
            """
            Failed to initialize response.
            Params:
                - URL: \(url)
                - Status code: \(statusCode)
                - Headers: \(headers ?? [:])
            """
        case .unimplemented:
            "Unimplemented"
        case let .unexpectedError(origin):
            """
            Unexpected error.
            Original: `\(origin)`
            """
        }
    }
}
