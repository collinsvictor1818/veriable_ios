import SwiftUI

@main
struct VeriableRetailApp: App {
    @StateObject private var appState = AppState(currentUser: .mock)
    private let environment = AppEnvironment.bootstrap()
    
    var body: some Scene {
        WindowGroup {
            RootTabView(environment: environment)
                .environmentObject(appState)
        }
    }
}

struct RootTabView: View {
    let environment: AppEnvironment
    @EnvironmentObject private var appState: AppState
    
    /// The main content for this view.
    ///
    /// Builds the application's primary tab-based navigation using a `TabView` bound
    /// to the shared `AppState`'s `selectedTab`. It presents five tabs:
    /// - Discover: Shows `HomeView` for exploring products and content.
    /// - Scan: Shows `ScannerView` for scanning items.
    /// - Cart: Shows `CartView` for reviewing selected items.
    /// - Checkout: Shows `CheckoutView` for completing purchases.
    /// - Settings: Shows `SettingsView` for application preferences.
    ///
    /// Each tab is configured with an SF Symbol and tagged with its corresponding
    /// `AppTab` case to maintain selection state across the app.
    ///
    /// Requirements:
    /// - An `AppEnvironment` instance to inject dependencies into child views.
    /// - An `AppState` provided via `.environmentObject` to manage the selected tab
    ///   and other global state.
    /// - The corresponding views (`HomeView`, `ScannerView`, `CartView`,
    ///   `CheckoutView`, and `SettingsView`) must be available in scope.
    ///
    /// Returns:
    /// A view hierarchy representing the root tab interface of the application.
    ///
    /// See Also:
    /// - `TabView`
    /// - `AppTab`
    /// - `AppState.selectedTab`
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
        }
        .tint(BrandColor.primary)
    }
}
