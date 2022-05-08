// MARK: - OR
public func || (lhs: @escaping StubMatcher, rhs: @escaping StubMatcher) -> StubMatcher {
    { lhs($0) || rhs($0) }
}

infix operator ||= : AssignmentPrecedence
public func ||= (lhs: inout StubMatcher, rhs: @escaping StubMatcher) {
    lhs = lhs || rhs
}

// MARK: - AND
public func && (lhs: @escaping StubMatcher, rhs: @escaping StubMatcher) -> StubMatcher {
    { lhs($0) && rhs($0) }
}

infix operator &&= : AssignmentPrecedence
public func &&= (lhs: inout StubMatcher, rhs: @escaping StubMatcher) {
    lhs = lhs && rhs
}

// MARK: - NOT
public prefix func ! (expr: @escaping StubMatcher) -> StubMatcher {
    { !expr($0) }
}
