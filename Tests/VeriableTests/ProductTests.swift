import XCTest

@testable import VeriableLib

final class ProductTests: XCTestCase {
  func testProductEquality() {
    let product1 = Product(id: 1, name: "Test", description: "Desc", price: 10.0, imageUrl: nil)
    let product2 = Product(id: 1, name: "Test", description: "Desc", price: 10.0, imageUrl: nil)
    let product3 = Product(id: 2, name: "Other", description: "Desc", price: 10.0, imageUrl: nil)

    XCTAssertEqual(product1, product2)
    XCTAssertNotEqual(product1, product3)
  }

  func testProductDecoding() throws {
    let json = """
      {
          "id": 1,
          "name": "Test Product",
          "description": "A test product",
          "price": 9.99,
          "imageUrl": "https://example.com/image.jpg"
      }
      """.data(using: .utf8)!

    let product = try JSONDecoder().decode(Product.self, from: json)

    XCTAssertEqual(product.id, 1)
    XCTAssertEqual(product.name, "Test Product")
    XCTAssertEqual(product.price, 9.99)
  }
}
