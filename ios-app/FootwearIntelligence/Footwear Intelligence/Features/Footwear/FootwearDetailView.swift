import SwiftUI

struct FootwearDetailView: View {
    @EnvironmentObject var session: AppSession
    let footwearItemId: String

    @StateObject private var viewModel = FootwearDetailViewModel()
    @State private var showingConditionCheckIn = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            if let userId = session.userId {
                content(userId: userId)
            } else {
                Text("Bootstrapping user session…")
                    .foregroundColor(.secondary)
                    .padding(.top, 30)
            }
        }
        .background(detailBackground)
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

    private var detailBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 0.93, blue: 0.89),
                Color(red: 0.90, green: 0.91, blue: 0.87),
                Color(red: 0.86, green: 0.88, blue: 0.84),
                Color(.systemGroupedBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
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
            VStack(alignment: .leading, spacing: 28) {
                objectHero(for: item, lifecycle: lifecycle)
                sculptedMetricsSection(lifecycle: lifecycle)
                lifecycleReadSection(lifecycle: lifecycle)
                conditionHistorySection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        } else if let item = viewModel.item {
            VStack(alignment: .leading, spacing: 24) {
                objectHeroWithoutLifecycle(for: item)

                Text("No lifecycle data has been built for this footwear yet.")
                    .foregroundColor(.secondary)
                    .softPanelStyle()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        } else {
            Text("No footwear detail available.")
                .foregroundColor(.secondary)
                .padding(.top, 30)
        }
    }

    private func objectHero(for item: FootwearItem, lifecycle: LifecycleSummaryLite) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.18, blue: 0.17),
                            Color(red: 0.26, green: 0.28, blue: 0.24),
                            Color(red: 0.40, green: 0.39, blue: 0.31)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 250, height: 250)
                            .offset(x: 90, y: -110)
                        Circle()
                            .fill(Color(red: 0.85, green: 0.89, blue: 0.78).opacity(0.16))
                            .frame(width: 170, height: 170)
                            .offset(x: 10, y: 70)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 26, x: 0, y: 18)

            VStack(alignment: .leading, spacing: 26) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.displayName)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.76))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        if item.isDefaultFallback {
                            tag(label: "Default")
                        }
                        tag(label: item.status.capitalized)
                    }
                }

                HStack(alignment: .center, spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.12), Color(red: 0.83, green: 0.86, blue: 0.74).opacity(0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 138, height: 138)
                        Circle()
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            .frame(width: 102, height: 102)
                        Image(systemName: "shoeprints.fill")
                            .font(.system(size: 42, weight: .medium))
                            .foregroundColor(.white.opacity(0.88))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current read")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Color.white.opacity(0.68))
                            .textCase(.uppercase)

                        Text(SoftUtilityRiskTone.longLabel(for: lifecycle.retirementRiskLevel))
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)

                        if let confidenceScore = lifecycle.confidenceScore {
                            Text(String(format: "Estimate confidence %.2f", confidenceScore))
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.74))
                        }
                    }
                }

                HStack(spacing: 14) {
                    heroMetric(value: "\(lifecycle.totalSteps)", label: "steps")
                    heroMetric(value: String(format: "%.1f km", lifecycle.totalDistanceKm), label: "distance")
                    heroMetric(value: lifecycle.retirementRiskLevel.capitalized, label: "risk")
                }
            }
            .padding(28)
        }
    }

    private func objectHeroWithoutLifecycle(for item: FootwearItem) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.18, blue: 0.17),
                            Color(red: 0.26, green: 0.28, blue: 0.24),
                            Color(red: 0.40, green: 0.39, blue: 0.31)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 26, x: 0, y: 18)

            VStack(alignment: .leading, spacing: 18) {
                Text(item.displayName)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                    .foregroundColor(Color.white.opacity(0.76))
                Text("This pair has been added, but its wear history hasn’t built up yet.")
                    .foregroundColor(Color.white.opacity(0.78))
            }
            .padding(28)
        }
    }

    private func sculptedMetricsSection(lifecycle: LifecycleSummaryLite) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Wear trajectory", detail: "A richer, less flat read on how this pair is ageing in real use.")

            HStack(alignment: .top, spacing: 14) {
                radialLifecycleCard(lifecycle: lifecycle)

                VStack(spacing: 14) {
                    compactTintedMetric(
                        label: "Distance",
                        value: String(format: "%.1f km", lifecycle.totalDistanceKm),
                        detail: "captured so far",
                        tint: Color(red: 0.87, green: 0.90, blue: 0.82)
                    )
                    compactTintedMetric(
                        label: "Assigned days",
                        value: "\(lifecycle.assignedDaysCount)",
                        detail: "days in rotation",
                        tint: Color(red: 0.93, green: 0.87, blue: 0.78)
                    )
                    compactTintedMetric(
                        label: "Remaining",
                        value: remainingDistanceText(lifecycle: lifecycle),
                        detail: "estimated distance",
                        tint: softenedRiskTint(for: lifecycle.retirementRiskLevel)
                    )
                }
            }
        }
    }

    private func radialLifecycleCard(lifecycle: LifecycleSummaryLite) -> some View {
        let progress = min(max(lifecycle.lifecycleProgressPct ?? 0.42, 0.08), 0.98)

        return VStack(alignment: .leading, spacing: 14) {
            Text("Lifecycle")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.08), lineWidth: 16)
                    .frame(width: 138, height: 138)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressGradient(for: lifecycle.retirementRiskLevel),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 138, height: 138)

                VStack(spacing: 4) {
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("used")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)

            Text(SoftUtilityRiskTone.shortLabel(for: lifecycle.retirementRiskLevel))
                .font(.subheadline.weight(.medium))
                .foregroundColor(SoftUtilityRiskTone.color(for: lifecycle.retirementRiskLevel))
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 332, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.88), Color(red: 0.95, green: 0.93, blue: 0.87)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.80), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.07), radius: 16, x: 0, y: 10)
    }

    private func lifecycleReadSection(lifecycle: LifecycleSummaryLite) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Lifecycle read", detail: "Not a hard replacement rule — a calmer interpretation of wear plus condition signals.")

            VStack(alignment: .leading, spacing: 16) {
                Text(SoftUtilityRiskTone.longLabel(for: lifecycle.retirementRiskLevel))
                    .font(.title3.weight(.semibold))

                if let remainingSteps = lifecycle.estimatedRemainingSteps {
                    infoRow(label: "Estimated remaining steps", value: "\(remainingSteps)")
                }

                if let remainingDistance = lifecycle.estimatedRemainingDistanceKm {
                    infoRow(label: "Estimated remaining distance", value: String(format: "%.1f km", remainingDistance))
                }

                if let progress = lifecycle.lifecycleProgressPct {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Lifecycle progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.0f%%", progress * 100))
                                .font(.subheadline.weight(.semibold))
                        }

                        GeometryReader { proxy in
                            let width = max(proxy.size.width * progress, 16)
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.black.opacity(0.08))
                                Capsule()
                                    .fill(progressGradient(for: lifecycle.retirementRiskLevel))
                                    .frame(width: width)
                            }
                        }
                        .frame(height: 12)
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.86), Color(red: 0.93, green: 0.91, blue: 0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white.opacity(0.70), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
        }
    }

    private var conditionHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Condition history", detail: "Snapshots of how the object actually felt over time.")

            if !viewModel.hasConditionHistory {
                Text("Condition check-ins will appear here once you start logging them.")
                    .foregroundColor(.secondary)
                    .softPanelStyle()
            } else {
                ForEach(viewModel.conditionLogs) { log in
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(log.loggedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(historyHeadline(for: log.overallConfidenceScore))
                                    .font(.title3.weight(.semibold))
                            }

                            Spacer()

                            Text("\(log.overallConfidenceScore)/5")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(scoreFill(for: log.overallConfidenceScore))
                                .foregroundColor(scoreColor(for: log.overallConfidenceScore))
                                .clipShape(Capsule())
                        }

                        HStack(spacing: 12) {
                            metricPill(label: "Comfort", value: "\(log.comfortScore)")
                            metricPill(label: "Support", value: "\(log.supportScore)")
                            metricPill(label: "Grip", value: "\(log.gripScore)")
                        }

                        if let notes = log.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [Color.white.opacity(0.88), Color(red: 0.95, green: 0.93, blue: 0.87)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(Color.white.opacity(0.78), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
                }
            }
        }
    }

    private func sectionHeader(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3)
                .bold()
            Text(detail)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func heroMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func compactTintedMetric(label: String, value: String, detail: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text(detail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(tint.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func metricPill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func tag(label: String) -> some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.12))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }

    private func remainingDistanceText(lifecycle: LifecycleSummaryLite) -> String {
        if let remainingDistance = lifecycle.estimatedRemainingDistanceKm {
            return String(format: "%.1f km", remainingDistance)
        }

        return "—"
    }

    private func softenedRiskTint(for level: String) -> Color {
        switch level.lowercased() {
        case "high": return Color(red: 0.95, green: 0.82, blue: 0.78)
        case "medium": return Color(red: 0.95, green: 0.88, blue: 0.72)
        default: return Color(red: 0.84, green: 0.91, blue: 0.82)
        }
    }

    private func progressGradient(for level: String) -> LinearGradient {
        switch level.lowercased() {
        case "high":
            return LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing)
        case "medium":
            return LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [Color.green.opacity(0.7), Color.green], startPoint: .leading, endPoint: .trailing)
        }
    }

    private func historyHeadline(for score: Int) -> String {
        switch score {
        case 1...2: return "This pair felt tired"
        case 3: return "This pair felt mixed"
        default: return "This pair felt solid"
        }
    }

    private func scoreFill(for score: Int) -> Color {
        switch score {
        case 1...2: return Color.red.opacity(0.14)
        case 3: return Color.orange.opacity(0.16)
        default: return Color.green.opacity(0.14)
        }
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 1...2: return .red
        case 3: return .orange
        default: return .green
        }
    }
}
