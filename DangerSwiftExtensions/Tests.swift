import Danger
import Foundation

func verifyTests(danger: DangerDSL) throws {
    try danger.git.createdOrModifiedFiles.filter { $0.contains("Tests") }.forEach {
        guard FileManager.default.fileExists(atPath: $0) else { return }
        let url = URL(fileURLWithPath: $0)
        let content = String(data: try Data(contentsOf: url), encoding: .utf8)!
        let pattern = (
            url.pathComponents.contains(where: { $0.hasPrefix("_") }),
            content.split(separator: "\n").contains { $0.hasSuffix(": XCTestCase {") }
        )
        switch pattern {
        case (true, true):
            danger.fail("`\(url.lastPathComponent)` should not be in a directory starting with '_'")
        case (false, false):
            danger.fail("`\(url.lastPathComponent)` should be in a directory starting with '_'")
        default: break
        }
    }
}
