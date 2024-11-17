import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    init(url: URL, method: String, headers: [String: String] = [:], body: Data? = nil) {
        self.init(url: url, cachePolicy: .useProtocolCachePolicy)
        self.httpMethod = method.uppercased()
        headers.forEach {
            self.addValue($1, forHTTPHeaderField: $0)
        }
        self.httpBody = body
    }
}
