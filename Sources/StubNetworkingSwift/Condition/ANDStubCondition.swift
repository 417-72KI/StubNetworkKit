struct ANDStubCondition<T1: StubCondition, T2: StubCondition>: StubCondition {
    let c1: T1
    let c2: T2
}

extension ANDStubCondition {
    var matcher: StubMatcher {
        c1.matcher && c2.matcher
    }
}

extension ANDStubCondition: Equatable where T1: Equatable, T2: Equatable {
}

// MARK: -
public func && <T1: StubCondition, T2: StubCondition>(lhs: T1, rhs: T2) -> some StubCondition {
    ANDStubCondition(c1: lhs, c2: rhs)
}
