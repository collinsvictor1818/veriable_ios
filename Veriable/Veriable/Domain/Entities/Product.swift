import Foundation

/// Represents a product available for purchase.
///
/// Conforms to `Codable` for data serialization, `Identifiable` for use in
/// SwiftUI lists, and `Equatable` for easy comparison.
struct Product: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageUrl: URL?
}

// MARK: - Mock Data

#if DEBUG
extension Product {
    /// A mock product for previews and testing.
    static var mock: Product {
        Product(id: "1",
                name: "Organic Eggs",
                description: "A dozen fresh, organic, free-range eggs.",
                price: 6.99,
                imageUrl: URL(string: "https://example.com/eggs.jpg"))
    }
    
    /// An array of mock products for previews and testing.
    static var mockProducts: [Product] {
        [
            Product(id: "1", name: "Organic Eggs", description: "Fresh, free-range eggs.", price: 6.99, imageUrl: nil),
            Product(id: "2", name: "Organic Avocado", description: "Ripe and ready to eat.", price: 2.49, imageUrl: nil),
            Product(id: "3", name: "Whole Milk", description: "Gallon of whole milk.", price: 3.59, imageUrl: nil),
            Product(id: "4", name: "Cold Brew", description: "Concentrated cold brew coffee.", price: 7.49, imageUrl: nil),
            Product(id: "5", name: "Almond Flour", description: "Finely ground almond flour.", price: 11.99, imageUrl: nil),
        ]
    }
}
#endif
