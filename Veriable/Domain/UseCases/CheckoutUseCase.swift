import Combine
import Foundation

/// A protocol that defines the contract for the checkout process.
public protocol CheckoutUseCaseProtocol {
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
  private let apiClient: APIClientProtocol
  private var currentUserId: Int?

  /// Initializes a new instance of the use case.
  /// - Parameters:
  ///   - cartRepository: The `CartRepositoryProtocol` to use for cart operations.
  ///   - apiClient: The `APIClientProtocol` to use for API operations.
  init(cartRepository: CartRepositoryProtocol, apiClient: APIClientProtocol) {
    self.cartRepository = cartRepository
    self.apiClient = apiClient
  }

  func setUserId(_ userId: Int) {
    self.currentUserId = userId
  }

  func execute(items: [CartItem]) async throws {
    guard let userId = currentUserId else {
      throw AppError.data(
        .encodingFailed(
          NSError(
            domain: "CheckoutUseCase", code: 401,
            userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
    }

    // Calculate total
    let total = items.reduce(0.0) { $0 + ($1.product.price * Double($1.quantity)) }

    print("Processing checkout for \(items.count) items with total $\(total)...")

    // Create order in backend
    let orderResponse: OrderResponse = try await apiClient.request(
      OrderAPI.createOrder(userId: userId, total: total, items: items))

    print("Created order #\(orderResponse.id)")

    // Create order items
    for item in items {
      let orderItemRequest = OrderItemRequest(
        order: orderResponse.id,
        product: item.product.id,
        quantity: item.quantity,
        price: item.product.price
      )

      // Post order item to backend
      let url = URL(string: "\(Config.apiBaseURL)/items/order_items")!
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.addValue("Bearer \(Config.apiToken)", forHTTPHeaderField: "Authorization")
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")

      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase
      request.httpBody = try encoder.encode(orderItemRequest)

      let (_, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode)
      else {
        throw AppError.network(
          .serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0))
      }
    }

    // On successful checkout, clear the cart
    try await cartRepository.clearCart()
    print("Checkout successful! Order #\(orderResponse.id) created.")
  }
}
