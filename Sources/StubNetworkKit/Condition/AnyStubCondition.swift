struct AnyStubCondition: StubCondition {
    private let base: any StubCondition

    init(_ base: any StubCondition) {
        self.base = base
    }

    var matcher: StubMatcher { base.matcher }
}
