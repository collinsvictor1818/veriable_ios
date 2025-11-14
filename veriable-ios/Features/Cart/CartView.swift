import SwiftUI

struct CartView: View {
    @StateObject private var viewModel: CartViewModel
    
    init(environment: AppEnvironment) {
        _viewModel = StateObject(wrappedValue: CartViewModel(cartRepository: environment.cartRepository,
                                                             checkoutUseCase: environment.checkoutUseCase))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                BrandColor.background
                    .ignoresSafeArea()
                content
            }
            .navigationTitle("My Cart")
        }
        .onAppear { viewModel.loadCart() }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.items.isEmpty {
            EmptyStateView(title: "Your cart is empty",
                           message: "Add items from the home screen to see them here.",
                           actionTitle: "Shop",
                           action: nil)
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: BrandSpacing.lg) {
                    VStack(spacing: BrandSpacing.md) {
                        ForEach(viewModel.items) { item in
                            cartItemCard(item)
                        }
                    }
                    summaryCard
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.vertical, BrandSpacing.lg)
            }
        }
    }
    
    private func cartItemCard(_ item: CartItem) -> some View {
        HStack(spacing: BrandSpacing.md) {
            AsyncImage(url: item.product.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Color.gray.opacity(0.2)
                        .overlay(Image(systemName: "cart").foregroundColor(.white))
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: BrandCornerRadius.small))
            
            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                Text(item.product.name)
                    .font(.system(.headline, design: .rounded))
                Text(item.product.price, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .foregroundColor(BrandColor.textSecondary)
                Text("Organic produce")
                    .font(.caption)
                    .foregroundColor(BrandColor.textSecondary)
            }
            Spacer()
            VStack(spacing: BrandSpacing.sm) {
                QuantityStepper(quantity: binding(for: item))
                Button(role: .destructive) {
                    viewModel.removeItem(item)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(BrandColor.textSecondary)
                }
            }
        }
        .padding(BrandSpacing.md)
        .brandCardBackground()
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                    Text("Promo Code")
                        .font(.subheadline)
                        .foregroundColor(BrandColor.textSecondary)
                    HStack {
                        TextField("Enter code", text: $viewModel.promoCode)
                        Button("Apply") {}
                            .padding(.horizontal, BrandSpacing.sm)
                            .padding(.vertical, BrandSpacing.xs)
                            .background(BrandColor.accent)
                            .cornerRadius(BrandCornerRadius.small)
                    }
                    .padding(BrandSpacing.sm)
                    .background(BrandColor.surface)
                    .cornerRadius(BrandCornerRadius.small)
                }
            }
            Divider()
            summaryRow(title: "Subtotal", value: subtotal)
            summaryRow(title: "Estimated Tax", value: tax)
            summaryRow(title: "Discounts", value: -discount)
            Divider()
            summaryRow(title: "Total", value: grandTotal, emphasize: true)
            PrimaryButton(title: "Proceed to Checkout") {
                viewModel.checkout()
            }
        }
        .padding(BrandSpacing.lg)
        .brandCardBackground()
    }
    
    private func summaryRow(title: String, value: Double, emphasize: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(emphasize ? .headline : .subheadline)
            Spacer()
            Text(value, format: .currency(code: "USD"))
                .font(emphasize ? .headline : .subheadline)
        }
    }
    
    private func binding(for item: CartItem) -> Binding<Int> {
        Binding(get: {
            item.quantity
        }, set: { newValue in
            viewModel.updateQuantity(for: item, quantity: newValue)
        })
    }
    
    private var subtotal: Double { viewModel.total }
    private var tax: Double { viewModel.total * 0.08 }
    private var discount: Double { viewModel.promoCode.isEmpty ? 0 : 5 }
    private var grandTotal: Double { subtotal + tax - discount }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(environment: .mock)
    }
}
