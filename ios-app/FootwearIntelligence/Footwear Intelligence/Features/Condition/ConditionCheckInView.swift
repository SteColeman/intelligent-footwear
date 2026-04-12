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
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Condition check-in")
                            .font(.largeTitle)
                            .bold()
                        Text("A short record of how this pair is feeling and holding up right now.")
                            .foregroundColor(.secondary)
                    }

                    softPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Condition")
                                .font(.headline)
                            Stepper("Comfort: \(viewModel.comfortScore)", value: $viewModel.comfortScore, in: 1...5)
                            Stepper("Cushioning: \(viewModel.cushioningScore)", value: $viewModel.cushioningScore, in: 1...5)
                            Stepper("Support: \(viewModel.supportScore)", value: $viewModel.supportScore, in: 1...5)
                            Stepper("Grip: \(viewModel.gripScore)", value: $viewModel.gripScore, in: 1...5)
                            Stepper("Upper condition: \(viewModel.upperConditionScore)", value: $viewModel.upperConditionScore, in: 1...5)
                            Stepper("Confidence in continued use: \(viewModel.overallConfidenceScore)", value: $viewModel.overallConfidenceScore, in: 1...5)
                        }
                    }

                    softPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.headline)
                            TextField("Optional notes", text: $viewModel.notes)
                        }
                    }

                    if let error = viewModel.errorMessage {
                        softPanel {
                            Text(error)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
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

    private func softPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
