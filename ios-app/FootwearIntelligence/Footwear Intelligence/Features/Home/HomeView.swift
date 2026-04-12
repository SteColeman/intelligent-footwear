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
            .background(homeBackground)
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }

    private var homeBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.96, blue: 0.94),
                Color(red: 0.92, green: 0.93, blue: 0.91),
                Color(.systemGroupedBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func flagshipHero(summary: HomeSummary) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.14, green: 0.18, blue: 0.17),
                            Color(red: 0.21, green: 0.28, blue: 0.24),
                            Color(red: 0.31, green: 0.36, blue: 0.30)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 220, height: 220)
                            .offset(x: 70, y: -90)
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 140, height: 140)
                            .offset(x: 10, y: 50)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.14), radius: 24, x: 0, y: 14)

            VStack(alignment: .leading, spacing: 22) {
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
                    heroStat(value: "\(summary.today.steps)", label: "steps")
                    heroStat(value: "\(summary.activeFootwear.count)", label: "active pairs")
                    heroStat(value: "\(summary.unassignedWear.count)", label: "to review")
                }

                if let currentDefault = summary.currentDefault {
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
            .padding(26)
        }
    }

    private func dailyMovementSection(summary: HomeSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Today’s movement", detail: summary.today.steps > 0 ? "A softer read on how far the day has carried you." : "Nothing has been tracked yet.")

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
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(title: "Needs review", detail: reviewLine(summary: summary))

                Text(summary.unassignedWear.count == 0 ? "Your imported movement is in a good state." : String(format: "%.1f km still has no footwear attached.", summary.unassignedWear.distanceKm))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
            .background(Color.white.opacity(0.74))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(title: "Default footwear", detail: summary.currentDefault?.displayName ?? "No fallback pair set yet")

                Text(summary.currentDefault == nil ? "Pick one to make assignment behaviour more predictable." : "Used when you want movement to land somewhere stable.")
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
            sectionHeader(title: "In rotation", detail: "The pairs currently carrying your walking life.")

            if summary.activeFootwear.isEmpty {
                Text("Add footwear to start building a real rotation.")
                    .foregroundColor(.secondary)
                    .softPanelStyle()
            } else {
                ForEach(summary.activeFootwear) { item in
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.tertiarySystemGroupedBackground))
                                .frame(width: 62, height: 62)
                            Image(systemName: "shoeprints.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }

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
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.78))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 8)
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

    private func heroStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
