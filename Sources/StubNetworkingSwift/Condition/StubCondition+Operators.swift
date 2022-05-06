// MARK: - OR
public func || (lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> StubCondition {
    { lhs($0) || rhs($0) }
}

infix operator ||= : AssignmentPrecedence
public func ||= (lhs: inout StubCondition, rhs: @escaping StubCondition) {
    lhs = lhs || rhs
}

// MARK: - AND
public func && (lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> StubCondition {
    { lhs($0) && rhs($0) }
}

infix operator &&= : AssignmentPrecedence
public func &&= (lhs: inout StubCondition, rhs: @escaping StubCondition) {
    lhs = lhs && rhs
}

// MARK: - NOT
public prefix func ! (expr: @escaping StubCondition) -> StubCondition {
    { !expr($0) }
}
