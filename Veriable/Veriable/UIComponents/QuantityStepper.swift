import SwiftUI

struct QuantityStepper: View {
    @Binding var quantity: Int
    var minValue: Int = 1
    var maxValue: Int = 99
    
    var body: some View {
        HStack(spacing: BrandSpacing.md) {
            controlButton(systemName: "minus", action: decrement)
                .disabled(quantity <= minValue)
            
            Text("\(quantity)")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(BrandColor.textPrimary)
                .frame(minWidth: 20)
                .accessibilityLabel("Quantity: \(quantity)")
            
            controlButton(systemName: "plus", action: increment)
                .disabled(quantity >= maxValue)
        }
    }
    
    private func controlButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(BrandColor.primary)
                .clipShape(Circle())
                .shadow(color: BrandColor.primary.opacity(0.25), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func decrement() {
        if quantity > minValue {
            quantity -= 1
        }
    }
    
    private func increment() {
        if quantity < maxValue {
            quantity += 1
        }
    }
}

struct QuantityStepper_Previews: PreviewProvider {
    static var previews: some View {
        QuantityStepper(quantity: .constant(2))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
