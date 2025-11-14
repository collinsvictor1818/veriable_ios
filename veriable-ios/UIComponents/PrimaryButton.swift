import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BrandSpacing.md)
                .padding(.horizontal, BrandSpacing.lg)
                .background(isEnabled ? BrandColor.button : BrandColor.button.opacity(0.4))
                .cornerRadius(BrandCornerRadius.large)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(title: "Add", action: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
