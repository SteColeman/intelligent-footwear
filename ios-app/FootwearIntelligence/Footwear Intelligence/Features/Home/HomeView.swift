import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today")
                    .font(.largeTitle)
                    .bold()

                if let userId = session.userId {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let summary = viewModel.summary {
                        Text("Steps today: \(summary.today.steps)")
                        Text(String(format: "Distance today: %.1f km", summary.today.distanceKm))
                        Text("Active footwear: \(summary.activeFootwear.count)")
                        if let currentDefault = summary.currentDefault {
                            Text("Default footwear: \(currentDefault.displayName)")
                        }
                        Text("Unassigned wear: \(summary.unassignedWear.count)")
                            .foregroundColor(.secondary)
                    } else if let error = viewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    } else {
                        Text("Your daily wear summary will appear here once you import activity and start assigning it to footwear.")
                            .foregroundColor(.secondary)
                    }

                    Button("Refresh") {
                        Task {
                            await viewModel.load(userId: userId)
                        }
                    }
                } else {
                    Text("Bootstrapping user session…")
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }
}
