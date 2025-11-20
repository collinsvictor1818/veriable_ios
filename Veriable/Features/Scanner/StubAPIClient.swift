import Foundation

/// A stubbed API client that returns sample/hard-coded data.
/// Use this when the backend isn't set up yet.
struct StubAPIClient: APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // Attempt to provide sample data for known endpoints/types.
        // Extend this as needed for other endpoints.
        if let products = Product.mockProducts as? T {
            return products
        }
        
        // As a generic fallback, try to load a bundled JSON named after the endpoint path last component.
        // e.g., for "/v1/products" it will look for "products.json" in the main bundle.
        if let fileName = endpoint.path.split(separator: "/").last.map(String.init),
           let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let decoded = try? decoder.decode(T.self, from: data) {
                return decoded
            }
        }
        
        // If we still can't provide data, throw a descriptive error.
        throw AppError.data(.decodingFailed(NSError(domain: "StubAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No stub available for requested type \(T.self)"])) )
    }
}
