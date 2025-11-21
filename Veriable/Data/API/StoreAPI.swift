import Foundation

enum StoreAPI: Endpoint {
    case fetchStores
    
    var baseURL: String {
        return Config.apiBaseURL
    }
    
    var path: String {
        return "/items/stores"
    }
    
    var method: String {
        return "GET"
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = [
            URLQueryItem(name: "filter[is_open][_eq]", value: "true")
        ]
        return components?.url
    }
}

enum PromotionAPI: Endpoint {
    case fetchPromotions
    
    var baseURL: String {
        return Config.apiBaseURL
    }
    
    var path: String {
        return "/items/promotions"
    }
    
    var method: String {
        return "GET"
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = [
            URLQueryItem(name: "filter[is_active][_eq]", value: "true")
        ]
        return components?.url
    }
}
