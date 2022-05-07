import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

protocol StubConditionType: Equatable {
    var condition: StubCondition { get }
}
