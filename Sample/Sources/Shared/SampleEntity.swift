import Foundation

public struct SampleEntity: Decodable {
    var foo: String
    var bar: Int
    var baz: Bool
    var qux: Child
}

public extension SampleEntity {
    struct Child: Decodable {
        var quux: String
        var corge: Double
        var grault: Bool
        var garply: [String]
    }
}
