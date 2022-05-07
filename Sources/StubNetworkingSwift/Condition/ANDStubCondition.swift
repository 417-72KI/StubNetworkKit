struct ANDStubCondition<T1: StubConditionType, T2: StubConditionType>: StubConditionType {
    let c1: T1
    let c2: T2
}

extension ANDStubCondition {
    var condition: StubCondition {
        c1.condition && c2.condition
    }
}

extension ANDStubCondition: Equatable where T1: Equatable, T2: Equatable {
}

// MARK: -
public func && <T1: StubConditionType, T2: StubConditionType>(lhs: T1, rhs: T2) -> some StubConditionType {
    ANDStubCondition(c1: lhs, c2: rhs)
}
