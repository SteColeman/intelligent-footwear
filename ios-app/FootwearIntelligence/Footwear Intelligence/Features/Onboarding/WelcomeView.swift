import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer(minLength: 20)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Track the footwear you actually live in")
                            .font(.largeTitle)
                            .bold()

                        Text("Built for walking, hiking, commuting, and everyday wear — not just workouts.")
                            .foregroundColor(.secondary)
                    }

                    softPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What this app helps with")
                                .font(.headline)
                            Text("• keep track of what gets worn most")
                            Text("• log how each pair is holding up")
                            Text("• spot what may need attention next")
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink {
                        HealthPermissionView()
                    } label: {
                        Text("Get started")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Welcome")
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
