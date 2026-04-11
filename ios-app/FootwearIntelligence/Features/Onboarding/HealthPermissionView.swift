import SwiftUI

struct HealthPermissionView: View {
    @EnvironmentObject var session: AppSession
    @State private var showFirstFootwearPrompt = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text("Connect Apple Health")
                .font(.largeTitle)
                .bold()

            Text("Use steps, distance, and walking or hiking activity to help track footwear wear automatically.")
                .foregroundColor(.secondary)

            Button("Connect Apple Health") {
                Task {
                    do {
                        try await HealthKitService.shared.requestAuthorization()
                        session.markHealthConnected()
                    } catch {
                        // Keep onboarding moving even if permission is declined or unavailable.
                    }
                    showFirstFootwearPrompt = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Skip for now") {
                showFirstFootwearPrompt = true
            }
            .frame(maxWidth: .infinity)
            .padding()

            Spacer()
        }
        .padding()
        .navigationTitle("Apple Health")
        .navigationDestination(isPresented: $showFirstFootwearPrompt) {
            FirstFootwearPromptView()
                .environmentObject(session)
        }
    }
}
