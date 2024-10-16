import Foundation

public struct SampleEntity: Decodable, Sendable {
    public var foo: String
    public var bar: Int
    public var baz: Bool
    public var qux: Child
}

public extension SampleEntity {
    struct Child: Decodable, Sendable {
        public var quux: String
        public var corge: Double
        public var grault: Bool
        public var garply: [String]
    }
}
