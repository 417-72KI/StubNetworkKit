import Foundation

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
public func stub(@StubConditionBuilder builder: () -> StubCondition) -> StubCondition {
    builder()
}
