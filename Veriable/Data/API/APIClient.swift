import Foundation
import Combine
/// A protocol defining the requirements for an API client.
/// This allows for mocking and dependency injection.
protocol APIClientProtocol {
    /// Performs a network request and decodes the response.
    /// - Parameter endpoint: The `Endpoint` to request.
    /// - Returns: The decoded object of type `T`.
    /// - Throws: An `AppError` if the request or decoding fails.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

/// The main networking client for the application.
///
/// This class is responsible for making network requests using `URLSession` and `async/await`.
/// It is generic and can be used to fetch and decode any `Decodable` type.
final class APIClient: APIClientProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw AppError.network(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        
        // Add headers
        request.addValue("Bearer \(Config.apiToken)", forHTTPHeaderField: "Authorization")
        if endpoint.body != nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network(.invalidResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.network(.serverError(statusCode: httpResponse.statusCode))
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            // Directus wraps responses in "data"
            let wrappedResponse = try decoder.decode(DirectusResponse<T>.self, from: data)
            return wrappedResponse.data
        } catch {
            throw AppError.data(.decodingFailed(error))
        }
    }
}

#if DEBUG
/// A mock API client that returns placeholder data for previews and tests.
struct MockAPIClient: APIClientProtocol {
    func request<T>(_ endpoint: Endpoint) async throws -> T where T : Decodable {
        guard let products = Product.mockProducts as? T else {
            throw AppError.data(.decodingFailed(NSError(domain: "MockAPI", code: -1)))
        }
        return products
    }
}
#endif
