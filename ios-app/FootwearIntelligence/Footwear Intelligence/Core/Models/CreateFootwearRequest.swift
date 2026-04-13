import Foundation

struct CreateFootwearRequest: Codable {
    let userId: String
    let brand: String
    let model: String
    let nickname: String?
    let category: String
    let purchaseDate: String?
    let startUseDate: String?
    let targetSteps: Int?
    let targetDistanceKm: Double?
    let isDefaultFallback: Bool?
    let photoUrl: String?
    let notes: String?
}
