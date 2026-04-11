import Foundation

@MainActor
final class FootwearDetailViewModel: ObservableObject {
    @Published var item: FootwearItem?
    @Published var conditionLogs: [ConditionLogEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(footwearItemId: String, userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            async let itemRequest = APIClient.shared.fetchFootwearDetail(id: footwearItemId, userId: userId)
            async let logRequest = APIClient.shared.fetchConditionLogs(footwearItemId: footwearItemId, userId: userId)
            item = try await itemRequest
            conditionLogs = try await logRequest
        } catch {
            errorMessage = error.localizedDescription
            item = nil
            conditionLogs = []
        }

        isLoading = false
    }

    var hasConditionHistory: Bool {
        !conditionLogs.isEmpty
    }
}
