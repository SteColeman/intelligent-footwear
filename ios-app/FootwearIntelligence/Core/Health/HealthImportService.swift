import Foundation
import HealthKit

final class HealthImportService {
    static let shared = HealthImportService()

    private let isoFormatter = ISO8601DateFormatter()

    private init() {}

    func buildTodayPayload(userId: String) async throws -> HealthImportPayload {
        let now = Date()
        let dayStart = Calendar.current.startOfDay(for: now)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? now

        let steps = Int(try await HealthKitService.shared.fetchTodayStepCount())
        let distanceKm = try await HealthKitService.shared.fetchTodayWalkingRunningDistanceKm()
        let workouts = try await HealthKitService.shared.fetchTodayRelevantWorkouts()

        var events: [HealthWearEventPayload] = [
            HealthWearEventPayload(
                eventDate: isoFormatter.string(from: dayStart),
                eventType: "mixed_daily_activity",
                stepsCount: steps,
                distanceKm: distanceKm,
                startTime: isoFormatter.string(from: dayStart),
                endTime: isoFormatter.string(from: dayEnd),
                sourceLabel: "apple_health"
            )
        ]

        events.append(contentsOf: workouts.map {
            HealthWearEventPayload(
                eventDate: isoFormatter.string(from: $0.startDate),
                eventType: $0.eventType,
                stepsCount: nil,
                distanceKm: $0.distanceKm,
                startTime: isoFormatter.string(from: $0.startDate),
                endTime: isoFormatter.string(from: $0.endDate),
                sourceLabel: "apple_health_workout"
            )
        })

        return HealthImportPayload(
            userId: userId,
            importedAt: isoFormatter.string(from: now),
            startRange: isoFormatter.string(from: dayStart),
            endRange: isoFormatter.string(from: dayEnd),
            sourceDevice: "iPhone",
            events: events
        )
    }

    func buildDemoPayload(userId: String) -> HealthImportPayload {
        let now = Date()
        let dayStart = Calendar.current.startOfDay(for: now)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? now

        return HealthImportPayload(
            userId: userId,
            importedAt: isoFormatter.string(from: now),
            startRange: isoFormatter.string(from: dayStart),
            endRange: isoFormatter.string(from: dayEnd),
            sourceDevice: "iPhone",
            events: [
                HealthWearEventPayload(
                    eventDate: isoFormatter.string(from: dayStart),
                    eventType: "mixed_daily_activity",
                    stepsCount: 8000,
                    distanceKm: 5.6,
                    startTime: isoFormatter.string(from: dayStart),
                    endTime: isoFormatter.string(from: dayEnd),
                    sourceLabel: "demo"
                )
            ]
        )
    }
}
