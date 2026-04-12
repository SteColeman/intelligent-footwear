import SwiftUI

struct ConditionCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel: ConditionCheckInViewModel

    init(footwearItemId: String) {
        _viewModel = StateObject(wrappedValue: ConditionCheckInViewModel(footwearItemId: footwearItemId))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    checkInHero

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Condition")
                            .font(.title3)
                            .bold()

                        scoreRow(title: "Comfort", value: $viewModel.comfortScore)
                        scoreRow(title: "Cushioning", value: $viewModel.cushioningScore)
                        scoreRow(title: "Support", value: $viewModel.supportScore)
                        scoreRow(title: "Grip", value: $viewModel.gripScore)
                        scoreRow(title: "Upper condition", value: $viewModel.upperConditionScore)
                        scoreRow(title: "Confidence in continued use", value: $viewModel.overallConfidenceScore)
                    }
                    .elevatedPanelStyle()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.headline)
                        TextField("Optional notes", text: $viewModel.notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .softPanelStyle()

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .softPanelStyle()
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Condition Check-In")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isSaving ? "Saving..." : "Save") {
                        guard let userId = session.userId else {
                            viewModel.errorMessage = "No active user session"
                            return
                        }

                        Task {
                            await viewModel.save(userId: userId)
                            if viewModel.didSave {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }

    private var checkInHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Condition check-in")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("A short record of how this pair is feeling and holding up right now.")
                .foregroundColor(Color.white.opacity(0.76))
            Text("Quick but useful")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.12))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .premiumHeroStyle()
    }

    private func scoreRow(title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(value.wrappedValue)/5")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(scoreColor(for: value.wrappedValue))
            }

            Stepper(value: value, in: 1...5) {
                Text(scoreCaption(for: value.wrappedValue))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func scoreCaption(for score: Int) -> String {
        switch score {
        case 1: return "Very poor"
        case 2: return "Below par"
        case 3: return "Holding up"
        case 4: return "Good"
        default: return "Very good"
        }
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 1...2: return .red
        case 3: return .orange
        default: return .green
        }
    }
}
