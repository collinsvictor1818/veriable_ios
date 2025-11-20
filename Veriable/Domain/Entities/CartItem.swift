import Foundation

/// Represents an item in the shopping cart.
///
/// This struct links a `Product` with a quantity. It is `Identifiable` by the
/// product's ID for use in SwiftUI lists.
struct CartItem: Codable, Identifiable, Equatable {
    var id: Int { product.id }
    let product: Product
    var quantity: Int
}

// MARK: - Mock Data

#if DEBUG
extension CartItem {
    /// An array of mock cart items for previews and testing.
    static var mockItems: [CartItem] {
        [
            CartItem(product: Product.mockProducts[0], quantity: 1),
            CartItem(product: Product.mockProducts[1], quantity: 2),
            CartItem(product: Product.mockProducts[2], quantity: 1)
        ]
    }
}
#endif
