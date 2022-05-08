import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import StubNetworkKit
import SwiftParamTest
import XCTest

extension XCTestCase {
    @discardableResult
    func assert(to stub: Stub,
                @ParameterBuilder1<URLRequest, Bool> builder: () -> [Row1<URLRequest, Bool>]
    ) -> ParameterizedTestResult {
        assert(to: stub.matcher, builder: builder)
    }
}

func expect<R: Equatable>(
    _ row: Row1<URL, R>,
    file: StaticString = #file,
    line: UInt = #line
) -> Row1<URLRequest, R> {
    expect(URLRequest(url: row.args.head) ==> row.expect, file: file, line: line)
}

func expect<R: Equatable>(
    _ row: Row2<URL, StubNetworkKit.Method, R>,
    file: StaticString = #file,
    line: UInt = #line
) -> Row1<URLRequest, R> {
    var request = URLRequest(url: row.args.head)
    request.httpMethod = { (method) -> String in
        switch method {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        case .head: return "HEAD"
        }
    }(row.args.tail.head)
    return expect(request ==> row.expect, file: file, line: line)
}
