import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkKit
import SwiftParamTest

final class StubMatcher_OperatorsTests: XCTestCase {
    private let trueMatcher: StubMatcher = { _ in true }
    private let falseMatcher: StubMatcher = { _ in false }

    override func setUp() {
        ParameterizedTest.option = .init(traceTable: .markdown,
                                         saveTableToAttachement: .markdown)
        StubNetworking.option(printDebugLog: true,
                              debugConditions: true)
    }

    func testOr() throws {
        func or(lhs: @escaping StubMatcher, rhs: @escaping StubMatcher) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            return (lhs || rhs)(req)
        }
        func orAssign(lhs: @escaping StubMatcher, rhs: @escaping StubMatcher) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            var condition = lhs
            condition ||= rhs
            return condition(req)
        }

        assert(to: or) {
            expect((trueMatcher, trueMatcher) ==> true)
            expect((falseMatcher, trueMatcher) ==> true)
            expect((trueMatcher, falseMatcher) ==> true)
            expect((falseMatcher, falseMatcher) ==> false)
        }
        assert(to: orAssign) {
            expect((trueMatcher, trueMatcher) ==> true)
            expect((falseMatcher, trueMatcher) ==> true)
            expect((trueMatcher, falseMatcher) ==> true)
            expect((falseMatcher, falseMatcher) ==> false)
        }
    }
    func testAnd() throws {
        func and(lhs: @escaping StubMatcher, rhs: @escaping StubMatcher) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            return (lhs && rhs)(req)
        }
        func andAssign(lhs: @escaping StubMatcher, rhs: @escaping StubMatcher) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            var condition = lhs
            condition &&= rhs
            return condition(req)
        }

        assert(to: and) {
            expect((trueMatcher, trueMatcher) ==> true)
            expect((falseMatcher, trueMatcher) ==> false)
            expect((trueMatcher, falseMatcher) ==> false)
            expect((falseMatcher, falseMatcher) ==> false)
        }
        assert(to: andAssign) {
            expect((trueMatcher, trueMatcher) ==> true)
            expect((falseMatcher, trueMatcher) ==> false)
            expect((trueMatcher, falseMatcher) ==> false)
            expect((falseMatcher, falseMatcher) ==> false)
        }
    }

    func testNot() throws {
        func not(expr: @escaping StubMatcher) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            return (!expr)(req)
        }
        assert(to: not) {
            expect(trueMatcher ==> false)
            expect(falseMatcher ==> true)
        }
    }
}
