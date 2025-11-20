import SwiftUI

struct NearbyStoresView: View {
    struct Store: Identifiable {
        let id = UUID()
        let name: String
        let address: String
        let distance: String
    }
    
    private let stores: [Store] = [
        Store(name: "Corner Market", address: "123 Main St", distance: "0.3 mi"),
        Store(name: "Green Grocers", address: "456 Oak Ave", distance: "0.7 mi"),
        Store(name: "Fresh Foods", address: "789 Pine Rd", distance: "1.2 mi"),
        Store(name: "Farmers Market", address: "321 Elm St", distance: "1.5 mi")
    ]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(stores) { store in
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name).font(.headline)
                    Text(store.address).font(.subheadline).foregroundColor(.secondary)
                    Text(store.distance).font(.caption).foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Nearby Stores")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NearbyStoresView()
}
