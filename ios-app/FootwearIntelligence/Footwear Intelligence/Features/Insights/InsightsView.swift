import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let userId = session.userId {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else if let summary = viewModel.summary {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Insights")
                                    .font(.largeTitle)
                                    .bold()
                                Text("A softer read on what’s getting worn most and what may need attention soon.")
                                    .foregroundColor(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Most worn")
                                    .font(.headline)
                                Text("\(summary.mostWorn.count) footwear item\(summary.mostWorn.count == 1 ? "" : "s") currently show the strongest wear history.")
                                if let top = summary.mostWorn.first {
                                    Text("Top pair: \(top.displayName)")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .softPanelStyle()

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Needs attention")
                                    .font(.headline)
                                Text("\(summary.needsAttention.count) footwear item\(summary.needsAttention.count == 1 ? "" : "s") may be worth a closer look.")
                                if let attention = summary.needsAttention.first {
                                    Text("Watch: \(attention.displayName)")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .softPanelStyle()

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Near retirement")
                                    .font(.headline)
                                if summary.nearRetirement.isEmpty {
                                    Text("Nothing looks close to retirement right now.")
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("\(summary.nearRetirement.count) footwear item\(summary.nearRetirement.count == 1 ? "" : "s") may be approaching end of life.")
                                    ForEach(summary.nearRetirement) { item in
                                        Text(item.displayName)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .softPanelStyle()
                        } else if let error = viewModel.errorMessage {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Insights couldn’t load")
                                    .font(.headline)
                                Text(error)
                                    .foregroundColor(.red)
                            }
                            .softPanelStyle()
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Insights")
                                    .font(.largeTitle)
                                    .bold()
                                Text("Wear trends and lifecycle signals will appear here once your footwear and assignments build up.")
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Text("Bootstrapping user session…")
                            .foregroundColor(.secondary)
                            .padding(.top, 30)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Insights")
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }
}
