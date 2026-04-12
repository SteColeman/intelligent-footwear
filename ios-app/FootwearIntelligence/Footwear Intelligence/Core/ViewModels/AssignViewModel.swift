import Foundation
import Combine

@MainActor
final class AssignViewModel: ObservableObject {
    @Published var unassignedWear: [WearEvent] = []
    @Published var footwearItems: [FootwearItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            async let wear = APIClient.shared.fetchUnassignedWear(userId: userId)
            async let footwear = APIClient.shared.fetchFootwear(userId: userId)
            unassignedWear = try await wear
            footwearItems = try await footwear
        } catch {
            errorMessage = error.localizedDescription
            unassignedWear = []
            footwearItems = []
        }

        isLoading = false
    }

    func importTodayHealthData(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let payload = try await HealthImportService.shared.buildTodayPayload(userId: userId)
            try await APIClient.shared.importHealthPayload(payload)
            await load(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func importDemoHealthData(userId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let payload = HealthImportService.shared.buildDemoPayload(userId: userId)
            try await APIClient.shared.importHealthPayload(payload)
            await load(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func assign(userId: String, wearEventId: String, footwearItemId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let payload = AssignmentRequest(
                userId: userId,
                wearEventId: wearEventId,
                footwearItemId: footwearItemId,
                assignmentMethod: "manual",
                assignmentConfidence: 1.0,
                confirmedByUser: true
            )
            try await APIClient.shared.createAssignment(payload)
            await load(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    var hasLoadedAssignableFootwear: Bool {
        !footwearItems.isEmpty
    }
}
