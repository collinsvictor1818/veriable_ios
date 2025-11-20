import SwiftUI

struct ProductDetailsView: View {
    let product: Product
    let onAdd: (Product) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            AsyncImage(url: product.imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .background(Color(.systemGray5))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 300)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text(product.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, Spacing.medium)
                
                Text(product.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text(product.price, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundColor(BrandColor.accent)
                    .padding(.vertical, Spacing.small)
                
                PrimaryButton(title: "Add to Cart") {
                    onAdd(product)
                }
                .padding(.top, Spacing.medium)
            }
            .padding(.horizontal, Spacing.medium)
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(BrandColor.accent)
                }
            }
        }
    }
}

// MARK: - Local Helpers

private enum Spacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
}

// MARK: - Preview

#if DEBUG
struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductDetailsView(product: Product.mock) { _ in }
        }
    }
}
#endif
