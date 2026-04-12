import SwiftUI

struct HealthPermissionView: View {
    @EnvironmentObject var session: AppSession
    @State private var showFirstFootwearPrompt = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                healthHero

                VStack(alignment: .leading, spacing: 14) {
                    Text("What gets used")
                        .font(.title3)
                        .bold()
                    onboardingBullet(text: "steps")
                    onboardingBullet(text: "walking and running distance")
                    onboardingBullet(text: "relevant activity like walking or hiking")
                }
                .elevatedPanelStyle()

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
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Button("Skip for now") {
                        showFirstFootwearPrompt = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
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
        .navigationTitle("Apple Health")
        .navigationDestination(isPresented: $showFirstFootwearPrompt) {
            FirstFootwearPromptView()
                .environmentObject(session)
        }
    }

    private var healthHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connect Apple Health")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Use steps, distance, and walking or hiking activity to help track real-life footwear wear more automatically.")
                .foregroundColor(Color.white.opacity(0.76))

            Text("Optional but useful")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.12))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .premiumHeroStyle()
    }

    private func onboardingBullet(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}
