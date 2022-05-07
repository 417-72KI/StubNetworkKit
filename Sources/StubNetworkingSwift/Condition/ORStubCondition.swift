struct ORStubCondition<T1: StubConditionType, T2: StubConditionType>: StubConditionType {
    let c1: T1
    let c2: T2
}

extension ORStubCondition {
    var condition: StubCondition {
        c1.condition || c2.condition
    }
}

// MARK: -
public func || <T1: StubConditionType, T2: StubConditionType>(lhs: T1, rhs: T2) -> some StubConditionType {
    ORStubCondition(c1: lhs, c2: rhs)
}
