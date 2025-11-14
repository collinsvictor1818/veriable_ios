import Foundation
import Combine

/// A class that holds the global state of the application.
///
/// This class is an `ObservableObject` so that SwiftUI views can subscribe to its changes.
/// It should be provided as a singleton throughout the app, likely as an environment object.
@MainActor
final class AppState: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The current user of the app. Published to trigger UI updates on change.
    @Published var currentUser: User? = nil
    
    /// The items currently in the user's shopping cart.
    @Published var cartItems: [CartItem] = []
    
    // MARK: - Initialization
    
    init(currentUser: User? = nil, cartItems: [CartItem] = []) {
        self.currentUser = currentUser
        self.cartItems = cartItems
    }
    
    // MARK: - Public Methods
    
    /// Adds a product to the cart or increments its quantity if it already exists.
    /// - Parameter product: The `Product` to be added to the cart.
    func addProductToCart(_ product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            let newItem = CartItem(product: product, quantity: 1)
            cartItems.append(newItem)
        }
    }
    
    /// Removes a product from the cart.
    /// - Parameter product: The `Product` to be removed from the cart.
    func removeProductFromCart(_ product: Product) {
        cartItems.removeAll { $0.product.id == product.id }
    }
    
    /// Clears all items from the cart.
    func clearCart() {
        cartItems.removeAll()
    }
}

// MARK: - Mock Data

#if DEBUG
extension AppState {
    static var mock: AppState {
        AppState(currentUser: User.mock, cartItems: CartItem.mockItems)
    }
}
#endif
