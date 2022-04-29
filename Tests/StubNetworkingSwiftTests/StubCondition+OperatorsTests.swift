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
        ParameterizedTest.option = ParameterizedTest.Option(
            traceTable: .markdown,
            saveTableToAttachement: .markdown
        )
    }

    func testOr() throws {
        func or(lhs: @escaping StubCondition, rhs: @escaping StubCondition) -> Bool {
            let req = URLRequest(url: URL(string: "foo://bar")!)
            return (lhs || rhs)(req)
        }

        assert(to: or) {
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
        assert(to: and) {
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
