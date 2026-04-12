import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: AppSession
    @State private var healthConnectError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Settings")
                            .font(.largeTitle)
                            .bold()
                        Text("Quiet status, connection, and build details for the current app state.")
                            .foregroundColor(.secondary)
                    }

                    softPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Apple Health")
                                .font(.headline)
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
                    }

                    softPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Session")
                                .font(.headline)
                            Text("Auth provider: \(session.authProviderId)")
                            Text("User ID: \(session.userId ?? "Not resolved")")
                                .foregroundColor(.secondary)
                        }
                    }

                    softPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Build")
                                .font(.headline)
                            Text("Current mode: connected app build")
                            Text("Backend URL: \(AppConfig.backendBaseURL.absoluteString)")
                                .foregroundColor(.secondary)
                        }
                    }

                    softPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preferences")
                                .font(.headline)
                            Text("Default footwear and reminder settings will appear here as the settings layer fills out.")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
        }
    }

    private func softPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
