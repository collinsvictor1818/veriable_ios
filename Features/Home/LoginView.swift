import SwiftUI

struct LoginView: View {
  let environment: AppEnvironment
  let logoImageName: String

  @EnvironmentObject private var appState: AppState

  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isLoading: Bool = false
  @State private var errorMessage: String?
  @State private var isSignUp: Bool = false

  init(environment: AppEnvironment, logoImageName: String = "Image") {
    self.environment = environment
    self.logoImageName = logoImageName
  }

  private func friendlyMessage(for error: Error) -> String {
    if let urlError = error as? URLError {
      switch urlError.code {
      case .notConnectedToInternet:
        return "You're offline. Please check your internet connection."
      case .timedOut:
        return "The request timed out. Please try again."
      default:
        return urlError.localizedDescription
      }
    }
    let nsError = error as NSError
    // Map common decoding/auth errors to clearer text
    if nsError.domain.contains("NSCocoaErrorDomain")
      || nsError.localizedDescription.contains("decoding")
    {
      return "We had trouble reading the server response. Please try again later."
    }
    if nsError.localizedDescription.lowercased().contains("unauthorized") || nsError.code == 401 {
      return "Incorrect email or password. Please try again."
    }
    // Generic fallback
    return error.localizedDescription.isEmpty
      ? "Something went wrong. Please try again." : error.localizedDescription
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Spacer()
        Image(logoImageName)
          .resizable()
          .scaledToFit()
          .frame(width: 220)
          .accessibilityLabel("Veriable")
        Text("Sign in to continue")
          .font(.title2.bold())
        VStack(spacing: 12) {
          TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(BrandColor.surface)
            .cornerRadius(12)
          SecureField("Password", text: $password)
            .textContentType(.password)
            .padding()
            .background(BrandColor.surface)
            .cornerRadius(12)
        }
        if let errorMessage = errorMessage {
          Text(errorMessage)
            .font(.footnote)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        PrimaryButton(title: isLoading ? "Please wait…" : (isSignUp ? "Create Account" : "Sign In"))
        {
          Task { await submit() }
        }
        .disabled(isLoading || email.isEmpty || password.isEmpty)
        Spacer()
      }
      .padding(24)
      .background(BrandColor.background.ignoresSafeArea())
      .navigationTitle("Login")
    }
  }

  @MainActor
  private func submit() async {
    isLoading = true
    errorMessage = nil
    do {
      let user: User
      if isSignUp {
        user = try await environment.userRepository.createAccount(
          name: email.components(separatedBy: "@").first ?? "", email: email, password: password)
      } else {
        user = try await environment.userRepository.loginWithPassword(
          email: email, password: password)
      }
      appState.login(user: user)
    } catch {
      errorMessage = friendlyMessage(for: error)
    }
    isLoading = false
  }
}

#Preview {
  LoginView(environment: .mock)
    .environmentObject(AppState())
}
