import Foundation

/// A simple in-memory cache for storing data.
///
/// In a production app, this might use Core Data, SQLite, or a custom caching mechanism.
final class LocalCache {
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
final class MockLocalCache: LocalCache {
    override func fetchProducts() -> [Product]? {
        Product.mockProducts
    }
}
#endif
