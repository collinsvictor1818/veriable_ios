import SwiftUI

struct ProductCardView: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            AsyncImage(url: product.imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 140)
                        .background(BrandColor.surface)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipped()
                        .accessibilityHidden(true)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .foregroundColor(BrandColor.textSecondary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(BrandCornerRadius.medium)
            
            Text(product.name)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(BrandColor.textPrimary)
                .lineLimit(2)
            
            Text(product.description)
                .font(.footnote)
                .foregroundColor(BrandColor.textSecondary)
                .lineLimit(2)
            
            HStack {
                Text(product.price, format: .currency(code: "USD"))
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(BrandColor.primary)
                Spacer()
                PrimaryButton(title: "Add", action: action)
                    .frame(width: 40, height: 10)
            }
        }
        .padding(BrandSpacing.md)
        .brandCardBackground()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.name), costs \(product.price, format: .currency(code: "USD"))")
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(product: .mock, action: {})
            .padding()
            .previewLayout(.fixed(width: 40, height: 10))
    }
}
