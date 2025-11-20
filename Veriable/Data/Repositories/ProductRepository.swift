import Foundation

/// A protocol defining the operations for fetching products.
protocol ProductRepositoryProtocol {
    func fetchProducts(forceRefresh: Bool) async throws -> [Product]
}

/// The repository responsible for fetching products from the API and caching them locally.
final class ProductRepository: ProductRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let cache: LocalCache
    private let logger = LoggerService(category: "ProductRepository")
    
    init(apiClient: APIClientProtocol, cache: LocalCache) {
        self.apiClient = apiClient
        self.cache = cache
    }
    
    func fetchProducts(forceRefresh: Bool = false) async throws -> [Product] {
        if !forceRefresh, let cachedProducts = cache.fetchProducts() {
            logger.info("Returning cached products")
            return cachedProducts
        }
        
        logger.debug("Fetching products from API")
        let products: [Product] = try await apiClient.request(ProductAPI.fetchProducts)
        cache.saveProducts(products)
        logger.notice("Fetched \(products.count) products from API")
        return products
    }
}
