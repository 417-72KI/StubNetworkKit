import Foundation

extension StubResponse {
    static func path(_ filePath: String,
                     withExtension ext: String? = nil,
                     in bundle: Bundle = .main
    ) -> String {
        guard let path = bundle.path(forResource: filePath, ofType: ext) else {
            preconditionFailure("File path \"\(filePath)\(ext.flatMap { ".\($0)" } ?? "")\" not found in \(bundle)")
        }
        return path
    }

    static func url(forResource name: String,
                    withExtension ext: String? = nil,
                    in bundle: Bundle = .main) -> URL {
        guard let url = bundle.url(forResource: name,
                                   withExtension: ext) else {
            preconditionFailure("File \"\(name)\(ext.flatMap { ".\($0)" } ?? "")\" not found in \(bundle)")
        }
        return url
    }
}
