import SwiftUI
import MapKit

struct StoreFinderView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @StateObject private var viewModel = StoresViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: viewModel.stores) { store in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: store.latitude ?? 37.7749,
                        longitude: store.longitude ?? -122.4194
                    )) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                            Text(store.name)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    if !viewModel.stores.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.stores) { store in
                                    StoreCardView(store: store)
                                }
                            }
                            .padding()
                        }
                        .background(Color.white.opacity(0.95))
                    }
                }
            }
            .navigationTitle("Find Stores")
            .task {
                viewModel.loadStores()
            }
        }
    }
}

struct StoreCardView: View {
    let store: Store
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.name)
                .font(.headline)
            Text(store.address)
                .font(.caption)
                .foregroundColor(.secondary)
            if let phone = store.phone {
                Text(phone)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    StoreFinderView()
}
