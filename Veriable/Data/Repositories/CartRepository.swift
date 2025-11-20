import Foundation

/// Protocol defining cart operations.
protocol CartRepositoryProtocol {
    func fetchCartItems() async throws -> [CartItem]
    func saveCartItems(_ items: [CartItem]) async throws
    func clearCart() async throws
}

/// Actor responsible for managing cart state in a thread-safe manner.
actor CartStore {
    private var items: [CartItem] = []
    
    func load() -> [CartItem] {
        items
    }
    
    func update(_ newItems: [CartItem]) {
        items = newItems
    }
    
    func removeAll() {
        items.removeAll()
    }
}

/// Repository that syncs cart data with backend and uses local storage as cache.
final class CartRepository: CartRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let secureStorage: SecureStorageProtocol
    private let cartStore = CartStore()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let service = "com.veriable.cart"
    private let account = "currentCart"
    
    // Current user ID - should be set after login
    private var currentUserId: Int?
    
    init(apiClient: APIClientProtocol, secureStorage: SecureStorageProtocol) {
        self.apiClient = apiClient
        self.secureStorage = secureStorage
    }
    
    func setUserId(_ userId: Int) {
        self.currentUserId = userId
    }
    
    func fetchCartItems() async throws -> [CartItem] {
        // If we have a user ID, fetch from backend
        if let userId = currentUserId {
            do {
                let responses: [CartItemResponse] = try await apiClient.request(CartAPI.fetchCartItems(userId: userId))
                
                // Convert CartItemResponse to CartItem
                // We need to fetch product details for each item
                var cartItems: [CartItem] = []
                for response in responses {
                    // Fetch product details
                    let products: [Product] = try await apiClient.request(ProductAPI.fetchProducts)
                    if let product = products.first(where: { $0.id == response.product }) {
                        let cartItem = CartItem(product: product, quantity: response.quantity)
                        cartItems.append(cartItem)
                    }
                }
                
                // Update local cache
                await cartStore.update(cartItems)
                let data = try encoder.encode(cartItems)
                try secureStorage.save(data: data, service: service, account: account)
                
                return cartItems
            } catch {
                // If API fails, fall back to local cache
                print("Failed to fetch cart from API, using local cache: \(error)")
            }
        }
        
        // Fall back to local storage
        let storedItems = await cartStore.load()
        if !storedItems.isEmpty {
            return storedItems
        }
        
        guard let data = try secureStorage.read(service: service, account: account) else {
            return []
        }
        
        let items = try decoder.decode([CartItem].self, from: data)
        await cartStore.update(items)
        return items
    }
    
    func saveCartItems(_ items: [CartItem]) async throws {
        // Save to local storage first
        let data = try encoder.encode(items)
        try secureStorage.save(data: data, service: service, account: account)
        await cartStore.update(items)
        
        // If we have a user ID, sync to backend
        if let userId = currentUserId {
            // This is a simplified approach - in production you'd want to:
            // 1. Track which items changed
            // 2. Only sync the changes
            // For now, we'll just ensure items exist on backend
            // The actual syncing will happen through individual add/update/delete operations
        }
    }
    
    func clearCart() async throws {
        // Clear local storage
        try secureStorage.delete(service: service, account: account)
        await cartStore.removeAll()
        
        // Clear backend if we have a user ID
        if let userId = currentUserId {
            do {
                // Delete all cart items for this user
                let _: [CartItemResponse] = try await apiClient.request(CartAPI.clearCart(userId: userId))
            } catch {
                print("Failed to clear cart on backend: \(error)")
            }
        }
    }
}
