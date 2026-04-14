import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    if let userId = session.userId {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 50)
                        } else if let summary = viewModel.summary {
                            flagshipHero(summary: summary)
                            dailyMovementSection(summary: summary)
                            reviewAndDefaultSection(summary: summary)
                            rotationSection(summary: summary)

                            Button("Refresh") {
                                Task {
                                    await viewModel.load(userId: userId)
                                }
                            }
                            .padding(.top, 2)
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
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Home")
            .warmAppBackground(top: Color(red: 0.95, green: 0.96, blue: 0.94), middle: Color(red: 0.92, green: 0.93, blue: 0.91))
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }

    private var activeFootwear: [FootwearItem] {
        (viewModel.summary?.activeFootwear ?? []).filter { $0.status == "active" }
    }

    private func flagshipHero(summary: HomeSummary) -> some View {
        WarmHeroCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(heroSummaryLine(summary: summary))
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.78))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("Movement")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color.white.opacity(0.68))
                        .textCase(.uppercase)
                    Text(String(format: "%.1f km", summary.today.distanceKm))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            HStack(spacing: 14) {
                WarmHeroStat(value: "\(summary.today.steps)", label: "steps")
                WarmHeroStat(value: "\(activeFootwear.count)", label: "active pairs")
                WarmHeroStat(value: "\(summary.unassignedWear.count)", label: "to review")
            }

            if let currentDefault = summary.currentDefault, currentDefault.status == "active" {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current default")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color.white.opacity(0.68))
                        .textCase(.uppercase)
                    Text(currentDefault.displayName)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                    Text("Your fallback pair when movement needs somewhere predictable to land.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.74))
                }
            }
        }
    }

    private func dailyMovementSection(summary: HomeSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            WarmSectionHeader(
                title: "Today’s movement",
                detail: summary.today.steps > 0 ? "A softer read on how far the day has carried you." : "Nothing has been tracked yet."
            )

            HStack(alignment: .top, spacing: 14) {
                oversizedMetricCard(
                    label: "Steps tracked",
                    value: "\(summary.today.steps)",
                    detail: summary.today.steps > 0 ? "walking through the day" : "waiting for first movement"
                )

                VStack(spacing: 14) {
                    compactMetricCard(
                        label: "Distance",
                        value: String(format: "%.1f km", summary.today.distanceKm),
                        detail: summary.today.distanceKm > 0 ? "covered so far" : "none yet"
                    )
                    compactMetricCard(
                        label: "Review queue",
                        value: "\(summary.unassignedWear.count)",
                        detail: summary.unassignedWear.count == 0 ? "everything assigned" : "events still waiting"
                    )
                }
            }
        }
    }

    private func reviewAndDefaultSection(summary: HomeSummary) -> some View {
        HStack(alignment: .top, spacing: 14) {
            WarmSurfaceCard {
                WarmSectionHeader(title: "Needs review", detail: reviewLine(summary: summary))

                Text(summary.unassignedWear.count == 0 ? "Your imported movement is in a good state." : String(format: "%.1f km still has no footwear attached.", summary.unassignedWear.distanceKm))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 14) {
                WarmSectionHeader(
                    title: "Default footwear",
                    detail: (summary.currentDefault?.status == "active") ? (summary.currentDefault?.displayName ?? "No fallback pair set yet") : "No active fallback pair set"
                )

                Text((summary.currentDefault == nil || summary.currentDefault?.status != "active") ? "Pick an active pair to make assignment behaviour more predictable." : "Used when you want movement to land somewhere stable.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.88, green: 0.92, blue: 0.88), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
        }
    }

    private func rotationSection(summary: HomeSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            WarmSectionHeader(title: "In rotation", detail: activeFootwear.isEmpty ? "No active footwear is currently in rotation." : "The pairs currently carrying your walking life.")

            if activeFootwear.isEmpty {
                Text("Set at least one pair to active to build a real rotation.")
                    .foregroundColor(.secondary)
                    .softPanelStyle()
            } else {
                ForEach(activeFootwear) { item in
                    WarmSurfaceCard {
                        HStack(alignment: .top, spacing: 16) {
                            WarmIconTile(systemName: "shoeprints.fill", tint: Color(red: 0.92, green: 0.90, blue: 0.84), size: 62)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.displayName)
                                            .font(.headline)
                                        Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if item.isDefaultFallback {
                                        Text("Default")
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.green.opacity(0.12))
                                            .foregroundColor(.green)
                                            .clipShape(Capsule())
                                    }
                                }

                                if let lifecycle = item.lifecycleSummary {
                                    HStack(spacing: 16) {
                                        inlineFact(label: "Steps", value: "\(lifecycle.totalSteps)")
                                        inlineFact(label: "Distance", value: String(format: "%.1f km", lifecycle.totalDistanceKm))
                                    }

                                    Text(SoftUtilityRiskTone.shortLabel(for: lifecycle.retirementRiskLevel))
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(SoftUtilityRiskTone.color(for: lifecycle.retirementRiskLevel))
                                } else {
                                    Text("No wear has been assigned to this footwear yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func oversizedMetricCard(label: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 42, weight: .bold, design: .rounded))
            Spacer(minLength: 0)
            Text(detail)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 10)
    }

    private func compactMetricCard(label: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(detail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 93, alignment: .topLeading)
        .background(Color.white.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 8)
    }

    private func inlineFact(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func heroSummaryLine(summary: HomeSummary) -> String {
        if summary.unassignedWear.count > 0 {
            return "\(summary.unassignedWear.count) movement event\(summary.unassignedWear.count == 1 ? " still needs review" : "s still need review")"
        }

        if summary.today.steps > 0 {
            return "Everything logged so far has somewhere to belong."
        }

        return "A calm baseline before the day starts to register wear."
    }

    private func reviewLine(summary: HomeSummary) -> String {
        if summary.unassignedWear.count == 0 {
            return "Nothing is currently waiting for manual assignment."
        }

        return "\(summary.unassignedWear.count) wear event\(summary.unassignedWear.count == 1 ? " is" : "s are") still waiting to be placed."
    }
}
