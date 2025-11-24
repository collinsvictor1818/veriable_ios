import Combine
import SwiftUI

enum OnboardingStep: Int, CaseIterable {
  case welcome = 0
  case name
  case email
  case password
  case complete

  var progress: Double {
    Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
  }
}

@MainActor
final class OnboardingViewModel: ObservableObject {
  @Published var currentStep: OnboardingStep = .welcome
  @Published var name: String = ""
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  private let userRepository: UserRepositoryProtocol
  private let onComplete: (User) -> Void

  init(userRepository: UserRepositoryProtocol, onComplete: @escaping (User) -> Void) {
    self.userRepository = userRepository
    self.onComplete = onComplete
  }

  var canProceed: Bool {
    switch currentStep {
    case .welcome, .complete:
      return true
    case .name:
      return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .email:
      return isValidEmail(email)
    case .password:
      return password.count >= 6
    }
  }

  func nextStep() {
    guard canProceed else { return }

    if currentStep == .password {
      completeOnboarding()
    } else if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
      withAnimation(.spring(response: 0.3)) {
        currentStep = nextStep
      }
    }
  }

  func previousStep() {
    if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
      withAnimation(.spring(response: 0.3)) {
        currentStep = previousStep
      }
    }
  }

  private func completeOnboarding() {
    isLoading = true
    errorMessage = nil

    Task {
      do {
        print("🔵 Creating account: name=\(name), email=\(email)")
        let user = try await userRepository.createAccount(
          name: name, email: email, password: password)
        print("✅ Account created successfully: \(user)")
        await MainActor.run {
          onComplete(user)
        }
      } catch {
        print("❌ Error creating account: \(error)")
        print("❌ Error type: \(type(of: error))")
        print("❌ Error description: \(error.localizedDescription)")

        await MainActor.run {
          // Handle different error types
          if let appError = error as? AppError {
            errorMessage = appError.message
          } else if let nsError = error as? NSError {
            // Provide more helpful error messages
            if nsError.domain.contains("NSURLError") {
              errorMessage = "Network error. Please check your internet connection."
            } else if nsError.localizedDescription.contains("409")
              || nsError.localizedDescription.contains("duplicate")
              || nsError.localizedDescription.contains("already exists")
            {
              errorMessage = "This email is already registered. Please try logging in instead."
            } else if nsError.localizedDescription.contains("400") {
              errorMessage = "Invalid information. Please check your details."
            } else {
              errorMessage = "Unable to create account.\n\(nsError.localizedDescription)"
            }
          } else {
            errorMessage =
              "Unable to create account. Please try again.\n\(error.localizedDescription)"
          }
          isLoading = false
        }
      }
    }
  }

  private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }
}
