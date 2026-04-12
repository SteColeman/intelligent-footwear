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
                            VStack(alignment: .leading, spacing: 22) {
                                listHero

                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 24)
                                } else if !viewModel.items.isEmpty {
                                    Text("Your rotation")
                                        .font(.title3)
                                        .bold()

                                    ForEach(viewModel.items) { item in
                                        VStack(alignment: .leading, spacing: 12) {
                                            NavigationLink {
                                                FootwearDetailView(footwearItemId: item.id)
                                                    .environmentObject(session)
                                            } label: {
                                                HStack(alignment: .top, spacing: 14) {
                                                    Circle()
                                                        .fill(Color(.tertiarySystemGroupedBackground))
                                                        .frame(width: 50, height: 50)
                                                        .overlay(
                                                            Image(systemName: "shoeprints.fill")
                                                                .foregroundColor(.secondary)
                                                        )

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
                                                            HStack(spacing: 14) {
                                                                inlineMetric(label: "Steps", value: "\(lifecycle.totalSteps)")
                                                                inlineMetric(label: "Distance", value: String(format: "%.1f km", lifecycle.totalDistanceKm))
                                                            }

                                                            Text(SoftUtilityRiskTone.shortLabel(for: lifecycle.retirementRiskLevel))
                                                                .font(.subheadline.weight(.medium))
                                                                .foregroundColor(SoftUtilityRiskTone.color(for: lifecycle.retirementRiskLevel))
                                                        } else {
                                                            Text("No wear has been assigned to this footwear yet.")
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                }
                                                .elevatedPanelStyle()
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
                                    .softPanelStyle()
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
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
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

    private var listHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Footwear")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("Your current rotation, treated as real objects with history, wear, and condition over time.")
                .foregroundColor(Color.white.opacity(0.76))
            heroChip(label: "\(viewModel.items.count) in rotation")
        }
        .premiumHeroStyle()
    }

    private func inlineMetric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
    }

    private func heroChip(label: String) -> some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.12))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
