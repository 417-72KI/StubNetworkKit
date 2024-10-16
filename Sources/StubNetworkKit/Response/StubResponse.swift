import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum StubResponse {
    case success(data: Data?, statusCode: Int, headers: [String: String]?)
    case failure(any Error)
}

// MARK: - Success
public extension StubResponse {
    init(data: Data,
         statusCode: Int = 200,
         headers: [String: String]? = nil) {
        self = .success(data: data, statusCode: statusCode, headers: headers)
    }

    init(fileURL: URL,
         statusCode: Int = 200,
         headers: [String: String]? = nil) {
        do {
            let data = try Data(contentsOf: fileURL)
            self.init(data: data,
                      statusCode: statusCode,
                      headers: headers)
        } catch {
            self.init(error: error)
        }
    }

    init(filePath: String,
         statusCode: Int = 200,
         headers: [String: String]? = nil) {
        self.init(fileURL: URL(fileURLWithPath: filePath),
                  statusCode: statusCode,
                  headers: headers)
    }
}

// MARK: JSON
public extension StubResponse {
    init(jsonObject: [AnyHashable: Any],
         statusCode: Int = 200,
         headers appendingHeaders: [String: String]? = nil) {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject)
            var headers = ["Content-Type": "application/json"]
            if let appendingHeaders = appendingHeaders {
                headers.merge(appendingHeaders) { (used, _) in used }
            }
            self.init(data: data,
                      statusCode: statusCode,
                      headers: headers)
        } catch {
            self.init(error: error)
        }
    }

    init(jsonArray: [Any],
         statusCode: Int = 200,
         headers appendingHeaders: [String: String]? = nil) {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray)
            var headers = ["Content-Type": "application/json"]
            if let appendingHeaders = appendingHeaders {
                headers.merge(appendingHeaders) { (used, _) in used }
            }
            self.init(data: data,
                      statusCode: statusCode,
                      headers: headers)
        } catch {
            self.init(error: error)
        }
    }
}

// MARK: - Failure
public extension StubResponse {
    init(error: any Error) {
        self = .failure(error)
    }
}

// MARK: -
extension StubResponse {
    func get() throws -> (Data?, Int, [String: String]?) {
        switch self {
        case let .success(data, statusCode, headers):
            (data, statusCode, headers)
        case let .failure(error):
            throw error
        }
    }
}
