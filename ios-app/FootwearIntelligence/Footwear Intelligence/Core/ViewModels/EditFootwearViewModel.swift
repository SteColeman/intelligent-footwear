import Foundation
import Combine

@MainActor
final class EditFootwearViewModel: ObservableObject {
    @Published var brand: String
    @Published var model: String
    @Published var nickname: String
    @Published var category: String
    @Published var isDefaultFallback: Bool
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false

    let categories = [
        "trainers",
        "walking_shoes",
        "hiking_boots",
        "work_shoes",
        "casual_shoes",
        "other"
    ]

    init(item: FootwearItem) {
        self.brand = item.brand
        self.model = item.model
        self.nickname = item.nickname ?? ""
        self.category = item.category
        self.isDefaultFallback = item.isDefaultFallback
    }

    func save(userId: String, footwearItemId: String) async {
        guard !brand.isEmpty, !model.isEmpty else {
            errorMessage = "Brand and model are required"
            return
        }

        isSaving = true
        errorMessage = nil
        didSave = false

        do {
            let payload = UpdateFootwearRequest(
                userId: userId,
                brand: brand,
                model: model,
                nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : nickname.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                isDefaultFallback: isDefaultFallback
            )

            _ = try await APIClient.shared.updateFootwear(
                userId: userId,
                footwearItemId: footwearItemId,
                payload: payload
            )
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}
