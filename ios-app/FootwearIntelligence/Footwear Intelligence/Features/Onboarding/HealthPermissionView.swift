import SwiftUI

struct HealthPermissionView: View {
    @EnvironmentObject var session: AppSession
    @State private var showFirstFootwearPrompt = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Connect Apple Health")
                        .font(.largeTitle)
                        .bold()

                    Text("Use steps, distance, and walking or hiking activity to help track real-life footwear wear more automatically.")
                        .foregroundColor(.secondary)
                }

                softPanel {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What gets used")
                            .font(.headline)
                        Text("• steps")
                        Text("• walking and running distance")
                        Text("• relevant activity like walking or hiking")
                            .foregroundColor(.secondary)
                    }
                }

                VStack(spacing: 12) {
                    Button("Connect Apple Health") {
                        Task {
                            do {
                                try await HealthKitService.shared.requestAuthorization()
                                session.markHealthConnected()
                            } catch {
                                // keep onboarding moving even if permission is declined or unavailable
                            }
                            showFirstFootwearPrompt = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button("Skip for now") {
                        showFirstFootwearPrompt = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Apple Health")
        .navigationDestination(isPresented: $showFirstFootwearPrompt) {
            FirstFootwearPromptView()
                .environmentObject(session)
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
