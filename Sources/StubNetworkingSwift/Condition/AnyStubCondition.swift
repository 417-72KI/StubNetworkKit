struct AnyStubCondition: StubConditionType {
    private let base: StubConditionType

    init(_ base: StubConditionType) {
        self.base = base
    }

    var matcher: StubMatcher { base.matcher }
}
