import Foundation

/// A protocol that defines the contract for adding a product to the cart.
protocol AddToCartUseCaseProtocol {
    /// Asynchronously adds a product to the cart.
    /// - Parameter product: The `Product` to add.
    /// - Throws: An `AppError` if the operation fails.
    func execute(product: Product) async throws
}

/// The concrete implementation of `AddToCartUseCaseProtocol`.
///
/// This class encapsulates the business logic for adding a product to the shopping cart.
final class AddToCartUseCase: AddToCartUseCaseProtocol {
    
    private let cartRepository: CartRepositoryProtocol
    
    /// Initializes a new instance of the use case.
    /// - Parameter cartRepository: The `CartRepositoryProtocol` to use for cart operations.
    init(cartRepository: CartRepositoryProtocol) {
        self.cartRepository = cartRepository
    }
    
    func execute(product: Product) async throws {
        var items = try await cartRepository.fetchCartItems()
        
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            let newItem = CartItem(product: product, quantity: 1)
            items.append(newItem)
        }
        
        try await cartRepository.saveCartItems(items)
    }
}
