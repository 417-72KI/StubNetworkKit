import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@resultBuilder
public struct StubConditionBuilder {
    public static func buildBlock(_ components: any StubCondition...) -> any StubCondition {
        components.reduce(alwaysTrue) { AnyStubCondition($0) && AnyStubCondition($1) }
    }

    public static func buildOptional(_ component: (any StubCondition)?) -> any StubCondition {
        component ?? alwaysTrue
    }

    public static func buildEither(first component: any StubCondition) -> any StubCondition {
        component
    }

    public static func buildEither(second component: any StubCondition) -> any StubCondition {
        component
    }
}

// MARK: -
public func stubCondition(@StubConditionBuilder builder: () -> any StubCondition) -> any StubCondition {
    builder()
}

@discardableResult
public func stub(@StubConditionBuilder builder: () -> any StubCondition,
                 withResponse stubResponse: @escaping @Sendable (URLRequest) -> StubResponse) -> Stub {
    stub(stubCondition(builder: builder),
         withResponse: stubResponse)
}

@discardableResult
public func stub(@StubConditionBuilder builder: () -> any StubCondition) -> Stub {
    stub(stubCondition(builder: builder),
         withResponse: errorResponse(.unimplemented))
}
