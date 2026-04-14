import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    if let userId = session.userId {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else if let summary = viewModel.summary {
                            insightsHero(summary: summary)

                            HStack(spacing: 14) {
                                headlineMetric(
                                    label: "Most worn",
                                    value: "\(activeMostWorn(from: summary).count)",
                                    caption: "active pairs with strongest wear history",
                                    tint: Color(red: 0.87, green: 0.90, blue: 0.82)
                                )
                                headlineMetric(
                                    label: "Watch list",
                                    value: "\(activeNeedsAttention(from: summary).count)",
                                    caption: "active pairs worth checking soon",
                                    tint: Color(red: 0.93, green: 0.87, blue: 0.78)
                                )
                            }

                            VStack(alignment: .leading, spacing: 16) {
                                WarmSectionHeader(
                                    title: "Most worn",
                                    detail: "The active pairs building the strongest real-life wear history."
                                )

                                if activeMostWorn(from: summary).isEmpty {
                                    emptyPanel(text: "No active footwear has built up enough assigned wear yet.")
                                } else {
                                    ForEach(activeMostWorn(from: summary)) { item in
                                        insightRow(
                                            title: item.displayName,
                                            subtitle: item.category.replacingOccurrences(of: "_", with: " ").capitalized,
                                            tone: item.lifecycleSummary.map { SoftUtilityRiskTone.color(for: $0.retirementRiskLevel) } ?? .secondary,
                                            detail: item.lifecycleSummary.map { SoftUtilityRiskTone.shortLabel(for: $0.retirementRiskLevel) } ?? "No lifecycle signal yet"
                                        )
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 16) {
                                WarmSectionHeader(
                                    title: "Needs attention",
                                    detail: "Active pairs showing signs that they may need a closer look soon."
                                )

                                if activeNeedsAttention(from: summary).isEmpty {
                                    emptyPanel(text: "No active footwear is standing out as concerning right now.")
                                } else {
                                    ForEach(activeNeedsAttention(from: summary)) { item in
                                        insightRow(
                                            title: item.displayName,
                                            subtitle: "Worth a closer look",
                                            tone: .orange,
                                            detail: item.lifecycleSummary.map { SoftUtilityRiskTone.shortLabel(for: $0.retirementRiskLevel) } ?? "Attention signal detected"
                                        )
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 16) {
                                WarmSectionHeader(
                                    title: "Near retirement",
                                    detail: "Active pairs that may be approaching the end of their useful life."
                                )

                                if activeNearRetirement(from: summary).isEmpty {
                                    emptyPanel(text: "No active footwear looks close to retirement right now.")
                                } else {
                                    ForEach(activeNearRetirement(from: summary)) { item in
                                        insightRow(
                                            title: item.displayName,
                                            subtitle: "Approaching end of life",
                                            tone: .red,
                                            detail: item.lifecycleSummary.map { SoftUtilityRiskTone.longLabel(for: $0.retirementRiskLevel) } ?? "May be nearing end of life"
                                        )
                                    }
                                }
                            }

                            if !inactiveItems(from: summary).isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    WarmSectionHeader(
                                        title: "Inactive history",
                                        detail: "Retired and archived footwear kept in the record, but not part of the active story."
                                    )

                                    ForEach(inactiveItems(from: summary)) { item in
                                        insightRow(
                                            title: item.displayName,
                                            subtitle: item.status.capitalized,
                                            tone: .gray,
                                            detail: inactiveDetailCopy(for: item.status)
                                        )
                                    }
                                }
                            }
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
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .warmAppBackground()
            .navigationTitle("Insights")
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }

    private func activeMostWorn(from summary: InsightSummary) -> [FootwearItem] {
        summary.mostWorn.filter { $0.status == "active" }
    }

    private func activeNeedsAttention(from summary: InsightSummary) -> [FootwearItem] {
        summary.needsAttention.filter { $0.status == "active" }
    }

    private func activeNearRetirement(from summary: InsightSummary) -> [FootwearItem] {
        summary.nearRetirement.filter { $0.status == "active" }
    }

    private func inactiveItems(from summary: InsightSummary) -> [FootwearItem] {
        summary.inactiveHistory
    }

    private func inactiveDetailCopy(for status: String) -> String {
        switch status {
        case "archived": return "Archived footwear remains in the record for reference only."
        case "retired": return "Retired footwear remains in the record but is no longer part of the active rotation."
        default: return "Inactive footwear."
        }
    }

    private func insightsHero(summary: InsightSummary) -> some View {
        WarmHeroCard {
            Text("Insights")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("A calmer read on what’s getting worn most, what may be drifting, and what may need attention soon.")
                .foregroundColor(Color.white.opacity(0.76))

            HStack(spacing: 12) {
                WarmHeroStat(value: "\(activeMostWorn(from: summary).count)", label: "most worn")
                WarmHeroStat(value: "\(activeNearRetirement(from: summary).count)", label: "near retirement")
            }
        }
    }

    private func headlineMetric(label: String, value: String, caption: String, tint: Color) -> some View {
        WarmMetricTile(label: label, value: value, caption: caption, tint: tint)
    }

    private func emptyPanel(text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .softPanelStyle()
    }

    private func insightRow(title: String, subtitle: String, tone: Color, detail: String) -> some View {
        WarmSurfaceCard {
            HStack(alignment: .top, spacing: 14) {
                WarmIconTile(systemName: "waveform.path.ecg", tint: tone.opacity(0.18))

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(detail)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(tone)
                }

                Spacer()
            }
        }
    }
}
