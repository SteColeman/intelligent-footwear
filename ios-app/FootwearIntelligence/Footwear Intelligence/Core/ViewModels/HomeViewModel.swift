import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var summary: HomeSummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            summary = try await APIClient.shared.fetchHomeSummary(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
