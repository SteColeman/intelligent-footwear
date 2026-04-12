import SwiftUI

struct FirstFootwearPromptView: View {
    @EnvironmentObject var session: AppSession
    @State private var showingCreate = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add your first footwear")
                        .font(.largeTitle)
                        .bold()

                    Text("Start with the pair you wear most so the app can begin building a useful history.")
                        .foregroundColor(.secondary)
                }

                softPanel {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("A good first pick")
                            .font(.headline)
                        Text("• your main daily pair")
                        Text("• your usual walking footwear")
                        Text("• the pair you trust most right now")
                            .foregroundColor(.secondary)
                    }
                }

                Button("Add footwear") {
                    showingCreate = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("First Footwear")
        .sheet(isPresented: $showingCreate) {
            CreateFootwearView()
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
