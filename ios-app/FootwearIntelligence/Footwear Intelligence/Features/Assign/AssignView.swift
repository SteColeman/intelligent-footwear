import SwiftUI

struct AssignView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = AssignViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if let userId = session.userId {
                    content(userId: userId)
                } else {
                    Text("Bootstrapping user session…")
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                }
            }
            .warmAppBackground()
            .navigationTitle("Assign")
            .task(id: session.userId) {
                if let userId = session.userId {
                    await viewModel.load(userId: userId)
                }
            }
        }
    }

    @ViewBuilder
    private func content(userId: String) -> some View {
        VStack(alignment: .leading, spacing: 26) {
            assignHero

            importPanel(userId: userId)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
            } else if let error = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Assign couldn’t load")
                        .font(.headline)
                    Text(error)
                        .foregroundColor(.red)
                }
                .softPanelStyle()
            } else if !viewModel.unassignedWear.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    WarmSectionHeader(
                        title: "Waiting for a home",
                        detail: "Imported movement that still needs to be matched to real footwear."
                    )

                    ForEach(viewModel.unassignedWear) { event in
                        assignmentCard(event: event, userId: userId)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nothing waiting right now")
                        .font(.headline)
                    Text("Imported wear will appear here when it still needs assigning.")
                        .foregroundColor(.secondary)
                }
                .softPanelStyle()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var activeAssignableItems: [FootwearItem] {
        viewModel.footwearItems.filter { $0.status == "active" }
    }

    private var inactiveAssignableItems: [FootwearItem] {
        viewModel.footwearItems.filter { $0.status != "active" }
    }

    private var assignHero: some View {
        WarmHeroCard {
            Text("Assign wear")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("A review queue for movement that still needs to be matched to real footwear.")
                .foregroundColor(Color.white.opacity(0.76))

            HStack(spacing: 12) {
                WarmHeroStat(value: "\(viewModel.unassignedWear.count)", label: "to review")
                WarmHeroStat(value: "\(activeAssignableItems.count)", label: "active pairs")
            }
        }
    }

    private func importPanel(userId: String) -> some View {
        WarmSurfaceCard {
            Text("Import activity")
                .font(.headline)

            Text("Bring in demo data to test the loop quickly, or use today’s Health data when you want the real path.")
                .foregroundColor(.secondary)

            HStack {
                Button("Import today’s health data") {
                    Task {
                        await viewModel.importTodayHealthData(userId: userId)
                    }
                }

                Button("Import demo data") {
                    Task {
                        await viewModel.importDemoHealthData(userId: userId)
                    }
                }
            }
        }
    }

    private func assignmentCard(event: WearEvent, userId: String) -> some View {
        WarmSurfaceCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.eventType.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.headline)
                    Text("Review and place this movement where it belongs.")
                        .foregroundColor(.secondary)
                }

                Spacer()

                WarmIconTile(systemName: "arrow.triangle.branch", tint: Color(red: 0.87, green: 0.90, blue: 0.82), size: 42)
            }

            HStack(spacing: 14) {
                metricTile(label: "Steps", value: "\(event.stepsCount ?? 0)", tint: Color(red: 0.87, green: 0.90, blue: 0.82))
                metricTile(label: "Distance", value: String(format: "%.1f km", event.distanceKm ?? 0), tint: Color(red: 0.93, green: 0.87, blue: 0.78))
            }

            if !activeAssignableItems.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Assign to")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)

                    ForEach(activeAssignableItems) { item in
                        Button {
                            Task {
                                await viewModel.assign(userId: userId, wearEventId: event.id, footwearItemId: item.id)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                WarmIconTile(systemName: "shoeprints.fill", tint: Color(red: 0.92, green: 0.90, blue: 0.84), size: 46)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.displayName)
                                        .foregroundColor(.primary)
                                    Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.caption)
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
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.58))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                }

                if !inactiveAssignableItems.isEmpty {
                    Text("Retired and archived footwear is excluded from normal assignment targets.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if !viewModel.footwearItems.isEmpty {
                Text("No active footwear is available for assignment right now.")
                    .foregroundColor(.secondary)
            } else {
                Text("Add footwear before assigning wear.")
                    .foregroundColor(.secondary)
            }
        }
    }

    private func metricTile(label: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
