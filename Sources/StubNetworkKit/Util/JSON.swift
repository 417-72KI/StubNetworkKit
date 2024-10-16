import Foundation

/// A type that can be converted to a JSON object.
/// - Note: The keys of the dictionary must be `String` and the values must be `Sendable`.
/// - SeeAlso: `Sendable`
public typealias JSONObject = [String: any Sendable]

/// A type that can be converted to a JSON array.
/// - Note: The elements of the array must be `Sendable`.
/// - SeeAlso: `Sendable`
public typealias JSONArray = [any Sendable]
