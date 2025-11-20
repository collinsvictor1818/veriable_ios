import SwiftUI
import MapKit

struct StoreFinderView: View {
    @Environment(\.dismiss) private var dismiss
    private let stores = Store.mockStores
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        NavigationStack {
            VStack(spacing: BrandSpacing.md) {
                Map(coordinateRegion: $region, annotationItems: stores) { store in
                    MapMarker(coordinate: store.location, tint: BrandColor.primary)
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: BrandCornerRadius.large))
                .padding(.horizontal)
                
                List(stores) { store in
                    VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                        Text(store.name)
                            .font(.headline)
                        Text(store.address)
                            .font(.subheadline)
                            .foregroundColor(BrandColor.textSecondary)
                        Text(store.distance)
                            .font(.caption)
                            .foregroundColor(BrandColor.accent)
                    }
                    .padding(.vertical, BrandSpacing.xs)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Find Stores")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
    }
}

struct StoreFinderView_Previews: PreviewProvider {
    static var previews: some View {
        StoreFinderView()
    }
}

struct Store: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: String
    let location: CLLocationCoordinate2D
    
    static var mockStores: [Store] {
        [
            Store(name: "Veriable Market Downtown",
                  address: "123 Market St, San Francisco",
                  distance: "0.4 mi",
                  location: CLLocationCoordinate2D(latitude: 37.779, longitude: -122.418)),
            Store(name: "Veriable Express SOMA",
                  address: "500 Howard St, San Francisco",
                  distance: "0.9 mi",
                  location: CLLocationCoordinate2D(latitude: 37.789, longitude: -122.399)),
            Store(name: "Veriable Marina",
                  address: "700 Lombard St, San Francisco",
                  distance: "1.8 mi",
                  location: CLLocationCoordinate2D(latitude: 37.803, longitude: -122.418))
        ]
    }
}
