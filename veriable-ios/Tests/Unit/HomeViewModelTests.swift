import XCTest
@testable import VeriableRetailApp

final class HomeViewModelTests: XCTestCase {
    @MainActor
    func testLoadProductsSuccess() async {
        let products = Product.mockProducts
        let fetchUseCase = FetchProductsUseCaseMock(result: .success(products))
        let addUseCase = AddToCartUseCaseMock()
        let sut = HomeViewModel(fetchProductsUseCase: fetchUseCase, addToCartUseCase: addUseCase)
        
        await sut.loadProducts().value
        
        XCTAssertEqual(sut.products.count, products.count)
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testLoadProductsFailure() async {
        let fetchUseCase = FetchProductsUseCaseMock(result: .failure(AppError.network(.invalidResponse)))
        let addUseCase = AddToCartUseCaseMock()
        let sut = HomeViewModel(fetchProductsUseCase: fetchUseCase, addToCartUseCase: addUseCase)
        
        await sut.loadProducts().value
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.products.isEmpty)
    }
}

// MARK: - Test Doubles

final class FetchProductsUseCaseMock: FetchProductsUseCaseProtocol {
    let result: Result<[Product], AppError>
    
    init(result: Result<[Product], AppError>) {
        self.result = result
    }
    
    func execute(forceRefresh: Bool) async throws -> [Product] {
        switch result {
        case .success(let products):
            return products
        case .failure(let error):
            throw error
        }
    }
}

final class AddToCartUseCaseMock: AddToCartUseCaseProtocol {
    private(set) var addCount = 0
    
    func execute(product: Product) async throws {
        addCount += 1
    }
}
