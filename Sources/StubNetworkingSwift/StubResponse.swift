import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum StubResponse {
    case success(data: Data?, statusCode: Int, headers: [String: String]?)
    case failure(Error)
}

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
            self.init(data: .init(),
                      statusCode: statusCode,
                      headers: headers)
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

public extension StubResponse {
    init(error: Error) {
        self = .failure(error)
    }
}
