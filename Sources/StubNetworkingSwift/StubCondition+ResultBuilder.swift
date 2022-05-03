import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@resultBuilder
public struct StubConditionBuilder {
    public static func buildBlock(_ components: StubCondition...) -> StubCondition {
        components.reduce({ _ in true }) { $0 && $1 }
    }

    public static func buildOptional(_ component: StubCondition?) -> StubCondition {
        component ?? { _ in true }
    }

    public static func buildEither(first component: @escaping StubCondition) -> StubCondition {
        component
    }

    public static func buildEither(second component: @escaping StubCondition) -> StubCondition {
        component
    }
}

// MARK: -
public func stubCondition(@StubConditionBuilder builder: () -> StubCondition) -> StubCondition {
    builder()
}

@discardableResult
public func stub(@StubConditionBuilder builder: () -> StubCondition,
                 withResponse stubResponse: @escaping (URLRequest) -> StubResponse) -> Stub {
    stub(stubCondition(builder: builder), withResponse: stubResponse)
}
