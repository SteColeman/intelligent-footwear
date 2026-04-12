import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer(minLength: 20)

                    welcomeHero

                    VStack(alignment: .leading, spacing: 14) {
                        Text("What this app helps with")
                            .font(.title3)
                            .bold()

                        onboardingBullet(text: "keep track of what gets worn most")
                        onboardingBullet(text: "log how each pair is holding up")
                        onboardingBullet(text: "spot what may need attention next")
                    }
                    .elevatedPanelStyle()

                    NavigationLink {
                        HealthPermissionView()
                    } label: {
                        Text("Get started")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
            .navigationTitle("Welcome")
        }
    }

    private var welcomeHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Track the footwear you actually live in")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Built for walking, hiking, commuting, and everyday wear — not just workouts.")
                .foregroundColor(Color.white.opacity(0.76))

            Text("Walking first")
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
