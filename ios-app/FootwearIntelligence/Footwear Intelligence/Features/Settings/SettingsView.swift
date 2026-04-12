import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: AppSession
    @State private var healthConnectError: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    SoftUtilityHero(
                        title: "Settings",
                        subtitle: "Quiet status, connection, and build details for the current app state.",
                        eyebrow: "Connected prototype",
                        titleSize: 32
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Apple Health")
                            .font(.title3)
                            .bold()

                        Text(session.healthConnectionStatus)
                            .foregroundColor(.secondary)

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
                    .elevatedPanelStyle()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Session")
                            .font(.headline)
                        Text("Auth provider: \(session.authProviderId)")
                        Text("User ID: \(session.userId ?? "Not resolved")")
                            .foregroundColor(.secondary)
                    }
                    .softPanelStyle()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Build")
                            .font(.headline)
                        Text("Current mode: connected app build")
                        Text("Backend URL: \(AppConfig.backendBaseURL.absoluteString)")
                            .foregroundColor(.secondary)
                    }
                    .softPanelStyle()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preferences")
                            .font(.headline)
                        Text("Default footwear and reminder settings will appear here as the settings layer fills out.")
                            .foregroundColor(.secondary)
                    }
                    .softPanelStyle()
                }
                .padding()
            }
            .softUtilityBackground()
            .navigationTitle("Settings")
        }
    }
}
