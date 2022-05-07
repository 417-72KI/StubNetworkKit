public protocol StubConditionType: Equatable {
    var condition: StubCondition { get }
}

// MARK: -
public let alwaysTrue: some StubConditionType = {
    _AlwaysTrue()
}()

final class _AlwaysTrue: StubConditionType {
    fileprivate init() {}
}

extension _AlwaysTrue {
    var condition: StubCondition { { _ in true } }
}

extension _AlwaysTrue {
    static func == (lhs: _AlwaysTrue, rhs: _AlwaysTrue) -> Bool {
        true
    }
}
