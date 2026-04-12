import Foundation

struct HealthImportPayload: Codable {
    let userId: String
    let importedAt: String
    let startRange: String
    let endRange: String
    let sourceDevice: String?
    let events: [HealthWearEventPayload]
}

struct HealthWearEventPayload: Codable {
    let eventDate: String
    let eventType: String
    let stepsCount: Int?
    let distanceKm: Double?
    let startTime: String?
    let endTime: String?
    let sourceLabel: String?
}
