import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkingSwift
import ParameterizedTestUtil

final class StubConditionTests: XCTestCase {
    func testMethod() throws {
        let methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD"]
        let matchers = [
            Method.isGet, Method.isPost, Method.isPut, Method.isPatch, Method.isDelete, Method.isHead]

        runAll(
            zip(methods, matchers).map {
                var req = URLRequest(url: URL(string: "https://foo.bar")!)
                req.httpMethod = $0
                return expect($1(req), is: true)
            }
        )
    }
}
