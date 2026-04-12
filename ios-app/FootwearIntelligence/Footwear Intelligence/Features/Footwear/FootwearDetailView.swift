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
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
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
        } else if let item = viewModel.item, let lifecycle = item.lifecycleSummary {
            VStack(alignment: .leading, spacing: 24) {
                premiumHero(for: item, lifecycle: lifecycle)

                HStack(spacing: 14) {
                    statCard(label: "Steps tracked", value: "\(lifecycle.totalSteps)")
                    statCard(label: "Distance", value: String(format: "%.1f km", lifecycle.totalDistanceKm))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Condition history")
                        .font(.headline)

                    if !viewModel.hasConditionHistory {
                        Text("Condition check-ins will appear here once you start logging them.")
                            .foregroundColor(.secondary)
                            .softPanelStyle()
                    } else {
                        ForEach(viewModel.conditionLogs) { log in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(log.loggedAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Confidence in continued use")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Text("\(log.overallConfidenceScore)/5")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color.blue.opacity(0.12))
                                        .foregroundColor(.blue)
                                        .clipShape(Capsule())
                                }

                                HStack(spacing: 12) {
                                    metricPill(label: "Comfort", value: "\(log.comfortScore)")
                                    metricPill(label: "Support", value: "\(log.supportScore)")
                                    metricPill(label: "Grip", value: "\(log.gripScore)")
                                }

                                if let notes = log.notes, !notes.isEmpty {
                                    Text(notes)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .elevatedPanelStyle()
                        }
                    }
                }
            }
            .padding()
        } else if let item = viewModel.item {
            VStack(alignment: .leading, spacing: 22) {
                premiumHeroWithoutLifecycle(for: item)

                Text("No lifecycle data has been built for this footwear yet.")
                    .foregroundColor(.secondary)
                    .softPanelStyle()
            }
            .padding()
        } else {
            Text("No footwear detail available.")
                .foregroundColor(.secondary)
                .padding(.top, 30)
        }
    }

    private func premiumHero(for item: FootwearItem, lifecycle: LifecycleSummaryLite) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.displayName)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                        .foregroundColor(Color.white.opacity(0.72))
                }

                Spacer()

                if item.isDefaultFallback {
                    Text("Default")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.16))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(SoftUtilityRiskTone.longLabel(for: lifecycle.retirementRiskLevel))
                    .font(.headline)
                    .foregroundColor(.white)

                if let confidenceScore = lifecycle.confidenceScore {
                    Text(String(format: "Confidence in this estimate: %.2f", confidenceScore))
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.72))
                }
            }

            HStack(spacing: 10) {
                chip(label: item.status.capitalized)
                chip(label: SoftUtilityRiskTone.shortLabel(for: lifecycle.retirementRiskLevel))
            }
        }
        .premiumHeroStyle()
    }

    private func premiumHeroWithoutLifecycle(for item: FootwearItem) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.displayName)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                        .foregroundColor(Color.white.opacity(0.72))
                }

                Spacer()

                if item.isDefaultFallback {
                    Text("Default")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.16))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }

            Text("This pair has been added, but its wear history hasn’t built up yet.")
                .foregroundColor(Color.white.opacity(0.78))
        }
        .premiumHeroStyle()
    }

    private func statCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
        }
        .metricTileStyle()
    }

    private func metricPill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func chip(label: String) -> some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.12))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
