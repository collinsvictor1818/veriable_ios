import Combine
import SwiftUI

struct CheckoutView: View {
  @StateObject private var viewModel: CheckoutViewModel

  init(environment: AppEnvironment) {
    _viewModel = StateObject(
      wrappedValue: CheckoutViewModel(
        checkoutUseCase: environment.checkoutUseCase,
        cartRepository: environment.cartRepository))
  }

  var body: some View {
    NavigationStack {
      ZStack(alignment: .top) {
        BrandColor.background
          .ignoresSafeArea()
        ScrollView(showsIndicators: false) {
          VStack(spacing: BrandSpacing.lg) {
            paymentMethodsCard
            savedCards
            orderSummary
            PrimaryButton(title: viewModel.isProcessing ? "Processing…" : "Complete Payment") {
              viewModel.checkout()
            }
            .disabled(viewModel.isProcessing)
          }
          .padding(.horizontal, BrandSpacing.lg)
          .padding(.vertical, BrandSpacing.lg)
        }
      }
      .navigationTitle("Checkout")
    }
    .alert(item: $viewModel.alert) { alert in
      Alert(
        title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
    }
  }

  private var paymentMethodsCard: some View {
    VStack(alignment: .leading, spacing: BrandSpacing.md) {
      Text("Payment Method")
        .font(.system(.title3, design: .rounded).weight(.semibold))
      HStack(spacing: BrandSpacing.sm) {
        ForEach(PaymentMethod.allCases) { method in
          let isSelected = viewModel.paymentMethod == method
          let textColor = isSelected ? BrandColor.textPrimary : BrandColor.textSecondary

          Button {
            viewModel.paymentMethod = method
          } label: {
            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
              Text(method.rawValue)
                .font(.subheadline)
                .foregroundColor(textColor)
              Text(
                method.rawValue == "Credit/Debit Card"
                  ? "Pay with card"
                  : method.rawValue == "Mobile Wallet"
                    ? "Pay with Apple/Google Pay" : "Pay when delivered"
              )
              .font(.caption)
              .foregroundColor(BrandColor.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              viewModel.paymentMethod == method
                ? BrandColor.primary.opacity(0.15) : BrandColor.surface
            )
            .overlay(
              RoundedRectangle(cornerRadius: BrandCornerRadius.medium)
                .stroke(
                  viewModel.paymentMethod == method ? BrandColor.primary : Color.clear, lineWidth: 2
                )
            )
            .cornerRadius(BrandCornerRadius.medium)
          }
          .buttonStyle(.plain)
        }
      }
    }
    .padding(BrandSpacing.lg)
    .brandCardBackground()
  }

  private var savedCards: some View {
    VStack(alignment: .leading, spacing: BrandSpacing.md) {
      Text("Payment Details")
        .font(.system(.title3, design: .rounded).weight(.semibold))
      VStack(spacing: BrandSpacing.sm) {
        HStack {
          Image(systemName: "creditcard")
            .foregroundColor(BrandColor.textSecondary)
          Text("Payment methods will be processed securely at checkout")
            .font(.subheadline)
            .foregroundColor(BrandColor.textSecondary)
          Spacer()
        }
        .padding()
        .background(BrandColor.surface)
        .cornerRadius(BrandCornerRadius.medium)

        Button(action: {}) {
          Label("Add Payment Method", systemImage: "plus.circle")
            .foregroundColor(BrandColor.primary)
        }
      }
    }
    .padding(BrandSpacing.lg)
    .brandCardBackground()
  }

  private var orderSummary: some View {
    VStack(alignment: .leading, spacing: BrandSpacing.sm) {
      Text("Order Summary")
        .font(.system(.title3, design: .rounded).weight(.semibold))
      summaryRow(title: "Subtotal", value: viewModel.subtotal)
      summaryRow(title: "Estimated Tax (7%)", value: viewModel.estimatedTax)
      if viewModel.discount > 0 {
        summaryRow(title: "Discounts", value: -viewModel.discount)
      }
      Divider()
      summaryRow(title: "Total", value: viewModel.total, emphasize: true)
      Text("Secure payment powered by Veriable AI")
        .font(.caption)
        .foregroundColor(BrandColor.textSecondary)
    }
    .padding(BrandSpacing.lg)
    .brandCardBackground()
  }

  private func summaryRow(title: String, value: Double, emphasize: Bool = false) -> some View {
    HStack {
      Text(title)
      Spacer()
      Text(value, format: .currency(code: "USD"))
        .fontWeight(emphasize ? .bold : .regular)
    }
    .font(emphasize ? .headline : .subheadline)
  }
}

#if DEBUG
  struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
      CheckoutView(environment: .mock)
    }
  }
#endif
