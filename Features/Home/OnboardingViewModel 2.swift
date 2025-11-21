import Combine
import Foundation

enum OnboardingStep: Hashable {
  case welcome
  case name
  case email
  case password

  var progress: Double {
    switch self {
    case .welcome: return 0.25
    case .name: return 0.5
    case .email: return 0.75
    case .password: return 1.0
    }
  }

  var next: OnboardingStep? {
    switch self {
    case .welcome: return .name
    case .name: return .email
    case .email: return .password
    case .password: return nil
    }
  }

  var previous: OnboardingStep? {
    switch self {
    case .welcome: return nil
    case .name: return .welcome
    case .email: return .name
    case .password: return .email
    }
  }
}

final class OnboardingViewModel: ObservableObject {
  // Inputs
  @Published var currentStep: OnboardingStep = .welcome
  @Published var name: String = ""
  @Published var email: String = ""
  @Published var password: String = ""

  // State
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
    case .welcome:
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
    errorMessage = nil
    if currentStep == .password {
      // Final step: create account
      guard canProceed, !isLoading else { return }
      isLoading = true
      let nameValue = name.trimmingCharacters(in: .whitespacesAndNewlines)
      let emailValue = email.trimmingCharacters(in: .whitespacesAndNewlines)
      let passwordValue = password
      Task { @MainActor in
        do {
          let user = try await userRepository.createAccount(
            name: nameValue, email: emailValue, password: passwordValue)
          isLoading = false
          onComplete(user)
        } catch {
          isLoading = false
          if let appError = error as? AppError {
            errorMessage = appError.message
          } else if let userFacing = error as? UserFacingError {
            errorMessage = userFacing.message
          } else {
            errorMessage = error.localizedDescription
          }
        }
      }
    } else if let next = currentStep.next, canProceed {
      currentStep = next
    }
  }

  func previousStep() {
    errorMessage = nil
    if let prev = currentStep.previous {
      currentStep = prev
    }
  }

  // MARK: - Validation
  private func isValidEmail(_ email: String) -> Bool {
    let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
    // Simple but adequate validation for onboarding
    return trimmed.contains("@") && trimmed.contains(".") && !trimmed.hasPrefix("@")
      && !trimmed.hasSuffix("@")
  }
}
