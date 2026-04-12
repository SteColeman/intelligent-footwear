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
            .softUtilityBackground()
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
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 16) {
                SoftUtilityHero(
                    title: "Assign wear",
                    subtitle: "A review queue for movement that still needs to be matched to real footwear.",
                    titleSize: 34
                )

                SoftUtilityHeroChip(label: viewModel.unassignedWear.isEmpty ? "All clear" : "\(viewModel.unassignedWear.count) to review")
            }

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
                VStack(alignment: .leading, spacing: 14) {
                    Text("Waiting for a home")
                        .font(.title3)
                        .bold()

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
        .padding()
    }

    private func importPanel(userId: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
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
        .elevatedPanelStyle()
    }

    private func assignmentCard(event: WearEvent, userId: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.eventType.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.headline)
                    Text("Review and place this movement where it belongs.")
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.triangle.branch")
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 14) {
                metricTile(label: "Steps", value: "\(event.stepsCount ?? 0)")
                metricTile(label: "Distance", value: String(format: "%.1f km", event.distanceKm ?? 0))
            }

            if viewModel.hasLoadedAssignableFootwear {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assign to")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)

                    ForEach(viewModel.footwearItems) { item in
                        Button {
                            Task {
                                await viewModel.assign(userId: userId, wearEventId: event.id, footwearItemId: item.id)
                            }
                        } label: {
                            HStack {
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
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            } else {
                Text("Add footwear before assigning wear.")
                    .foregroundColor(.secondary)
            }
        }
        .elevatedPanelStyle()
    }

    private func metricTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
        }
        .metricTileStyle()
    }
}
