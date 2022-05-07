struct AnyStubCondition: StubConditionType {
    private let base: StubConditionType

    init(_ base: StubConditionType) {
        self.base = base
    }

    var condition: StubCondition { base.condition }
}
