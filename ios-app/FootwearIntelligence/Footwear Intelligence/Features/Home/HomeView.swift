import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    if let userId = session.userId {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 50)
                        } else if let summary = viewModel.summary {
                            homeHero(summary: summary)

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Today’s movement")
                                    .font(.title3)
                                    .bold()

                                HStack(spacing: 14) {
                                    statBlock(label: "Steps", value: "\(summary.today.steps)", caption: summary.today.steps > 0 ? "moving through the day" : "nothing tracked yet")
                                    statBlock(label: "Distance", value: String(format: "%.1f km", summary.today.distanceKm), caption: summary.today.distanceKm > 0 ? "covered so far" : "no distance yet")
                                }
                            }

                            if let currentDefault = summary.currentDefault {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Current default")
                                        .font(.title3)
                                        .bold()

                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(currentDefault.displayName)
                                            .font(.headline)
                                        Text("Used as the fallback when you want wear to land somewhere predictable.")
                                            .foregroundColor(.secondary)
                                    }
                                    .elevatedPanelStyle()
                                }
                            }

                            HStack(alignment: .top, spacing: 14) {
                                reviewCard(count: summary.unassignedWear.count, distanceKm: summary.unassignedWear.distanceKm)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Rotation")
                                        .font(.headline)
                                    Text("\(summary.activeFootwear.count)")
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                    Text("pairs currently active")
                                        .foregroundColor(.secondary)
                                }
                                .metricTileStyle()
                            }

                            if !summary.activeFootwear.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("In rotation")
                                        .font(.title3)
                                        .bold()

                                    ForEach(summary.activeFootwear) { item in
                                        HStack(alignment: .top, spacing: 14) {
                                            Circle()
                                                .fill(Color(.tertiarySystemGroupedBackground))
                                                .frame(width: 44, height: 44)
                                                .overlay(
                                                    Image(systemName: "shoeprints.fill")
                                                        .foregroundColor(.secondary)
                                                )

                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(item.displayName)
                                                    .font(.headline)
                                                Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                                    .foregroundColor(.secondary)

                                                if let lifecycle = item.lifecycleSummary {
                                                    Text(SoftUtilityRiskTone.shortLabel(for: lifecycle.retirementRiskLevel))
                                                        .foregroundColor(SoftUtilityRiskTone.color(for: lifecycle.retirementRiskLevel))
                                                }
                                            }

                                            Spacer()
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
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }

    private func homeHero(summary: HomeSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("A calmer read on movement, footwear in rotation, and anything that still needs your attention.")
                .foregroundColor(Color.white.opacity(0.76))

            HStack(spacing: 10) {
                heroChip(label: "\(summary.activeFootwear.count) active")
                heroChip(label: "\(summary.unassignedWear.count) to review")
            }
        }
        .premiumHeroStyle()
    }

    private func reviewCard(count: Int, distanceKm: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Needs review")
                .font(.headline)
            Text("\(count)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text(count == 0 ? "everything assigned" : String(format: "%.1f km still unassigned", distanceKm))
                .foregroundColor(.secondary)
        }
        .metricTileStyle()
    }

    private func statBlock(label: String, value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text(caption)
                .font(.caption)
                .foregroundColor(.secondary)
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
