import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Insights")
                    .font(.title)
                    .bold()

                if let userId = session.userId {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let summary = viewModel.summary {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Most worn: \(summary.mostWorn.count)")
                            if let top = summary.mostWorn.first {
                                Text("Top pair: \(top.displayName)")
                                    .foregroundColor(.secondary)
                            }

                            Text("Needs attention: \(summary.needsAttention.count)")
                            if let attention = summary.needsAttention.first {
                                Text("Watch: \(attention.displayName)")
                                    .foregroundColor(.secondary)
                            }

                            Text("Near retirement: \(summary.nearRetirement.count)")
                                .foregroundColor(.secondary)
                        }
                    } else if let error = viewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    } else {
                        Text("Wear trends and lifecycle signals will appear here once your footwear and assignments build up.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Bootstrapping user session…")
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Insights")
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }
}
