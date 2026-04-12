import SwiftUI

struct FootwearDetailView: View {
    @EnvironmentObject var session: AppSession
    let footwearItemId: String

    @StateObject private var viewModel = FootwearDetailViewModel()
    @State private var showingConditionCheckIn = false

    var body: some View {
        ScrollView {
            if let userId = session.userId {
                content(userId: userId)
            } else {
                Text("Bootstrapping user session…")
                    .foregroundColor(.secondary)
                    .padding(.top, 30)
            }
        }
        .navigationTitle(viewModel.item?.displayName ?? "Footwear")
        .background(Color(.systemGroupedBackground))
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
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
        } else if let error = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 12) {
                Text("Footwear detail couldn’t load")
                    .font(.title3)
                    .bold()
                Text(error)
                    .foregroundColor(.red)

                Button("Retry") {
                    Task {
                        await viewModel.load(footwearItemId: footwearItemId, userId: userId)
                    }
                }
            }
            .padding()
        } else if let item = viewModel.item {
            VStack(alignment: .leading, spacing: 18) {
                softPanel {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.displayName)
                            .font(.title2)
                            .bold()
                        Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                            .foregroundColor(.secondary)
                        Text(item.status.capitalized)
                            .foregroundColor(.secondary)

                        if item.isDefaultFallback {
                            Text("This is your current default fallback footwear.")
                                .foregroundColor(.green)
                        }
                    }
                }

                if let lifecycle = item.lifecycleSummary {
                    softPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lifecycle")
                                .font(.headline)

                            HStack(spacing: 24) {
                                statBlock(label: "Steps", value: "\(lifecycle.totalSteps)")
                                statBlock(label: "Distance", value: String(format: "%.1f km", lifecycle.totalDistanceKm))
                            }

                            Text(riskLabel(for: lifecycle.retirementRiskLevel))
                                .foregroundColor(riskColor(for: lifecycle.retirementRiskLevel))

                            if let confidenceScore = lifecycle.confidenceScore {
                                Text(String(format: "Confidence in this estimate: %.2f", confidenceScore))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Condition history")
                        .font(.headline)

                    if !viewModel.hasConditionHistory {
                        softPanel {
                            Text("Condition check-ins will appear here once you start logging them.")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        ForEach(viewModel.conditionLogs) { log in
                            softPanel {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(log.loggedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Confidence: \(log.overallConfidenceScore)/5")
                                    Text("Comfort: \(log.comfortScore)/5")
                                        .foregroundColor(.secondary)
                                    if let notes = log.notes, !notes.isEmpty {
                                        Text(notes)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        } else {
            Text("No footwear detail available.")
                .foregroundColor(.secondary)
                .padding(.top, 30)
        }
    }

    private func statBlock(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .bold()
        }
    }

    private func softPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func riskLabel(for level: String) -> String {
        switch level.lowercased() {
        case "high": return "This footwear may need replacing soon."
        case "medium": return "This footwear is worth keeping an eye on."
        default: return "This footwear looks to be holding up well."
        }
    }

    private func riskColor(for level: String) -> Color {
        switch level.lowercased() {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }
}
