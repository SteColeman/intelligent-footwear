import SwiftUI

struct EditFootwearView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel: EditFootwearViewModel

    let footwearItemId: String

    init(item: FootwearItem) {
        self.footwearItemId = item.id
        _viewModel = StateObject(wrappedValue: EditFootwearViewModel(item: item))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    SoftUtilityHero(
                        title: "Edit footwear",
                        subtitle: "Update the identity and category of this pair without recreating it.",
                        eyebrow: "Keep the history, refine the record",
                        titleSize: 32
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Footwear details")
                            .font(.title3)
                            .bold()

                        TextField("Brand", text: $viewModel.brand)
                            .textFieldStyle(.roundedBorder)
                        TextField("Model", text: $viewModel.model)
                            .textFieldStyle(.roundedBorder)
                        TextField("Nickname (optional)", text: $viewModel.nickname)
                            .textFieldStyle(.roundedBorder)

                        Picker("Category", selection: $viewModel.category) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                Text(category.replacingOccurrences(of: "_", with: " ").capitalized).tag(category)
                            }
                        }

                        Toggle("Use as default footwear", isOn: $viewModel.isDefaultFallback)
                    }
                    .elevatedPanelStyle()

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .softPanelStyle()
                    }
                }
                .padding()
            }
            .softUtilityBackground()
            .navigationTitle("Edit Footwear")
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
                            await viewModel.save(userId: userId, footwearItemId: footwearItemId)
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
}
