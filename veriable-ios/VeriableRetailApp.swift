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
    
    var body: some View {
        TabView {
            HomeView(environment: environment)
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
            CartView(environment: environment)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
            CheckoutView(environment: environment)
                .tabItem {
                    Label("Checkout", systemImage: "creditcard")
                }
        }
    }
}
