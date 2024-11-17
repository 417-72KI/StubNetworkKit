struct AnyStubCondition: StubCondition {
    private let base: any StubCondition

    init(_ base: any StubCondition) {
        self.base = base
    }

    var matcher: StubMatcher { base.matcher }
}

extension AnyStubCondition {
    static func == (lhs: AnyStubCondition, rhs: AnyStubCondition) -> Bool {
        switch (lhs.base, rhs.base) {
        case let (lhs as _Scheme, rhs as _Scheme): lhs == rhs
        case let (lhs as _Host, rhs as _Host): lhs == rhs
        case let (lhs as _Path, rhs as _Path): lhs == rhs
        case let (lhs as _PathExtension, rhs as _PathExtension): lhs == rhs
        case let (lhs as _Method, rhs as _Method): lhs == rhs
        case let (lhs as _Header, rhs as _Header): lhs == rhs
        case let (lhs as _Body, rhs as _Body): lhs == rhs
        case let (lhs as _QueryParams, rhs as _QueryParams): lhs == rhs
        case let (lhs as _AlwaysTrue, rhs as _AlwaysTrue): lhs == rhs
        case let (lhs as _AlwaysFalse, rhs as _AlwaysFalse): lhs == rhs
        case let (lhs as ORStubCondition, rhs as ORStubCondition): lhs == rhs
        case let (lhs as ANDStubCondition, rhs as ANDStubCondition): lhs == rhs
        case let (lhs as AnyStubCondition, rhs as AnyStubCondition): lhs == rhs
        case let (lhs as AnyStubCondition, _): lhs == rhs
        case let (_, rhs as AnyStubCondition): lhs == rhs
        default: false
        }
    }

    func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}
