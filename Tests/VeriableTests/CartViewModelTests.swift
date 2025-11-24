import Combine
import XCTest

@testable import VeriableLib

// Mocks
class MockCartRepository: CartRepositoryProtocol {
  var items: [CartItem] = []

  func fetchCartItems() async throws -> [CartItem] {
    return items
  }

  func saveCartItems(_ items: [CartItem]) async throws {
    self.items = items
  }

  func clearCart() async throws {
    items.removeAll()
  }
}

class MockCheckoutUseCase: CheckoutUseCaseProtocol {
  var executeCalled = false

  func execute(items: [CartItem]) async throws {
    executeCalled = true
  }
}

@MainActor
final class CartViewModelTests: XCTestCase {
  var viewModel: CartViewModel!
  var mockRepository: MockCartRepository!
  var mockCheckout: MockCheckoutUseCase!

  override func setUp() async throws {
    mockRepository = MockCartRepository()
    mockCheckout = MockCheckoutUseCase()
    viewModel = CartViewModel(cartRepository: mockRepository, checkoutUseCase: mockCheckout)
  }

  func testAddItem() {
    let product = Product(id: 1, name: "Test", description: "Desc", price: 10.0, imageUrl: nil)

    viewModel.addItem(product: product)

    XCTAssertEqual(viewModel.items.count, 1)
    XCTAssertEqual(viewModel.items.first?.quantity, 1)
    XCTAssertEqual(viewModel.total, 10.0)
  }

  func testAddExistingItemIncrementsQuantity() {
    let product = Product(id: 1, name: "Test", description: "Desc", price: 10.0, imageUrl: nil)

    viewModel.addItem(product: product)
    viewModel.addItem(product: product)

    XCTAssertEqual(viewModel.items.count, 1)
    XCTAssertEqual(viewModel.items.first?.quantity, 2)
    XCTAssertEqual(viewModel.total, 20.0)
  }

  func testRemoveItem() {
    let product = Product(id: 1, name: "Test", description: "Desc", price: 10.0, imageUrl: nil)
    viewModel.addItem(product: product)

    let itemToRemove = viewModel.items.first!
    viewModel.removeItem(itemToRemove)

    // Wait for async update
    let expectation = XCTestExpectation(description: "Remove item")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      XCTAssertTrue(self.viewModel.items.isEmpty)
      XCTAssertEqual(self.viewModel.total, 0)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
}
