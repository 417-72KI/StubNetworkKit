import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkingSwift

final class StubNetworkingSwiftTests: XCTestCase {
    func testDefaultStubSession() throws {
        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let e = expectation(description: "URLSession")
        defaultStubSession.dataTask(with: url) { data, response, error in
            XCTAssertNotNil(data)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertNil(error)
            e.fulfill()
        }.resume()
        waitForExpectations(timeout: 5)
    }

    func testSharedSession() throws {
        registerStubForSharedSession()
        defer { unregisterStubForSharedSession() }

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) { _ in
            StubResponse(data: "Hello world!".data(using: .utf8)!)
        }

        let e = expectation(description: "URLSession")
        URLSession.shared.dataTask(with: url) { data, response, error in
            XCTAssertNotNil(data)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertNil(error)
            e.fulfill()
        }.resume()
        waitForExpectations(timeout: 5)
    }
}
