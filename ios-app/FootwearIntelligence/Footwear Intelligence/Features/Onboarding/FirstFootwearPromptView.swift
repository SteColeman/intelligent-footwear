import SwiftUI

struct FirstFootwearPromptView: View {
    @EnvironmentObject var session: AppSession
    @State private var showingCreate = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                SoftUtilityHero(
                    title: "Add your first footwear",
                    subtitle: "Start with the pair you wear most so the app can begin building a useful history.",
                    eyebrow: "Start with reality"
                )

                VStack(alignment: .leading, spacing: 14) {
                    Text("A good first pick")
                        .font(.title3)
                        .bold()
                    SoftUtilityBulletRow(text: "your main daily pair")
                    SoftUtilityBulletRow(text: "your usual walking footwear")
                    SoftUtilityBulletRow(text: "the pair you trust most right now")
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
        .softUtilityBackground()
        .navigationTitle("First Footwear")
        .sheet(isPresented: $showingCreate) {
            CreateFootwearView()
                .environmentObject(session)
        }
    }
}
