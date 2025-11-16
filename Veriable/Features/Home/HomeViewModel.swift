import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let fetchProductsUseCase: FetchProductsUseCaseProtocol
    private let addToCartUseCase: AddToCartUseCaseProtocol
    private let logger = LoggerService(category: "HomeViewModel")
    
    init(fetchProductsUseCase: FetchProductsUseCaseProtocol,
         addToCartUseCase: AddToCartUseCaseProtocol) {
        self.fetchProductsUseCase = fetchProductsUseCase
        self.addToCartUseCase = addToCartUseCase
    }
    
    @discardableResult
    func loadProducts(forceRefresh: Bool = false) -> Task<Void, Never> {
        Task {
            await fetchProducts(forceRefresh: forceRefresh)
        }
    }
    
    func refresh() {
        loadProducts(forceRefresh: true)
    }
    
    private func fetchProducts(forceRefresh: Bool) async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await fetchProductsUseCase.execute(forceRefresh: forceRefresh)
            logger.info("Loaded \(products.count) products")
        } catch let error as AppError {
            errorMessage = error.message
            logger.error("Failed to fetch products: \(error.message)")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Unexpected error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func addToCart(_ product: Product) {
        Task {
            do {
                try await addToCartUseCase.execute(product: product)
                logger.notice("Added product \(product.id) to cart")
            } catch {
                logger.error("Failed to add to cart: \(error.localizedDescription)")
            }
        }
    }
}
