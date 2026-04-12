import SwiftUI

struct FirstFootwearPromptView: View {
    @EnvironmentObject var session: AppSession
    @State private var showingCreate = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                firstFootwearHero

                VStack(alignment: .leading, spacing: 14) {
                    Text("A good first pick")
                        .font(.title3)
                        .bold()
                    onboardingBullet(text: "your main daily pair")
                    onboardingBullet(text: "your usual walking footwear")
                    onboardingBullet(text: "the pair you trust most right now")
                }
                .elevatedPanelStyle()

                Button("Add footwear") {
                    showingCreate = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        .navigationTitle("First Footwear")
        .sheet(isPresented: $showingCreate) {
            CreateFootwearView()
                .environmentObject(session)
        }
    }

    private var firstFootwearHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add your first footwear")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Start with the pair you wear most so the app can begin building a useful history.")
                .foregroundColor(Color.white.opacity(0.76))

            Text("Start with reality")
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
