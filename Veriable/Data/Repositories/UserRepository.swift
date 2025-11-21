import Foundation

protocol UserRepositoryProtocol {
    func login(email: String) async throws -> User
    func loginWithPassword(email: String, password: String) async throws -> User
    func createAccount(name: String, email: String, password: String) async throws -> User
}

final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // Legacy email-only login (for backward compatibility)
    func login(email: String) async throws -> User {
        let users: [User] = try await apiClient.request(UserAPI.fetchUser(email: email))
        
        if let user = users.first {
            return user
        } else {
            // Create new user if doesn't exist
            let createRequest = CreateUserRequest(name: email.components(separatedBy: "@").first ?? "User", email: email, password: nil)
            let createdUser: User = try await apiClient.request(UserAPI.createUser(createRequest))
            return createdUser
        }
    }
    
    // Login with password
    func loginWithPassword(email: String, password: String) async throws -> User {
        let passwordHash = password.sha256()
        let users: [User] = try await apiClient.request(UserAPI.loginWithPassword(email: email, passwordHash: passwordHash))
        
        guard let user = users.first else {
            throw AppError.data(.decodingFailed(NSError(domain: "UserRepository", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password"])))
        }
        
        return user
    }
    
    // Create new account with password
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let passwordHash = password.sha256()
        let createRequest = CreateUserRequest(name: name, email: email, password: passwordHash)
        let user: User = try await apiClient.request(UserAPI.createUser(createRequest))
        return user
    }
}

struct CreateUserRequest: Codable {
    let name: String
    let email: String
    let password: String?
}
