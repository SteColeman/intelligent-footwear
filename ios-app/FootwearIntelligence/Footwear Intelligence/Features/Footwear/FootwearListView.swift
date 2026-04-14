import SwiftUI

struct FootwearListView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = FootwearListViewModel()
    @State private var showingCreate = false
    @State private var selectedForCheckIn: FootwearItem?

    var body: some View {
        NavigationStack {
            Group {
                if let userId = session.userId {
                    if viewModel.hasNoFootwear {
                        FirstFootwearPromptView()
                            .environmentObject(session)
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 26) {
                                listHero

                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 24)
                                } else if !viewModel.items.isEmpty {
                                    if !activeItems.isEmpty {
                                        WarmSectionHeader(
                                            title: "Active rotation",
                                            detail: "The footwear currently carrying your days."
                                        )

                                        ForEach(activeItems) { item in
                                            footwearCard(item: item, subdued: false)
                                        }
                                    }

                                    if !inactiveItems.isEmpty {
                                        WarmSectionHeader(
                                            title: "Archived and retired",
                                            detail: "Footwear kept in the record, but no longer part of the active rotation."
                                        )

                                        ForEach(inactiveItems) { item in
                                            footwearCard(item: item, subdued: true)
                                        }
                                    }
                                } else if let error = viewModel.errorMessage {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Footwear couldn’t load")
                                            .font(.headline)
                                        Text(error)
                                            .foregroundColor(.red)
                                    }
                                    .softPanelStyle()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                } else {
                    Text("Bootstrapping user session…")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Footwear")
            .warmAppBackground()
            .toolbar {
                if session.userId != nil {
                    Button("Add") {
                        showingCreate = true
                    }
                }
            }
            .sheet(isPresented: $showingCreate, onDismiss: {
                Task {
                    if let userId = session.userId {
                        await viewModel.load(userId: userId)
                    }
                }
            }) {
                CreateFootwearView()
                    .environmentObject(session)
            }
            .sheet(item: $selectedForCheckIn, onDismiss: {
                Task {
                    if let userId = session.userId {
                        await viewModel.load(userId: userId)
                    }
                }
            }) { item in
                ConditionCheckInView(footwearItemId: item.id)
                    .environmentObject(session)
            }
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }

    private var activeItems: [FootwearItem] {
        viewModel.items.filter { $0.status == "active" }
    }

    private var inactiveItems: [FootwearItem] {
        viewModel.items.filter { $0.status != "active" }
    }

    private var listHero: some View {
        WarmHeroCard {
            Text("Footwear")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Your current rotation, treated as a set of real objects with history, wear, and condition over time.")
                .foregroundColor(Color.white.opacity(0.76))

            HStack(spacing: 12) {
                WarmHeroStat(value: "\(activeItems.count)", label: "active")
                WarmHeroStat(value: "\(inactiveItems.count)", label: "inactive")
            }
        }
    }

    private func footwearCard(item: FootwearItem, subdued: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink {
                FootwearDetailView(footwearItemId: item.id)
                    .environmentObject(session)
            } label: {
                WarmSurfaceCard {
                    HStack(alignment: .top, spacing: 14) {
                        FootwearPhotoView(
                            photoUrl: item.photoUrl,
                            size: 72,
                            cornerRadius: 22,
                            tint: subdued ? Color(red: 0.86, green: 0.86, blue: 0.84) : Color(red: 0.90, green: 0.89, blue: 0.81),
                            iconFont: .title2,
                            progressTint: .secondary,
                            backgroundOpacity: 0.35
                        )
                        .opacity(subdued ? 0.82 : 1)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(item.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                HStack(spacing: 8) {
                                    statusPill(for: item.status)

                                    if item.isDefaultFallback {
                                        Text("Default")
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.green.opacity(0.15))
                                            .foregroundColor(.green)
                                            .clipShape(Capsule())
                                    }
                                }
                            }

                            if let lifecycle = item.lifecycleSummary {
                                HStack(spacing: 12) {
                                    smallMetric(label: "Steps", value: "\(lifecycle.totalSteps)", tint: subdued ? Color(red: 0.90, green: 0.90, blue: 0.88) : Color(red: 0.87, green: 0.90, blue: 0.82))
                                    smallMetric(label: "Distance", value: String(format: "%.1f km", lifecycle.totalDistanceKm), tint: subdued ? Color(red: 0.92, green: 0.91, blue: 0.89) : Color(red: 0.93, green: 0.87, blue: 0.78))
                                }

                                Text(item.status == "active" ? SoftUtilityRiskTone.shortLabel(for: lifecycle.retirementRiskLevel) : inactiveStatusCopy(for: item.status))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(item.status == "active" ? SoftUtilityRiskTone.color(for: lifecycle.retirementRiskLevel) : .secondary)
                            } else {
                                Text(item.status == "active" ? "No wear has been assigned to this footwear yet." : inactiveStatusCopy(for: item.status))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .opacity(subdued ? 0.88 : 1)
            }
            .buttonStyle(.plain)

            if item.status == "active" {
                Button {
                    selectedForCheckIn = item
                } label: {
                    Text("Log condition")
                }
                .font(.subheadline.weight(.medium))
            }
        }
    }

    private func statusPill(for status: String) -> some View {
        let color: Color = {
            switch status {
            case "archived": return .gray
            case "retired": return .orange
            default: return .blue
            }
        }()

        return Text(status.capitalized)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private func inactiveStatusCopy(for status: String) -> String {
        switch status {
        case "archived": return "Kept for reference, but removed from the active rotation."
        case "retired": return "No longer in regular use, but still part of the history."
        default: return "Inactive footwear."
        }
    }

    private func smallMetric(label: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(tint.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
