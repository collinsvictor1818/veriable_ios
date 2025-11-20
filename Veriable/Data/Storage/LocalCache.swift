import Foundation

/// A simple in-memory cache for storing data.
///
/// In a production app, this might use Core Data, SQLite, or a custom caching mechanism.
class LocalCache {
    private var cachedProducts: [Product]?
    private let queue = DispatchQueue(label: "LocalCacheQueue", attributes: .concurrent)
    
    func saveProducts(_ products: [Product]) {
        queue.async(flags: .barrier) {
            self.cachedProducts = products
        }
    }
    
    func fetchProducts() -> [Product]? {
        queue.sync {
            cachedProducts
        }
    }
}

#if DEBUG
class MockLocalCache: LocalCache {
    override init() {
        super.init()
        // Preload with mock data
        saveProducts(Product.mockProducts)
    }
    
    override func fetchProducts() -> [Product]? {
        // For testing purposes, always return mock products
        return Product.mockProducts
    }
}
#endif
