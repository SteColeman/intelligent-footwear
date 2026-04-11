import Foundation

struct AssignmentRequest: Codable {
    let userId: String
    let wearEventId: String
    let footwearItemId: String
    let assignmentMethod: String
    let assignmentConfidence: Double?
    let confirmedByUser: Bool?
}
