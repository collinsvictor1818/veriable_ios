import Combine
import Foundation

@MainActor
class CheckoutViewModel: ObservableObject {
  @Published var paymentMethod: PaymentMethod = .card
  @Published var isProcessing: Bool = false
  @Published var alert: CheckoutAlert?
  @Published private(set) var lastOrderTotal: Double = 0

  // Dynamic cart data
  @Published var cartItems: [CartItem] = []
  @Published var subtotal: Double = 0
  @Published var estimatedTax: Double = 0
  @Published var discount: Double = 0
  @Published var total: Double = 0

  private let checkoutUseCase: CheckoutUseCaseProtocol
  private let cartRepository: CartRepositoryProtocol
  private let logger = LoggerService(category: "CheckoutViewModel")

  init(checkoutUseCase: CheckoutUseCaseProtocol, cartRepository: CartRepositoryProtocol) {
    self.checkoutUseCase = checkoutUseCase
    self.cartRepository = cartRepository

    // Fetch cart items and calculate totals on init
    Task {
      await fetchCartItems()
    }
  }

  func fetchCartItems() async {
    do {
      cartItems = try await cartRepository.fetchCartItems()
      calculateTotals()
    } catch {
      logger.error("Failed to fetch cart items: \(error.localizedDescription)")
    }
  }

  private func calculateTotals() {
    // Calculate subtotal from cart items
    subtotal = cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }

    // Calculate estimated tax (7% of subtotal)
    estimatedTax = subtotal * 0.07

    // Discount is 0 for now (can be made dynamic with promo codes later)
    discount = 0

    // Calculate total
    total = subtotal + estimatedTax - discount
  }

  func checkout() {
    Task {
      isProcessing = true
      do {
        let items = try await cartRepository.fetchCartItems()
        lastOrderTotal = items.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
        try await checkoutUseCase.execute(items: items)
        alert = CheckoutAlert(title: "Checkout", message: "Thank you for your purchase!")
        logger.notice("Checkout completed successfully")
      } catch {
        alert = CheckoutAlert(
          title: "Checkout", message: "Checkout failed: \(error.localizedDescription)")
        logger.error("Checkout failed: \(error.localizedDescription)")
      }
      isProcessing = false
    }
  }
}

struct CheckoutAlert: Identifiable {
  let id = UUID()
  let title: String
  let message: String
}

enum PaymentMethod: String, CaseIterable, Identifiable {
  case card = "Credit/Debit Card"
  case wallet = "Mobile Wallet"
  case cash = "Cash on Delivery"

  var id: String { rawValue }
}
