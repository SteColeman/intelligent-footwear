import Foundation

struct InsightSummary: Codable {
    let mostWorn: [FootwearItem]
    let needsAttention: [FootwearItem]
    let nearRetirement: [FootwearItem]
    let inactiveHistory: [FootwearItem]
}
