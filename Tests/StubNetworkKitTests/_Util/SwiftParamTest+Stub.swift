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
    request.httpMethod = switch row.args.tail.head {
    case .get: "GET"
    case .post: "POST"
    case .put: "PUT"
    case .patch: "PATCH"
    case .delete: "DELETE"
    case .head: "HEAD"
    }
    return expect(request ==> row.expect, file: file, line: line)
}
