import SwiftUI

struct HealthPermissionView: View {
    @EnvironmentObject var session: AppSession
    @State private var showFirstFootwearPrompt = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                SoftUtilityHero(
                    title: "Connect Apple Health",
                    subtitle: "Use steps, distance, and walking or hiking activity to help track real-life footwear wear more automatically.",
                    eyebrow: "Optional but useful"
                )

                VStack(alignment: .leading, spacing: 14) {
                    Text("What gets used")
                        .font(.title3)
                        .bold()
                    SoftUtilityBulletRow(text: "steps")
                    SoftUtilityBulletRow(text: "walking and running distance")
                    SoftUtilityBulletRow(text: "relevant activity like walking or hiking")
                }
                .elevatedPanelStyle()

                VStack(spacing: 12) {
                    Button("Connect Apple Health") {
                        Task {
                            do {
                                try await HealthKitService.shared.requestAuthorization()
                                await session.markHealthConnected()
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
        .softUtilityBackground()
        .navigationTitle("Apple Health")
        .navigationDestination(isPresented: $showFirstFootwearPrompt) {
            FirstFootwearPromptView()
                .environmentObject(session)
        }
    }
}
