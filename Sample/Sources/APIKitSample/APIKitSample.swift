import Foundation
import APIKit
import Shared

final class APIKitSample {
    private let session: Session

    init(_ session: Session = .shared) {
        self.session = session
    }
}

extension APIKitSample {
    func fetch() async throws -> SampleEntity {
        try await session.response(for: SampleRequest())
    }
}

struct SampleRequest: Request {
    typealias Response = SampleEntity

    var baseURL: URL { URL(string: "https://foo.bar")! }
    var path: String { "/baz/qux" }
    var method: HTTPMethod { .get }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> SampleEntity {
        let data = try (object as? Data) ?? (try JSONSerialization.data(withJSONObject: object, options: []))
        return try JSONDecoder()
            .decode(Response.self, from: data)
    }
}
