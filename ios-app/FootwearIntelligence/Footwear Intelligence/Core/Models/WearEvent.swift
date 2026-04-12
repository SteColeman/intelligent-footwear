import Foundation

struct WearEvent: Identifiable, Codable {
    let id: String
    let eventDate: Date
    let eventType: String
    let stepsCount: Int?
    let distanceKm: Double?
}
