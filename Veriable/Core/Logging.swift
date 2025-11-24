import Foundation
import OSLog

/// Centralized loggers for the app using Apple's unified logging system.
///
/// Use these loggers instead of `print` for structured, filterable logs
/// visible in Xcode's console and the Console app.
enum Log {
  private static let subsystem: String = Bundle.main.bundleIdentifier ?? "App"

  /// General app lifecycle and UI events
  static let app = Logger(subsystem: subsystem, category: "app")

  /// Authentication and user session-related events
  static let auth = Logger(subsystem: subsystem, category: "auth")

  /// Backend/network requests and responses
  static let backend = Logger(subsystem: subsystem, category: "backend")

  /// Scanning-related events and pipeline
  static let scan = Logger(subsystem: subsystem, category: "scan")

  /// Cart and checkout-related events
  static let cart = Logger(subsystem: subsystem, category: "cart")
}
