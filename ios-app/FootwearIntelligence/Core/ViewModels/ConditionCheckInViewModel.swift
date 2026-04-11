import Foundation

@MainActor
final class ConditionCheckInViewModel: ObservableObject {
    @Published var comfortScore = 4
    @Published var cushioningScore = 4
    @Published var supportScore = 4
    @Published var gripScore = 4
    @Published var upperConditionScore = 4
    @Published var overallConfidenceScore = 4
    @Published var notes = ""
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false

    let footwearItemId: String

    init(footwearItemId: String) {
        self.footwearItemId = footwearItemId
    }

    func save(userId: String) async {
        isSaving = true
        errorMessage = nil
        didSave = false

        do {
            try await APIClient.shared.createConditionLog(
                userId: userId,
                footwearItemId: footwearItemId,
                comfortScore: comfortScore,
                cushioningScore: cushioningScore,
                supportScore: supportScore,
                gripScore: gripScore,
                upperConditionScore: upperConditionScore,
                waterproofingScore: nil,
                overallConfidenceScore: overallConfidenceScore,
                painFlag: false,
                notes: notes.isEmpty ? nil : notes
            )
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}
