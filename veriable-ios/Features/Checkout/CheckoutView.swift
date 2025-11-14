import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel: CheckoutViewModel
    
    init(environment: AppEnvironment) {
        _viewModel = StateObject(wrappedValue: CheckoutViewModel(checkoutUseCase: environment.checkoutUseCase,
                                                                 cartRepository: environment.cartRepository))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Payment Method") {
                    Picker("Select Method", selection: $viewModel.paymentMethod) {
                        ForEach(PaymentMethod.allCases) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Section("Order Summary") {
                    summaryRow(title: "Subtotal", value: "$120.00")
                    summaryRow(title: "Tax", value: "$8.50")
                    summaryRow(title: "Discount", value: "-$5.00")
                    summaryRow(title: "Total", value: "$123.50", bold: true)
                }
                
                Section {
                    PrimaryButton(title: viewModel.isProcessing ? "Processing…" : "Complete Payment") {
                        viewModel.checkout()
                    }
                    .disabled(viewModel.isProcessing)
                }
            }
            .navigationTitle("Checkout")
            .alert(item: Binding<String?>(get: { viewModel.confirmationMessage }, set: { _ in
                viewModel.confirmationMessage = nil
            })) { message in
                Alert(title: Text("Checkout"), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func summaryRow(title: String, value: String, bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(bold ? .bold : .regular)
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(environment: .mock)
    }
}
