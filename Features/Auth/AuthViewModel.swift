import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userRepository: UserRepositoryProtocol
    private let onLoginSuccess: (User) -> Void
    
    init(userRepository: UserRepositoryProtocol, onLoginSuccess: @escaping (User) -> Void) {
        self.userRepository = userRepository
        self.onLoginSuccess = onLoginSuccess
    }
    
    func login() {
        guard !email.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await userRepository.login(email: email)
                onLoginSuccess(user)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
