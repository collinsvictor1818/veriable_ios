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
}

/// Defines the endpoints related to products.
enum ProductAPI: Endpoint {
    case fetchProducts
    
    var baseURL: String {
        // In a real app, this would come from a configuration file.
        return "https://api.example.com"
    }
    
    var path: String {
        switch self {
        case .fetchProducts:
            return "/v1/products"
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
