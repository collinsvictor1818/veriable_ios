import SwiftUI

enum BrandColor {
    static let primary = Color(red: 0/255, green: 156/255, blue: 32/255) // #009C20
    static let accent = Color(red: 252/255, green: 188/255, blue: 2/255)  // #FCBC02
    static let background = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let button = Color(red: 18/255, green: 18/255, blue: 18/255) // #121212
}

enum BrandSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum BrandCornerRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
}

struct BrandShadow {
    static let subtle = Shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

extension View {
    func brandCardBackground() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: BrandCornerRadius.medium,
                                  style: .continuous)
                    .fill(BrandColor.surface)
            )
            .shadow(color: BrandShadow.subtle.color,
                    radius: BrandShadow.subtle.radius,
                    x: BrandShadow.subtle.x,
                    y: BrandShadow.subtle.y)
    }
}
