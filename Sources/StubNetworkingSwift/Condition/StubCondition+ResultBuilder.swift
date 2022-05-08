import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@resultBuilder
public struct StubConditionBuilder {
    public static func buildBlock(_ components: StubCondition...) -> StubCondition {
        components.reduce(alwaysTrue) { AnyStubCondition($0) && AnyStubCondition($1) }
    }

    public static func buildOptional(_ component: StubCondition?) -> StubCondition {
        component ?? alwaysTrue
    }

    public static func buildEither(first component: StubCondition) -> StubCondition {
        component
    }

    public static func buildEither(second component: StubCondition) -> StubCondition {
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
    stub(stubCondition(builder: builder),
         withResponse: stubResponse)
}

@discardableResult
public func stub(@StubConditionBuilder builder: () -> StubCondition) -> Stub {
    stub(stubCondition(builder: builder),
         withResponse: errorResponse(.unimplemented))
}
