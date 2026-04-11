import SwiftUI

struct FirstFootwearPromptView: View {
    @EnvironmentObject var session: AppSession
    @State private var showingCreate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add your first footwear")
                .font(.title)
                .bold()

            Text("Start with the pair you wear most so the app can begin tracking real-life wear.")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Text("Good first pick:")
                    .font(.headline)
                Text("• your main daily pair")
                Text("• your usual walking footwear")
                Text("• the pair you trust most right now")
                    .foregroundColor(.secondary)
            }

            Button("Add footwear") {
                showingCreate = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .navigationTitle("First Footwear")
        .sheet(isPresented: $showingCreate) {
            CreateFootwearView()
                .environmentObject(session)
        }
    }
}
