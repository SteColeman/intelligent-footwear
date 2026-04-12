import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer(minLength: 20)

                    SoftUtilityHero(
                        title: "Track the footwear you actually live in",
                        subtitle: "Built for walking, hiking, commuting, and everyday wear — not just workouts.",
                        eyebrow: "Walking first"
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        Text("What this app helps with")
                            .font(.title3)
                            .bold()

                        SoftUtilityBulletRow(text: "keep track of what gets worn most")
                        SoftUtilityBulletRow(text: "log how each pair is holding up")
                        SoftUtilityBulletRow(text: "spot what may need attention next")
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
            .softUtilityBackground()
            .navigationTitle("Welcome")
        }
    }
}
