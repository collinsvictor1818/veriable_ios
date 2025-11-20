import Foundation

/// A stubbed API client that returns sample/hard-coded data.
/// Use this when the backend isn't set up yet.
struct StubAPIClient: APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // Provide sample products for product list endpoints without relying on DEBUG-only mocks.
        if T.self == [Product].self || T.self == Array<Product>.self {
            let samples: [Product] = [
                Product(id: 1, name: "Organic Eggs", description: "Fresh, free-range eggs.", price: 6.99, imageUrl: nil),
                Product(id: 2, name: "Organic Avocado", description: "Ripe and ready to eat.", price: 2.49, imageUrl: nil),
                Product(id: 3, name: "Whole Milk", description: "Gallon of whole milk.", price: 3.59, imageUrl: nil),
                Product(id: 4, name: "Cold Brew", description: "Concentrated cold brew coffee.", price: 7.49, imageUrl: nil),
                Product(id: 5, name: "Almond Flour", description: "Finely ground almond flour.", price: 11.99, imageUrl: nil)
            ]
            // Force-cast is safe due to type check above
            return samples as! T
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
