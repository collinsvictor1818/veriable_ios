import Foundation

/// A container for all the dependencies and services that the app needs.
///
/// This struct is responsible for creating and holding instances of services,
/// repositories, and use cases. It can be configured for different environments
/// (e.g., production, development, testing) by providing different implementations
/// of the required protocols.
///
/// It is typically created once at app startup and passed down through the view
/// hierarchy as an environment object.
struct AppEnvironment {
    let apiClient: APIClientProtocol
    let productRepository: ProductRepositoryProtocol
    let cartRepository: CartRepositoryProtocol
    let fetchProductsUseCase: FetchProductsUseCase
    let addToCartUseCase: AddToCartUseCase
    let checkoutUseCase: CheckoutUseCase
    
    init(apiClient: APIClientProtocol,
         productRepository: ProductRepositoryProtocol,
         cartRepository: CartRepositoryProtocol,
         fetchProductsUseCase: FetchProductsUseCase,
         addToCartUseCase: AddToCartUseCase,
         checkoutUseCase: CheckoutUseCase) {
        self.apiClient = apiClient
        self.productRepository = productRepository
        self.cartRepository = cartRepository
        self.fetchProductsUseCase = fetchProductsUseCase
        self.addToCartUseCase = addToCartUseCase
        self.checkoutUseCase = checkoutUseCase
    }
}

// MARK: - Factory Methods

extension AppEnvironment {
    
    /// Creates a default `AppEnvironment` for the production app.
    static func bootstrap() -> AppEnvironment {
        let apiClient = APIClient()
        let localCache = LocalCache()
        let secureStorage = SecureStorage()
        
        let productRepository = ProductRepository(apiClient: apiClient, cache: localCache)
        let cartRepository = CartRepository(secureStorage: secureStorage)
        
        let fetchProductsUseCase = FetchProductsUseCase(repository: productRepository)
        let addToCartUseCase = AddToCartUseCase(cartRepository: cartRepository)
        let checkoutUseCase = CheckoutUseCase(cartRepository: cartRepository)
        
        return AppEnvironment(apiClient: apiClient,
                              productRepository: productRepository,
                              cartRepository: cartRepository,
                              fetchProductsUseCase: fetchProductsUseCase,
                              addToCartUseCase: addToCartUseCase,
                              checkoutUseCase: checkoutUseCase)
    }
    
    #if DEBUG
    /// Creates a mock `AppEnvironment` for SwiftUI previews and testing.
    static var mock: AppEnvironment {
        let apiClient = MockAPIClient()
        let localCache = MockLocalCache()
        let secureStorage = MockSecureStorage()
        
        let productRepository = ProductRepository(apiClient: apiClient, cache: localCache)
        let cartRepository = CartRepository(secureStorage: secureStorage)
        
        let fetchProductsUseCase = FetchProductsUseCase(repository: productRepository)
        let addToCartUseCase = AddToCartUseCase(cartRepository: cartRepository)
        let checkoutUseCase = CheckoutUseCase(cartRepository: cartRepository)
        
        return AppEnvironment(apiClient: apiClient,
                              productRepository: productRepository,
                              cartRepository: cartRepository,
                              fetchProductsUseCase: fetchProductsUseCase,
                              addToCartUseCase: addToCartUseCase,
                              checkoutUseCase: checkoutUseCase)
    }
    #endif
}
