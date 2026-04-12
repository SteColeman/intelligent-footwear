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
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Footwear")
                                        .font(.largeTitle)
                                        .bold()
                                    Text("Your current rotation, tracked as real objects with real wear history.")
                                        .foregroundColor(.secondary)
                                }

                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 24)
                                } else if !viewModel.items.isEmpty {
                                    ForEach(viewModel.items) { item in
                                        VStack(alignment: .leading, spacing: 12) {
                                            NavigationLink {
                                                FootwearDetailView(footwearItemId: item.id)
                                                    .environmentObject(session)
                                            } label: {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    HStack(alignment: .top) {
                                                        VStack(alignment: .leading, spacing: 6) {
                                                            Text(item.displayName)
                                                                .font(.headline)
                                                                .foregroundColor(.primary)
                                                            Text(item.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                                                .foregroundColor(.secondary)
                                                        }

                                                        Spacer()

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

                                                    if let lifecycle = item.lifecycleSummary {
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text("\(lifecycle.totalSteps) steps tracked")
                                                            Text(String(format: "%.1f km logged", lifecycle.totalDistanceKm))
                                                                .foregroundColor(.secondary)
                                                            Text(riskLabel(for: lifecycle.retirementRiskLevel))
                                                                .foregroundColor(riskColor(for: lifecycle.retirementRiskLevel))
                                                        }
                                                        .font(.subheadline)
                                                    } else {
                                                        Text("No wear has been assigned to this footwear yet.")
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                .padding(16)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(.secondarySystemGroupedBackground))
                                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            }

                                            Button {
                                                selectedForCheckIn = item
                                            } label: {
                                                Text("Log condition")
                                            }
                                            .font(.subheadline.weight(.medium))
                                        }
                                    }
                                } else if let error = viewModel.errorMessage {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Footwear couldn’t load")
                                            .font(.headline)
                                        Text(error)
                                            .foregroundColor(.red)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    Text("Bootstrapping user session…")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Footwear")
            .background(Color(.systemGroupedBackground))
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
