import Foundation

public extension StubResponse {
    static func data(_ data: Data,
                     statusCode: Int = 200,
                     headers: [String: String]? = nil) -> Self {
        self.init(data: data,
                  statusCode: statusCode,
                  headers: headers)
    }

    static func json(_ jsonObject: [AnyHashable: Any],
                     statusCode: Int = 200,
                     headers: [String: String]? = nil) -> Self {
        self.init(jsonObject: jsonObject,
                  statusCode: statusCode,
                  headers: headers)
    }

    static func json(_ jsonArray: [Any],
                     statusCode: Int = 200,
                     headers: [String: String]? = nil) -> Self {
        self.init(jsonArray: jsonArray,
                  statusCode: statusCode,
                  headers: headers)
    }

    static func fixture(filePath: String,
                        withExtension ext: String? = nil,
                        in bundle: Bundle = .main,
                        statusCode: Int = 200,
                        headers: [String: String]? = nil) -> Self {
        self.init(filePath: path(filePath,
                                 withExtension: ext,
                                 in: bundle),
                  statusCode: statusCode,
                  headers: headers)
    }

    static func json(fromFile filePath: String,
                     in bundle: Bundle = .main,
                     statusCode: Int = 200,
                     headers appendingHeaders: [String: String]? = nil) -> Self {

        var headers = ["Content-Type": "application/json"]
        if let appendingHeaders = appendingHeaders {
            headers.merge(appendingHeaders) { (used, _) in used }
        }

        return fixture(filePath: filePath,
                       withExtension: "json",
                       in: bundle,
                       statusCode: statusCode,
                       headers: headers)
    }
}

public extension StubResponse {
    static func error(_ error: StubError) -> Self {
        .init(error: error)
    }
}
