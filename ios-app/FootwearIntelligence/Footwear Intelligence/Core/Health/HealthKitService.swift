import Foundation
import HealthKit

struct HealthWorkoutSummary {
    let eventType: String
    let startDate: Date
    let endDate: Date
    let distanceKm: Double?
}

final class HealthKitService {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()

    private init() {}

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthDataAvailable else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let workoutType = HKObjectType.workoutType()

        try await healthStore.requestAuthorization(toShare: [], read: [stepType, distanceType, workoutType])
    }

    func fetchTodayStepCount() async throws -> Double {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: value)
            }
            self.healthStore.execute(query)
        }
    }

    func fetchTodayWalkingRunningDistanceKm() async throws -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return 0 }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = result?.sumQuantity()?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0
                continuation.resume(returning: value)
            }
            self.healthStore.execute(query)
        }
    }

    func fetchTodayRelevantWorkouts() async throws -> [HealthWorkoutSummary] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let workouts = (samples as? [HKWorkout] ?? []).compactMap { workout -> HealthWorkoutSummary? in
                    let activity = workout.workoutActivityType
                    let eventType: String?

                    switch activity {
                    case .walking:
                        eventType = "walking_workout"
                    case .hiking:
                        eventType = "hiking_workout"
                    case .running:
                        eventType = "running_workout"
                    default:
                        eventType = nil
                    }

                    guard let eventType else { return nil }

                    let distance = workout.totalDistance?.doubleValue(for: HKUnit.meterUnit(with: .kilo))
                    return HealthWorkoutSummary(
                        eventType: eventType,
                        startDate: workout.startDate,
                        endDate: workout.endDate,
                        distanceKm: distance
                    )
                }

                continuation.resume(returning: workouts)
            }
            self.healthStore.execute(query)
        }
    }
}
