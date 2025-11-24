import Combine
import Foundation

@MainActor
public final class CartViewModel: ObservableObject {
  @Published public private(set) var items: [CartItem] = []
  @Published public private(set) var total: Double = 0
  @Published public var promoCode: String = ""

  private let cartRepository: CartRepositoryProtocol
  private let checkoutUseCase: CheckoutUseCaseProtocol
  private let logger = LoggerService(category: "CartViewModel")

  public init(cartRepository: CartRepositoryProtocol, checkoutUseCase: CheckoutUseCaseProtocol) {
    self.cartRepository = cartRepository
    self.checkoutUseCase = checkoutUseCase
  }

  public func loadCart() {
    Task {
      await loadCartAsync()
    }
  }

  public func refreshAsync() async {
    await loadCartAsync()
  }

  private func loadCartAsync() async {
    do {
      items = try await cartRepository.fetchCartItems()
      calculateTotal()
    } catch {
      logger.error("Failed to load cart: \(error.localizedDescription)")
    }
  }

  public func addItem(product: Product) {
    if let index = items.firstIndex(where: { $0.product.id == product.id }) {
      items[index].quantity += 1
    } else {
      let newItem = CartItem(product: product, quantity: 1)
      items.append(newItem)
    }
  }

  public func updateQuantity(for item: CartItem, quantity: Int) {
    Task {
      var updatedItems = items
      if let index = updatedItems.firstIndex(where: { $0.id == item.id }) {
        updatedItems[index].quantity = max(1, quantity)
        try await cartRepository.saveCartItems(updatedItems)
        items = updatedItems
        calculateTotal()
      }
    }
  }

  public func removeItem(_ item: CartItem) {
    Task {
      var updatedItems = items
      updatedItems.removeAll { $0.id == item.id }
      try await cartRepository.saveCartItems(updatedItems)
      items = updatedItems
      calculateTotal()
    }
  }

  public func checkout() {
    Task {
      do {
        try await checkoutUseCase.execute(items: items)
        items.removeAll()
        total = 0
      } catch {
        logger.error("Checkout failed: \(error.localizedDescription)")
      }
    }
  }

  private func calculateTotal() {
    total = items.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
  }
}
