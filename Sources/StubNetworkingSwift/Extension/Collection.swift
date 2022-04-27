import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Collection where Element == URLQueryItem {
    func first(forName name: String) -> Element? {
        first(where: { $0.name == name })
    }
}
