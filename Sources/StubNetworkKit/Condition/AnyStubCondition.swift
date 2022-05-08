struct AnyStubCondition: StubCondition {
    private let base: StubCondition

    init(_ base: StubCondition) {
        self.base = base
    }

    var matcher: StubMatcher { base.matcher }
}
