import Foundation

enum AppConfig {
    static let defaultAuthProviderId = "demo-user"
    private static let fallbackBackendURLString = "http://localhost:3000"

    static var backendBaseURL: URL {
        if let override = ProcessInfo.processInfo.environment["FOOTWEAR_BACKEND_URL"]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !override.isEmpty,
           let url = URL(string: override) {
            return url
        }

        guard let fallbackURL = URL(string: fallbackBackendURLString) else {
            preconditionFailure("Invalid fallback backend URL: \(fallbackBackendURLString)")
        }

        return fallbackURL
    }
}
