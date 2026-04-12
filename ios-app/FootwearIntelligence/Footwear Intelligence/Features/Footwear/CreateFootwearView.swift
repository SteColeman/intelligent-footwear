import SwiftUI

struct CreateFootwearView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = CreateFootwearViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Add footwear")
                            .font(.largeTitle)
                            .bold()
                        Text("Start with the pair you wear most often so the app can build a useful history around it.")
                            .foregroundColor(.secondary)
                    }

                    softPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Footwear details")
                                .font(.headline)

                            TextField("Brand", text: $viewModel.brand)
                            TextField("Model", text: $viewModel.model)
                            TextField("Nickname (optional)", text: $viewModel.nickname)

                            Picker("Category", selection: $viewModel.category) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    Text(category.replacingOccurrences(of: "_", with: " ").capitalized).tag(category)
                                }
                            }

                            Toggle("Use as default footwear", isOn: $viewModel.isDefaultFallback)
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

    private func softPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
