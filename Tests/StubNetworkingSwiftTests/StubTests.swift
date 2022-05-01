#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
import StubNetworkingSwift
import SwiftParamTest

final class StubTests: XCTestCase {
    func testStub() throws {
        assert(to: stub(url: "https://foo.bar/baz")) {
            expect(URL(string: "https://foo.bar/baz?q=1&empty=&flag")! ==> true)
            expect(URL(string: "https://foo.bar/baz")! ==> true)
        }

        assert(to: stub(url: "https://foo.bar/baz?q=1&empty=&flag")) {
            expect(URL(string: "https://foo.bar/baz?q=1&empty=&flag")! ==> true)
            expect(URL(string: "https://foo.bar/baz")! ==> false)
        }

        assert(to: stub(url: "https://foo.bar/baz", method: .post)) {
            expect((URL(string: "https://foo.bar/baz")!, .get) ==> false)
            expect((URL(string: "https://foo.bar/baz")!, .post) ==> true)
        }
    }
}
