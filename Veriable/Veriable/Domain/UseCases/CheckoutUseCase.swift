import Foundation
import Combine

/// A protocol that defines the contract for the checkout process.
protocol CheckoutUseCaseProtocol {
    /// Asynchronously performs the checkout operation.
    /// - Parameter items: The list of `CartItem`s to check out.
    /// - Throws: An `AppError` if the checkout fails.
    func execute(items: [CartItem]) async throws
}

/// The concrete implementation of `CheckoutUseCaseProtocol`.
///
/// This class encapsulates the business logic for the checkout process.
/// In a real app, this would involve payment processing, order creation, etc.
final class CheckoutUseCase: CheckoutUseCaseProtocol {
    
    private let cartRepository: CartRepositoryProtocol
    
    /// Initializes a new instance of the use case.
    /// - Parameter cartRepository: The `CartRepositoryProtocol` to use for cart operations.
    init(cartRepository: CartRepositoryProtocol) {
        self.cartRepository = cartRepository
    }
    
    func execute(items: [CartItem]) async throws {
        // In a real application, this would interact with a payment gateway
        // and an order processing system.
        
        // For this example, we'll just simulate a network delay and then
        // clear the cart to signify a successful checkout.
        
        print("Processing checkout for \(items.count) items...")
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulate 2-second network call
        
        // On successful checkout, clear the cart.
        try await cartRepository.clearCart()
        print("Checkout successful!")
    }
}
