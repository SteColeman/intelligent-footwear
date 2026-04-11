import Foundation

struct HomeSummary: Codable {
    struct TodaySummary: Codable {
        let steps: Int
        let distanceKm: Double
    }

    struct UnassignedWearSummary: Codable {
        let count: Int
        let steps: Int
        let distanceKm: Double
    }

    let today: TodaySummary
    let activeFootwear: [FootwearItem]
    let currentDefault: FootwearItem?
    let unassignedWear: UnassignedWearSummary
}
