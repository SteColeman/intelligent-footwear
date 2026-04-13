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
                                    value: "\(summary.mostWorn.count)",
                                    caption: "pairs with strongest wear history",
                                    tint: Color(red: 0.87, green: 0.90, blue: 0.82)
                                )
                                headlineMetric(
                                    label: "Watch list",
                                    value: "\(summary.needsAttention.count)",
                                    caption: "pairs worth checking soon",
                                    tint: Color(red: 0.93, green: 0.87, blue: 0.78)
                                )
                            }

                            VStack(alignment: .leading, spacing: 16) {
                                WarmSectionHeader(
                                    title: "Most worn",
                                    detail: "The pairs building the strongest real-life wear history."
                                )

                                if summary.mostWorn.isEmpty {
                                    emptyPanel(text: "Wear ranking will appear once more activity has been assigned.")
                                } else {
                                    ForEach(summary.mostWorn) { item in
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
                                    detail: "Pairs showing signs that they may need a closer look soon."
                                )

                                if summary.needsAttention.isEmpty {
                                    emptyPanel(text: "Nothing is standing out as concerning right now.")
                                } else {
                                    ForEach(summary.needsAttention) { item in
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
                                    detail: "Pairs that may be approaching the end of their useful life."
                                )

                                if summary.nearRetirement.isEmpty {
                                    emptyPanel(text: "Nothing looks close to retirement right now.")
                                } else {
                                    ForEach(summary.nearRetirement) { item in
                                        insightRow(
                                            title: item.displayName,
                                            subtitle: "Approaching end of life",
                                            tone: .red,
                                            detail: item.lifecycleSummary.map { SoftUtilityRiskTone.longLabel(for: $0.retirementRiskLevel) } ?? "May be nearing end of life"
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

    private func insightsHero(summary: InsightSummary) -> some View {
        WarmHeroCard {
            Text("Insights")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("A calmer read on what’s getting worn most, what may be drifting, and what may need attention soon.")
                .foregroundColor(Color.white.opacity(0.76))

            HStack(spacing: 12) {
                WarmHeroStat(value: "\(summary.mostWorn.count)", label: "most worn")
                WarmHeroStat(value: "\(summary.nearRetirement.count)", label: "near retirement")
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
