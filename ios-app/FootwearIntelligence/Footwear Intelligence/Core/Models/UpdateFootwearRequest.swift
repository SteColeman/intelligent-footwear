import Foundation

struct UpdateFootwearRequest: Codable {
    let userId: String
    let brand: String
    let model: String
    let nickname: String?
    let category: String
    let isDefaultFallback: Bool?
    let status: String?
}
