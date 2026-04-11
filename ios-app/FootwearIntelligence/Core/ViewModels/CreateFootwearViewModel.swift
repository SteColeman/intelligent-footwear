import Foundation

@MainActor
final class CreateFootwearViewModel: ObservableObject {
    @Published var brand = ""
    @Published var model = ""
    @Published var nickname = ""
    @Published var category = "trainers"
    @Published var isDefaultFallback = false
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

    func save(userId: String) async {
        guard !brand.isEmpty, !model.isEmpty else {
            errorMessage = "Brand and model are required"
            return
        }

        isSaving = true
        errorMessage = nil
        didSave = false

        do {
            let payload = CreateFootwearRequest(
                userId: userId,
                brand: brand,
                model: model,
                nickname: nickname.isEmpty ? nil : nickname,
                category: category,
                purchaseDate: nil,
                startUseDate: nil,
                targetSteps: nil,
                targetDistanceKm: nil,
                isDefaultFallback: isDefaultFallback,
                notes: nil
            )

            try await APIClient.shared.createFootwear(payload)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}
