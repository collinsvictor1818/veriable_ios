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

/// Repository that interacts with secure storage to manage cart data.
final class CartRepository: CartRepositoryProtocol {
    private let secureStorage: SecureStorageProtocol
    private let cartStore = CartStore()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let service = "com.veriable.cart"
    private let account = "currentCart"
    
    init(secureStorage: SecureStorageProtocol) {
        self.secureStorage = secureStorage
    }
    
    func fetchCartItems() async throws -> [CartItem] {
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
        let data = try encoder.encode(items)
        try secureStorage.save(data: data, service: service, account: account)
        await cartStore.update(items)
    }
    
    func clearCart() async throws {
        try secureStorage.delete(service: service, account: account)
        await cartStore.removeAll()
    }
}
