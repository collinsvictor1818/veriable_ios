import Foundation

enum UserAPI: Endpoint {
    case fetchUser(email: String)
    case createUser(CreateUserRequest)
    case loginWithPassword(email: String, passwordHash: String)
    
    var baseURL: String {
        return Config.apiBaseURL
    }
    
    var path: String {
        switch self {
        case .fetchUser, .loginWithPassword:
            return "/items/app_users"
        case .createUser:
            return "/items/app_users"
        }
    }
    
    var method: String {
        switch self {
        case .fetchUser, .loginWithPassword:
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
        case .loginWithPassword(let email, let passwordHash):
            components?.queryItems = [
                URLQueryItem(name: "filter[email][_eq]", value: email),
                URLQueryItem(name: "filter[password][_eq]", value: passwordHash)
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
