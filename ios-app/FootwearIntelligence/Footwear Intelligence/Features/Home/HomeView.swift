import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let userId = session.userId {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else if let summary = viewModel.summary {
                            homeHero(summary: summary)

                            activityPanel(summary: summary)

                            if let currentDefault = summary.currentDefault {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Default footwear")
                                        .font(.headline)
                                    Text(currentDefault.displayName)
                                        .font(.title3)
                                    Text("Used as the fallback when you want wear to land somewhere predictable.")
                                        .foregroundColor(.secondary)
                                }
                                .elevatedPanelStyle()
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Needs review")
                                    .font(.headline)

                                if summary.unassignedWear.count > 0 {
                                    Text("\(summary.unassignedWear.count) wear event\(summary.unassignedWear.count == 1 ? "" : "s") still need assigning.")
                                    Text(String(format: "That currently represents %.1f km of unassigned movement.", summary.unassignedWear.distanceKm))
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Everything imported so far has been assigned.")
                                    Text("Your daily view is up to date.")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .softPanelStyle()

                            if !summary.activeFootwear.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("In rotation")
                                        .font(.headline)

                                    ForEach(summary.activeFootwear) { item in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(item.displayName)
                                                .font(.headline)
                                            Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                                .foregroundColor(.secondary)

                                            if let lifecycle = item.lifecycleSummary {
                                                Text("\(lifecycle.totalSteps) steps tracked")
                                                Text(SoftUtilityRiskTone.shortLabel(for: lifecycle.retirementRiskLevel))
                                                    .foregroundColor(SoftUtilityRiskTone.color(for: lifecycle.retirementRiskLevel))
                                            }
                                        }
                                        .softPanelStyle()
                                    }
                                }
                            }

                            Button("Refresh") {
                                Task {
                                    await viewModel.load(userId: userId)
                                }
                            }
                            .padding(.top, 4)
                        } else if let error = viewModel.errorMessage {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Home couldn’t load")
                                    .font(.title3)
                                    .bold()
                                Text(error)
                                    .foregroundColor(.red)
                                Button("Retry") {
                                    Task {
                                        await viewModel.load(userId: userId)
                                    }
                                }
                            }
                            .padding(.top, 20)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today")
                                    .font(.largeTitle)
                                    .bold()
                                Text("Your daily wear summary will appear here once you import activity and start assigning it to footwear.")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 20)
                        }
                    } else {
                        Text("Bootstrapping user session…")
                            .foregroundColor(.secondary)
                            .padding(.top, 30)
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .background(Color(.systemGroupedBackground))
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }

    private func homeHero(summary: HomeSummary) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("A calm view of movement, footwear in rotation, and anything that still needs your attention.")
                .foregroundColor(Color.white.opacity(0.74))

            HStack(spacing: 10) {
                heroChip(label: "\(summary.activeFootwear.count) active")
                heroChip(label: "\(summary.unassignedWear.count) to review")
            }
        }
        .premiumHeroStyle()
    }

    private func activityPanel(summary: HomeSummary) -> some View {
        HStack(spacing: 14) {
            statBlock(label: "Steps", value: "\(summary.today.steps)")
            statBlock(label: "Distance", value: String(format: "%.1f km", summary.today.distanceKm))
        }
    }

    private func statBlock(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
        }
        .metricTileStyle()
    }

    private func heroChip(label: String) -> some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.12))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
