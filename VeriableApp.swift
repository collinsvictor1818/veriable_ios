import SwiftUI

@main
struct VeriableRetailApp: App {
  @StateObject private var appState = AppState()
  private let environment = AppEnvironment.bootstrap()

  var body: some Scene {
    WindowGroup {
      if !appState.hasCompletedOnboarding {
        // First-time user - show onboarding
        OnboardingView(userRepository: environment.userRepository) { user in
          appState.login(user: user)
          // Set user ID in cart repository for syncing
          if let cartRepo = environment.cartRepository as? CartRepository {
            cartRepo.setUserId(user.id)
          }
          // Set user ID in checkout use case
          if let checkoutUseCase = environment.checkoutUseCase as? CheckoutUseCase {
            checkoutUseCase.setUserId(user.id)
          }
        }
      } else if appState.currentUser == nil {
        // Returning user without active session - show login
        NewLoginView(userRepository: environment.userRepository) { user in
          appState.login(user: user)
          // Set user ID in cart repository for syncing
          if let cartRepo = environment.cartRepository as? CartRepository {
            cartRepo.setUserId(user.id)
          }
          // Set user ID in checkout use case
          if let checkoutUseCase = environment.checkoutUseCase as? CheckoutUseCase {
            checkoutUseCase.setUserId(user.id)
          }
        }
      } else {
        // Logged in user - show main app
        RootTabView(environment: environment)
          .environmentObject(appState)
      }
    }
  }
}

struct RootTabView: View {
  let environment: AppEnvironment
  @EnvironmentObject private var appState: AppState

  var body: some View {
    TabView(selection: $appState.selectedTab) {
      HomeView(environment: environment)
        .tabItem {
          Label("Discover", systemImage: "sparkles")
        }
        .tag(AppTab.discover)
      ScannerView()
        .tabItem {
          Label("Scan", systemImage: "camera.viewfinder")
        }
        .tag(AppTab.scanner)
      CartView(environment: environment)
        .tabItem {
          Label("Cart", systemImage: "cart")
        }
        .tag(AppTab.cart)
      CheckoutView(environment: environment)
        .tabItem {
          Label("Checkout", systemImage: "creditcard")
        }
        .tag(AppTab.checkout)
      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gearshape")
        }
        .tag(AppTab.settings)
    }
  }
}
