public protocol StubConditionType {
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
