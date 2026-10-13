import Foundation

#if canImport(os)
import os

final class Lock<State: Sendable>: Sendable {
    let lock: OSAllocatedUnfairLock<State>

    init(_ initialState: State) {
        lock = .init(initialState: initialState)
    }
}

extension Lock {
    @inlinable
    func withLock<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R {
        try lock.withLock(body)
    }
}
#elseif canImport(Synchronization)
import Synchronization

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
final class Lock<Value: Sendable>: Sendable {
    let lock: Mutex<Value>

    init(_ initialValue: Value) {
        lock = .init(initialValue)
    }
}

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension Lock {
    @inlinable
    func withLock<Result: ~Copyable, E: Error>(_ body: (inout sending Value) throws(E) -> sending Result) throws(E) -> sending Result {
        try lock.withLock(body)
    }
}
#endif
