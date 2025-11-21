import Combine
import SwiftUI

struct NearbyStoresView: View {
  @StateObject private var viewModel = StoresViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      Group {
        if viewModel.isLoading {
          ProgressView("Loading stores...")
        } else if let error = viewModel.errorMessage {
          VStack(spacing: 16) {
            Text("Failed to load stores")
              .font(.headline)
            Text(error)
              .font(.caption)
              .foregroundColor(.secondary)
            Button("Retry") {
              viewModel.loadStores()
            }
          }
        } else {
          List(viewModel.stores) { store in
            VStack(alignment: .leading, spacing: 8) {
              Text(store.name)
                .font(.headline)
              Text(store.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
              if let phone = store.phone {
                Text(phone)
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              if let hours = store.hours {
                Text(hours)
                  .font(.caption)
                  .foregroundColor(store.isOpen ? .green : .red)
              }
              Text(store.distance)
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.vertical, 6)
          }
          .refreshable {
            await viewModel.refreshAsync()
          }
        }
      }
      .navigationTitle("Nearby Stores")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Dismiss") { dismiss() }
        }
      }
    }
    .task {
      viewModel.loadStores()
    }
  }
}

@MainActor
final class StoresViewModel: ObservableObject {
  @Published var stores: [Store] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  private let apiClient: APIClientProtocol

  init(apiClient: APIClientProtocol = APIClient()) {
    self.apiClient = apiClient
  }

  func loadStores() {
    Task {
      await fetchStores()
    }
  }

  func refreshAsync() async {
    await fetchStores()
  }

  private func fetchStores() async {
    isLoading = true
    errorMessage = nil

    do {
      let response: DirectusResponse<[Store]> = try await apiClient.request(StoreAPI.fetchStores)
      stores = response.data
    } catch {
      if let appError = error as? AppError {
        errorMessage = appError.message
      } else {
        errorMessage = "Unable to load stores. Please try again."
      }
    }

    isLoading = false
  }
}

#Preview {
  NearbyStoresView()
}
