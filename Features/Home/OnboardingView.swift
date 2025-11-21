import SwiftUI

struct OnboardingView: View {
  @StateObject private var viewModel: OnboardingViewModel
  @Environment(\.dismiss) private var dismiss

  init(userRepository: UserRepositoryProtocol, onComplete: @escaping (User) -> Void) {
    _viewModel = StateObject(
      wrappedValue: OnboardingViewModel(userRepository: userRepository, onComplete: onComplete))
  }

  var body: some View {
    ZStack {
      BrandColor.background
        .ignoresSafeArea()

      VStack(spacing: 0) {
        // Progress bar
        progressBar

        // Content
        TabView(selection: $viewModel.currentStep) {
          WelcomeStepView(viewModel: viewModel)
            .tag(OnboardingStep.welcome)

          NameStepView(viewModel: viewModel)
            .tag(OnboardingStep.name)

          EmailStepView(viewModel: viewModel)
            .tag(OnboardingStep.email)

          PasswordStepView(viewModel: viewModel)
            .tag(OnboardingStep.password)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }

      // Error Toast
      if let error = viewModel.errorMessage {
        ToastView(message: error)
          .padding(.horizontal, 16)
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .zIndex(1)
          .onTapGesture {
            withAnimation { viewModel.errorMessage = nil }
          }
          .onAppear {
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
              withAnimation { viewModel.errorMessage = nil }
            }
          }
          .frame(maxHeight: .infinity, alignment: .bottom)
          .padding(.bottom, 24)
      }
    }
  }

  private var progressBar: some View {
    VStack(spacing: 0) {
      HStack {
        if viewModel.currentStep != .welcome {
          Button(action: viewModel.previousStep) {
            Image(systemName: "chevron.left")
              .font(.system(size: 20, weight: .semibold))
              .foregroundColor(.white)
              .frame(width: 44, height: 44)
          }
        }

        Spacer()
      }
      .padding(.horizontal, 20)
      .padding(.top, 8)

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          Rectangle()
            .fill(Color.white.opacity(0.2))
            .frame(height: 8)

          Rectangle()
            .fill(BrandColor.primary)
            .frame(width: geometry.size.width * viewModel.currentStep.progress, height: 8)
            .animation(.spring(response: 0.3), value: viewModel.currentStep)
        }
        .cornerRadius(4)
      }
      .frame(height: 8)
      .padding(.horizontal, 20)
      .padding(.top, 12)
    }
    .frame(height: 80)
  }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
  @ObservedObject var viewModel: OnboardingViewModel

  var body: some View {
    VStack(spacing: 40) {
      Spacer()

      VStack(spacing: 12) {
        Text("Welcome to")
          .font(.system(size: 28, weight: .medium))
          .foregroundColor(.white.opacity(0.8))

        Image("Image")
          .resizable()
          .scaledToFit()
          .frame(width: 220)
          .accessibilityLabel("Veriable")

        Text("AI-Powered Shopping Assistant")
          .font(.system(size: 18, weight: .regular))
          .foregroundColor(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 40)
      }

      Spacer()

      PrimaryButton(title: "GET STARTED", action: viewModel.nextStep)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
  }
}

// MARK: - Name Step
struct NameStepView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(spacing: 30) {
      Spacer()

      VStack(alignment: .leading, spacing: 20) {
        Text("What's your name?")
          .font(.system(size: 28, weight: .bold))
          .foregroundColor(.white)
          .padding(.horizontal, 20)

        TextField("", text: $viewModel.name)
          .placeholder(when: viewModel.name.isEmpty) {
            Text("Enter your name")
              .foregroundColor(.white.opacity(0.4))
          }
          .font(.system(size: 18))
          .foregroundColor(.white)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.white.opacity(0.1))
              .overlay(
                RoundedRectangle(cornerRadius: 16)
                  .stroke(isFocused ? BrandColor.primary : Color.white.opacity(0.2), lineWidth: 2)
              )
          )
          .padding(.horizontal, 20)
          .focused($isFocused)
          .submitLabel(.next)
          .onSubmit {
            if viewModel.canProceed {
              viewModel.nextStep()
            }
          }
      }

      Spacer()

      PrimaryButton(
        title: "NEXT",
        action: viewModel.nextStep,
        isEnabled: viewModel.canProceed
      )
      .padding(.horizontal, 20)
      .padding(.bottom, 40)
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        isFocused = true
      }
    }
  }
}

// MARK: - Email Step
struct EmailStepView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(spacing: 30) {
      Spacer()

      VStack(alignment: .leading, spacing: 20) {
        Text("What's your email?")
          .font(.system(size: 28, weight: .bold))
          .foregroundColor(.white)
          .padding(.horizontal, 20)

        if !viewModel.name.isEmpty {
          Text("Nice to meet you, \(viewModel.name)!")
            .font(.system(size: 16))
            .foregroundColor(BrandColor.primary)
            .padding(.horizontal, 20)
        }

        HStack {
          TextField("", text: $viewModel.email)
            .placeholder(when: viewModel.email.isEmpty) {
              Text("your.email@example.com")
                .foregroundColor(BrandColor.primary)
            }
            .font(.system(size: 18))
            .foregroundColor(.white)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .focused($isFocused)
            .submitLabel(.next)
            .onSubmit {
              if viewModel.canProceed {
                viewModel.nextStep()
              }
            }

          if viewModel.canProceed {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(BrandColor.primary)
              .font(.system(size: 24))
          }
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.1))
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? BrandColor.primary : Color.white.opacity(0.2), lineWidth: 2)
            )
        )
        .padding(.horizontal, 20)
      }

      Spacer()

      PrimaryButton(
        title: "NEXT",
        action: viewModel.nextStep,
        isEnabled: viewModel.canProceed
      )
      .padding(.horizontal, 20)
      .padding(.bottom, 40)
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        isFocused = true
      }
    }
  }
}

// MARK: - Password Step
struct PasswordStepView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  @FocusState private var isFocused: Bool
  @State private var showPassword: Bool = false

  var body: some View {
    VStack(spacing: 30) {
      Spacer()

      VStack(alignment: .leading, spacing: 20) {
        Text("Create a password")
          .font(.system(size: 28, weight: .bold))
          .foregroundColor(.white)
          .padding(.horizontal, 20)

        Text("Keep your account secure")
          .font(.system(size: 16))
          .foregroundColor(.white.opacity(0.7))
          .padding(.horizontal, 20)

        HStack {
          Group {
            if showPassword {
              TextField("", text: $viewModel.password)
            } else {
              SecureField("", text: $viewModel.password)
            }
          }
          .placeholder(when: viewModel.password.isEmpty) {
            Text("At least 6 characters")
              .foregroundColor(.white.opacity(0.4))
          }
          .font(.system(size: 18))
          .foregroundColor(.white)
          .focused($isFocused)
          .submitLabel(.done)
          .onSubmit {
            if viewModel.canProceed {
              viewModel.nextStep()
            }
          }

          Button(action: { showPassword.toggle() }) {
            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
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
                .stroke(isFocused ? BrandColor.primary : Color.white.opacity(0.2), lineWidth: 2)
            )
        )
        .padding(.horizontal, 20)

        if viewModel.password.count > 0 && viewModel.password.count < 6 {
          Text("Password must be at least 6 characters")
            .font(.system(size: 14))
            .foregroundColor(.red.opacity(0.8))
            .padding(.horizontal, 20)
        }
      }

      Spacer()

      if viewModel.isLoading {
        ProgressView()
          .tint(BrandColor.primary)
          .scaleEffect(1.5)
          .padding(.bottom, 40)
      } else {
        PrimaryButton(
          title: "CREATE ACCOUNT",
          action: viewModel.nextStep,
          isEnabled: viewModel.canProceed
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        isFocused = true
      }
    }
  }
}

// MARK: - Toast View
struct ToastView: View {
  let message: String

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemName: "exclamationmark.triangle.fill")
        .foregroundColor(.white)
      Text(message)
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(.white)
        .lineLimit(3)
        .multilineTextAlignment(.leading)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 14)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(Color.red.opacity(0.95))
    )
    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Error")
    .accessibilityHint(message)
  }
}

// MARK: - TextField Placeholder Extension
extension View {
  func placeholder<Content: View>(
    when shouldShow: Bool,
    alignment: Alignment = .leading,
    @ViewBuilder placeholder: () -> Content
  ) -> some View {

    ZStack(alignment: alignment) {
      placeholder().opacity(shouldShow ? 1 : 0)
      self
    }
  }
}
