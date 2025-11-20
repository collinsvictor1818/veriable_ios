import Foundation

protocol UserRepositoryProtocol {
    func login(email: String) async throws -> User
}

final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func login(email: String) async throws -> User {
        // 1. Try to fetch user by email
        let users: [User] = try await apiClient.request(UserAPI.fetchUser(email: email))
        
        if let existingUser = users.first {
            return existingUser
        }
        
        // 2. If not found, create new user
        let newUserRequest = CreateUserRequest(name: email.components(separatedBy: "@").first ?? "User", email: email)
        
        // We need to decode the response which should be the created User
        // Directus returns the created item wrapped in "data"
        let createdUser: User = try await apiClient.request(UserAPI.createUser(newUserRequest))
        return createdUser
    }
}

struct CreateUserRequest: Codable {
    let name: String
    let email: String
}
