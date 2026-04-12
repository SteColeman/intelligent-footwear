import SwiftUI

struct CreateFootwearView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = CreateFootwearViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Footwear") {
                    TextField("Brand", text: $viewModel.brand)
                    TextField("Model", text: $viewModel.model)
                    TextField("Nickname (optional)", text: $viewModel.nickname)

                    Picker("Category", selection: $viewModel.category) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }

                    Toggle("Use as default footwear", isOn: $viewModel.isDefaultFallback)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Footwear")
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
                                session.completeOnboarding()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }
}
