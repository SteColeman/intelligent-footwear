import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: AppSession
    @State private var healthConnectError: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Apple Health") {
                    Text(session.healthConnectionStatus)

                    Button("Connect Apple Health") {
                        Task {
                            do {
                                try await HealthKitService.shared.requestAuthorization()
                                session.markHealthConnected()
                                healthConnectError = nil
                            } catch {
                                healthConnectError = error.localizedDescription
                            }
                        }
                    }

                    if let healthConnectError {
                        Text(healthConnectError)
                            .foregroundColor(.red)
                    }
                }

                Section("Session") {
                    Text("Auth provider: \(session.authProviderId)")
                    Text("User ID: \(session.userId ?? "Not resolved")")
                        .foregroundColor(.secondary)
                }

                Section("Build") {
                    Text("Current mode: connected app build")
                    Text("Backend URL: \(AppConfig.backendBaseURL.absoluteString)")
                        .foregroundColor(.secondary)
                }

                Section("Preferences") {
                    Text("Default footwear and reminder settings will appear here as the settings layer fills out.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
