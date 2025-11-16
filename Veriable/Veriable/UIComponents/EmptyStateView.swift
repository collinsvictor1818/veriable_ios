import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: BrandSpacing.md) {
            Image(systemName: "cart")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(BrandColor.accent)
                .accessibilityHidden(true)
            
            Text(title)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(BrandColor.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.body)
                .foregroundColor(BrandColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BrandSpacing.lg)
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(BrandSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: BrandCornerRadius.large, style: .continuous)
                .fill(BrandColor.surface)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
        .padding(BrandSpacing.lg)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(title: "Cart is Empty",
                       message: "Browse products and add them to your cart to see them here.",
                       actionTitle: "Browse",
                       action: {})
    }
}
