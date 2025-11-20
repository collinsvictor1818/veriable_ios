import Foundation

/// An enumeration that defines the API endpoints.
///
/// Using an enum for endpoints provides a type-safe way to construct URLs
/// and configure network requests.
protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: String { get }
    var url: URL? { get }
    var body: Data? { get }
}

extension Endpoint {
    var body: Data? { nil }
}

/// Defines the endpoints related to products.
enum ProductAPI: Endpoint {
    case fetchProducts
    
    var baseURL: String {
        return Config.apiBaseURL
    }
    
    var path: String {
        switch self {
        case .fetchProducts:
            return "/items/products"
        }
    }
    
    var method: String {
        switch self {
        case .fetchProducts:
            return "GET"
        }
    }
    
    var url: URL? {
        URL(string: baseURL + path)
    }
}
