import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var appState: AppState
  @Environment(\.dismiss) private var dismiss

  @State private var isDarkMode = false
  @State private var isNotificationsEnabled = true
  @State private var selectedCurrency = "USD"
  @State private var showingLogoutAlert = false

  private let currencies = ["USD", "EUR", "GBP", "JPY", "CAD"]

  var body: some View {
    NavigationView {
      Form {
        // Account Section
        Section(header: Text("Account")) {
          if let user = appState.currentUser {
            HStack {
              Text("Signed in as")
              Spacer()
              Text(user.name)
                .foregroundColor(.secondary)
            }

            Button(role: .destructive) {
              showingLogoutAlert = true
            } label: {
              HStack {
                Spacer()
                Text("Sign Out")
                Spacer()
              }
            }
          } else {
            NavigationLink(destination: LoginView(environment: .mock)) {
              Text("Sign In")
            }
          }
        }

        // Preferences Section
        Section(header: Text("Preferences")) {
          Toggle(isOn: $isDarkMode) {
            Label("Dark Mode", systemImage: "moon.fill")
          }

          Toggle(isOn: $isNotificationsEnabled) {
            Label("Enable Notifications", systemImage: "bell.fill")
          }

          Picker("Currency", selection: $selectedCurrency) {
            ForEach(currencies, id: \.self) { currency in
              Text(currency).tag(currency)
            }
          }
          .pickerStyle(.navigationLink)
        }

        // Support Section
        Section(header: Text("Support")) {
          Button(action: {
            // Handle help action
          }) {
            Label("Help Center", systemImage: "questionmark.circle")
          }

          Button(action: {
            // Handle contact support action
          }) {
            Label("Contact Support", systemImage: "envelope")
          }

          Button(action: {
            // Handle about action
          }) {
            Label("About", systemImage: "info.circle")
          }
        }

        // App Version
        Section {
          HStack {
            Text("Version")
            Spacer()
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
              .foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("Settings")
      .toolbar {
          #if os(iOS)
          ToolbarItem(placement: .navigationBarTrailing) {
          #else
          ToolbarItem(placement: .automatic) {
          #endif
          Button("Done") {
            dismiss()
          }
        }
      }
      .alert("Sign Out", isPresented: $showingLogoutAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Sign Out", role: .destructive) {
          appState.currentUser = nil
          dismiss()
        }
      } message: {
        Text("Are you sure you want to sign out?")
      }
    }
  }
}

// MARK: - Preview
#if DEBUG
  struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
      SettingsView()
        .environmentObject(AppState(currentUser: .mock))
    }
  }
#endif
