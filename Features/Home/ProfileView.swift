import SwiftUI

struct ProfileView: View {
  @EnvironmentObject private var appState: AppState
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List {
      Section(header: Text("Account")) {
        HStack(spacing: 12) {
          Circle()
            .fill(BrandColor.primary.opacity(0.2))
            .frame(width: 44, height: 44)
            .overlay(
              Text(initials(from: appState.currentUser?.name))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(BrandColor.primary)
            )
          VStack(alignment: .leading, spacing: 4) {
            Text(appState.currentUser?.name ?? "Guest")
              .font(.headline)
            Text(appState.currentUser?.email ?? "Not signed in")
              .font(.subheadline)
              .foregroundColor(BrandColor.textSecondary)
          }
        }
      }

      Section(header: Text("Loyalty")) {
        HStack {
          Text("Points")
          Spacer()
          Text("\(appState.loyaltyPoints)")
            .foregroundColor(BrandColor.primary)
            .font(.system(.headline, design: .rounded))
        }
      }

      Section(header: Text("Appearance")) {
        Picker("Theme", selection: $appState.theme) {
          ForEach(AppTheme.allCases) { theme in
            Label(theme.rawValue, systemImage: theme.iconName)
              .tag(theme)
          }
        }
        .pickerStyle(.navigationLink)
      }

      Section(header: Text("Preferences")) {
        Toggle(isOn: $appState.notificationsEnabled) {
          Label("Enable Notifications", systemImage: "bell.badge.fill")
        }
        Toggle(isOn: $appState.marketingOptIn) {
          Label("Marketing Updates", systemImage: "megaphone.fill")
        }
      }

      Section(header: Text("About")) {
        HStack {
          Text("App Version")
          Spacer()
          Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
            .foregroundColor(BrandColor.textSecondary)
        }
        HStack {
          Text("Build")
          Spacer()
          Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-")
            .foregroundColor(BrandColor.textSecondary)
        }
        Link(destination: URL(string: "https://example.com/privacy")!) {
          Label("Privacy Policy", systemImage: "hand.raised.fill")
        }
        Link(destination: URL(string: "https://example.com/terms")!) {
          Label("Terms of Service", systemImage: "doc.plaintext")
        }
      }

      Section {
        if appState.currentUser != nil {
          Button(role: .destructive) {
            appState.logout()
            dismiss()
          } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
          }
        } else {
          Text("You are not signed in.")
            .foregroundColor(BrandColor.textSecondary)
        }
      }
    }
    .navigationTitle("Profile")
  }

  private func initials(from name: String?) -> String {
    guard let name = name, !name.isEmpty else { return "U" }
    let parts = name.split(separator: " ")
    let first = parts.first?.prefix(1) ?? "U"
    let last = parts.dropFirst().first?.prefix(1)
    return String(first + (last ?? ""))
  }
}

#if DEBUG
  #Preview {
    NavigationStack {
      ProfileView()
        .environmentObject(AppState.mock)
    }
  }
#endif
