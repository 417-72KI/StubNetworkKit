import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - URLQueryItem
extension Sequence where Element == URLQueryItem {
    func first(forName name: String) -> Element? {
        first(where: { $0.name == name })
    }
}

// MARK: - KeyPath
extension Sequence {
    public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }

    public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T?>) -> [Element] {
        sorted {
            guard let l = $0[keyPath: keyPath],
                  let r = $1[keyPath: keyPath] else { return false }
            return l < r
        }
    }
}
