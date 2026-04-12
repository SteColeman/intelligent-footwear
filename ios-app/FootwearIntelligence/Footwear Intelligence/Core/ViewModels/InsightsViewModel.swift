import Foundation
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var summary: InsightSummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            summary = try await APIClient.shared.fetchInsights(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            summary = nil
        }

        isLoading = false
    }
}
