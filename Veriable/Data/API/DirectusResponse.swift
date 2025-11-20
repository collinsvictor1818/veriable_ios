import Foundation

/// A generic wrapper for Directus API responses.
///
/// Directus wraps all successful responses in a `data` object.
/// This struct allows for easy decoding of that structure.
struct DirectusResponse<T: Decodable>: Decodable {
    let data: T
}
