struct ANDStubCondition: StubCondition {
    let c1: AnyStubCondition
    let c2: AnyStubCondition
}

extension ANDStubCondition {
    var matcher: StubMatcher {
        c1.matcher && c2.matcher
    }
}

extension ANDStubCondition {
    static func == (lhs: ANDStubCondition, rhs: ANDStubCondition) -> Bool {
        lhs.c1 == rhs.c1 && lhs.c2 == rhs.c2
        || lhs.c1 == rhs.c2 && lhs.c2 == rhs.c1
    }
}

// MARK: -
public func && <T1: StubCondition, T2: StubCondition>(lhs: T1, rhs: T2) -> some StubCondition {
    ANDStubCondition(c1: AnyStubCondition(lhs), c2: AnyStubCondition(rhs))
}
