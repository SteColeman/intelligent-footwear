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
                        List {
                            if viewModel.isLoading {
                                ProgressView()
                            } else if !viewModel.items.isEmpty {
                                ForEach(viewModel.items) { item in
                                    VStack(alignment: .leading, spacing: 10) {
                                        NavigationLink {
                                            FootwearDetailView(footwearItemId: item.id)
                                                .environmentObject(session)
                                        } label: {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(item.displayName)
                                                    .font(.headline)
                                                Text(item.category)
                                                    .foregroundColor(.secondary)

                                                if let lifecycle = item.lifecycleSummary {
                                                    Text("Steps: \(lifecycle.totalSteps)")
                                                    Text(String(format: "Distance: %.1f km", lifecycle.totalDistanceKm))
                                                        .foregroundColor(.secondary)
                                                    Text("Risk: \(lifecycle.retirementRiskLevel)")
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding(.vertical, 2)
                                        }

                                        Button {
                                            selectedForCheckIn = item
                                        } label: {
                                            Text("Log condition")
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            } else if let error = viewModel.errorMessage {
                                Text("Error: \(error)")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                } else {
                    Text("Bootstrapping user session…")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Footwear")
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
}
