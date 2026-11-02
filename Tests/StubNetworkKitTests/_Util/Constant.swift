import Foundation

let needsDebugLog = ProcessInfo.processInfo.environment["DEBUG"].flatMap(Bool.init) ?? false
