import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@resultBuilder
public struct StubConditionBuilder {
    public static func buildBlock(_ components: StubConditionType...) -> StubConditionType {
        components.reduce(alwaysTrue) { AnyStubCondition($0) && AnyStubCondition($1) }
    }

    public static func buildOptional(_ component: StubConditionType?) -> StubConditionType {
        component ?? alwaysTrue
    }

    public static func buildEither(first component: StubConditionType) -> StubConditionType {
        component
    }

    public static func buildEither(second component: StubConditionType) -> StubConditionType {
        component
    }
}

// MARK: -
public func stubCondition(@StubConditionBuilder builder: () -> StubConditionType) -> StubConditionType {
    builder()
}

@discardableResult
public func stub(@StubConditionBuilder builder: () -> StubConditionType,
                 withResponse stubResponse: @escaping (URLRequest) -> StubResponse) -> Stub {
    stub(stubCondition(builder: builder),
         withResponse: stubResponse)
}

@discardableResult
public func stub(@StubConditionBuilder builder: () -> StubConditionType) -> Stub {
    stub(stubCondition(builder: builder),
         withResponse: errorResponse(.unimplemented))
}
