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
            ZStack(alignment: .top) {
                BrandColor.background
                    .ignoresSafeArea()
                content
            }
            .navigationTitle("Discover")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.refresh) {
                        Image(systemName: "bell")
                            .foregroundColor(BrandColor.textPrimary)
                    }
                }
            }
        }
        .task {
            viewModel.loadProducts()
        }
    }
    
    @ViewBuilder
    private var content: some View {
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
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: BrandSpacing.xl) {
                    heroCard
                    quickActions
                    productSection(title: "Just For You")
                    productSection(title: "Trending Now")
                    specialOffers
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.vertical, BrandSpacing.lg)
            }
        }
    }
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                    Text("Hello, \(appState.currentUser?.name ?? "Guest") 👋")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.white)
                    Text("Welcome back to Veriable")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Loyalty Points")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(appState.loyaltyPoints)")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundColor(.white)
                }
            }
            PrimaryButton(title: "Start Scanning") {
                appState.switchTab(.scanner)
            }
            .background(
                RoundedRectangle(cornerRadius: BrandCornerRadius.large)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .padding(BrandSpacing.lg)
        .background(
            LinearGradient(colors: [BrandColor.primary, BrandColor.primary.opacity(0.8)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .cornerRadius(BrandCornerRadius.large)
        )
        .shadow(color: BrandColor.primary.opacity(0.3), radius: 16, x: 0, y: 10)
    }
    
    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BrandSpacing.md) {
                ForEach(quickActionItems) { action in
                    Button {
                        handleQuickAction(action)
                    } label: {
                        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                            Image(systemName: action.icon)
                                .font(.title2)
                                .foregroundColor(BrandColor.primary)
                                .padding(BrandSpacing.sm)
                                .background(BrandColor.surface)
                                .clipShape(Circle())
                            Text(action.title)
                                .font(.subheadline)
                                .foregroundColor(BrandColor.textPrimary)
                            Text(action.subtitle)
                                .font(.caption)
                                .foregroundColor(BrandColor.textSecondary)
                        }
                        .padding(BrandSpacing.md)
                        .brandCardBackground()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func productSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            HStack {
                Text(title)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                Spacer()
                Button("See all", action: {})
                    .font(.footnote)
                    .foregroundColor(BrandColor.primary)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BrandSpacing.md) {
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
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            Text("Special Offers")
                .font(.system(.title3, design: .rounded).weight(.semibold))
            VStack(spacing: BrandSpacing.sm) {
                offerRow(title: "BOGO Free Pasta", subtitle: "Limited time offer", accent: BrandColor.accent)
                offerRow(title: "Member Exclusive", subtitle: "50 bonus points", accent: BrandColor.primary.opacity(0.2))
            }
        }
    }
    
    private func offerRow(title: String, subtitle: String, accent: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(BrandColor.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(BrandColor.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(BrandColor.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: BrandCornerRadius.medium)
                .fill(accent.opacity(0.3))
        )
    }
    
    private var quickActionItems: [QuickAction] {
        [
            QuickAction(icon: "camera.viewfinder", title: "Start Scanning", subtitle: "Use the camera", type: .scanner),
            QuickAction(icon: "mappin.and.ellipse", title: "Find Stores", subtitle: "Nearby locations", type: .stores),
            QuickAction(icon: "clock.arrow.circlepath", title: "Recent Scans", subtitle: "View history", type: .history)
        ]
    }
    
    private func handleQuickAction(_ action: QuickAction) {
        switch action.type {
        case .scanner:
            appState.switchTab(.scanner)
        case .stores, .history:
            // Future navigation hooks
            break
        }
    }
}

private struct QuickAction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let type: QuickActionType
}

private enum QuickActionType {
    case scanner
    case stores
    case history
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(environment: .mock)
            .environmentObject(AppState.mock)
    }
}
