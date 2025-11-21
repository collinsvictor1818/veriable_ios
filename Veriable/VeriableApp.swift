import SwiftUI

@main
struct VeriableRetailApp: App {
    @StateObject private var appState = AppState()
    private let environment = AppEnvironment.bootstrap()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !appState.hasCompletedOnboarding {
                    OnboardingView(userRepository: environment.userRepository) { user in
                        appState.login(user: user)
                        if let cartRepo = environment.cartRepository as? CartRepository {
                            cartRepo.setUserId(user.id)
                        }
                        if let checkoutUseCase = environment.checkoutUseCase as? CheckoutUseCase {
                            checkoutUseCase.setUserId(user.id)
                        }
                    }
                    .environmentObject(appState)
                } else if appState.currentUser == nil {
                    LoginView(environment: environment)
                        .environmentObject(appState)
                        .onChange(of: appState.currentUser) { oldValue, newValue in
                            if let user = newValue {
                                if let cartRepo = environment.cartRepository as? CartRepository {
                                    cartRepo.setUserId(user.id)
                                }
                                environment.checkoutUseCase.setUserId(user.id)
                            }
                        }
                } else {
                    RootTabView(environment: environment)
                        .environmentObject(appState)
                }
            }
            .preferredColorScheme(appState.theme.colorScheme)
        }
    }
}

struct RootTabView: View {
    let environment: AppEnvironment
    @EnvironmentObject private var appState: AppState
    @State private var showSplash: Bool = true
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                Tab("Discover", systemImage: "sparkles", value: AppTab.discover) {
                    HomeView(environment: environment)
                }
                
                Tab("Scan", systemImage: "camera", value: AppTab.scanner) {
                    ObjectScannerView { detection in
                        // Record the scan in app state
                        appState.addScanRecord(ScanRecord(productName: detection.name, confidence: detection.confidence))
                    }
                }
                
                Tab("Cart", systemImage: "cart", value: AppTab.cart) {
                    CartView(environment: environment)
                }
                
                Tab("Checkout", systemImage: "creditcard", value: AppTab.checkout) {
                    CheckoutView(environment: environment)
                }
            }
            .tint(BrandColor.primary)
            .disabled(showSplash) // prevent interaction while splash is visible
            
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // Dismiss splash after a short delay; adjust as needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}

