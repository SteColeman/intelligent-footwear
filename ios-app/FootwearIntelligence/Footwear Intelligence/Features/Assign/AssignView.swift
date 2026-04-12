import SwiftUI

struct AssignView: View {
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = AssignViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let userId = session.userId {
                    content(userId: userId)
                } else {
                    Text("Bootstrapping user session…")
                        .foregroundColor(.secondary)
                }
            }
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
        if viewModel.isLoading {
            ProgressView()
        } else if let error = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 12) {
                Text("Error: \(error)")
                    .foregroundColor(.red)

                assignActions(userId: userId)
            }
            .padding()
        } else if !viewModel.unassignedWear.isEmpty {
            List {
                Section {
                    assignActions(userId: userId)
                }

                Section("Unassigned wear") {
                    ForEach(viewModel.unassignedWear) { event in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.eventType)
                                .font(.headline)
                            Text("Steps: \(event.stepsCount ?? 0)")
                            Text(String(format: "Distance: %.1f km", event.distanceKm ?? 0))
                                .foregroundColor(.secondary)

                            if viewModel.hasLoadedAssignableFootwear {
                                ForEach(viewModel.footwearItems) { item in
                                    Button {
                                        Task {
                                            await viewModel.assign(userId: userId, wearEventId: event.id, footwearItemId: item.id)
                                        }
                                    } label: {
                                        Text("Assign to \(item.displayName)")
                                    }
                                }
                            } else {
                                Text("Add footwear before assigning wear.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Text("What are you wearing?")
                    .font(.title)
                    .bold()

                assignActions(userId: userId)

                Text("No unassigned wear to review right now.")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func assignActions(userId: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What are you wearing?")
                .font(.title)
                .bold()

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
}
