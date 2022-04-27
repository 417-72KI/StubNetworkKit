public func || (lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> StubCondition {
    { lhs($0) || rhs($0) }
}

public func && (lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> StubCondition {
    { lhs($0) && rhs($0) }
}

public prefix func ! (expr: @escaping StubCondition) -> StubCondition {
    { !expr($0) }
}
