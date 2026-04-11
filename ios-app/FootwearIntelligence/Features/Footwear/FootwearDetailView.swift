import SwiftUI

struct FootwearDetailView: View {
    @EnvironmentObject var session: AppSession
    let footwearItemId: String

    @StateObject private var viewModel = FootwearDetailViewModel()
    @State private var showingConditionCheckIn = false

    var body: some View {
        Group {
            if let userId = session.userId {
                content(userId: userId)
            } else {
                Text("Bootstrapping user session…")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(viewModel.item?.displayName ?? "Footwear")
        .toolbar {
            if session.userId != nil {
                Button("Log condition") {
                    showingConditionCheckIn = true
                }
            }
        }
        .sheet(isPresented: $showingConditionCheckIn, onDismiss: {
            Task {
                if let userId = session.userId {
                    await viewModel.load(footwearItemId: footwearItemId, userId: userId)
                }
            }
        }) {
            ConditionCheckInView(footwearItemId: footwearItemId)
                .environmentObject(session)
        }
        .task(id: session.userId) {
            if let userId = session.userId {
                await viewModel.load(footwearItemId: footwearItemId, userId: userId)
            }
        }
    }

    @ViewBuilder
    private func content(userId: String) -> some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let error = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 12) {
                Text("Error: \(error)")
                    .foregroundColor(.red)

                Button("Retry") {
                    Task {
                        await viewModel.load(footwearItemId: footwearItemId, userId: userId)
                    }
                }
            }
            .padding()
        } else if let item = viewModel.item {
            List {
                Section("Overview") {
                    Text(item.displayName)
                        .font(.headline)
                    Text(item.category)
                        .foregroundColor(.secondary)
                    Text("Status: \(item.status)")
                        .foregroundColor(.secondary)
                    if item.isDefaultFallback {
                        Text("Default fallback footwear")
                            .foregroundColor(.secondary)
                    }
                }

                if let lifecycle = item.lifecycleSummary {
                    Section("Lifecycle") {
                        Text("Steps: \(lifecycle.totalSteps)")
                        Text(String(format: "Distance: %.1f km", lifecycle.totalDistanceKm))
                        Text("Risk: \(lifecycle.retirementRiskLevel)")
                        if let confidenceScore = lifecycle.confidenceScore {
                            Text(String(format: "Confidence: %.2f", confidenceScore))
                        }
                    }
                }

                Section("Condition history") {
                    if !viewModel.hasConditionHistory {
                        Text("Condition check-ins will appear here once you start logging them.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.conditionLogs) { log in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(log.loggedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                Text("Confidence: \(log.overallConfidenceScore)/5")
                                Text("Comfort: \(log.comfortScore)/5")
                                    .foregroundColor(.secondary)
                                if let notes = log.notes, !notes.isEmpty {
                                    Text(notes)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        } else {
            Text("No footwear detail available.")
                .foregroundColor(.secondary)
        }
    }
}
