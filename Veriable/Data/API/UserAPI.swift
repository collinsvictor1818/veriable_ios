import Foundation

enum UserAPI: Endpoint {
    case fetchUser(email: String)
    case createUser(CreateUserRequest)
    
    var baseURL: String {
        return Config.apiBaseURL
    }
    
    var path: String {
        switch self {
        case .fetchUser:
            return "/items/app_users"
        case .createUser:
            return "/items/app_users"
        }
    }
    
    var method: String {
        switch self {
        case .fetchUser:
            return "GET"
        case .createUser:
            return "POST"
        }
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        
        switch self {
        case .fetchUser(let email):
            components?.queryItems = [
                URLQueryItem(name: "filter[email][_eq]", value: email)
            ]
        default:
            break
        }
        
        return components?.url
    }
}

// Extension to support body for POST requests
extension UserAPI {
    var body: Data? {
        switch self {
        case .createUser(let userRequest):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(userRequest)
        default:
            return nil
        }
    }
}
