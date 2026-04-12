import Foundation
import SwiftUI
import Combine

@MainActor
final class AppSession: ObservableObject {
    @Published var authProviderId: String = AppConfig.defaultAuthProviderId
    @Published var userId: String?
    @Published var hasCompletedOnboarding: Bool = false
    @Published var healthConnectionStatus: String = "not_connected"
    @Published var isBootstrapping = false
    @Published var bootstrapError: String?

    func bootstrap() async {
        isBootstrapping = true
        bootstrapError = nil
        defer { isBootstrapping = false }

        do {
            try await APIClient.shared.bootstrapDemoUserIfNeeded()
            let profile = try await APIClient.shared.fetchUserProfile(authProviderId: authProviderId)
            userId = profile.id
            healthConnectionStatus = profile.healthConnectionStatus
            hasCompletedOnboarding = profile.onboardingStatus == "onboarding_complete"
        } catch {
            bootstrapError = error.localizedDescription
        }
    }

    func completeOnboarding() async {
        guard let userId else {
            hasCompletedOnboarding = true
            return
        }

        do {
            try await APIClient.shared.markOnboardingComplete(userId: userId)
            hasCompletedOnboarding = true
        } catch {
            bootstrapError = error.localizedDescription
        }
    }

    func markHealthConnected() async {
        guard let userId else {
            healthConnectionStatus = "connected"
            return
        }

        do {
            try await APIClient.shared.markHealthConnected(userId: userId)
            healthConnectionStatus = "connected"
        } catch {
            bootstrapError = error.localizedDescription
        }
    }
}
