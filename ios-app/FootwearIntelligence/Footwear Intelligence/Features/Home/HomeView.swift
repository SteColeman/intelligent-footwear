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
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Today")
                                    .font(.largeTitle)
                                    .bold()
                                Text("A quiet view of today’s movement and what still needs assigning.")
                                    .foregroundColor(.secondary)
                            }

                            softPanel {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Today’s activity")
                                        .font(.headline)

                                    HStack(spacing: 24) {
                                        statBlock(label: "Steps", value: "\(summary.today.steps)")
                                        statBlock(label: "Distance", value: String(format: "%.1f km", summary.today.distanceKm))
                                    }
                                }
                            }

                            if let currentDefault = summary.currentDefault {
                                softPanel {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Default footwear")
                                            .font(.headline)
                                        Text(currentDefault.displayName)
                                            .font(.title3)
                                        Text("Used as the fallback when you want wear to land somewhere predictable.")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }

                            softPanel {
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
                            }

                            if !summary.activeFootwear.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("In rotation")
                                        .font(.headline)

                                    ForEach(summary.activeFootwear) { item in
                                        softPanel {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(item.displayName)
                                                    .font(.headline)
                                                Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                                    .foregroundColor(.secondary)

                                                if let lifecycle = item.lifecycleSummary {
                                                    Text("\(lifecycle.totalSteps) steps tracked")
                                                    Text(riskLabel(for: lifecycle.retirementRiskLevel))
                                                        .foregroundColor(riskColor(for: lifecycle.retirementRiskLevel))
                                                }
                                            }
                                        }
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
        case "high": return "Needs attention soon"
        case "medium": return "Worth keeping an eye on"
        default: return "Holding up well"
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
