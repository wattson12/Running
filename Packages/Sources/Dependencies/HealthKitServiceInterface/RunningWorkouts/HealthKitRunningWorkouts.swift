import CoreLocation
import Foundation
import HealthKit

public struct WorkoutDetail: Equatable {
    public let locations: [CLLocation]
    public let samples: [HKCumulativeQuantitySample]

    public init(
        locations: [CLLocation],
        samples: [HKCumulativeQuantitySample]
    ) {
        self.locations = locations
        self.samples = samples
    }
}

public struct HealthKitRunningWorkouts: Sendable {
    public var _allRunningWorkouts: @Sendable () async throws -> [WorkoutType]
    public var _detail: @Sendable (UUID) async throws -> WorkoutDetail

    public init(
        allRunningWorkouts: @Sendable @escaping () async throws -> [WorkoutType],
        detail: @Sendable @escaping (UUID) async throws -> WorkoutDetail
    ) {
        _allRunningWorkouts = allRunningWorkouts
        _detail = detail
    }
}

public extension HealthKitRunningWorkouts {
    func allRunningWorkouts() async throws -> [WorkoutType] {
        try await _allRunningWorkouts()
    }

    func detail(for id: UUID) async throws -> WorkoutDetail {
        try await _detail(id)
    }
}
