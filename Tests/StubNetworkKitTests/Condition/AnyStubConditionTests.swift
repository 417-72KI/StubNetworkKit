import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing

@testable import StubNetworkKit

@Suite
struct AnyStubConditionTests {

    @Test
    func scheme() async throws {
        let condition = AnyStubCondition(Scheme.is("https"))
        #expect(condition(URL(string: "https://foo.bar")!))
    }

    @Suite
    struct And {
        @Test func directly() async throws {
            let c1 = Scheme.is("https")
            let c2 = Host.is("foo.bar")

            let and1 = AnyStubCondition(c1 && c2)
            let and2 = AnyStubCondition(c2 && c1)
            #expect(and1 == and2)
        }

        @Test func leftSideTypeErased() async throws {
            let c1 = AnyStubCondition(Scheme.is("https"))
            let c2 = Host.is("foo.bar")

            let and1 = AnyStubCondition(c1 && c2)
            let and2 = AnyStubCondition(c2 && c1)

            #expect(and1 == and2)
        }

        @Test func rightSideTypeErased() async throws {
            let c1 = Scheme.is("https")
            let c2 = AnyStubCondition(Host.is("foo.bar"))

            let and1 = AnyStubCondition(c1 && c2)
            let and2 = AnyStubCondition(c2 && c1)

            #expect(and1 == and2)
        }

        @Test func bothTypeErased() async throws {
            let c1 = AnyStubCondition(Scheme.is("https"))
            let c2 = AnyStubCondition(Host.is("foo.bar"))

            let and1 = c1 && c2
            let and2 = c2 && c1

            #expect(and1 == and2)
        }
    }

    @Suite
    struct OR {
        @Test func directly() async throws {
            let c1 = Scheme.is("https")
            let c2 = Host.is("foo.bar")

            let or1 = AnyStubCondition(c1 || c2)
            let or2 = AnyStubCondition(c2 || c1)
            #expect(or1 == or2)

        }

        @Test func leftSideTypeErased() async throws {
            let c1 = AnyStubCondition(Scheme.is("https"))
            let c2 = Host.is("foo.bar")

            let or1 = AnyStubCondition(c1 || c2)
            let or2 = AnyStubCondition(c2 || c1)

            #expect(or1 == or2)
        }

        @Test func rightSideTypeErased() async throws {
            let c1 = Scheme.is("https")
            let c2 = AnyStubCondition(Host.is("foo.bar"))

            let or1 = AnyStubCondition(c1 || c2)
            let or2 = AnyStubCondition(c2 || c1)

            #expect(or1 == or2)
        }

        @Test func bothTypeErased() async throws {
            let c1 = AnyStubCondition(Scheme.is("https"))
            let c2 = AnyStubCondition(Host.is("foo.bar"))

            let or1 = c1 || c2
            let or2 = c2 || c1

            #expect(or1 == or2)
        }
    }
}
