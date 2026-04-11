import Foundation

struct UserProfile: Codable {
    let id: String
    let authProviderId: String
    let timezone: String?
    let locale: String?
    let onboardingStatus: String
    let healthConnectionStatus: String
}
