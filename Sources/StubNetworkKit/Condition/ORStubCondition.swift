struct ORStubCondition: StubCondition {
    let c1: AnyStubCondition
    let c2: AnyStubCondition
}

extension ORStubCondition {
    var matcher: StubMatcher {
        c1.matcher || c2.matcher
    }
}

extension ORStubCondition {
    static func == (lhs: ORStubCondition, rhs: ORStubCondition) -> Bool {
        lhs.c1 == rhs.c1 && lhs.c2 == rhs.c2
        || lhs.c1 == rhs.c2 && lhs.c2 == rhs.c1
    }
}

// MARK: -
public func || <T1: StubCondition, T2: StubCondition>(lhs: T1, rhs: T2) -> some StubCondition {
    ORStubCondition(c1: AnyStubCondition(lhs), c2: AnyStubCondition(rhs))
}
