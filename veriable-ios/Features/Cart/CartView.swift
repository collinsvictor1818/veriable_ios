import SwiftUI

struct CartView: View {
    @StateObject private var viewModel: CartViewModel
    
    init(environment: AppEnvironment) {
        _viewModel = StateObject(wrappedValue: CartViewModel(cartRepository: environment.cartRepository,
                                                             checkoutUseCase: environment.checkoutUseCase))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.items.isEmpty {
                    EmptyStateView(title: "Your cart is empty",
                                   message: "Add items from the home screen to see them here.",
                                   actionTitle: "Shop",
                                   action: nil)
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.product.name)
                                        .font(.headline)
                                    Text(item.product.price, format: .currency(code: "USD"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                QuantityStepper(quantity: binding(for: item))
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.map { viewModel.items[$0] }.forEach(viewModel.removeItem)
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Promo Code")
                            Spacer()
                            TextField("Enter code", text: $viewModel.promoCode)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack {
                            Text("Total")
                                .font(.title3).bold()
                            Spacer()
                            Text(viewModel.total, format: .currency(code: "USD"))
                                .font(.title3).bold()
                        }
                        
                        PrimaryButton(title: "Proceed to Checkout") {
                            viewModel.checkout()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Cart")
        }
        .onAppear { viewModel.loadCart() }
    }
    
    private func binding(for item: CartItem) -> Binding<Int> {
        Binding(get: {
            item.quantity
        }, set: { newValue in
            viewModel.updateQuantity(for: item, quantity: newValue)
        })
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(environment: .mock)
    }
}
