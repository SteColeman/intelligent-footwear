import SwiftUI

struct AssignView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = AssignViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                if let userId = session.userId {
                    content(userId: userId)
                } else {
                    Text("Bootstrapping user session…")
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
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
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Assign wear")
                    .font(.largeTitle)
                    .bold()
                Text("A quiet review queue for movement that still needs a home.")
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Import activity")
                    .font(.headline)

                Text("Start with demo data for testing, or bring in today’s Health data when you want the real path.")
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
            .softPanelStyle()

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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Needs review")
                        .font(.headline)

                    ForEach(viewModel.unassignedWear) { event in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(event.eventType.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.headline)

                            HStack(spacing: 20) {
                                statLine(label: "Steps", value: "\(event.stepsCount ?? 0)")
                                statLine(label: "Distance", value: String(format: "%.1f km", event.distanceKm ?? 0))
                            }

                            if viewModel.hasLoadedAssignableFootwear {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Assign to")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    ForEach(viewModel.footwearItems) { item in
                                        Button {
                                            Task {
                                                await viewModel.assign(userId: userId, wearEventId: event.id, footwearItemId: item.id)
                                            }
                                        } label: {
                                            HStack {
                                                Text(item.displayName)
                                                Spacer()
                                                if item.isDefaultFallback {
                                                    Text("Default")
                                                        .font(.caption)
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("Add footwear before assigning wear.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .softPanelStyle()
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

    private func statLine(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }
}
