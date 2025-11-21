import Foundation
import SwiftUI

/// Represents the available app theme options
enum AppTheme: String, CaseIterable, Identifiable {
  case light = "Light"
  case dark = "Dark"
  case system = "System"

  var id: String { rawValue }

  /// Converts AppTheme to SwiftUI ColorScheme
  var colorScheme: ColorScheme? {
    switch self {
    case .light:
      return .light
    case .dark:
      return .dark
    case .system:
      return nil  // Let system decide
    }
  }

  /// Returns the system icon name for the theme
  var iconName: String {
    switch self {
    case .light:
      return "sun.max.fill"
    case .dark:
      return "moon.fill"
    case .system:
      return "circle.lefthalf.filled"
    }
  }
}
