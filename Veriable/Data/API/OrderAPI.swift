import Foundation

enum OrderAPI: Endpoint {
    case createOrder(userId: Int, total: Double, items: [CartItem])
    
    var baseURL: String {
        return Config.apiBaseURL
    }
    
    var path: String {
        return "/items/orders"
    }
    
    var method: String {
        return "POST"
    }
    
    var url: URL? {
        return URL(string: baseURL + path)
    }
    
    var body: Data? {
        switch self {
        case .createOrder(let userId, let total, _):
            let data: [String: Any] = [
                "user": userId,
                "total": total,
                "status": "pending"
            ]
            return try? JSONSerialization.data(withJSONObject: data)
        }
    }
}

// Response models
struct OrderResponse: Codable {
    let id: Int
    let user: Int
    let total: Double
    let status: String
}

struct OrderItemRequest: Codable {
    let order: Int
    let product: Int
    let quantity: Int
    let price: Double
}
