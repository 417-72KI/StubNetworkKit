import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class Stub {
    typealias Response = (URLRequest) -> StubResponse

    private(set) var condition: StubCondition = { _ in true }
    private(set) var response: Response = { _ in .failure(StubError.unimplemented) }

    init(condition: @escaping StubCondition,
         response: @escaping Response) {
        self.condition = condition
        self.response = response
    }
}
