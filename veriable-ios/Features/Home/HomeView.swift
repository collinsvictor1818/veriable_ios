import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var appState: AppState
    
    init(environment: AppEnvironment) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(fetchProductsUseCase: environment.fetchProductsUseCase,
                                                             addToCartUseCase: environment.addToCartUseCase))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading products…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(title: "Something went wrong",
                                   message: error,
                                   actionTitle: "Retry",
                                   action: { viewModel.loadProducts(forceRefresh: true) })
                } else if viewModel.products.isEmpty {
                    EmptyStateView(title: "No products yet",
                                   message: "Check back later for fresh arrivals.",
                                   actionTitle: "Reload",
                                   action: { viewModel.loadProducts(forceRefresh: true) })
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            heroCard
                            productGrid
                            specialOffers
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Discover")
        }
        .task {
            viewModel.loadProducts()
        }
    }
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hello, \(appState.currentUser?.name ?? "Guest")")
                .font(.title2).bold()
            Text("Welcome back to Veriable. Earn rewards with every scan.")
                .foregroundColor(.secondary)
            PrimaryButton(title: "Start Scanning") {
                // Placeholder action
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private var productGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Just For You")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.products) { product in
                    ProductCardView(product: product) {
                        appState.addProductToCart(product)
                        viewModel.addToCart(product)
                    }
                }
            }
        }
    }
    
    private var specialOffers: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Special Offers")
                .font(.headline)
            VStack(spacing: 8) {
                offerRow(title: "BOGO Free Pasta", subtitle: "Limited time offer")
                offerRow(title: "Member Exclusive", subtitle: "50 bonus points")
            }
        }
    }
    
    private func offerRow(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(environment: .mock)
            .environmentObject(AppState.mock)
    }
}
