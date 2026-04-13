import Foundation

struct LifecycleSummaryLite: Codable {
    let totalSteps: Int
    let totalDistanceKm: Double
    let retirementRiskLevel: String
    let confidenceScore: Double?
}

struct FootwearItem: Identifiable, Codable {
    let id: String
    let brand: String
    let model: String
    let nickname: String?
    let category: String
    let status: String
    let isDefaultFallback: Bool
    let photoUrl: String?
    let lifecycleSummary: LifecycleSummaryLite?

    var displayName: String {
        if let nickname, !nickname.isEmpty {
            return nickname
        }
        return "\(brand) \(model)"
    }
}
