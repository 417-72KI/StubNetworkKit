import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkingSwift
import SwiftParamTest

final class StubCondition_OperatorsTests: XCTestCase {
    private let trueMatcher: StubCondition = { _ in true }
    private let falseMatcher: StubCondition = { _ in false }

    override func setUp() {
        ParameterizedTest.option = .init(traceTable: .markdown,
                                         saveTableToAttachement: .markdown)
        StubNetworking.option = .init(printDebugLog: true,
                                      debugConditions: true)
    }

    func testOr() throws {
        func or(lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            return (lhs || rhs)(req)
        }
        func orAssign(lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> Bool {
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
        func and(lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            return (lhs && rhs)(req)
        }
        func andAssign(lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> Bool {
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
        func not(expr: @escaping StubCondition) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            return (!expr)(req)
        }
        assert(to: not) {
            expect(trueMatcher ==> false)
            expect(falseMatcher ==> true)
        }
    }
}
