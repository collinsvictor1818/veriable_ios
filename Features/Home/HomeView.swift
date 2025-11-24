import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel: HomeViewModel
  @EnvironmentObject private var appState: AppState
  @State private var showStores = false
  @State private var showHistory = false
  @State private var showAllProducts = false

  init(environment: AppEnvironment) {
    _viewModel = StateObject(
      wrappedValue: HomeViewModel(
        fetchProductsUseCase: environment.fetchProductsUseCase,
        addToCartUseCase: environment.addToCartUseCase))
  }

  var body: some View {
    NavigationStack {
      ZStack(alignment: .top) {
        BrandColor.background
          .ignoresSafeArea()
        content
          .refreshable {
            await viewModel.refreshAsync()
          }
      }
      .navigationTitle("Discover")
      #if os(iOS)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(destination: ProfileView()) {
              Circle()
              .fill(BrandColor.primary.opacity(0.2))
              .frame(width: 36, height: 36)
              .overlay(
                Text(appState.currentUser?.name.prefix(1).uppercased() ?? "?")
                  .font(.system(size: 16, weight: .bold))
                  .foregroundColor(BrandColor.primary)
              )
            }
          }
        }
      #else
        .toolbar {
          ToolbarItem(placement: .automatic) {
            NavigationLink(destination: ProfileView()) {
              Circle()
              .fill(BrandColor.primary.opacity(0.2))
              .frame(width: 36, height: 36)
              .overlay(
                Text(appState.currentUser?.name.prefix(1).uppercased() ?? "?")
                  .font(.system(size: 16, weight: .bold))
                  .foregroundColor(BrandColor.primary)
              )
            }
          }
        }
      #endif
      .sheet(isPresented: $showStores) {
        NearbyStoresView()
      }
      .sheet(isPresented: $showHistory) {
        RecentScansView()
          .environmentObject(appState)
      }
      .sheet(isPresented: $showAllProducts) {
        AllProductsListView(products: viewModel.products) { product in
          appState.addProductToCart(product)
          viewModel.addToCart(product)
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
      EmptyStateView(
        title: "Something went wrong",
        message: error,
        actionTitle: "Retry",
        action: { viewModel.loadProducts(forceRefresh: true) })
    } else if viewModel.products.isEmpty {
      EmptyStateView(
        title: "No products yet",
        message: "Check back later for fresh arrivals.",
        actionTitle: "Reload",
        action: { viewModel.loadProducts(forceRefresh: true) })
    } else {
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: BrandSpacing.lg) {
          greetingCard
            .padding(.horizontal, BrandSpacing.md)  // Reduced horizontal padding for card

          Group {
            quickActions
            productSection(title: "Just For You")
            productSection(title: "Trending Now")
            specialOffers
          }
          .padding(.horizontal, BrandSpacing.lg)
        }
        .padding(.vertical, BrandSpacing.lg)
      }
    }
  }

  private var greetingName: String {
    if let name = appState.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines),
      !name.isEmpty
    {
      let lower = name.lowercased()
      let banned = ["test", "preview", "user", "guest"]
      if banned.contains(where: { lower.contains($0) }) {
        return "there"
      }
      return name
    }
    return "there"
  }

  private var greetingCard: some View {
    VStack(alignment: .leading) {
      HStack {
        VStack(alignment: .leading) {
          HStack {
            Text("Hello, \(greetingName)")
              .font(.system(size: 24, weight: .bold))
              .foregroundColor(.white)
            Text("👋")
              .font(.system(size: 24))
          }
          Text("Welcome back to Veriable")
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.9))
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 4) {
          Text("Loyalty Points")
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.8))
          Text("0")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
        }
      }

      Button(action: {
        // Navigate to scanner
        appState.switchTab(.scanner)
      }) {
        Text("Start Scanning")
          .font(.system(size: 16, weight: .semibold))
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color.white.opacity(0.2))
          )
      }
    }
    .padding(BrandSpacing.lg)
    .background(
      RoundedRectangle(cornerRadius: BrandCornerRadius.large)
        .fill(
          LinearGradient(
            colors: [BrandColor.primary, BrandColor.primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
    )
    .padding(.horizontal, BrandSpacing.lg)
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
        Button("See all") { showAllProducts = true }
          .font(.footnote)
          .foregroundColor(BrandColor.primary)
      }
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BrandSpacing.md) {
        ForEach(viewModel.products) { product in
          NavigationLink(
            destination:
              ProductDetailsView(product: product) { selected in
                appState.addProductToCart(selected)
                viewModel.addToCart(selected)
              }
          ) {
            ProductCardView(product: product) {
              appState.addProductToCart(product)
              viewModel.addToCart(product)
            }
          }
        }
      }
    }
  }

  private var specialOffers: some View {
    VStack(alignment: .leading, spacing: BrandSpacing.md) {
      Text("Special Offers")
        .font(.system(.title3, design: .rounded).weight(.semibold))
      if viewModel.promotions.isEmpty {
        Text("No active promotions")
          .font(.caption)
          .foregroundColor(BrandColor.textSecondary)
          .padding()
      } else {
        VStack(spacing: BrandSpacing.sm) {
          ForEach(viewModel.promotions) { promotion in
            offerRow(
              title: promotion.title, subtitle: promotion.subtitle, accent: BrandColor.accent)
          }
        }
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
      QuickAction(
        icon: "camera.viewfinder", title: "Start Scanning", subtitle: "Use the camera",
        type: .scanner),
      QuickAction(
        icon: "mappin.and.ellipse", title: "Find Stores", subtitle: "Nearby locations",
        type: .stores),
      QuickAction(
        icon: "clock.arrow.circlepath", title: "Recent Scans", subtitle: "View history",
        type: .history),
    ]
  }

  private func handleQuickAction(_ action: QuickAction) {
    switch action.type {
    case .scanner:
      appState.switchTab(.scanner)
    case .stores:
      showStores = true
    case .history:
      showHistory = true
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

private struct AllProductsListView: View {
  let products: [Product]
  let onAdd: (Product) -> Void
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      List(products) { product in
        HStack(spacing: 12) {
          AsyncImage(url: product.imageUrl) { phase in
            switch phase {
            case .empty:
              ProgressView().frame(width: 56, height: 56)
            case .success(let image):
              image.resizable().scaledToFill().frame(width: 56, height: 56).clipped().cornerRadius(
                8)
            case .failure:
              Image(systemName: "photo").resizable().scaledToFit().frame(width: 56, height: 56)
                .foregroundColor(.secondary)
            @unknown default:
              EmptyView()
            }
          }
          VStack(alignment: .leading, spacing: 4) {
            Text(product.name).font(.headline)
            Text(product.price, format: .currency(code: "USD")).font(.subheadline).foregroundColor(
              .secondary)
          }
          Spacer()
          Button(action: { onAdd(product) }) {
            Image(systemName: "plus").font(.headline).padding(8)
          }
          .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 6)
      }
      .navigationTitle("All Products")
      .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Dismiss") { dismiss() } } }
    }
  }
}

#if DEBUG
  struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
      HomeView(environment: .mock)
        .environmentObject(AppState.mock)
    }
  }
#endif
