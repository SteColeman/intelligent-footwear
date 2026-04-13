import Foundation

struct APIErrorResponse: Decodable {
    struct APIErrorBody: Decodable {
        let code: String
        let message: String
    }

    let error: APIErrorBody
}

struct ConditionLogEntry: Identifiable, Codable {
    let id: String
    let comfortScore: Int
    let cushioningScore: Int
    let supportScore: Int
    let gripScore: Int
    let upperConditionScore: Int
    let waterproofingScore: Int?
    let overallConfidenceScore: Int
    let painFlag: Bool
    let notes: String?
    let photoUrl: String?
    let loggedAt: Date
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL = AppConfig.backendBaseURL
    private init() {}

    func fetchUserProfile(authProviderId: String) async throws -> UserProfile {
        let url = baseURL
            .appendingPathComponent("me")
            .appending(queryItems: [URLQueryItem(name: "authProviderId", value: authProviderId)])

        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder.apiDecoder.decode(UserProfile.self, from: data)
    }

    func bootstrapDemoUserIfNeeded() async throws {
        let url = baseURL.appendingPathComponent("dev/bootstrap-demo-user")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    func markOnboardingComplete(userId: String) async throws {
        let url = baseURL.appendingPathComponent("me/onboarding-complete")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["userId": userId])

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    func markHealthConnected(userId: String) async throws {
        let url = baseURL.appendingPathComponent("me/health-connected")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["userId": userId])

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    func fetchFootwear(userId: String) async throws -> [FootwearItem] {
        let url = baseURL
            .appendingPathComponent("footwear")
            .appending(queryItems: [URLQueryItem(name: "userId", value: userId)])

        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder.apiDecoder.decode([FootwearItem].self, from: data)
    }

    func fetchFootwearDetail(id: String, userId: String) async throws -> FootwearItem {
        let url = baseURL
            .appendingPathComponent("footwear")
            .appendingPathComponent(id)
            .appending(queryItems: [URLQueryItem(name: "userId", value: userId)])

        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder.apiDecoder.decode(FootwearItem.self, from: data)
    }

    func updateFootwearPhoto(userId: String, footwearItemId: String, photoUrl: String?) async throws -> FootwearItem {
        let url = baseURL
            .appendingPathComponent("footwear")
            .appendingPathComponent(footwearItemId)
            .appendingPathComponent("photo")

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode([
            "userId": userId,
            "photoUrl": photoUrl as String?
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
        return try JSONDecoder.apiDecoder.decode(FootwearItem.self, from: data)
    }

    func fetchConditionLogs(footwearItemId: String, userId: String) async throws -> [ConditionLogEntry] {
        let url = baseURL
            .appendingPathComponent("footwear")
            .appendingPathComponent(footwearItemId)
            .appendingPathComponent("condition-logs")
            .appending(queryItems: [URLQueryItem(name: "userId", value: userId)])

        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder.apiDecoder.decode([ConditionLogEntry].self, from: data)
    }

    func fetchHomeSummary(userId: String) async throws -> HomeSummary {
        let url = baseURL
            .appendingPathComponent("home-summary")
            .appending(queryItems: [URLQueryItem(name: "userId", value: userId)])

        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder.apiDecoder.decode(HomeSummary.self, from: data)
    }

    func fetchInsights(userId: String) async throws -> InsightSummary {
        let url = baseURL
            .appendingPathComponent("insights")
            .appending(queryItems: [URLQueryItem(name: "userId", value: userId)])

        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder.apiDecoder.decode(InsightSummary.self, from: data)
    }

    func fetchUnassignedWear(userId: String) async throws -> [WearEvent] {
        let url = baseURL
            .appendingPathComponent("wear-events/unassigned")
            .appending(queryItems: [URLQueryItem(name: "userId", value: userId)])

        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder.apiDecoder.decode([WearEvent].self, from: data)
    }

    func importHealthPayload(_ payload: HealthImportPayload) async throws {
        let url = baseURL.appendingPathComponent("health/import-batch")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    func createAssignment(_ payload: AssignmentRequest) async throws {
        let url = baseURL.appendingPathComponent("assignments")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    func createFootwear(_ payload: CreateFootwearRequest) async throws {
        let url = baseURL.appendingPathComponent("footwear")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    func createConditionLog(
        userId: String,
        footwearItemId: String,
        comfortScore: Int,
        cushioningScore: Int,
        supportScore: Int,
        gripScore: Int,
        upperConditionScore: Int,
        waterproofingScore: Int?,
        overallConfidenceScore: Int,
        painFlag: Bool,
        notes: String?
    ) async throws {
        let url = baseURL.appendingPathComponent("condition-logs")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any?] = [
            "userId": userId,
            "footwearItemId": footwearItemId,
            "comfortScore": comfortScore,
            "cushioningScore": cushioningScore,
            "supportScore": supportScore,
            "gripScore": gripScore,
            "upperConditionScore": upperConditionScore,
            "waterproofingScore": waterproofingScore,
            "overallConfidenceScore": overallConfidenceScore,
            "painFlag": painFlag,
            "notes": notes,
            "photoUrl": nil
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder.apiDecoder.decode(APIErrorResponse.self, from: data) {
                throw NSError(
                    domain: "FootwearIntelligenceAPI",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: apiError.error.message]
                )
            }

            let fallbackMessage = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            throw NSError(
                domain: "FootwearIntelligenceAPI",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: fallbackMessage?.isEmpty == false ? fallbackMessage! : "Request failed with status \(httpResponse.statusCode)"]
            )
        }
    }
}

private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        return components.url!
    }
}

extension JSONDecoder {
    static var apiDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
