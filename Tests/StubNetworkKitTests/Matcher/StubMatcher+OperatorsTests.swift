import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
import StubNetworkKit

@Suite struct StubMatcher_OperatorsTests {
    init() {
        StubNetworking.option(printDebugLog: true,
                              debugConditions: true)
    }

    @Test(arguments: [
        (true, true, true),
        (false, true, true),
        (true, false, true),
        (false, false, false),
    ])
    func or(_ lhs: Bool, rhs: Bool, _ expected: Bool) throws {
        let matcher1: StubMatcher = { _ in lhs }
        let matcher2: StubMatcher = { _ in rhs }

        let req = URLRequest(url: URL(string: "foo://bar")!)

        #expect((matcher1 || matcher2)(req) == expected)

        var condition = matcher1
        condition ||= matcher2
        #expect(condition(req) == expected)
    }

    @Test(arguments: [
        (true, true, true),
        (false, true, false),
        (true, false, false),
        (false, false, false),
    ])
    func and(_ lhs: Bool, rhs: Bool, _ expected: Bool) throws {
        let matcher1: StubMatcher = { _ in lhs }
        let matcher2: StubMatcher = { _ in rhs }

        let req = URLRequest(url: URL(string: "foo://bar")!)

        #expect((matcher1 && matcher2)(req) == expected)

        var condition = matcher1
        condition &&= matcher2
        #expect(condition(req) == expected)
    }

    @Test(arguments: [
        (true, false),
        (false, true),
    ])
    func not(_ value: Bool, _ expected: Bool) throws {
        let matcher: StubMatcher = { _ in value }
        let req = URLRequest(url: URL(string: "foo://bar")!)
        #expect((!matcher)(req) == expected)
    }
}
