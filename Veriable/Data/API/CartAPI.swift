import Foundation

enum CartAPI: Endpoint {
    case fetchCartItems(userId: Int)
    case addCartItem(userId: Int, productId: Int, quantity: Int)
    case updateCartItem(itemId: Int, quantity: Int)
    case deleteCartItem(itemId: Int)
    case clearCart(userId: Int)
    
    var baseURL: String {
        return Config.apiBaseURL
    }
    
    var path: String {
        switch self {
        case .fetchCartItems:
            return "/items/cart_items"
        case .addCartItem:
            return "/items/cart_items"
        case .updateCartItem(let itemId):
            return "/items/cart_items/\(itemId)"
        case .deleteCartItem(let itemId):
            return "/items/cart_items/\(itemId)"
        case .clearCart:
            return "/items/cart_items"
        }
    }
    
    var method: String {
        switch self {
        case .fetchCartItems:
            return "GET"
        case .addCartItem:
            return "POST"
        case .updateCartItem:
            return "PATCH"
        case .deleteCartItem, .clearCart:
            return "DELETE"
        }
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        
        switch self {
        case .fetchCartItems(let userId):
            components?.queryItems = [
                URLQueryItem(name: "filter[user][_eq]", value: "\(userId)")
            ]
        case .clearCart(let userId):
            components?.queryItems = [
                URLQueryItem(name: "filter[user][_eq]", value: "\(userId)")
            ]
        default:
            break
        }
        
        return components?.url
    }
    
    var body: Data? {
        switch self {
        case .addCartItem(let userId, let productId, let quantity):
            let data: [String: Any] = [
                "user": userId,
                "product": productId,
                "quantity": quantity
            ]
            return try? JSONSerialization.data(withJSONObject: data)
            
        case .updateCartItem(_, let quantity):
            let data: [String: Any] = ["quantity": quantity]
            return try? JSONSerialization.data(withJSONObject: data)
            
        default:
            return nil
        }
    }
}

// Response model for cart items from Directus
struct CartItemResponse: Codable {
    let id: Int
    let user: Int
    let product: Int
    let quantity: Int
}
