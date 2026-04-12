import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: AppSession
    @State private var healthConnectError: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    settingsHero

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
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Settings")
        }
    }

    private var settingsHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("Quiet status, connection, and build details for the current app state.")
                .foregroundColor(Color.white.opacity(0.76))
            Text("Connected prototype")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.12))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .premiumHeroStyle()
    }
}
