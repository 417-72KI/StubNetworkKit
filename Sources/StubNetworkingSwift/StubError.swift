import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum StubError: Error {
    case unexpectedRequest(URLRequest)
}
