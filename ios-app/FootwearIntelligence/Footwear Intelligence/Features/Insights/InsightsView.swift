import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    if let userId = session.userId {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else if let summary = viewModel.summary {
                            VStack(alignment: .leading, spacing: 16) {
                                SoftUtilityHero(
                                    title: "Insights",
                                    subtitle: "A softer read on what’s getting worn most, what’s beginning to drift, and what may need attention soon.",
                                    titleSize: 34
                                )

                                HStack(spacing: 10) {
                                    SoftUtilityHeroChip(label: "\(summary.mostWorn.count) most worn")
                                    SoftUtilityHeroChip(label: "\(summary.nearRetirement.count) near retirement")
                                }
                            }

                            HStack(spacing: 14) {
                                headlineMetric(label: "Most worn", value: "\(summary.mostWorn.count)", caption: "pairs with strongest wear history")
                                headlineMetric(label: "Watch list", value: "\(summary.needsAttention.count)", caption: "pairs worth checking soon")
                            }

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Most worn")
                                    .font(.title3)
                                    .bold()

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

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Needs attention")
                                    .font(.title3)
                                    .bold()

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

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Near retirement")
                                    .font(.title3)
                                    .bold()

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
                .padding()
            }
            .softUtilityBackground()
            .navigationTitle("Insights")
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }

    private func headlineMetric(label: String, value: String, caption: String) -> some View {
        SoftUtilityMetricTile(label: label, value: value, caption: caption)
    }

    private func emptyPanel(text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .softPanelStyle()
    }

    private func insightRow(title: String, subtitle: String, tone: Color, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(tone.opacity(0.14))
                .frame(width: 46, height: 46)
                .overlay(
                    Circle()
                        .stroke(tone.opacity(0.24), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(tone)
                )

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
        .elevatedPanelStyle()
    }
}
