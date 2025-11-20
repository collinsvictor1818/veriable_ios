import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel
    
    init(userRepository: UserRepositoryProtocol, onLoginSuccess: @escaping (User) -> Void) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(userRepository: userRepository, onLoginSuccess: onLoginSuccess))
    }
    
    var body: some View {
        ZStack {
            BrandColor.background.ignoresSafeArea()
            
            VStack(spacing: BrandSpacing.xl) {
                Text("Veriable")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(BrandColor.primary)
                
                VStack(spacing: BrandSpacing.md) {
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(BrandCornerRadius.medium)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    PrimaryButton(title: "Continue") {
                        viewModel.login()
                    }
                    .disabled(viewModel.email.isEmpty || viewModel.isLoading)
                    .opacity(viewModel.email.isEmpty || viewModel.isLoading ? 0.6 : 1)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
                .padding(BrandSpacing.lg)
                .background(Color.white.opacity(0.5))
                .cornerRadius(BrandCornerRadius.large)
            }
            .padding()
        }
    }
}
