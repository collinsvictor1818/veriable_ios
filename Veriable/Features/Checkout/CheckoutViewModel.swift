import Foundation
import Combine

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var paymentMethod: PaymentMethod = .card
    @Published var isProcessing: Bool = false
    @Published var alert: CheckoutAlert?
    @Published private(set) var lastOrderTotal: Double = 0
    
    private let checkoutUseCase: CheckoutUseCaseProtocol
    private let cartRepository: CartRepositoryProtocol
    private let logger = LoggerService(category: "CheckoutViewModel")
    
    init(checkoutUseCase: CheckoutUseCaseProtocol, cartRepository: CartRepositoryProtocol) {
        self.checkoutUseCase = checkoutUseCase
        self.cartRepository = cartRepository
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
                alert = CheckoutAlert(title: "Checkout", message: "Checkout failed: \(error.localizedDescription)")
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
