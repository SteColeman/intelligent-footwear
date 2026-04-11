import Foundation

@MainActor
final class FootwearListViewModel: ObservableObject {
    @Published var items: [FootwearItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            items = try await APIClient.shared.fetchFootwear(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            items = []
        }

        isLoading = false
    }

    var hasNoFootwear: Bool {
        items.isEmpty && !isLoading && errorMessage == nil
    }
}
