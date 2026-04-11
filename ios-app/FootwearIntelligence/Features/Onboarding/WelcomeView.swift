import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Spacer()

                Text("Track real-life footwear wear")
                    .font(.largeTitle)
                    .bold()

                Text("Built for walking, hiking, and everyday wear — not just workouts.")
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Text("• Track wear from everyday movement")
                    Text("• Log condition over time")
                    Text("• See when footwear may be nearing end of life")
                }

                Spacer()

                NavigationLink {
                    HealthPermissionView()
                } label: {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }
}
