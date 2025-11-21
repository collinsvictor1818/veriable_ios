import Combine
import Foundation
import SwiftUI

enum AppTab: Hashable {
  case scanner
  case discover
  case cart
  case checkout
  case settings
}

/// A class that holds the global state of the application.
///
/// This class is an `ObservableObject` so that SwiftUI views can subscribe to its changes.
/// It should be provided as a singleton throughout the app, likely as an environment object.
@MainActor
final class AppState: ObservableObject {

  // MARK: - Published Properties

  /// The current user of the app. Published to trigger UI updates on change.
  @Published var currentUser: User? = nil

  /// The items currently in the user's shopping cart.
  @Published var cartItems: [CartItem] = []

  /// Current loyalty points for the signed-in user.
  @Published var loyaltyPoints: Int = 0

  /// Currently selected tab in the main interface.
  @Published var selectedTab: AppTab = .discover

  /// Recently scanned detections for history.
  @Published var scanHistory: [ScanRecord] = []

  /// Tracks if user has completed onboarding
  @Published var hasCompletedOnboarding: Bool

  /// User-selected app theme (light/dark/system), persisted in UserDefaults
  @Published var theme: AppTheme {
    didSet { UserDefaults.standard.set(theme.rawValue, forKey: "app_theme") }
  }

  /// Whether push/local notifications are enabled (app-level preference)
  @Published var notificationsEnabled: Bool {
    didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled") }
  }

  /// Whether user opts in to marketing emails/notifications
  @Published var marketingOptIn: Bool {
    didSet { UserDefaults.standard.set(marketingOptIn, forKey: "marketing_opt_in") }
  }

  // MARK: - Initialization

  init(
    currentUser: User? = nil,
    cartItems: [CartItem] = [],
    loyaltyPoints: Int = 0,
    selectedTab: AppTab = .discover,
    scanHistory: [ScanRecord] = []
  ) {
    self.currentUser = currentUser
    self.cartItems = cartItems
    self.loyaltyPoints = loyaltyPoints
    self.selectedTab = selectedTab
    self.scanHistory = scanHistory

    // Theme & preferences from UserDefaults
    if let raw = UserDefaults.standard.string(forKey: "app_theme"), let saved = AppTheme(rawValue: raw) {
      self.theme = saved
    } else {
      self.theme = .system
    }
    self.notificationsEnabled = UserDefaults.standard.object(forKey: "notifications_enabled") as? Bool ?? true
    self.marketingOptIn = UserDefaults.standard.object(forKey: "marketing_opt_in") as? Bool ?? false

    // Check UserDefaults for onboarding completion
    self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding_v2")
  }

  // MARK: - Public Methods

  /// Adds a product to the cart or increments its quantity if it already exists.
  /// - Parameter product: The `Product` to be added to the cart.
  func addProductToCart(_ product: Product) {
    if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
      cartItems[index].quantity += 1
    } else {
      let newItem = CartItem(product: product, quantity: 1)
      cartItems.append(newItem)
    }
  }

  /// Removes a product from the cart.
  /// - Parameter product: The `Product` to be removed from the cart.
  func removeProductFromCart(_ product: Product) {
    cartItems.removeAll { $0.product.id == product.id }
  }

  /// Clears all items from the cart.
  func clearCart() {
    cartItems.removeAll()
  }

  /// Adds loyalty points earned from purchases.
  func addLoyaltyPoints(_ points: Int) {
    loyaltyPoints += points
  }

  func switchTab(_ tab: AppTab) {
    selectedTab = tab
  }

  func addScanRecord(_ record: ScanRecord) {
    scanHistory.insert(record, at: 0)
    if scanHistory.count > 50 {
      scanHistory.removeLast(scanHistory.count - 50)
    }

    // Upload to backend if user is logged in
    if let userId = currentUser?.id {
      Task {
        do {
          // Create API client
          let apiClient = APIClient()
          let _: ScanRecordResponse = try await apiClient.request(
            ScanRecordAPI.uploadScanRecord(
              userId: userId,
              productName: record.productName,
              confidence: record.confidence,
              quantity: record.quantity
            )
          )
          print("✓ Uploaded scan record to backend")
        } catch {
          print("✗ Failed to upload scan record: \(error)")
          // Fail silently - local record is already saved
        }
      }
    }
  }

  /// Mark onboarding as completed
  func completeOnboarding() {
    hasCompletedOnboarding = true
    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding_v2")
  }

  /// Log in a user.
  func login(user: User) {
    self.currentUser = user
    // Onboarding is implicitly complete if user logs in
    completeOnboarding()
    // Ideally persist user ID here
  }

  func logout() {
    self.currentUser = nil
    // Clear persistence
  }
}

// MARK: - Mock Data

#if DEBUG
  extension AppState {
    static var mock: AppState {
      AppState(
        currentUser: User.mock,
        cartItems: CartItem.mockItems,
        loyaltyPoints: 2450,
        selectedTab: .discover,
        scanHistory: ScanRecord.mockHistory)
    }
  }
#endif

