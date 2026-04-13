import Foundation
import Combine

@MainActor
final class CreateFootwearViewModel: ObservableObject {
    @Published var brand = ""
    @Published var model = ""
    @Published var nickname = ""
    @Published var category = "trainers"
    @Published var isDefaultFallback = false
    @Published var photoUrl = ""
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

    func setLocalPhoto(data: Data) throws {
        let directory = try ensurePhotoDirectory()
        let fileURL = directory.appendingPathComponent("\(UUID().uuidString).jpg")
        try data.write(to: fileURL, options: .atomic)
        photoUrl = fileURL.absoluteString
    }

    func clearLocalPhoto() {
        photoUrl = ""
    }

    func save(userId: String) async {
        guard !brand.isEmpty, !model.isEmpty else {
            errorMessage = "Brand and model are required"
            return
        }

        isSaving = true
        errorMessage = nil
        didSave = false

        do {
            let trimmedPhotoUrl = photoUrl.trimmingCharacters(in: .whitespacesAndNewlines)

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
                photoUrl: trimmedPhotoUrl.isEmpty ? nil : trimmedPhotoUrl,
                notes: nil
            )

            try await APIClient.shared.createFootwear(payload)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    private func ensurePhotoDirectory() throws -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent("FootwearPhotos", isDirectory: true)

        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }
}
