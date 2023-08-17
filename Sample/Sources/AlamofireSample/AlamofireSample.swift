import Foundation
import Alamofire
import Shared

final class AlamofireSample {
    private let session: Session

    init(_ session: Session = .default) {
        self.session = session
    }
}

extension AlamofireSample {
    func fetch() async throws -> SampleEntity {
        let url = URL(string: "https://foo.bar/baz")!
        return try await session.request(url)
            .serializingDecodable(SampleEntity.self)
            .response
            .result
            .get()
    }
}
