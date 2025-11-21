import CoreLocation
import Foundation

// Store Entity
struct Store: Codable, Identifiable {
  let id: Int
  let name: String
  let address: String
  let phone: String?
  let hours: String?
  let latitude: Double?
  let longitude: Double?
  let isOpen: Bool

  var distance: String {
    // Calculate distance based on user location
    // For now, return placeholder
    guard let lat = latitude, let lon = longitude else {
      return "N/A"
    }
    // TODO: Calculate actual distance from user location
    return "0.5 mi"
  }

  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: latitude ?? 0,
      longitude: longitude ?? 0
    )
  }
}

// Promotion Entity
struct Promotion: Codable, Identifiable {
  let id: Int
  let title: String
  let subtitle: String
  let isActive: Bool
}

#if DEBUG
  extension Store {
    static var mock: Store {
      Store(
        id: 1, name: "Test Store", address: "123 Test St", phone: "(555) 123-4567",
        hours: "9AM-5PM", latitude: 37.7749, longitude: -122.4194, isOpen: true)
    }
  }

  extension Promotion {
    static var mock: Promotion {
      Promotion(id: 1, title: "Test Promotion", subtitle: "Test subtitle", isActive: true)
    }
  }
#endif
