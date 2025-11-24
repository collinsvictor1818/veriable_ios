import SwiftUI

struct NewLoginView: View {
  @StateObject private var viewModel: LoginViewModel
  @State private var showOnboarding = false

  init(userRepository: UserRepositoryProtocol, onComplete: @escaping (User) -> Void) {
    _viewModel = StateObject(
      wrappedValue: LoginViewModel(userRepository: userRepository, onComplete: onComplete))
  }

  var body: some View {
    ZStack {
      BrandColor.background
        .ignoresSafeArea()

      VStack(spacing: 40) {
        Spacer()

        // Logo and Title
        VStack(spacing: 20) {
          Text("Veriable")
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(BrandColor.primary)

          Text("Welcome Back")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.white)
        }

        // Login Form
        VStack(spacing: 20) {
          // Email Field
          TextField("", text: $viewModel.email)
            .placeholder(when: viewModel.email.isEmpty) {
              Text("Email")
                .foregroundColor(.white.opacity(0.4))
            }
            .font(.system(size: 18))
            .foregroundColor(.white)
            #if os(iOS)
              .keyboardType(.emailAddress)
              .autocapitalization(.none)
            #endif
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                  RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
            )

          // Password Field
          HStack {
            Group {
              if viewModel.showPassword {
                TextField("", text: $viewModel.password)
              } else {
                SecureField("", text: $viewModel.password)
              }
            }
            .placeholder(when: viewModel.password.isEmpty) {
              Text("Password")
                .foregroundColor(.white.opacity(0.4))
            }
            .font(.system(size: 18))
            .foregroundColor(.white)

            Button(action: { viewModel.showPassword.toggle() }) {
              Image(systemName: viewModel.showPassword ? "eye.slash.fill" : "eye.fill")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 20))
            }
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.white.opacity(0.1))
              .overlay(
                RoundedRectangle(cornerRadius: 16)
                  .stroke(Color.white.opacity(0.2), lineWidth: 2)
              )
          )
        }
        .padding(.horizontal, 20)

        // Error Message
        if let error = viewModel.errorMessage {
          Text(error)
            .font(.system(size: 14))
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        }

        // Login Button
        if viewModel.isLoading {
          ProgressView()
            .tint(BrandColor.primary)
            .scaleEffect(1.5)
        } else {
          PrimaryButton(
            title: "LOG IN",
            action: viewModel.login,
            isEnabled: viewModel.canLogin
          )
          .padding(.horizontal, 20)
        }

        // Create Account Button
        Button(action: { showOnboarding = true }) {
          Text("Don't have an account? **Sign Up**")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.8))
        }

        Spacer()
      }
    }
    .fullScreenCover(isPresented: $showOnboarding) {
      OnboardingView(userRepository: viewModel.userRepository, onComplete: viewModel.onComplete)
    }
  }
}

@MainActor
final class LoginViewModel: ObservableObject {
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var showPassword: Bool = false
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  let userRepository: UserRepositoryProtocol
  let onComplete: (User) -> Void

  init(userRepository: UserRepositoryProtocol, onComplete: @escaping (User) -> Void) {
    self.userRepository = userRepository
    self.onComplete = onComplete
  }

  var canLogin: Bool {
    !email.isEmpty && !password.isEmpty
  }

  func login() {
    isLoading = true
    errorMessage = nil

    Task {
      do {
        let user = try await userRepository.loginWithPassword(email: email, password: password)
        onComplete(user)
      } catch {
        errorMessage = "Invalid email or password"
        isLoading = false
      }
    }
  }
}
