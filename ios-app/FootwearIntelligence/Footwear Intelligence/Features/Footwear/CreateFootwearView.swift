import SwiftUI
import PhotosUI

struct CreateFootwearView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = CreateFootwearViewModel()

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: Image?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    SoftUtilityHero(
                        title: "Add footwear",
                        subtitle: "Start with the pair you wear most often so the app can build a useful history around it.",
                        eyebrow: "Start with your real default",
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

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photo")
                            .font(.headline)

                        Text("Choose a real image for this pair. The current prototype stores it locally on the device and uses it as the primary photo.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let selectedImage {
                            selectedImage
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        } else {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color(.tertiarySystemGroupedBackground))
                                .frame(height: 180)
                                .overlay(
                                    VStack(spacing: 10) {
                                        Image(systemName: "photo")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                        Text("No photo selected yet")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        }

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Text(selectedImage == nil ? "Choose photo" : "Change photo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        if selectedImage != nil || !viewModel.photoUrl.isEmpty {
                            Button("Remove photo") {
                                selectedPhotoItem = nil
                                selectedImage = nil
                                viewModel.clearLocalPhoto()
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .softPanelStyle()

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .softPanelStyle()
                    }

                    if let sessionError = session.bootstrapError {
                        Text(sessionError)
                            .foregroundColor(.red)
                            .softPanelStyle()
                    }
                }
                .padding()
            }
            .softUtilityBackground()
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
                            guard viewModel.didSave else { return }

                            await session.completeOnboarding()

                            if session.hasCompletedOnboarding {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .task(id: selectedPhotoItem) {
                guard let selectedPhotoItem else { return }
                await loadPreviewImage(from: selectedPhotoItem)
            }
        }
    }

    private func loadPreviewImage(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = Image(uiImage: uiImage)
                try viewModel.setLocalPhoto(data: data)
            }
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
}
