import Foundation

/// A protocol that defines the contract for fetching products.
protocol FetchProductsUseCaseProtocol {
    /// Asynchronously fetches a list of products.
    /// - Parameter forceRefresh: Determines whether the cache should be bypassed.
    /// - Returns: An array of `Product` objects.
    /// - Throws: An `AppError` if the fetch operation fails.
    func execute(forceRefresh: Bool) async throws -> [Product]
}

/// The concrete implementation of `FetchProductsUseCaseProtocol`.
///
/// This class encapsulates the business logic for fetching products from a repository.
/// It follows the single-responsibility principle, with its only purpose being to fetch products.
final class FetchProductsUseCase: FetchProductsUseCaseProtocol {
    
    private let repository: ProductRepositoryProtocol
    
    /// Initializes a new instance of the use case.
    /// - Parameter repository: The `ProductRepositoryProtocol` to use for fetching products.
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(forceRefresh: Bool = false) async throws -> [Product] {
        try await repository.fetchProducts(forceRefresh: forceRefresh)
    }
}
