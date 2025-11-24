import Combine
import Foundation
import OSLog
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

    // Check UserDefaults for onboarding completion EARLY to allow safe use of `self`
    self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding_v2")

    // Theme & preferences from UserDefaults
    if let raw = UserDefaults.standard.string(forKey: "app_theme"),
      let saved = AppTheme(rawValue: raw)
    {
      self.theme = saved
    } else {
      self.theme = .system
    }
    self.notificationsEnabled =
      UserDefaults.standard.object(forKey: "notifications_enabled") as? Bool ?? true
    self.marketingOptIn = UserDefaults.standard.object(forKey: "marketing_opt_in") as? Bool ?? false

    Log.app.debug(
      "Prefs loaded. theme=\(self.theme.rawValue, privacy: .public) notifications=\(self.notificationsEnabled, privacy: .public) marketing=\(self.marketingOptIn, privacy: .public)"
    )

    // Load saved user session if exists
    loadSavedUser()

    Log.app.debug(
      "AppState initialized. Items in cart: \(self.cartItems.count, privacy: .public), loyalty: \(self.loyaltyPoints, privacy: .public), selectedTab: \(String(describing: self.selectedTab), privacy: .public)"
    )

    Log.app.debug("Onboarding state: \(self.hasCompletedOnboarding, privacy: .public)")
  }

  // MARK: - Public Methods

  /// Adds a product to the cart or increments its quantity if it already exists.
  /// - Parameter product: The `Product` to be added to the cart.
  func addProductToCart(_ product: Product) {
    Log.cart.debug("Adding product to cart: \(product.id, privacy: .public)")
    if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
      cartItems[index].quantity += 1
    } else {
      let newItem = CartItem(product: product, quantity: 1)
      cartItems.append(newItem)
    }
    Log.cart.info("Cart updated. Items: \(self.cartItems.count, privacy: .public)")
  }

  /// Removes a product from the cart.
  /// - Parameter product: The `Product` to be removed from the cart.
  func removeProductFromCart(_ product: Product) {
    Log.cart.debug("Removing product from cart: \(product.id, privacy: .public)")
    cartItems.removeAll { $0.product.id == product.id }
    Log.cart.info("Cart updated. Items: \(self.cartItems.count, privacy: .public)")
  }

  /// Clears all items from the cart.
  func clearCart() {
    Log.cart.info("Clearing cart. Previous items: \(self.cartItems.count, privacy: .public)")
    cartItems.removeAll()
    Log.cart.info("Cart cleared. Items: \(self.cartItems.count, privacy: .public)")
  }

  /// Adds loyalty points earned from purchases.
  func addLoyaltyPoints(_ points: Int) {
    Log.app.info("Adding loyalty points: \(points, privacy: .public)")
    loyaltyPoints += points
    Log.app.info("Total loyalty points: \(self.loyaltyPoints, privacy: .public)")
  }

  func switchTab(_ tab: AppTab) {
    Log.app.info("Switching tab to: \(String(describing: tab), privacy: .public)")
    selectedTab = tab
  }

  func addScanRecord(_ record: ScanRecord) {
    Log.scan.info(
      "Adding scan record for: \(record.productName, privacy: .public) confidence: \(String(describing: record.confidence), privacy: .public) qty: \(record.quantity, privacy: .public)"
    )
    scanHistory.insert(record, at: 0)
    if scanHistory.count > 50 {
      scanHistory.removeLast(scanHistory.count - 50)
    }
    Log.scan.debug("Scan history count: \(self.scanHistory.count, privacy: .public)")

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
          Log.backend.info("Uploaded scan record to backend ✅")
        } catch {
          Log.backend.error(
            "Failed to upload scan record: \(String(describing: error), privacy: .public)")
          // Fail silently - local record is already saved
        }
      }
    }
  }

  /// Mark onboarding as completed
  func completeOnboarding() {
    Log.app.info("Onboarding completed")
    hasCompletedOnboarding = true
    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding_v2")
  }

  /// Log in a user and persist their session.
  func login(user: User) {
    Log.auth.info("User login: \(user.id, privacy: .public)")
    self.currentUser = user
    // Onboarding is implicitly complete if user logs in
    completeOnboarding()
    // Persist user session
    saveUser(user)
    Log.auth.debug("Current user set and persisted. Onboarding marked complete.")
  }

  /// Log out the user and clear their persisted session.
  func logout() {
    Log.auth.info("User logout")
    self.currentUser = nil
    clearSavedUser()
    Log.auth.debug("User session cleared")
  }
  
  // MARK: - Private Helpers
  
  /// Save user to UserDefaults for persistent login
  private func saveUser(_ user: User) {
    if let encoded = try? JSONEncoder().encode(user) {
      UserDefaults.standard.set(encoded, forKey: "saved_user")
      Log.auth.debug("User saved to UserDefaults")
    }
  }
  
  /// Load saved user from UserDefaults
  private func loadSavedUser() {
    guard let data = UserDefaults.standard.data(forKey: "saved_user"),
          let user = try? JSONDecoder().decode(User.self, from: data) else {
      Log.auth.debug("No saved user found")
      return
    }
    self.currentUser = user
    Log.auth.info("Restored user session: \(user.id, privacy: .public)")
  }
  
  /// Clear saved user from UserDefaults
  private func clearSavedUser() {
    UserDefaults.standard.removeObject(forKey: "saved_user")
    Log.auth.debug("Saved user cleared from UserDefaults")
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
