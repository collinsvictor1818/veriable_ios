import Foundation

/// Represents a user of the application.
///
/// This struct is a simple data model that conforms to `Codable` for easy
/// encoding and decoding from data formats like JSON.
struct User: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let email: String
}

// MARK: - Mock Data

#if DEBUG
extension User {
    /// A mock user for previews and testing.
    static var mock: User {
        User(id: 1, name: "Collins Koech", email: "jane.doe@example.com")
    }
}
#endif
