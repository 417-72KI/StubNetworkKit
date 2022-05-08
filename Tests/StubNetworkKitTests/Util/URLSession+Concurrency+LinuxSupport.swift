import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS)) && compiler(>=5.6) && canImport(_Concurrency)
extension URLSession {
    func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { cont in
            dataTask(with: url) { data, response, error in
                if let error = error {
                    cont.resume(throwing: error)
                    return
                }
                cont.resume(returning: (data!, response!))
            }.resume()
        }
    }
}
#endif
